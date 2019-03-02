Function New-AnsibleHost
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Description,

        [Parameter(Mandatory=$true)]
        $Inventory,

        [Parameter(Mandatory=$true)]
        $group,

        [String]$Variables = "---",

        [bool]$Enabled = $true,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )

    $InventoryId = $null
    switch($Inventory.GetType().Fullname) {
        "AnsibleTower.Inventory" {
            $InventoryId = $Inventory.id
        }
        "System.Int32" {
            $InventoryId = $Inventory
        }
        "System.String" {
            $InventoryId = (Get-AnsibleInventory -Name $Inventory -AnsibleTower $AnsibleTower).Id
        }
        default {
            Write-Error "Unknown type passed as -Inventory ($_).  Suppored values are String, Int32, and AnsibleTower.Inventory." -ErrorAction Stop
            return
        }
    }

    $GroupId = $null
    switch($Group.GetType().Fullname) {
        "AnsibleTower.Group" {
            $GroupId = $Group.id
        }
        "System.Int32" {
            $GroupId = $Group
        }
        "System.String" {
            $GroupId = (Get-AnsibleGroup -Name $Group -Inventory $InventoryId -AnsibleTower $AnsibleTower).Id
        }
        default {
            Write-Error "Unknown type passed as -Group ($_).  Suppored values are String, Int32, and AnsibleTower.Group." -ErrorAction Stop
            return
        }
    }

    $myobj = "" | Select-Object name, description, inventory, variables, enabled
    $myobj.Name = $Name
    $myobj.Description = $Description
    $myobj.Inventory = $InventoryId
    $myobj.variables = $Variables
    $myobj.enabled = $Enabled

    if($PSCmdlet.ShouldProcess($AnsibleTower.ToString(), "Create host $($MyObj.Name)")) {
        Invoke-PostAnsibleInternalJsonResult -ItemType "groups" -InputObject $myobj -itemId $GroupId -ItemSubItem "hosts" > $null
    }
}