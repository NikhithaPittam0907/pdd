const winston = require('winston');
const path = require('path');
const fs = require('fs');

const logsDir = path.resolve(__dirname, '../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.printf(({ timestamp, level, message }) => {
      return `[${timestamp}] [${level.toUpperCase()}]: ${message}`;
    })
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message }) => `[${timestamp}] [${level}]: ${message}`)
      )
    }),
    new winston.transports.File({ filename: path.join(logsDir, 'execution.log') }),
    new winston.transports.File({ filename: path.join(logsDir, 'error.log'), level: 'error' })
  ]
});

module.exports = logger;
