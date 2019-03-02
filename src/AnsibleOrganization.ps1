Function New-AnsibleOrganization
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param ($Name, $Description)
    $myobj = "" | Select-Object name, description
    $myobj.name = $Name
    if ($Description)
    {
        $myobj.description = $Description
    }

    if($PSCmdlet.ShouldProcess($AnsibleTower, "Create organization $Name")) {
        $result = Invoke-PostAnsibleInternalJsonResult -ItemType "organizations" -InputObject $myobj
        if ($result)
        {
            $resultString = $result | ConvertTo-Json
            $resultobj = $JsonParsers.ParseToOrganization($resultString)
            $resultobj
        }
    }
}