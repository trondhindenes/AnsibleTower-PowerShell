<#
.DESCRIPTION
Creates a new team in Ansible Tower.

.PARAMETER Description
Optional description of this team.

.PARAMETER Name
Name of this team.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function New-AnsibleTeam {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [String]$Description,

        [Parameter(Mandatory=$true,Position=1)]
        [String]$Name,

        [Parameter(Mandatory=$true,Position=3)]
        [Object]$Organization,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    End {
        $OrganizationId = $null
        if($PSBoundParameters.ContainsKey("Organization")) {
            switch($Organization.GetType().Fullname) {
                "AnsibleTower.Organization" {
                    $OrganizationId = $Organization.Id
                }
                "System.Int32" {
                    $OrganizationId = $Organization
                }
                "System.String" {
                    $OrganizationId = (Get-AnsibleOrganization -Name $Organization -AnsibleTower $AnsibleTower).Id
                }
                default {
                    Write-Error "Unknown type passed as -Organization ($_).  Suppored values are String, Int32, and AnsibleTower.Organization." -ErrorAction Stop
                    return
                }
            }
        }
        if(!$OrganizationId) {
            Write-Error "Unable to locate an organization by $Organization" -ErrorAction Stop
            return
        }

        $NewObject = @{
            description = $Description
            name = $Name
            organization = $OrganizationId
        }

        if($PSCmdlet.ShouldProcess($AnsibleTower, "Create team $($NewObject.Name)")) {
            Invoke-PostAnsibleInternalJsonResult -ItemType teams -InputObject $NewObject -AnsibleTower $AnsibleTower > $Null
        }
    }
}
