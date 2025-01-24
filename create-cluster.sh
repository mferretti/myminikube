#!/bin/bash

## DEFAULTS
NAME="minikube"
CPUS=4
MEMORY=8192
NODES=1

OPTSTRING=":c:m:l:n:h"

while getopts ${OPTSTRING} opt; do
  case ${opt} in
    l)
      echo "Name assigned to cluster: ${OPTARG}"
      NAME=${OPTARG}
      ;;
    c)
      echo "Number of CPUs allocated to cluster: ${OPTARG}"
      CPUS=${OPTARG}
      ;;
    m)
      echo "Memory allocated to cluster: ${OPTARG}"
      MEMORY=${OPTARG}
      ;;
    n)
      echo "Number of nodes allocated: ${OPTARG}"
      NODES=${OPTARG}
      ;;
    h)
      echo "Usage: $0 [-l name] [-c cpus] [-m memory] [-h]"
      echo "Options:"
      echo "  -l: name of the cluster (default: minikube)"
      echo "  -c: number of CPUs to allocate to the cluster (default: 4)"
      echo "  -m: amount of memory to allocate to the cluster (default: 8192)"
      echo "  -n: number of nodes to create in the cluster (default: 1)"
      echo "  -h: display this help message"
      exit 0
      ;;
    :)
      echo "Option -${OPTARG} requires an argument."
      exit 1
      ;;
    ?)
      echo "Ignoring option: -${OPTARG}."
      exit 1
      ;;
  esac
done
echo ""
echo "---------------------------------------------------"
echo "The cluster specs provided are"
echo "Name: $NAME"
echo "CPUs: $CPUS"
echo "Memory: $MEMORY"
echo "Nodes: $NODES"
echo "---------------------------------------------------"

CL_RUNNING=`minikube status -p $NAME | grep -ci "host: running"`

if [ $CL_RUNNING == 0 ]; then
   echo "Cluster $NAME is not running: starting it"
   minikube start -p $NAME --cpus $CPUS --memory $MEMORY --nodes $NODES
else
    echo "Cluster $NAME is already running"
fi

metrics_server=`minikube addons list -p $NAME | grep "enabled" | grep -c "metrics-server"`
ingress=`minikube addons list -p $NAME | grep "enabled" | grep -c "ingress"`
dashboard=`minikube addons list -p $NAME | grep "enabled" | grep -c "yakd"`

if [ $metrics_server == 0 ]; then
    echo "metrics-server not enabled; enabling it"
    minikube addons enable metrics-server -p $NAME
else
    echo "metrics-server already enabled"
fi

if [ $ingress == 0 ]; then
    echo "ingress not enabled; enabling it"
    minikube addons enable ingress -p $NAME
else
    echo "ingress already enabled"
fi

if [ $dashboard == 0 ]; then
    echo "dashboard not enabled; enabling it"
    minikube addons enable yakd -p $NAME
else
    echo "dashboard already enabled"
fi

echo "Your cluster is ready to use; here's some useful information:"
echo "name: $NAME" 
echo "ingress ip: `minikube ip -p $NAME`"
status=`minikube status -p $NAME`
status=`tail -n +2 <<< "$status"`
printf "status:\n$status"
echo ""
echo "---------------------------------------------------"
echo "To access the dashboard, run: minikube dashboard -p $NAME"
echo "To stop the cluster, run: minikube stop -p $NAME"
echo "To delete the cluster, run: minikube delete -p $NAME"
echo "---------------------------------------------------"
