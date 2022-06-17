const puppeteer = require('puppeteer');
const process = require('process');
const util = require('util');

async function takeShots(imageSavePath, imageUrl) {
  const browser = await puppeteer.launch({headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']});
  const page = await browser.newPage();

  await page.setViewport({width: 3600, height: 2160});

  await page.goto(imageUrl, { waitUntil: 'networkidle0' }); // wait until page load
  await page.emulateMediaFeatures([{
    name: 'prefers-color-scheme', value: 'light' }]);

  await page.waitForSelector('#carousel__container');
  const metrics = await page.$('#carousel__container');
  await metrics.screenshot({
    path: util.format('%s/metrics.png', imageSavePath)
    });

    // #card-statistics-histogram

  await page.waitForSelector('#card-statistics-histogram');
  const cve_details = await page.$('#card-statistics-histogram');
  await cve_details.screenshot({
    path: util.format('%s/cve.png', imageSavePath)
    });

  await page.close();
  await browser.close();
  console.log("screen shots taken");
}

async function main() {
  imageSavePath = "img";
  imageUrl = "https://frontrow.rapidfort.com/app/community/imageinfo/docker.io%2Fbitnami%2Fenvoy/vulns/original";
  await takeShots(imageSavePath, imageUrl);
  console.log(process.argv[1]);
}

main();
