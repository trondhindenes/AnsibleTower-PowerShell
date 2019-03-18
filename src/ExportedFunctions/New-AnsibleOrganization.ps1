Function New-AnsibleOrganization
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(Mandatory=$true)]
        $Name,

        $Description,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )

    $NewOrg = @{
        name = $Name
        description = $Description
    }

    if($PSCmdlet.ShouldProcess($AnsibleTower, "Create organization $Name")) {
        $ResultObject = Invoke-PostAnsibleInternalJsonResult -ItemType "organizations" -InputObject $NewOrg -AnsibleTower $AnsibleTower
        if ($ResultObject)
        {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToOrganization($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
        }
    }
}