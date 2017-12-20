

function Get-Datasets{
    
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
                Write-Verbose 'Returning datasets for specified Workspace'
                $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($WorkspaceID)/datasets"

                $datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                $datasets.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $WorkspaceID
            }
            elseif ($workspaceName) {
                Write-Verbose 'Workspace Name provided. Matching to ID & building API call'
                $workspace = Get-Workspaces -authToken $authToken -workspaceName $workspaceName

                Write-Verbose 'Returning datasets for specified Workspace'
                $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/datasets"
                
                $datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                $datasets.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $Workspace.id
            }
            else {
                Write-Verbose 'Fetching all Workspaces'
                $workspaces = Get-Workspaces -authToken $authToken 

                $datasets = @()

                Write-Verbose 'Returning datasets for all Workspaces'
                foreach($workspace in $workspaces)
                {
                    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets"
                    $workspaceDatasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

                    $workspaceDatasets.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $Workspace.id

                    $datasets += $workspaceDatasets
                    
                }
            }               
            
        }
        catch {
            Write-Error "Error calling REST API: $($_.Exception.Message)"
        }
    }
    End{    
        
        return $datasets.Value

    }
}