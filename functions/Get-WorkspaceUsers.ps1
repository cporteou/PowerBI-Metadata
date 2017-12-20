

function Get-WorkspaceUsers{
    
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]
        $authToken,
    
        [string]
        $workspaceID,

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
            if($workspaceID){                    
                Write-Verbose 'Returning Users for specified Workspace'
                $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($WorkspaceID)/users"

                $workspaceUsers = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                $workspaceUsers.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $WorkspaceID
            }
            elseif ($workspaceName) {
                
                Write-Verbose 'Workspace Name provided. Matching to ID & building API call'
                $workspace = Get-Workspaces -authToken $authToken -workspaceName $workspaceName

                Write-Verbose 'Returning Users for specified Workspace'
                $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/users"
                
                $workspaceUsers = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                $workspaceUsers.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $workspace.id
            }
            else {
                Write-Verbose 'Fetching all Workspaces'
                $workspaces = Get-Workspaces -authToken $authToken 

                $workspaceUsers = @()

                Write-Verbose 'Returning Users for all Workspaces'
                foreach($workspace in $workspaces)
                {
                    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/users"
                    $users = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

                    $users.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $Workspace.id

                    $workspaceUsers += $users
                    
                }
            }               
            
        }
        catch {
            Write-Error "Error calling REST API: $($_.Exception.Message)"
        }
    }
    End{    
        
        return $workspaceUsers.Value

    }
}