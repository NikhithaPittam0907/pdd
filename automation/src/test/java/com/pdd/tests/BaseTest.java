package com.pdd.tests;

import com.pdd.utils.DriverFactory;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Listeners;

@Listeners({com.pdd.utils.ExcelReportListener.class})
public class BaseTest {
    @BeforeMethod
    public void setUp() {
        DriverFactory.getDriver();
    }

    @AfterMethod
    public void tearDown() {
        DriverFactory.quitDriver();
    }
}
