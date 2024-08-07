"""The selenium test."""
# pylint: skip-file

# Generated by Selenium IDE
import json  # pylint: disable=import-error disable=unused-import
import time  # pylint: disable=import-error disable=unused-import
import pytest  # pylint: disable=import-error disable=unused-import
from selenium import webdriver  # pylint: disable=import-error
from selenium.webdriver.chrome.options import Options  # pylint: disable=import-error
from selenium.webdriver.common.by import By  # pylint: disable=import-error
from selenium.webdriver.common.action_chains import ActionChains  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.support import expected_conditions  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.support.wait import WebDriverWait  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.common.keys import Keys  # pylint: disable=import-error disable=unused-import
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities  # pylint: disable=import-error disable=unused-import

class TestKibanatest():
    def setup_method(self, method):  # pylint: disable=unused-argument
        """setup method."""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument("disable-infobars")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument('ignore-certificate-errors')

        self.driver = webdriver.Chrome(
            options=chrome_options)  # pylint: disable=attribute-defined-outside-init
        self.driver.implicitly_wait(10)

    def teardown_method(self, method):  # pylint: disable=unused-argument
        """teardown method."""
        self.driver.quit()

    #adding sample data  
    def test_sampledata(self, params):
        """test kibana."""
        self.driver.get("http://{}:{}/app/home#/tutorial_directory/sampleData".format(params["server"], params["port"]))  # pylint: disable=consider-using-f-string
        self.driver.set_window_size(1296, 688)
        # self.driver.find_element(By.CSS_SELECTOR, ".euiFlexItem:nth-child(1) > .euiPanel .euiButton__text").click()
        # time.sleep(10)
        # self.driver.close()
        self.driver.find_element(By.CSS_SELECTOR, ".euiAccordion__buttonContent").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiFlexItem:nth-child(1) > .euiPanel:nth-child(1) .eui-textTruncate:nth-child(1)")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).click_and_hold().perform()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiFlexItem:nth-child(1) > .euiPanel .css-cf8eum-euiButtonDisplayContent")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).release().perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiFlexItem:nth-child(1) > .euiPanel .css-cf8eum-euiButtonDisplayContent").click()
        self.driver.execute_script("window.scrollTo(0,508)")
        self.driver.execute_script("window.scrollTo(0,508)")
        self.driver.close()

    # testing map section of kibana ui
    def test_maps(self, params):
        self.driver.get("http://{}:{}/app/maps".format(params["server"], params["port"]))  
        self.driver.set_window_size(1296, 688)
        self.driver.find_element(By.CSS_SELECTOR, ".euiLink:nth-child(1) > span").click()
        element = self.driver.find_element(By.CSS_SELECTOR, "#qvhh3 .euiButtonEmpty__content")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "#qvhh3 .eui-textTruncate")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, "#qvhh3 .eui-textTruncate").click()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "#y3fjb .eui-textTruncate")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, "#y3fjb .eui-textTruncate").click()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.close()

    # performing task on dashboard and different filters
    def test_dashboard(self, params):
        self.driver.get("http://{}:{}/app/dashboards".format(params["server"], params["port"]))  # pylint: disable=consider-using-f-string
        self.driver.set_window_size(1296, 688)
        self.driver.find_element(By.CSS_SELECTOR, ".euiLink:nth-child(1) > span").click()
        element = self.driver.find_element(By.CSS_SELECTOR, "#controlFrame--1ee1617f-fd8e-45e4-bc6a-d5736710ea20 .euiFilterButton__text")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "#controlFrame--1ee1617f-fd8e-45e4-bc6a-d5736710ea20 .euiButtonEmpty__content")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.execute_script("window.scrollTo(0,233.3333282470703)")
        self.driver.find_element(By.CSS_SELECTOR, "#panel-bdb525ab-270b-46f1-a847-dd29be19aadb .euiButtonIcon").click()
        self.driver.close()
    # visualization of different sections of data in ui
    def test_visualize(self, params):
        self.driver.get("http://{}:{}/app/visualize".format(params["server"], params["port"]))  
        self.driver.set_window_size(1296, 688)
        self.driver.find_element(By.CSS_SELECTOR, ".euiTableRow:nth-child(1) .euiText span").click()
        self.driver.execute_script("window.scrollTo(0,14)")
        self.driver.find_element(By.CSS_SELECTOR, ".euiSuperUpdateButton").click()
        element = self.driver.find_element(By.CSS_SELECTOR, "#headerHelpMenu .euiButtonEmpty__content")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.close()

    # visualization of data in terms of divisions
    def test_discover(self, params):
        self.driver.get("http://{}:{}/app/discover".format(params["server"], params["port"]))
        self.driver.set_window_size(1296, 688)
        self.driver.close()

    # deleting of data added
    def test_deletingdata(self, params):
        """test kibana."""
        self.driver.get("http://{}:{}/app/home#/tutorial_directory/sampleData".format(params["server"], params["port"]))  # pylint: disable=consider-using-f-string
        self.driver.set_window_size(1296, 688)
        # self.driver.find_element(By.CSS_SELECTOR, ".euiButtonEmpty--danger .euiButtonEmpty__text").click()
        # self.driver.close()
        self.driver.execute_script("window.scrollTo(0,19.33333396911621)")
        self.driver.execute_script("window.scrollTo(0,262)")
        self.driver.find_element(By.CSS_SELECTOR, ".euiAccordion__buttonContent").click()
        self.driver.execute_script("window.scrollTo(0,678)")
        self.driver.find_element(By.CSS_SELECTOR, ".css-1h0356f-euiButtonDisplay-euiButtonEmpty-m-empty-danger-flush-left .eui-textTruncate").click()
        self.driver.close()
    
    # testing dev tools of kibana in console
    def test_tools(self, params):
        self.driver.get("http://{}:{}/app/dev_tools".format(params["server"], params["port"]))  
        self.driver.set_window_size(1296, 688)
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiTab:nth-child(4) > .css-bzyfuv-euiTab__content-s")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiTab:nth-child(2) .euiToolTipAnchor > span").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiTab-isSelected .euiToolTipAnchor > span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiTab:nth-child(3) .euiToolTipAnchor > span").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiTab-isSelected .euiToolTipAnchor > span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiTab:nth-child(4) .euiToolTipAnchor > span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiTab:nth-child(4) .euiToolTipAnchor > span").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiTab-isSelected .euiToolTipAnchor > span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiTab:nth-child(1) .euiToolTipAnchor > span").click()
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiTab-isSelected .euiToolTipAnchor > span")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        element = self.driver.find_element(By.CSS_SELECTOR, "body")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.close()
    # testing security alerts ui
    def test_alerts(self, params):
        self.driver.get("http://{}:{}/app/security/explore".format(params["server"], params["port"]))
        self.driver.set_window_size(1296, 688)
        element = self.driver.find_element(By.CSS_SELECTOR, ".euiFlexItem:nth-child(1) > .euiLink .euiImage")
        actions = ActionChains(self.driver)
        actions.move_to_element(element).perform()
        self.driver.find_element(By.CSS_SELECTOR, ".euiFlexItem:nth-child(1) > .euiLink .euiImage").click()
        self.driver.close()
    