<#
.DESCRIPTION
  Gets projects from ansible tower.

.PARAMETER CustomVirtualenv
  Local absolute file path containing a custom Python virtualenv to use

.PARAMETER Description
  Optional description of this project.

.PARAMETER LocalPath
  Local path (relative to PROJECTS_ROOT) containing playbooks and related files for this project.

.PARAMETER Name
  Name of this project.

.PARAMETER ScmBranch
  Specific branch, tag or commit to checkout.

.PARAMETER ScmClean
  Discard any local changes before syncing the project.

.PARAMETER ScmDeleteOnUpdate
  Delete the project before syncing.

.PARAMETER ScmRevision
  The last revision fetched by a project update

.PARAMETER ScmType
  Specifies the source control system used to store the project.

.PARAMETER ScmUpdateOnLaunch
  Update the project when a job is launched that uses the project.

.PARAMETER ScmUrl
  The location where the project is stored.

.PARAMETER Id
  The ID of a specific AnsibleProject to get

.PARAMETER AnsibleTower
  The Ansibl Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleProject {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [OutputType([AnsibleTower.Project])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "Credential")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUsePSCredentialType","")]
    param(
        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$Credential,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$CustomVirtualenv,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(ParameterSetName='PropertyFilter')]
        [bool]$LastJobFailed,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$LocalPath,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$Organization,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ScmBranch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [bool]$ScmClean,

        [Parameter(ParameterSetName='PropertyFilter')]
        [bool]$ScmDeleteOnUpdate,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ScmRevision,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('','git','hg','svn','insights')]
        [string]$ScmType,

        [Parameter(ParameterSetName='PropertyFilter')]
        [bool]$ScmUpdateOnLaunch,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$ScmUrl,

        [Parameter(ParameterSetName='PropertyFilter')]
        [ValidateSet('new','pending','waiting','running','successful','failed','error','canceled','never updated','ok','missing')]
        [string]$Status,

        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(ParameterSetName='ById')]
        [Switch]$UseCache,

        [Object]$AnsibleTower = $Global:DefaultAnsibleTower
    )
    end {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("Credential")) {
            switch($Credential.GetType().Fullname) {
                "AnsibleTower.Credential" {
                    $Filter["credential"] = $Credential.Id
                }
                "System.Int32" {
                    $Filter["credential"] = $Credential
                }
                "System.String" {
                    $Filter["credential__name"] = $Credential
                }
                default {
                    Write-Error "Unknown type passed as -Credential ($_).  Supported values are String, Int32, and AnsibleTower.Credential." -ErrorAction Stop
                    return
                }
            }
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

        if($PSBoundParameters.ContainsKey("LastJobFailed")) {
            $Filter["last_job_failed"] = $LastJobFailed
        }

        if($PSBoundParameters.ContainsKey("LocalPath")) {
            if($LocalPath.Contains("*")) {
                $Filter["local_path__iregex"] = $LocalPath.Replace("*", ".*")
            } else {
                $Filter["local_path"] = $LocalPath
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

        if($PSBoundParameters.ContainsKey("ScmBranch")) {
            if($ScmBranch.Contains("*")) {
                $Filter["scm_branch__iregex"] = $ScmBranch.Replace("*", ".*")
            } else {
                $Filter["scm_branch"] = $ScmBranch
            }
        }

        if($PSBoundParameters.ContainsKey("ScmClean")) {
            $Filter["scm_clean"] = $ScmClean
        }

        if($PSBoundParameters.ContainsKey("ScmDeleteOnUpdate")) {
            $Filter["scm_delete_on_update"] = $ScmDeleteOnUpdate
        }

        if($PSBoundParameters.ContainsKey("ScmRevision")) {
            if($ScmRevision.Contains("*")) {
                $Filter["scm_revision__iregex"] = $ScmRevision.Replace("*", ".*")
            } else {
                $Filter["scm_revision"] = $ScmRevision
            }
        }

        if($PSBoundParameters.ContainsKey("ScmType")) {
            if($ScmType.Contains("*")) {
                $Filter["scm_type__iregex"] = $ScmType.Replace("*", ".*")
            } else {
                $Filter["scm_type"] = $ScmType
            }
        }

        if($PSBoundParameters.ContainsKey("ScmUpdateOnLaunch")) {
            $Filter["scm_update_on_launch"] = $ScmUpdateOnLaunch
        }

        if($PSBoundParameters.ContainsKey("ScmUrl")) {
            if($ScmUrl.Contains("*")) {
                $Filter["scm_url__iregex"] = $ScmUrl.Replace("*", ".*")
            } else {
                $Filter["scm_url"] = $ScmUrl
            }
        }

        if($PSBoundParameters.ContainsKey("Status")) {
            if($Status.Contains("*")) {
                $Filter["status__iregex"] = $Status.Replace("*", ".*")
            } else {
                $Filter["status"] = $Status
            }
        }

        if($id) {
            $CacheKey = "projects/$Id"
            $AnsibleObject = $AnsibleTower.Cache.Get($CacheKey)
            if($UseCache -and $AnsibleObject) {
                Write-Debug "[Get-AnsibleProject] Returning $($AnsibleObject.Url) from cache"
                $AnsibleObject
                return
            } else {
                $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "projects" -Id $Id -AnsibleTower $AnsibleTower
            }
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "projects" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToproject($JsonString)
            $CacheKey = "projects/$($AnsibleObject.Id)"
            Write-Debug "[Get-AnsibleProject] Caching $($AnsibleObject.Url) as $CacheKey"
            $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
            #Add to cache before filling in child objects to prevent recursive loop
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Debug "[Get-AnsibleProject] Returning $($AnsibleObject.Url)"
            $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}