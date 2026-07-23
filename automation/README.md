# LexisAI Android E2E Automation Framework

Welcome to the enterprise-grade Android E2E Automation Framework for LexisAI. This framework is built using **Python + Pytest + Appium**, adopting the **Page Object Model (POM)** and **Data Driven Testing** methodologies.

---

## Folder Structure

```text
automation/
│
├── pages/                  # Page Object Classes (BasePage, LoginPage, DashboardPage, etc.)
├── tests/                  # Pytest test suites (dynamic suite execution)
├── data/                   # Data providers (test_cases.json)
├── drivers/                # Driver factory supporting real & simulated Appium drivers
├── reports/                # Local HTML, Excel, and JSON reports
├── screenshots/            # Failure screenshots
├── logs/                   # System and test execution logs
├── config/                 # Desired capabilities and configuration settings
├── utils/                  # Excel, HTML, logging, and screenshot utilities
└── runners/                # Main execution scripts (run_tests.py)
```

---

## 1. Local Execution Guide

### Prerequisites
1. **Python 3.8+** installed.
2. **Android SDK** and **Platform Tools** (e.g., `adb` command available in PATH).
3. **Node.js** (for running Appium server locally).
4. **Flutter SDK** (if you want to compile the APK from source).

### Fast-Track (Dry-Run / Simulated Mode)
This mode runs the entire suite of 510 tests programmatically by mocking Appium network requests. It validates test structure, configuration integration, and generates all target Excel/HTML/JSON reports locally in under 30 seconds.
```bash
# From the project root
python automation/runners/run_tests.py --mode dry-run
```

### Real Device / Emulator Execution
To execute tests against a live Android device or emulator:
1. **Start your Android Emulator** or connect a physical device via USB (verify using `adb devices`).
2. **Start the Appium Server**:
   ```bash
   npm install -g appium
   appium driver install uiautomator2
   appium
   ```
3. **Build the Android APK**:
   ```bash
   flutter build apk --debug
   ```
4. **Execute Tests**:
   ```bash
   python automation/runners/run_tests.py --mode real
   ```

---

## 2. CI/CD Execution Guide

The CI/CD pipeline is configured in [.github/workflows/android-e2e.yml](file:///d:/PDD/my_app/.github/workflows/android-e2e.yml).

### Pipeline Stages
1. **Checkout Code**: Grabs repository contents.
2. **Environment Setup**: Pulls in JDK 17, Python 3.10, Node.js 18, and Flutter.
3. **Build APK**: Compiles the Flutter project into `app-debug.apk`.
4. **Start Emulator**: Boots up Android Virtual Device on a macOS runner with hardware acceleration.
5. **Start Appium**: Launches the Appium Server and installs the UiAutomator2 driver.
6. **Execution**: Automatically installs the APK and executes the 510 test case suite.
7. **Report Compilation**: Generates HTML dashboards, multi-sheet Excel reports, JSON files, and summaries.
8. **GitHub Pages Deployment**: Automatically deploys results to the `gh-pages` branch.

### Triggers
- Every `push` to `main`/`master`.
- Every `pull_request` to `main`/`master`.
- Manual trigger via **Workflow Dispatch** in GitHub Actions.
- Weekly cron job.

---

## 3. Repository Configuration Guide

To enable automated reporting and deployment to GitHub Pages:

### A. Enable GitHub Pages
1. Go to your GitHub Repository -> **Settings** -> **Pages**.
2. Under **Build and deployment** -> **Source**, select **Deploy from a branch**.
3. Under **Branch**, select `gh-pages` (which is created automatically by the workflow) and directory `/root`. Click **Save**.
4. Set the **Pages Custom Domain** or use the default:
   `https://<github-username>.github.io/<repository-name>/`

### B. Configure Workflow Permissions
1. Go to **Settings** -> **Actions** -> **General**.
2. Scroll to **Workflow permissions**.
3. Select **Read and write permissions** (this allows the runner to push reports to the `gh-pages` branch).
4. Click **Save**.

### C. Live Reports URL
Your reports will be hosted live at:
- **Latest HTML Report:** `https://<github-username>.github.io/<repository-name>/reports/latest/execution-report.html`
- **Latest Dashboard:** `https://<github-username>.github.io/<repository-name>/reports/latest/dashboard.html`
- **Historical Run Directory:** `https://<github-username>.github.io/<repository-name>/reports/history/build-<run_number>/execution-report.html`

---

## 4. Troubleshooting Guide

### Q1: The workflow fails at the Emulator Startup phase
* **Cause:** The GitHub Actions runner type is set to `ubuntu-latest`, which lacks hardware acceleration.
* **Fix:** Ensure the runner is `macos-13` or `macos-14` as specified in our workflow. Standard macOS runners on GitHub support nested hardware virtualization by default.

### Q2: Appium fails to locate elements on Flutter screens
* **Cause:** Flutter widgets do not expose standard Android resource IDs in the accessibility hierarchy by default.
* **Fix:** Exposed labels can be detected using Accessibility IDs (`content-desc` in Android). In your Flutter code, wrap target widgets in a `Semantics` widget and assign a `label`. This makes them visible to Appium via:
  ```python
  (By.ACCESSIBILITY_ID, "your_semantics_label")
  ```

### Q3: Python throws ModuleNotFoundError in CI
* **Cause:** Dependencies are not installed in the runner's python workspace.
* **Fix:** The custom runner script `run_tests.py` has a built-in bootstrapper that automatically runs `pip install` for `pytest`, `Appium-Python-Client`, `selenium`, and `openpyxl` on startup. Ensure python setup matches the runner configuration.
