---
layout: page
title: Spring Boot
---

## Basic bootstrap class

```java
package com.example.myapp;

@SpringBootApplication
public class Application {

    /**
     * A main method to start this application.
     */
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

## Basic Controller class

```java
@Controller
public class WebController {

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(WebController.class);

    
}

```

## Annotations

Spring Boot annotations, and what they mean:

| Annotation          | Use on        | Description               | Use for                   |
| ------------------- | ------------- | ------------------------- | ------------------------- |
| `@Autowired`        | Constructors  | Injects any dependencies into a Constructor | ... |
| `@Bean`             | Methods       | Declares a method that returns a bean. Executes the annotated method and registers the return value as a bean within a BeanFactory. | Equivalent to `<bean...>` in XML configuration. |
| `@Component`        | Classes       | A generic stereotype for any Spring-managed component. | ... |
| `@Controller`       | Classes       | A stereotype for a controller component in the presentation layer |
| `@Repository`       | Classes       | A stereotype for DAO component in the persistence layer | ... |
| `@Service`          | Classes | A service component in the business layer |
| `@SpringBootApplication` | Class | Equivalent to using `@Configuration`, `@EnableAutoConfiguration` and `@ComponentScan` together | ... |


## Testing

Use this runner:

    @RunWith(SpringRunner.class)

(`SpringRunner` is the new name for `SpringJUnit4ClassRunner`)

Or use this runner for Camel:

    @RunWith(CamelSpringBootRunner.class)

### Cookbook

#### Specifying Spring configuration in a test class

```java
@SpringBootTest(classes = { MyApplicationTest.class, MyApplicationTest.TestConfig.class })
public class MyApplicationTest {

    @Configuration
    public static class TestConfig {

        @Bean
        RoutesBuilder route() { ..... }

        @Bean
        MyBean myBean() { ..... }

    }
}
```

#### Mixing XML and Java based configuration in a test class

Create a test class named `MyApplicationTest`:

```java
@RunWith(SpringRunner.class)
@SpringBootTest(
        classes = MyApplicationTest.Config.class)
public class MyApplicationTest {

    @Configuration
    //@ImportResource(value = {"classpath:your-config.xml"})
    static class Config {
        // any further beans can be defined here
        // @Bean ...
    }

}
```

If the class is named `MyApplicationTest`, Spring will look by default for an XML config file in `MyApplicationTest`'s classpath. In practice, this means for Maven projects, that the **maven-resources-plugin** should be configured, and then the test Spring XML config file placed in:

    src/test/resources/com/mycompany/myapp/MyApplicationTest-context.xml

The **maven-resources-plugin** will then copy resources files to `target/test-classes`, so they're visible from the compiled classes. Alternatively, you can use the `@ImportResource` annotation (as commented above) to specify an exact location for the XML file.

**NB:** Don't specify `@ImportResource` if the file is already in the default location, or it will be loaded twice.

## Logging

Logging can be set at a profile level. For example, to set logging when using a profile named `local`, add this to `application-local.properties`:

    logging.level.com.example.myclass = DEBUG

Set logging configuration for a test class like this:

```java
@SpringBootTest(classes = MyApplication.class, properties = {
        "logging.level.com.example.myclass = DEBUG"})
public class MyApplicationTest { ... }
```

### Configuring Logback

`spring-boot-starter` pulls in Logback (`ch.qos.logback:logback-classic`) as a dependency.

A sample `logback.xml` configuration:

```xml
<configuration>

    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <!-- encoders are assigned the type
             ch.qos.logback.classic.encoder.PatternLayoutEncoder by default -->
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="info">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
```

**Logback sets the logging level to _DEBUG_ by default, unless it has been configured with a `logback.xml` on the classpath.**  This behaviour is detailed in the Logback docs:

> Assuming the configuration files logback-test.xml or logback.xml are not present, logback will default to invoking BasicConfigurator which will set up a minimal configuration ... Moreover, by default the root logger is assigned the DEBUG level.

-- https://logback.qos.ch/manual/configuration.html

## Configuration properties cookbook

### Logging

Change the console log format - e.g. include the full thread name:

    logging.pattern.console=%clr(%d{${LOG_DATEFORMAT_PATTERN:-yyyy-MM-dd HH:mm:ss.SSS}}){faint} %t %clr(${LOG_LEVEL_PATTERN:-%5p}) %clr(${PID:-}){magenta} %clr(---){faint} %clr([%15.15t]){faint} %clr(%-40.40logger{39}){cyan} %clr(:){faint} %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%wEx}

Log all SQL statements produced by `JdbcTemplate`:

    logging.level.org.springframework.jdbc.core.JdbcTemplate=DEBUG
    logging.level.org.springframework.jdbc.core.StatementCreatorUtils=TRACE

Log Spring Transaction events:

    logging.level.org.springframework.transaction=DEBUG

## Spring Boot 2.x migration

- The Spring Boot Maven plugin [now **forks** by default][gh-16945] since Spring Boot 2.2 [(Release Notes)][22rn].
  - From the docs: "By default, the Gradle and Maven plugins fork the
application process."
  - This means that command line arguments such as `-Dmy.property=true` will not override application properties, as the Spring Boot app runs in a separate JVM.
  - In Spring Boot 1.x, fork was only enabled "if an agent, jvmArguments or working directory are specified, or if devtools is present."
  - You can disable forking using `spring-boot.run.fork=false`.
  - Or override properties using: `-Drun.arguments=--my.property=foobar,--other.prop=qux`

[gh-16945]: https://github.com/spring-projects/spring-boot/issues/16945
[22rn]: https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.2-Release-Notes#fork-enabled-by-default-in-maven-plugin
