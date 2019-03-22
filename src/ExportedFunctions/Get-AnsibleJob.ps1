<#
.DESCRIPTION
Gets job status from Ansible Tower.

.PARAMETER ControllerNode
The instance that managed the isolated execution environment.

.PARAMETER Description
Optional description of this job.

.PARAMETER ExecutionNode
The node the job executed on.

.PARAMETER InstanceGroup
The Rampart/Instance group the job was run under

.PARAMETER JobExplanation
A status field to indicate the state of the job if it wasn't able to run and capture stdout

.PARAMETER Name
Name of this job.

.PARAMETER ScmRevision
The SCM Revision from the Project used for this job, if available

.PARAMETER MaxResults
The maximum number of job objects to return from Ansible Tower.

.PARAMETER Id
The ID of a specific AnsibleJob to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleJob {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ControllerNode,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ExecutionNode,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ExtraVars,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$InstanceGroup,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [Object]$Inventory,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$JobExplanation,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$JobTags,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$JobTemplate,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('run','check')]
        [string]$JobType,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('manual','relaunch','callback','scheduled','dependency','workflow','sync','scm')]
        [string]$LaunchType,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Limit,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Playbook,

        [Parameter(Position=3,ParameterSetName='PropertyFilter')]
        [Object]$Project,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ScmRevision,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$SkipTags,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('new','pending','waiting','running','successful','failed','error','canceled')]
        [string]$Status,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$UnifiedJobTemplate,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet(0,1,2,3,4,5)]
        [string]$Verbosity,

        [Int32]$MaxResults = 1000,

        [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        $Filter = @{
            order_by="-started"
        }

        if($PSBoundParameters.ContainsKey("ControllerNode")) {
            if($ControllerNode.Contains("*")) {
                $Filter["controller_node__iregex"] = $ControllerNode.Replace("*", ".*")
            } else {
                $Filter["controller_node"] = $ControllerNode
            }
        }

        if($PSBoundParameters.ContainsKey("Description")) {
            if($Description.Contains("*")) {
                $Filter["description__iregex"] = $Description.Replace("*", ".*")
            } else {
                $Filter["description"] = $Description
            }
        }

        if($PSBoundParameters.ContainsKey("ExecutionNode")) {
            if($ExecutionNode.Contains("*")) {
                $Filter["execution_node__iregex"] = $ExecutionNode.Replace("*", ".*")
            } else {
                $Filter["execution_node"] = $ExecutionNode
            }
        }

        if($PSBoundParameters.ContainsKey("ExtraVars")) {
            if($ExtraVars.Contains("*")) {
                $Filter["extra_vars__iregex"] = $ExtraVars.Replace("*", ".*")
            } else {
                $Filter["extra_vars"] = $ExtraVars
            }
        }

        if($PSBoundParameters.ContainsKey("InstanceGroup")) {
            switch($InstanceGroup.GetType().Fullname) {
                "AnsibleTower.InstanceGroup" {
                    $Filter["instance_group"] = $InstanceGroup.Id
                }
                "System.Int32" {
                    $Filter["instance_group"] = $InstanceGroup
                }
                "System.String" {
                    $Filter["instance_group__name"] = $InstanceGroup
                }
                default {
                    Write-Error "Unknown type passed as -InstanceGroup ($_).  Supported values are String, Int32, and AnsibleTower.InstanceGroup." -ErrorAction Stop
                    return
                }
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

        if($PSBoundParameters.ContainsKey("JobExplanation")) {
            if($JobExplanation.Contains("*")) {
                $Filter["job_explanation__iregex"] = $JobExplanation.Replace("*", ".*")
            } else {
                $Filter["job_explanation"] = $JobExplanation
            }
        }

        if($PSBoundParameters.ContainsKey("JobTags")) {
            if($JobTags.Contains("*")) {
                $Filter["job_tags__iregex"] = $JobTags.Replace("*", ".*")
            } else {
                $Filter["job_tags"] = $JobTags
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

        if($PSBoundParameters.ContainsKey("JobType")) {
            if($JobType.Contains("*")) {
                $Filter["job_type__iregex"] = $JobType.Replace("*", ".*")
            } else {
                $Filter["job_type"] = $JobType
            }
        }

        if($PSBoundParameters.ContainsKey("LaunchType")) {
            if($LaunchType.Contains("*")) {
                $Filter["launch_type__iregex"] = $LaunchType.Replace("*", ".*")
            } else {
                $Filter["launch_type"] = $LaunchType
            }
        }

        if($PSBoundParameters.ContainsKey("Limit")) {
            if($Limit.Contains("*")) {
                $Filter["limit__iregex"] = $Limit.Replace("*", ".*")
            } else {
                $Filter["limit"] = $Limit
            }
        }

        if($PSBoundParameters.ContainsKey("Name")) {
            if($Name.Contains("*")) {
                $Filter["name__iregex"] = $Name.Replace("*", ".*")
            } else {
                $Filter["name"] = $Name
            }
        }

        if($PSBoundParameters.ContainsKey("Playbook")) {
            if($Playbook.Contains("*")) {
                $Filter["playbook__iregex"] = $Playbook.Replace("*", ".*")
            } else {
                $Filter["playbook"] = $Playbook
            }
        }

        if($PSBoundParameters.ContainsKey("Project")) {
            switch($Project.GetType().Fullname) {
                "AnsibleTower.Project" {
                    $Filter["project"] = $Project.Id
                }
                "System.Int32" {
                    $Filter["project"] = $Project
                }
                "System.String" {
                    $Filter["project__name"] = $Project
                }
                default {
                    Write-Error "Unknown type passed as -Project ($_).  Supported values are String, Int32, and AnsibleTower.Project." -ErrorAction Stop
                    return
                }
            }
        }

        if($PSBoundParameters.ContainsKey("ScmRevision")) {
            if($ScmRevision.Contains("*")) {
                $Filter["scm_revision__iregex"] = $ScmRevision.Replace("*", ".*")
            } else {
                $Filter["scm_revision"] = $ScmRevision
            }
        }

        if($PSBoundParameters.ContainsKey("SkipTags")) {
            if($SkipTags.Contains("*")) {
                $Filter["skip_tags__iregex"] = $SkipTags.Replace("*", ".*")
            } else {
                $Filter["skip_tags"] = $SkipTags
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

        if($PSBoundParameters.ContainsKey("Verbosity")) {
            if($Verbosity.Contains("*")) {
                $Filter["verbosity__iregex"] = $Verbosity.Replace("*", ".*")
            } else {
                $Filter["verbosity"] = $Verbosity
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "jobs" -Id $Id -AnsibleTower $AnsibleTower -MaxResults $MaxResults
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "jobs" -Filter $Filter -AnsibleTower $AnsibleTower -MaxResults $MaxResults
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseTojob($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            if($AnsibleObject.Inventory) {
                $AnsibleObject.Inventory = Get-AnsibleInventory -Id $AnsibleObject.Inventory -AnsibleTower $AnsibleTower -UseCache
            }
            if($AnsibleObject.Project) {
                $AnsibleObject.Project = Get-AnsibleProject -Id $AnsibleObject.Project -AnsibleTower $AnsibleTower -UseCache
            }
            if($AnsibleObject.job_template) {
                $AnsibleObject.job_template = Get-AnsibleJobTemplate -Id $AnsibleObject.job_template -AnsibleTower $AnsibleTower -UseCache
            }
            Write-Output $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}