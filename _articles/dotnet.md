---
layout: page
title: .NET
---

## Zero-code OpenTelemetry in .NET

### Enabling OpenTelemetry debug logs

_Environment variable: OTEL_LOG_LEVEL=debug_

By setting the optional env var `OTEL_LOG_LEVEL`, you'll see some useful debug logs in `C:\Windows\Temp`. [See example logs](./logs-windows-sample.log)

### Enabling OpenTelemetry diagnostic logs

_Create an OTEL_DIAGNOSTICS.json file in your working directory_

To enable diagnostic logs ([see documentation](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/src/OpenTelemetry/README.md#self-diagnostics)), open a shell in the container and create the file `OTEL_DIAGNOSTICS.json`:

```powershell
$jsonContent = @"
{
    "LogDirectory": "C:\Windows\Temp",
    "FileSize": 32768,
    "LogLevel": "Warning",
    "FormatMessage": "true"
}
"@

Set-Content -Path "C:\Windows\System32\inetsrv\OTEL_DIAGNOSTICS.json" -Value $jsonContent
```

After a few seconds you should see a file in `C:\Windows\Temp` like `w3wp.exe.1328.log`. It writes lines like this:

```
If you are seeing this message, it means that the OpenTelemetry SDK has successfully created the log file used to write
self-diagnostic logs. This file will be appended with logs as they appear. If you do not see any logs following this lin
e, it means no logs of the configured LogLevel is occurring. You may change the LogLevel to show lower log levels, so th
at logs of lower severities will be shown.
2025-11-13T18:46:15.0492550Z:Failed to inject activity context in format: '{0}', context: '{1}'.{TraceContextPropagator}
{Invalid context}
2025-11-13T18:47:15.0425619Z:Failed to inject activity context in format: '{0}', context: '{1}'.{TraceContextPropagator}
{Invalid context}
```

### No instrumentation happening at all?

Check that the OpenTelemetry DLL is even being loaded by your process:

```
Get-Process w3wp | Select-Object -ExpandProperty Modules
```

You should see the library in the list:

```
1304 OpenTelemetry.AutoInstrumentation.Native.dll       C:\Program Files\OpenTelemetry .NET...
```

## OpenTelemetry troubleshooting

### Cannot install packages (.NET Framework)

Ensure that "Include Prerelease" is checked in the NuGet Package Manager inside Visual Studio.

At the time of writing this, some of the underlying OpenTelemetry packages are pre-release versions ("beta", "rc") and pre-release needs to be explicitly allowed.

### Cannot install packages, due to long file names

If your project folder is nested too deeply in your filesystem, then you'll hit Windows's "long path name" limit. So, add a file `nuget.config` with the contents below:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <config>
    <add key="repositoryPath" value="C:\Nuget" />
  </config>
</configuration>
```

