#!/bin/bash

set -eu

KEY=testkey

for host in $(terraform output instance_ips | cut -f 1 -d ','); do
    echo "### Processing host $host"
    ssh -q -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -i $KEY ubuntu@$host source /tmp/enable_kubectl.sh
done
