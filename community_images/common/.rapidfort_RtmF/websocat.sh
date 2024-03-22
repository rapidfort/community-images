#!/.rapidfort_RtmF/bash-static --norc

export LD_LIBRARY_PATH=/.rapidfort_RtmF
export PATH=/.rapidfort_RtmF:/.rapidfort_RtmF/_tools

export RF_APP_HOST=$1
export WS_SOCK=$2
shift
shift

## just for debugging
echo ${HOSTS} > /.rapidfort_RtmF/rf_app_host.list


trap_term() { 
  echo "websocat.sh caught term, exiting..." 1>&2
  kill -TERM "$child"
  kill -KILL "$child"
  exit 1
}

trap trap_term SIGTERM

while true ; do
  export HOSTS=$((echo ${RF_APP_HOST} ; cat /etc/resolv.conf | grep "^nameserver" | sed "s=^nameserver==g" | awk '{print "dig +short @" $1 " RF_APP_HOST"}' | sed "s=RF_APP_HOST=${RF_APP_HOST}=g" | bash-static | sed "s=;.*==g" | tr -d -c '[:digit:][:space:].') | sort -r | grep .. | uniq)
  echo "websocat.sh : trying hosts: ${HOSTS}" 1>&2
  for HOST in ${HOSTS} ; do
    export WS_HOST=wss://${HOST}:443/rfpubsub
    ls -l ${WS_SOCK} 1>&2
    rm -f ${WS_SOCK}
    echo websocat "$@" --unlink --oneshot unix-listen:${WS_SOCK} ${WS_HOST} 1>&2
    websocat "$@" --unlink --oneshot unix-listen:${WS_SOCK} ${WS_HOST} &
    child=$! 
    wait "$child"
    sleep 2
  done
done
