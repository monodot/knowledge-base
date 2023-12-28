---
layout: page
title: GitHub
---


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
