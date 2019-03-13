<#
.DESCRIPTION
Gets credential types configured in Ansible Tower.

.PARAMETER Description
Optional description of this credential type.

.PARAMETER Injectors
Enter injectors using either JSON or YAML syntax. Use the radio button to toggle between the two. Refer to the Ansible Tower documentation for example syntax.

.PARAMETER Inputs
Enter inputs using either JSON or YAML syntax. Use the radio button to toggle between the two. Refer to the Ansible Tower documentation for example syntax.

.PARAMETER Name
Name of this credential type.

.PARAMETER Id
The ID of a specific AnsibleCredentialType to get

.PARAMETER AnsibleTower
The Ansibl Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleCredentialType {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(Position=3,ParameterSetName='PropertyFilter')]
        [ValidateSet('ssh','vault','net','scm','cloud','insights')]
        [string]$Kind,

        [Parameter(ParameterSetName='PropertyFilter')]
        [bool]$ManagedByTower,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    End {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("Description")) {
            if($Description.Contains("*")) {
                $Filter["description__iregex"] = $Description.Replace("*", ".*")
            } else {
                $Filter["description"] = $Description
            }
        }

        if($PSBoundParameters.ContainsKey("Kind")) {
            if($Kind.Contains("*")) {
                $Filter["kind__iregex"] = $Kind.Replace("*", ".*")
            } else {
                $Filter["kind"] = $Kind
            }
        }

        if($PSBoundParameters.ContainsKey("ManagedByTower")) {
            switch($ManagedByTower.GetType().Fullname) {
                "AnsibleTower.ManagedByTower" {
                    $Filter["managed_by_tower"] = $ManagedByTower.Id
                }
                "System.Int32" {
                    $Filter["managed_by_tower"] = $ManagedByTower
                }
                "System.String" {
                    $Filter["managed_by_tower__name"] = $ManagedByTower
                }
                default {
                    Write-Error "Unknown type passed as -ManagedByTower ($_).  Supported values are String, Int32, and AnsibleTower.ManagedByTower." -ErrorAction Stop
                    return
                }
            }
        }

        if($PSBoundParameters.ContainsKey("Name")) {
            if($Name.Contains("*")) {
                $Filter["name__iregex"] = $Name.Replace("*", ".*")
            } else {
                $Filter["name"] = $Name
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "credential_types" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "credential_types" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToCredentialType($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}
