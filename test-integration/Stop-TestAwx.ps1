#!/usr/bin/env pwsh
param(
    [ValidateSet("2.1.2","3.0.1")]
    $Version = "3.0.1"
)

$Path = Join-Path $PSScriptRoot $Version
$ComposeFile = Join-Path $PSScriptRoot "docker-compose.yml"
pushd $Path
try {
    docker-compose -f $ComposeFile -p "awx$Version" rm -s -v -f
} finally {
    popd
}