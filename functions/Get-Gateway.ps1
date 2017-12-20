
<#
.SYNOPSIS
Returns information about the tenant's On Premises Data Gateway(s)

.DESCRIPTION
This will return information such as status, hosting server etc for the specified data gateway or ALL data gateways if the Gateway 
parameters are not provided.

.PARAMETER authToken
This is the required API authentication token (string) generated by the Get-PBIAuthTokenUnattended or Get-PBIAuthTokenPrompt commands.

.PARAMETER gatewayName
Optional parameter to restrict data to a specific Gateway Name. The Gateway ID is retrieved using this name by the function

.PARAMETER gatewayID
Optional parameter to restrict data to a specific Gateway

.EXAMPLE
Get-Gateway -authToken $auth 
Get-Gateway -authToken $auth -GatewayName 'Gateway-Name'
Get-Gateway -authToken $auth -GatewayID '3d9355d4-XXXX-XXXX-XXXX-39cb67305ede'

.NOTES
General notes
#>
function Get-Gateway{
    
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$true)]
            [string]
            $authToken,
            
            
            [Parameter(ParameterSetName='gatewayName')]
            [string]
            $gatewayName,

            [Parameter(ParameterSetName='gatewayID')]
            [string]
            $gatewayID
        )
    
        Begin{
    
            Write-Verbose 'Building Rest API header with authorization token'
            $authHeader = @{
                'Content-Type'='application/json'
                'Authorization'='Bearer ' + $authToken
            }
        }
        Process{
    
            try {
                
                if($gatewayName){
                    Write-Verbose 'Gateway Name provided. Fetching all Gateways'
                    $uri = "https://api.powerbi.com/v1.0/myorg/gateways"
                    $gateways = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
    
                    Write-Verbose 'Matching Gateway Name to ID'
                    $gatewayInfo = $gateways.value | Where-Object{$_.name -eq $gatewayName}
                    #Another step is needed as this method does not provide gateway Status
                    Write-Verbose 'Gateway ID provided. Fetching info'
                    $uri = "https://api.powerbi.com/v1.0/myorg/gateways/$($gatewayinfo.id)"
                    $gateway = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                }
                elseif($gatewayID){
                    Write-Verbose 'Gateway ID provided. Fetching info'
                    $uri = "https://api.powerbi.com/v1.0/myorg/gateways/$($gatewayID)"
                    $gateway = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                }
                else{
                    Write-Verbose 'No Gateway provided. Returning all Gateway info'
                    $uri = "https://api.powerbi.com/v1.0/myorg/gateways"
                
                    $gateways = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

                    $gateway = @()

                    foreach($gatewayInfo in $gateways.value){
                        Write-Verbose "Gateway ID provided. Fetching info for $($gatewayinfo.name)"
                        $uri = "https://api.powerbi.com/v1.0/myorg/gateways/$($gatewayInfo.id)"
                        $gw = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

                        $gateway += $gw
                    }
                }
            }
            catch {
                Write-Error "Error retrieving Gateways from API: $($_.Exception.Message)"
            }
            
        }
        End{    
            Write-Verbose 'Returning Gateway info'
            return $gateway    
        }
    }