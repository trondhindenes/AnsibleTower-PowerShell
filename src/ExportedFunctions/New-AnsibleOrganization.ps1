<#
.DESCRIPTION
Creates a new organization in Ansible Tower.

.PARAMETER CustomVirtualenv
Local absolute file path containing a custom Python virtualenv to use

.PARAMETER Description
Optional description of this organization.

.PARAMETER Name
Name of this organization.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function New-AnsibleOrganization {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [String]$CustomVirtualenv,

        [Parameter(Position=2)]
        [String]$Description,

        [Parameter(Mandatory=$true,Position=1)]
        [String]$Name,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    End {
        $NewObject = @{
            description = $Description
            name = $Name
            custom_virtualenv = $CustomVirtualenv
        }

        if($PSCmdlet.ShouldProcess($AnsibleTower, "Create organization $($NewObject.Name)")) {
            Invoke-PostAnsibleInternalJsonResult -ItemType organizations -InputObject $NewObject -AnsibleTower $AnsibleTower > $Null
        }
    }
}