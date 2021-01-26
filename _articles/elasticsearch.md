---
layout: page
title: Elasticsearch
---

## Cookbook

### High Level Client API

#### Create test SearchHits object

To create a dummy `SearchHits` object, from some given JSON, you can use the static `SearchHits.fromXContent()` helper method. This takes in some JSON and converts it into a `SearchHits` object. This is useful when you want to create a mock response from Elasticsearch - e.g. to create a fake set of search results for a test case:

```java
// import org.elasticsearch.common.xcontent.XContentType;
// import org.elasticsearch.common.xcontent.XContentParser;
// import org.elasticsearch.search.SearchHits;
// import org.elasticsearch.common.xcontent.NamedXContentRegistry;

String somejson = "{\n" +
    "    \"total\" : {\n" +
    "      \"value\" : 4,\n" +
    "      \"relation\" : \"eq\"\n" +
    "    },\n" +
    "    \"max_score\" : 0.7985077,\n" +
    "    \"hits\" : [\n" +
    "      {\n" +
    "        \"_index\" : \"resources\",\n" +
    "        \"_type\" : \"resource\",\n" +
    "        \"_id\" : \"11\",\n" +
    "        \"_score\" : 0.7985077,\n" +
    "        \"_source\" : {\n" +
    "          \"fileId\" : \"London Bridge\",\n" +
    "          \"filename\" : \"test.png\",\n" +
    "          \"created\" : \"2019-07-08T15:46:53Z\",\n" +
    "          \"name\" : \"test\",\n" +
    "          \"datetime\" : \"2019-07-08T15:46:53Z\",\n" +
    "          \"format\" : \"png\",\n" +
    "          \"projection\" : \"4326\"\n" +
    "        }\n" +
    "      }\n" +
    "    ]\n" +
    "  }";

XContentType xContentType = XContentType.JSON;
XContentParser parser = xContentType.xContent().createParser(NamedXContentRegistry.EMPTY, somejson);

SearchHits mySearchHits = SearchHits.fromXContent(parser);
```
