

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

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    $Schema = Get-SchemaForType -Type $Type -AnsibleTower $AnsibleTower

    switch($Verb) {
        "Get" {
            New-GetCmdlet -Noun $Noun -Verb $Verb -Schema $Schema -Class $Class -SchemaType $Type -ExtraPropertyInfo $ExtraPropertyInfo
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

        $ExtraPropertyInfo
    )
    PSFunction "$Verb-$Noun" -DefaultParameterSetName "PropertyFilter" {
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
            $SchemaParameters | ForEach-Object {
                $SchemaParameter = $Schema.Actions.Get."$SchemaName"
            }
@"
        `$Filter = @{}
$($Filters -join "`r`n`r`n")

        if(`$id) {
            `$Return = Invoke-GetAnsibleInternalJsonResult -ItemType "$SchemaType" -Id `$Id -AnsibleTower `$AnsibleTower
        } else {
            `$Return = Invoke-GetAnsibleInternalJsonResult -ItemType "$SchemaType" -Filter `$Filter -AnsibleTower `$AnsibleTower
        }

        if(!(`$Return)) {
            return
        }
        foreach(`$ResultObject in `$Return) {
            `$JsonString = `$ResultObject | ConvertTo-Json
            `$AnsibleObject = [AnsibleTower.JsonFunctions]::ParseTo$($Schema.Types[0])(`$JsonString)
            `$AnsibleObject.AnsibleTower = `$AnsibleTower
            Write-Output `$AnsibleObject
            `$AnsibleObject = `$Null
        }
"@
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

New-SchemaCmdlet -Type projects -Verb Get -Noun AnsibleProject -Class ([AnsibleTower.Project]) -ExtraPropertyInfo @{ Name = @{ Position = 1}; Description = @{ Position = 2}}