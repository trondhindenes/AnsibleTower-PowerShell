function Get-AnsibleHost
{
    <#
    .PARAMETER Inventory
        The inventory to filter hosts by.  This can be the id (int), name (string), or an object returned from Get-AnsibleInventory.

    .PARAMETER Name
        The name to filter hosts by.  If not specified all hosts are returned.  If the name contains * it is interpreted as a regex with '*' replaced with '.*'.  If specified without * only hosts with an exact matching name will be returned.
    #>
    [CmdletBinding()]
    [OutputType([AnsibleTower.Host])]
    Param (
        [string]$Name,

        $Inventory,

        $Group,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    begin {
        $GroupCache = @{}
    }
    process {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("Name")) {
            if($Name.Contains("*")) {
                $Filter["name__iregex"] = $Name.Replace("*", ".*")
            } else {
                $Filter["name"] = $Name
            }
        }
        if($PSBoundParameters.ContainsKey("Inventory")) {
            switch($Inventory.GetType().Fullname) {
                "AnsibleTower.Inventory" {
                    $Filter["inventory"] = $Inventory.id
                }
                "System.Int32" {
                    $Filter["inventory"] = $Inventory
                }
                "System.String" {
                    $Filter["inventory__name"] = $Inventory
                }
                default {
                    Write-Error "Unknown type passed as -Inventory ($_).  Suppored values are String, Int32, and AnsibleTower.Inventory." -ErrorAction Stop
                    return
                }
            }
        }

        if($PSBoundParameters.ContainsKey("Group")) {
            switch($Inventory.GetType().Fullname) {
                "AnsibleTower.Group" {
                    $Filter["groups__id"] = $Group.id
                }
                "System.Int32" {
                    $Filter["group__id"] = $Group
                }
                "System.String" {
                    $Filter["groups__name"] = $Group
                }
                default {
                    Write-Error "Unknown type passed as -Inventory ($_).  Suppored values are String, Int32, and AnsibleTower.Inventory." -ErrorAction Stop
                    return
                }
            }
        }

        if ($id)
        {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "hosts" -Id $id -AnsibleTower $AnsibleTower
        }
        Else
        {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "hosts" -AnsibleTower $AnsibleTower -Filter $Filter
        }


        if (!($Return))
        {
            #Nothing returned from the call
            Return
        }
        foreach ($jsonhost in $return)
        {
            #Shift back to json and let newtonsoft parse it to a strongly named object instead
            $jsonhoststring = $jsonhost | ConvertTo-Json
            Write-Debug "Host String`r`n$JsonHostString"
            $thishost = $JsonParsers.ParseToHost($jsonhoststring)

            Write-verbose "Found host id $($thishost.id)"

            #Get the related groups
            $Groups = Invoke-GetAnsibleInternalJsonResult -ItemType "hosts" -Id $thishost.id -ItemSubItem "groups" -AnsibleTower $AnsibleTower

            foreach ($group in $groups)
            {
                if(!$GroupCache[$Group.Id]) {
                    $GroupCache[$Group.Id] = Get-AnsibleGroup -id $group.id -AnsibleTower $AnsibleTower
                }
                $GroupObj = $GroupCache[$Group.Id]
                if (!($thishost.groups))
                {
                    $thishost.groups = $GroupObj
                }
                Else
                {
                    $thishost.groups.add($GroupObj)
                }
            }

            $ThisHost.AnsibleTower = $AnsibleTower
            Write-Output $thishost
            $thishost = $null
        }
    }
}