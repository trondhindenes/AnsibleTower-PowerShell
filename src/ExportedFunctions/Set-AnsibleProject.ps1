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

.PARAMETER PassThru
Outputs the updated objects to the pipeline.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Set-AnsibleProject {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [OutputType([AnsibleTower.Project])]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', 'Credential')]
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

        [switch]$PassThru,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    Process {
        if($Id) {
            $ThisObject = Get-AnsibleProject -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $AnsibleTower = $InputObject.AnsibleTower
            $ThisObject = Get-AnsibleProject -Id $InputObject.Id -AnsibleTower $AnsibleTower
        }

        if($PSBoundParameters.ContainsKey('Credential')) {
            switch($Credential.GetType().Fullname) {
                "System.Int32" {
                    $CredentialId = $Credential
                }
                "System.String" {
                    $CredentialId = (Get-AnsibleCredential -Name $Credential -AnsibleTower $AnsibleTower).Id
                }
                "AnsibleTower.Credential" {
                    $CredentialId = $Credential.id
                }
                default {
                    Write-Error "Unknown type passed as -Credential ($_).  Supported values are String, Int32, and AnsibleTower.Credential."
                    return
                }
            }
            $ThisObject.credential = $CredentialId
        }

        if($PSBoundParameters.ContainsKey('CustomVirtualenv')) {
            $ThisObject.custom_virtualenv = $CustomVirtualenv
        }

        if($PSBoundParameters.ContainsKey('Description')) {
            $ThisObject.description = $Description
        }

        if($PSBoundParameters.ContainsKey('LocalPath')) {
            $ThisObject.local_path = $LocalPath
        }

        if($PSBoundParameters.ContainsKey('Name')) {
            $ThisObject.name = $Name
        }

        if($PSBoundParameters.ContainsKey('Organization')) {
            switch($Organization.GetType().Fullname) {
                "System.Int32" {
                    $OrganizationId = $Organization
                }
                "System.String" {
                    $OrganizationId = (Get-AnsibleOrganization -Name $Organization -AnsibleTower $AnsibleTower).Id
                }
                "AnsibleTower.Organization" {
                    $OrganizationId = $Organization.id
                }
                default {
                    Write-Error "Unknown type passed as -Organization ($_).  Supported values are String, Int32, and AnsibleTower.Organization."
                    return
                }
            }
            $ThisObject.organization = $OrganizationId
        }

        if($PSBoundParameters.ContainsKey('ScmBranch')) {
            $ThisObject.scm_branch = $ScmBranch
        }

        if($PSBoundParameters.ContainsKey('ScmClean')) {
            $ThisObject.scm_clean = $ScmClean
        }

        if($PSBoundParameters.ContainsKey('ScmDeleteOnUpdate')) {
            $ThisObject.scm_delete_on_update = $ScmDeleteOnUpdate
        }

        if($PSBoundParameters.ContainsKey('ScmType')) {
            $ThisObject.scm_type = $ScmType
        }

        if($PSBoundParameters.ContainsKey('ScmUpdateCacheTimeout')) {
            $ThisObject.scm_update_cache_timeout = $ScmUpdateCacheTimeout
        }

        if($PSBoundParameters.ContainsKey('ScmUpdateOnLaunch')) {
            $ThisObject.scm_update_on_launch = $ScmUpdateOnLaunch
        }

        if($PSBoundParameters.ContainsKey('ScmUrl')) {
            $ThisObject.scm_url = $ScmUrl
        }

        if($PSBoundParameters.ContainsKey('Timeout')) {
            $ThisObject.timeout = $Timeout
        }

        if($PSCmdlet.ShouldProcess($AnsibleTower, "Update projects $($ThisObject.Id)")) {
            $Result = Invoke-PutAnsibleInternalJsonResult -ItemType projects -InputObject $ThisObject -AnsibleTower $AnsibleTower
            if($Result) {
                $JsonString = ConvertTo-Json -InputObject $Result
                $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToProject($JsonString)
                $AnsibleObject.AnsibleTower = $AnsibleTower
                if($PassThru) {
                    $AnsibleObject
                }
            }
        }
    }
}
