---
layout: page
title: JAXB
---

## Sample @SetUp with an unmarshalled XML payload

```java
@Before
public void setUp() throws Exception {
    try {
        JAXBContext jc = JAXBContext.newInstance(WorkerSyncType.class);
        Unmarshaller unmarshaller = jc.createUnmarshaller();
        File file = new File("src/test/data/test.xml");
        JAXBElement<WorkerSyncType> workerSyncType = (JAXBElement<WorkerSyncType>) unmarshaller.unmarshal(file);
        workerType = workerSyncType.getValue().getWorker().get(0);
    } catch (Exception e) {
        _log.error(e.getMessage());
    }
}
```

## Marshal/serialise a JAXB-annotated object

```java
StringWriter writer = new StringWriter();
JAXBContext context = JAXBContext.newInstance(Student.class);
Marshaller m = context.createMarshaller();
m.marshal(student, writer);
```
