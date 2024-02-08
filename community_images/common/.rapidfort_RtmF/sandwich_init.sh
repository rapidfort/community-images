#!/.rapidfort_RtmF/bash-static --norc
# --noprofile

export RF_ORIG_LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
export RF_ORIG_PATH=${PATH}

export LD_LIBRARY_PATH=/.rapidfort_RtmF
export PATH=/.rapidfort_RtmF:/.rapidfort_RtmF/_tools

if test -z "$RF_VERBOSE" ; then
  export RF_VERBOSE=0
fi

export RAPIDFORT_SANDWICH_TOKEN=${1}
export RAPIDFORT_SANDWICH_INFO=${2}
export RAPIDFORT_ORIG_UID=$(id -u)
export RAPIDFORT_ORIG_GID=$(id -g)

if [ "${RAPIDFORT_ORIG_UID}" = "0" ] ; then
  chown 0:0 /.rapidfort_RtmF/resock
  chmod +s /.rapidfort_RtmF/resock
fi

  echo "SI: DEBUG RESOCK" 1>&2
  ## debug builds of resock are compiled with address sanitizer
  ## k8s prodmon environments may run without SYS_PTRACE, which is sometimes needed by LSAN, so disable leak checking
  export ASAN_OPTIONS="detect_leaks=0"
  ## export LSAN_OPTIONS="verbosity=1:log_threads=1"
  ## the following is useful for debugging but does not retain PID1
  if false ; then
    if /.rapidfort_RtmF/resock --auto -v ${RF_VERBOSE} ; then
      echo "SI: success."
      exit 0
    else
      export LD_LIBRARY_PATH=/.rapidfort_RtmF
      export PATH=/.rapidfort_RtmF:/.rapidfort_RtmF/_tools
      echo "SI: ERROR: resock failed" 1>&2
      echo "/.rapidfort_RtmF/rfsuid /.rapidfort_RtmF/resock --auto -v ${RF_VERBOSE}" 1>&2
      exec /.rapidfort_RtmF/bash-static --norc
    fi
  fi

  ls -l /.rapidfort/run/resock
  ls -l /.rapidfort_RtmF/resock

if [ "${3}" = "scan" ] ; then
  export RF_RESOCK_ARGS=" --prodmon-scan"
else
  export RF_RESOCK_ARGS=" "
fi

if test -s /.rapidfort/run/resock ; then
  exec /.rapidfort/run/resock --auto -v ${RF_VERBOSE} ${RF_RESOCK_ARGS}
else
  exec /.rapidfort_RtmF/resock --auto -v ${RF_VERBOSE} ${RF_RESOCK_ARGS}
fi

echo "SI: ERROR: exec resock failed" 1>&2
exit 1
