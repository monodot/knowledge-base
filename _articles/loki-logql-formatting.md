---
layout: page
title: "Loki: Formatting examples"
lede: "Examples of formatting logs in fun and weird ways in Loki."
---

## Control characters

- `\u001b[1m` - Bold
- `\u001b[0m` - Reset styles

Colours:

- `\u001b[90m` - Grey
- `\u001b[36m` - Cyan

## Using control characters for colours and fonts

```
{job="opentelemetry-demo/cartservice"} | json | line_format "\u001b[1m{{if .severity}}{{alignRight 5 .severity}}{{end}}\u001b[0m \u001b[90m[{{alignRight 10 .resources_service_instance_id}}{{if .attributes_thread_name}}/{{alignRight 20 .attributes_thread_name}}{{end}}]\u001b[0m \u001b[36m{{if .instrumentation_scope_name }}{{alignRight 40 .instrumentation_scope_name}}{{end}}\u001b[0m{{if .traceid}} \u001b[37m\u001b[3m[traceid={{.traceid}}]{{end}}: {{.body}}"
```

Prints (with colours):

```
2023-09-27 09:03:21.050	
ation [          ]  [traceid=a92ac7dff16044217db7b4a650c6a42a]: GetCartAsync called with userId={userId}
```