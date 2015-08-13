#!/bin/sh
# 
# Author: Mohit Suman, 2015
# Elasticsearch cluster node re-balancing script
#
# chkconfig:   2345 80 20
# description: Perform cluster rebalancing and shard allocations when a node goes down due to maintainance, or elasticearch upgrade on the node.
#

prog="elasticsearch"

start() {
    echo "$prog"
    /etc/init.d/$prog start
    echo "Waiting for node to rejoin"
    sleep 2
    echo "Enabling shard allocations"  
    curl -s -XPUT /_cluster/settings -d '{ "transient" : { "cluster.routing.allocation.enable" : "all" } }'
    echo "Waiting for cluster state to be ready to allocate primary shards"
    curl -s -XGET 'http://localhost:9200/_cluster/health?wait_for_status=yellow'
    echo "Cluster state is ready to allocate shards"
}

stop() {
   echo "Disabling shard allocations"
   curl -s -XPUT /_cluster/settings -d '{ "transient" : { "cluster.routing.allocation.enable" : "none" } }'
   echo "Sending shutdown signal to node"
   /etc/init.d/$prog stop
   #curl -s -XPOST /_cluster/nodes/_local/_shutdown
   echo "Restart the $prog service at the node to join"
}

restart() {
    stop
    start
}

status(){
    /etc/init.d/$prog status
}

case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    status)
        $1
	;;
    status)
	$1
	;;
    restart)
	$1
	;;
*)
        echo $"Usage: $0 {start|stop|status|restart}"
        exit 2
esac
exit $?
