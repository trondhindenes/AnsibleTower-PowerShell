<#
.DESCRIPTION
Gets schedules defined in Ansible Tower.

.PARAMETER Description
Optional description of this schedule.

.PARAMETER Name
Name of this schedule.

.PARAMETER Rrule
A value representing the schedules iCal recurrence rule.

.PARAMETER Id
The ID of a specific AnsibleSchedule to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleSchedule {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [Object]$Inventory,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Rrule,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$UnifiedJobTemplate,

        [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
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

        if($PSBoundParameters.ContainsKey("Inventory")) {
            switch($Inventory.GetType().Fullname) {
                "AnsibleTower.Inventory" {
                    $Filter["inventory"] = $Inventory.Id
                }
                "System.Int32" {
                    $Filter["inventory"] = $Inventory
                }
                "System.String" {
                    $Filter["inventory__name"] = $Inventory
                }
                default {
                    Write-Error "Unknown type passed as -Inventory ($_).  Supported values are String, Int32, and AnsibleTower.Inventory." -ErrorAction Stop
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

        if($PSBoundParameters.ContainsKey("Rrule")) {
            if($Rrule.Contains("*")) {
                $Filter["rrule__iregex"] = $Rrule.Replace("*", ".*")
            } else {
                $Filter["rrule"] = $Rrule
            }
        }

        if($PSBoundParameters.ContainsKey("UnifiedJobTemplate")) {
            switch($UnifiedJobTemplate.GetType().Fullname) {
                "AnsibleTower.UnifiedJobTemplate" {
                    $Filter["unified_job_template"] = $UnifiedJobTemplate.Id
                }
                "System.Int32" {
                    $Filter["unified_job_template"] = $UnifiedJobTemplate
                }
                "System.String" {
                    $Filter["unified_job_template__name"] = $UnifiedJobTemplate
                }
                default {
                    Write-Error "Unknown type passed as -UnifiedJobTemplate ($_).  Supported values are String, Int32, and AnsibleTower.UnifiedJobTemplate." -ErrorAction Stop
                    return
                }
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "schedules" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "schedules" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToschedule($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}
