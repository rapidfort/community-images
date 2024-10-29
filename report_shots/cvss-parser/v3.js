const { roundUp } = require('./helpers');
const metricWeights = {
  // Base Metric Group
  AV: {
      title: 'Attack Vector',
      default:0.85, 
      values: {
          N: { weight: 0.85, title: "Network" },
          A: { weight: 0.62, title: "Adjacent Network" },
          L: { weight: 0.55, title: "Local" },
          P: { weight: 0.2, title: "Physical" }
      }
  },
  AC: {
      title: 'Attack Complexity',
      values: {
          L: { weight: 0.77, title: "Low" },
          H: { weight: 0.44, title: "High" }
      }
  },
  PR: {
      title: 'Privileges Required',
      values: {
          N: { weight: 0.85, title: "None" },
          L: { weight: 0.62, title: "Low" },
          H: { weight: 0.27, title: "High" }
      },
      valuesChanged: {
        N: { weight: 0.85, title: "None" },
        L: { weight: 0.68, title: "Low" },
        H: { weight: 0.50, title: "High" },
        X: { weight: 0, title: "High" }
      }
  },
  UI: {
      title: 'User Interaction',
      values: {
          N: { weight: 0.85, title: "None" },
          R: { weight: 0.62, title: "Required" }
      }
  },
  S: {
      title: 'Scope',
      values: {
          U: { weight: 0, title: "Unchanged" },
          C: { weight: 0, title: "Changed" }
      }
  },
  C: {
      title: 'Confidentiality Impact',
      values: {
          N: { weight: 0, title: "None" },
          L: { weight: 0.22, title: "Low" },
          H: { weight: 0.56, title: "High" }
      }
  },
  I: {
      title: 'Integrity Impact',
      default:0, 
      values: {
          N: { weight: 0, title: "None" },
          L: { weight: 0.22, title: "Low" },
          H: { weight: 0.56, title: "High" }
      }
  },
  A: {
      title: 'Availability Impact',
      values: {
          N: { weight: 0, title: "None" },
          L: { weight: 0.22, title: "Low" },
          H: { weight: 0.56, title: "High" }
      }
  },
  // Temporal Metric Group
  E: {
      title: 'Exploit Code Maturity',
      values: {
          X: { weight: 1, title: "Not Defined" },
          H: { weight: 1, title: "High" },
          F: { weight: 0.97, title: "Functional" },
          P: { weight: 0.94, title: "Proof-of-Concept" },
          U: { weight: 0.91, title: "Unproven" }
      }
  },
  RL: {
      title: 'Remediation Level',
      default:1, 
      values: {
          X: { weight: 1, title: "Not Defined" },
          O: { weight: 0.95, title: "Official Fix" },
          T: { weight: 0.96, title: "Temporary Fix" },
          W: { weight: 0.97, title: "Workaround" },
          U: { weight: 1, title: "Unavailable" }
      }
  },
  RC: {
      title: 'Report Confidence',
      default:1, 
      values: {
          X: { weight: 1, title: "Not Defined" },
          C: { weight: 1, title: "Confirmed" },
          R: { weight: 0.96, title: "Reasonable" },
          U: { weight: 0.92, title: "Unknown" }
      }
  },
  // Environmental Metric Group
  CR: {
      title: 'Confidentiality Requirement',
      default:1, 
      values: {
          X: { weight: 1, title: "Not Defined" },
          L: { weight: 0.5, title: "Low" },
          M: { weight: 1, title: "Medium" },
          H: { weight: 1.5, title: "High" }
      }
  },
  IR: {
      title: 'Integrity Requirement',
      default:1, 
      values: {
          X: { weight: 1, title: "Not Defined" },
          L: { weight: 0.5, title: "Low" },
          M: { weight: 1, title: "Medium" },
          H: { weight: 1.5, title: "High" }
      }
  },
  AR: {
      title: 'Availability Requirement',
      default:1, 
      values: {
          X: { weight: 1, title: "Not Defined" },
          L: { weight: 0.5, title: "Low" },
          M: { weight: 1, title: "Medium" },
          H: { weight: 1.5, title: "High" }
      }
  },
  // Modified Base Metrics
  MAV: {
      title: 'Modified Attack Vector',
      default:0.85, 
      values: {
          X: { weight: 0.85, title: "Not Defined" },
          N: { weight: 0.85, title: "Network" },
          A: { weight: 0.62, title: "Adjacent" },
          L: { weight: 0.55, title: "Local" },
          P: { weight: 0.2, title: "Physical" }
      }
  },
  MAC: {
      title: 'Modified Attack Complexity',
      default:0.77, 
      values: {
          X: { weight: 0.77, title: "Not Defined"},
          L: { weight: 0.77, title: "Low" },
          H: { weight: 0.44, title: "High" }
      }
  },
  MPR: {
      title: 'Modified Privileges Required',
      default:0.85, 
      values: {
          X: { weight: 0.85, title: "Not Defined" },
          N: { weight: 0.85, title: "None" },
          L: { weight: 0.62, title: "Low" },
          H: { weight: 0.27, title: "High" }
      }
  },
  MUI: {
      title: 'Modified User Interaction',
      default:0.85, 
      values: {
          X: { weight: 0.85, title: "Not Defined" },
          N: { weight: 0.85, title: "None" },
          R: { weight: 0.62, title: "Required" }
      }
  },
  MS: {
      title: 'Modified Scope',
      default:6.42, 
      values: {
          X: { weight: 6.42, title: "Not Defined" },
          U: { weight: 6.42, title: "Unchanged" },
          C: { weight: 7.52, title: "Changed" }
      }
  },
  MC: {
      title: 'Modified Confidentiality',
      default:0, 
      values: {
          X: { weight: 0, title: "Not Defined" },
          N: { weight: 0, title: "None" },
          L: { weight: 0.22, title: "Low" },
          H: { weight: 0.56, title: "High" }
      }
  },
  MI: {
      title: 'Modified Integrity',
      default:0, 
      values: {
          X: { weight: 0, title: "Not Defined" },
          N: { weight: 0, title: "None" },
          L: { weight: 0.22, title: "Low" },
          H: { weight: 0.56, title: "High" }
      }
  },
  MA: {
      title: 'Modified Availability',
      default:0, 
      values: {
          X: { weight: 0, title: "Not Defined" },
          N: { weight: 0, title: "None" },
          L: { weight: 0.22, title: "Low" },
          H: { weight: 0.56, title: "High" }
      }
  }
};

const parse = (vector)=> {
    if (!vector) {
        return false;
    }

    const metricsComponents = vector.split("/");
    const version = metricsComponents[0].includes("CVSS") ? metricsComponents[0].split(":")[1] : "Unknown";
    const startIndex = metricsComponents[0].includes("CVSS") ? 1 : 0;

    const parsedMetrics = {};
    for (let i = startIndex; i < metricsComponents.length; i++) {
      const [metric, value] = metricsComponents[i].split(":"); 
      
      if (metricWeights[metric] && metricWeights[metric]?.values?.[value]) {
        parsedMetrics[metric] = {...metricWeights[metric].values?.[value]};
        parsedMetrics[metric].key = value
      }
    }
    const cvss = {
      metrics: parsedMetrics,
    };
    // Adjust the PR weight if necessary
    ['PR', 'MRP'].forEach((l)=> {
        if (cvss.metrics?.[l] && cvss.metrics.S && cvss.metrics.S.key === 'C') {
            // Adjust PR weight for 'Changed' scope
            const prAdjustments = { 'N': 0.85, 'L': 0.68, 'H': 0.50 };
            const prValue = cvss.metrics[l].key;
            if (prAdjustments[prValue]) {
                cvss.metrics[l].weight = prAdjustments[prValue];
            }
        }
    })

    // Ensure all required metrics are present
    Object.keys(metricWeights).forEach((key) => {
      cvss.metrics[key] = cvss.metrics[key] ? cvss.metrics[key] : { weight: 0, title: undefined, key:'X' };
    });

  function getImpactScore() {
    const ISCbase = 1 - (1 - cvss.metrics.C.weight) * (1 - cvss.metrics.I.weight) * (1 - cvss.metrics.A.weight);
    return cvss.metrics.S.title === 'Changed' ? 7.52 * (ISCbase - 0.029) - 3.25 * Math.pow(ISCbase - 0.02, 15) : 6.42 * ISCbase;
  }
  
  function getExploitabilityScore() {
      return (
        8.22 *
          cvss.metrics.AV.weight *
          cvss.metrics.AC.weight *
          cvss.metrics.PR.weight *
          cvss.metrics.UI.weight
      );
  }

  
  function getBaseScore() {
      const ISC = getImpactScore();
      const ESC = getExploitabilityScore();

      let baseScore = 0;
      if (ISC > 0) {
          if (cvss.metrics.S.title === 'Changed')
              baseScore = Math.min(1.08 * (ISC + ESC), 10);
          else
              baseScore = Math.min(ISC + ESC, 10);
      }
  
      return roundUp(baseScore);
  }
  
  function getTemporalScore() {
    const envMetricKeys = ['E', 'RL', 'RC']
    const temporalScoreAvailable = envMetricKeys.reduce((prev, cur)=> {
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
    // First, handle 'X' values by setting them to the base score values
    
    const envMetricKeys = ['MC', 'MI', 'MA', 'MAV', 'MAC', 'MPR', 'MUI', 'CR', 'IR', 'AR']
    const environmentalScoreAvailable = envMetricKeys.reduce((prev, cur)=> {
      return cvss.metrics[cur].key !== 'X' || prev
    }, false)
    
    if (!environmentalScoreAvailable) {
      return 0;
    }
    const MC = cvss.metrics.MC.key !== 'X' ? cvss.metrics.MC.weight : cvss.metrics.C.weight;
    const MI = cvss.metrics.MI.key !== 'X' ? cvss.metrics.MI.weight : cvss.metrics.I.weight;
    const MA = cvss.metrics.MA.key !== 'X' ? cvss.metrics.MA.weight : cvss.metrics.A.weight;

    const MAV = cvss.metrics.MAV.key !== 'X' ? cvss.metrics.MAV.weight : cvss.metrics.AV.weight;
    const MAC = cvss.metrics.MAC.key !== 'X' ? cvss.metrics.MAC.weight : cvss.metrics.AC.weight;
    const MPR = cvss.metrics.MPR.key !== 'X' ? cvss.metrics.MPR.weight : cvss.metrics.PR.weight;
    const MUI = cvss.metrics.MUI.key !== 'X' ? cvss.metrics.MUI.weight : cvss.metrics.UI.weight;

    const CR = cvss.metrics.CR.key !== 'X' ? cvss.metrics.CR.weight : 1;
    const IR = cvss.metrics.IR.key !== 'X' ? cvss.metrics.IR.weight : 1;
    const AR = cvss.metrics.AR.key !== 'X' ? cvss.metrics.AR.weight : 1;

    // Now calculate the ISC Modified using the base or modified values as appropriate
    const ISCmodified = Math.min(1 - (1 - MC * CR) * (1 - MI * IR) * (1 - MA * AR), 0.915);

    let mISC;
    if (cvss.metrics.MS && cvss.metrics.MS.title === 'Changed') {
        // Use the original formula for CVSS v3.0
        mISC = 7.52 * (ISCmodified - 0.029) - 3.25 * Math.pow(ISCmodified * 0.9731 - 0.02, 13);
    } else {
        mISC = 6.42 * ISCmodified;
    }

    // Calculate Modified Exploitability Subscore
    const mESC = 8.22 * MAV * MAC * MPR * MUI;

    let environmentalScore = 0;
    if (mISC > 0) {
        if (cvss.metrics.MS && cvss.metrics.MS.title === 'Changed') {
            environmentalScore = roundUp(Math.min(1.08 * (mISC + mESC), 10)) * 
                                 (cvss.metrics.E.key !== 'X' ? cvss.metrics.E.weight : 1) *
                                 (cvss.metrics.RL.key !== 'X' ? cvss.metrics.RL.weight : 1) *
                                 (cvss.metrics.RC.key !== 'X' ? cvss.metrics.RC.weight : 1);
        } else {
            environmentalScore = roundUp(Math.min(mISC + mESC, 10)) * 
                                 (cvss.metrics.E.key !== 'X' ? cvss.metrics.E.weight : 1) *
                                 (cvss.metrics.RL.key !== 'X' ? cvss.metrics.RL.weight : 1) *
                                 (cvss.metrics.RC.key !== 'X' ? cvss.metrics.RC.weight : 1);
        }
    }
    return roundUp(environmentalScore);
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
      version: version,
      vector: vector,
      metrics: cvss.metrics,
      impactScore: getImpactScore().toFixed(1),
      metricWeights:metricWeights,
      exploitabilityScore: getExploitabilityScore().toFixed(1),
      baseScore: baseScore,
      temporalScore: temporalScore,
      environmentalScore: environmentalScore,
      overallScore:overallScore,
  };
}

module.exports = {
    metricWeights:metricWeights,
    parse:parse,
};