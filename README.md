# cado-poc-eks-cluster

This repository contains a script, and instructions to create a simple EKS cluster for testing EKS acquisition in the Cado platform.

A version of this cluster runs as part of our automated testing against each version of the platform.

The cluster is a basic `nginx` webserver cluster, using a smaller node pool size to reduce costs. You can run our [CloudAndContainerCompromiseSimulator](https://github.com/cado-security/CloudAndContainerCompromiseSimulator) inside the cluster to get more interesting results inside the Cado platform.

## Example

If you want to use this script to deploy the `TestCluster` in `us-east-2` in the AWS account: `123456789012`, and I have the `arn:aws:iam::123456789012:role/MyAccountRole` role in the Cado platform. Then you would run the script like so:

`create-cluster.sh --cluster_name TestCluster --region us-east-2 --arn arn:aws:iam::123456789012:role/MyAccountRole`


## Usage
```
create-cluster.sh --cluster_name <cluster_name> --region <region> --arn <arn>

--cluster_name: The name of the cluster to create.
--region: The region to create the cluster in.
--arn: The ARN of the IAM role that will be used to create a link between the cluster and Cado Response. If unsure, use the Cado Response AWS Role.
```


## Requirements

* [eksctl](https://eksctl.io/)
* [awscli](https://aws.amazon.com/cli/)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/)
