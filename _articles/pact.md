---
layout: page
title: Pact (contract testing)
---

## Integrating with Java

### Pact testing a Camel/Spring Boot application - example

This example shows how to implement Provider-side contract testing of a REST API which has been implemented using [Apache Camel][camel]/[Red Hat Fuse][fuse] on [Spring Boot][springboot]. This will retrieve a contract from the Pact Broker:

1. The Consumer first defines the contract, using the appropriate client-side tooling (e.g. for Angular)
2. Add the [Pact JVM Provider][pactjvmprovider] dependency to the Provider project.
3. Add a test class (`*IT`) to the Provider project. Use the annotations provided by `pact-jvm-provider` to download the relevant contract from a Pact Broker. Use the `SpringRestPactRunner.class` runner.
4. Configure Maven Failsafe Plugin to run the contract test during the [Maven integration-test phase][maven] and publish results to the Pact Broker.

First add dependencies to the POM:

```xml
<dependency>
    <groupId>au.com.dius</groupId>
    <artifactId>pact-jvm-provider-spring_2.12</artifactId>
    <version>${pact-jvm-provider.version}</version>
    <scope>test</scope>
</dependency>
```

Construct a contract test class:

- Replace any components that talk to downstream applications (e.g. databases, etc) with Camel mock components
- Configure the mock components to return appropriate fake data
- Build a test case for each `State` in the Pact contract.

An example test class might look something like this:

```java
@RunWith(SpringRestPactRunner.class)
@Provider("provider-name-given-in-pact-broker")
@PactBroker
@SpringBootTest(
        classes = CatalogueSearchApplication.class,
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@DirtiesContext(classMode = DirtiesContext.ClassMode.BEFORE_EACH_TEST_METHOD)
@UseAdviceWith
@MockEndpointsAndSkip("bean:my-data-store")
public class MyApplicationProviderContractIT {

    @EndpointInject(uri = "mock:bean:my-data-store")
    MockEndpoint mockMyDataStore;

    @TestTarget
    public final Target target = new SpringBootHttpTarget();

    /**
     * Implements what the application should return when the following Pact
     * interaction is executed:
     * "state name as defined in the pact contract"
     */
    @State("state name as defined in the pact contract")
    @Test
    public void lookupUsingQueryParams() throws Exception {
        // Configure the mock bean to return some fake data
        mockMyDataStore.whenAnyExchangeReceived(new MockDataStoreProcessor());

        // The application will function otherwise as normal,
        // returning a response back to the caller
    }

    @State("another state from the pact contract")
    @Test
    public void anotherTest() throws Exception {
        // ...
    }

    class MockDataStoreProcessor implements Processor {
        @Override
        public void process(Exchange exchange) throws Exception {
            exchange.getMessage().setBody("some fake data");
        }
    }
}
```

Finally configure the Maven Failsafe Plugin to run the test with specific properties to connect to the Pact Broker:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-failsafe-plugin</artifactId>
    <version>2.22.0</version>
    <configuration>
        <!-- Configure plugin to play nicely with Spring Boot -->
        <!-- https://github.com/spring-projects/spring-boot/issues/6254#issuecomment-307151464 -->
        <classesDirectory>${project.build.outputDirectory}</classesDirectory>

        <!-- Configure PACT to publish contract test results when finished -->
        <systemPropertyVariables>
            <pactbroker.host>my-pact-broker</pactbroker.host>
            <pactbroker.port>8080</pactbroker.port>
            <pactbroker.username>admin</pactbroker.username>
            <pactbroker.password>letmein</pactbroker.password>
            <pact.provider.version>${project.version}</pact.provider.version>
        </systemPropertyVariables>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>integration-test</goal>
                <goal>verify</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

Then the test can be run using:

    mvn clean verify



[pactjvmprovider]: https://github.com/DiUS/pact-jvm
[maven]: {{ site.baseurl }}{% link _articles/maven.md %}
[camel]: {{ site.baseurl }}{% link _articles/apache-camel.md %}
[fuse]: {{ site.baseurl }}{% link _articles/jboss-fuse.md %}
[springboot]: {{ site.baseurl }}{% link _articles/spring-boot.md %}
