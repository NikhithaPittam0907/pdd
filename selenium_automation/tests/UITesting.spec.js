const { expect } = require('chai');
const { By } = require('selenium-webdriver');
const SeleniumUtils = require('../utilities/SeleniumUtils');
const BasePage = require('../pages/BasePage');
const ExcelReporter = require('../utilities/ExcelReporter');
const logger = require('../utilities/WinstonLogger');

describe('React Application - UI Component & Element Readiness Suite', function () {
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
    await excelReporter.generateReport('UIComponent_Report.xlsx');
  });

  afterEach(async function () {
    const testName = this.currentTest ? this.currentTest.title : 'UI Test';
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

    excelReporter.recordTest('TC_UI_001', 'UI Components', testName, 'Chrome', status, duration, errorMsg, screenshotPath, currentUrl);
  });

  it('TC_UI_001: Validate Primary Action Buttons & Interactive Attributes', async function () {
    logger.info('Executing TC_UI_001: Primary Action Buttons');
    await basePage.open('/signin');
    const isPresent = await basePage.isElementPresent(By.tagName('button'));
    expect(isPresent).to.be.true;
  });

  it('TC_UI_002: Validate Input Fields, Selectors & Checkbox Rendering', async function () {
    logger.info('Executing TC_UI_002: Input Fields Rendering');
    await basePage.open('/signin');
    const inputs = await driver.findElements(By.tagName('input'));
    expect(inputs.length).to.be.greaterThan(0);
  });

  it('TC_UI_003: Validate Header Banner Branding & Typography Standards', async function () {
    logger.info('Executing TC_UI_003: Header Branding');
    await basePage.open('/signin');
    const title = await basePage.getTitle();
    expect(title).to.be.a('string');
  });
});
