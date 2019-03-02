function Invoke-AnsibleRequest {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        $AnsibleTower = $Global:DefaultAnsibleTower,
        [Parameter(ParameterSetName="relpath")]
        $RelPath,
        [Parameter(ParameterSetName="fullpath")]
        $FullPath,
        $Method = "GET",
        [HashTable]$QueryParameters,
        $Body,
        $ContentType = "application/json"
    )
    if($PSBoundParameters.ContainsKey("RelPath")) {
        $Uri = Join-AnsibleUrl $AnsibleTower.TowerApiUrl,$RelPath
    }
    if($PSBoundParameters.ContainsKey("FullPath")) {
        $Uri = $AnsibleTower.AnsibleUrl.TrimEnd("/") + "/" + $FullPath.TrimStart("/")
    }
    if($PSBoundParameters.ContainsKey("QueryParameters") -and $QueryParameters.Count -gt 0) {
        $QueryString = [System.Web.HttpUtility]::ParseQueryString("")
        $QueryParameters.Keys | ForEach-Object {
            $QueryString.Add($_, $QueryParameters[$_])
        }
        $Uri = $Uri + "?" + $QueryString.ToString()
    }
    $Headers = @{
        "Authorization" = "Bearer $($AnsibleTower.Token.access_token)"
    }
    $IRMArgs = @{ }
    if($PSBoundParameters.ContainsKey("Body")) {
        $IRMARgs["Body"] = $Body
    }
    Invoke-RestMethod -Method $Method -Uri $Uri -ContentType $ContentType -Headers $Headers @IRMArgs
}