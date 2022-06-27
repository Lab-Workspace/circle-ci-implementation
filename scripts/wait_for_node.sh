#!/bin/bash
# NODE=$HOSTNAME bash -x wait_for_node.sh

MAX_LOOP=60
loop=1

while [ $loop -le $MAX_LOOP ]
do
    # Test Node's status
    kubectl wait --for=condition=Ready node/$NODE --timeout=1s >/dev/null
    if [ $? -eq 0 ]
    then
        break
    fi

    echo "Node status not ready: $(( $MAX_LOOP - $loop ))"
    loop=$(( $loop + 1 ))
done

kubectl wait --for=condition=Ready node/$NODE --timeout=1s
