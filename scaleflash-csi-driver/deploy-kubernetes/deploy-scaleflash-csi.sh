#!/bin/bash

set -xe

## create namespace : k8storage
kubectl apply -f namespace.yaml
if [[ $? != 0 ]] ;then
	echo "ERROR : namespaces.yaml"
	exit 1
fi

## rbac
kubectl apply -f rbac-serviceaccount.yaml
if [[ $? != 0 ]] ;then
    echo "ERROR : rbac-serviceaccount.yaml"
    exit 1
fi

# deploy csi pod

kubectl apply -f csi-scaleflash-nodeplugin.yaml
sleep 5
kubectl apply -f csi-scaleflash-controllerplugin.yaml

