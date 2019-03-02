function Test-AnsibleTower {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    if($AnsibleTower.TokenExpiration.AddMinutes(30) -lt [DateTime]::Now) {
        #Renew
    } else {
        if(!$AnsibleTower.Me) {
            $meResult = Invoke-AnsibleRequest -AnsibleTower $AnsibleTower -RelPath 'me'
            if (!$meResult -or !$meResult.results) {
                throw "Could not authenticate to Tower";
            }
            $AnsibleTower.Me = $JsonParsers.ParseToUser((ConvertTo-Json ($meResult.results | Select-Object -First 1)));
        }
    }
    $AnsibleTower.Me
}