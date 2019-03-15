<#
.DESCRIPTION
Updates an existing user in Ansible Tower.

.PARAMETER Id
The ID of the  to update

.PARAMETER InputObject
The object to update

.PARAMETER IsSuperuser
Designates that this user has all permissions without explicitly assigning them.

.PARAMETER Password
Write-only field used to change the password.

.PARAMETER Username
Required. 150 characters or fewer. Letters, digits and @/./+/-/_ only.

.PARAMETER PassThru
Outputs the updated objects to the pipeline.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Set-AnsibleUser {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [OutputType([AnsibleTower.User])]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingUserNameAndPassWordParams', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByObject')]
        [AnsibleTower.User]$InputObject,

        [Parameter(Position=4)]
        [String]$Email,

        [Parameter(Position=2)]
        [String]$FirstName,

        [switch]$IsSuperuser,

        [switch]$IsSystemAuditor,

        [Parameter(Position=3)]
        [String]$LastName,

        [String]$Password,

        [Parameter(Position=1)]
        [String]$Username,

        [switch]$PassThru,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    Process {
        if($Id) {
            $ThisObject = Get-AnsibleUser -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $AnsibleTower = $InputObject.AnsibleTower
            # Get a new instance to avoid modifing the passed in user object
            $ThisObject = Get-AnsibleUser -Id $InputObject.Id -AnsibleTower $AnsibleTower
        }

        if($PSBoundParameters.ContainsKey('Email')) {
            $ThisObject.email = $Email
        }

        if($PSBoundParameters.ContainsKey('FirstName')) {
            $ThisObject.first_name = $FirstName
        }

        if($PSBoundParameters.ContainsKey('IsSuperuser')) {
            $ThisObject.is_superuser = $IsSuperuser
        }

        if($PSBoundParameters.ContainsKey('IsSystemAuditor')) {
            $ThisObject.is_system_auditor = $IsSystemAuditor
        }

        if($PSBoundParameters.ContainsKey('LastName')) {
            $ThisObject.last_name = $LastName
        }

        if($PSBoundParameters.ContainsKey('Password')) {
            $ThisObject.password = $Password
        }

        if($PSBoundParameters.ContainsKey('Username')) {
            $ThisObject.username = $Username
        }

        if($PSCmdlet.ShouldProcess($AnsibleTower, "Update user $($ThisObject.Id)")) {
            $Result = Invoke-PutAnsibleInternalJsonResult -ItemType users -InputObject $ThisObject -AnsibleTower $AnsibleTower
            if($Result) {
                $JsonString = ConvertTo-Json -InputObject $Result
                $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToUser($JsonString)
                $AnsibleObject.AnsibleTower = $AnsibleTower
                if($PassThru) {
                    $AnsibleObject
                }
            }
        }
    }
}
