function Get-AnsibleOrganization
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [String]$Name,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id,

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
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "organizations" -Id $id -AnsibleTower $AnsibleTower
        }
        Else
        {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "organizations" -AnsibleTower $AnsibleTower -Filter $Filter
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
            $org = $JsonParsers.ParseToOrganization($jsonorgstring)
            Write-Output $org
            $org = $null
        }
    }
}