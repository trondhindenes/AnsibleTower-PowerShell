function Add-AnsibleGroupmember {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        $Group,

        [Parameter(Mandatory=$true)]
        [object[]]$Members,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    begin {
        switch($Group.GetType().Fullname) {
            "AnsibleTower.Group" {
                #do nothing
            }
            "System.String" {
                $Group = Get-AnsibleGroup -Name $Group -AnsibleTower $AnsibleTower
            }
            "System.Int32" {
                $Group = Get-AnsibleGroup -Id $Group -AnsibleTower $AnsibleTower
            }
            default {
                Write-Error "Unknown type passed as -Group ($_).  Suppored values are String, Int32, and AnsibleTower.Group." -ErrorAction Stop
                return
            }
        }
    }
    process {
        $Members | ForEach-Object {
            $Member = $_
            switch($Member.GetType().Fullname) {
                "AnsibleTower.Host" {
                    $AnsibleTower = $Member.AnsibleTower
                }
                "System.String" {
                    $Member = Get-AnsibleHost -Name $Member -AnsibleTower $AnsibleTower
                }
                "System.Int32" {
                    $Member = Get-AnsibleHost -Id $Member -AnsibleTower $AnsibleTower
                }
                default {
                    Write-Error "Unknown type passed as -Inventory ($_).  Suppored values are String, Int32, and AnsibleTower.Inventory." -ErrorAction Stop
                    return
                }
            }
            $MemberGroupUrl = Join-AnsibleUrl $Member.Url, 'groups'
            $HostName = $Member.Name

            $GroupName = $Group.Name
            if($PSCmdlet.ShouldProcess($AnsibleTower.ToString(), "Add host '$HostName' to group '$GroupName'")) {
                Invoke-AnsibleRequest -AnsibleTower $AnsibleTower -FullPath $MemberGroupUrl -Method POST -Body (
                    ConvertTo-Json @{ id = $Group.Id}
                )
            }
        }
    }
}