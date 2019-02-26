#!/bin/bash

#set -eu
set -u

KEY=testkey

ERRORS=0

echo "#################################################"
echo "## Test running container on all bastion hosts ##"
echo "#################################################"
for host in $(terraform output instance_ips | cut -f 1 -d ','); do
    echo "### Testing docker on host $host"
    ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -i $KEY ubuntu@$host docker container run -p 8080:80 -d --rm --name testing123 nginx >/dev/null
    curl -s $host:8080 | grep -q 'Welcome to nginx!'
    if [ $? -eq 0 ]; then
        echo "Got expected result from Nginx on host $host"
    else
        echo "*** ERROR - did not get expected result from Nginx on host $host"
	let ERRORS=ERRORS+1 
    fi
    ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -i $KEY ubuntu@$host docker container stop testing123 >/dev/null
done

echo "-----------------------------------"
if [ $ERRORS -eq 0 ]; then
    echo "Success - no errors detected"
else
    echo "*** Failed - $ERRORS error(s) found"
fi
echo "-----------------------------------"
