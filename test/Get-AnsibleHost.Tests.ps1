Microsoft.PowerShell.Management\Push-Location -Path ..\Release
Import-Module .\AnsibleTower -ErrorAction Stop

Describe "Get-AnsibleHost" {
    It "Has the manually added Group parameter" {
        (gcm Get-AnsibleHost).Parameters["Group"] | Should -Not -Be $null
    }
}

Microsoft.PowerShell.Management\Pop-Location
