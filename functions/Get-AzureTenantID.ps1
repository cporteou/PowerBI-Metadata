<#
.SYNOPSIS
This function returns the Azure Tenant ID for a provided domain

.DESCRIPTION
This function queries Azure anonymously to return the provided domain's
tenant ID. The function can take a valid user email for that domain or
the domain name itself.

.PARAMETER Domain
This is the Azure domain name with the suffix included

.PARAMETER Email
This is a valid user email for the target domain

.EXAMPLE
Get-AzureTenantID -Domain 'craigporteous.com'
Get-AzureTenantID -Email 'Craig@craigporteous.com'

.NOTES

#>
function Get-AzureTenantID {

    [CmdletBinding()]
    param
    (
        [string]
        $Domain,

        [string]
        $Email
    )

    Process {
        try {
            if ($Domain) {
                Write-Verbose 'Domain provided.'
            }
            elseif ($Email) {
                Write-Verbose 'Split the string on the username to get the Domain.'
                $Domain = $Email.Split("@")[1]
            }
            else {
                throw
                Write-Warning 'You must provide a valid Domain or User email to proceed.'
            }

            Write-Verbose 'Query Azure anonymously (this may not work for ALL tenant domains. Eg. Those that use .onmicrosoft.com)'
            $tenantID = (Invoke-WebRequest -UseBasicParsing https://login.windows.net/$($Domain)/.well-known/openid-configuration|ConvertFrom-Json).token_endpoint.Split('/')[3]

        }
        catch {
            throw $_
        }
        return $tenantID
    }
}