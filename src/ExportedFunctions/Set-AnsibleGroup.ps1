function Set-AnsibleGroup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([AnsibleTower.Group])]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $Group,

        $Name,

        $Description,

        $Inventory,

        [switch]$Enabled,

        $Instance_id,

        [Hashtable]$Variables,

        [switch]$PassThru
    )
    process {
        $AnsibleTower = $Group.AnsibleTower
        $UpdateProps = @{}
        if($PSBoundParameters.ContainsKey("Name")) {
            $UpdateProps["name"] = $Name
        }
        if($PSBoundParameters.ContainsKey("Description")) {
            $UpdateProps["description"] = $Description
        }
        if($PSBoundParameters.ContainsKey("Variables")) {
            $UpdateProps["variables"] = ConvertTo-Json $Variables -Depth 12
        }

        $Body = ConvertTo-Json $UpdateProps

        if($PSCmdlet.ShouldProcess($AnsibleTower.ToString(), "Update properties on group $($Group.Name)")) {
            $Result = Invoke-AnsibleRequest -Method PATCH -FullPath $Group.Url -AnsibleTower $AnsibleTower -Body $Body
            $JsonString = $Result | ConvertTo-Json
            $Group = [AnsibleTower.JsonFunctions]::ParseToGroup($JsonString)
            $Group.Variables = [AnsibleTower.JsonFunctions]::ParseToHashtable($Result.Variables)
            $Group.AnsibleTower = $AnsibleTower
        }

        if($PassThru) {
            Write-Output $Group
        }
    }
}