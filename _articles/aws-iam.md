---
layout: page
title: AWS IAM
---

## Example policies

### Policy that grants read access to a bucket all objects

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowReadAccessToBucket",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::my-bucket",
                "arn:aws:s3:::my-bucket/*"
            ]
        }
    ]
}
```

## Troubleshooting

### `awscli` on EC2 instance says "Unable to locate credentials"

If you've attached an IAM role to an EC2 instance but the awscli doesn't seem to be working, verify the Instance Profile has been attached correctly from outside the VM:

```shell
aws ec2 describe-iam-instance-profile-associations --filters Name=instance-id,Values=i-00aaaaaaaaaaa --region us-east-1
{
    "IamInstanceProfileAssociations": [
        {
            "AssociationId": "iip-assoc-03aaaaaaaaaaaaaa",
            "InstanceId": "i-00aaaaaaaaaaaaa",
            "IamInstanceProfile": {
                "Arn": "arn:aws:iam::12345555555555:instance-profile/my-instance-profile-name",
                "Id": "AIRRRRRRRRRRRRRRRRRR"
            },
            "State": "associated"
        }
    ]
}
```

And then from inside the VM:

```shell
$ TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/info
{
  "Code" : "InstanceProfileNotFound",
  "Message" : "Instance Profile with Id AIPA2XXXXXXXXXXXX cannot be found.  Please see documentation at https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot_iam-ec2.html#troubleshoot_iam-ec2_errors-info-doc.",
  "LastUpdated" : "2024-06-20T18:51:35Z"
}
```

This might be caused by the original role being deleted and a new role being created with the same name (perhaps a Terraform re-`apply` situation). If all else fails just destroy and recrate your EC2 instance, Instance Profile, etc.

