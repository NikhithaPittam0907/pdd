const ExcelJS = require('exceljs');
const fs = require('fs');
const path = require('path');

async function generateFinalReport() {
    console.log("Generating Final Excel Report...");
    
    const dataPath = path.resolve(__dirname, './data/Test_Cases_Master.xlsx');
    if (!fs.existsSync(dataPath)) {
        console.error("Test data not found!");
        return;
    }

    const inputWorkbook = new ExcelJS.Workbook();
    await inputWorkbook.xlsx.readFile(dataPath);
    
    const inputSheet = inputWorkbook.getWorksheet('Executed Test Cases');
    
    const outputWorkbook = new ExcelJS.Workbook();
    const allSheet = outputWorkbook.addWorksheet('Executed Test Cases');
    const passedSheet = outputWorkbook.addWorksheet('Passed Tests');
    const failedSheet = outputWorkbook.addWorksheet('Failed Tests');
    const skippedSheet = outputWorkbook.addWorksheet('Skipped Tests');
    const metricsSheet = outputWorkbook.addWorksheet('Execution Metrics');
    
    // Copy headers
    const headers = [
        { header: 'Test ID', key: 'id', width: 15 },
        { header: 'Module', key: 'module', width: 25 },
        { header: 'Test Name', key: 'name', width: 40 },
        { header: 'Priority', key: 'priority', width: 10 },
        { header: 'Preconditions', key: 'preconditions', width: 30 },
        { header: 'Test Steps', key: 'steps', width: 50 },
        { header: 'Test Data', key: 'data', width: 25 },
        { header: 'Expected Result', key: 'expected', width: 40 },
        { header: 'Actual Result', key: 'actual', width: 40 },
        { header: 'Status', key: 'status', width: 15 },
        { header: 'Execution Time', key: 'time', width: 15 }
    ];

    [allSheet, passedSheet, failedSheet, skippedSheet].forEach(sheet => {
        sheet.columns = headers;
        sheet.getRow(1).font = { bold: true };
    });

    let passed = 0, failed = 0, skipped = 0, total = 0;

    inputSheet.eachRow((row, rowNumber) => {
        if (rowNumber > 1) {
            const rowData = {
                id: row.getCell(1).value,
                module: row.getCell(2).value,
                name: row.getCell(3).value,
                priority: row.getCell(4).value,
                preconditions: row.getCell(5).value,
                steps: row.getCell(6).value,
                data: row.getCell(7).value,
                expected: row.getCell(8).value,
                actual: row.getCell(9).value,
                status: row.getCell(10).value,
                time: row.getCell(11).value
            };
            
            allSheet.addRow(rowData);
            total++;

            if (rowData.status === 'Passed') { passedSheet.addRow(rowData); passed++; }
            else if (rowData.status === 'Failed') { failedSheet.addRow(rowData); failed++; }
            else if (rowData.status === 'Skipped') { skippedSheet.addRow(rowData); skipped++; }
        }
    });

    metricsSheet.columns = [
        { header: 'Metric', key: 'metric', width: 25 },
        { header: 'Value', key: 'value', width: 15 }
    ];
    metricsSheet.getRow(1).font = { bold: true };
    
    metricsSheet.addRow({ metric: 'Total Tests Executed', value: total });
    metricsSheet.addRow({ metric: 'Passed', value: passed });
    metricsSheet.addRow({ metric: 'Failed', value: failed });
    metricsSheet.addRow({ metric: 'Skipped', value: skipped });
    metricsSheet.addRow({ metric: 'Pass Percentage', value: `${((passed / total) * 100).toFixed(2)}%` });

    // Output files
    const outputDir = path.resolve(__dirname, './Test Results/Excel');
    if (!fs.existsSync(outputDir)){
        fs.mkdirSync(outputDir, { recursive: true });
    }
    
    const outputPath = path.join(outputDir, 'Automation_Test_Report.xlsx');
    await outputWorkbook.xlsx.writeFile(outputPath);
    
    console.log(`Final Report Generated at: ${outputPath}`);
}

generateFinalReport().catch(console.error);
