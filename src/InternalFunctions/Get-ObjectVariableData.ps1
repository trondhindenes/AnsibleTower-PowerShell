function Get-ObjectVariableData {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $Object
    )
    process {
        $DataUrl = Join-AnsibleUrl $Object.Url, "variable_data"
        $Return = Invoke-AnsibleRequest -Method GET -FullPath $DataUrl -AnsibleTower $Object.AnsibleTower

        $JsonString = $Return | ConvertTo-Json
        $Data = [AnsibleTower.JsonFunctions]::ParseToHashtable($JsonString)
        Write-Output $Data
    }
}