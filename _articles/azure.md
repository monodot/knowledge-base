---
layout: page
title: Azure
---

## Entra: Tenancy

- **Single-tenant Entra**
- **Multi-tenant Entra**

## Entra: Identity management

In Microsoft Entra (formerly Active Directory):

- **App registration** defines an application (client secrets, API permissions, redirect URIs, etc.). It is _"a template or blueprint to create one or more service principal objects."_
- **Service principal** (also called **Enterprise Application** in the UI) is like an instance of the application. It defines the access policy and permissions for the user/application in the Microsoft Entra tenant. There can be many service principals linked to 1 app registration.

Some nuggets of info from the docs - https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals?tabs=browser#application-object :

- _"If you register an application, an application object and a service principal object are automatically created in your home tenant"_ - In other words, creating an App Registration will also create a Service Principal, in your current Microsoft Entra tenant. If you're running single-tenant Entra, then your work is done here.
- _"A single-tenant application has only one service principal (in its home tenant), created and consented for use during application registration"_ - this says the same thing.
- _"A service principal is created in every tenant where the application is used ... A multitenant application also has a service principal created in each tenant where a user from that tenant has consented to its use."_ -- In other words, you should just need to create 1 of these service principals, unless you have many Entra tenants.
