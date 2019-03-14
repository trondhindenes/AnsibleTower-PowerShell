<#
.DESCRIPTION
Updates an existing project in Ansible Tower.

.PARAMETER Id
The ID of the project to update

.PARAMETER InputObject
The object to update

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

.PARAMETER ScmType
Specifies the source control system used to store the project.

.PARAMETER ScmUpdateCacheTimeout
The number of seconds after the last project update ran that a newproject update will be launched as a job dependency.

.PARAMETER ScmUpdateOnLaunch
Update the project when a job is launched that uses the project.

.PARAMETER ScmUrl
The location where the project is stored.

.PARAMETER Timeout
The amount of time (in seconds) to run before the task is canceled.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Set-AnsibleProject {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [OutputType([AnsibleTower.Project])]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByObject')]
        [AnsibleTower.Project]$InputObject,

        [Object]$Credential,

        [String]$CustomVirtualenv,

        [String]$Description,

        [String]$LocalPath,

        [Parameter(Position=1)]
        [String]$Name,

        [Parameter(Position=3)]
        [Object]$Organization,

        [String]$ScmBranch,

        [switch]$ScmClean,

        [switch]$ScmDeleteOnUpdate,

        [string]$ScmType,

        [Int32]$ScmUpdateCacheTimeout,

        [switch]$ScmUpdateOnLaunch,

        [String]$ScmUrl,

        [Int32]$Timeout,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    Process {
        if($Id) {
            $ThisObject = Get-AnsibleProject -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $AnsibleTower = $InputObject.AnsibleTower
            $ThisObject = Get-AnsibleProject -Id $InputObject.Id -AnsibleTower $AnsibleTower
        }

        if($Credential) {
            $ThisObject.credential = $Credential
        }

        if($CustomVirtualenv) {
            $ThisObject.custom_virtualenv = $CustomVirtualenv
        }

        if($Description) {
            $ThisObject.description = $Description
        }

        if($LocalPath) {
            $ThisObject.local_path = $LocalPath
        }

        if($Name) {
            $ThisObject.name = $Name
        }

        if($Organization) {
            $ThisObject.organization = $Organization
        }

        if($ScmBranch) {
            $ThisObject.scm_branch = $ScmBranch
        }

        if($ScmClean) {
            $ThisObject.scm_clean = $ScmClean
        }

        if($ScmDeleteOnUpdate) {
            $ThisObject.scm_delete_on_update = $ScmDeleteOnUpdate
        }

        if($ScmType) {
            $ThisObject.scm_type = $ScmType
        }

        if($ScmUpdateCacheTimeout) {
            $ThisObject.scm_update_cache_timeout = $ScmUpdateCacheTimeout
        }

        if($ScmUpdateOnLaunch) {
            $ThisObject.scm_update_on_launch = $ScmUpdateOnLaunch
        }

        if($ScmUrl) {
            $ThisObject.scm_url = $ScmUrl
        }

        if($Timeout) {
            $ThisObject.timeout = $Timeout
        }

        if($PSCmdlet.ShouldProcess($AnsibleTower, "Update projects $($ThisObject.Id)")) {
            $Result = Invoke-PutAnsibleInternalJsonResult -ItemType projects -InputObject $ThisObject -AnsibleTower $AnsibleTower
             if($Result) {
                $JsonString = ConvertTo-Json -InputObject $Result
                $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToProject($JsonString)
                $AnsibleObject.AnsibleTower = $AnsibleTower
                $AnsibleObject
            }
        }
    }
}
