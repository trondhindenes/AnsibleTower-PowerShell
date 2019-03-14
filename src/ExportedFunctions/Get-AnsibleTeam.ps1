<#
.DESCRIPTION
Gets teams defined in Ansible Tower.

.PARAMETER Description
Optional description of this team.

.PARAMETER Name
Name of this team.

.PARAMETER Id
The ID of a specific AnsibleTeam to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleTeam {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [Object]$Organization,

        [Parameter(Position=3,ParameterSetName='PropertyFilter')]
        [String]$Description,

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

        if($PSBoundParameters.ContainsKey("Name")) {
            if($Name.Contains("*")) {
                $Filter["name__iregex"] = $Name.Replace("*", ".*")
            } else {
                $Filter["name"] = $Name
            }
        }

        if($PSBoundParameters.ContainsKey("Organization")) {
            switch($Organization.GetType().Fullname) {
                "AnsibleTower.Organization" {
                    $Filter["organization"] = $Organization.Id
                }
                "System.Int32" {
                    $Filter["organization"] = $Organization
                }
                "System.String" {
                    $Filter["organization__name"] = $Organization
                }
                default {
                    Write-Error "Unknown type passed as -Organization ($_).  Supported values are String, Int32, and AnsibleTower.Organization." -ErrorAction Stop
                    return
                }
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "teams" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "teams" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToteam($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            $AnsibleObject.Organization = Get-AnsibleOrganization -Id $AnsibleObject.Organization -AnsibleTower $AnsibleTower -UseCache
            Write-Output $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}
