#requires -Modules FnDsl

function Get-SchemaForType {
    param(
        [Parameter(Mandatory=$true)]
        $Type,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    Invoke-AnsibleRequest -FullPath api/v2/$type/?format=json -Method OPTIONS
}

function New-SchemaCmdlet {
    param(
        [Parameter(Mandatory=$true)]
        $Type,

        [Parameter(Mandatory=$true)]
        [ValidateSet("Get","Set","New")]
        $Verb,

        [Parameter(Mandatory=$true)]
        $Noun,

        $Class,

        $ExcludeProperties,

        $ExtraPropertyInfo,

        $Description,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    $Schema = Get-SchemaForType -Type $Type -AnsibleTower $AnsibleTower

    switch($Verb) {
        "Get" {
            New-GetCmdlet -Noun $Noun -Verb $Verb -Schema $Schema -Class $Class -SchemaType $Type -ExtraPropertyInfo $ExtraPropertyInfo -ExcludeProperties $ExcludeProperties -Description $Description
        }
        "Set" {
        }
        "New" {
        }
    }
}

function New-GetCmdlet {
    param(
        [Parameter(Mandatory=$true)]
        $Noun,

        [Parameter(Mandatory=$true)]
        $Verb,

        $ExcludeProperties = @("type"),

        $Class,

        $Schema,

        $SchemaType,

        $Description,

        $ExtraPropertyInfo
    )
    PSFunction "$Verb-$Noun" -Description $Description -DefaultParameterSetName "PropertyFilter" {
        $SchemaParameters = $Schema.Actions.Get | Get-Member -MemberType Properties
        $Filters = @()

        $SchemaParameters | ForEach-Object {
            $PSName = ToCamlCase $_.Name
            $SchemaName = $_.Name
            $SchemaParameter = $Schema.Actions.Get."$SchemaName"
            $Filterable = $SchemaParameter.Filterable
            $Type = MapType $SchemaParameter
            if($Filterable -and $ExcludeProperties -NotContains $SchemaName -and $Type -in @("String","Bool","Object")) {
                $ExtraProperties = @{}
                if($SchemaParameter.Type -eq "Choice") {
                    $ExtraProperties["ValidateSet"] = $SchemaParameter.choices | ForEach-Object {$_[0]}
                }
                if($PSName -eq "Id") {
                    $ExtraProperties["ParameterSetName"] = "ById"
                } else {
                    $ExtraProperties["ParameterSetName"] = "PropertyFilter"
                }
                if($ExtraPropertyInfo.ContainsKey($PSName)) {
                    $ExtraPropertyInfo[$PSName].Keys | ForEach-Object {
                        $ExtraProperties[$_] = $ExtraPropertyInfo[$PSName][$_]
                    }
                }
                PSParam $PSName -Type $Type @ExtraProperties -HelpText $SchemaParameter.help_text
                $Filters += AnsibleGetFilter -PSName $PSName -SchemaName $SchemaName -PSType $Type
            }

        }
        PSParam -Name "Id" -ParameterSetName "ById" -Type Int32 -HelpText "The ID of a specific $Noun to get"
        PSParam -Name "AnsibleTower" -DefaultValue '$Global:DefaultAnsibleTower' -HelpText "The Ansibl Tower instance to run against.  If no value is passed the command will run against `$Global:DefaultAnsibleTower."
        PSEnd {
            PS$ Filter "@{}"

            ($Filters -join "`r`n`r`n") + "`r`n"

            PSIf {PS$ id} {
                PS$ "Return" (PSExec Invoke-GetAnsibleInternalJsonResult -ItemType `"$SchemaType`" -Id (PS$ Id) -AnsibleTower (PS$ AnsibleTower))
            } {
                PS$ "Return" (PSExec Invoke-GetAnsibleInternalJsonResult -ItemType `"$SchemaType`" -Filter (PS$ Filter) -AnsibleTower (PS$ AnsibleTower))
            } -LB

            PSIf { "!(`$Return)" } {
                PSExec return
            }
            PSForeach {PSExec (PS$ ResultObject) in (PS$ Return)} {
                PS$ JsonString (PSExec (PS$ ResultObject) "|" ConvertTo-Json)
                PS$ AnsibleObject "[AnsibleTower.JsonFunctions]::ParseTo$($Schema.Types[0])(`$JsonString)"
                PS$ AnsibleObject.AnsibleTower (PS$ AnsibleTower)
                PSExec Write-Output (PS$ AnsibleObject)
                PS$ AnsibleObject (PS$ Null)
            }
        }
    }
}

function ToCamlCase {
  param(
    $string
  )
  ($String.Split("_") | ForEach-Object {
    $_.Substring(0,1).ToUpper() + $_.Substring(1)
  }) -Join ""
}

function MapType {
    param(
        $Property
    )
    switch($Property.Type) {
        "boolean" {
            "bool"
        }
        "choice" {
            "string"
        }
        "datetime" {
            "DateTime"
        }
        "field" {
            "Object"
        }
        "integer" {
            "Int32"
        }
        "object" {
            "Object"
        }
        "string" {
            "String"
        }
    }
}

function AnsibleGetFilter {
    param(
        $PSName,
        $SchemaName,
        $PSType
    )
    switch($PSType) {
        "string" {
@"
        if(`$PSBoundParameters.ContainsKey("$PSName")) {
            if(`$$PSName.Contains("*")) {
                `$Filter["${SchemaName}__iregex"] = `$$PSName.Replace("*", ".*")
            } else {
                `$Filter["$SchemaName"] = `$$PSName
            }
        }
"@
        }
        "bool" {
@"
        if(`$PSBoundParameters.ContainsKey("$PSName")) {
            `$Filter["$SchemaName"] = `$$PSName
        }
"@
        }
        "object" {
@"
        if(`$PSBoundParameters.ContainsKey("$PSName")) {
            switch(`$$PSName.GetType().Fullname) {
                "AnsibleTower.$PSName" {
                    `$Filter["$SchemaName"] = `$$PSName.Id
                }
                "System.Int32" {
                    `$Filter["$SchemaName"] = `$$PSName
                }
                "System.String" {
                    `$Filter["${SchemaName}__name"] = `$$PSName
                }
                default {
                    Write-Error "Unknown type passed as -$PSName (`$_).  Supported values are String, Int32, and AnsibleTower.$PSName." -ErrorAction Stop
                    return
                }
            }
        }
"@
        }
        default {
            Write-Warning "Cannot create filter for type $_"
        }
    }
}

# New-SchemaCmdlet -Type projects -Verb Get -Noun AnsibleProject -Class ([AnsibleTower.Project]) -ExtraPropertyInfo @{ Name = @{ Position = 1}; Description = @{ Position = 2}} -Description "Gets projects from ansible tower." -ExcludeProperties "Type"

# New-SchemaCmdlet -Type teams -Verb Get -Noun AnsibleTeam -Class ([AnsibleTower.Team]) -ExtraPropertyInfo @{ Name = @{ Position = 1}; Description = @{ Position = 2}}
# New-SchemaCmdlet -Type credentials -Verb Get -Noun AnsibleCredential -Class ([AnsibleTower.Credential]) -ExtraPropertyInfo @{ Name = @{ Position = 1}; Description = @{ Position = 2}} -ExcludeProperties Type,Inputs -Description "Gets credentials configured in Ansible Tower."
