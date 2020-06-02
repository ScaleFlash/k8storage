#!/bin/bash

set -xe

## create namespace : k8storage
oc apply -f namespace.yaml
if [[ $? != 0 ]] ;then
	echo "ERROR : namespaces.yaml"
	exit 1
fi

## rbac
oc apply -f rbac-serviceaccount.yaml
if [[ $? != 0 ]] ;then
    echo "ERROR : rbac-serviceaccount.yaml"
    exit 1
fi

oc adm policy add-scc-to-user privileged -n k8storage -z csi-service-account
if [[ $? != 0 ]] ;then
    echo "ERROR : add-scc-to-user"
    exit 1
fi

# deploy csi pod

oc apply -f csi-scaleflash-nodeplugin.yaml
sleep 5
oc apply -f csi-scaleflash-controllerplugin.yaml

