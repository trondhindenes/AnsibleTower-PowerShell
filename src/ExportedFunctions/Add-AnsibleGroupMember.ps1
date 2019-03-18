<#
.DESCRIPTION
Adds hosts or groups to groups in an Ansible inventory.

.PARAMETER Group
The name, id, or group object of a group.  If using the name and it is not unique, you must
specify an inventory by prepending the inventory name to the group name (eg 'inventory/group') or
using the -Inventory parameter.

.PARAMETER Hosts
A list of hosts to add to the specified group.  This can be the host name, id, or host object.
The hosts must already be defined in the same inventory as the target group.

.PARAMETER ChildGroups
A list of groups to add to the specified group.  This can be the group name, id, or group object.
The groups must already be defined in the same inventory as the target group.

.PARAMETER Inventory
The inventory to operate on if the target group is not unique.  This is only needed when specifing
-Group as a non-unique name.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
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
        }
        switch($Group.GetType().Fullname) {
            "AnsibleTower.Group" {
                #do nothing
            }
            "System.String" {
                if(!$Inventory -and $Group.Contains("/")) {
                    $InventoryParam["Inventory"],$Group = $Group.Split("/")
                }
                $Group = Get-AnsibleGroup -Name $Group @InventoryParam -AnsibleTower $AnsibleTower
            }
            "System.Int32" {
                $Group = Get-AnsibleGroup -Id $Group -AnsibleTower $AnsibleTower
            }
            default {
                Write-Error "Unknown type passed as -Group ($_).  Suppored values are String, Int32, and AnsibleTower.Group." -ErrorAction Stop
            }
        }
        if($Group.Count -ne 1) {
            $GroupList = ($Group | ForEach-Object {
                "$($_.Inventory.Name)/$($_.Name)"
            }) -Join ", "
            Write-Error "Unable to resolve target group to a single group. Found: $GroupList" -ErrorAction Stop
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
                    Write-Error "Unable to locate host '$_' in inventory '$($InventoryParam['Inventory'])'"
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
                    Write-Error "Unable to locate child group '$_' in inventory '$($InventoryParam['Inventory'])'"
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