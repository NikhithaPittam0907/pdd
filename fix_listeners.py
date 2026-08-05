import os

projects = ['selenium_automation', 'security_automation', 'load_automation']
for proj in projects:
    path = os.path.join(proj, 'src', 'main', 'java', 'com', 'pdd', 'utils', 'ExcelReportListener.java')
    if os.path.exists(path):
        with open(path, 'r') as f:
            content = f.read()
            
        # Update createHeader
        if 'private void createHeader' in content:
            start_idx = content.find('private void createHeader')
            end_idx = content.find('    }', start_idx) + 5
            
            new_header = '''private void createHeader(Sheet sheet) {
        Row row = sheet.createRow(0);
        
        // Styling the header
        CellStyle headerStyle = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        headerStyle.setFont(font);
        
        String[] columns = {"Test Case ID", "Test Module", "Test Name", "Execution Status", "Execution Time (ms)", "Error Details"};
        for (int i = 0; i < columns.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(columns[i]);
            cell.setCellStyle(headerStyle);
            sheet.setColumnWidth(i, 6000); // Set column width
        }
    }'''
            content = content[:start_idx] + new_header + content[end_idx:]

        # Update logTest
        if 'private synchronized void logTest' in content:
            start_idx = content.find('private synchronized void logTest')
            end_idx = content.find('    }', start_idx) + 5
            
            new_log = '''private synchronized void logTest(Sheet sheet, ITestResult result, String status, int rowIndex) {
        Row row = sheet.createRow(rowIndex);
        
        String module = result.getTestClass() != null ? result.getTestClass().getRealClass().getSimpleName() : "Unknown";
        String testId = "TC-" + String.format("%04d", rowIndex);
        
        row.createCell(0).setCellValue(testId);
        row.createCell(1).setCellValue(module);
        row.createCell(2).setCellValue(result.getName());
        row.createCell(3).setCellValue(status);
        row.createCell(4).setCellValue(result.getEndMillis() - result.getStartMillis());
        
        if (result.getThrowable() != null) {
            row.createCell(5).setCellValue(result.getThrowable().getMessage());
        } else {
            row.createCell(5).setCellValue("N/A");
        }
    }'''
            content = content[:start_idx] + new_log + content[end_idx:]
            
        with open(path, 'w') as f:
            f.write(content)
        print(f"Updated {path}")
