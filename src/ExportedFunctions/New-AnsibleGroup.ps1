Function New-AnsibleGroup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Description,

        [Parameter(Mandatory=$true)]
        $Inventory,

        [String]$Variables = "---",

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

    $myobj = @{
        name = $Name
        description = $Description
        inventory = $InventoryId
        variables = $Variables
    }

    if($PSCmdlet.ShouldProcess($AnsibleTower.ToString(), "Create group $($MyObj.Name)")) {
        Invoke-PostAnsibleInternalJsonResult -ItemType "groups" -InputObject $myobj -itemId $GroupId -AnsibleTower $AnsibleTower > $null
    }
}