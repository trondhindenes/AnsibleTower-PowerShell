function Grant-AnsibleRole {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Position=1,Mandatory=$true)]
        [object]$Team,

        [Parameter(Position=2,Mandatory=$true)]
        [object]$Role,

        [switch]$Force,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        switch ($Team.GetType().Fullname) {
            "AnsibleTower.Team" {
                $AnsibleTower = $Team.AnsibleTower
            }
            "System.Int32" {
                $Team = Get-AnsibleTeam -Id $Team -AnsibleTower $AnsibleTower
            }
            "System.String" {
                $TeamSearch = @{}
                if($Team.Contains("/")) {
                    $TeamSearch["Organization"] = $Team.Split("/")[0]
                    $TeamSearch["Name"] = $Team.Split("/")[1]
                } else {
                    $TeamSearch["Name"] = $Team
                }
                $Team = Get-AnsibleTeam @TeamSearch -AnsibleTower $AnsibleTower

                if($Team.Count -gt 1) {
                    $TeamList = ($Team | ForEach-Object {
                        "$($_.organization)/$($_.Name)"
                    }) -join ", "
                    if(!$Force -and !$PSCmdlet.ShouldContinue("Grant role to multiple teams? (Use -Force to bypass prompt)", "Multiple teams found: $TeamList")) {
                        return
                    }
                }
            }
            default {
                Write-Error -Message "Unknown type passed as -Team ($Team).  Supported values are String, Int32, and AnsibleTower.Team." -ErrorAction Stop
                return
            }
        }

        if(!$Team) {
            Write-Error -Message "No team was located using the specified search parameter." -ErrorAction Stop
            return
        }

        switch ($Role.GetType().Fullname) {
            "AnsibleTower.Role" {
                # Nothing needed
            }
            "System.Int32" {
                $Role = Get-AnsibleRole -Id $Role -AnsibleTower $AnsibleTower
            }
            "System.String" {
                $Role = Get-AnsibleRole -Team $TeamId -Name $Role -AnsibleTower $AnsibleTower
            }
            default {
                Write-Error "Unknown type passed as -Role ($Role).  Supported values are String, Int32, and AnsibleTower.Role." -ErrorAction Stop
                return
            }
        }

        if(!$Role) {
            Write-Error -Message "No role was located using the specified search parameter." -ErrorAction Stop
            return
        }

        $Team | ForEach-Object {
            $ThisTeam = $_
            $Role | ForEach-Object {
                $ThisRole = $_
                if($PSCmdlet.ShouldProcess("$($ThisRole.Resource_type)/$($ThisRole.resource_name)", "Grant $($ThisRole.Name) to $($ThisTeam.Organization)/$($ThisTeam.Name)")) {
                    Invoke-PostAnsibleInternalJsonResult -ItemType teams -ItemId $ThisTeam.Id -ItemSubItem roles -InputObject @{ id = $ThisRole.Id } -AnsibleTower $AnsibleTower
                }
            }
        }
    }
}