#!/bin/bash
#
STATUS=$(minikube status | grep host | awk '{split($0,a," "); print a[2]}')
if [ "$STATUS" = "Stopped" ]; then
	echo "minikube is not running";
	exit 0;
fi
echo "minikube is running" 
INGRESS=$(minikube addons list | grep "ingress-dns")
if ! echo "$OUTPUT" | grep -q "enabled"; then 
	minikube addons disable ingress-dns
fi

