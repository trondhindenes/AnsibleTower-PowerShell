<#
.DESCRIPTION
Updates an existing host in Ansible Tower.

.PARAMETER Id
The ID of the hosts to update

.PARAMETER InputObject
The object to update

.PARAMETER Description
Optional description of this host.

.PARAMETER Enabled
Is this host online and available for running jobs?

.PARAMETER InstanceId
The value used by the remote inventory source to uniquely identify the host

.PARAMETER Name
Name of this host.

.PARAMETER Variables
Host variables in JSON or YAML format.

.PARAMETER PassThru
Outputs the updated objects to the pipeline.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Set-AnsibleHost {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [OutputType([AnsibleTower.Host])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByObject')]
        [AnsibleTower.Host]$InputObject,

        [Parameter(Position=2)]
        [String]$Description,

        [switch]$Enabled,

        [String]$InstanceId,

        [Parameter(Position=1)]
        [String]$Name,

        [Parameter(Position=3)]
        [String]$Variables,

        [switch]$PassThru,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    Process {
        if($Id) {
            $ThisObject = Get-AnsibleHost -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $AnsibleTower = $InputObject.AnsibleTower
            # Get a new instance to avoid modifing the passed in user object
            $ThisObject = Get-AnsibleHost -Id $InputObject.Id -AnsibleTower $AnsibleTower
        }

        if($PSBoundParameters.ContainsKey('Description')) {
            $ThisObject.description = $Description
        }

        if($PSBoundParameters.ContainsKey('Enabled')) {
            $ThisObject.enabled = $Enabled
        }

        if($PSBoundParameters.ContainsKey('InstanceId')) {
            $ThisObject.instance_id = $InstanceId
        }

        if($PSBoundParameters.ContainsKey('Name')) {
            $ThisObject.name = $Name
        }

        if($PSBoundParameters.ContainsKey('Variables')) {
            $ThisObject.variables = $Variables
        }

        if($PSCmdlet.ShouldProcess($AnsibleTower, "Update hosts $($ThisObject.Id)")) {
            $Result = Invoke-PutAnsibleInternalJsonResult -ItemType hosts -InputObject $ThisObject -AnsibleTower $AnsibleTower
            if($Result) {
                $JsonString = ConvertTo-Json -InputObject $Result
                $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToHost($JsonString)
                $AnsibleObject.AnsibleTower = $AnsibleTower
                $CacheKey = "hosts/$($AnsibleObject.Id)"
                $AnsibleTower.Cache.Remove($CacheKey) > $null
                $AnsibleObject = Add-RelatedObject -InputObject $AnsibleObject -ItemType "hosts" -RelatedType "groups" -RelationProperty "Groups" -RelationCommand (Get-Command Get-AnsibleGroup) -PassThru
                if($PassThru) {
                    $AnsibleObject
                }
            }
        }
    }
}
