const { By } = require('selenium-webdriver');
const config = require('../config/config');
const logger = require('./WinstonLogger');

class FormDiscoveryUtil {
  static async discoverFormsAndRoutes(driver) {
    logger.info("=== Starting Dynamic React Route & Form Discovery Engine ===");
    const discoveredSuites = [];

    for (const routeObj of config.reactRoutes) {
      const fullUrl = `${config.baseUrl}${routeObj.path}`;
      logger.info(`[Discovery Engine] Navigating to route: ${fullUrl}`);

      try {
        await driver.get(fullUrl);
        await driver.sleep(1000); // Allow React hydration

        const formElements = await driver.findElements(By.css('form, [data-testid="form"], .form-container'));
        const inputElements = await driver.findElements(By.css('input, select, textarea'));

        const fieldDetails = [];
        for (const input of inputElements) {
          const type = (await input.getAttribute('type')) || 'text';
          const name = (await input.getAttribute('name')) || (await input.getAttribute('id')) || (await input.getAttribute('placeholder')) || 'unnamed_field';
          const required = await input.getAttribute('required');
          const minLength = await input.getAttribute('minlength');
          const maxLength = await input.getAttribute('maxlength');
          const pattern = await input.getAttribute('pattern');

          fieldDetails.push({
            name,
            type,
            required: required !== null,
            minLength: minLength ? parseInt(minLength, 10) : null,
            maxLength: maxLength ? parseInt(maxLength, 10) : null,
            pattern
          });
        }

        const generatedCases = this.generateDynamicCasesForRoute(routeObj.path, fieldDetails);
        discoveredSuites.push({
          route: routeObj.path,
          routeName: routeObj.name,
          formCount: formElements.length,
          fieldCount: inputElements.length,
          fields: fieldDetails,
          testCases: generatedCases
        });

        logger.info(`✔ Discovered Route [${routeObj.path}]: ${formElements.length} forms, ${inputElements.length} inputs -> Built ${generatedCases.length} dynamic validation tests.`);
      } catch (err) {
        logger.warn(`[Discovery Engine Warning] Could not inspect route ${routeObj.path}: ${err.message}`);
      }
    }

    return discoveredSuites;
  }

  static generateDynamicCasesForRoute(routePath, fields) {
    const cases = [];
    let caseIdx = 1;

    // 1. Mandatory Empty Submission Check
    cases.push({
      id: `DYN_${routePath.replace('/', '').toUpperCase()}_${String(caseIdx++).padStart(3, '0')}`,
      name: `Verify ${routePath} Form Empty Submission Rule`,
      type: 'EMPTY_SUBMISSION',
      fieldsToFill: []
    });

    // 2. Field-Specific Rules
    fields.forEach(field => {
      if (field.type === 'email') {
        cases.push({
          id: `DYN_${routePath.replace('/', '').toUpperCase()}_${String(caseIdx++).padStart(3, '0')}`,
          name: `Verify ${routePath} Invalid Email Format Validation [Field: ${field.name}]`,
          type: 'INVALID_EMAIL',
          targetField: field.name,
          inputValue: 'invalid_email_no_at_sign'
        });
      }

      if (field.type === 'password' || field.name.toLowerCase().includes('password')) {
        cases.push({
          id: `DYN_${routePath.replace('/', '').toUpperCase()}_${String(caseIdx++).padStart(3, '0')}`,
          name: `Verify ${routePath} Password Min-Length Complexity Rule [Field: ${field.name}]`,
          type: 'WEAK_PASSWORD',
          targetField: field.name,
          inputValue: '123'
        });
      }

      if (field.type === 'tel' || field.name.toLowerCase().includes('phone')) {
        cases.push({
          id: `DYN_${routePath.replace('/', '').toUpperCase()}_${String(caseIdx++).padStart(3, '0')}`,
          name: `Verify ${routePath} Phone Format Validation [Field: ${field.name}]`,
          type: 'INVALID_PHONE',
          targetField: field.name,
          inputValue: 'abc_not_a_phone'
        });
      }
    });

    // 3. Valid Submission Flow
    cases.push({
      id: `DYN_${routePath.replace('/', '').toUpperCase()}_${String(caseIdx++).padStart(3, '0')}`,
      name: `Verify ${routePath} Valid Form Submission & State Processing`,
      type: 'VALID_SUBMISSION',
      fieldsToFill: fields.map(f => ({
        name: f.name,
        val: f.type === 'email' ? 'user@example.com' : (f.type === 'password' ? 'Password123!' : 'ValidInputData')
      }))
    });

    return cases;
  }
}

module.exports = FormDiscoveryUtil;
