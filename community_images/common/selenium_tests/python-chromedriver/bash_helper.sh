set -o errexit
set -o nounset
set -o pipefail

# Retry a command on a particular exit code, up to a max number of attempts,
# with exponential backoff.
# Invocation:
#   err_retry exit_code attempts sleep_multiplier <command>
# exit_code: The exit code to retry on.
# attempts: The number of attempts to make.
# sleep_millis: Multiplier for sleep between attempts. Examples:
#     If multiplier is 1000, sleep intervals are 1, 2, 4, 8, 16, etc. seconds.
#     If multiplier is 5000, sleep intervals are 5, 10, 20, 40, 80, etc. seconds.
function err_retry() {
  local exit_code=$1
  local attempts=$2
  local sleep_millis=$3
  shift 3
  for attempt in `seq 1 $attempts`; do
    if [[ $attempt -gt 1 ]]; then
      echo "Attempt $attempt of $attempts"
    fi
    # This weird construction lets us capture return codes under -o errexit
    "$@" && local rc=$? || local rc=$?
    if [[ ! $rc -eq $exit_code ]]; then
      return $rc
    fi
    if [[ $attempt -eq $attempts ]]; then
      return $rc
    fi
    local sleep_ms="$(($attempt * $attempt * $sleep_millis))"
    sleep "${sleep_ms:0:-3}.${sleep_ms: -3}"
  done
}
