import type { Options } from '@wdio/types';
import * as fs from 'fs';
import * as path from 'path';

// Ensure standard automation directories exist
const logsDir = path.resolve(__dirname, 'logs');
const screenshotsDir = path.resolve(__dirname, 'screenshots');
const allureDir = path.resolve(__dirname, 'allure-results');

[logsDir, screenshotsDir, allureDir].forEach(dir => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
});

const apkPath = path.resolve(__dirname, '../build/app/outputs/flutter-apk/app-debug.apk');

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
    exclude: [],
    
    maxInstances: 1,
    capabilities: [{
        platformName: 'Android',
        'appium:deviceName': process.env.EMULATOR_DEVICE || 'Android Emulator',
        'appium:automationName': 'UiAutomator2',
        'appium:app': apkPath,
        'appium:noReset': false,
        'appium:fullReset': false,
        'appium:autoGrantPermissions': true,
        'appium:newCommandTimeout': 240,
    }],
    
    logLevel: 'info',
    outputDir: './logs',
    bail: 0,
    baseUrl: 'http://localhost',
    waitforTimeout: 15000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,
    
    services: [],
    
    framework: 'mocha',
    reporters: [
        'spec',
        ['allure', {
            outputDir: 'allure-results',
            disableWebdriverStepsReporting: false,
            disableWebdriverScreenshotsReporting: false,
        }]
    ],
    
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
    },

    onPrepare: function () {
        console.log(`[WDIO Config] Target APK Path: ${apkPath}`);
        if (!fs.existsSync(apkPath)) {
            console.warn(`[WDIO Config WARNING] APK file not found at ${apkPath}`);
        }
    },

    afterTest: async function(test, context, { error, result, duration, passed, retries }) {
        if (!passed) {
            try {
                const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
                const sanitizeTitle = test.title.replace(/[^a-zA-Z0-9]/g, '_');
                const screenshotPath = path.join(screenshotsDir, `FAIL_${sanitizeTitle}_${timestamp}.png`);
                
                const screenshot = await browser.takeScreenshot();
                fs.writeFileSync(screenshotPath, screenshot, 'base64');
                console.log(`[WDIO Failure Screenshot] Saved screenshot to: ${screenshotPath}`);
            } catch (err) {
                console.error(`[WDIO Error] Failed to take screenshot:`, err);
            }
        }
    },
};
