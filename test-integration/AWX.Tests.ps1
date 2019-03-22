param(
    $ModulePath = (Join-Path $PSScriptRoot "../Release/AnsibleTower"),

    $Password = "7db2d013-21e5-45a1-b242-4e5e07c1b33a",

    $Url
)

function DockerComposeUp {
    param(
        $Path,
        $ComposeFile,
        $ProjectName = "AnsiblePesterTests"
    )
    pushd $Path
    try {
        docker-compose -f $ComposeFile -p $ProjectName up --quiet-pull --detach > $null
        $WebContainer = "${ProjectName}_web_1".ToLower()
        $NetworkName = "${ProjectName}_default".ToLower()
        $Container = docker inspect $WebContainer | ConvertFrom-Json
        $Port = $Container[0].NetworkSettings.Ports."8052/tcp".HostPort
        $IP = $Container[0].NetworkSettings.networks[0]."$NetworkName".IPAddress
        "http://127.0.0.1:${Port}"
    } finally {
        popd
    }
}

function DockerComposeStop {
    param(
        $Path,
        $ComposeFile,
        $ProjectName = "AnsiblePesterTests"
    )
    pushd $Path
    try {
        docker-compose -f $ComposeFile -p $ProjectName stop
        docker-compose -f $ComposeFile -p $ProjectName rm --force
        docker volume prune --force
        docker network prune --force
    } finally {
        popd
    }
}

function IntegrationTest {
    param(
        [Parameter(Mandatory=$true)]
        $Password,

        [Parameter(Mandatory=$true)]
        $Url,

        $TestName = "Remote"
    )
    $PasswordSS = ConvertTo-SecureString -ASPlainText $Password -Force
    $Credential = New-Object System.Management.Automation.PSCredential("admin", $PasswordSS)

    Write-Host "[$TestName] Waiting for $Url/api to become available" -NoNewLine
    foreach($i in (1..18)) {
        Write-Host "." -NoNewLine
        try {
            $Response = Invoke-RestMethod $Url/api -ErrorAction SilentlyContinue
        } catch {}
        if($Response.current_version) {
            break
        } else {
            Start-Sleep -Seconds 20
        }
    }
    Write-Host "."
    Start-Sleep -Seconds 20

    Remove-Variable -Scope Global -Name DefaultAnsibleTower -ErrorAction SilentlyContinue

    Describe "AWX $TestName Integration"  {
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

            It "Sets AnsibleTower on inventories" {
                $Inv = Get-AnsibleInventory -Name "Demo Inventory"
                $Inv.AnsibleTower | Should -Not -Be $Null
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

            It "Parses the host inventory property correctly" {
                $H = Get-AnsibleHost -Name localhost -Inventory "Demo Inventory"
                $H.Inventory.Name | Should -Be "Demo Inventory"
            }

            It "Sets AnsibleTower on hosts" {
                $H = Get-AnsibleHost -Name localhost -Inventory "Demo Inventory"
                $H.AnsibleTower | Should -Not -Be $null
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

            It "Sets AnsibleTower on orgs" {
                $Org = Get-AnsibleOrganization -Name Default
                $Org.AnsibleTower | Should -Not -Be $null
            }

            It "Gets the admin user" {
                $User = Get-AnsibleUser -Id 1
                $User | Should -Not -Be $Null
                $User.username | Should -Be "admin"
            }

            It "Gets the demo credential" {
                $Cred = Get-AnsibleCredential -Id 1
                $Cred | Should -Not -Be $Null
                $Cred.Name | Should -Be "Demo Credential"
            }

            It "Gets the demo project" {
                $Project = Get-AnsibleProject -Id 4
                $Project | Should -Not -Be $Null
                $Project.Name | Should -Be "Demo Project"
            }

            It "Updates the admin user" {
                #Names cannot be more than 30 characters
                $Firstname = [Guid]::NewGuid().ToString().Substring(0, 25)
                $LastName = [Guid]::NewGuid().ToString().Substring(0, 25)
                Set-AnsibleUser -Id 1 -Firstname $FirstName -LastName $LastName
                $User = tower-cli user get 1 -f json -h $url -t $Connection.Token.access_token | ConvertFrom-Json
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
}

Import-Module $ModulePath -Force -ErrorAction Stop

if($Url) {
    IntegrationTests -Password $Password -Url $Url
} else {
    #Start all containers first
    $TestList = Get-ChildItem -Directory | ForEach-Object {
        $TestPath = $_.Fullname
        $ComposeFile = Join-Path $PSScriptRoot "docker-compose.yml"
        $ProjectName = [Guid]::NewGuid().Guid
        $Url = DockerComposeUp -Path $TestPath -ComposeFile $ComposeFile -ProjectName $ProjectName
        [PSCustomObject]@{
            Name = $_.BaseName
            Path = $_.Fullname
            ComposeFile = $ComposeFile
            DockerProject = $ProjectName
            Url = $Url
        }
    }
    try {
        $Testlist | ForEach-Object {
            IntegrationTest -Password $Password -Url $_.Url -TestName $_.Name
        }
    } finally {
        $TestList | ForEach-Object {
            DockerComposeStop -Path $_.Path -ComposeFile $_.ComposeFile -ProjectName $_.DockerProject
        }
    }
}