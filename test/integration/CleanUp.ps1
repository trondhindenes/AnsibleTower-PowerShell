param(
    $ComposeFile,

    $Path,

    [switch]$UseCompose
)

if($UseCompose -and !$Global:SkipDockerCleanup) {
    pushd $path
    try {
        docker-compose -f $ComposeFile -p AnsiblePesterTests rm -s -v -f
    } finally {
        popd
    }
}