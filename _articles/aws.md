---
layout: page
title: AWS
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

