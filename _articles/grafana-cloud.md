---
layout: page
title: Grafana Cloud
---

## Grafana Agent

The agent has a configuration file in `/etc/grafana-agent.yaml`.

Check the status of the monitoring agent:

    systemctl status grafana-agent

Look at the logs from the agent:

    journalctl -u grafana-agent

