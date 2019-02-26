#!/bin/bash

#set -eu
set -u

KEY=testkey

ERRORS=0

INST=1
for host in $(terraform output instance_ips | cut -f 1 -d ','); do
    NAME="training-$INST\$"
    echo "### Testing host $host (expected name reqex $NAME)"
    HNAME=$(ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -i $KEY ubuntu@$host hostname | grep -E -q $NAME)
    if [ $? -ne 0 ]; then
        echo "*** ERROR - did not get expected name from host $host"
	let ERRORS=ERRORS+1 
    fi
    let INST=INST+1
done

echo "-----------------------------------"
if [ $ERRORS -eq 0 ]; then
    echo "Success - no errors detected"
else
    echo "*** Failed - $ERRORS error(s) found"
fi
echo "-----------------------------------"
