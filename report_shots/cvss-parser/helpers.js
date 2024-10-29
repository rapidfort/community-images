function roundUpApprox(num, precision) {
  precision = Math.pow(10, precision);
  return Math.ceil(num * precision) / precision;
}
function roundUpExact(num) {
  const int_input = Math.round(num * 100000);
  if (int_input % 10000 === 0) {
    return int_input / 100000;
  } else {
    return (Math.floor(int_input / 10000) + 1) / 10;
  }
}
function roundUp (value) {
  let rounded = Math.round(value * 100000);
  return rounded % 10000 === 0 ? rounded / 100000.0 : (Math.floor(rounded / 10000) + 1) / 10.0;
}

module.exports = {
  roundUpApprox,
  roundUpExact,
  roundUp
};