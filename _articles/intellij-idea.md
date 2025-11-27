---
layout: page
title: IntelliJ IDEA
---

## Installation and upgrade

To install:
```
curl -o intellij-idea.tar.gz -L https://download.jetbrains.com/idea/ideaIC-2020.1.tar.gz
mkdir -p /opt/idea
tar -C /opt/idea -xvf intellij-idea.tar.gz
```

### Adding to GNOME Applications menu

An example entry for the GNOME Applications menu - note the reference to the startup script, `idea.sh`:
```
$ cat ~/.local/share/applications/jetbrains-idea-ce.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Community Edition
Icon=/opt/idea/idea-IC-201.6668.121/bin/idea.png
Exec="/opt/idea/idea-IC-201.6668.121/bin/idea.sh" %f
Comment=Capable and Ergonomic IDE for JVM
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea-ce
```

### Adding a symlink

To add a symlink (so you can easily start IntelliJ from the terminal on Linux):
```
$ sudo ln -s $IDEA_HOME/bin/idea.sh /usr/local/bin/idea

# Then you can run using:
# cd myproject && nohup idea . &
```

## Logs

To view log files, go to _Help - Show Log in Files_ (or Finder, depending on platform)

- e.g. on Linux, my log files are in `~/.cache/JetBrains/IdeaIC...`

## Nice keyboard shortcuts

- **Select In:** Alt+Shift+1\. To quickly select the current element in any view (Project view, Maven view, etc.)
- **Quick Documentation:** Ctrl+Q. To view documentation for whatever object (class, type, etc.) currently at the caret.

## IntelliJ project files

Removing all IntelliJ project files:
```
find . -name '.idea' -exec rm -r "{}" \;
find . -name '*.iml' -type f -delete
```

## Working with version control systems

### Resolving conflicts

Useful process for larger projects:

1. Open the Version Control window using View > Tool Windows > Version Control.
2. Click Local Changes to show local changes (which will include conflicts)
3. Click the gear icon and Group By either Directory or Module (makes it easier to just work on merge conflicts in a specific directory or module)

## Debugging

### Debugging unit tests using IntelliJ

1. Create a new Run Configuration in IntelliJ.
2. Set the command line property to your test Maven goal name, e.g. `test`
3. On the Runner tab, set VM Options to: `-DforkMode=never`
4. Set any breakpoints in your code
5. Now Debug your Run Configuration, e.g. Ctrl+D, or Run → Debug 'my-app [test]'.

### Debugging an external application

1. Choose Run → Edit Configurations.
2. Add a new Configuration of type **Remote**. Name it **debugging**.
3. Copy the command line arguments for running remote JVM (e.g. `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005`)
4. (Optional) Modify `suspend=y` to make the Java application wait until the debugger is connected before starting.
5. (Optional) Set the debug flags in the environment variable `JAVA_OPTS`.
6. In a Terminal, start the application to be debugged.
7. In IntelliJ, start the remote debugger (Run → Debug → **debugging**).

For example:
```
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 -jar target/spring-boot-camel-xa-1.0-SNAPSHOT.jar
```

### Debugging a Maven execution

1.  Create a Run Configuration type "Remove JVM Debug", setting the debugger's mode as "Attach to remote JVM", with listen port of 8000.

2.  Click OK.

3.  In a terminal, run Maven using `mvnDebug goal1 goal2`

4.  Maven will wait on port 8000 for a debugger to be connected.

5.  In IntelliJ, go to Run &rarr; Debug... and then select the debugger Run Configuration you just created.


### Debugging for specific tools/frameworks

#### Spring Boot 2.x

Since Spring Boot Maven Plugin now forks the Java process since version 2.2, **debugging breakpoints won't stop/work when running the application using the `spring-boot:run` goal**.

Instead, run the application using the bootstrap class: find the `@SpringBootApplication` class and just run it from the IDE (green Play button).

#### Thorntail Maven Plugin

Set the property `thorntail.debug.port` which causes Thorntail Maven Plugin to suspend on start and open a debugger on this port (when using `run` or `start` goals), e.g.:
```
$ mvn thorntail:run -Dthorntail.debug.port=8000
```

## Troubleshooting

### IntelliJ tries to build the entire project before running a single test

1. Run → Edit Configurations
2. Navigate to JUnit → Your project, and then remove _Make_ from the list of 'before launch' tasks.

### Cannot resolve classes/objects/dependencies (lots of squiggly red underlines everywhere)

- Open the IntelliJ logs (see location above) and look for any Maven errors - logger name will be something like `#org.jetbrains.idea.maven`:
  - e.g. Maven failed to find an artifact, but cached this failure and won't try again: _"java.lang.RuntimeException: org.eclipse.aether.transfer.ArtifactTransferException: Failure to transfer org.springframework.boot:spring-boot-starter-parent:pom:2.4.1 **was cached in the local repository**"_
- Check that the project has been added as a Maven project (right-click the pom.xml → Add as Maven Project)
- Ensure that IntelliJ is using the correct Maven binary - go to Settings → Maven, and check the path to the Maven installation location, and `settings.xml`.
- Check that artifacts can be resolved correctly. Drop to a Terminal and, using the same Maven binary configured in IntelliJ, try `mvn -U help:effective-pom`. If artifacts can't be resolved here, then fix this first.
- If you're pulling artifacts from a Nexus repository, check that it's able to pull artifacts from the web. Log in to Nexus and check the status of your proxy repositories.
- Check that `maven-compiler-plugin` is configured correctly (e.g. with a version number)
- Project wasn't imported correctly the first time round => Run the action _Reimport All Maven Projects_ (either from the Maven "tool window" or from the Actions popup (Ctrl+Shift+A))
- Dependencies weren't imported, and Maven cached the failure and refuses to try again => Go to Settings - Maven and make sure "Always update snapshots" is **ticked** (despite the label saying 'snpashots' on the checkbox, this actually seemed to fix an issue when Maven refused to re-attempt to download a missing dependency.)

### Package names aren't resolving (classes can't see other classes, etc.)

- Check that the `main` and `test` folders have been added as Sources
- Right-click the `src/main/java` folder, right-click → Mark Directory as → Sources Root
- Right-click the `src/test/java` folder, right-click → Mark Directory as → Test Sources Root

### XML Schema URLs are appearing in red in the XML editor

- IntelliJ doesn't know how to resolve the XML schema definition (XSD)
- If one of your Maven dependencies contains the XSD file already inside the JAR, then IntelliJ will use that.
- The red error highlighting indicates you either need to add a Maven dependency which contains the missing XSD, or you need to download the resource manually.
- Ctrl+hover over an XSD which **is** valid, and you'll see the path that IntelliJ has resolved to the XSD file (e.g. if it's been resolved from a Maven dependency, it's a `$HOME/.m2/repository` path)
- Hover around the red text and wait for the **Intention** (light-bulb icon) and choose the command _Fetch external resource_
- See also: _Map External Resource_ feature - which allows you to map a URI to a file inside a JAR manually.
- See also: _Settings -> Resources_ where you can map URIs to physical files on disk manually.

### External Libraries list is empty, but you expect there to be entries of dependencies, etc.

- Could be something to do with path setups. Check Sources, Paths, Dependencies (Project Settings &rarr; Modules)
- Try deleting the IntelliJ project and opening the project again.

### Issues with building and running under different JDK versions

- Check _Settings &rarr; Build Execution Deployment &rarr; Compiler &rarr; Java Compiler_. Check that strange JDK version-specific settings haven't ended up in here.

### Cannot load a Go project in a subfolder

Ensure that Go Modules are enabled:

- Settings -> Languages & Frameworks -> Go -> Go Modules. Ensure **Enable Go modules integration** is checked.
