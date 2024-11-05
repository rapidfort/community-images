const parseJSON = (result) => {
  return result.text().then(function(text) {
    try {
      return JSON.parse(text);
    } catch {
      const arr = text.split('\n');
      for (let i = 0; i < arr.length; i++) {
        const line = arr[i]
        try {
          const lineJSON =  JSON.parse(line);
          if(typeof lineJSON === 'object') {
            return lineJSON
          }
        } catch (error) {
          console.log('error', error)
        }
      }
    }
    return text
  })
}

function formatBytes (bytes, decimals = 2, forceUnit = null) {
  if (bytes === 0) return '0 Bytes';

  const k = 1000;
  const dm = decimals < 0 ? 0 : decimals;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  let i;
  if (forceUnit === null) {
    i = Math.floor(Math.log(Math.abs(bytes)) / Math.log(k));
  } else {
    i = sizes.indexOf(forceUnit);
  }

  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}


function toCamelCase(str) {
  return str
      // First, lowercases the string to handle cases like 'Hello-World'
      .toLowerCase()
      // Then, replaces any non-alphanumeric character (or set of characters) followed by an alphanumeric character
      .replace(/[^a-zA-Z0-9]+(.)/g, (match, chr) => chr.toUpperCase());
}

const parseCSVFormatV2 = ({fields, data}, topLevel) => {
  const reducer = (prev, cur, index) => {
    if (Array.isArray(fields[index])) {
      const [key, subheaders] = fields[index]
      prev[toCamelCase(key)] = parseCSVFormatV2({fields:subheaders, data:cur})
    } else {
      prev[toCamelCase(fields[index])] = cur
    }
    return prev
  }
  const mapper = (l) => {
    return l?.reduce?.(reducer, {}) ?? {}
  }
  let result
  if ((data?.length > 0 && Array.isArray(data[0]))) {
    result = data?.map?.(mapper)
  } else {
    result = data?.reduce?.(reducer, {}) ?? topLevel ? [] : {}
  }
  return result
}
 
const  capitalizeFirstLetter = (string) => {
  if (!string) {
    return string
  }
  return string.charAt(0).toUpperCase() + string.slice(1);
}

function formatSizeString(sizeString) {
  const [size, unit] = sizeString.split(' ');
  let number = parseFloat(size);

  // Determine the number of significant digits and format accordingly
  const digitCount = Math.floor(Math.log10(number)) + 1;

  // Format based on the number of digits
  const formattedSize = digitCount >= 3
    ? Math.floor(number) // Show as an integer if 3 or more digits
    : parseFloat(number.toPrecision(3)); // Show up to 3 significant digits

  // Return the formatted size with the unit (no space before the unit)
  return `${formattedSize}${unit}`;
}

module.exports = {
  parseJSON,
  parseCSVFormatV2,
  formatBytes,
  capitalizeFirstLetter,
  formatSizeString
};
