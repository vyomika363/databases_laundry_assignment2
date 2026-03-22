const logAction = require("../utils/logger");

function normalizeRole(role) {
  return String(role || "").toLowerCase() === "user"
    ? "customer"
    : String(role || "").toLowerCase();
}

function allowRoles(...allowedRoles) {
  const normalizedAllowed = allowedRoles.map(normalizeRole);

  return (req, res, next) => {
    const userRole = normalizeRole(req.user?.role);

    if (!req.user || !normalizedAllowed.includes(userRole)) {
      logAction(
        req.user || {},
        `Unauthorized access attempt to ${req.originalUrl}`,
        "DENIED"
      );
      return res.status(403).json({ error: "Access denied" });
    }

    next();
  };
}

module.exports = allowRoles;