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
