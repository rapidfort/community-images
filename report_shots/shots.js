const puppeteer = require('puppeteer');
const process = require('process');
const util = require('util');
const fsPromise = require('fs/promises');
const yaml = require('js-yaml')
const fs = require('fs');

async function takeShots(browser, imageSavePath, imageUrl, firstShot) {
  const page = await browser.newPage();

  await page.setViewport({
    width: 5120,
    height: 3840,
    deviceScaleFactor: 8,
  });

  await page.setViewport({width: 3600, height: 2160});

  await page.goto(imageUrl, { waitUntil: 'networkidle0' }); // wait until page load
  await page.emulateMediaFeatures([{
    name: 'prefers-color-scheme', value: 'light' }]);

  // Select light theme
  if(firstShot) {
    await page.waitForSelector("#App > div:nth-child(1) > div.page.docker-image-page > div > header > div > div > div > div.header__right-view > div");
    await page.click("#App > div:nth-child(1) > div.page.docker-image-page > div > header > div > div > div > div.header__right-view > div");
  }

  await page.waitForSelector('#carousel__container');
  const metrics = await page.$('#carousel__container');
  await metrics.screenshot({
    path: util.format('%s/metrics.png', imageSavePath)
    });

  await page.waitForSelector('#card-statistics-histogram');
  const cve_details = await page.$('#card-statistics-histogram');
  await cve_details.screenshot({
    path: util.format('%s/cve_reduction.png', imageSavePath)
    });

  await page.close();

  console.log("screen shots taken");
}

async function main() {
  const imgListPath = process.argv[2]

  const imgList = await fsPromise.readFile(imgListPath, { encoding: 'utf8' });
  const imgListArray = imgList.split("\n");
  console.log(imgListArray);

  const browser = await puppeteer.launch({headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']});

  let firstShot=true;

  for await (const imagePath of imgListArray) {
    console.log(imagePath);

    try {
      let imageYmlPath = fs.realpathSync(util.format('../community_images/%s/image.yml', imagePath));

      const imageSavePath = fs.realpathSync(util.format('../community_images/%s/assets', imagePath));
      console.log(imageSavePath);
  
      let imageYmlContents = await fsPromise.readFile(imageYmlPath, { encoding: 'utf8' });
      let imageYml = await yaml.load(imageYmlContents);
      console.log(imageYml.report_url)
      await takeShots(browser, imageSavePath, imageYml.report_url, firstShot);
      firstShot=false;
  
    } catch (err) {
        continue;
    }
  }

  await browser.close();
}

main();
