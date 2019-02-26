#!/bin/bash

set -eu

KEY=testkey

echo "##########################################"
echo "## Testing kubectl on all bastion hosts ##"
echo "##########################################"
for host in $(terraform output instance_ips | cut -f 1 -d ','); do
    echo "### Testing kubectl on host $host"
    ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -i $KEY ubuntu@$host kubectl version
    ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -i $KEY ubuntu@$host kubectl get componentstatuses
done

echo "-----------------------------------"
echo "Success - all hosts responded"
echo "-----------------------------------"
