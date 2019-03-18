<#
.DESCRIPTION
Updates an existing credential in Ansible Tower.

.PARAMETER Id
The ID of the credentials to update

.PARAMETER InputObject
The object to update

.PARAMETER CredentialType
Specify the type of credential you want to create. Refer to the Ansible Tower documentation for details on each type.

.PARAMETER Description
Optional description of this credential.

.PARAMETER Inputs
Enter inputs using either JSON or YAML syntax. Use the radio button to toggle between the two. Refer to the Ansible Tower documentation for example syntax.

.PARAMETER Name
Name of this credential.

.PARAMETER Organization
Inherit permissions from organization roles.

.PARAMETER PassThru
Outputs the updated objects to the pipeline.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Set-AnsibleCredential {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [OutputType([AnsibleTower.Credential])]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', 'CredentialType')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByObject')]
        [AnsibleTower.Credential]$InputObject,

        [Object]$CredentialType,

        [Parameter(Position=2)]
        [String]$Description,

        [hashtable]$Inputs,

        [Parameter(Position=1)]
        [String]$Name,

        [Object]$Organization,

        [switch]$PassThru,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    Process {
        if($Id) {
            $ThisObject = Get-AnsibleCredential -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $AnsibleTower = $InputObject.AnsibleTower
            # Get a new instance to avoid modifing the passed in user object
            $ThisObject = Get-AnsibleCredential -Id $InputObject.Id -AnsibleTower $AnsibleTower
        }

        if($PSBoundParameters.ContainsKey('CredentialType')) {
            $ThisObject.credential_type = $CredentialType
        }

        if($PSBoundParameters.ContainsKey('Description')) {
            $ThisObject.description = $Description
        }

        if($PSBoundParameters.ContainsKey('Inputs')) {
            $ThisObject.inputs = $Inputs
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

        if($PSCmdlet.ShouldProcess($AnsibleTower, "Update credentials $($ThisObject.Id)")) {
            $Result = Invoke-PutAnsibleInternalJsonResult -ItemType credentials -InputObject $ThisObject -AnsibleTower $AnsibleTower
            if($Result) {
                $JsonString = ConvertTo-Json -InputObject $Result
                $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToCredential($JsonString)
                $AnsibleObject.AnsibleTower = $AnsibleTower
                if($PassThru) {
                    $AnsibleObject
                }
            }
        }
    }
}
