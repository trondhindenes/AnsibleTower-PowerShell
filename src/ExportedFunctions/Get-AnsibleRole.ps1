<#
.DESCRIPTION
Gets roles defined in Ansible Tower.

.PARAMETER Id
The ID of a specific AnsibleRole to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleRole {
    [CmdletBinding(DefaultParameterSetName="SearchAll")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Credential")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUsePSCredentialType", "")]
    param(
        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(Position=1,ParameterSetName='Organization')]
        [Parameter(Position=1,ParameterSetName='Project')]
        [Parameter(Position=1,ParameterSetName='Credential')]
        [Parameter(Position=1,ParameterSetName='SearchAll')]
        [string]$Name,

        [Parameter(Position=2,ParameterSetName='Organization')]
        [object]$Organization,

        [Parameter(Position=2,ParameterSetName='Project')]
        [object]$Project,

        #Inventory
        #JobTemplate
        #Team
        #CustomInventoryScript
        #WorkflowJobTemplate

        [Parameter(Position=2,ParameterSetName='Credential')]
        [object]$Credential,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    End {
        switch($PSCmdlet.ParameterSetName) {
            "Organization" {
                $GetCommand = Get-Command Get-AnsibleOrganization
                $Parent = $Organization
                $ParentType = "organizations"
            }
            "Project" {
                $GetCommand = Get-Command Get-AnsibleProject
                $Parent = $Project
                $ParentType = "projects"
            }
            "Credential" {
                $GetCommand = Get-Command Get-AnsibleCredential
                $Parent = $Credential
                $ParentType = "credentials"
            }
            "ById" {
            }
            "SearchAll" {
            }
            default {
                Write-Error "Unknown parameter set name $_"
                Return
            }
        }

        if($PSCmdlet.ParameterSetName -ne "ById" -and $PSCmdlet.ParameterSetName -ne "SearchAll") {
            switch -Wildcard ($Parent.GetType().Fullname) {
                "Ansible.*" {
                    $ParentId = $Parent.Id
                    $AnsibleTower = $Parent.AnsibleTower
                }
                "System.Int32" {
                    $ParentId = $Parent
                }
                "System.String" {
                    $ParentId = (&$GetCommand -Name $Parent -AnsibleTower $AnsibleTower).Id
                }
                default {
                    Write-Error "Unknown type passed as -$($PSCmdlet.ParameterSetName) ($Parent).  Supported values are String, Int32, and AnsibleTower.$($PSCmdlet.ParameterSetName)."
                    return
                }
            }
            if(!$ParentId) {
                Write-Error "Unable to locate $($PSCmdlet.ParameterSetName) $Parent"
                return
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "roles" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            if($PSCmdlet.ParameterSetName -eq "SearchAll") {
                $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "roles" -AnsibleTower $AnsibleTower
            } else {
                $Return = Invoke-GetAnsibleInternalJsonResult -ItemType $ParentType -ItemSubItem "object_roles" -Id $ParentId -AnsibleTower $AnsibleTower
            }
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            if(!$Name -or $ResultObject.Name -like $Name) {
                $JsonString = $ResultObject | ConvertTo-Json
                $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseTorole($JsonString)
                $AnsibleObject.AnsibleTower = $AnsibleTower
                Write-Output $AnsibleObject
                $AnsibleObject = $Null
            }
        }
    }
}