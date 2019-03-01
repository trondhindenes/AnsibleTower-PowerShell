function Remove-AnsibleHost {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="High")]
    param(
        [Parameter(Mandatory=$true,ParameterSetName="ByUrl")]
        $Url,

        [Parameter(Mandatory=$true,ParameterSetName="ByName")]
        $Name,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName="ByInputObject")]
        [AnsibleTower.Host]$InputObject,

        [Parameter(ParameterSetName="ByUrl")]
        [Parameter(ParameterSetName="ByName")]
        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        switch($PSCmdlet.ParameterSetName) {
            "ByInputObject" {
                $Url = $InputObject.Url
                $AnsibleTower = $InputObject.AnsibleTower
                $HostDisplay = "{0}\{1}" -f $InputObject.Inventory.Name,$InputObject.Name
            }
            "ByUrl" {
                $HostDisplay = $Url
            }
            "ByName" {
                Get-AnsibleHost -Name $Name -AnsibleTower $AnsibleTower | Remove-AnsibleHost
                return
            }
            default {
                Write-Error "Unknown parameter set name $_" -ErrorAction Stop
                return
            }
        }
        if($PSCmdlet.ShouldProcess($AnsibleTower.ToString(), "Delete host $HostDisplay")) {
            Invoke-AnsibleRequest -AnsibleTower $AnsibleTower -FullPath $Url -Method DELETE
        }
    }
}