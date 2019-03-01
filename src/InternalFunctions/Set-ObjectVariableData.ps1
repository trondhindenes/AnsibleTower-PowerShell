function Set-ObjectVariableData {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $Object,

        [Hashtable]$Variables
    )
    process {
        $DataUrl = Join-AnsibleUrl $Object.Url,"variable_data"

        $Result = Invoke-AnsibleRequest -Method PUT -FullPath $DataUrl -AnsibleTower $Object.AnsibleTower -ContentType "application/json" -Body (
            ConvertTo-Json $Variables
        )
        $JsonString = $Result | ConvertTo-Json
        Write-Output ([AnsibleTower.JsonFunctions]::ParseToHashtable($JsonString))
    }
}