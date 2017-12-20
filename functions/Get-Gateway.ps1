



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