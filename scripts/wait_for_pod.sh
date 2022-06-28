#!/bin/bash
# POD=go-server bash -x wait_for_pod.sh

MAX_LOOP=60
loop=1
POD=$(kubectl get pod | grep $POD | cut -d' ' -f1)

while [ $loop -le $MAX_LOOP ]
do
    # Test Pod's status
    kubectl wait --for=condition=Ready pod/$POD --timeout=1s >/dev/null
    if [ $? -eq 0 ]
    then
        break
    fi

    echo "$POD status not ready: $(( $MAX_LOOP - $loop ))"
    loop=$(( $loop + 1 ))
done

kubectl wait --for=condition=Ready pod/$POD --timeout=1s
