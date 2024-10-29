const cvssParserV2 = require('./v2');
const cvssParserV3 = require('./v3');
function memoize(fn) {
  const cache = new Map();
  return function(...args) {
    const key = JSON.stringify(args);
    if (cache.has(key)) {
      return cache.get(key);
    }
    const result = fn.apply(this, args);
    cache.set(key, result);
    return result;
  };
}

const parse = (vector, version) => {
  let parser;
  switch (version){ 
    case 'V2':
      parser = cvssParserV2;
      break;
    case 'V3':
      parser = cvssParserV3;
      break;
    default:
      parser = cvssParserV3;
      break;
  }
  return parser.parse(vector)
};
module.exports = {
  parse:memoize(parse)
}