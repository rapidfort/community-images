const util = require('util');
const fsPromise = require('fs/promises');
const yaml = require('js-yaml')
const fs = require('fs');
const { parseJSON, parseCSVFormatV2, formatBytes } = require('./utils');
const { convertVulnsData, vulnsColorScheme } = require('./vulnsParser');
const sharp = require('sharp');
const svgson = require('svgson');
// Function to save SVG content to file
function saveSVGToFile(svgContent, imageSavePath) {
  fs.writeFile(imageSavePath, svgContent, 'utf8', (err) => {
    if (err) {
      console.error('Error saving SVG file:', err);
    } else {
      console.log('SVG file successfully saved at:', imageSavePath);
    }
  });
}

// generate rect path with rounded top left and right corners 
function createRoundedRectPath(x, y, width, height, radius) {
  if (height < radius) {
    radius = height;
  }
  return `
    M${x + radius},${y} 
    H${x + width - radius} 
    C${x + width},${y} ${x + width},${y} ${x + width},${y + radius} 
    V${y + height} 
    H${x} 
    V${y + radius} 
    C${x},${y} ${x},${y} ${x + radius},${y}
    Z
  `;
}  

const generateCharts = async (imageName, platform, imageSavePath) => {
  const fetchDataRequest = async (path)=> {
    let baseAPIUrl = ''
    switch (platform) {
      case 'pre-prod':
        baseAPIUrl = 'https://frontrow-dev.rapidfort.io'
        break;
      case 'staging':
        baseAPIUrl = 'https://frontrow.rapidfort.io'
        break;
      default:
        baseAPIUrl = 'https://us01.rapidfort.com'
    }
    const result =  await fetch(`${baseAPIUrl}${path}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });
    return await parseJSON(result);
  }

  try {
    // api/v1/community/imageinfo/?name=docker.io/library/redis
    const jsonInfo = await fetchDataRequest(`/api/v1/community/imageinfo/?name=${imageName}`);
    const imageInfoRaw = await fetchDataRequest(`/api/v1/community/images/?image_name=${imageName}`);
    const imageInfo = parseCSVFormatV2({fields:imageInfoRaw?.fields, data:[imageInfoRaw?.image]})?.[0]
    const vulns = await fetchDataRequest(jsonInfo?.vulns);
    const vulnsHardened = await fetchDataRequest(jsonInfo?.vulns_hardened);
    const {vulnsSeverityCount: vulnsHardenedSummary, hardenedVulnsFlags, } = convertVulnsData(vulnsHardened, true, true);
    const {vulnsSeverityCount: vulnsOriginalSummary} = convertVulnsData(vulns, true, false, hardenedVulnsFlags);

    // generate SVGs
    const vulnsSavingsChartSVG = await generateSavingsChart('Vulnerabilities', imageInfo.noVulns, imageInfo.noVulnsHardened, false);
    const packagesSavingsChartSVG = await generateSavingsChart('Packages', imageInfo.noPkgs, imageInfo.noPkgsHardened, false);
    const sizeSavingsChartSVG = await generateSavingsChart('Attack surface', imageInfo.origImageSize, imageInfo.hardenedImageSize, true);
    const contextualSeverityChart = await generateContextualSeverityChart(vulnsOriginalSummary)
    const vulnsBySeverityChart = await generateVulnsBySeverityChart(vulnsOriginalSummary.default, vulnsHardenedSummary.default);

    // save individual charts as svg
    // saveSVGToFile(vulnsSavingsChartSVG, util.format('%s/savings_chart_vulns.svg', imageSavePath));
    // saveSVGToFile(packagesSavingsChartSVG, util.format('%s/savings_chart_pkgs.svg', imageSavePath));
    // saveSVGToFile(sizeSavingsChartSVG, util.format('%s/savings_chart_size.svg', imageSavePath));
    // saveSVGToFile(contextualSeverityChart, util.format('%s/contextual_severity_chart.svg', imageSavePath));
    // saveSVGToFile(vulnsBySeverityChart, util.format('%s/vulns_by_severity_histogram.svg', imageSavePath));
    generateReportViews(vulnsSavingsChartSVG, packagesSavingsChartSVG, sizeSavingsChartSVG, contextualSeverityChart, vulnsBySeverityChart, imageSavePath);
  } catch (error) {
    console.error(error);
  }
}

// Recursive function to find width and height in nested SVG tags
const findSVGDimensions = (node) => {
  if (node.name === 'svg' && node.attributes.width && node.attributes.height) {
    return {
      width: parseFloat(node.attributes.width),
      height: parseFloat(node.attributes.height),
    };
  }
  
  for (const child of node.children || []) {
    const dimensions = findSVGDimensions(child);
    if (dimensions) return dimensions;
  }

  return null;
};

const parseSVGDimensions = async (svgContent) => {
  const svgJSON = await svgson.parse(svgContent);
  const dimensions = findSVGDimensions(svgJSON);
  return dimensions || { width: 0, height: 0 };
};

const generateReportViews = async (
  vulnsSavingsChartSVG,
  packagesSavingsChartSVG,
  sizeSavingsChartSVG,
  contextualSeverityChartSVG,
  vulnsBySeverityChartSVG,
  imageSavePath
) => {
  const gap = 16;
  let padding = 16;

  const svgFiles = [
    vulnsBySeverityChartSVG,
    contextualSeverityChartSVG,
    vulnsSavingsChartSVG,
    packagesSavingsChartSVG,
    sizeSavingsChartSVG,
  ];
  // Extract and deduplicate style content
  // Extract and deduplicate @font-face and other style content
  const uniqueFontFaces = new Set();
  const otherStyles = new Set();

  svgFiles.forEach((svgContent) => {
    const styleMatch = svgContent.match(/<style[^>]*>([\s\S]*?)<\/style>/);
    if (styleMatch) {
      const styleContent = styleMatch[1];
      
      // Match and deduplicate @font-face
      const fontFaceMatches = styleContent.match(/@font-face\s*{[^}]*}/g) || [];
      fontFaceMatches.forEach(fontFace => uniqueFontFaces.add(fontFace));

      // Extract remaining styles
      const nonFontFaceStyles = styleContent.replace(/@font-face\s*{[^}]*}/g, "");
      if (nonFontFaceStyles.trim()) {
        otherStyles.add(nonFontFaceStyles.trim());
      }
    }
  });

  // Combine unique font faces and other styles
  const combinedStyle = `
    <style>
      ${[...uniqueFontFaces].join("\n")}
      ${[...otherStyles].join("\n")}
    </style>
  `;

  // Remove individual <style> tags from SVGs
  const cleanedSVGs = svgFiles.map(svgContent =>
    svgContent.replace(/<style[^>]*>[\s\S]*?<\/style>/, "")
  );
  
  const dimensions = await Promise.all(svgFiles.map(parseSVGDimensions));

  const severityVulnsDimensions = dimensions[0]
  const maxHeight = Math.max(...dimensions.map((dim) => dim.height));
  const totalWidth =
    padding * 2 +
    dimensions.reduce((sum, dim) => sum + dim.width, 0) +
    gap * (svgFiles.length - 1);

  let currentX = padding;
  const combinedSVGContent = dimensions.map((dim, index) => {
    const svgContent = cleanedSVGs[index];
    const content = `
      <g transform="translate(${currentX}, ${padding})">
        ${svgContent}
      </g>`;
    currentX += (dim.width + gap) ;
    return content;
  }).join("\n");

  const combinedSVG = `
    <svg width="${totalWidth}" height="${maxHeight + padding * 2}" xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="#F1F1F3"/>
      ${combinedStyle}
      ${combinedSVGContent}
    </svg>
  `;

  padding = 8;
  const cveReductionSVG = `
    <svg width="${severityVulnsDimensions.width + padding * 2}" height="${severityVulnsDimensions.height+ padding * 2}" xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="#F1F1F3"/>
      <g transform="translate(${padding}, ${padding})">
        ${vulnsBySeverityChartSVG}
      </g>
    </svg>
  `;

  saveSVGToFile(combinedSVG,util.format('%s/metrics.svg', imageSavePath))
  saveSVGToFile(cveReductionSVG, util.format('%s/cve_reduction.svg', imageSavePath))

  await sharp(Buffer.from(combinedSVG), {density:72})
    .webp({ lossless: true })
    .toFile(`${imageSavePath}/metrics.webp`);

  await sharp(Buffer.from(cveReductionSVG), {density:72})
    .webp({ lossless: true })
    .toFile(`${imageSavePath}/cve_reduction.webp`);
};


async function readSVGTemplate (filename) {
  // reading svg template
  return await fsPromise.readFile(`./${filename}.svg`, { encoding: 'utf8' });
}

// helper function for initiating svg modifying
async function prepareSVG (filename) {
  const { SVG, registerWindow } = await import('@svgdotjs/svg.js');
  const { createSVGWindow } = await import('svgdom');
  const svgTemplate = await readSVGTemplate(filename);
  const window = createSVGWindow();
  const document = window.document;
  registerWindow(window, document);
  const draw = SVG(document.documentElement);
  draw.svg(svgTemplate);
  return draw
}

// helper function for updating text in tspan of text element
const updateText = (draw, selector, newText) => {
  const textElement = draw.findOne(selector);
  if (textElement) {
    const tspanElement = textElement.findOne('tspan'); // Find <tspan> inside <text>
    if (tspanElement) {
      tspanElement.text(newText);       // Updating text inside <tspan>
      return tspanElement
    }
  }
};

// Generating chart savings chart (vulns, packages, size)
/**
 * 
 * @param {String} title chart title
 * @param {Number} original original value
 * @param {Number} hardened  hardened value
 * @param {Boolean} isSize if size then need to show values with metrics suffix
 * @returns 
 */
async function generateSavingsChart(title, original, hardened, isSize) {
  // preparing data
  let reduction = original - hardened;
  // calc percent
  const percentage = (1 - (hardened / original)) * 100;
  // for size we need to format the bytes
  if (isSize) {
    original = formatBytes(original, 2);
    const unit = original.split(' ')[1];
    hardened = formatBytes(hardened, 2, unit);
    reduction = formatBytes(reduction, 0, unit);
  }

  const draw = await prepareSVG('template_savings_chart')

  // update text fields  in svg
  updateText(draw, '#title', title);
  updateText(draw, '#original_value', original.toString());
  updateText(draw, '#hardened_value', hardened.toString());
  updateText(draw, '#reduction_value', reduction.toString());
  updateText(draw, '#percentage', `${Math.round(percentage)}%`);

  // calculate dash array and dash offset for progress line in svg
  const calculateDasharray = (r) => Math.PI * r * 2;
  const calculateDashoffset = (percentageShown, circumference) => ((100 - percentageShown) / 100) * circumference;
  const dashArray = calculateDasharray(42.8825);
  const dashOffset = calculateDashoffset(percentage, dashArray);
  // set value for circle as progress bar
  const progressCircle = draw.findOne('#progress');
  progressCircle.attr({
    'stroke-dasharray': dashArray,
    'stroke-dashoffset': dashOffset,
  });

  // Calculate width of reduction_value text for setting it centered
  const reductionText = draw.text(reduction.toString()).font({ size: 12, family: 'Inter', weight: 'medium' });
  const reductionWidth = reductionText.bbox().width;
  reductionText.remove(); // remove text after measure

  // Define the center x-coordinate and calculate offset for centering the group
  const centerX = 275;
  const groupOffsetX = centerX + (reductionWidth - 17) / 2;

  // Adjust the position of the reduction group to center it
  const reductionGroup = draw.findOne('#reduction');
  if (reductionGroup) {
    reductionGroup.attr('transform', `translate(${groupOffsetX}, 89)`);
  }

  // return back SVG as string
  return draw.svg();
}

/**
 * 
 * @param {*} original original data usual severity object {critical:n, high:m, ...}
 * @param {*} hardened hardened data usual severity object {critical:n, high:m, ...}
 * @returns {String} svg string
 */
async function generateVulnsBySeverityChart(original, hardened) { 
  // preparing data for chart
  const severities = ['poc', 'critical', 'high', 'medium', 'low', 'unknown', 'na'];
  const datasets = ['original', 'hardened'];
  // Getting max value for bar height
  const maxVal = Math.max(
    ...severities.map((severity) =>
      Math.max(original[severity], hardened[severity])
    )
  );
  // function for calculating bar height
  const calculateHeight = (value) => {
    const maxHeight = 36; // Max bar height in px
    return Math.floor((value / maxVal) * maxHeight);
  };

  // preparing svg
  const draw = await prepareSVG('template_vulns_by_severity')


  severities.forEach((severity) => {
    const mask = draw.defs().mask().id(`mask_${severity}`);
  
    datasets.forEach((dataset) => {
      const summary = dataset === 'original' ? original : hardened;
      const value = summary[severity];
      const columnId = `column_${dataset}_${severity}`;
      const pathElement = draw.findOne(`#${columnId}`);
  
      if (pathElement) {
        const width = 28; // Bar width
        const radius = 5; // border radius for bar
        const height = calculateHeight(value);
        const baseY = 85; // bottom line y for bars (all bars aligned at bottom)
  
        // get new y value and generate new value for path element
        const x = parseFloat(pathElement.attr('d').match(/M(\d+\.?\d*)/)[1]);
        const newPath = createRoundedRectPath(x - 26, baseY - height, width, height, radius);
        
        // updating d and fill attributes
        pathElement.attr('d', newPath);
        pathElement.attr('fill', `${vulnsColorScheme[severity]}${dataset === 'original' ? '33' : 'ff'}`);
  
        // creating mask only for original (original view will be always bg for hardened)
        if (dataset === 'original') {
          // adding rectangular mask with border radius for certain coords and size
          mask.rect(width, height)
              .move(x - 26, baseY - height) // Positioning mask by coords of element
              .radius(radius) // rounding mask corners
              .fill('white'); // white space for visible part of element
        }
        // applying mask to current element
        pathElement.attr('mask', `url(#mask_${severity})`);
  
        // updating text value
        const textSpanElement = updateText(draw, `#${dataset}_${severity}`, value.toString());
        if (textSpanElement && dataset === 'original') {
          // setting position of text above original bar
          textSpanElement.attr({ x: x - 26 + 14, y: baseY - height - 6 });
        }
      }
    });
  });

  // return svg string 
  return draw.svg();
}


async function generateContextualSeverityChart(vulnsOriginalSummary) {
  // preparing data
  const { default: defaultSummary, rfcvss_default: rfcvssSummary } = vulnsOriginalSummary;

  const severities = ['critical', 'high', 'medium', 'low'];
  const datasets = ['original', 'contextual'];

  // Getting max value for bar height
  const maxVal = Math.max(
    ...severities.map((severity) =>
      Math.max(defaultSummary[severity], rfcvssSummary[severity])
    )
  );

  // compute step for chart y ticks
  function calculateStep(maxValue) {
    const magnitude = Math.pow(10, Math.floor(Math.log10(maxValue)));
    const factors = [1, 2, 5]; 
    for (let factor of factors) {
        const step = magnitude * factor;
        if (maxValue / step <= 2) {
            return step;
        }
    }

    return magnitude * 10; 
  }

  const step = calculateStep(maxVal);

  // calculating max height for bar
  const calculateHeight = (value) => {
    const maxHeight = 50; // max bar height
    return (value / maxVal) * maxHeight;
  };
  
  const draw = await prepareSVG('template_contextual_severity');
  
  // updating height and position for every bar
  severities.forEach((severity) => {
    datasets.forEach((dataset) => {
      const summary = dataset === 'original' ? defaultSummary : rfcvssSummary;
      const value = summary[severity];
      const columnId = `column_${severity}_${dataset}`;
      const pathElement = draw.findOne(`#${columnId}`);

      if (pathElement) {
        const width = 28; // bar width
        const radius = 5; // bar border radius
        const height = calculateHeight(value);
        const baseY = 101; // bar bottom line

        // setting new path for bar
        const x = parseFloat(pathElement.attr('d').match(/M(\d+\.?\d*)/)[1]); // getting x coord from path
        const newPath = createRoundedRectPath(x, baseY - height, width, height, radius);
        pathElement.attr('d', newPath);
      }
    });
  });

  // Getting grid ticks values
  const gridValue1 = draw.findOne('#grid_value_1');
  const gridValue2 = draw.findOne('#grid_value_2');

  // Setting grid ticks values
  if (gridValue1) {
    updateText(draw, '#grid_value_1', step.toString());
    gridValue1.attr({ y: 101 - calculateHeight(step) }); // y position for grid_value_1
  }

  if (gridValue2) {
    const grid2Value = step * 2;
    if (grid2Value > maxVal) {
      // Hidding grid_value_2, if it's bigger than max value
      gridValue2.attr({ display: 'none' });
    } else {
      updateText(draw, '#grid_value_2', grid2Value.toString());
      gridValue2.attr({ y: 101 - calculateHeight(grid2Value) });
      gridValue2.attr({ display: 'inline' });
    }
  }

  // return svg as string
  return draw.svg();
}

async function main() {
  const imgListPath = process.argv[2]
  const platform = process.argv[3]

  const imgList = await fsPromise.readFile(imgListPath, { encoding: 'utf8' });
  const imgListArray = imgList.split("\n");

  for await (const imagePath of imgListArray) {
    console.log("image name=", imagePath);
    
    try {
      let imageYmlPath = fs.realpathSync(util.format('../community_images/%s/image.yml', imagePath));

      const imageSavePath = fs.realpathSync(util.format('../community_images/%s/assets', imagePath));
      console.log("Image save path=", imageSavePath);
      let imageYmlContents = await fsPromise.readFile(imageYmlPath, { encoding: 'utf8' });
      let imageYml = await yaml.load(imageYmlContents);
      let imageName = imageYml.report_url?.replace('https://us01.rapidfort.com/app/community/imageinfo/', '');
      console.log('Report URL ', imageYml.report_url)
      console.log('Generating charts for ', decodeURIComponent(imageName))
      await generateCharts(imageName, platform, imageSavePath);
    } catch (err) {
      console.log('Error:', err);
      continue;
    }
  }

}

main();
