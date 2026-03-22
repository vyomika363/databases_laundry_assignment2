const jwt = require("jsonwebtoken");
const safeLog = require("../utils/logger");

function verifyToken(req, res, next) {
  let token = null;

  const authHeader = req.headers.authorization;
  if (authHeader) {
    token = authHeader.startsWith("Bearer ")
      ? authHeader.split(" ")[1]
      : authHeader;
  }

  if (!token && req.query.token) {
    token = req.query.token;
  }

  if (!token) {
    safeLog(
      null,
      `${req.method} ${req.originalUrl} - Access denied: No token`,
      "FAIL"
    );
    return res.status(401).json({ error: "No session found" });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      // Attempt to decode payload even if invalid to log user info
      let userInfo = null;
      try {
        userInfo = jwt.decode(token);
      } catch (_) {}
      
      safeLog(
        userInfo,
        `${req.method} ${req.originalUrl} - Access denied: Invalid/Expired token`,
        "FAIL"
      );

      return res.status(401).json({ error: "Invalid session token" });
    }

    req.user = decoded;
    next();
  });
}

module.exports = verifyToken;