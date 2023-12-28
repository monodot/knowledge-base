---
layout: page
title: Visual Studio Code
---

## Getting started on Fedora

On Fedora:

    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    sudo dnf install code

Then to upgrade:

    dnf check-update
    sudo dnf update code

## Launch configuration examples (`.vscode/launch.json`)

### Node.js: Debug Jest Tests which use Testcontainers and Podman

A very specific use case, but here's a configuration that attaches a debugger to Jest tests written with Testcontainers, where Podman is the local container runtime:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Server: Debug All Tests with Podman",
            "type": "node",
            "request": "launch",
            "cwd": "${workspaceFolder}/myapp",
            "runtimeExecutable": "npm",
            "runtimeArgs": [
                "run",
                "test"
            ],
            "console": "integratedTerminal",
            "internalConsoleOptions": "neverOpen",
            "env": {
                "DOCKER_HOST": "unix:///run/user/1000/podman/podman.sock",
                "TESTCONTAINERS_RYUK_DISABLED": "true"
            }
        }
    ]
}
```
