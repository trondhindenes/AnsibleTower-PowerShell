function Register-AnsibleTower {
    <#
    .SYNOPSIS
    Saves the module application's client ID from an Ansible Tower instance to allow the module to authenticate against the instance.
    
    .PARAMETER ClientId
    The client ID created when the application was created in Ansible Tower.

    .PARAMETER TowerUrl
    Url of the Tower host, e.g. https://ansible.mydomain.local

    .EXAMPLE
    Register-AnsibleTower -ClientId gqbhxgavadpptyirpicypvqctaahzqsxgpdzfgfq -TowerUrl 'https://ansible.domain.local'

    This will use the specified client ID when connections are made to 'https://ansible.domain.local'
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$ClientId,

        [Parameter(Mandatory=$true)]
        [string]$TowerUrl
    )
    $TowerConfig = Get-ModuleConfig
    $UrlKey = $TowerUrl.ToLower()
    $NewApp = New-Object AnsibleTower.Application -Property @{
        client_id = $ClientId
    }
    $TowerConfig.Applications.Add($UrlKey, $NewApp)
    Save-ModuleConfig -ModuleConfig $TowerConfig
}