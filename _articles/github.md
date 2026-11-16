---
layout: page
title: GitHub
---


## CLI

### Download and install a release (neat!)

```sh
# Download to a location then chmod and check version
gh release download v0.42.0 --repo gruntwork-io/cloud-nuke \
  --pattern 'cloud-nuke_linux_amd64' \
  --output ~/bin/cloud-nuke

chmod +x ~/bin/cloud-nuke
cloud-nuke --version
```

Verify a checksum:

```sh
gh release download v0.42.0 --repo gruntwork-io/cloud-nuke \
  --pattern 'cloud-nuke_linux_amd64' --pattern 'SHA256SUMS'
grep cloud-nuke_linux_amd64 SHA256SUMS | sha256sum -c -
```

Download, extract and copy a tar.gz:

```sh
gh release download --repo trufflesecurity/trufflehog --pattern '*linux_amd64*.tar.gz' --dir /tmp 

tar -xzf /tmp/trufflehog_*_linux_amd64.tar.gz -C /tmp

sudo mv /tmp/trufflehog /usr/local/bin/trufflehog
```

## API

### GraphQL: Get issues assigned to a user and their Project (V2) details (sprint, status)

I haven't found a way to filter this list, so it includes all issues assigned to a user. In a client, you could implement filtering to remove items which aren't linked to a Project, or which aren't in this current Sprint iteration.

```graphql
query UserIssuesWithProjectInfo($login: String!, $since: DateTime!) {
  user(login: $login) {
    issues(first: 50, filterBy: {assignee: $login, states: [OPEN], since: $since}) {
      pageInfo {
        hasNextPage
        endCursor
      }
      nodes {
        title
        state
        repository {
          id
          nameWithOwner
        }
        projects: projectItems(first: 5) {
          nodes {
            status: fieldValueByName(name: "Status") {
              ... on ProjectV2ItemFieldSingleSelectValue {
                value: name
                optionId
              }
            }
            sprint: fieldValueByName(name: "Sprint") {
              ... on ProjectV2ItemFieldIterationValue {
                title
                duration
              }
            }
            project {
              id
              title
            }
          }
        }
      }
    }
  }
}
```
