"""The selenium test."""
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


class TestPrometheus():
    """The test word press class for testing wordpress image."""
    def setup_method(self):
        """setup method."""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument('--disable-dev-shm-usage')
        chrome_options.add_argument("disable-infobars")
        chrome_options.add_argument("--disable-extensions")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--no-sandbox")
        self.driver = webdriver.Chrome(options=chrome_options)  # pylint: disable=attribute-defined-outside-init
        self.driver.implicitly_wait(10)

    def teardown_method(self, method): # pylint: disable=unused-argument
        """teardown method."""
        self.driver.quit()

    def test_prometheus(self, params):
        """The test method"""
        # Test name: s1
        # Step # | name | target | value
        # 1 | open | /graph?g0.expr=&g0.tab=1&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1h |
        self.driver.get("http://{}:{}/".format(params["prom_server"], params["port"]))  # pylint: disable=consider-using-f-string
        # 2 | setWindowSize | 1200x859 |
        self.driver.set_window_size(1200, 859)
        # 3 | click | css=.cm-line |
        self.driver.find_element(By.CSS_SELECTOR, ".cm-line").click()
        # 4 | click | css=.execute-btn |
        self.driver.find_element(By.CSS_SELECTOR, ".execute-btn").click()
        # 5 | click | css=.cm-line |
        self.driver.find_element(By.CSS_SELECTOR, ".cm-line").click()
        # 6 | editContent | css=.cm-content | <div class="cm-line">request_count_total</div>
        element = self.driver.find_element(By.CSS_SELECTOR, ".cm-content")
        self.driver.execute_script("if(arguments[0].contentEditable === 'true') {arguments[0].innerText = '<div class=\"cm-line\">request_count_total</div>'}", element) #pylint: disable=line-too-long
        # 7 | click | css=.execute-btn |
        self.driver.find_element(By.CSS_SELECTOR, ".execute-btn").click()
        # search for the text on the page now
        assert "request_count_total" in self.driver.page_source
        # 8 | editContent | css=.cm-content | <div class="cm-line">request_latency_seconds_bucket</div> # pylint: disable=line-too-long
        element = self.driver.find_element(By.CSS_SELECTOR, ".cm-content")
        self.driver.execute_script("if(arguments[0].contentEditable === 'true') {arguments[0].innerText = '<div class=\"cm-line\">request_latency_seconds_bucket</div>'}", element)
        # 9 | click | css=.execute-btn |
        self.driver.find_element(By.CSS_SELECTOR, ".execute-btn").click()
        # search for the text on the page
        assert "request_latency_seconds_bucket" in self.driver.page_source
