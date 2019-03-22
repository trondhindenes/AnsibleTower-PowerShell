Microsoft.PowerShell.Management\Push-Location -Path ..\Release

Describe "AnsibleTower Module" {
    It "Successfully imports" {
        { Import-Module .\AnsibleTower -ErrorAction Stop } | Should -Not -Throw
    }

    Context "Module Loaded" {
        BeforeEach {
            if(!(Get-Module AnsibleTower)) {
                Import-Module .\AnsibleTower
            }
        }

        It "Has AnsibleTower clases loaded" {
            Import-Module .\AnsibleTower -ErrorAction Stop
            { [AnsibleTower.Tower] } | Should -Not -Throw
        }

        It "Exports Get-AnsibleHost" {
            (Get-Module AnsibleTower).ExportedCommands["Get-AnsibleHost"] | Should -Not -Be $null
        }
    }
}

Microsoft.PowerShell.Management\Pop-Location