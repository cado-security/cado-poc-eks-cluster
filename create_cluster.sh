#!/bin/bash

# This script creates an EKS cluster with eksctl for PoC purposes, and allows it
# to be acquired in Cado Response. It is not intended for production use.

# This script requires eksctl and kubectl to be installed and configured.

set -e

# Get the directory of the repo
REPO="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function print_usage() {
    echo "Usage: create-cluster.sh --cluster_name <cluster_name> --region <region> --arn <arn>"
    echo " --cluster_name: The name of the cluster to create."
    echo " --region: The region to create the cluster in."
    echo " --arn: The ARN of the IAM role that will be used to create a link between the cluster and Cado Response. If unsure, use the Cado Response AWS Role."
}

function check_dependency() {
    if ! command -v "$1" &> /dev/null
    then
        echo "$1 could not be found. Install at $2."
        exit
    fi
}

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
    print_usage
    exit 1
    ;;
esac
done

check_dependency eksctl "https://eksctl.io/"
check_dependency aws "https://aws.amazon.com/cli/"
check_dependency kubectl "https://kubernetes.io/docs/reference/kubectl/"

# Check if .aws/credentials exists
if [ ! -f ~/.aws/credentials ]; then
    echo "AWS credentials not found. Please run aws configure and use credentials for the account you want to deploy the cluster in."
    exit 1
fi

echo "Creating cluster $CLUSTER_NAME in $REGION. This may take a while..."
eksctl create cluster --region="$REGION" --name="$CLUSTER_NAME" --node-volume-size=64

echo "Authenticating with cluster..."
aws eks --region "$REGION" update-kubeconfig --name "$CLUSTER_NAME"

echo "Creating the namespace for the cluster..."
kubectl create namespace cado-poc-cluster

echo "Applying the deployment..."
kubectl apply -f "$REPO"/deployment-manifest.yml
kubectl apply -f "$REPO"/service-manifest.yml

echo "Applying RBAC roles..."
kubectl auth reconcile -f "$REPO"/cado-eks-cluster-role.yml
kubectl auth reconcile -f "$REPO"/cado-eks-cluster-role-binding.yml

echo "Attempting to create an iamidentitymapping for $ARN, if this goes wrong, make sure the ARN provided is correct."
echo "This is going to use the system:masters group from RBAC. This is not intended for production use and is strictly for PoC purposes."
eksctl create iamidentitymapping --cluster "$CLUSTER_NAME" --arn "$ARN" --region "$REGION" --group cado
