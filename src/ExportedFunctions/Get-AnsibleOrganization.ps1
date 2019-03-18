function Get-AnsibleOrganization {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [int]$id,

        [Parameter(ParameterSetName='ById')]
        [Switch]$UseCache,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
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
            $CacheKey = "organization/$id"
            $AnsibleObject = $AnsibleTower.Cache.Get($CacheKey)
            if($UseCache -and $AnsibleObject) {
                Write-Debug "[Get-AnsibleOrganization] Returning $($AnsibleObject.Url) from cache"
                $AnsibleObject
            } else {
                Invoke-GetAnsibleInternalJsonResult -ItemType "organizations" -Id $id -AnsibleTower $AnsibleTower | ConvertToOrganization -AnsibleTower $AnsibleTower
            }
        }
        Else
        {
            Invoke-GetAnsibleInternalJsonResult -ItemType "organizations" -AnsibleTower $AnsibleTower -Filter $Filter | ConvertToOrganization -AnsibleTower $AnsibleTower
        }
    }
}

function ConvertToOrganization {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $InputObject,

        [Parameter(Mandatory=$true)]
        $AnsibleTower
    )
    process {
        $JsonString = ConvertTo-Json $InputObject
        $AnsibleObject = $JsonParsers.ParseToOrganization($JsonString)
        $AnsibleObject.AnsibleTower = $AnsibleTower
        $CacheKey = "organization/$($AnsibleObject.Id)"
        Write-Debug "[Get-AnsibleOrganization] Caching $($AnsibleObject.Url) as $CacheKey"
        $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
        Write-Debug "[Get-AnsibleOrganization] Returning $($AnsibleObject.Url)"
        $AnsibleObject
    }
}
