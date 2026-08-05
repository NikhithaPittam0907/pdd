import type { Options } from '@wdio/types';

export const config: Options.Testrunner = {
    runner: 'local',
    autoCompileOpts: {
        autoCompile: true,
        tsNodeOpts: {
            project: './tsconfig.json',
            transpileOnly: true
        }
    },
    port: 4723,
    
    specs: [
        './tests/**/*.ts'
    ],
    exclude: [
        // 'path/to/excluded/files'
    ],
    
    maxInstances: 2, // Parallel execution support
    capabilities: [{
        platformName: 'Android',
        'appium:deviceName': 'Android Emulator',
        'appium:automationName': 'UiAutomator2',
        'appium:app': '../build/app/outputs/flutter-apk/app-debug.apk',
        'appium:noReset': false,
        'appium:fullReset': true,
        'appium:autoGrantPermissions': true,
    }],
    
    logLevel: 'info',
    outputDir: './logs',
    bail: 0,
    baseUrl: 'http://localhost',
    waitforTimeout: 15000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3, // Retry mechanism
    
    services: ['appium'],
    
    framework: 'mocha',
    reporters: ['spec', ['allure', {
        outputDir: 'allure-results',
        disableWebdriverStepsReporting: true,
        disableWebdriverScreenshotsReporting: false,
    }]],
    
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
    },

    afterTest: async function(test, context, { error, result, duration, passed, retries }) {
        if (!passed) {
            // Capture Screenshot on Failure
            await browser.takeScreenshot();
            // In a real framework, we'd also pull device logs here and write them to ./logs
        }
    },
};
