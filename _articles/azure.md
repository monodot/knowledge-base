---
layout: page
title: Azure
---

## Entra

### Single-tenant vs multi-tenant

- **Single-tenant Entra**
- **Multi-tenant Entra**

### App Registrations and Service Principals

In Microsoft Entra (formerly Azure AD):

- **App registration** defines an application (client secrets, API permissions, redirect URIs, etc.). It is _"a template or blueprint to create one or more service principal objects."_
- **Service principal** (appears in **Enterprise Application** in the UI) is like an instance of the application. It defines the access policy and permissions for the user/application in the Microsoft Entra tenant. There can be many service principals linked to 1 app registration.

To authenticate as a service principal, you need:
- `client_id` (from App Registration)
- `client_secret` or certificate (from App Registration)
- `tenant_id` (your Entra tenant)

#### Key differences between App Registrations, Service Principals, Enterprise Applications

- **Credentials live on App Registrations, not Service Principals.** Client secrets and certificates are stored on the App Registration, and all Service Principals linked to that registration share the same credentials.
- **"Enterprise Applications" is just a UI view of Service Principals.** Despite the confusing name, it's not a separate object type - it's simply where Azure Portal displays Service Principal identities, including those linked to App Registrations and standalone ones like Managed Identities.
- **"If you register an application, an application object and a service principal object are automatically created in your home tenant"** - In other words, creating an App Registration **in the UI** will also create a Service Principal, in your current Microsoft Entra tenant. However when creating via API/Terraform, you may need to explicitly create the Service Principal separately, **and you will need specific permissions in Entra to be able to do that.**
- **"A service principal is created in every tenant where the application is used"** -- In other words, you just need to create 1 service principal, unless you are working with many Entra tenants.

Sources:

- https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals?tabs=browser#application-object
- https://stackoverflow.com/questions/65922566/what-are-the-differences-between-service-principal-and-app-registration

## Cookbook

### Spin up a Windows dev machine with Visual Studio for .NET development

To have a Windows .NET environment for testing, especially for legacy frameworks like .NET Framework on Windows, you can spin up a virtual machine with the following settings (tested in Jan 2026):

**1. Create the VM**

- Virtual machine name: **yourname-dev-machine**
- Zone options: (just pick 1 zone)
- Image: **Visual Studio 2022 Community on Windows 11 Enterprise, version 25H2 (x64)**
- Size: **Standard_D4s_v3** (4 vcpus, 16 GiB memory) - note that this costs $233/mo.
- Public inbound ports: **None**
- Disks: (accept the default, 127 GiB)
- Networking tab:
    - NIC network security group: **Advanced** (we'll allowlist your IP address after VM creation)
    - Delete public IP and NIC when VM is deleted - **yes**
- Accept the rest of the defaults and **Create**.

**2. Update the Security Group**

Azure always wants to open up RDP to the entire internet for some reason. So you'll need to lock it down. After creation:

1. Edit the new Network Security Group (NSG) that is associated with the VM.
1. Delete the default "allow all" inbound rule to port 3389
1. Add a new rule: Settings > Inbound security rules > Add:
    - Source: **My IP Address**
    - Service: **RDP**

### RBAC in Azure

#### Working with App Registrations and Service Principals

```sh
# Fetch an App Registration
az ad app list --display-name "my-client-app"

# Fetch a Service Principal
az ad sp list --display-name "my-client-app"
```
