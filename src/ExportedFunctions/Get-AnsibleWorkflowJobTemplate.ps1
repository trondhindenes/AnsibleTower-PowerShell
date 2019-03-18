<#
.DESCRIPTION
Gets workflow job templates defined in Ansible Tower.

.PARAMETER Description
Optional description of this workflow job template.

.PARAMETER Inventory
Inventory applied to all job templates in workflow that prompt for inventory.

.PARAMETER Name
Name of this workflow job template.

.PARAMETER Id
The ID of a specific AnsibleWorkflowJobTemplate to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleWorkflowJobTemplate {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    [OutputType([AnsibleTower.WorkflowJobTemplate])]
    param(
        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AllowSimultaneous,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskInventoryOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskVariablesOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ExtraVars,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [Object]$Inventory,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$LastJobFailed,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(Position=3,ParameterSetName='PropertyFilter')]
        [Object]$Organization,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('new','pending','waiting','running','successful','failed','error','canceled','never updated','ok','missing','none','updating')]
        [string]$Status,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$SurveyEnabled,

        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    End {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("AllowSimultaneous")) {
            $Filter["allow_simultaneous"] = $AllowSimultaneous
        }

        if($PSBoundParameters.ContainsKey("AskInventoryOnLaunch")) {
            $Filter["ask_inventory_on_launch"] = $AskInventoryOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskVariablesOnLaunch")) {
            $Filter["ask_variables_on_launch"] = $AskVariablesOnLaunch
        }

        if($PSBoundParameters.ContainsKey("Description")) {
            if($Description.Contains("*")) {
                $Filter["description__iregex"] = $Description.Replace("*", ".*")
            } else {
                $Filter["description"] = $Description
            }
        }

        if($PSBoundParameters.ContainsKey("ExtraVars")) {
            if($ExtraVars.Contains("*")) {
                $Filter["extra_vars__iregex"] = $ExtraVars.Replace("*", ".*")
            } else {
                $Filter["extra_vars"] = $ExtraVars
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

        if($PSBoundParameters.ContainsKey("LastJobFailed")) {
            $Filter["last_job_failed"] = $LastJobFailed
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

        if($PSBoundParameters.ContainsKey("Status")) {
            if($Status.Contains("*")) {
                $Filter["status__iregex"] = $Status.Replace("*", ".*")
            } else {
                $Filter["status"] = $Status
            }
        }

        if($PSBoundParameters.ContainsKey("SurveyEnabled")) {
            $Filter["survey_enabled"] = $SurveyEnabled
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "workflow_job_templates" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "workflow_job_templates" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToWorkflowJobTemplate($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            $CacheKey = "workflow_job_templates/$($AnsibleObject.Id)"
            Write-Debug "[Get-AnsibleWorkflowJobTemplate] Caching $($AnsibleObject.Url) as $CacheKey"
            $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
            #Add to cache before filling in child objects to prevent recursive loop
            if($AnsibleObject.Inventory) {
                $AnsibleObject.Inventory = Get-AnsibleInventory -Id $AnsibleObject.Inventory -AnsibleTower $AnsibleTower -UseCache
            }
            if($AnsibleObject.Organization) {
                $AnsibleObject.Organization = Get-AnsibleOrganization -Id $AnsibleObject.Organization -AnsibleTower $AnsibleTower -UseCache
            }
            $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}
