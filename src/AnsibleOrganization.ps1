Function New-AnsibleOrganization
{
    [CmdletBinding()]
    Param ($Name, $Description)
    $myobj = "" | Select-Object name, description
    $myobj.name = $Name
    if ($Description)
    {
        $myobj.description = $Description
    }

    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "organizations" -InputObject $myobj
    if ($result)
    {
        $resultString = $result | ConvertTo-Json
        $resultobj = $JsonParsers.ParseToOrganization($resultString)
        $resultobj
    }
}