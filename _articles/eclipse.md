---
layout: page
title: Eclipse
---

`Do you want to exit the Eclipse?`

## Useful locations/paths

- **Configuration:**
  - JBDS/CodeReady configuration is stored in `$ECLIPSE_HOME/studio/configuration`
    - See `config.ini`
  - Also, workspace configuration is stored in `$WORKSPACE/.metadata/.plugins`
- **Logs:**
  - JBDS/CodeReady writes some logs to `$ECLIPSE_HOME/studio/configuration/nnnnnnnn.log`
  - Also, workspace logs are written to `$WORKSPACE/.metadata/log`.

## Maven integration

Eclipse uses _m2eclipse_ for its Maven integration features:

- Eclipse **ALWAYS** uses its own, embedded Maven for dependency resolution; so ensure that Eclipse points to a valid `settings.xml`.
- To execute a Maven goal, create a new _Run Configuration_ (menu: Run &rarr; Run Configurations). You can also **select which Maven runtime to use**.
- **Update Maven Project** menu item: not entirely certain what this does. But it [probably][updateproject] refreshes the project from the file system, checks for new dependencies in the POM, refreshes plugins/lifecycle mappings, and builds the project.

## Tuning

Disable auto-updates:

- Go to Preferences &rarr; Install/Update &rarr; Automatic Updates &rarr; then **uncheck** _Automatically find new updates and notify me_
- Perhaps also disable any additional update sites, in Install/Update &rarr; Available Software Sites, by selecting them and clicking the Disable button.

## Troubleshooting (the Eclipse)

### Eclipse general

**_Project > Clean_ doesn't seem to do anything**

Clean does actually do stuff, but it won't actually delete the `target` directory, so the timestamp on the directory will remain the same. It just seems to delete/overwrite existing files inside `target`.

**Exception in thread "main" java.lang.UnsupportedClassVersionError: com/example/myproject/MainApp has been compiled by a more recent version of the Java Runtime**

This is usually caused by the version of Eclipse's internal Java compiler being newer than the default JRE on the classpath. Go to Project Properties &rarr; Java Compiler and ensure that _Use compliance from execution environment_ is ticked.

**Resource is out of sync with the file system**

You need to refresh the project to see changes. Hit F5 on the project, or right-click and choose _Refresh_.

If automatic refresh is enabled (Preferences > General > Workspace > enable _Refresh using native hooks or polling_ ), then you might just need to wait for Eclipse to pick up the change. Open and close some files. Maybe it might work, maybe it won't.

### Proxies

**System property http.proxyHost is not set but should be my-proxy.com** \
**System property http.proxyHost is set to 10.1.1.3 but should not be set**

Not sure about this one. TBC.

### JBoss Developer Studio

**Camel route XML files don't open in the Camel editor**

Right-click the file, choose Open With > Fuse Tooling Route Editor.

**Camel component palette seems to be hidden/missing**

Window > Show View > Palette.

#### JBDS notes

JBoss Developer Studio/CodeReady Workspaces repos:

- A pre-configured `org.eclipse.equinox.p2.repository` (or `org.eclipse.equinox.internal.p2.metadata.repository.CompositeMetadataRepository`, to be precise) is included in the distribution, named _"Red Hat Developer Studio - Core + Central Update Site"_. This points to _devstudio.redhat.com_ for downloading updates.
- This is located in `$STUDIO_HOME/studio/p2/org.eclipse.equinox.p2.repository/cache`

Fuse Tooling:

- This functionality is provided by plugins beginning with the prefix `org.fusesource.ide`, e.g. `org.fusesource.ide.camel.model.service.impl`
- Camel Catalog
  - Functionality is configured using the plugin `org.fusesource.ide.camel.model.service.impl.VERSION`, which defines an `extension point=".."` and the implementing class (`org.fusesource.ide.camel.model.service.impl.VERSION.CamelCatalogWrapper`)
  - The actual catalog is loaded using the class `CamelCatalogUtils`
- Enable debug logs by setting this logging property: `org.fusesource.ide.camel.model.service.core/debug=true`

[updateproject]: https://stackoverflow.com/questions/42554213/what-exactly-does-maven-update-project-do-in-eclipse/42562054#
