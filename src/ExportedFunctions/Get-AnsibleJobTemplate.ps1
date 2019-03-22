<#
.DESCRIPTION
Gets job templates defined in Ansible Tower.

.PARAMETER CustomVirtualenv
Local absolute file path containing a custom Python virtualenv to use

.PARAMETER Description
Optional description of this job template.

.PARAMETER DiffMode
If enabled, textual changes made to any templated files on the host are shown in the standard output

.PARAMETER Name
Name of this job template.

.PARAMETER UseFactCache
If enabled, Tower will act as an Ansible Fact Cache Plugin; persisting facts at the end of a playbook run to the database and caching facts for use by Ansible.

.PARAMETER Id
The ID of a specific AnsibleJobTemplate to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleJobTemplate {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    [OutputType([AnsibleTower.JobTemplate])]
    Param (
        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AllowSimultaneous,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskCredentialOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskDiffModeOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskInventoryOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskJobTypeOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskLimitOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskSkipTagsOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskTagsOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskVariablesOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$AskVerbosityOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$BecomeEnabled,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$CustomVirtualenv,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$DiffMode,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ExtraVars,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$ForceHandlers,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$HostConfigKey,

        [Parameter(Position=3,ParameterSetName='PropertyFilter')]
        [Object]$Inventory,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$JobTags,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('run','check')]
        [string]$JobType,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$LastJobFailed,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Limit,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(Position=4,ParameterSetName='PropertyFilter')]
        [String]$Playbook,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [Object]$Project,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$SkipTags,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$StartAtTask,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('new','pending','waiting','running','successful','failed','error','canceled','never updated')]
        [string]$Status,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$SurveyEnabled,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$UseFactCache,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet(0,1,2,3,4,5)]
        [string]$Verbosity,

        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(ParameterSetName='ById')]
        [Switch]$UseCache,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    end {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("AllowSimultaneous")) {
            $Filter["allow_simultaneous"] = $AllowSimultaneous
        }

        if($PSBoundParameters.ContainsKey("AskCredentialOnLaunch")) {
            $Filter["ask_credential_on_launch"] = $AskCredentialOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskDiffModeOnLaunch")) {
            $Filter["ask_diff_mode_on_launch"] = $AskDiffModeOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskInventoryOnLaunch")) {
            $Filter["ask_inventory_on_launch"] = $AskInventoryOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskJobTypeOnLaunch")) {
            $Filter["ask_job_type_on_launch"] = $AskJobTypeOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskLimitOnLaunch")) {
            $Filter["ask_limit_on_launch"] = $AskLimitOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskSkipTagsOnLaunch")) {
            $Filter["ask_skip_tags_on_launch"] = $AskSkipTagsOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskTagsOnLaunch")) {
            $Filter["ask_tags_on_launch"] = $AskTagsOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskVariablesOnLaunch")) {
            $Filter["ask_variables_on_launch"] = $AskVariablesOnLaunch
        }

        if($PSBoundParameters.ContainsKey("AskVerbosityOnLaunch")) {
            $Filter["ask_verbosity_on_launch"] = $AskVerbosityOnLaunch
        }

        if($PSBoundParameters.ContainsKey("BecomeEnabled")) {
            $Filter["become_enabled"] = $BecomeEnabled
        }

        if($PSBoundParameters.ContainsKey("CustomVirtualenv")) {
            if($CustomVirtualenv.Contains("*")) {
                $Filter["custom_virtualenv__iregex"] = $CustomVirtualenv.Replace("*", ".*")
            } else {
                $Filter["custom_virtualenv"] = $CustomVirtualenv
            }
        }

        if($PSBoundParameters.ContainsKey("Description")) {
            if($Description.Contains("*")) {
                $Filter["description__iregex"] = $Description.Replace("*", ".*")
            } else {
                $Filter["description"] = $Description
            }
        }

        if($PSBoundParameters.ContainsKey("DiffMode")) {
            $Filter["diff_mode"] = $DiffMode
        }

        if($PSBoundParameters.ContainsKey("ExtraVars")) {
            if($ExtraVars.Contains("*")) {
                $Filter["extra_vars__iregex"] = $ExtraVars.Replace("*", ".*")
            } else {
                $Filter["extra_vars"] = $ExtraVars
            }
        }

        if($PSBoundParameters.ContainsKey("ForceHandlers")) {
            $Filter["force_handlers"] = $ForceHandlers
        }

        if($PSBoundParameters.ContainsKey("HostConfigKey")) {
            if($HostConfigKey.Contains("*")) {
                $Filter["host_config_key__iregex"] = $HostConfigKey.Replace("*", ".*")
            } else {
                $Filter["host_config_key"] = $HostConfigKey
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

        if($PSBoundParameters.ContainsKey("JobTags")) {
            if($JobTags.Contains("*")) {
                $Filter["job_tags__iregex"] = $JobTags.Replace("*", ".*")
            } else {
                $Filter["job_tags"] = $JobTags
            }
        }

        if($PSBoundParameters.ContainsKey("JobType")) {
            if($JobType.Contains("*")) {
                $Filter["job_type__iregex"] = $JobType.Replace("*", ".*")
            } else {
                $Filter["job_type"] = $JobType
            }
        }

        if($PSBoundParameters.ContainsKey("LastJobFailed")) {
            $Filter["last_job_failed"] = $LastJobFailed
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

        if($PSBoundParameters.ContainsKey("SkipTags")) {
            if($SkipTags.Contains("*")) {
                $Filter["skip_tags__iregex"] = $SkipTags.Replace("*", ".*")
            } else {
                $Filter["skip_tags"] = $SkipTags
            }
        }

        if($PSBoundParameters.ContainsKey("StartAtTask")) {
            if($StartAtTask.Contains("*")) {
                $Filter["start_at_task__iregex"] = $StartAtTask.Replace("*", ".*")
            } else {
                $Filter["start_at_task"] = $StartAtTask
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

        if($PSBoundParameters.ContainsKey("UseFactCache")) {
            $Filter["use_fact_cache"] = $UseFactCache
        }

        if($PSBoundParameters.ContainsKey("Verbosity")) {
            if($Verbosity.Contains("*")) {
                $Filter["verbosity__iregex"] = $Verbosity.Replace("*", ".*")
            } else {
                $Filter["verbosity"] = $Verbosity
            }
        }

        if($id) {
            $CacheKey = "job_templates/$Id"
            $AnsibleObject = $AnsibleTower.Cache.Get($CacheKey)
            if($UseCache -and $AnsibleObject) {
                Write-Debug "[Get-AnsibleJobTemplate] Returning $($AnsibleObject.Url) from cache"
                $AnsibleObject
                return
            } else {
                $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "job_templates" -Id $Id -AnsibleTower $AnsibleTower
            }
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "job_templates" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToJobTemplate($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            $CacheKey = "job_templates/$($AnsibleObject.Id)"
            Write-Debug "[Get-AnsibleJobTemplate] Caching $($AnsibleObject.Url) as $CacheKey"
            $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
            #Add to cache before filling in child objects to prevent recursive loop
            if($AnsibleObject.Inventory) {
                $AnsibleObject.Inventory = Get-AnsibleInventory -Id $AnsibleObject.Inventory -AnsibleTower $AnsibleTower -UseCache
            }
            if($AnsibleObject.Project) {
                $AnsibleObject.Project = Get-AnsibleProject -Id $AnsibleObject.Project -AnsibleTower $AnsibleTower -UseCache
            }
            if($AnsibleObject.Credential) {
                $AnsibleObject.Credential = Get-AnsibleCredential -Id $AnsibleObject.Credential -AnsibleTower $AnsibleTower -UseCache
            }
            $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}