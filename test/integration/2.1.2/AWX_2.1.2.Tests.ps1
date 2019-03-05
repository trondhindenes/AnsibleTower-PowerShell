param(
    $ModulePath = (Join-Path $PSScriptRoot "../../../Release/AnsibleTower"),

    $Password = "7db2d013-21e5-45a1-b242-4e5e07c1b33a",

    $Url = "http://localhost:8052"
)

Import-Module $ModulePath -ErrorAction Stop
$PasswordSS = ConvertTo-SecureString -ASPlainText $Password -Force
$Credential = New-Object System.Management.Automation.PSCredential("admin", $PasswordSS)

$ComposeFile = Join-Path $PSScriptRoot "../docker-compose.yml"

if($PSBoundParameters.ContainsKey("Url")) {
    & (Join-Path $PSScriptRoot "../Setup.ps1") -ComposeFile $ComposeFile -Url $Url -Path $PSScriptRoot
} else {
    Write-Host "Passing $Url"
    & (Join-Path $PSScriptRoot "../Setup.ps1") -ComposeFile $ComposeFile -Url $Url -Path $PSScriptRoot -UseCompose
}

Describe "AWX 2.1.2 Integration" -Tags Integration {
    It "Connects" {
        { Connect-AnsibleTower -TowerUrl $Url -Credential $Credential } | Should -Not -Throw
    }

    context "Default connection" {
        $Connection = Connect-AnsibleTower -TowerUrl $Url -Credential $Credential
        tower-cli config host $Url
        tower-cli config oauth_token $Connection.Token.access_token
        tower-cli config verify_ssl false

        It "Gets the demo inventory" {
            $Inv = Get-AnsibleInventory -Name "Demo Inventory"
            $Inv | Should -Not -Be $Null
            $Inv.Name | Should -Be "Demo Inventory"
        }

        <#  NOT IMPLEMENTED
        It "Gets the demo project" {
            $Project = Get-AnsibleProject -Name "Demo Project"
            $Project | Should -Not -Be $Null
            $Project.Name | Should -Be "Demo Project"
        }
        #>

        It "Gets localhost from the demo inventory" {
            $H = Get-AnsibleHost -Name localhost -Inventory "Demo Inventory"
            $H | Should -Not -Be $Null
            $H.Name | Should -Be "localhost"
        }

        It "Gets the demo job template" {
            $jt = Get-AnsibleJobTemplate -Name "Demo Job Template"
            $jt | Should -Not -Be $Null
            $jt.Name | Should -Be "Demo Job Template"
        }

        It "Gets the default org" {
            $Org = Get-AnsibleOrganization -Name Default
            $Org | Should -Not -Be $Null
            $Org.Name | Should -Be "Default"
        }

        It "Gets the admin user" {
            $User = Get-AnsibleUser -Id 1
            $User | Should -Not -Be $Null
            $User.username | Should -Be "admin"
        }

        It "Updates the admin user" {
            #Names cannot be more than 30 characters
            $Firstname = [Guid]::NewGuid().ToString().Substring(0, 25)
            $LastName = [Guid]::NewGuid().ToString().Substring(0, 25)
            $User = Set-AnsibleUser -Id 1 -Firstname $FirstName -LastName $LastName
            $User.first_name | Should -Be $FirstName
            $User.last_name | Should -Be $LastName
        }

        It "Creates a new organization" {
            $Name = [Guid]::NewGuid().ToString().Substring(0, 25)
            $Description = [Guid]::NewGuid().ToString().Substring(0, 25)
            New-AnsibleOrganization -Name $Name -Description $Description
            $Org = tower-cli organization get -n $Name -f json -h $url -t $Connection.Token.access_token | ConvertFrom-json
            $Org | Should -Not -Be $Null
            $Org.Name | Should -Be $Name
            $Org.Description | Should -Be $Description
        }

        It "Creates a new user" {
            $Username = [Guid]::NewGuid().ToString().Substring(0, 25)
            $Firstname = [Guid]::NewGuid().ToString().Substring(0, 25)
            $LastName = [Guid]::NewGuid().ToString().Substring(0, 25)
            $Password = [Guid]::NewGuid().ToString().Substring(0, 25)
            $Email = "${Firstname}@$Lastname.com"
            New-AnsibleUser -Username $Username -FirstName $Firstname -Lastname $Lastname -Email $Email -SuperUser $false -Password $Password
            $User = tower-cli user get --username $Username -f json -h $url -t $Connection.Token.access_token | ConvertFrom-json
            $User | Should -Not -Be $Null
            $User.First_name | Should -Be $FirstName
            $User.Last_name | Should -Be $LastName
            $User.username | Should -Be $Username
        }
    }
}

if(!$PSBoundParameters.ContainsKey("Url")) {
    & (Join-Path $PSScriptRoot "../CleanUp.ps1") -ComposeFile $ComposeFile -Path $PSScriptRoot -UseCompose
} else {
    & (Join-Path $PSScriptRoot "../CleanUp.ps1") -ComposeFile $ComposeFile -Path $PSScriptRoot
}