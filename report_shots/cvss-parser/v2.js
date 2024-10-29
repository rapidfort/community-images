const metricWeights = {
  // Base metrics
  AV: {
      title: 'Access Vector',
      values: {
          N: { weight: 1.0, title: "Network", default:true},
          A: { weight: 0.646, title: "Adjacent Network" },
          L: { weight: 0.395, title: "Local" }
      }
  },
  AC: {
      title: 'Access Complexity',
      values: {
          H: { weight: 0.35, title: "High", default:true },
          M: { weight: 0.61, title: "Medium" },
          L: { weight: 0.71, title: "Low" }
      }
  },
  Au: {
      title: 'Authentication',
      values: {
          M: { weight: 0.45, title: "Multiple", default:true },
          S: { weight: 0.56, title: "Single" },
          N: { weight: 0.704, title: "None" }
      }
  },
  C: {
      title: 'Confidentiality Impact',
      values: {
          N: { weight: 0.0, title: "None" , default:true},
          P: { weight: 0.275, title: "Partial" },
          C: { weight: 0.660, title: "Complete" }
      }
  },
  I: {
      title: 'Integrity Impact',
      values: {
          N: { weight: 0.0, title: "None", default:true },
          P: { weight: 0.275, title: "Partial" },
          C: { weight: 0.660, title: "Complete" }
      }
  },
  A: {
      title: 'Availability Impact',
      values: {
          N: { weight: 0.0, title: "None", default:true },
          P: { weight: 0.275, title: "Partial" },
          C: { weight: 0.660, title: "Complete" }
      }
  },
  // Temporal metrics
  E: {
      title: 'Exploitability',
      values: {
          ND: { weight: 1.0, title: "Not Defined" , default:true},
          U: { weight: 0.85, title: "Unproven" },
          POC: { weight: 0.9, title: "Proof-of-Concept" },
          F: { weight: 0.95, title: "Functional" },
          H: { weight: 1.0, title: "High" }
      }
  },
  RL: {
      title: 'Remediation Level',
      values: {
          ND: { weight: 1.0, title: "Not Defined", default:true },
          OF: { weight: 0.87, title: "Official Fix" },
          TF: { weight: 0.9, title: "Temporary Fix" },
          W: { weight: 0.95, title: "Workaround" },
          U: { weight: 1.0, title: "Unavailable" }
      }
  },
  RC: {
      title: 'Report Confidence',
      values: {
          ND: { weight: 1.0, title: "Not Defined", default:true },
          UC: { weight: 0.9, title: "Uncorroborated" },
          UR: { weight: 0.95, title: "Uncorroborated" },
          C: { weight: 1.0, title: "Confirmed" }
      }
  },
  // Environmental metrics
  CDP: {
      title: 'Collateral Damage Potential',
      values: {
          ND: { weight: 0.0, title: "Not Defined", default:true },
          N: { weight: 0.0, title: "None" },
          L: { weight: 0.1, title: "Low" },
          LM: { weight: 0.3, title: "Low-Medium" },
          MH: { weight: 0.4, title: "Medium-High" },
          H: { weight: 0.5, title: "High" }
      }
  },
  TD: {
      title: 'Target Distribution',
      values: {
          ND: { weight: 1.0, title: "Not Defined", default:true },
          N: { weight: 0.0, title: "None" },
          L: { weight: 0.25, title: "Low" },
          M: { weight: 0.75, title: "Medium" },
          H: { weight: 1.0, title: "High" }
      }
  },
  CR: {
      title: 'Confidentiality Requirement',
      values: {
          ND: { weight: 1.0, title: "Not Defined", default:true },
          L: { weight: 0.5, title: "Low" },
          M: { weight: 1.0, title: "Medium" },
          H: { weight: 1.51, title: "High" }
      }
  },
  IR: {
      title: 'Integrity Requirement',
      values: {
          ND: { weight: 1.0, title: "Not Defined", default:true },
          L: { weight: 0.5, title: "Low" },
          M: { weight: 1.0, title: "Medium" },
          H: { weight: 1.51, title: "High" }
      }
  },
  AR: {
      title: 'Availability Requirement',
      values: {
          ND: { weight: 1.0, title: "Not Defined", default:true },
          L: { weight: 0.5, title: "Low" },
          M: { weight: 1.0, title: "Medium" },
          H: { weight: 1.51, title: "High" }
      }
  }
};
const parse = (vector) => {
  if (!vector) {
    return false;
  }
  const metricsComponents = vector.split("/");
  const startIndex = metricsComponents[0].includes("CVSS2") ? 1 : 0;
  const parsedMetrics = {};

  for (let i = startIndex; i < metricsComponents.length; i++) {
    const [metric, value] = metricsComponents[i].split(":");
    if (metricWeights[metric] && metricWeights[metric]?.values?.[value]) {
      parsedMetrics[metric] = metricWeights[metric]?.values?.[value];
      parsedMetrics[metric].key = value
    } else {
      console.warn(`Unknown metric or value encountered for CVSSv2: ${metric}:${value}`);
    }
  }

  const cvss = {
      metrics: parsedMetrics,
  };

  Object.keys(metricWeights).forEach((key) => {
    cvss.metrics[key] = cvss.metrics[key] ? cvss.metrics[key] : { weight: 0, title: undefined, key:'X' };
  });

  // Define functions to calculate various scores using cvss.metrics for CVSS v2
  function getImpactScore() {
    return 10.41 * (1 - (1 - cvss.metrics.C.weight) * (1 - cvss.metrics.I.weight) * (1 - cvss.metrics.A.weight));
  }

  function getExploitabilityScore() {
    return 20 * cvss.metrics.AV.weight * cvss.metrics.AC.weight * cvss.metrics.Au.weight;
  }

  function getBaseScore() {
    const impact = getImpactScore();
    const exploitability = getExploitabilityScore();
    const fImpactValue = impact === 0 ? 0 : 1.176;
    const baseScore = ((0.6 * impact) + (0.4 * exploitability) - 1.5) * fImpactValue;
    return roundUp(baseScore); // or use a different rounding function if needed
    // return impact === 0 ? 0 : roundUp(Math.min((0.6 * impact) + (0.4 * exploitability) - 1.5, 10.0));
  }

  function getTemporalScore() {
    const tempMetricKeys = ['E', 'RL', 'RC']
    const temporalScoreAvailable = tempMetricKeys.reduce((prev, cur)=> {
      return cvss.metrics[cur].key !== 'X' || prev
    }, false)
    
    if (!temporalScoreAvailable) {
      return 0;
    }
    const E =  (cvss.metrics.E.key !== 'X' ? cvss.metrics.E.weight : 1) ;
    const RL = (cvss.metrics.RL.key !== 'X' ? cvss.metrics.RL.weight : 1);
    const RC = (cvss.metrics.RC.key !== 'X' ? cvss.metrics.RC.weight : 1);
    return roundUp(getBaseScore() * E * RL * RC);
  }

  function getEnvironmentalScore() {
    const environmentalMetrics = ['CR', 'IR', 'AR', 'CDP', 'TD'];
    const allNotDefined = environmentalMetrics.every(metric => cvss.metrics[metric].key === 'ND');

    if (allNotDefined) {
        return null; // or however you wish to represent an undefined score
    } else {
        const temporalScoreAdjusted = getTemporalScore(true); // Assuming this function exists and can handle adjusted impact
        const CDP = (cvss.metrics.CDP.key !== 'ND' ? cvss.metrics.CDP.weight : 1);
        const TD = (cvss.metrics.TD.key !== 'ND' ? cvss.metrics.TD.weight : 1);
        let rawEnvironmentalScore = ((temporalScoreAdjusted + (10 - temporalScoreAdjusted) * CDP) * TD);
        // Round to one decimal place
        rawEnvironmentalScore = roundUp(rawEnvironmentalScore);
        // Ensure the score is not less than 0.0
        return Math.max(0.0, rawEnvironmentalScore);
    }
}
  const baseScore = roundUp(getBaseScore());
  const temporalScore = roundUp(getTemporalScore());
  const environmentalScore = roundUp(getEnvironmentalScore())
  let overallScore = baseScore; // Default to base score

  // If environmental score is not "NA" and not zero, use it
  if (environmentalScore !== "NA" && environmentalScore !== 0) {
    overallScore = environmentalScore;
  } else if (temporalScore !== "NA" && temporalScore !== 0) {
    overallScore = temporalScore;
  }
  return {
      version: 'v2.0',
      vector: vector,
      metrics: cvss.metrics,
      metricWeights:metricWeights,
      impactScore: roundUp(getImpactScore()),
      exploitabilityScore: roundUp(getExploitabilityScore()),
      baseScore: baseScore,
      temporalScore: temporalScore,
      environmentalScore: environmentalScore,
      overallScore:overallScore,
  }
};

// Helper function to round up to one decimal place
function roundUp(number) {
  return Math.round(number * 10) / 10;
}

module.exports = {
  metricWeights:metricWeights,
  parse:parse,
};