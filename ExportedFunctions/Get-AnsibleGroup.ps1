function Get-AnsibleGroup
{
    [CmdletBinding()]
    Param (
        [String]$Name,

        $Inventory,

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

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "groups" -Id $id -AnsibleTower $AnsibleTower
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "groups" -AnsibleTower $AnsibleTower -Filter $Filter
    }
    

    if (!($Return))
    {
        #Nothing returned from the call
        Return
    }
    $returnobj = @()
    foreach ($jsongroup in $return)
    {
        #Shift back to json and let newtonsoft parse it to a strongly named object instead
        $jsongroupstring = $jsongroup | ConvertTo-Json
        $group = $JsonParsers.ParseToGroup($jsongroupstring)
        $Group.AnsibleTower = $AnsibleTower
        $Group.Variables = Get-ObjectVariableData $Group
        Write-Output $Group
        $group = $null
    }
}