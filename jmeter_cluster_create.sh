#!/usr/bin/env bash
#Create multiple Jmeter namespaces on an existing kuberntes cluster
#Started On January 23, 2018

working_dir=`pwd`

echo "checking if kubectl is present"

if ! hash kubectl 2>/dev/null
then
    echo "'kubectl' was not found in PATH"
    echo "Kindly ensure that you can acces an existing kubernetes cluster via kubectl"
    exit
fi

kubectl version --short

tenant="automation"

echo "Creating Namespace: $tenant"

kubectl create namespace $tenant

echo "Namspace $tenant has been created"

echo

echo "Creating Jmeter slave nodes"

nodes=`kubectl get no | egrep -v "master|NAME" | wc -l`

echo

echo "Number of worker nodes on this cluster is " $nodes

echo

#echo "Creating $nodes Jmeter slave replicas and service"

echo

kubectl create -n $tenant -f $working_dir/jmeter_slaves_deploy.yaml

kubectl create -n $tenant -f $working_dir/jmeter_slaves_svc.yaml

echo "Creating Jmeter Master"

kubectl create -n $tenant -f $working_dir/jmeter_master_configmap.yaml

kubectl create -n $tenant -f $working_dir/jmeter_master_deploy.yaml


echo "Creating Jmeter Reporter"

kubectl create -n $tenant -f $working_dir/jmeter_grafana_reporter.yaml


echo "Creating Influxdb and the service"

kubectl create -n $tenant -f $working_dir/jmeter_influxdb_configmap.yaml

kubectl create -n $tenant -f $working_dir/jmeter_influxdb_deploy.yaml

kubectl create -n $tenant -f $working_dir/jmeter_influxdb_svc.yaml

echo

kubectl get -n $tenant all

echo namespace = $tenant > $working_dir/tenant_export
