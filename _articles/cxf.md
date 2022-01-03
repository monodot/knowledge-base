---
layout: page
title: Apache CXF
---

{% include toc.html %}

## Concepts

Here are some of the key concepts in CXF:

Databinding

: this is CXF's pluggable approach to configure how it maps between XML and Java objects, and is usually one of:

- [JAXB][cxfjaxb]
- [XMLBeans][cxfxmlbeans] (deprecated)

Frontend

: this is CXF's way of mapping Java classes to/from a WSDL; it can be one of:

- [JAXWS][cxfjaxws] - where CXF will read JAX-WS annotations (e.g. `@javax.jws.WebService`) on the `interface` to set namespaces, operation names and parameter names.
- [Simple][cxfsimple] - where a simple `interface` (with no annotations) can be mapped to/from a WSDL. This means that CXF will make guesses at operation names and namespaces based on the method names and package of the interface.

Service Class / Service Endpoint Interface (JAX-WS)

: This is a Java `interface` which maps to a `portType` in a WSDL. It defines the service's operations, input and output messages, and is annotated with `@WebService`.

- e.g. `@WebService(targetNamespace = "http://customerservice.tomd.xyz/", name = "CustomerService")`

## Cookbook

### Generating client classes from a WSDL

Add the `cxf-codegen-plugin` to your Maven POM plugin configuration and bind the `wsdl2java` goal to [Maven's `generate-sources` phase][maven]. The classes will be generated in `target/generated-sources/cxf` by default:

```xml
<plugin>
    <groupId>org.apache.cxf</groupId>
    <artifactId>cxf-codegen-plugin</artifactId>
    <executions>
        <execution>
            <id>generate-sources</id>
            <phase>generate-sources</phase>
            <configuration>
                <wsdlOptions>
                    <wsdlOption>
                        <wsdl>src/main/resources/wsdl/BookService.wsdl</wsdl>
                        <wsdl>src/main/resources/wsdl/CustomerService.wsdl</wsdl>
                    </wsdlOption>
                </wsdlOptions>
            </configuration>
            <goals>
                <goal>wsdl2java</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### CXF as Client - Invoking an operation using CXF

You'll need:

- Java classes generated from your target service, with JAX-WS annotations.
- This Maven dependency: `org.apache.cxf:cxf-rt-frontend-jaxws`.

```java
// This Factory will create beans which can understand JAX-WS annotations
JaxWsProxyFactoryBean proxyFactory = new JaxWsProxyFactoryBean();

// This Factory creates a client for the service
ClientFactoryBean clientBean = proxyFactory.getClientFactoryBean();

// Configure
clientBean.setAddress("http://soap.mycompany.com:8080/BookService");
clientBean.setServiceClass(BookService.class); // This should be the `interface` generated from the WSDL
clientBean.setBus(BusFactory.newInstance().createBus());

BookService bookService = (BookService) proxyFactory.create();

// Invoke an operation named `GetAllBooks`
GetAllBooksResponse result = bookService.getAllBooks(new GetAllBooks());
```

## CXF with Camel

To use CXF in [Apache Camel][camel], use the CXF component. The component can be configured to use one of the following data formats:

- `POJO` (the default in Camel) - a Java object representation of the XML payload
- `MESSAGE` - the raw message received from the transport layer; i.e. the untouched, unparsed, raw SOAP XML (including headers, etc.)
- `PAYLOAD` - the message payload; i.e. the contents of `soap:Body`

  - This needs a `serviceClass`, which should be the fully-qualified class name of the `interface`, e.g. annotated with `@WebService(targetNamespace = "http://www.example.com/MyService/", name = "MyService")`

- `CXF_MESSAGE`

### Exposing a CXF endpoint in Camel on Spring Boot

Add to the POM:

```xml
<dependency>
  <groupId>org.apache.camel</groupId>
  <artifactId>camel-cxf-starter</artifactId>
</dependency>
<!-- Registers a CXF servlet for exposing web services at path: /services/ -->
<dependency>
  <groupId>org.apache.cxf</groupId>
  <artifactId>cxf-spring-boot-starter-jaxws</artifactId>
</dependency>
```

And a sample XML DSL Camel route:

```xml
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:cxf="http://camel.apache.org/schema/cxf"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://camel.apache.org/schema/spring http://camel.apache.org/schema/spring/camel-spring.xsd
        http://camel.apache.org/schema/cxf http://camel.apache.org/schema/cxf/camel-cxf.xsd">


    <camelContext id="camel" xmlns="http://camel.apache.org/schema/spring">
        <route id="inboundRoute">
            <from uri="cxf:/SimpleService?wsdlURL=/wsdl/myService.wsdl&dataFormat=MESSAGE"/>
            <log message="Received message at mock SOAP Service"/>
            <log message="${body}" loggingLevel="DEBUG"/>
            <setBody>
                <constant>OK</constant>
            </setBody>
        </route>
    </camelContext>

</beans>
```

Now the service should be available at `http://localhost:8080/services/SimpleService`

In the logs, look out for:

```
o.s.b.w.servlet.ServletRegistrationBean  : Servlet CXFServlet mapped to [/services/*]
```

### Explicitly configuring the namespaces on output

CXF will usually try to create a default namespace and assign its own prefixes. But if a legacy client doesn't understand these, or you need more control over the output (response) from [a CXF endpoint][camelcxfendpoint], then you can configure CXF explicitly. Here is an example of how to do it in Camel with Spring XML:

```xml
<!-- Configure the CXF endpoint manually here so that we have a bit more control over it -->
<cxf:cxfEndpoint id="customerEndpoint"
        address="http://localhost:8189/CustomerService"
        wsdlURL="/wsdl/CustomerService.wsdl"
        serviceClass="xyz.tomd.customerservice.CustomerService">
    <cxf:properties>
        <!-- Manually set the prefixes of namespaces in the output -->
        <entry key="soap.env.ns.map">
            <map>
                <entry key="ns0" value="http://customerservice.tomd.xyz/types/"/>
                <entry key="ns1" value="http://www.oracle.com/webservices/internal/literal"/>
                <entry key="env" value="http://schemas.xmlsoap.org/soap/envelope/"/>
            </map>
        </entry>
        <!-- This property will prevent CXF from setting a default namespace where it can -->
        <entry key="disable.outputstream.optimization" value="true"/>
    </cxf:properties>
</cxf:cxfEndpoint>
```

Notes on this example:

- Make sure that `xmlns:cxf="http://camel.apache.org/schema/cxf"` is added to the namespace definitions in the XML.
- The property [`disable.outputstream.optimization` is the key thing here][cxftransformation] and causes CXF to use namespace prefixes explicitly in the response, rather than trying to assign some elements to a default namespace.

## Troubleshooting

CXF & Camel: _"serviceClass must be specified"_

- When wsdlURL option is used without serviceClass, the serviceName and portName (endpointName for Spring configuration) options MUST be provided

CXF: _"org.apache.cxf.binding.soap.SoapFault: Message part {<http://bookservice.cleverbuilder.com/}getAllBooks> was not recognized. (Does it exist in service WSDL?)"_

- You are most likely using a `ClientProxyFactoryBean`; switch to a `JaxWsProxyFactoryBean` (the JAXWS 'frontend') so that CXF can understand JAX-WS annotations.

  - Observe that the namespace and operation name given in the log line does not exactly match the namespace and operation in the WSDL.
  - CXF is trying to create its own requests from the package name and method in the service class (interface), rather than using the namespace and operation names defined in JAX-WS annotations.

CXF/JAXWS: _"java.io.IOException: Cannot find any registered HttpDestinationFactory from the Bus."_

- Your endpoint's `address` is an absolute URL (has a hardcoded `http:` at the start of it). Change it to a relative URL, to allow CXF to use whatever web server is available (e.g. Tomcat, Undertow)
- You're trying to create a service (e.g. `Endpoint.publish(...)`) but there is no HTTP transport for CXF on the classpath. Add `cxf-rt-transports-http-jetty` as a dependency. This will allow CXF to use Jetty to host your service.

[maven]: {{ site.baseurl }}{% link _articles/maven.md %}
[camel]: {{ site.baseurl }}{% link _articles/camel.md %}

[camelcxfendpoint]: https://github.com/apache/camel/blob/master/components/camel-cxf/src/main/docs/cxf-component.adoc#configure-the-cxf-endpoints-with-spring
[cxfjaxb]: https://cxf.apache.org/docs/jaxb.html
[cxfjaxws]: https://cxf.apache.org/docs/jax-ws.html
[cxfsimple]: https://cxf.apache.org/docs/simple-frontend.html
[cxftransformation]: https://cwiki.apache.org/confluence/display/CXF20DOC/TransformationFeature
[cxfxmlbeans]: https://cxf.apache.org/docs/xmlbeans.html
