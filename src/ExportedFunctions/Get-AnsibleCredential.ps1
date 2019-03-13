<#
.DESCRIPTION
  Gets credentials configured in Ansible Tower.

.PARAMETER CredentialType
  Specify the type of credential you want to create. Refer to the Ansible Tower documentation for details on each type.

.PARAMETER Description
  Optional description of this credential.

.PARAMETER Name
  Name of this credential.

.PARAMETER Organization
  Inherit permissions from organization roles. If provided on creation, do not give either user or team.

.PARAMETER Id
  The ID of a specific AnsibleCredential to get

.PARAMETER AnsibleTower
  The Ansibl Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleCredential {
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "CredentialType")]
    param(
        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$CredentialType,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='PropertyFilter')]
        [Object]$Organization,

        [Parameter(ParameterSetName='ById')]
        [Int32]$Id,

        [Object]$AnsibleTower = $Global:DefaultAnsibleTower
    )
    end {
                $Filter = @{}
        if($PSBoundParameters.ContainsKey("CredentialType")) {
            switch($CredentialType.GetType().Fullname) {
                "AnsibleTower.CredentialType" {
                    $Filter["credential_type"] = $CredentialType.Id
                }
                "System.Int32" {
                    $Filter["credential_type"] = $CredentialType
                }
                "System.String" {
                    $Filter["credential_type__name"] = $CredentialType
                }
                default {
                    Write-Error "Unknown type passed as -CredentialType ($_).  Supported values are String, Int32, and AnsibleTower.CredentialType." -ErrorAction Stop
                    return
                }
            }
        }

        if($PSBoundParameters.ContainsKey("Description")) {
            if($Description.Contains("*")) {
                $Filter["description__iregex"] = $Description.Replace("*", ".*")
            } else {
                $Filter["description"] = $Description
            }
        }

        if($PSBoundParameters.ContainsKey("Name")) {
            if($Name.Contains("*")) {
                $Filter["name__iregex"] = $Name.Replace("*", ".*")
            } else {
                $Filter["name"] = $Name
            }
        }

        if($PSBoundParameters.ContainsKey("Organization")) {
            switch($Organization.GetType().Fullname) {
                "AnsibleTower.Organization" {
                    $Filter["organization"] = $Organization.Id
                }
                "System.Int32" {
                    $Filter["organization"] = $Organization
                }
                "System.String" {
                    $Filter["organization__name"] = $Organization
                }
                default {
                    Write-Error "Unknown type passed as -Organization ($_).  Supported values are String, Int32, and AnsibleTower.Organization." -ErrorAction Stop
                    return
                }
            }
        }

        if($id) {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "credentials" -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "credentials" -Filter $Filter -AnsibleTower $AnsibleTower
        }

        if(!($Return)) {
            return
        }
        foreach($ResultObject in $Return) {
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseTocredential($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
            $AnsibleObject = $Null
        }
    }
}