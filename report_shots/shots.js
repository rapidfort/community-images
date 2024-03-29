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
    deviceScaleFactor: 1.25,
  });

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
    path: util.format('%s/metrics.webp', imageSavePath),
    type: 'webp'
    });

  await page.waitForSelector('#card-severity-histogram.card-severity-histogram');
  const cve_details = await page.$('#card-severity-histogram.card-severity-histogram');
  await cve_details.screenshot({
    path: util.format('%s/cve_reduction.webp', imageSavePath),
    type: 'webp'
    });

  await page.close();

  console.log("screen shots taken and saved at: ", imageSavePath);
}

async function main() {
  const imgListPath = process.argv[2]
  const platform = process.argv[3]

  const imgList = await fsPromise.readFile(imgListPath, { encoding: 'utf8' });
  const imgListArray = imgList.split("\n");
  console.log(imgListArray);

  const browser = await puppeteer.launch({headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']});

  let firstShot=false;

  for await (const imagePath of imgListArray) {
    console.log("image name=", imagePath);

    try {
      let imageYmlPath = fs.realpathSync(util.format('../community_images/%s/image.yml', imagePath));

      const imageSavePath = fs.realpathSync(util.format('../community_images/%s/assets', imagePath));
      console.log("image save path=", imageSavePath);

      let imageYmlContents = await fsPromise.readFile(imageYmlPath, { encoding: 'utf8' });
      let imageYml = await yaml.load(imageYmlContents);
      let fetched_url = imageYml.report_url

      if (platform === "pre-prod") {
        fetched_url = fetched_url.replace("us01.rapidfort.com", "frontrow-dev.rapidfort.io");
      } else if (platform === "staging") {
        fetched_url = fetched_url.replace("us01.rapidfort.com", "frontrow.rapidfort.io");
      }

      let report_url = fetched_url + "?story_off=true"
      console.log("image url=", report_url);

      await takeShots(browser, imageSavePath, report_url, firstShot);
      firstShot=false;

    } catch (err) {
        continue;
    }
  }

  await browser.close();
}

main();
