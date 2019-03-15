Function New-AnsibleUser
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingUserNameAndPassWordParams', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [Parameter(Mandatory=$true)]
        $UserName,
        [Parameter(Mandatory=$true)]
        $FirstName,
        [Parameter(Mandatory=$true)]
        $LastName,
        [Parameter(Mandatory=$true)]
        $Email,
        [Parameter(Mandatory=$true)]
        [bool]$SuperUser,
        [Parameter(Mandatory=$true)]
        $Password,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    $myobj = "" | Select-Object username, first_name, last_name, email, is_superuser, password
    $myobj.username = $UserName
    if ($FirstName){$myobj.first_name = $FirstName}
    if ($LastName){$myobj.last_name = $LastName}
    if ($Email){$myobj.email = $Email}
    if ($SuperUser) {$myobj.is_superuser = $SuperUser}
    if ($Password) {$myobj.password = $Password}

    if($PSCmdlet.ShouldProcess($AnsibleTower, "Create user $UserName")) {
        $ResultObject = Invoke-PostAnsibleInternalJsonResult -ItemType "users" -InputObject $myobj -AnsibleTower $AnsibleTower
        if ($ResultObject)
        {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToUser($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
        }
    }
}