const express = require("express");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

const db = require("./db");
const logAction = require("./utils/logger");
const verifyToken = require("./middleware/authMiddleware");
const allowRoles = require("./middleware/roleMiddleware");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname)));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../index.html"));
});

//helpers
function normalizeRole(role) {
  if (!role) return null;
  const r = String(role).toLowerCase();
  if (r === "user") return "customer";
  return r;
}

function safeLog(user, action, status) {
  try {
    logAction(user, action, status);
  } catch (err) {
    console.error("LOGGING ERROR:", err.message);
  }
}

function toInt(value) {
  const n = Number.parseInt(value, 10);
  return Number.isFinite(n) ? n : null;
}

async function queryOne(conn, sql, params = []) {
  const [rows] = await conn.query(sql, params);
  return rows[0] || null;
}

//DB helpers
async function getCustomerByUserId(userId) {
  const [rows] = await db.query(
    "SELECT MemberID, Name, Email, PhoneNumber, Address, Age, RegistrationDate, UserID FROM Customer WHERE UserID = ? LIMIT 1",
    [userId]
  );
  return rows[0] || null;
}

async function getCustomerByMemberId(memberId) {
  const [rows] = await db.query(
    "SELECT MemberID, Name, Email, PhoneNumber, Address, Age, RegistrationDate, UserID FROM Customer WHERE MemberID = ? LIMIT 1",
    [memberId]
  );
  return rows[0] || null;
}

async function getStaffByUserId(userId) {
  const [rows] = await db.query(
    "SELECT StaffID, Name, Role, ContactNumber, UserID FROM Staff WHERE UserID = ? LIMIT 1",
    [userId]
  );
  return rows[0] || null;
}

async function getStaffByStaffId(staffId) {
  const [rows] = await db.query(
    "SELECT StaffID, Name, Role, ContactNumber, UserID FROM Staff WHERE StaffID = ? LIMIT 1",
    [staffId]
  );
  return rows[0] || null;
}

async function getOrderById(orderId) {
  const [rows] = await db.query(
    "SELECT OrderID, MemberID, OrderStatus, Quantity, DeliveryStatus FROM Orders WHERE OrderID = ? LIMIT 1",
    [orderId]
  );
  return rows[0] || null;
}

async function userLinkedElsewhere(conn, userId, excludeType, excludeId) {
  if (excludeType === "customer") {
    const customerOther = await queryOne(
      conn,
      "SELECT COUNT(*) AS cnt FROM Customer WHERE UserID = ? AND MemberID <> ?",
      [userId, excludeId]
    );
    const staffOther = await queryOne(
      conn,
      "SELECT COUNT(*) AS cnt FROM Staff WHERE UserID = ?",
      [userId]
    );
    return (customerOther?.cnt || 0) > 0 || (staffOther?.cnt || 0) > 0;
  }

  if (excludeType === "staff") {
    const staffOther = await queryOne(
      conn,
      "SELECT COUNT(*) AS cnt FROM Staff WHERE UserID = ? AND StaffID <> ?",
      [userId, excludeId]
    );
    const customerOther = await queryOne(
      conn,
      "SELECT COUNT(*) AS cnt FROM Customer WHERE UserID = ?",
      [userId]
    );
    return (staffOther?.cnt || 0) > 0 || (customerOther?.cnt || 0) > 0;
  }

  return false;
}

//LOGIN
app.post("/login", async (req, res) => {
  const { username, password, role, adminCode } = req.body;

  if (!username || !password) {
    safeLog({ username }, "Login attempt missing parameters", "FAILED");
    return res.status(400).json({ error: "Missing parameters" });
  }

  try {
    const [users] = await db.query(
      "SELECT * FROM Users WHERE Username = ? LIMIT 1",
      [username]
    );

    if (users.length === 0) {
      safeLog({ username }, "Login failed - user not found", "FAILED");
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const account = users[0];
    const accountRole = normalizeRole(account.Role);
    const requestedRole = normalizeRole(role);

    if (password !== account.Password) {
      safeLog({ username }, "Login failed - wrong password", "FAILED");
      return res.status(401).json({ error: "Invalid credentials" });
    }

    if (requestedRole && requestedRole !== accountRole) {
      safeLog(
        { username, role: requestedRole },
        `Login failed - role mismatch (expected ${accountRole})`,
        "FAILED"
      );
      return res.status(401).json({ error: "Invalid credentials" });
    }

    if (accountRole === "admin") {
      if (!adminCode || adminCode !== process.env.ADMIN_SECRET) {
        safeLog({ username }, "Login failed - invalid admin code", "FAILED");
        return res.status(403).json({ error: "Invalid admin code" });
      }
    }

    const token = jwt.sign(
      {
        id: account.UserID,
        username: account.Username,
        role: accountRole
      },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    safeLog({ username: account.Username, role: accountRole }, "Login successful", "SUCCESS");

    res.json({
      token,
      role: accountRole,
      username: account.Username
    });
  } catch (err) {
    safeLog({ username }, `Login error: ${err.message}`, "ERROR");
    res.status(500).json({ error: err.message });
  }
});

//AUTH CHECK
app.get("/isAuth", verifyToken, (req, res) => {
  const expiry = req.user?.exp ? new Date(req.user.exp * 1000).toISOString() : null;

  res.json({
    message: "User is authenticated",
    username: req.user.username,
    role: req.user.role,
    expiry
  });
});

//DASHBOARD
app.get("/dashboard", verifyToken, async (req, res) => {
  try {
    const role = normalizeRole(req.user.role);

    if (role === "customer") {
      const customer = await getCustomerByUserId(req.user.id);
      if (!customer) return res.status(404).json({ error: "Customer not found" });

      const [orders] = await db.query(
        `
        SELECT 
          o.OrderID,
          o.MemberID,
          o.OrderStatus,
          o.Quantity,
          o.DeliveryStatus,
          p.PickupDate,
          p.PickupTime,
          d.DeliveryDate,
          d.DeliveryTime
        FROM Orders o
        LEFT JOIN Pickup p ON p.OrderID = o.OrderID
        LEFT JOIN Delivery d ON d.OrderID = o.OrderID
        WHERE o.MemberID = ?
        ORDER BY o.OrderID DESC
        `,
        [customer.MemberID]
      );

      return res.json({
        role: "customer",
        username: req.user.username,
        profile: customer,
        orders
      });
    }

    if (role === "staff") {
      const staff = await getStaffByUserId(req.user.id);
      if (!staff) return res.status(404).json({ error: "Staff not found" });

      const [pickups] = await db.query(
        `
        SELECT 
          p.OrderID,
          c.Name AS CustomerName,
          p.PickupDate,
          p.PickupTime
        FROM Pickup p
        LEFT JOIN Orders o ON o.OrderID = p.OrderID
        LEFT JOIN Customer c ON c.MemberID = o.MemberID
        WHERE p.StaffID = ?
        ORDER BY p.PickupDate DESC, p.PickupTime DESC
        `,
        [staff.StaffID]
      );

      const [deliveries] = await db.query(
        `
        SELECT 
          d.OrderID,
          c.Name AS CustomerName,
          d.DeliveryDate,
          d.DeliveryTime
        FROM Delivery d
        LEFT JOIN Orders o ON o.OrderID = d.OrderID
        LEFT JOIN Customer c ON c.MemberID = o.MemberID
        WHERE d.StaffID = ?
        ORDER BY d.DeliveryDate DESC, d.DeliveryTime DESC
        `,
        [staff.StaffID]
      );

      return res.json({
        role: "staff",
        username: req.user.username,
        profile: staff,
        pickups,
        deliveries
      });
    }

    if (role === "admin") {
      const [orders] = await db.query(
        `
        SELECT 
          o.OrderID,
          o.MemberID,
          c.Name AS CustomerName,
          o.OrderStatus,
          o.Quantity,
          o.DeliveryStatus
        FROM Orders o
        LEFT JOIN Customer c ON c.MemberID = o.MemberID
        ORDER BY o.OrderID DESC
        `
      );

      const [customers] = await db.query(
        `
        SELECT 
          c.MemberID,
          c.Name,
          c.Email,
          c.PhoneNumber,
          c.Address,
          c.Age,
          c.RegistrationDate,
          c.UserID,
          u.Username
        FROM Customer c
        LEFT JOIN Users u ON u.UserID = c.UserID
        ORDER BY c.MemberID DESC
        `
      );

      const [staffMembers] = await db.query(
        `
        SELECT 
          s.StaffID,
          s.Name,
          s.Role,
          s.ContactNumber,
          s.UserID,
          u.Username
        FROM Staff s
        LEFT JOIN Users u ON u.UserID = s.UserID
        ORDER BY s.StaffID DESC
        `
      );

      return res.json({
        role: "admin",
        username: req.user.username,
        orders,
        customers,
        staffMembers
      });
    }

    return res.status(403).json({ error: "Access denied" });
  } catch (err) {
    console.error("DASHBOARD ERROR:", err);
    res.status(500).json({ error: "Database error" });
  }
});

//CUSTOMER PORTFOLIO UPDATE
app.put(
  "/me/customer",
  verifyToken,
  allowRoles("customer"),
  async (req, res) => {
    const { name, email, phoneNumber, address, age } = req.body;

    try {
      const customer = await getCustomerByUserId(req.user.id);
      if (!customer) return res.status(404).json({ error: "Customer not found" });

      const newName = name || customer.Name;
      const newEmail = email || customer.Email;
      const newPhone = phoneNumber || customer.PhoneNumber;
      const newAddress = address || customer.Address;
      const newAge = age !== undefined && age !== "" ? toInt(age) : customer.Age;

      await db.query(
        `
        UPDATE Customer
        SET Name = ?, Email = ?, PhoneNumber = ?, Address = ?, Age = ?
        WHERE MemberID = ?
        `,
        [newName, newEmail, newPhone, newAddress, newAge, customer.MemberID]
      );

      safeLog(req.user, "Updated own customer profile", "SUCCESS");

      res.json({ message: "Profile updated" });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Database error" });
    }
  }
);

//ORDER LIST
app.get("/orders", verifyToken, async (req, res) => {
  try {
    const role = normalizeRole(req.user.role);

    if (role === "admin") {
      const [orders] = await db.query(
        `
        SELECT 
          o.OrderID,
          o.MemberID,
          c.Name AS CustomerName,
          o.OrderStatus,
          o.Quantity,
          o.DeliveryStatus
        FROM Orders o
        LEFT JOIN Customer c ON c.MemberID = o.MemberID
        ORDER BY o.OrderID DESC
        `
      );
      return res.json({ orders });
    }

    if (role === "customer") {
      const customer = await getCustomerByUserId(req.user.id);
      if (!customer) return res.status(404).json({ error: "Customer not found" });

      const [orders] = await db.query(
        `
        SELECT 
          OrderID, 
          MemberID,
          OrderStatus, 
          Quantity, 
          DeliveryStatus
        FROM Orders
        WHERE MemberID = ?
        ORDER BY OrderID DESC
        `,
        [customer.MemberID]
      );

      return res.json({ orders });
    }

    return res.status(403).json({ error: "Access denied" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

//CREATE ORDER
app.post(
  "/orders",
  verifyToken,
  allowRoles("admin", "customer"),
  async (req, res) => {
    const { memberId, orderStatus, quantity, deliveryStatus } = req.body;

    try {
      let finalMemberId = memberId;

      if (req.user.role === "customer") {
        const customer = await getCustomerByUserId(req.user.id);
        if (!customer) return res.status(404).json({ error: "Customer not found" });
        finalMemberId = customer.MemberID;
      }

      const qty = toInt(quantity);
      if (!finalMemberId || !orderStatus || !qty || qty <= 0) {
        return res.status(400).json({ error: "Missing or invalid parameters" });
      }

      const customerExists = await getCustomerByMemberId(finalMemberId);
      if (!customerExists) {
        return res.status(400).json({ error: "MemberID does not exist in Customer table" });
      }

      const [result] = await db.query(
        `
        INSERT INTO Orders (MemberID, OrderStatus, Quantity, DeliveryStatus)
        VALUES (?, ?, ?, ?)
        `,
        [finalMemberId, orderStatus, qty, deliveryStatus || "Pending"]
      );

      safeLog(req.user, `Created order ${result.insertId}`, "SUCCESS");

      res.json({
        message: "Order created",
        orderId: result.insertId
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Database error" });
    }
  }
);

//UPDATE ORDER
app.put(
  "/orders/:id",
  verifyToken,
  allowRoles("admin", "customer"),
  async (req, res) => {
    const orderId = req.params.id;
    const { orderStatus, quantity, deliveryStatus } = req.body;

    try {
      const existing = await getOrderById(orderId);
      if (!existing) return res.status(404).json({ error: "Order not found" });

      if (req.user.role === "customer") {
        const customer = await getCustomerByUserId(req.user.id);
        if (!customer) return res.status(404).json({ error: "Customer not found" });

        if (Number(existing.MemberID) !== Number(customer.MemberID)) {
          safeLog(req.user, `Unauthorized order edit attempt on ${orderId}`, "DENIED");
          return res.status(403).json({ error: "You can only edit your own order" });
        }
      }

      const newStatus = orderStatus ?? existing.OrderStatus;
      const newQty = quantity !== undefined && quantity !== "" ? toInt(quantity) : existing.Quantity;
      const newDelivery = deliveryStatus ?? existing.DeliveryStatus;

      if (!newQty || newQty <= 0) {
        return res.status(400).json({ error: "Invalid quantity" });
      }

      await db.query(
        `
        UPDATE Orders
        SET OrderStatus = ?, Quantity = ?, DeliveryStatus = ?
        WHERE OrderID = ?
        `,
        [newStatus, newQty, newDelivery, orderId]
      );

      safeLog(req.user, `Updated order ${orderId}`, "SUCCESS");

      res.json({ message: "Order updated" });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Database error" });
    }
  }
);

//DELETE ORDER
app.delete(
  "/orders/:id",
  verifyToken,
  allowRoles("admin"),
  async (req, res) => {
    const orderId = req.params.id;

    try {
      const existing = await getOrderById(orderId);
      if (!existing) return res.status(404).json({ error: "Order not found" });

      await db.query("DELETE FROM Orders WHERE OrderID = ?", [orderId]);

      safeLog(req.user, `Deleted order ${orderId}`, "SUCCESS");

      res.json({ message: "Deleted" });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Database error" });
    }
  }
);

//ADMIN: GET CUSTOMERS
app.get("/customers", verifyToken, allowRoles("admin"), async (req, res) => {
  try {
    const [customers] = await db.query(
      `
      SELECT 
        c.MemberID,
        c.Name,
        c.Email,
        c.PhoneNumber,
        c.Address,
        c.Age,
        c.RegistrationDate,
        c.UserID,
        u.Username
      FROM Customer c
      LEFT JOIN Users u ON u.UserID = c.UserID
      ORDER BY c.MemberID DESC
      `
    );

    res.json({ customers });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

//ADMIN: UPDATE CUSTOMER
app.put("/customers/:id", verifyToken, allowRoles("admin"), async (req, res) => {
  const memberId = req.params.id;
  const { name, email, phoneNumber, address, age } = req.body;

  try {
    const customer = await getCustomerByMemberId(memberId);
    if (!customer) return res.status(404).json({ error: "Customer not found" });

    const newName = name || customer.Name;
    const newEmail = email || customer.Email;
    const newPhone = phoneNumber || customer.PhoneNumber;
    const newAddress = address || customer.Address;
    const newAge = age !== undefined && age !== "" ? toInt(age) : customer.Age;

    await db.query(
      `
      UPDATE Customer
      SET Name = ?, Email = ?, PhoneNumber = ?, Address = ?, Age = ?
      WHERE MemberID = ?
      `,
      [newName, newEmail, newPhone, newAddress, newAge, memberId]
    );

    safeLog(req.user, `Updated customer ${memberId}`, "SUCCESS");

    res.json({ message: "Customer updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

//ADMIN: ADD CUSTOMER
app.post("/customers", verifyToken, allowRoles("admin"), async (req, res) => {
  const { memberId, name, email, phoneNumber, address, age, username, password } = req.body;

  try {
    if (!memberId || !name || !username || !password) {
      return res.status(400).json({ error: "MemberID, Name, Username, and Password are required" });
    }

    //Create user
    const [existingUser] = await db.query("SELECT UserID FROM Users WHERE Username = ?", [username]);
    if (existingUser.length) {
      return res.status(400).json({ error: "Username already exists" });
    }

    const [userResult] = await db.query(
      "INSERT INTO Users (Username, Password, Role) VALUES (?, ?, 'customer')",
      [username, password]
    );
    const newUserId = userResult.insertId;

    //Insert customer
    const [existingMember] = await db.query("SELECT MemberID FROM Customer WHERE MemberID = ?", [memberId]);
    if (existingMember.length) return res.status(400).json({ error: "MemberID exists" });

    const ageKey = age ? parseInt(age, 10) : null;
    await db.query(
      `INSERT INTO Customer (MemberID, Name, Email, PhoneNumber, Address, Age, RegistrationDate, UserID)
       VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)`,
      [parseInt(memberId, 10), name, email || null, phoneNumber || null, address || null, ageKey, newUserId]
    );

    safeLog(req.user, `Created customer ${memberId}`, "SUCCESS");

    res.json({ message: "Customer and user added successfully", userId: newUserId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});
//ADMIN: SAFE DELETE CUSTOMER
app.delete("/customers/:id", verifyToken, allowRoles("admin"), async (req, res) => {
  const memberId = req.params.id;
  const conn = await db.getConnection();

  try {
    await conn.beginTransaction();

    const customer = await queryOne(
      conn,
      "SELECT MemberID, UserID FROM Customer WHERE MemberID = ? LIMIT 1",
      [memberId]
    );

    if (!customer) {
      await conn.rollback();
      return res.status(404).json({ error: "Customer not found" });
    }

    const orderCountRow = await queryOne(
      conn,
      "SELECT COUNT(*) AS cnt FROM Orders WHERE MemberID = ?",
      [memberId]
    );

    if ((orderCountRow?.cnt || 0) > 0) {
      await conn.rollback();
      safeLog(req.user, `Blocked customer delete ${memberId} because orders exist`, "DENIED");
      return res.status(409).json({
        error: "Cannot delete customer with existing orders"
      });
    }

    await conn.query("DELETE FROM Customer WHERE MemberID = ?", [memberId]);

    const userLinked = customer.UserID;
    if (userLinked) {
      const stillLinked = await userLinkedElsewhere(conn, userLinked, "customer", memberId);
      if (!stillLinked) {
        await conn.query("DELETE FROM Users WHERE UserID = ?", [userLinked]);
      }
    }

    await conn.commit();

    safeLog(req.user, `Deleted customer ${memberId}`, "SUCCESS");
    res.json({ message: "Customer deleted safely" });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ error: "Database error" });
  } finally {
    conn.release();
  }
});

//ADMIN: GET STAFF
app.get("/staff", verifyToken, allowRoles("admin"), async (req, res) => {
  try {
    const [staffMembers] = await db.query(
      `
      SELECT 
        s.StaffID,
        s.Name,
        s.Role,
        s.ContactNumber,
        s.UserID,
        u.Username
      FROM Staff s
      LEFT JOIN Users u ON u.UserID = s.UserID
      ORDER BY s.StaffID DESC
      `
    );

    res.json({ staffMembers });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

//ADMIN: UPDATE STAFF
app.put("/staff/:id", verifyToken, allowRoles("admin"), async (req, res) => {
  const staffId = req.params.id;
  const { name, role, contactNumber } = req.body;

  try {
    const staff = await getStaffByStaffId(staffId);
    if (!staff) return res.status(404).json({ error: "Staff not found" });

    const newName = name || staff.Name;
    const newRole = role || staff.Role;
    const newContact = contactNumber || staff.ContactNumber;

    await db.query(
      `
      UPDATE Staff
      SET Name = ?, Role = ?, ContactNumber = ?
      WHERE StaffID = ?
      `,
      [newName, newRole, newContact, staffId]
    );

    safeLog(req.user, `Updated staff ${staffId}`, "SUCCESS");

    res.json({ message: "Staff updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

//ADMIN: ADD STAFF
app.post("/staff", verifyToken, allowRoles("admin"), async (req, res) => {
  const { staffId, name, role, contactNumber, userId } = req.body;

  try {
    const staffKey = toInt(staffId);
    const userKey = toInt(userId);

    if (!staffKey || !name || !userKey) {
      return res.status(400).json({ error: "StaffID, Name, and UserID are required" });
    }

    const [existing] = await db.query(
      "SELECT StaffID FROM Staff WHERE StaffID = ?",
      [staffKey]
    );
    if (existing.length) {
      return res.status(400).json({ error: "StaffID exists" });
    }

    const [userRows] = await db.query(
      "SELECT UserID FROM Users WHERE UserID = ?",
      [userKey]
    );
    if (!userRows.length) {
      return res.status(400).json({ error: "UserID invalid" });
    }

    const [userUsedInCustomer] = await db.query(
      "SELECT MemberID FROM Customer WHERE UserID = ?",
      [userKey]
    );
    const [userUsedInStaff] = await db.query(
      "SELECT StaffID FROM Staff WHERE UserID = ?",
      [userKey]
    );

    if (userUsedInCustomer.length || userUsedInStaff.length) {
      return res.status(400).json({ error: "UserID already linked to another member" });
    }

    await db.query(
      "INSERT INTO Staff (StaffID, Name, Role, ContactNumber, UserID) VALUES (?, ?, ?, ?, ?)",
      [staffKey, name, role || null, contactNumber || null, userKey]
    );

    safeLog(req.user, `Created staff ${staffKey}`, "SUCCESS");

    res.json({ message: "Staff added" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Database error" });
  }
});

//ADMIN: SAFE DELETE STAFF
app.delete("/staff/:id", verifyToken, allowRoles("admin"), async (req, res) => {
  const staffId = req.params.id;
  const conn = await db.getConnection();

  try {
    await conn.beginTransaction();

    const staff = await queryOne(
      conn,
      "SELECT StaffID, UserID FROM Staff WHERE StaffID = ? LIMIT 1",
      [staffId]
    );

    if (!staff) {
      await conn.rollback();
      return res.status(404).json({ error: "Staff not found" });
    }

    const pickupCount = await queryOne(
      conn,
      "SELECT COUNT(*) AS cnt FROM Pickup WHERE StaffID = ?",
      [staffId]
    );

    const deliveryCount = await queryOne(
      conn,
      "SELECT COUNT(*) AS cnt FROM Delivery WHERE StaffID = ?",
      [staffId]
    );

    if ((pickupCount?.cnt || 0) > 0 || (deliveryCount?.cnt || 0) > 0) {
      await conn.rollback();
      safeLog(req.user, `Blocked staff delete ${staffId} because assignments exist`, "DENIED");
      return res.status(409).json({
        error: "Cannot delete staff with existing pickup/delivery assignments"
      });
    }

    await conn.query("DELETE FROM Staff WHERE StaffID = ?", [staffId]);

    const userLinked = staff.UserID;
    if (userLinked) {
      const stillLinked = await userLinkedElsewhere(conn, userLinked, "staff", staffId);
      if (!stillLinked) {
        await conn.query("DELETE FROM Users WHERE UserID = ?", [userLinked]);
      }
    }

    await conn.commit();

    safeLog(req.user, `Deleted staff ${staffId}`, "SUCCESS");
    res.json({ message: "Staff deleted safely" });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ error: "Database error" });
  } finally {
    conn.release();
  }
});

//OPTIONAL ADMIN LOG VIEW
app.get("/logs", verifyToken, allowRoles("admin"), (req, res) => {
  const fs = require("fs");
  const logPath = path.join(__dirname, "logs", "audit.log");

  try {
    const logs = fs.existsSync(logPath) ? fs.readFileSync(logPath, "utf8") : "";
    res.json({ logs });
  } catch (err) {
    res.status(500).json({ error: "Could not read logs" });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log("Server running on port " + PORT);
});