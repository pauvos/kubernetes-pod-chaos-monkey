#!/bin/bash
# Randomly delete pods in a Kubernetes namespace.
set -ex

: ${DELAY:=30}
: ${NAMESPACE:=default}
: ${FORCE:=false}

if [ "${SELECTOR_MODE}" == "equality-based" ] || [ "${SELECTOR_MODE}" == "set-based" ]; then 
  CMD_SELECTOR="--selector ${SELECTOR}"
else
  CMD_SELECTOR=""
fi

if [ "${FORCE}" == "true" ]; then
  CMD_FORCE="--force --grace-period=0"
else
  CMD_FORCE=""
fi

while true; do
  kubectl \
    --namespace "${NAMESPACE}" \
    -o 'jsonpath={.items[*].metadata.name}' \
    get pods ${CMD_SELECTOR} | \
      tr " " "\n" | \
      shuf | \
      head -n 1 |
      xargs -t --no-run-if-empty \
        kubectl --namespace "${NAMESPACE}" delete pod ${CMD_FORCE}
  sleep "${DELAY}"
done
