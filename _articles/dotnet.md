---
layout: page
title: .NET
---

## OpenTelemetry troubleshooting

_Cannot install packages_

- Ensure that "Include Prerelease" is checked in the NuGet Package Manager inside Visual Studio.

_Cannot install packages due to long file names_

- If your project folder is nested too deeply in your filesystem, then you'll hit Windows's "long path name" limit. So, add a file `nuget.config` with the contents below:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <config>
    <add key="repositoryPath" value="C:\Nuget" />
  </config>
</configuration>
```

