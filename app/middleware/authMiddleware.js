const jwt = require("jsonwebtoken");

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
    return res.status(401).json({ error: "No session found" });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(401).json({ error: "Invalid session token" });
    }

    req.user = decoded;
    next();
  });
}

module.exports = verifyToken;