
function Get-PBIAuthTokenUnattended{
    <#
.SYNOPSIS
Authenticate against the Power BI API

.DESCRIPTION
This is an unattended authentication function. 
# Prerequisites
#-------------------------------------------------------------------------------
# Client ID & Client Secret can be obtained from creating a Power BI app:
# https://dev.powerbi.com/apps
# App Type: Web App / API
#-------------------------------------------------------------------------------

.PARAMETER userName
This is the user that will connect to Power BI. The datasets & groups that are returned
are restricted by the user's permissions

.PARAMETER tenantID
#----------------------------------------
# To find your Office 365 tenant ID in the Azure AD portal
# - Log in to Microsoft Azure as an administrator.
# - In the Microsoft Azure portal, click Azure Active Directory.
# - Under Manage, click Properties. The tenant ID is shown in the Directory ID box.

.PARAMETER clientId
This is the ID generated by the Power BI App created above. It can also be found from
within Azure

.PARAMETER client_secret
This is also generated when the Power BI App is created & must be noted as it is
irretrievable once you leave the page

.EXAMPLE
$authtoken = Get-PBIAuthTokenUnattended -userName User@domain.com -tenantID "85b7f285-XXXX-XXXX-XXXX-ec7116aa9ef5" -clientId "f40daa92-XXXX-XXXX-XXXX-7e027fe03e2e" -client_secret "5bM2KeZl2nVXXXXXXXXXXXXi6IYVPOt8lAtPwXXXXXX=""
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]    
        [string]
        $userName = "$(Read-Host 'Power BI Account')",
        
        [string]
        $tenantID,
        
        [Parameter(Mandatory=$true)]  
        [string]
        $clientId,
        
        [Parameter(Mandatory=$true)]  
        [string]
        $client_secret
    )

    begin {

        if($tenantID.Length -lt 36)
        {
            Write-Verbose "Retrieving Tenant ID for $($userName)"
            $tenantID = Get-AzureTenantID -Email $userName
        }

        $pbiAuthorityUrl = "https://login.windows.net/$tenantID/oauth2/token"
        $pbiResourceUrl = "https://analysis.windows.net/powerbi/api"

        Write-Verbose 'Test if ADAL module is installed & install if DLL not found'
        $moduleName = 'Microsoft.ADAL.PowerShell'        
        Try
        {
            if (Get-Module -ListAvailable -Name $moduleName)
            {
                Import-Module -Name $moduleName -ErrorAction SilentlyContinue
            }        
            else
            {
                Install-Module -Name $moduleName -ErrorAction SilentlyContinue
            }
        }
        Catch
        {
            throw '$moduleName module is not installed and could not be added'
        }

        Write-Verbose 'Get Username from encrypted text file'    
        $path = (Resolve-Path .\).Path
        #Grab current user as encrypted file is tagged with who encrypted it	
        $user = $env:UserName	
        $file = ($userName + "_cred_by_$($user).txt")
        Write-Verbose 'Testing if credential file exists & create if not'
        if(Test-Path $file)
        {
            $Pass = Get-Content ($path + '\' + $file) | ConvertTo-SecureString
        }
        else{
            Write-Host 'Encrypted Credential file not found. Creating new file.'
		    Read-Host -Prompt "Please enter Password for $userName" -AsSecureString | ConvertFrom-SecureString | Out-File "$($path)\$($userName)_cred_by_$($user).txt"
            Write-Verbose 'Encrypted file created'
            $Pass = Get-Content ($path + '\' + $file) | ConvertTo-SecureString
        }
    }
    Process{
        
        try {
            #Pull password from secure string
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Pass)
            $textPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            
            Write-Verbose 'Authenticating to Azure/PBI'
            $authBody = @{
                    'resource'=$pbiResourceUrl
                    'client_id'=$clientId        
                    'grant_type'="password"
                    'username'=$userName
                    'password'= $textPass
                    'scope'="openid"
                    'client_secret'=$client_secret
                }
            #Clear password variable immediately after use
            $textPass = $null            
            $auth = Invoke-RestMethod -Uri $pbiAuthorityUrl -Body $authBody -Method POST -Verbose
            #Clear auth array immediately after use
            $authBody = $null            
        }
        catch {
            Write-Error "Authentication or Connection failure: $($_.Exception.Message)" 
            throw $_            
        }
        Write-Verbose 'Authentication token retrieved'
        return $auth.access_token
    }
}
