#!/bin/bash

# This script creates an EKS cluster with eksctl for PoC purposes, and allows it
# to be acquired in Cado Response. It is not intended for production use.

# This script requires eksctl and kubectl to be installed and configured.

# Get the directory of the repo
REPO="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
REPO=$(dirname "$REPO../")
REPO=$(dirname "$REPO../")

# Handle the following arguments --cluster_name --region --arn
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -c|--cluster_name)
    CLUSTER_NAME="$2"
    shift
    shift
    ;;
    -r|--region)
    REGION="$2"
    shift
    shift
    ;;
    -a|--arn)
    ARN="$2"
    shift
    shift
    ;;
    *)
    echo "Unknown option: $1"
    echo "Usage: create-cluster.sh --cluster_name <cluster_name> --region <region> --arn <arn>"
    echo " --cluster_name: The name of the cluster to create"
    echo " --region: The region to create the cluster in"
    echo " --arn: The ARN of the IAM role that will be used to allow Cado Response to access the cluster"
    exit 1
    ;;
esac
done

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null
then
    echo "eksctl could not be found. Install at https://eksctl.io/"
    exit
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found. Install at https://kubernetes.io/docs/reference/kubectl/"
    exit
fi

# Check if awscli is installed
if ! command -v aws &> /dev/null
then
    echo "awscli could not be found. Install at https://aws.amazon.com/cli/"
    exit
fi

echo "Creating cluster $CLUSTER_NAME in $REGION"
eksctl create cluster --region=$REGION --name=$CLUSTER_NAME --node-volume-size=8

echo "Authenticating with cluster"
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

echo "Creating the namespace for the cluster"
kubectl create namespace cado-poc-cluster

echo "Applying the deployment"
kubectl apply -f $REPO/deployment-manifest.yaml
kubectl apply -f $REPO/service-manifest.yaml

echo "Attempting to create an iamidentitymapping for $ARN, if this goes wrong, make sure the ARN provided is correct"
echo "This is going to use the system:masters group from RBAC. This is not intended for production use and is strictly for PoC purposes"
eksctl create iamidentitymapping --cluster $CLUSTER_NAME --arn $ARN --region $REGION --group system:masters