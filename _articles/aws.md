---
layout: page
title: Amazon Web Services (AWS)
---

## Glossary

**Elastic Block Storage (EBS)**
: The default storage you'll get when you create an EC2 instance. An EBS volume resides only in **one** Availability Zone, so it's not suitable for cross-AZ redundancy. It's like a directly-attached drive.

**Elastic File System (EFS)**
: Amazon's equivalent of NFS. It's a shared network volume that is replicated across Availability Zones. It's like a network drive.

**KCL**
: Kinesis Client Library. The developer library used for accessing Kinesis Data Streams.

**Kinesis Data Streams**
: Managed data intake pipeline (like Kafka?). You can scale streams up or down so you don't lose messages, etc.

**Kinesis Data Firehose**
: For delivering streaming data to S3, Redshift, Elasticsearch, Splunk.

## AWS CLI

### Using the awscli Docker image

```
alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli'
export AWS_DEFAULT_PROFILE=myprofile

# Then run any command using 'aws ...'
aws iam get-user
```

### Installation on RHEL

To install AWS CLI on RHEL (using Python 2.x and `pip`):

```
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
export PATH=~/.local/bin:$PATH
source ~/.bash_profile    # optional
pip install awscli --upgrade --user
```

### Installation on MacOS

awscli can be found in Homebrew.

It can be updated like this:

```
brew upgrade awscli
```

## Cookbook

### Tool version

```
aws --version
```

### Get the current user details or STS token

```
$ aws iam get-user
{
    "User": {
        "Path": "/",
        "UserName": "jeffrey",
        "UserId": "AAAAAAAAAAAAAAAAAAAAA",
        "Arn": "arn:aws:iam::123456789000:user/jeffrey",
        "CreateDate": "2019-09-19T13:00:05Z"
    }
}

$ aws sts get-current-identity
{
    "UserId": "123456789000",
    "Account": "123456789000",
    "Arn": "arn:aws:iam::123456789000:root"
}
```

### EC2: Fetching instance info from an EC2 instance

Fetch the instance ID:

```
curl -s http://169.254.169.254/latest/meta-data/instance-id
```

### EKS

#### Start a cluster

```
export AWS_DEFAULT_PROFILE=myprofile
eksctl create cluster
```

#### Listing clusters

```
$ aws eks list-clusters --profile myprofile --region eu-west-1
{
    "clusters": [
        "cillablack"
    ]
}
```

#### Set up kubeconfig to authenticate to an EKS cluster

First install `aws-iam-authenticator`. Then:

```
$ export AWS_DEFAULT_PROFILE=profile-for-this-customer
$ alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli'
$ aws eks update-kubeconfig --name cillablack
# This should add the cluster to kubeconfig and switch the context to it.
```

Troubleshooting:

```
# Check that the config has been added to kubeconfig
$ kubectl config view
# Check that we have a context (an identity/session)
$ kubectl config get-contexts | grep cillablack    
# Get the token from aws-iam-authenticator
$ aws eks get-token --cluster-name cillablack
```

#### Adding Kubernetes Dashboard

```
export DASHBOARD_VERSION="v2.0.0"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml

# Get a token and copy it to the clipboard
aws eks get-token --cluster-name ${CLUSTER_NAME_HERE} | jq -r '.status.token'

# Proxy connections on port 8080 to the cluster
kubectl proxy --port=8080 --address=0.0.0.0 --disable-filter=true &
```

Then access: http://localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

Or this apparently also works according to the docs:

```
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
```

Then access: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login

### SQS: List queues

```
$ aws sqs list-queues --profile xxxx --region xxxxx
{
    "QueueUrls": [
        "https://sqs.eu-west-1.amazonaws.com/xxxxxxxx/keda-test",
        "https://sqs.eu-west-1.amazonaws.com/xxxxxxxx/toms-queue"
    ]
}
```

### SQS: Send a message to a queue

```
aws sqs send-message --queue-url $QUEUE_URL --message-body "Oh hiya!" --profile xxxx --region xxxx
```

## Troubleshooting

_"error: You must be logged in to the server (Unauthorized)"_ when authenticating to EKS:

- If you created the EKS cluster using the AWS web UI, then you **need to use this same user** when accessing the cluster using the CLI.
- Ensure the user you're accessing the cluster as, has been added into the `aws-auth` ConfigMap in the `kube-system` namespace.
- Check your current identity (including ARN) using `aws sts get-caller-identity`

