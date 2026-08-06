const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');
const config = require('../config/config');
const logger = require('./WinstonLogger');

class ExcelReporter {
  constructor() {
    this.testRecords = [];
    this.failedRecords = [];
    this.logRecords = [];
    this.startTime = Date.now();
  }

  recordTest(id, moduleName, scenarioName, browser, status, durationMs, errorMsg = 'N/A', screenshot = 'N/A', url = 'N/A') {
    const record = {
      id: id || `TC-${String(this.testRecords.length + 1).padStart(3, '0')}`,
      module: moduleName || 'General E2E',
      name: scenarioName,
      browser: browser || config.browser,
      status: status.toUpperCase(),
      startTime: new Date(Date.now() - durationMs).toISOString(),
      endTime: new Date().toISOString(),
      duration: `${(durationMs / 1000).toFixed(2)}s`,
      durationMs,
      error: errorMsg,
      screenshot,
      url
    };

    this.testRecords.push(record);

    if (record.status === 'FAIL') {
      this.failedRecords.push({
        name: scenarioName,
        error: errorMsg,
        screenshot: screenshot,
        browser: record.browser,
        url: url
      });
    }

    this.logRecords.push({
      timestamp: new Date().toISOString(),
      name: scenarioName,
      step: `Executed ${scenarioName}`,
      result: record.status,
      remarks: record.status === 'FAIL' ? errorMsg : 'Completed successfully'
    });
  }

  async generateReport(customFileName = 'E2E_Report.xlsx') {
    logger.info(`Generating Multi-Sheet Excel Report [${customFileName}]...`);
    const workbook = new ExcelJS.Workbook();

    const summarySheet = workbook.addWorksheet('Summary');
    const casesSheet = workbook.addWorksheet('Test Cases');
    const failedSheet = workbook.addWorksheet('Failed Tests');
    const logsSheet = workbook.addWorksheet('Execution Logs');

    // 1. Sheet 1: Summary
    summarySheet.columns = [
      { header: 'Metric', key: 'metric', width: 28 },
      { header: 'Value', key: 'value', width: 35 }
    ];
    summarySheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFF' } };
    summarySheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '001A3A' } };

    let passed = 0, failed = 0, skipped = 0;
    let totalDurationMs = 0;
    this.testRecords.forEach(r => {
      if (r.status === 'PASS' || r.status === 'PASSED') passed++;
      else if (r.status === 'FAIL' || r.status === 'FAILED') failed++;
      else skipped++;
      totalDurationMs += r.durationMs || 0;
    });

    const total = this.testRecords.length;
    const passRate = total > 0 ? ((passed / total) * 100).toFixed(2) : '0.00';
    const totalDurationSec = ((Date.now() - this.startTime) / 1000).toFixed(2);

    summarySheet.addRow({ metric: 'Execution Date', value: new Date().toUTCString() });
    summarySheet.addRow({ metric: 'Environment', value: process.env.NODE_ENV || 'Production Staging' });
    summarySheet.addRow({ metric: 'Target Browser', value: config.browser.toUpperCase() });
    summarySheet.addRow({ metric: 'Total Tests', value: total });
    summarySheet.addRow({ metric: 'Passed', value: passed });
    summarySheet.addRow({ metric: 'Failed', value: failed });
    summarySheet.addRow({ metric: 'Skipped', value: skipped });
    summarySheet.addRow({ metric: 'Pass Percentage', value: `${passRate}%` });
    summarySheet.addRow({ metric: 'Execution Duration', value: `${totalDurationSec}s` });

    // 2. Sheet 2: Test Cases
    casesSheet.columns = [
      { header: 'Test ID', key: 'id', width: 15 },
      { header: 'Module', key: 'module', width: 25 },
      { header: 'Scenario Name', key: 'name', width: 45 },
      { header: 'Browser', key: 'browser', width: 15 },
      { header: 'Status', key: 'status', width: 12 },
      { header: 'Start Time', key: 'startTime', width: 25 },
      { header: 'End Time', key: 'endTime', width: 25 },
      { header: 'Duration', key: 'duration', width: 15 }
    ];
    casesSheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFF' } };
    casesSheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '001A3A' } };
    this.testRecords.forEach(r => casesSheet.addRow(r));

    // 3. Sheet 3: Failed Tests
    failedSheet.columns = [
      { header: 'Test Name', key: 'name', width: 45 },
      { header: 'Failure Reason', key: 'error', width: 45 },
      { header: 'Screenshot Path', key: 'screenshot', width: 40 },
      { header: 'Browser', key: 'browser', width: 15 },
      { header: 'URL', key: 'url', width: 35 }
    ];
    failedSheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFF' } };
    failedSheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'C62828' } };
    this.failedRecords.forEach(r => failedSheet.addRow(r));

    // 4. Sheet 4: Execution Logs
    logsSheet.columns = [
      { header: 'Timestamp', key: 'timestamp', width: 25 },
      { header: 'Test Name', key: 'name', width: 40 },
      { header: 'Step Description', key: 'step', width: 45 },
      { header: 'Result', key: 'result', width: 12 },
      { header: 'Remarks', key: 'remarks', width: 45 }
    ];
    logsSheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFF' } };
    logsSheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: '001A3A' } };
    this.logRecords.forEach(r => logsSheet.addRow(r));

    const targetDir = config.paths.reports;
    const excelDir = config.paths.excel;

    [targetDir, excelDir].forEach(dir => {
      if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    });

    const e2eReportPath = path.join(targetDir, customFileName);
    const excelReportPath = path.join(excelDir, 'Execution_Report.xlsx');

    await workbook.xlsx.writeFile(e2eReportPath);
    await workbook.xlsx.writeFile(excelReportPath);

    logger.info(`✔ Multi-Sheet Excel Reports saved to:\n  - ${e2eReportPath}\n  - ${excelReportPath}`);
  }
}

module.exports = ExcelReporter;
