# PowerBI-Metadata

This is a collection of Power BI API functions to access Power BI Metadata.

## Prerequisites

### Power BI or Azure App

To facilitate authentication to Power BI we must use an App created in Power BI or Azure.

https://dev.powerbi.com/apps

**App Name** - Name your app appropriately

**Redirect URL** - This can be entered as any URL with the **Server-side Web app** as it is not required

**Home Page URL** - This can be entered as any URL with the **Server-side Web app** as it is not required

**App Type**
* Server-side Web App / API - Required to utilise the unattended authentication function. You will be provided with a **ClientID** and a **Client_Secret**
* Native App - Used for prompted authentication. Only provides a **ClientID**

**Choose APIs to access** - All APIs should be selected unless you intend to use this app in a restricted environment or use multiple apps for consumption & distribution of data



*NOTE: First use of an "App" needs to be granted permission from Azure Portal (-> go to Azure Active Directory -> App Registrations -> find your app -> Required Permissions -> Grant Permissions.)*


## Sample Commands

