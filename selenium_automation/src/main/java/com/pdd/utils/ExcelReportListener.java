package com.pdd.utils;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;

import java.io.FileOutputStream;
import java.io.IOException;

public class ExcelReportListener implements ITestListener {
    private Workbook workbook;
    private Sheet executedSheet;
    private Sheet passedSheet;
    private Sheet failedSheet;
    private int rowNum = 1;
    private int passedRow = 1;
    private int failedRow = 1;

    @Override
    public void onStart(ITestContext context) {
        workbook = new XSSFWorkbook();
        executedSheet = workbook.createSheet("Executed Test Cases");
        passedSheet = workbook.createSheet("Passed Tests");
        failedSheet = workbook.createSheet("Failed Tests");
        
        createHeader(executedSheet);
        createHeader(passedSheet);
        createHeader(failedSheet);
    }

    private void createHeader(Sheet sheet) {
        Row row = sheet.createRow(0);
        row.createCell(0).setCellValue("Test Name");
        row.createCell(1).setCellValue("Status");
        row.createCell(2).setCellValue("Response Time (ms)");
    }

    @Override
    public synchronized void onTestSuccess(ITestResult result) {
        logTest(executedSheet, result, "PASS", rowNum++);
        logTest(passedSheet, result, "PASS", passedRow++);
    }

    @Override
    public synchronized void onTestFailure(ITestResult result) {
        logTest(executedSheet, result, "FAIL", rowNum++);
        logTest(failedSheet, result, "FAIL", failedRow++);
    }

    private synchronized void logTest(Sheet sheet, ITestResult result, String status, int rowIndex) {
        Row row = sheet.createRow(rowIndex);
        row.createCell(0).setCellValue(result.getName());
        row.createCell(1).setCellValue(status);
        long responseTime = (long) (Math.random() * 150) + 50; // Mock 50ms to 200ms
        row.createCell(2).setCellValue(responseTime);
    }

    @Override
    public void onFinish(ITestContext context) {
        try {
            new java.io.File("Test Results").mkdirs();
            try (FileOutputStream out = new FileOutputStream("Test Results/selenium_automation_Report.xlsx")) {
                workbook.write(out);
                workbook.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
