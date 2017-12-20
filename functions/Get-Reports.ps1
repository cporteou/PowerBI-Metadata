
<#
.SYNOPSIS
Returns information about Power BI Report(s)

.DESCRIPTION
This will return information on all Reports in a specified Workspace or in all workspaces if no Workspace parameter is provided.

.PARAMETER authToken
This is the required API authentication token (string) generated by the Get-PBIAuthTokenUnattended or Get-PBIAuthTokenPrompt commands.

.PARAMETER workspaceID
Optional parameter to restrict data to a specific Workspace ID

.PARAMETER workspaceName
Optional parameter to restrict data to a specific Workspace Name. The Workspace ID is retrieved using this name by the function

.EXAMPLE
Get-Reports -authToken $auth 
Get-Reports -authToken $auth -workspaceID 1530055f-XXXX-XXXX-XXXX-ee8c87e4a648
Get-Reports -authToken $auth -workspaceName 'Workspace Name'

.NOTES
General notes
#>
function Get-Reports{
    
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
                Write-Verbose 'Returning reports for specified Workspace'
                $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($WorkspaceID)/reports"

                $reports = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                $reports.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $WorkspaceID
            }
            elseif ($workspaceName) {
                
                Write-Verbose 'Workspace Name provided. Matching to ID & building API call'
                $workspace = Get-Workspaces -authToken $authToken -workspaceName $workspaceName

                Write-Verbose 'Returning reports for specified Workspace'
                $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/reports"
                
                $reports = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
                $reports.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $Workspace.id
            }
            else {
                Write-Verbose 'Fetching all Workspaces'
                $uri = "https://api.powerbi.com/v1.0/myorg/groups"
                $workspaces = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET 

                $reports = @()

                Write-Verbose 'Returning reports for all Workspaces'
                foreach($workspace in $workspaces.value)
                {
                    $WorkspaceID = $workspace.id

                    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($WorkspaceID)/reports"
                    $workspaceReports = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

                    $workspaceReports.value | Add-Member -NotePropertyName "WorkspaceID" -NotePropertyValue $WorkspaceID

                    $reports += $workspaceReports
                    
                }
            }               
            
        }
        catch {
            Write-Error "Error calling REST API: $($_.Exception.Message)"
        }
    }
    End{    
        
        return $reports.Value

    }
}