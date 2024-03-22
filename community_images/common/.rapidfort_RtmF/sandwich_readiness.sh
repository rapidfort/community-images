#!/.rapidfort_RtmF/bash-static --norc
# --noprofile

export RF_ORIG_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
export RF_ORIG_PATH=${PATH}

export LD_LIBRARY_PATH=/.rapidfort_RtmF
export PATH=/.rapidfort_RtmF:/.rapidfort_RtmF/_tools

if test -z "$RF_VERBOSE" ; then
  export RF_VERBOSE=0
fi
if [ "$RF_VERBOSE" -ne "0" ] ; then
  set -x
fi

if test -e /.rapidfort_RtmF/sandwich_init.${RAPIDFORT_RTMF_POD_UID}.ready ; then
  echo "/.rapidfort_RtmF/sandwich_init.${RAPIDFORT_RTMF_POD_UID}.ready exists"
  exit 0
else
  echo "/.rapidfort_RtmF/sandwich_init.${RAPIDFORT_RTMF_POD_UID}.ready DOES NOT exist"
  exit 1
fi

