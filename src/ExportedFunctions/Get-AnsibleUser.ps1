<#
.DESCRIPTION
Gets users defined in Ansible Tower.

.PARAMETER IsSuperuser
Designates that this user has all permissions without explicitly assigning them.

.PARAMETER Username
Required. 150 characters or fewer. Letters, digits and @/./+/-/_ only.

.PARAMETER Id
The ID of a specific AnsibleUser to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleUser {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [OutputType([AnsibleTower.User])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [String]$Email,

        [Parameter(Position=3,ParameterSetName='PropertyFilter')]
        [String]$FirstName,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$IsSuperuser,

        [Parameter(Position=4,ParameterSetName='PropertyFilter')]
        [String]$LastName,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Username,

        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    End {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("Email")) {
            if($Email.Contains("*")) {
                $Filter["email__iregex"] = $Email.Replace("*", ".*")
            } else {
                $Filter["email"] = $Email
            }
        }

        if($PSBoundParameters.ContainsKey("FirstName")) {
            if($FirstName.Contains("*")) {
                $Filter["first_name__iregex"] = $FirstName.Replace("*", ".*")
            } else {
                $Filter["first_name"] = $FirstName
            }
        }

        if($PSBoundParameters.ContainsKey("IsSuperuser")) {
            $Filter["is_superuser"] = $IsSuperuser
        }

        if($PSBoundParameters.ContainsKey("LastName")) {
            if($LastName.Contains("*")) {
                $Filter["last_name__iregex"] = $LastName.Replace("*", ".*")
            } else {
                $Filter["last_name"] = $LastName
            }
        }

        if($PSBoundParameters.ContainsKey("Username")) {
            if($Username.Contains("*")) {
                $Filter["username__iregex"] = $Username.Replace("*", ".*")
            } else {
                $Filter["username"] = $Username
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "users" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "users" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseTouser($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}
