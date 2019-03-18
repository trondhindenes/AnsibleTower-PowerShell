function Add-AnsibleGroupmember {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Mandatory=$true)]
        $Group,

        [Parameter(Mandatory=$true,ParameterSetName="AddHost")]
        [object[]]$Hosts,

        [Parameter(Mandatory=$true,ParameterSetName="AddGroup")]
        [object[]]$ChildGroups,

        $Inventory,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    begin {
        $InventoryParam = @{}
        if($Inventory) {
            $InventoryParam["Inventory"] = $Inventory
        } elseif($Group.Contains("/")) {
            $InventoryParam["Inventory"],$Group = $Group.Split("/")
        }
        switch($Group.GetType().Fullname) {
            "AnsibleTower.Group" {
                #do nothing
            }
            "System.String" {
                $Group = Get-AnsibleGroup -Name $Group @InventoryParam -AnsibleTower $AnsibleTower
            }
            "System.Int32" {
                $Group = Get-AnsibleGroup -Id $Group -AnsibleTower $AnsibleTower
            }
            default {
                Write-Error "Unknown type passed as -Group ($_).  Suppored values are String, Int32, and AnsibleTower.Group." -ErrorAction Stop
                break
            }
        }
        if($Group.Count -gt 1) {
            $GroupList = ($Group | ForEach-Object {
                "$($_.Inventory.Name)/$($_.Name)"
            }) -Join ", "
            Write-Error "Multiple target groups found: $GroupList"
            break
        }
        if(!$InventoryParam.ContainsKey("inventory")) {
            $inventoryParam["Inventory"] = $Group.Inventory
        }
    }
    process {
        if($PSCmdlet.ParameterSetName -eq "AddHost") {
            $Hosts | ForEach-Object {
                $ThisHost = $_
                switch($ThisHost.GetType().Fullname) {
                    "AnsibleTower.Host" {
                        $AnsibleTower = $ThisHost.AnsibleTower
                    }
                    "System.String" {
                        $ThisHost = Get-AnsibleHost -Name $ThisHost @InventoryParam -AnsibleTower $AnsibleTower
                    }
                    "System.Int32" {
                        $ThisHost = Get-AnsibleHost -Id $ThisHost -AnsibleTower $AnsibleTower
                    }
                    default {
                        Write-Error "Unknown type passed as -Hosts ($_).  Suppored values are String, Int32, and AnsibleTower.Host." -ErrorAction Stop
                        return
                    }
                }
                if(!$ThisHost) {
                    Write-Error "Unable to locate host by '$_'"
                    return
                }
                $HostGroupUrl = Join-AnsibleUrl $ThisHost.Url, 'groups'
                $HostName = $ThisHost.Name

                $GroupName = $Group.Name
                if($PSCmdlet.ShouldProcess($AnsibleTower.ToString(), "Add host '$HostName' to group '$GroupName'")) {
                    Invoke-AnsibleRequest -AnsibleTower $AnsibleTower -FullPath $HostGroupUrl -Method POST -Body (
                        ConvertTo-Json @{ id = $Group.Id}
                    )
                }
            }
        } else {
            $ChildGroups | ForEach-Object {
                $ThisGroup = $_
                switch($ThisGroup.GetType().Fullname) {
                    "AnsibleTower.Group" {
                        $AnsibleTower = $ThisGroup.AnsibleTower
                    }
                    "System.String" {
                        $ThisGroup = Get-AnsibleGroup -Name $ThisGroup @InventoryParam -AnsibleTower $AnsibleTower
                    }
                    "System.Int32" {
                        $ThisGroup = Get-AnsibleGroup -Id $ThisGroup -AnsibleTower $AnsibleTower
                    }
                    default {
                        Write-Error "Unknown type passed as -Group ($_).  Suppored values are String, Int32, and AnsibleTower.Group." -ErrorAction Stop
                        return
                    }
                }
                if(!$ThisGroup) {
                    Write-Error "Unable to locate child group by '$_'"
                    return
                }
                $GroupChildrenUrl = Join-AnsibleUrl $ThisGroup.Url, 'children'
                $ThisGroupName = $ThisGroup.Name

                $GroupName = $Group.Name
                if($PSCmdlet.ShouldProcess($AnsibleTower.ToString(), "Add group '$ThisGroupname' to group '$GroupName'")) {
                    Invoke-AnsibleRequest -AnsibleTower $AnsibleTower -Fullpath $GroupChildrenUrl -Method POST -Body (
                        ConvertTo-Json @{ id = $Group.Id}
                    )
                }
            }
        }
    }
}