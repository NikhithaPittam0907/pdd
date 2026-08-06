# Enterprise Selenium WebDriver E2E Automation Framework for React (Node.js)

Welcome to the enterprise-grade **Selenium WebDriver E2E Automation Framework** built for React applications using **Node.js, Mocha, Chai, ExcelJS, Mochawesome, and Winston Logger**.

---

## Key Features

- **Page Object Model (POM)**: Decoupled UI page objects (`BasePage`, `SignInPage`, `SignUpPage`, `DashboardPage`).
- **Dynamic React Route & Form Discovery**: `FormDiscoveryUtil` dynamically navigates React routes (`/signin`, `/signup`, `/forgot`, `/role`, etc.), inspects DOM input elements and validation rules, and constructs E2E validation test cases.
- **Enterprise Multi-Sheet Excel Reporting**: Generates `E2E_Report.xlsx` & `Execution_Report.xlsx` with 4 sheets:
  1. **Summary**: Execution Metrics, Date, Environment, Pass Rate.
  2. **Test Cases**: Test ID, Module, Scenario Name, Status, Start/End Time, Duration.
  3. **Failed Tests**: Test Name, Failure Reason, Screenshot Path, Browser, URL.
  4. **Execution Logs**: Timestamp, Step Description, Result, Remarks.
- **HTML Reporting**: Interactive HTML dashboard and Mochawesome reports.
- **Failure Resilience & Debugging**: Automatically captures failure screenshots, browser console logs, current URL, and stack traces into `reports/failures/`.
- **Winston Logger**: Formatted logging to console and `logs/execution.log`.
- **GitHub Actions Integration**: Automated workflow pipeline (`.github/workflows/selenium-e2e.yml`) running on Node 24 with artifact uploads and GitHub Pages deployment (`environment: github-pages`).

---

## Project Structure

```
selenium_automation/
├── config/
│   └── config.js            # Environment, Browser & React Route Configuration
├── pages/
│   ├── BasePage.js          # Core Page Object Base Class
│   ├── SignInPage.js        # React SignIn Page Object
│   ├── SignUpPage.js        # React SignUp Page Object
│   └── DashboardPage.js     # React Dashboard Page Object
├── utilities/
│   ├── SeleniumUtils.js     # WebDriver Management, Explicit Waits & Failure Handling
│   ├── ExcelReporter.js     # 4-Sheet Excel Report Generator (ExcelJS)
│   ├── FormDiscoveryUtil.js # Dynamic React Route & Form Discovery Engine
│   └── WinstonLogger.js     # Enterprise Logger
├── tests/
│   ├── Authentication.spec.js       # Login, Logout & Credentials Tests
│   ├── FormValidation.spec.js       # Field Rules & Validation Tests
│   ├── UITesting.spec.js            # UI Elements & Component Tests
│   ├── Navigation.spec.js           # Router & History Navigation Tests
│   └── DynamicFormDiscovery.spec.js # Auto-Discovery E2E Suite
├── reports/                 # Output HTML & Excel Reports
├── screenshots/             # Failure Screenshots
├── logs/                    # Execution Logs
├── data/                    # Master Datasets
├── .mocharc.json            # Mocha Runner Config
├── generate_tests.js        # Master Test Suite Generator (300 Cases)
├── generate_report.js       # Excel & HTML Report Engine
├── package.json
└── README.md
```

---

## Execution Instructions

### 1. Install Dependencies
```bash
cd selenium_automation
npm install
```

### 2. Run All E2E Test Suites
```bash
npm test
```

### 3. Run Specific Test Suites
```bash
npm run test:auth      # Authentication Suite
npm run test:form      # Form Validation Suite
npm run test:ui        # UI Components Suite
npm run test:nav       # Navigation Suite
npm run test:dynamic   # Dynamic React Discovery Suite
```

### 4. Generate Master Test Suite (300 Test Cases) & Reports
```bash
npm run generate-tests
npm run report
```
