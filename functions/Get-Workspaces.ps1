

function Get-Workspaces{

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $authToken,
        
        [string]
        $workspaceName
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
            
            if($workspaceName){
                Write-Verbose 'Workspace Name provided. Fetching all Workspaces'
                $uri = "https://api.powerbi.com/v1.0/myorg/groups"
                $workspace = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

                Write-Verbose 'Matching Workspace Name to ID'
                $workspaces = $workspace.value | Where-Object{$_.name -eq $workspaceName}
            }
            else{
                $uri = "https://api.powerbi.com/v1.0/myorg/groups"
            
                $workspace = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                $workspaces = $workspace.value
            }
        }
        catch {
            Write-Error "Error retrieving Workspaces from API: $($_.Exception.Message)"
        }
        
    }
    End{    
        Write-Verbose 'Returning Workspace info'
        return $workspaces

    }
}