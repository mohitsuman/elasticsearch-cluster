#!/bin/sh
# 
# Author: Mohit Suman, 2015
# elasticsearch cluster node re-balancing script
#
# chkconfig:   2345 80 20
# description: Starts and stops a single elasticsearch instance on this system
#

CLUSTER="http://10.3.8.247:9200"
start() {
    sudo systemctl restart elasticsearch
    echo "waiting for node to rejoin"
    sleep 2
    echo "enabling allocations"
    curl -s -XPUT /_cluster/settings -d '{ "transient" : { "cluster.routing.allocation.enable" : "all" } }'
    echo "waiting for cluster state:green"
    while [[ "green" != $(curl -s "${CLUSTER}/_cat/health?h=status" | tr -d '[:space:]') ]] ; do
      sleep 8
    done

}

stop() {
   echo "disabling allocations"
   curl -s -XPUT /_cluster/settings -d '{ "transient" : { "cluster.routing.allocation.enable" : "none" } }'
   echo "Sending shutdown to node"
   sudo systemctl stop elasticsearch
#curl -s -XPOST /_cluster/nodes/_local/_shutdown
   echo "Restart the service for the node to join"
}

case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
*)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 2
esac
exit $
