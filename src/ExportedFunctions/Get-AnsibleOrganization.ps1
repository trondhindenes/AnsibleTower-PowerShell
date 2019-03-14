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
            if($UseCache) {
                $OrgKey = "organization/$id"
                $Organization = $AnsibleTower.Cache.Get($OrgKey)
            }
            if($Organization) {
                $Organization
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
        $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy)
        $AnsibleObject
    }
}
