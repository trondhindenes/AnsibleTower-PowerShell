<#
.DESCRIPTION
Gets hosts defined in Ansible Tower.

.PARAMETER Description
Optional description of this host.

.PARAMETER InsightsSystemId
Red Hat Insights host unique identifier.

.PARAMETER InstanceId
The value used by the remote inventory source to uniquely identify the host

.PARAMETER Name
Name of this host.

.PARAMETER Variables
Host variables in JSON or YAML format.

.PARAMETER Id
The ID of a specific AnsibleHost to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleHost {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [OutputType([AnsibleTower.Host])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$InsightsSystemId,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$InstanceId,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [Object]$Inventory,

        [Parameter(Position=3,ParameterSetName='PropertyFilter')]
        [Object]$Group,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$LastJob,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Variables,

        [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("Description")) {
            if($Description.Contains("*")) {
                $Filter["description__iregex"] = $Description.Replace("*", ".*")
            } else {
                $Filter["description"] = $Description
            }
        }

        if($PSBoundParameters.ContainsKey("InsightsSystemId")) {
            if($InsightsSystemId.Contains("*")) {
                $Filter["insights_system_id__iregex"] = $InsightsSystemId.Replace("*", ".*")
            } else {
                $Filter["insights_system_id"] = $InsightsSystemId
            }
        }

        if($PSBoundParameters.ContainsKey("InstanceId")) {
            if($InstanceId.Contains("*")) {
                $Filter["instance_id__iregex"] = $InstanceId.Replace("*", ".*")
            } else {
                $Filter["instance_id"] = $InstanceId
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

        if($PSBoundParameters.ContainsKey("Group")) {
            switch($Inventory.GetType().Fullname) {
                "AnsibleTower.Group" {
                    $Filter["groups__id"] = $Group.id
                }
                "System.Int32" {
                    $Filter["group__id"] = $Group
                }
                "System.String" {
                    $Filter["groups__name"] = $Group
                }
                default {
                    Write-Error "Unknown type passed as -Inventory ($_).  Suppored values are String, Int32, and AnsibleTower.Inventory." -ErrorAction Stop
                    return
                }
            }
        }

        if($PSBoundParameters.ContainsKey("LastJob")) {
            switch($LastJob.GetType().Fullname) {
                "AnsibleTower.Job" {
                    $Filter["last_job"] = $LastJob.Id
                }
                "System.Int32" {
                    $Filter["last_job"] = $LastJob
                }
                "System.String" {
                    $Filter["last_job__name"] = $LastJob
                }
                default {
                    Write-Error "Unknown type passed as -LastJob ($_).  Supported values are String, Int32, and AnsibleTower.Job." -ErrorAction Stop
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

        if($PSBoundParameters.ContainsKey("Variables")) {
            if($Variables.Contains("*")) {
                $Filter["variables__iregex"] = $Variables.Replace("*", ".*")
            } else {
                $Filter["variables"] = $Variables
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "hosts" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "hosts" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseTohost($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            $CacheKey = "hosts/$($AnsibleObject.Id)"
            Write-Debug "[Get-AnsibleHost] Caching $($AnsibleObject.Url) as $CacheKey"
            $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
            #Add to cache before filling in child objects to prevent recursive loop
            $AnsibleObject = Add-RelatedObject -InputObject $AnsibleObject -ItemType "hosts" -RelatedType "groups" -RelationProperty "Groups" -RelationCommand (Get-Command Get-AnsibleGroup) -PassThru
            Write-Output $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}
