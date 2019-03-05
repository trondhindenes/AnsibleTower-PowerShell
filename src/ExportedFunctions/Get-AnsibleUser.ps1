function Get-AnsibleUser
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        if ($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "users" -Id $id -AnsibleTower $AnsibleTower
        }
        Else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "users" -AnsibleTower $AnsibleTower
        }


        if (!($Return))
        {
            #Nothing returned from the call
            Return
        }
        foreach ($ResultObject in $return)
        {
            # Shift back to json and let newtonsoft parse it to a strongly named object instead
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = $JsonParsers.ParseToUser($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
            $AnsibleObject = $null
        }
    }
}