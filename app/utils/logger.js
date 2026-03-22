const fs = require("fs");
const path = require("path");

const logDir = path.join(__dirname, "..", "logs");
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

const logPath = path.join(logDir, "audit.log");

function logAction(user, action, status) {
  const line = `[${new Date().toISOString()}] user=${
    user?.username || user?.id || "unknown"
  } role=${user?.role || "unknown"} action=${action} status=${status}\n`;

  fs.appendFileSync(logPath, line, "utf8");
}

module.exports = logAction;