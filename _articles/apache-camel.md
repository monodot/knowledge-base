---
layout: page
title: Apache Camel
lede: "Apache Camel is an integration framework for Java. It allows you to exchange data with applications, in tons of different formats and protocols."
---

As well as being a rather spiffing framework, using Apache Camel is also a wonderful way to honour the humble and ancient camel. Here's a camel for you to say thanks for visiting this page: 🐪

## Component versions

Camel version | Spring Boot version | CXF version |
:------------ | :------------------ | :---------- |
Camel 2.21.0  | Spring Boot 1.5.10  | |
Camel 2.22.0  | Spring Boot 2.0.3   | |
Camel 2.23.0  | Spring Boot 2.1.0   | |
Camel 2.24.0  | Spring Boot 2.1.4   | |
Camel 2.25.1  | Spring Boot 2.1.4   | |
Camel 3.0.0   | Spring Boot 2.2.1   | |
Camel 3.1.0   | Spring Boot 2.2.4   | |
Camel 3.2.0   | Spring Boot 2.2.6   | |
Camel 3.3.0   | Spring Boot 2.2.7   | |
Camel 3.4.2   | Spring Boot 2.3.1   | CXF 3.3.6   |

## Quickstarts

### New Camel on Spring Boot project (Java DSL)

Create a new Camel on Spring Boot project from the Maven archetype:

- Upstream (not Red Hat Fuse)
- Camel Java DSL
- Uses `camel-spring-boot-dependencies` and `spring-boot-dependencies` BOMs

```
CAMEL_VERSION=3.2.0
PROJECT_NAME=myproject1
mvn -DgroupId=xyz.tomd.cameldemos \
    -DartifactId=${PROJECT_NAME} -Dversion=1.0-SNAPSHOT \
    -DarchetypeGroupId=org.apache.camel.archetypes \
    -DarchetypeArtifactId=camel-archetype-spring-boot \
    -DarchetypeVersion=${CAMEL_VERSION} \
    org.apache.maven.plugins:maven-archetype-plugin:RELEASE:generate
```

(Optional) Add an XML configuration file for XML DSL based routes:

```
mkdir -p src/test/resources/spring

curl -o src/test/resources/spring/camel-context.xml -L https://raw.githubusercontent.com/fabric8-quickstarts/spring-boot-camel-xml/spring-boot-camel-xml-7.5.0.fuse-sb2-750001/src/main/resources/spring/camel-context.xml

# Remove any Java DSL _Router_ classes
# Add an `@ImportResource()` to the application bootstrap class.
```

### New Camel on Spring project (XML DSL)

Create a new Camel on Spring project from the Maven archetype:

- Upstream (not Red Hat Fuse)
- Camel XML DSL
- Run it using `mvn camel:run`

```
CAMEL_VERSION=3.2.0
PROJECT_NAME=myproject1
mvn -DgroupId=xyz.tomd.cameldemos \
    -DartifactId=${PROJECT_NAME} -Dversion=1.0-SNAPSHOT \
    -DarchetypeGroupId=org.apache.camel.archetypes \
    -DarchetypeArtifactId=camel-archetype-spring \
    -DarchetypeVersion=${CAMEL_VERSION} \
    org.apache.maven.plugins:maven-archetype-plugin:RELEASE:generate
```

## Platforms

### Quarkus

The Camel components that are supported on Quarkus are the ones which have a Quarkus extension - see the [list of extensions](https://camel.apache.org/camel-quarkus/latest/list-of-camel-quarkus-extensions.html). e.g.: `camel-quarkus-activemq`, `camel-quarkus-timer`, etc.

Camel Quarkus components respect the `camel.component.*` properties for autoconfiguration, e.g. setting `camel.component.activemq.broker-url` when the ActiveMQ component is used, will create a connection to the given broker URL.

## Cookbook

### Basics 

#### Logging the message body and headers

Add a log step, which will log the current message body and all headers:

```
.to("log:com.example.mylogger?level=INFO&showAll=true")
```

### Servlet: Configure the Servlet component with a mapping URI

To be able to provide services from the local Servlet container, Camel registers itself as a Servlet. To configure this manually (and specify the mapping URI that the Camel Servlet component should use):

```java
// import org.springframework.context.annotation.Bean;
// import org.springframework.boot.web.servlet.ServletRegistrationBean;

@Bean
ServletRegistrationBean servletRegistrationBean() {
    ServletRegistrationBean servlet = new ServletRegistrationBean(
        new CamelHttpTransportServlet(), "/my-services/*");
    servlet.setName("MyCamelServletName");
    return servlet;
}
```

### Servlet: use Spring Boot auto-configuration to create a Servlet

The `camel-servlet-starter` can configure a Servlet for all your HTTP-related stuff. Add the dependency:

```xml
<dependency>
  <groupId>org.apache.camel</groupId>
  <artifactId>camel-servlet-starter</artifactId>        
</dependency>
```

Then modify the servlet configuration using these Spring properties:

- `camel.component.servlet.mapping.enabled` - Enables the automatic mapping of the servlet component into the Spring web context (default: true)
- `camel.component.servlet.mapping.context-path` - this is the **root** context path where your services will be mapped from, e.g. `/services/*` (default is `/camel/*`)
- `camel.component.servlet.mapping.servlet-name` - the name of the Camel Servlet (default: `CamelServlet`). **NB:** if you change this servlet name from the default, you might find that your requests do not get mapped properly, resulting in 404 errors.

### JMS: Initialise the JMS component with a transaction manager

Initialise a Camel JMS component and use the transaction manager on the classpath, e.g. if Narayana is there, it will use it:

```java
@Bean(name = "jms-component")
public JmsComponent jmsComponent(ConnectionFactory xaJmsConnectionFactory,
        PlatformTransactionManager jtaTransactionManager) {
    JmsComponent jms = new JmsComponent();
    jms.setConnectionFactory(xaJmsConnectionFactory);
    jms.setTransactionManager(jtaTransactionManager);
    jms.setTransacted(true);

    return jms;
}
```

### CXF/SOAP: populate the body with a simple JAXB element

XML DSL: Use `transform` and `method` with the `ObjectFactory` created by JAXB to create a simple output:

```xml
<transform>
    <method method="createMyResponseElement"
            beanType="com.example.myservice.ObjectFactory"/>
</transform>
```

## Testing

Camel provides the following test support classes:

Class                    | ...
------------------------ | ------------------------------------------------------------------------
`TestSupport`            | Contains some useful test methods, e.g. `deleteDirectory`, etc.
`CamelTestSupport`       | Extends `TestSupport` by creating a CamelContext and a ProducerTemplate.
`CamelSpringTestSupport` | ...

And these runners:

Runner                  | Description
----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
`CamelSpringBootRunner` | e.g. `@RunWith(CamelSpringBootRunner.class)` - to be used with Spring Boot applications. Add an `@Autowired CamelContext camelContext` to the class members. This extends the `SpringJUnit4ClassRunner` class from Spring.

### Mock component

Use the Mock component to intercept requests, return mock data, etc.

- The `@MockEndpointsAndSkip` annotation can be used to mock one set of endpoints automatically. This requires that the component being mocked already exists - e.g. an `activemq` component or `amqp` component, etc.

  - To confirm that the endpoint(s) are successfully mocked, look for this in the logs: `.c.i.InterceptSendToMockEndpointStrategy : Adviced endpoint [jms://queue:MY.QUEUE?exchangePattern=InOnly] with mock endpoint [mock:jms:queue:MY.QUEUE]`
  - Note that mock endpoints will **not** be shown in the log line which starts with: `Adviced route before/after as XML....`

- A route **can't receive** from a `mock:` endpoint, so use `replaceFromWith()` to a direct endpoint if you also want to "mock" the first component in a route.

- If a `getMockEndpoint()` references a Mock endpoint that doesn't actually exist, any assertions placed onto that Mock endpoint will silently pass without error.

#### Basic assertions with mock endpoints

Use mock points to verify that a particular endpoint was invoked, and optionally do assertions on the content of the message received by the mock.

Assert that the first received message is of a given type:

```java
MockEndpoint mock = getMockEndpoint("mock:output");
mock.message(0).body().isInstanceOf(MyCustomClass.class);

assertMockEndpointsSatisfied();
```

#### Return test data from a mock endpoint with a reusable Processor

Returning fake data from a Mock endpoint is done by providing a `Processor` to `whenAnyExchangeReceived`. We can create an inner `Processor` class which can be reused across multiple tests, in case there are many tests which execute in a similar way:

```java
MockEndpoint myMockComponent;

public void shouldDoSomething() throws Exception {
    myMockComponent.whenAnyExchangeReceived(new TestDataProcessor("something"));

    // do your assertions here
}

// Inner Processor class which can be reused across multiple tests
class TestDataProcessor implements Processor {
    private String testData;

    public TestDataProcessor(String testData) {
        super();
        this.testData = testData;
    }

    @Override
    public void process(Exchange exchange) throws Exception {
        // Put the test String in the message body
        exchange.getMessage().setBody(testData);
        // optionally also set any headers here
    }
}
```

### Camel Testing cookbook

#### Using files in `src/test/resources` as test data

Using the contents of a file as the body of a test message:

```java
InputStream payload = getClass().getClassLoader().getResourceAsStream("barPolicyRoute.xml");
template.sendBody("direct:your-endpoint", payload);
```

#### Adding a bean to the Camel registry for testing

**Camel 3.x method:**

Extend the `CamelTestSupport` class and then annotate any fields with `@BindToRegistry`, which adds that bean to the registry, e.g.:

```java
@BindToRegistry("digitalOceanClient")
DigitalOceanClient digitalOceanClient = new DigitalOceanClientMock();
```

Or override the method `bindToRegistry(Registry registry)` in the class `CamelTestSupport`:

```java
@Override
protected void bindToRegistry(Registry registry) throws Exception {
    // add ActiveMQ with embedded broker
    ConnectionFactory connectionFactory = CamelJmsTestHelper.createConnectionFactory();
    JmsComponent amq = jmsComponentAutoAcknowledge(connectionFactory);
    amq.setCamelContext(context);

    registry.bind("jms", amq);
}
```

**Camel 2.x method:**

To add clients, components, or anything that needs to be available to Camel when the test runs, extend the `CamelTestSupport` class and override `createRegistry()`:

```java
@Override
protected JndiRegistry createRegistry() throws Exception {
  JndiRegistry registry = super.createRegistry();

  // Instantiate the object and add it to the Camel registry
  MyClientBean clientBean = new MyClientBean();
  registry.bind("clientBean", clientBean);

  return registry;
}
```

#### Assertions on a synchronous exchange

Use an inline processor and the `request` method to invoke an endpoint synchronously:

```java
Exchange rtn = template.request("direct:hello", new Processor() {
  @Override
  public void process(Exchange exchange) throws Exception {
    exchange.getMessage().setHeader("foo", "bar");
  }
});
assertEquals("bar", rtn.getMessage().getHeader("foo"));
```

#### Testing a custom Camel Processor

To test your own custom Camel Processor without having to test it from within a route, you'll need an `Exchange` object, which itself needs a `CamelContext`. We can easily do this with a `DefaultCamelContext` and an `ExchangeBuilder`:

```java
// import org.apache.camel.builder.ExchangeBuilder;
// import org.apache.camel.impl.DefaultCamelContext;

@Test
public void testCustomProcessor() throws Exception {
    CustomProcessor customProcessor = new CustomProcessor();
    CamelContext context = new DefaultCamelContext();
    Exchange exchange = new ExchangeBuilder(context).withBody("INPUT_STRING").build();

    // Pass exchange to Processor
    customProcessor.process(exchange);

    // Assert that the Exchange changed
    assertEquals("EXPECTED_OUTPUT", exchange.getMessage().getBody(String.class));
}
```

#### Testing a Timer with NotifyBuilder

Test that a number of messages flow through the route successfully:

```java
@RunWith(CamelSpringBootRunner.class)
@SpringBootTest(classes = Application.class)
public class ApplicationTest {

    @Autowired
    private CamelContext camelContext;

    @Test
    public void shouldSendMessage() throws Exception {
        // Assert that Camel produces 1 message
        // (which is generated by the Timer component)
        NotifyBuilder notify = new NotifyBuilder(camelContext).whenDone(1).create();
        // whenDone = sets a condition when number of Exchange is done being processed.

        assertTrue(notify.matches(10, TimeUnit.SECONDS));

    }
}
```

#### Using AdviceWith in Camel 3.x

If using Camel 3 onwards, use this helper class to apply an `adviceWith` to a route:

```java
AdviceWithRouteBuilder.adviceWith(context, "main-route",
    a -> a.weaveAddLast().to("mock:output")
);
```

#### Use AdviceWith to add an endpoint

Adding a mock component (`mock:output`) to the end of a route:

```java
RouteDefinition route = context.getRouteDefinitions().get(0);
route.adviceWith(context, new AdviceWithRouteBuilder() {
  @Override
  public void configure() throws Exception {
    weaveAddLast().to("mock:output");
  }
});
```

#### Using AdviceWith with Spring Boot

If you want to use `adviceWith()` to modify Camel routes in your Spring Boot app then:

- Annotate your test class with `@UseAdviceWith`
- If you don't, then the `CamelSpringBootJUnit4ClassRunner` will attempt to start your routes.
- This would be bad, because then your routes will be started with the _non-adviced_ configuration.

Example:

```java
@RunWith(CamelSpringBootRunner.class)
@UseAdviceWith
@SpringBootTest(classes = MyApplication.class,
        properties = { "key = value"})
public class MyApplicationTest {

    @Autowired
    private CamelContext context;

    @Before
    public void setUp() throws Exception {

        RouteDefinition initiate = context.getRouteDefinition("my-route");
        initiate.adviceWith(context, new AdviceWithRouteBuilder() {
            @Override
            public void configure() throws Exception {
                // Replace the `from` component in this route with a direct:start
                replaceFromWith("direct:start");
            }
        });
    }

    @Test
    public void testXslt() throws Exception {
        context.start();
        // do stuff
        context.stop();
    }
}
```

### Test templates

#### Using CamelTestSupport

A basic Camel test support class, useful for playing around/POCs. Define a Camel route and test it, all in one single test class:

```java
public class MyQuickCamelTest extends CamelTestSupport {

  @Test
  public void testRoute() throws Exception {
    // Test and assertions go here
  }

  @Override
  protected RoutesBuilder createRouteBuilder() throws Exception {
    return new RouteBuilder() {
      @Override
      public void configure() throws Exception {
        // Route goes here:
        // from("direct:...").to("something:else")....
      }
    };
  }
}
```

#### Using CamelSpringTestSupport

For Spring-based applications. Allows you to get standard Camel objects like `ProducerTemplate` and methods like `getMockEndpoints`, without having to inject any dependencies:

```java
public class BeanTest extends CamelSpringTestSupport {

  @Override
  protected AbstractApplicationContext createApplicationContext() {
    // provide the path to your Spring XML config
    return new ClassPathXmlApplicationContext("com/example/MyApplication-context.xml");
  }

  @Test
  public void testSingleMethod() throws Exception {
    RouteDefinition route = context.getRouteDefinitions().get(0);
    route.adviceWith(context, new AdviceWithRouteBuilder() {
      @Override
      public void configure() throws Exception {
        weaveAddLast().to("mock:output");
      }
    });

    MockEndpoint mock = getMockEndpoint("mock:output");
    mock.expectedBodiesReceived("Expected body here");

    template.sendBody("direct:start", null);

    assertMockEndpointsSatisfied();
  }

}
```

#### Spring Boot Camel test

Assuming that you have already defined a Camel Context (using XML or otherwise), then first add these dependencies:

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-test</artifactId>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.apache.camel</groupId>
  <artifactId>camel-test-spring</artifactId>
  <scope>test</scope>
</dependency>
```

And then create a simple test class like this:

```java
@RunWith(CamelSpringBootRunner.class)
@SpringBootTest(classes = MyApplication.class)
public class MyApplicationTest {

    @Autowired
    private CamelContext camelContext;

    @Test
    public void shouldDoSomething() throws Exception {
        // Put assertions here
    }

}
```

#### Blueprint testing with CamelBlueprintTestSupport

An example test class for Camel routes implemented with OSGi Blueprint:

```java
import org.apache.camel.test.blueprint.CamelBlueprintTestSupport;
import org.junit.Test;

public class MyApplicationTest extends CamelBlueprintTestSupport {

    @Override
    protected String getBlueprintDescriptor() {
        return "/OSGI-INF/blueprint/camel-context.xml";
    }

    @Test
    public void testReturnsProperty() throws Exception {
        // assert that the CamelContext starts up correctly
        assertTrue(context.getStatus().isStarted());
    }

}
```

## Camel 2 to 3 migration notes

`RouteBuilder` class not found:

- Camel Spring Boot dependencies have moved to the Maven groupId `org.apache.camel.springboot`

_Package `org.apache.camel.builder.xml` does not exist_:

- The XPathBuilder class has moved.
- Add `camel-xpath` dependency
- Replace import with: `import static org.apache.camel.language.xpath.XPathBuilder.xpath`

_org.apache.camel.impl.JndiRegistry in org.apache.camel.impl has been deprecated_:

- No longer need to explicitly create and configure a registry
- Use the `@BindToRegistry("myBeanName")` annotation against a field member.
- Or override the method `void bindToRegistry(Registry registry)`
- See the section below on _Adding a bean to the Camel registry for testing_

_cannot find symbol: class DefaultExchange, location: package org.apache.camel.impl_:

- Moved to `org.apache.camel.support.DefaultExchange`

_getOut() in org.apache.camel.Exchange has been deprecated_:

- Use `getMessage()` instead.

`adviceWith()` no longer exists in `RouteDefinition` class:

- Switch to: `AdviceWithRouteBuilder.adviceWith(context, "main-route", a -> a.weaveAddLast().to("mock:output"));`

`saxon=true` no longer exists on XSLT component:

- Functionality has been moved to the `xslt-saxon` component instead.

Data formats: `<unmarshal ref="myformat"/>` is no longer supported syntax:

- Use `<unmarshal><custom ref="myformat"></unmarshal>` instead.

## Troubleshooting

Non-privileged (non-root) user can't start a web server - _java.net.SocketException: Permission denied_ when trying to start a web server (e.g. Jetty) on port 80xx:

- Make sure that the full scheme is specified in the consumer, e.g. `jetty:http://localhost:8443/hello`
