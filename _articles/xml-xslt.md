---
layout: page
title: XML and XSLT
---

{% include toc.html %}

## Tools

### CLI

MacOS comes with a command line Xpath evaluator (useful!):

    $ xpath inputfile.xml '//ws:Worker[ws:Personal/ws:Email_Data[ws:Email_Type="HOME" and ws:Is_Primary!="true"]'

Quick and dirty way of finding the number of occurrences of an XML element:

    $ grep -o '<ws:Worker>' inputfile.xml | wc -l

## Functions

### document()

`document()` can be used to access nodes in an external XML document:

    document(path)

#### Path resolution

When using Apache Camel's XSLT component, the `path` argument can be:

- `filename.xml` - this will look in the classpath (relative to the location of the XSLT file)
- `file:///home/jsmith/files/filename.xml` - this will look on the file system at the given location


#### Example - using document() with a mapping file

Given an XML document like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<customerTypeMappings>
    <customerTypeMapping source="Basic" target="B"/>
    <customerTypeMapping source="Premium" target="P"/>
    <customerTypeMapping source="Gold" target="G"/>
</customerTypeMappings>
```

You can implement XSLT like this to **read in the document** and then **use the data** within a `template` - e.g. to map one value to another:

```xml
<xsl:param name="myXmlDocument"/>
<xsl:variable name="my_variable"
              select="document($myXmlDocument)"/>
              
<xsl:template match="ns1:Customer_Type">
  <ns1:Customer_Type>
    <xsl:value-of select="$my_variable/customerTypeMappings/customerTypeMapping[@source = current()]/@target"/>
  </ns1:Customer_Type>
</xsl:template>
```


    
