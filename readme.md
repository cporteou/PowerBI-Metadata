# PowerBI-Metadata

This is a collection of Power BI API functions to access Power BI Metadata.

[<img src="https://cporteous.visualstudio.com/_apis/public/build/definitions/6ab8fe89-fdea-4b38-80bd-7daa632d0f9c/1/badge"/>](https://cporteous.visualstudio.com/Power%20BI%20Metadata/_build/index?definitionId=1)

PowerShell Gallery Page: https://www.powershellgallery.com/packages/PowerBI-Metadata

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

## Installation

`Install-Module -Name PowerBI-Metadata`

## Sample Commands

Authenticate to Power BI
`$auth = Get-PBIAuthTokenPrompt -clientId "f40daa92-XXXX-XXXX-XXXX-7e027fe03e2e"`

Return all Workspaces
`Get-Workspace -authToken $auth`

Return all datasets for a specific Workspace
`Get-Dataset -authToken $auth -workspaceName 'Workspace Name'`

Return the last 10 Refresh history for all datasets in Workspace
`Get-Dataset -authToken $auth -workspaceName 'GBI Dev' | foreach{Get-DatasetRefreshHistory -authToken $auth -workspaceID $_.WorkspaceID -DatasetID $_.id}`





