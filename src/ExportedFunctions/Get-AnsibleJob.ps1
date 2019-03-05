function Get-AnsibleJob
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$ID,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        if ($ID) {
            $result = Invoke-GetAnsibleInternalJsonResult -ItemType "jobs" -Id $ID -AnsibleTower $AnsibleTower
        } else {
            $result = Invoke-GetAnsibleInternalJsonResult -ItemType "jobs" -AnsibleTower $AnsibleTower
        }

        if (!$result) {
            # Nothing returned from the call.
            return $null
        }
        foreach ($jsonorg in $result)
        {
            # Shift back to json and let newtonsoft parse it to a strongly named object instead.
            $jsonorgstring = $jsonorg | ConvertTo-Json
            $org = $JsonParsers.ParseToJob($jsonorgstring)
            $Org.AnsibleTower = $AnsibleTower
            Write-Output $org
            $org = $null
        }
    }
}