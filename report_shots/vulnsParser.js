const { parse : parseCVSS } = require('./cvss-parser/cvss');



const vulnsColorScheme = {
  exploited:'#C62A2F',
  critical:'#DF1C41',
  high:'#6E3FF3',
  medium:'#F2AE40',
  low:'#35B9E9',
  unknown:'#8b8d98',
  poc:'#C62A2F',
  na:'#32D583',
}
const SEVERITY = {
  CRITICAL: 'critical',
  HIGH: 'high',
  MEDIUM: 'medium',
  LOW: 'low',
  UNKNOWN: 'unknown'
}


const SEVERITY_DETAIL = {
  [SEVERITY.CRITICAL]: {
    id: SEVERITY.CRITICAL,
    order: 0,
    label: 'Critical',
    color: vulnsColorScheme.critical
  },
  [SEVERITY.HIGH]: {
    id: SEVERITY.HIGH,
    order: 1,
    label: 'High',
    color: vulnsColorScheme.high
  },
  [SEVERITY.MEDIUM]: {
    id: SEVERITY.MEDIUM,
    order: 2,
    label: 'Medium',
    color: vulnsColorScheme.medium
  },
  [SEVERITY.LOW]: {
    id: SEVERITY.LOW,
    order: 3,
    label: 'Low',
    color:vulnsColorScheme.low
  },
  [SEVERITY.UNKNOWN]: {
    id: SEVERITY.UNKNOWN,
    order: 4,
    label: 'Unknown',
    color: vulnsColorScheme.unknown
  },
}

const applyVectorModifiers = (vector, version, pocAvailable, execPath) => {
  // Parse the vector string into an object
  const vectorParams = vector.split('/').reduce((acc, param) => {
    const [key, value] = param.split(':');
    acc[key] = value;
    return acc;
  }, {});

  // Update the Exploit Code Maturity if pocAvailable is true
  if (!pocAvailable) {
    vectorParams.E = 'U';
    vectorParams.RL = version === 'V2' ? 'ND' : 'X';
    vectorParams.RC = version === 'V2' ? 'ND' : 'X';
  }

  // Update the Attack Complexity and User Interaction if execPath is true
  if (!execPath && version === 'V3') {
    vectorParams.MAC = 'H';
    vectorParams.MUI = 'R';
  }

  // Construct the updated vector string
  const updatedVector = Object.entries(vectorParams)
    .map(([key, value]) => `${key}:${value}`)
    .join('/');

  return updatedVector;
};


function getSeverity(version, score) {
  const ratings = {
      'V2': [
          { threshold: 0.0, label: 'UNKNOWN' },
          { threshold: 3.9, label: 'LOW' },
          { threshold: 6.9, label: 'MEDIUM' },
          { threshold: 10.0, label: 'HIGH' }
      ],
      'V3': [
          { threshold: 0.0, label: 'UNKNOWN' },
          { threshold: 3.9, label: 'LOW' },
          { threshold: 6.9, label: 'MEDIUM' },
          { threshold: 8.9, label: 'HIGH' },
          { threshold: 10.0, label: 'CRITICAL' }
      ]
  };

  const rating = ratings[version];
  if (!rating) return 'UNKNOWN';

  for (let i = 0; i < rating.length; i++) {
      if (score <= rating[i].threshold) {
          return rating[i].label;
      }
  }
}

const applyContextualCVSS = (item, type, imageHardened)=> {
  const version = item[type]?.Version;
  let vector = item[type].SeverityVector;
  let score = item[type].SeverityScore;
  let severity = item[type].Severity;
  if (vector !== '-') {
    vector = applyVectorModifiers(vector, version, item.RRS === 1, !imageHardened || item.hardened)
    let parsedData = parseCVSS(vector, version);
    score = parsedData;
    const severity = getSeverity(version, parsedData.overallScore) ?? 'Unknown'
    return {
      Severity : (SEVERITY_DETAIL[severity.toLowerCase()]?.order ?? 0) > (SEVERITY_DETAIL[item[type]?.Severity.toLowerCase()]?.order) ? severity : item[type].Severity,
      SeverityScore: parsedData.overallScore ?? score,
      SeverityVector: vector,
      Source: item[type].SeveritySource,
      Version: version,
      parsedData:parsedData,
    }
  } else {
    return {
      Severity: severity,
      SeverityScore : score,
      SeverityVector : vector,
      Source: item[type].SeveritySource,
      Version : version,
    }
  }
}

const vulnsCountInfoObjTemplate = {
  critical:0, 
  medium: 0, 
  high: 0, 
  low: 0, 
  unknown:0,
  total : 0,
  poc: 0,
  na: 0
}

const updateSeverityInfo = (item, cvss, severity, severitySource, severityRef, imageHardened) => {
  const nvdScale = cvss?.nvd?.V3Score ? 'V3' : cvss?.nvd?.V2Score ? 'V2' : severityRef?.nvd?.V3Severity ? 'V3' : severityRef?.nvd?.V2Severity ? 'V2' : '-';
  const defaultScale = cvss?.[severitySource]?.V3Score ? 'V3' : cvss?.[severitySource]?.V2Score ? 'V2' : severityRef?.[severitySource]?.V3Severity ? 'V3' : severityRef?.[severitySource]?.V2Severity ? 'V2' : '-';;
  item.nvd = {
    Severity : severityRef?.nvd?.[`${nvdScale}Severity`] ?? 'UNKNOWN',
    SeverityScore : (parseFloat(cvss?.nvd?.[`${nvdScale}Score`]) > 0 ? cvss?.nvd?.[`${nvdScale}Score`] : '-') ?? '-',
    SeverityVector : cvss?.nvd?.[`${nvdScale}Vector`] ?? '-',
    Source:'NVD',
    Version : nvdScale,
  }
  
  item.default  = {
    Severity : severity ?? '',
  }
  item.default = {
    Severity : severity,
    Source:severitySource,
    SeverityScore : (parseFloat(cvss?.[severitySource]?.[`${defaultScale}Score`]) > 0 ? cvss?.[severitySource]?.[`${defaultScale}Score`] : '-') ?? '-',
    SeverityVector : cvss?.[severitySource]?.[`${defaultScale}Vector`] ?? '-',
    Version : defaultScale,
  }

  item.rfcvss = {}
  
  item.rfcvss_nvd = applyContextualCVSS(item, 'nvd', imageHardened)
  if (severitySource.toLowerCase() === 'nvd') {
    item.rfcvss_default = item.rfcvss_nvd
  } else {
    item.rfcvss_default = applyContextualCVSS(item, 'default', imageHardened)
  }

  if (!cvss) {
    if (cvss?.[severitySource]?.V3Score) {
      item.default.Version = 'V3'
      item.default.SeverityScore = cvss?.[severitySource]?.V3Score
    } else if (cvss?.[severitySource]?.V2Score) {
      item.default.Version = 'V2'
      item.default.SeverityScore = cvss?.[severitySource]?.V2Score
    } else {
      item.default.Version = '-'
      item.default.SeverityScore = '-'
    }
  }
}

const convertVulnsData = (data, imageHardened, isHardened, flags) => { 
  let vulnsSeverityCount = {default: {...vulnsCountInfoObjTemplate}, nvd:{...vulnsCountInfoObjTemplate}, rfcvss_nvd:{...vulnsCountInfoObjTemplate}, rfcvss_default:{...vulnsCountInfoObjTemplate}}
  const seenVulns = new Map();
  const seenNotApplicableVulns = new Map();
  const hardenedVulnsFlags = {}
  let appKeyIndex = 0;
  data?.forEach?.((cur, index) => {
    cur?.Vulnerabilities?.forEach?.((item)=> {
      let appKey = appKeyIndex++;
      if ((cur.Class && cur.Class === 'os-pkgs') || (!cur.Class && index === 0)) {
        appKey = cur.Type;
      }
      if (isHardened) {
        item.hardened = true;
        hardenedVulnsFlags[`i:${item.VulnerabilityID}|v${item.InstalledVersion}|p${item.PkgName}`] = true
      } else {
        item.hardened = flags[`i:${item.VulnerabilityID}|v${item.InstalledVersion}|p${item.PkgName}`]
      }
      item.applicable = item.RFJustification?.status === 'na' ? false : true;
      item.Severity = (item.Severity) ? item.Severity : 'UNKNOWN'
      updateSeverityInfo(item, item.CVSS, item.Severity, item.SeveritySource, item.SeverityRef, imageHardened)
      const key = `${item.VulnerabilityID}_${item?.SourcePkgName ?? item?.PkgName}_${item.PkgSource}_${item.SourceVersion}_${appKey}`;
      let isFirstOccurency = false;
      if (item.applicable) {
        if (!seenVulns.has(key)) {
          isFirstOccurency = true
          seenVulns.set(key, item);
        }
      } else {
        if (!seenNotApplicableVulns.has(key)) {
          isFirstOccurency = true
          item.Packages = [item.PkgName]
          seenNotApplicableVulns.set(key, item);
        }
      }
      const advisories = ['default', 'rfcvss_default'];
      // const advisories = ['default', 'rfcvss_default', 'nvd', 'rfcvss_nvd'];
      advisories.forEach(advisory => {
        const severitykey = item[advisory]?.Severity.toLowerCase() ?? 'unknown'
        if (item.applicable) {
          if (isFirstOccurency) {
            vulnsSeverityCount[advisory][severitykey]++;
            if (item.RRS >= 1) {
              vulnsSeverityCount[advisory].poc++;
            }
            vulnsSeverityCount[advisory].total++
          }
        } else {
          if (isFirstOccurency) {
            vulnsSeverityCount[advisory].na++;
          }
        }
      })
    })
  })
  return {
    hardenedVulnsFlags,
    vulnsSeverityCount
  }
}


module.exports = {
  applyContextualCVSS,
  convertVulnsData,
  vulnsColorScheme,
};