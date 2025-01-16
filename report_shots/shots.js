const util = require('util');
const fsPromise = require('fs/promises');
const yaml = require('js-yaml')
const fs = require('fs');
const { parseJSON, parseCSVFormatV2, formatBytes, capitalizeFirstLetter, formatSizeString } = require('./utils');
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
    // const vulnsSavingsChartSVG = await generateSavingsChart('Vulnerabilities', imageInfo.noVulns, imageInfo.noVulnsHardened, false);
    // const packagesSavingsChartSVG = await generateSavingsChart('Packages', imageInfo.noPkgs, imageInfo.noPkgsHardened, false);
    // const sizeSavingsChartSVG = await generateSavingsChart('Attack surface', imageInfo.origImageSize, imageInfo.hardenedImageSize, true);
    // const contextualSeverityChart = await generateContextualSeverityChart(vulnsOriginalSummary)
    // const vulnsBySeverityChart = await generateVulnsBySeverityChart(vulnsOriginalSummary.default, vulnsHardenedSummary.default);
    const {width, svg:vulnsCountChartSVG} = await generateVulnsCountChart(vulnsHardenedSummary.default);
    const vulnsOriginalHardenedChartSVG = await generateVulnsOriginalHardenedChart(width, vulnsOriginalSummary.default, vulnsHardenedSummary.default);


    saveSVGToFile(vulnsCountChartSVG, util.format('%s/vulns_count_chart.svg', imageSavePath));
    saveSVGToFile(vulnsOriginalHardenedChartSVG, util.format('%s/original_vs_hardened_vulns_chart.svg', imageSavePath));
    const vulnsChartMergedSvg = await mergeSvgHorizontally([vulnsCountChartSVG, vulnsOriginalHardenedChartSVG], 24);

    saveSVGToFile(vulnsChartMergedSvg, util.format('%s/vulns_charts.svg', imageSavePath));

    const savingsSVG = await generateSavingsCardsCompound([
      {
        type:'vulns',
        title:'Vulnerabilities',
        original: imageInfo.noVulns,
        hardened:imageInfo.noVulnsHardened,
        isSize:false,
      },
      {
        type:'packages',
        title:'Packages',
        original: imageInfo.noPkgs,
        hardened:imageInfo.noPkgsHardened,
        isSize:false,
      },
      {
        type:'size',
        title:'Size',
        original: imageInfo.origImageSize,
        hardened:imageInfo.hardenedImageSize,
        isSize:true,
      }
    ]);
    saveSVGToFile(savingsSVG, util.format('%s/savings.svg', imageSavePath));
    // save individual charts as svg
    // saveSVGToFile(vulnsSavingsChartSVG, util.format('%s/savings_chart_vulns.svg', imageSavePath));
    // saveSVGToFile(packagesSavingsChartSVG, util.format('%s/savings_chart_pkgs.svg', imageSavePath));
    // saveSVGToFile(sizeSavingsChartSVG, util.format('%s/savings_chart_size.svg', imageSavePath));
    // saveSVGToFile(contextualSeverityChart, util.format('%s/contextual_severity_chart.svg', imageSavePath));
    // saveSVGToFile(vulnsBySeverityChart, util.format('%s/vulns_by_severity_histogram.svg', imageSavePath));
    // generateReportViews(vulnsSavingsChartSVG, packagesSavingsChartSVG, sizeSavingsChartSVG, contextualSeverityChart, vulnsBySeverityChart, imageSavePath);

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
      ${combinedStyle}
      <rect width="100%" height="100%" fill="#F1F1F3"/>
      <g transform="translate(${padding}, ${padding})">
        ${cleanedSVGs[0]}
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
async function prepareSVG(filename) {
  const { SVG, registerWindow } = await import('@svgdotjs/svg.js');
  const { createSVGWindow } = await import('svgdom');
  const svgTemplate = await readSVGTemplate(filename);

  // Extract attributes from the <svg> tag in the template
  const svgTagMatch = svgTemplate.match(/<svg\s+([^>]+)>/);
  const attributes = {};
  if (svgTagMatch) {
    const attrString = svgTagMatch[1];
    attrString.replace(/(\w+)=["']([^"']*)["']/g, (match, name, value) => {
      attributes[name] = value;
    });
  }

  // Remove the outer <svg> tags from the template content
  const innerContent = svgTemplate.replace(/<svg[^>]*>|<\/svg>/g, '');

  // Set up a window and document
  const window = createSVGWindow();
  const document = window.document;
  registerWindow(window, document);

  // Initialize SVG and add only the inner content
  const draw = SVG(document.documentElement);
  draw.svg(innerContent); // Add only the inner content to `draw`

  // Apply extracted attributes to the new <svg> element
  Object.keys(attributes).forEach(attr => draw.attr(attr, attributes[attr]));

  return draw;
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
/**
 * Draws a chart in an SVG based on the provided data.
 *
 * @param {Object} draw - SVG.js object.
 * @param {string} groupId - ID of the group where the chart will be added.
 * @param {number} maxWidth - Maximum width of the chart.
 * @param {Object} vulnsCount - Object with vulnerability counts by severity.
 * @param {number} total - Total value for filling the chart to 100%.
 */
function drawVulnsChart(draw, groupId, maxWidth, vulnsCount, total) {
  const severities = ['critical', 'high', 'medium', 'low', 'unknown'].filter(l => vulnsCount[l] > 0);

  const minWidth = 5;
  const spacing = 2;

  // Calculate initial widths for each severity level
  let initialWidths = severities.map(severity => ({
    severity,
    color: vulnsColorScheme[severity],
    value: vulnsCount[severity],
    width: (vulnsCount[severity] / total) * (maxWidth - spacing * (severities.length - 1))
  }));

  // Adjust widths to meet minimum width requirements and calculate the excess
  let totalExcess = 0;
  initialWidths.forEach(item => {
    if (item.width < minWidth) {
      totalExcess += minWidth - item.width;
      item.width = minWidth;
    }
  });


  // Proportionally distribute the remaining width
  let remainingRects = initialWidths.filter(item => item.width > minWidth);
  let remainingWidth = maxWidth - initialWidths.reduce((acc, item) => acc + item.width, 0) - (spacing * (severities.length - 1));

  if (remainingWidth > 0) {
    remainingRects.forEach(item => {
      item.width += (item.width / remainingRects.reduce((acc, r) => acc + r.width, 0)) * remainingWidth;
    });
  }

  // Find the group by ID and clear any existing elements
  const group = draw.findOne(`#${groupId}`);
  group.clear();

  // Draw rectangles
  let currentX = 0;
  initialWidths.forEach(({ color, width }) => {
    group.rect(width, 8)
      .attr({ x: currentX, y: 0, fill: color });
    currentX += width + spacing;
  });
}


/**
 *
 * @param {*} vulnsCount
 * @returns
 */
async function generateVulnsCountChart(vulnsCount) {
  // Preparing data for chart
  const severities = ['critical', 'high', 'medium', 'low', 'unknown'];
  const draw = await prepareSVG('template_vulns_count');

  const margin = 10;
  const initialSize = 92;
  const maxLegendWidth = severities.reduce((prev, severity)=> {
    // Calculate width of reduction_value text for setting it centered
    const reductionText = draw.text(`${capitalizeFirstLetter(severity)}: ${vulnsCount[severity]}`).font({ size: 12, family: 'InterMedium' });
    const reductionWidth = reductionText.bbox().width;
    reductionText.remove(); // remove text after measure
    return Math.max(reductionWidth + 14 + margin, prev)
  }, 0)

  const offsetMultiplier = [0, 1, 2, 0, 1]
  severities.forEach((severity, index) => {
    updateText(draw, `#text_${severity}`, vulnsCount[severity]);
    const legendGroup = draw.findOne(`#legend_${severity}`);
    legendGroup.attr('transform', `translate(${(maxLegendWidth - initialSize) * offsetMultiplier[index]}, 0)`)
  })
  const initialContentWidth = 316;
  // Prepare SVG
  const contentWidth = Math.max(maxLegendWidth * 3, 316);
  draw.findOne("#vulns_count_mask").attr('width', contentWidth)
  draw.findOne("#external-link").attr('transform', `translate(${contentWidth - initialContentWidth}, 0)`)
  draw.findOne("#vulns_count_mask_rect").attr('width', contentWidth)
  drawVulnsChart(draw, 'vulns_count_view', contentWidth, vulnsCount, vulnsCount.total);
  // Update the total count text
  updateText(draw, '#vulns_total', vulnsCount.total);

  draw.width(contentWidth + 48);
  const currentViewBox = draw.attr('viewBox') || '0 0 100 100';
  const [x, y, , originalHeight] = currentViewBox.split(' ').map(Number);
  const newWidth = contentWidth + 48;
  const updatedViewBox = `${x} ${y} ${newWidth} ${originalHeight}`;
  draw.attr('viewBox', updatedViewBox);

  // return svg as string
  return {width:newWidth, svg: draw.svg()}
}


/**
 *
 * @param {*} vulnsCount
 * @returns
 */
async function generateVulnsOriginalHardenedChart(cardWidth, original, hardened) {
  // Preparing data for chart
  const severities = ['critical', 'high', 'medium', 'low', 'unknown'];
  const data = {
    original: original,
    hardened: hardened
  }
  const draw = await prepareSVG('template_original_vs_hardened');
  const originalValueText = draw.text(`${original.total}`).font({ size: 14, family: 'InterMedium' });
  const originalValueTextWidth = originalValueText.bbox().width;
  originalValueText.remove(); // remove text after measure
  const initialContentWidth = 365;
  draw.findOne("#external-link").attr('transform', `translate(${cardWidth - initialContentWidth}, 0)`)
  draw.findOne(`#original_value_tspan`).attr('x', cardWidth - originalValueTextWidth - 24)
  draw.findOne(`#original_mask`).attr('width', cardWidth - originalValueTextWidth - 24 - 10 - 106)
  draw.findOne(`#original_mask_rect`).attr('width', cardWidth - originalValueTextWidth - 24 - 10 - 106)

  Object.entries(data).forEach(([key, vulnsCount]) => {
    if (original.total === 0) {
      return
    }
    let contentWidth = cardWidth - originalValueTextWidth - 24 - 10 - 106;
    if (key === 'hardened') {
      const minWidth = severities.reduce((prev, severity) => {
        return prev + (vulnsCount[severity] > 0 ? 7 : 0)
      }, 0)
      contentWidth = Math.max(vulnsCount.total / original.total * 197, minWidth);
      draw.findOne(`#hardened_mask`).attr('width', contentWidth)
      draw.findOne(`#hardened_mask_rect`).attr('width', contentWidth)
      draw.findOne(`#hardened_value_tspan`).attr('x', 106 + contentWidth + 10)
    }
    drawVulnsChart(draw, `${key}_count_view`, contentWidth, vulnsCount, vulnsCount.total);
    updateText(draw, `#${key}_value`, vulnsCount.total);
  })

  draw.width(cardWidth);
  const currentViewBox = draw.attr('viewBox');
  const [x, y, , originalHeight] = currentViewBox.split(' ').map(Number);
  const updatedViewBox = `${x} ${y} ${cardWidth} ${originalHeight}`;
  draw.attr('viewBox', updatedViewBox);

  return draw.svg()
}

// Generating chart savings chart (vulns, packages, size)
/**
 *
 * @param {String} title chart title
 * @param {Number} original original value
 * @param {Number} hardened  hardened value
 * @param {Boolean} isSize if size then need to show values with metrics suffix
 * @returns
 */
async function generateSavingsCardsCompound(savingsData) {
  const draw = await prepareSVG('template_savings_view')
  savingsData.forEach(async ({type, title, original, hardened, isSize}) => {
    const percentage = (1 - (hardened / original)) * 100;
    if (isSize) {
      original = formatSizeString(formatBytes(original, 2));
      const unit = original.split(' ')[1];
      hardened = formatSizeString(formatBytes(hardened, 2, unit));
    }

    // update text fields  in svg
    updateText(draw, `#${type}_title`, title);
    updateText(draw, `#${type}_original_value`, original.toString());
    updateText(draw, `#${type}_hardened_value`, hardened.toString());
    updateText(draw, `#${type}_percentage`, `${Math.round(-percentage)}%`);

    // calculate dash array and dash offset for progress line in svg
    const calculateDasharray = (r) => Math.PI * r * 2;
    const calculateDashoffset = (percentageShown, circumference) => ((100 - percentageShown) / 100) * circumference;
    const dashArray = calculateDasharray(33.5);
    const dashOffset = calculateDashoffset(100 - percentage, dashArray);
    // set value for circle as progress bar
    const progressCircle = draw.findOne(`#${type}_progress`);

    progressCircle.attr({
      'stroke-dasharray': dashArray,
      'stroke-dashoffset': dashOffset,
    });

  // return back SVG as string
  });

  // Adjust the width to 760px and set the height proportionally
  draw.width(760); // Set the width to 760px
  const { width, height } = draw.viewbox(); // Get original dimensions from viewBox
  const newHeight = (760 / width) * height; // Scale height proportionally
  draw.size(760, newHeight); // Set the new size on the SVG

  return draw.svg();
}


async function mergeSvgHorizontally(svgStrings, gap) {
  const { SVG, registerWindow } = await import('@svgdotjs/svg.js');
  const { createSVGWindow } = await import('svgdom');
  const window = createSVGWindow();
  const document = window.document;
  registerWindow(window, document);

  const remainingCSSList = [];
  const canvas = SVG(document.documentElement);
  const uniqueCSSRules = new Set();
  let totalWidth = 0;
  let maxHeight = 0;
  let fontFaceCaptured = false; // Track if font-face has already been captured

  svgStrings.forEach((svgString, index) => {
    // Extract all styles content
    const styleMatch = svgString.match(/<style[^>]*>([\s\S]*?)<\/style>/);
    if (styleMatch && styleMatch[1]) {
      let styleContent = styleMatch[1];
      // Extract `@font-face` and other CSS rules separately
      const fontFaceRules = styleContent.match(/@font-face\s*{[^}]*}/g) || [];
      const remainingCSS = styleContent.replace(/@font-face\s*{[^}]*}/g, '').trim();
      // Add only the first set of `@font-face` rules
      if (!fontFaceCaptured) {
        fontFaceRules.forEach(rule => uniqueCSSRules.add(rule));
        fontFaceCaptured = true;
      }
      remainingCSSList.push(remainingCSS);
    }

    const svgWithoutStyle = svgString.replace(/<style[^>]*>([\s\S]*?)<\/style>/, '');
    const svg = SVG(svgWithoutStyle);

    const width = svg.width();
    const height = svg.height();

    if (index > 0) totalWidth += gap;
    svg.move(totalWidth, 0); // Move each SVG horizontally with the specified gap
    totalWidth += width;
    maxHeight = Math.max(maxHeight, height);

    canvas.add(svg);
  });

  // Construct the final style tag with unique rules
  const combinedStyle = `<style>${[...uniqueCSSRules, ...remainingCSSList].join('\n')}</style>`;

  // Add the combined styles to the canvas
  canvas.svg(combinedStyle + canvas.svg());

  // Set the viewBox to scale down the combined SVG to a width of 760px
  const scaleFactor = 760 / totalWidth;
  const scaledHeight = maxHeight * scaleFactor;
  canvas.viewbox(0, 0, totalWidth, maxHeight); // Set the viewBox based on the combined content size
  canvas.size(760, scaledHeight); // Set the final scaled width and proportional height

  return canvas.svg();
}
async function main() {
  const imgListPath = process.argv[2]
  const platform = process.argv[3]

  const imgList = await fsPromise.readFile(imgListPath, { encoding: 'utf8' });
  const imgListArray = imgList.split("\n");
  // const imgListArray = ['apache/official'];

  for await (const imagePath of imgListArray) {

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
