param(
    [Parameter(Mandatory=$true)]
    $ComposeFile,

    [Parameter(Mandatory=$true)]
    $Path,

    [Parameter(Mandatory=$true)]
    [Uri]$Url,

    [switch]$UseCompose
)

if($UseCompose) {
    pushd $Path
    try {
        docker-compose -f $ComposeFile -p AnsiblePesterTests up --detach
        Write-Host "Waiting for $Url/api to become available" -NoNewLine
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
        Start-Sleep -Seconds 20
    } finally {
        popd
    }
}