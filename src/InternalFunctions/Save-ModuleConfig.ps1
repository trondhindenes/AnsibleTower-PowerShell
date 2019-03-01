function Save-ModuleConfig {
    param(
        [Parameter(Mandatory=$true)]
        $ModuleConfig
    )
    $TowerFolder = Join-Path $HOME ".pstower"
    if(-not (Test-Path $TowerFolder)) {
        New-Item -ItemType Directory -Path $TowerFolder > $null
    }
    $TowerConfigPath = Join-Path $TowerFolder "tower.json"
    Set-Content -Path $TowerConfigPath -Value (ConvertTo-Json $ModuleConfig)
}