---
layout: page
title: .NET
---

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

