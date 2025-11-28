---
layout: page
title: .NET
---

## OpenTelemetry

### Instrumenting the Confluent Kafka client

To enhance an application to add Confluent Kafka instrumentation, we can use the [`OpenTelemetry.Instrumentation.ConfluentKafka`](https://github.com/open-telemetry/opentelemetry-dotnet-contrib/blob/main/src/) package.

Follow instructions below or see a complete example at: <https://github.com/monodot/grafana-playground/tree/main/dotnet-kafka-otel>

1.  Add the package:

    ```sh
    dotnet package add OpenTelemetry.Instrumentation.ConfluentKafka --prerelease
    ```

1.  Update the bootstrapping code:

    ```csharp
    // Create an instrumented consumer - this needs to be done before bootstrapping the OTel tracer provider
    var instrumentedConsumerBuilder = new InstrumentedConsumerBuilder<string, string>(config);
    
    using var tracerProvider = Sdk.CreateTracerProviderBuilder()
        .UseGrafana()
        .AddKafkaConsumerInstrumentation(instrumentedConsumerBuilder)
        .Build();
    ```

1.  Use the instrumented consumer:

    ```csharp
    using (var consumer = instrumentedConsumerBuilder.Build()) { ... }
    ```

### Custom span attributes example

Here's an example of adding custom span attributes, either as constant values, or derived from an incoming HTTP header:

```csharp
using OpenTelemetry.Trace;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace cheese_app.Controllers
{
    public class ValuesController : ApiController
    {
        // GET api/values
        public IEnumerable<string> Get()
        {
            var span = Tracer.CurrentSpan;
            span.SetAttribute("cheese.catalogue.size", 42);
            span.SetAttribute("cheese.catalogue.updated", DateTime.UtcNow.ToString("o"));

            return new string[] { "value1", "value2" };
        }

        // GET api/values/5
        public string Get(int id)
        {
            var span = Tracer.CurrentSpan;
            span.SetAttribute("cheese.store.origin", "FR");
            span.SetAttribute("cheese.strength", 5);
            span.SetAttribute("cheese.tasty", true);

            return "value";
        }

        // POST api/values
        public void Post([FromBody] string value)
        {
            var span = Tracer.CurrentSpan;

            IEnumerable<string> headerValues;
            if (Request.Headers.TryGetValues("X-Store-ID", out headerValues))
            {
                var headerValue = headerValues.FirstOrDefault();
                if (!string.IsNullOrEmpty(headerValue))
                {
                    span.SetAttribute("cheese.store.id", headerValue);
                }
            }
        }

    }
}
```

### Troubleshooting OpenTelemetry in .NET

#### Enabling OpenTelemetry debug logs (zero-code instrumentation only)

_Environment variable: OTEL_LOG_LEVEL=debug_

By setting the optional env var `OTEL_LOG_LEVEL`, you'll see some useful debug logs in `C:\Windows\Temp`. [See example logs](./logs-windows-sample.log)

#### Enabling OpenTelemetry diagnostic logs

_Create an OTEL_DIAGNOSTICS.json file in your working directory_

To enable diagnostic logs ([see documentation](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/src/OpenTelemetry/README.md#self-diagnostics)), open a shell in the container and create the file `OTEL_DIAGNOSTICS.json`:

```powershell
$jsonContent = @"
{
    "LogDirectory": "C:\Windows\Temp",
    "FileSize": 1024,
    "LogLevel": "Informational",
    "FormatMessage": "true"
}
"@

Set-Content -Path "C:\Windows\System32\inetsrv\OTEL_DIAGNOSTICS.json" -Value $jsonContent
```

The allowed values for LogLevel are Critical, Error, Warning, Informational, Verbose.

After a few seconds, you should see a file in `C:\Windows\Temp` like `w3wp.exe.1328.log`. This example should create a 1MB log file.

**If the file doesn't exist,** send a request to your app's API (e.g. with curl or via web browser) which should "wake up" the `w3wp` process. Then it should notice the OTEL_DIAGNOSTICS.json file, and you should see the log file be created in `C:\Windows\Temp`.

Type the log:

```
type w3wp.exe.1744.log | more
```

Example logs - these logs show that the exporter failed to connect to a non-existent collector on localhost:4318:

```
If you are seeing this message, it means that the OpenTelemetry SDK has successfully created the log file used to write self-diagnostic logs. This file will be appended with logs as they appear. If you do not see any logs following this line, it means no logs of the configured LogLevel is occurring. You may change the LogLevel to show lower log levels, so that logs of lower severities will be shown.
2025-11-18T19:31:56.5040232Z:Exporter failed send data to collector to http://localhost:4318/v1/traces endpoint. Data will not be sent. Exception: System.Net.Http.HttpRequestException: An error occurred while sending the request. ---> System.Net.WebException: Unable to connect to the remote server ---> System.Net.Sockets.SocketException: No connection could be made because the target machine actively refused it 127.0.0.1:4318
   at System.Net.Sockets.Socket.InternalEndConnect(IAsyncResult asyncResult)
   at System.Net.Sockets.Socket.EndConnect(IAsyncResult asyncResult)
   at System.Net.ServicePoint.ConnectSocketInternal(Boolean connectFailure, Socket s4, Socket s6, Socket& socket, IPAddress& address, ConnectSocketState state, IAsyncResult asyncResult, Exception& exception)
   --- End of inner exception stack trace ---
   at System.Net.HttpWebRequest.EndGetRequestStream(IAsyncResult asyncResult, TransportContext& context)
   at System.Net.Http.HttpClientHandler.GetRequestStreamCallback(IAsyncResult ar)
   --- End of inner exception stack trace ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at OpenTelemetry.Exporter.OpenTelemetryProtocol.Implementation.ExportClient.OtlpExportClient.SendHttpRequest(HttpRequestMessage request, CancellationToken cancellationToken)
   at OpenTelemetry.Exporter.OpenTelemetryProtocol.Implementation.ExportClient.OtlpHttpExportClient.SendExportRequest(Byte[] buffer, Int32 contentLength, DateTime deadlineUtc, CancellationToken cancellationToken)
2025-11-18T19:32:03.5272472Z:Exporter failed send data to collector to http://localhost:4318/v1/traces endpoint. Data will not be sent. Exception: System.Net.Http.HttpRequestException: An error occurred while sending the request. ---> System.Net.WebException: Unable to connect to the remote server ---> System.Net.Sockets.SocketException: No connection could be made because the target machine actively refused it 127.0.0.1:4318
   at System.Net.Sockets.Socket.InternalEndConnect(IAsyncResult asyncResult)
   at System.Net.Sockets.Socket.EndConnect(IAsyncResult asyncResult)
   at System.Net.ServicePoint.ConnectSocketInternal(Boolean connectFailure, Socket s4, Socket s6, Socket& socket, IPAddress& address, ConnectSocketState state, IAsyncResult asyncResult, Exception& exception)
   --- End of inner exception stack trace ---
   at System.Net.HttpWebRequest.EndGetRequestStream(IAsyncResult asyncResult, TransportContext& context)
   at System.Net.Http.HttpClientHandler.GetRequestStreamCallback(IAsyncResult ar)
   --- End of inner exception stack trace ---
   at System.Runtime.ExceptionServices.ExceptionDispatchInfo.Throw()
   at System.Runtime.CompilerServices.TaskAwaiter.HandleNonSuccessAndDebuggerNotification(Task task)
   at OpenTelemetry.Exporter.OpenTelemetryProtocol.Implementation.ExportClient.OtlpExportClient.SendHttpRequest(HttpRequestMessage request, CancellationToken cancellationToken)
   at OpenTelemetry.Exporter.OpenTelemetryProtocol.Implementation.ExportClient.OtlpHttpExportClient.SendExportRequest(Byte[] buffer, Int32 contentLength, DateTime deadlineUtc, CancellationToken cancellationToken)
```

#### No instrumentation happening at all?

Check that the OpenTelemetry DLL is even being loaded by your process:

```
Get-Process w3wp | Select-Object -ExpandProperty Modules
```

You should see the library in the list:

```
1304 OpenTelemetry.AutoInstrumentation.Native.dll       C:\Program Files\OpenTelemetry .NET...
```

#### Look for log files in a Windows container (.NET Framework)

If this is a Windows container, and you're not sure where log files are being written to, try looking for the log files using this Powershell command:

```powershell
Get-ChildItem -Path \ -Recurse -Filter *.log -ErrorAction SilentlyContinue
```

#### Cannot install packages (.NET Framework)

Ensure that "Include Prerelease" is checked in the NuGet Package Manager inside Visual Studio.

At the time of writing this, some of the underlying OpenTelemetry packages are pre-release versions ("beta", "rc") and pre-release needs to be explicitly allowed.

#### Cannot install packages, due to long file names

If your project folder is nested too deeply in your filesystem, then you'll hit Windows's "long path name" limit. So, add a file `nuget.config` with the contents below:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <config>
    <add key="repositoryPath" value="C:\Nuget" />
  </config>
</configuration>
```

