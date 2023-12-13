# cado-poc-eks-cluster

This repository contains a script, and instructions to create a simple EKS cluster for testing EKS acquisition in the Cado platform.

The cluster is a basic `nginx` webserver cluster, using a smaller node pool size to reduce costs. You can run our [CloudAndContainerCompromiseSimulator](https://github.com/cado-security/CloudAndContainerCompromiseSimulator) inside the cluster to get more interesting results inside the Cado platform.

**This scenario assumes you are deploying a cluster in the same account as your Cado Response deployment for testing purposes.**

## Usage

`create-cluser.sh --cluster_name <cluster_name> --region <region> --arn <arn>`

`--cluster_name: The name of the cluster to create.`

`--region: The region to create the cluster in.`

`--arn: The ARN of the IAM role that will be used to create a link between the cluster and Cado Response. If unsure, use the Cado Response AWS Role.`


## Requirements

* [eksctl](https://eksctl.io/)
* [awscli](https://aws.amazon.com/cli/)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/)
