Function Set-AnsibleUser
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingUserNameAndPassWordParams', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName="ById")]
        [int32]$Id,

        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ParameterSetName="ByObject")]
        [AnsibleTower.User]$User,

        $UserName,

        $FirstName,

        $LastName,

        $Email,

        [bool]$SuperUser,

        $Password,

        [Parameter(ParameterSetName="ById")]
        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        if($Id) {
            $ThisUser = Get-AnsibleUser -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $AnsibleTower = $User.AnsibleTower
            # Get a new instance to avoid modifing the passed in user object
            $ThisUser = Get-AnsibleUser -Id $User.Id -AnsibleTower $AnsibleTower
        }

        if ($UserName) {$ThisUser.username = $UserName}
        if ($FirstName) {$ThisUser.first_name = $FirstName}
        if ($LastName) {$ThisUser.last_name = $LastName}
        if ($Email) {$ThisUser.email = $Email}
        if ($SuperUser) {$ThisUser.is_superuser = $SuperUser}
        if ($Password) {$ThisUser.password = $Password}

        if($PSCmdlet.ShouldProcess($AnsibleTower, "Update user $($ThisUser.Username)")) {
            $result = Invoke-PutAnsibleInternalJsonResult -ItemType "users" -InputObject $ThisUser -AnsibleTower $AnsibleTower
            if ($result)
            {
                $JsonString = $Result | ConvertTo-Json
                $AnsibleObject = $JsonParsers.ParseToUser($JsonString)
                $AnsibleObject.AnsibleTower = $AnsibleTower
                Write-Output $AnsibleObject
            }
        }
    }
}