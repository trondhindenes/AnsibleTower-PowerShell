Microsoft.PowerShell.Management\Push-Location -Path ..\Release

Describe "AnsibleTower Module" {
    It "Successfully imports" {
        { Import-Module .\AnsibleTower -ErrorAction Stop } | Should -Not -Throw
    }
}


Microsoft.PowerShell.Management\Pop-Location