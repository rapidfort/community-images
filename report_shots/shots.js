const puppeteer = require('puppeteer');

async function main() {
  const browser = await puppeteer.launch({headless: true});
  const page = await browser.newPage();

  await page.setViewport({width: 3600, height: 2160});

  await page.goto('https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fenvoy/vulns/original', { waitUntil: 'networkidle0' }); // wait until page load
  await page.emulateMediaFeatures([{
    name: 'prefers-color-scheme', value: 'light' }]);

  await page.waitForSelector('#carousel__container');  
  const metrics = await page.$('#carousel__container');
  await metrics.screenshot({
    path: 'img/metrics.png'
    });

    // #card-statistics-histogram
  
  await page.waitForSelector('#card-statistics-histogram');  
  const cve_details = await page.$('#card-statistics-histogram'); 
  await cve_details.screenshot({
    path: 'img/cve.png'
    });

  await page.close();
  await browser.close();    
  console.log("screen shots taken");
}

main();
