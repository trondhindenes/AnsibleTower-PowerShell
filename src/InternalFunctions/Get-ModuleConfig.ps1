function Get-ModuleConfig {
    $TowerConfigPath = Join-Path $HOME ".pstower/tower.json"
    if( (Test-Path $TowerConfigPath) ) {
        $TowerConfig = [AnsibleTower.JsonFunctions]::ParseToModuleConfig((Get-Content -Path $TowerConfigPath -Raw))
    } else {
        $TowerConfig = New-Object AnsibleTower.ModuleConfig -Property @{
            applications = New-Object "System.Collections.Generic.Dictionary[string,AnsibleTower.Application]"
        }
    }
    $TowerConfig
}