<#
.DESCRIPTION
Gets workflow jobs defined in Ansible Tower.

.PARAMETER Description
Optional description of this workflow job.

.PARAMETER JobExplanation
A status field to indicate the state of the job if it wasn't able to run and capture stdout

.PARAMETER JobTemplate
If automatically created for a sliced job run, the job template the workflow job was created from.

.PARAMETER Name
Name of this workflow job.

.PARAMETER Id
The ID of a specific AnsibleWorkflowJob to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleWorkflowJob {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AllowSimultaneous,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ExtraVars,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$Failed,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [Object]$Inventory,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$IsSlicedJob,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$JobExplanation,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$JobTemplate,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('manual','relaunch','callback','scheduled','dependency','workflow','sync','scm')]
        [string]$LaunchType,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('new','pending','waiting','running','successful','failed','error','canceled')]
        [string]$Status,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$UnifiedJobTemplate,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$WorkflowJobTemplate,

        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    End {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("AllowSimultaneous")) {
            $Filter["allow_simultaneous"] = $AllowSimultaneous
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

        if($PSBoundParameters.ContainsKey("Failed")) {
            $Filter["failed"] = $Failed
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

        if($PSBoundParameters.ContainsKey("IsSlicedJob")) {
            $Filter["is_sliced_job"] = $IsSlicedJob
        }

        if($PSBoundParameters.ContainsKey("JobExplanation")) {
            if($JobExplanation.Contains("*")) {
                $Filter["job_explanation__iregex"] = $JobExplanation.Replace("*", ".*")
            } else {
                $Filter["job_explanation"] = $JobExplanation
            }
        }

        if($PSBoundParameters.ContainsKey("JobTemplate")) {
            switch($JobTemplate.GetType().Fullname) {
                "AnsibleTower.JobTemplate" {
                    $Filter["job_template"] = $JobTemplate.Id
                }
                "System.Int32" {
                    $Filter["job_template"] = $JobTemplate
                }
                "System.String" {
                    $Filter["job_template__name"] = $JobTemplate
                }
                default {
                    Write-Error "Unknown type passed as -JobTemplate ($_).  Supported values are String, Int32, and AnsibleTower.JobTemplate." -ErrorAction Stop
                    return
                }
            }
        }

        if($PSBoundParameters.ContainsKey("LaunchType")) {
            if($LaunchType.Contains("*")) {
                $Filter["launch_type__iregex"] = $LaunchType.Replace("*", ".*")
            } else {
                $Filter["launch_type"] = $LaunchType
            }
        }

        if($PSBoundParameters.ContainsKey("Name")) {
            if($Name.Contains("*")) {
                $Filter["name__iregex"] = $Name.Replace("*", ".*")
            } else {
                $Filter["name"] = $Name
            }
        }

        if($PSBoundParameters.ContainsKey("Status")) {
            if($Status.Contains("*")) {
                $Filter["status__iregex"] = $Status.Replace("*", ".*")
            } else {
                $Filter["status"] = $Status
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

        if($PSBoundParameters.ContainsKey("WorkflowJobTemplate")) {
            switch($WorkflowJobTemplate.GetType().Fullname) {
                "AnsibleTower.WorkflowJobTemplate" {
                    $Filter["workflow_job_template"] = $WorkflowJobTemplate.Id
                }
                "System.Int32" {
                    $Filter["workflow_job_template"] = $WorkflowJobTemplate
                }
                "System.String" {
                    $Filter["workflow_job_template__name"] = $WorkflowJobTemplate
                }
                default {
                    Write-Error "Unknown type passed as -WorkflowJobTemplate ($_).  Supported values are String, Int32, and AnsibleTower.WorkflowJobTemplate." -ErrorAction Stop
                    return
                }
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "workflow_jobs" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "workflow_jobs" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToWorkflowJob($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}
