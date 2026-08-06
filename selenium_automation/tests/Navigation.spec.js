const { expect } = require('chai');
const SeleniumUtils = require('../utilities/SeleniumUtils');
const BasePage = require('../pages/BasePage');
const ExcelReporter = require('../utilities/ExcelReporter');
const logger = require('../utilities/WinstonLogger');

describe('React Application - Navigation & Router Test Suite', function () {
  this.timeout(60000);
  let driver;
  let basePage;
  const excelReporter = new ExcelReporter();

  before(async function () {
    driver = await SeleniumUtils.createDriver();
    basePage = new BasePage(driver);
  });

  after(async function () {
    if (driver) await driver.quit();
    await excelReporter.generateReport('Navigation_Report.xlsx');
  });

  afterEach(async function () {
    const testName = this.currentTest ? this.currentTest.title : 'Navigation Test';
    const status = this.currentTest.state === 'passed' ? 'PASS' : 'FAIL';
    const duration = this.currentTest.duration || 0;
    let screenshotPath = 'N/A';
    let currentUrl = 'N/A';
    let errorMsg = 'N/A';

    if (status === 'FAIL') {
      const failInfo = await SeleniumUtils.handleFailure(driver, testName);
      screenshotPath = failInfo.screenshotPath;
      currentUrl = failInfo.currentUrl;
      errorMsg = this.currentTest.err ? this.currentTest.err.message : 'Assertion error';
    }

    excelReporter.recordTest('TC_NAV_001', 'Navigation', testName, 'Chrome', status, duration, errorMsg, screenshotPath, currentUrl);
  });

  it('TC_NAV_001: Validate React Router Screen Transitions (/signin -> /signup)', async function () {
    logger.info('Executing TC_NAV_001: Route Transitions');
    await basePage.open('/signin');
    await basePage.open('/signup');
    const url = await basePage.getCurrentUrl();
    expect(url).to.include('/signup');
  });

  it('TC_NAV_002: Validate Browser Back and Forward History Integrity', async function () {
    logger.info('Executing TC_NAV_002: Browser Back/Forward');
    await basePage.open('/signin');
    await basePage.open('/signup');
    await driver.navigate().back();
    let url = await basePage.getCurrentUrl();
    expect(url).to.include('/signin');

    await driver.navigate().forward();
    url = await basePage.getCurrentUrl();
    expect(url).to.include('/signup');
  });

  it('TC_NAV_003: Validate Page Refresh & Client-Side State Preservation', async function () {
    logger.info('Executing TC_NAV_003: Page Refresh Behavior');
    await basePage.open('/signin');
    await driver.navigate().refresh();
    const url = await basePage.getCurrentUrl();
    expect(url).to.include('/signin');
  });
});
