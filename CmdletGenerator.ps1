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
            New-SetCmdlet -Noun $Noun -Verb $Verb -Schema $Schema -Class $Class -SchemaType $Type -ExtraPropertyInfo $ExtraPropertyInfo -ExcludeProperties $ExcludeProperties -Description $Description
        }
        "New" {
            New-NewCmdlet -Noun $Noun -Verb $Verb -Schema $Schema -Class $Class -SchemaType $Type -ExtraPropertyInfo $ExtraPropertyInfo -ExcludeProperties $ExcludeProperties -Description $Description
        }
    }
}

function New-SetCmdlet {
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
    Write-Debug "Available actions $($Schema.Actions)"
    _Function "$Verb-$Noun" -Description $Description -SupportsShouldProcess {
        $SchemaParameters = $Schema.Actions.Post | Get-Member -MemberType Properties
        Write-Debug "Availabel parameters $($SchemaParameters.Name)"

        _Parameter Id -Type Int32 -ValueFromPipelineByPropertyName -Mandatory -ParameterSetName "ById" -HelpText "The ID of the $SchemaType to update"
        _Parameter InputObject -Type $Class -ValueFromPipeline -Mandatory -ParameterSetName "ByObject" -HelpText "The object to update"

        $SchemaParameters | ForEach-Object {
            Write-Debug "Checking schema parameter $($_.Name)"
            $PSName = ToCamlCase $_.Name
            $SchemaName = $_.Name
            $SchemaParameter = $Schema.Actions.Post."$SchemaName"
            $Mandatory = $SchemaParameter.Required
            $Type = MapType $SchemaParameter

            $ExtraProperties = @{}
            if($ExtraPropertyInfo.ContainsKey($PSName)) {
                $ExtraPropertyInfo[$PSName].Keys | ForEach-Object {
                    $ExtraProperties[$_] = $ExtraPropertyInfo[$PSName][$_]
                }
            }

            _Parameter $PSName -Type $Type -HelpText $SchemaParameter.Help_Text @ExtraProperties
        }
        _Parameter -Name "AnsibleTower" -DefaultValue '$Global:DefaultAnsibleTower' -HelpText "The Ansible Tower instance to run against.  If no value is passed the command will run against `$Global:DefaultAnsibleTower."

        _process {
            _if {_$ Id} {
                _$ ThisObject (_ "Get-$Noun" -Id (_$ Id) -AnsibleTower (_$ AnsibleTower))
            } {
                _$ AnsibleTower (_$ InputObject.AnsibleTower)
                PSLB
                _$ ThisObject (_ "Get-$Noun" -Id (_$ InputObject.Id) -AnsibleTower (_$ AnsibleTower))
            } -lb

            $SchemaParameters | ForEach-Object {
                $PSName = ToCamlCase $_.Name
                $SchemaName = $_.Name
                _if {_$ $PSName} {
                    _$ ThisObject.$SchemaName (_$ $PSName)
                } -lb
            }

            _if { "`$PSCmdlet.ShouldProcess(`$AnsibleTower, `"Update $SchemaType `$(`$ThisObject.Id)`")" } {
                _$ Result (_ Invoke-PutAnsibleInternalJsonResult -ItemType "$SchemaType" -InputObject (_$ ThisObject) -AnsibleTower (_$ AnsibleTower))
                PSLB
                _if { _$ Result } {
                    _$ JsonString (_ ConvertTo-Json -InputObject (_$ Result))
                    PSLB
                    $ClassName = $Class.Split(".")[1]
                    _$ AnsibleObject "[AnsibleTower.JsonFunctions]::ParseTo${ClassName}(`$JsonString)"
                    PSLB
                    _$ AnsibleObject.AnsibleTower (_$ AnsibleTower)
                    PSLB
                    _$ AnsibleObject
                }
            }
        }
    }
}

function New-NewCmdlet {
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
    _Function "$Verb-$Noun" -Description $Description {
        $SchemaParameters = $Schema.Actions.Post | Get-Member -MemberType Properties

        $SchemaParameters | ForEach-Object {
            $PSName = ToCamlCase $_.Name
            $SchemaName = $_.Name
            $SchemaParameter = $Schema.Actions.Post."$SchemaName"
            $Mandatory = $SchemaParameter.Required
            $Type = MapType $SchemaParameter

            $ExtraProperties = @{}
            if($ExtraPropertyInfo.ContainsKey($PSName)) {
                $ExtraPropertyInfo[$PSName].Keys | ForEach-Object {
                    $ExtraProperties[$_] = $ExtraPropertyInfo[$PSName][$_]
                }
            }

            _Parameter $PSName -Type $Type -HelpText $SchemaParameter.Help_Text @ExtraProperties
            _Parameter -Name "AnsibleTower" -DefaultValue '$Global:DefaultAnsibleTower' -HelpText "The Ansible Tower instance to run against.  If no value is passed the command will run against `$Global:DefaultAnsibleTower."
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
    _Function "$Verb-$Noun" -Description $Description -DefaultParameterSetName "PropertyFilter" {
        $SchemaParameters = $Schema.Actions.Get | Get-Member -MemberType Properties
        $Filters = @()

        $SchemaParameters | ForEach-Object {
            $PSName = ToCamlCase $_.Name
            $SchemaName = $_.Name
            $SchemaParameter = $Schema.Actions.Get."$SchemaName"
            $Filterable = $SchemaParameter.Filterable
            $Type = MapType $SchemaParameter
            if($Filterable -and $ExcludeProperties -NotContains $SchemaName -and $Type -in @("String","Bool","Object","Switch")) {
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
                _Parameter $PSName -Type $Type @ExtraProperties -HelpText $SchemaParameter.help_text
                $Filters += AnsibleGetFilter -PSName $PSName -SchemaName $SchemaName -PSType $Type
            }

        }
        $IdExtras = @{}
        if($ExtraPropertyInfo.ContainsKey("Id")) {
            $ExtraPropertyInfo["Id"].Keys | ForEach-Object {
                $IdExtras[$_] = $ExtraPropertyInfo["Id"][$_]
            }
        }
        _Parameter -Name "Id" -ParameterSetName "ById" -Type Int32 -HelpText "The ID of a specific $Noun to get" @IdExtras
        _Parameter -Name "AnsibleTower" -DefaultValue '$Global:DefaultAnsibleTower' -HelpText "The Ansible Tower instance to run against.  If no value is passed the command will run against `$Global:DefaultAnsibleTower."
        _End {
            _$ Filter "@{}"

            ($Filters -join "`r`n`r`n") + "`r`n"

            _If {_$ id} {
                _$ "Return" (_ Invoke-GetAnsibleInternalJsonResult -ItemType `"$SchemaType`" -Id (_$ Id) -AnsibleTower (_$ AnsibleTower))
            } {
                _$ "Return" (_ Invoke-GetAnsibleInternalJsonResult -ItemType `"$SchemaType`" -Filter (_$ Filter) -AnsibleTower (_$ AnsibleTower))
            } -LB

            _If { "!(`$Return)" } {
                _ return
            }
            _Foreach {_ (_$ ResultObject) in (_$ Return)} {
                _$ JsonString (_ (_$ ResultObject) "|" ConvertTo-Json)
                _$ AnsibleObject "[AnsibleTower.JsonFunctions]::ParseTo$($Schema.Types[0])(`$JsonString)"
                _$ AnsibleObject.AnsibleTower (_$ AnsibleTower)
                _ Write-Output (_$ AnsibleObject)
                _$ AnsibleObject (_$ Null)
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
            "switch"
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
        "switch" {
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

<#
$Credential = @{
    Type = "credential"
    Verb = "Get"
    Noun = "AnsibleCredential"
    Class = "AnsibleTower.Credential"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Description = @{ Position = 2}
    }
    ExcludeProperties = @("Type","Inputs")
    Description = "Gets credentials configured in Ansible Tower."
}
New-SchemaCmdlet @Credential
#>

<#
$CredentialType = @{
    Type = "credential_types"
    Verb = "Get"
    Noun = "AnsibleCredentialType"
    Class = "AnsibleTower.CredentialType"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Description = @{ Position = 2}
        Kind = @{ Position = 3}
    }
    ExcludeProperties = @("Type")
    Description = "Gets credential types configured in Ansible Tower."
}
New-SchemaCmdlet @CredentialType
#>

<#
$Inventory = @{
    Type = "inventories"
    Verb = "Get"
    Noun = "AnsibleInventory"
    Class = "AnsibleTower.Inventory"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Description = @{ Position = 2}
        Organization = @{ Position = 3}
    }
    ExcludeProperties = @("Type")
    Description = "Gets inventories defined in Ansible Tower."
}
New-SchemaCmdlet @Inventory
#>


<#
$AHost = @{
    Type = "hosts"
    Verb = "Get"
    Noun = "AnsibleHost"
    Class = "AnsibleTower.Host"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Inventory = @{ Position = 2}
        Group = @{ Position = 3}
        Id = @{ ValueFromPipelineByPropertyName = $true }
    }
    ExcludeProperties = @("type","last_job_host_summary")
    Description = "Gets hosts defined in Ansible Tower."
}
New-SchemaCmdlet @AHost
#>

<#
$Job = @{
    Type = "jobs"
    Verb = "Get"
    Noun = "AnsibleJob"
    Class = "AnsibleTower.Job"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Inventory = @{ Position = 2}
        Project = @{ Position = 3}
        Id = @{ ValueFromPipelineByPropertyName = $true }
    }
    ExcludeProperties = @("type","artifacts","start_at_task")
    Description = "Gets job status from Ansible Tower."
}
New-SchemaCmdlet @Job
#>

<#
$Schedule = @{
    Type = "schedules"
    Verb = "Get"
    Noun = "AnsibleSchedule"
    Class = "AnsibleTower.Schedule"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Inventory = @{ Position = 2}
        Project = @{ Position = 3}
    }
    ExcludeProperties = @("type","extra_data")
    Description = "Gets schedules defined in Ansible Tower."
}
New-SchemaCmdlet @Schedule
#>

<#
$WorkflowJob = @{
    Type = "workflow_jobs"
    Verb = "Get"
    Noun = "AnsibleWorkflowJob"
    Class = "AnsibleTower.WorkflowJob"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Inventory = @{ Position = 2}
        Project = @{ Position = 3}
    }
    ExcludeProperties = @("type")
    Description = "Gets workflow jobs defined in Ansible Tower."
}
New-SchemaCmdlet @WorkflowJob
#>

<#
$WorkflowJobTemplate = @{
    Type = "workflow_job_templates"
    Verb = "Get"
    Noun = "AnsibleWorkflowJobTemplate"
    Class = "AnsibleTower.WorkflowJobTemplate"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Inventory = @{ Position = 2}
        Organization = @{ Position = 3}
    }
    ExcludeProperties = @("type")
    Description = "Gets workflow job templates defined in Ansible Tower."
}
New-SchemaCmdlet @WorkflowJobTemplate
#>

<#
$NewGroup = @{
    Type = "groups"
    Verb = "New"
    Noun = "AnsibleGroup"
    Class = "AnsibleTower.Group"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Inventory = @{ Position = 2}
        Organization = @{ Position = 3}
    }
    ExcludeProperties = @("type")
    Description = "Creates a new group in an inventory in Ansible Tower."
}
New-SchemaCmdlet @NewGroup
#>


<#
$SetProject = @{
    Type = "projects"
    Verb = "Set"
    Noun = "AnsibleProject"
    Class = "AnsibleTower.Project"
    ExtraPropertyInfo = @{
        Name = @{ Position = 1};
        Inventory = @{ Position = 2}
        Organization = @{ Position = 3}
    }
    ExcludeProperties = @("type")
    Description = "Updates an existing project in Ansible Tower."
}
New-SchemaCmdlet @SetProject
#>