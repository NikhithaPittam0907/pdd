const path = require('path');

module.exports = {
  baseUrl: process.env.BASE_URL || 'http://localhost:3000',
  browser: process.env.BROWSER || 'chrome', // 'chrome' | 'firefox' | 'edge'
  headless: process.env.HEADLESS !== 'false', // true by default in CI
  timeout: parseInt(process.env.TIMEOUT || '15000', 10),
  retryCount: 2,
  
  paths: {
    reports: path.resolve(__dirname, '../reports'),
    failures: path.resolve(__dirname, '../reports/failures'),
    screenshots: path.resolve(__dirname, '../screenshots'),
    logs: path.resolve(__dirname, '../logs'),
    excel: path.resolve(__dirname, '../Test Results/Excel'),
    data: path.resolve(__dirname, '../data')
  },

  reactRoutes: [
    { path: '/signin', name: 'SignIn View', hasForm: true },
    { path: '/signup', name: 'SignUp View', hasForm: true },
    { path: '/forgot', name: 'Forgot Password View', hasForm: true },
    { path: '/role', name: 'Role Selection View', hasForm: false },
    { path: '/client', name: 'Client Dashboard', hasForm: false },
    { path: '/lawyer', name: 'Lawyer Dashboard', hasForm: false },
    { path: '/admin', name: 'Admin Dashboard', hasForm: false }
  ]
};
