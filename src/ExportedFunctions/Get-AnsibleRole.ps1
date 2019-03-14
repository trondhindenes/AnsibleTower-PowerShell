<#
.DESCRIPTION
Gets roles defined in Ansible Tower.

.PARAMETER Id
The ID of a specific AnsibleRole to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleRole {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(Position=1,ParameterSetName='Organization')]
        [Parameter(Position=1,ParameterSetName='Project')]
        [string]$Name,

        [Parameter(Position=2,ParameterSetName='Organization')]
        [object]$Organization,

        [Parameter(Position=2,ParameterSetName='Project')]
        [object]$Project,

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
            "ById" {
            }
            default {
                Write-Error "Unknown parameter set name $_" -ErrorAction Stop
                Return
            }
        }

        if($PSCmdlet.ParameterSetName -ne "ById") {
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
                    Write-Error "Unknown type passed as -$($PSCmdlet.ParameterSetName) ($Parent).  Supported values are String, Int32, and AnsibleTower.$($PSCmdlet.ParameterSetName)." -ErrorAction Stop
                    return
                }
            }
            if(!$ParentId) {
                Write-Error "Unable to locate $($PSCmdlet.ParameterSetName) $Parent" -ErrorAction Stop
                return
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "roles" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType $ParentType -ItemSubItem "object_roles" -Id $ParentId -AnsibleTower $AnsibleTower
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
