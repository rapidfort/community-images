const puppeteer = require('puppeteer');

async function main() {
  const browser = await puppeteer.launch({headless: false});
  const page = await browser.newPage();
  await page.setViewport({width: 1200, height: 720});
  await page.goto('http://frontrow.rapidfort.com/app/login', { waitUntil: 'networkidle0' }); // wait until page load

  await page.type('#email', "<enter_username>");
  console.log("put email");
  await Promise.all([
    page.click('#App > div:nth-child(1) > div.auth-page.undefined > div > div > div > div > form > div:nth-child(3) > button'),
    
  ]);
  console.log("typed password");
  await page.type('#password', "<enter_password>");
  await Promise.all([
    page.click('#App > div:nth-child(1) > div.auth-page.undefined > div > div > div > div > form > div:nth-child(3) > button'),
    page.waitForNavigation({ waitUntil: 'networkidle2' }),
  ])
  console.log("reached dashboard");
  await page.screenshot({ path: 'img/frontrow.png' });
  await browser.close();
  console.log("screen shot taken");
}

main();
