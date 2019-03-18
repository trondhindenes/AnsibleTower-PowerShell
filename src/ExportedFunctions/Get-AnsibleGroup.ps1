function Get-AnsibleGroup
{
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='PropertyFilter')]
        $Inventory,

        [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [int]$id,

        [Parameter(ParameterSetName='ById')]
        [Switch]$UseCache,

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

#    $AnsibleObject = $null
    if ($id)
    {
        $CacheKey = "groups/$id"
        $AnsibleObject = $AnsibleTower.Cache.Get($CacheKey)
        if($UseCache -and $AnsibleObject) {
            Write-Debug "[Get-AnsibleGroup] Returning $($AnsibleObject.Url) from cache"
            $AnsibleObject
        } else {
            Invoke-GetAnsibleInternalJsonResult -ItemType "groups" -Id $id -AnsibleTower $AnsibleTower | ConvertToGroup -AnsibleTower $AnsibleTower
        }
    }
    Else
    {
        Invoke-GetAnsibleInternalJsonResult -ItemType "groups" -AnsibleTower $AnsibleTower -Filter $Filter | ConvertToGroup -AnsibleTower $AnsibleTower
    }
}

function ConvertToGroup {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $InputObject,

        [Parameter(Mandatory=$true)]
        $AnsibleTower
    )
    process {
        $JsonString = ConvertTo-Json $InputObject
        $AnsibleObject = $JsonParsers.ParseToGroup($JsonString)
        $AnsibleObject.AnsibleTower = $AnsibleTower
        $CacheKey = "groups/$($AnsibleObject.Id)"
        Write-Debug "[Get-AnsibleGroup] Caching $($AnsibleObject.Url) as $CacheKey"
        $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
        #Add to cache before filling in child objects to prevent recursive loop
        $AnsibleObject.Variables = Get-ObjectVariableData $AnsibleObject
        $AnsibleObject.Inventory = Get-AnsibleInventory -Id $AnsibleObject.Inventory -AnsibleTower $AnsibleTower -UseCache
        Write-Debug "[Get-AnsibleGroup] Returning $($AnsibleObject.Url)"
        $AnsibleObject
    }
}