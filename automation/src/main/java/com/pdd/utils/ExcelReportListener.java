package com.pdd.utils;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ExcelReportListener implements ITestListener {
    private Workbook workbook;
    private Sheet executedSheet;
    private Sheet passedSheet;
    private Sheet failedSheet;
    private Sheet skippedSheet;
    private Sheet metricsSheet;
    private int rowNum = 1;
    private int passedRow = 1;
    private int failedRow = 1;
    private int skippedRow = 1;
    private int totalPassed = 0;
    private int totalFailed = 0;
    private int totalSkipped = 0;

    @Override
    public void onStart(ITestContext context) {
        workbook = new XSSFWorkbook();
        executedSheet = workbook.createSheet("Executed Test Cases");
        passedSheet = workbook.createSheet("Passed Tests");
        failedSheet = workbook.createSheet("Failed Tests");
        skippedSheet = workbook.createSheet("Skipped Tests");
        metricsSheet = workbook.createSheet("Execution Metrics");
        
        createHeader(executedSheet);
        createHeader(passedSheet);
        createHeader(failedSheet);
        createHeader(skippedSheet);
    }

    private void createHeader(Sheet sheet) {
        Row row = sheet.createRow(0);
        
        CellStyle headerStyle = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setColor(IndexedColors.WHITE.getIndex());
        headerStyle.setFont(font);
        headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        
        String[] columns = {
            "Test ID", "Test Name", "Module", "Status", "Duration", 
            "Execution Time", "Device", "Platform", "Screenshot Path", 
            "Failure Reason", "Timestamp"
        };
        for (int i = 0; i < columns.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(columns[i]);
            cell.setCellStyle(headerStyle);
            sheet.setColumnWidth(i, 6000);
        }
    }

    @Override
    public synchronized void onTestSuccess(ITestResult result) {
        totalPassed++;
        logTest(executedSheet, result, "PASS", rowNum++);
        logTest(passedSheet, result, "PASS", passedRow++);
    }

    @Override
    public synchronized void onTestFailure(ITestResult result) {
        totalFailed++;
        logTest(executedSheet, result, "FAIL", rowNum++);
        logTest(failedSheet, result, "FAIL", failedRow++);
    }

    @Override
    public synchronized void onTestSkipped(ITestResult result) {
        totalSkipped++;
        logTest(executedSheet, result, "SKIP", rowNum++);
        logTest(skippedSheet, result, "SKIP", skippedRow++);
    }

    private synchronized void logTest(Sheet sheet, ITestResult result, String status, int rowIndex) {
        Row row = sheet.createRow(rowIndex);
        
        String module = result.getTestClass() != null ? result.getTestClass().getRealClass().getSimpleName() : "Core";
        String testId = "TC-" + String.format("%04d", rowIndex);
        long durationMs = result.getEndMillis() - result.getStartMillis();
        String executionTime = String.format("%.2fs", durationMs / 1000.0);
        String device = System.getenv("EMULATOR_DEVICE") != null ? System.getenv("EMULATOR_DEVICE") : "Android Emulator (Pixel 6)";
        String platform = System.getenv("ANDROID_VERSION") != null ? System.getenv("ANDROID_VERSION") : "Android 12.0 (API 31)";
        String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date(result.getStartMillis()));

        String failureReason = "N/A";
        if (result.getThrowable() != null) {
            failureReason = result.getThrowable().getMessage() != null ? result.getThrowable().getMessage() : result.getThrowable().toString();
        }

        row.createCell(0).setCellValue(testId);
        row.createCell(1).setCellValue(result.getName());
        row.createCell(2).setCellValue(module);
        row.createCell(3).setCellValue(status);
        row.createCell(4).setCellValue(String.valueOf(durationMs));
        row.createCell(5).setCellValue(executionTime);
        row.createCell(6).setCellValue(device);
        row.createCell(7).setCellValue(platform);
        row.createCell(8).setCellValue("N/A");
        row.createCell(9).setCellValue(failureReason);
        row.createCell(10).setCellValue(timestamp);
    }

    @Override
    public void onFinish(ITestContext context) {
        int total = totalPassed + totalFailed + totalSkipped;
        double passRate = total > 0 ? (totalPassed * 100.0 / total) : 0.0;

        Row mHeader = metricsSheet.createRow(0);
        mHeader.createCell(0).setCellValue("Metric");
        mHeader.createCell(1).setCellValue("Value");

        int mRow = 1;
        metricsSheet.createRow(mRow++).createCell(0).setCellValue("Total Executed");
        metricsSheet.getRow(mRow - 1).createCell(1).setCellValue(total);
        metricsSheet.createRow(mRow++).createCell(0).setCellValue("Passed");
        metricsSheet.getRow(mRow - 1).createCell(1).setCellValue(totalPassed);
        metricsSheet.createRow(mRow++).createCell(0).setCellValue("Failed");
        metricsSheet.getRow(mRow - 1).createCell(1).setCellValue(totalFailed);
        metricsSheet.createRow(mRow++).createCell(0).setCellValue("Skipped");
        metricsSheet.getRow(mRow - 1).createCell(1).setCellValue(totalSkipped);
        metricsSheet.createRow(mRow++).createCell(0).setCellValue("Pass Percentage");
        metricsSheet.getRow(mRow - 1).createCell(1).setCellValue(String.format("%.2f%%", passRate));

        File excelDir = new File("Test Results/Excel");
        File reportsLatestDir = new File("reports/latest");
        excelDir.mkdirs();
        reportsLatestDir.mkdirs();

        writeWorkbookToFile(new File(excelDir, "Execution_Report.xlsx"));
        writeWorkbookToFile(new File(reportsLatestDir, "Execution_Report.xlsx"));
    }

    private void writeWorkbookToFile(File targetFile) {
        try (FileOutputStream out = new FileOutputStream(targetFile)) {
            workbook.write(out);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
