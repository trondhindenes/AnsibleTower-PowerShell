function Get-AnsibleInventory
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        $Name,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )

    $Filter = @{}
    if($PSBoundParameters.ContainsKey("Name")) {
        if($Name.Contains("*")) {
            $Filter["name__iregex"] = $Name.Replace("*", ".*")
        } else {
            $Filter["name"] = $Name
        }
    }

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "inventory" -Id $id
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "inventory" -Filter $Filter
    }

    if (!($Return))
    {
        #Nothing returned from the call
        Return
    }

    foreach ($jsonorg in $return)
    {
        #Shift back to json and let newtonsoft parse it to a strongly named object instead
        $jsonorgstring = $jsonorg | ConvertTo-Json
        $inventory = $JsonParsers.ParseToInventory($jsonorgstring)

        $Groups = Invoke-GetAnsibleInternalJsonResult -ItemType "inventory" -Id $inventory.id -ItemSubItem "groups"

        foreach ($group in $groups)
        {
            $GroupObj = Get-AnsibleGroup -id $group.id
            if (!($thishost.groups))
            {
                $inventory.groups = $GroupObj
            }
            Else
            {
                $inventory.groups.add($GroupObj)
            }
        }

        Write-Output $Inventory
        $inventory = $null

    }
}