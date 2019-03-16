#!/usr/bin/env pwsh
param(
    [ValidateSet("2.1.2","3.0.1")]
    $Version = "3.0.1",
    $Password = "7db2d013-21e5-45a1-b242-4e5e07c1b33a"
)

$Path = Join-Path $PSScriptRoot $Version
$ComposeFile = Join-Path $PSScriptRoot "docker-compose.yml"
pushd $Path
try {
    $ProjectName = "awx{0}" -f $Version.Replace(".","")
    if($Password) {
        $env:AWX_PASSWORD = $Password
    }
    $PasswordSS = ConvertTo-SecureString -AsPlainText -Force $Password
    docker-compose -f $ComposeFile -p $ProjectName up --quiet-pull --detach > $null
    $WebContainer = "${ProjectName}_web_1".ToLower()
    $NetworkName = "${ProjectName}_default".ToLower()
    $Container = docker inspect $WebContainer | ConvertFrom-Json
    $Port = $Container[0].NetworkSettings.Ports."8052/tcp".HostPort
    $HostIP = ip -j -4 addr list | convertfrom-json | %{$_} | Where-Object {
        $_.ifname -eq "eth0"
    } | ForEach-Object {$_.addr_info.local}
    @{
        TowerUrl = "http://${HostIP}:$Port"
        Credential = New-Object System.Management.Automation.PSCredential("admin",$PasswordSS)
    }
} finally {
    popd
}