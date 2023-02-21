---
layout: page
title: Grafana Agent
---

## Example configs

### Namespace-scoped Role and RoleBinding

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: grafana-agent
  namespace: myapp
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: grafana-agent
  namespace: myapp
rules:
- apiGroups:
  - ""
  resources:
  - services
  - endpoints
  - pods
  - events
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: grafana-agent
  namespace: myapp
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: grafana-agent
subjects:
- kind: ServiceAccount
  name: grafana-agent
  namespace: myapp
```

## Troubleshooting

### Metrics do not appear in Grafana Cloud

- Check that the Agent is running and that the Service/Pod is healthy.
- Check the list of endpoints that the Agent has discovered and is scraping. Port-forward to the Agent and use the HTTP API to list the discovered targets:
    - `kubectl -n <namespace> port-forward grafana-agent-0 8001:80`
    - `curl localhost:8001/agent/api/v1/metrics/targets`
- If the targets list is empty, something is wrong:
    - Make sure that the Agent has permissions to view pods and services in the cluster (e.g. with a RoleBinding)
    - If scraping a single namespace (or just a few), make sure that the Agent is configured to do so:

```yaml
    kubernetes_sd_configs:
        - role: pod
        namespaces:
            names:
            - <NAMESPACE>
```
