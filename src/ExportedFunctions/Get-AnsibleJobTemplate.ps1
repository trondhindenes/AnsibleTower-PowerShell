function Get-AnsibleJobTemplate
{
    <#
    .SYNOPSIS
    Gets one or all job templates.

    .EXAMPLE
    Get-AnsibleJobTemplate

    Gets all job templates.

    .EXAMPLE
    Get-AnsibleJobTemplate | where { $_.project -eq 4 }

    Gets all job templates that belong to project ID 4.

    .EXAMPLE
    Get-AnsibleJobTemplate 'Demo Job Template'

    Gets details about job template named 'Demo Job Template'.

    .EXAMPLE
    $jobTemplate = Get-AnsibleJobTemplate -ID 5

    .OUPUTS
    Strongly typed job template object(s).
    #>
    [CmdletBinding(DefaultParameterSetName='Filter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='Filter')]
        [string]$Name,

        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='ID')]
        [int]$ID,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("Name")) {
            if($Name.Contains("*")) {
                $Filter["name__iregex"] = $Name.Replace("*", ".*")
            } else {
                $Filter["name"] = $Name
            }
        }

        if ($ID) {
            $return = Invoke-GetAnsibleInternalJsonResult -ItemType "job_templates" -Id $ID -AnsibleTower $AnsibleTower
        } else {
            $return = Invoke-GetAnsibleInternalJsonResult -ItemType "job_templates" -AnsibleTower $AnsibleTower -Filter $Filter
        }

        if (!$return)
        {
            # Nothing returned from the call
            return
        }

        foreach ($ResultObject in $return)
        {
            # Shift back to json and let newtonsoft parse it to a strongly named object instead
            $JsonString = $ResultObject | ConvertTo-Json
            $AnsibleObject = $JsonParsers.ParseToJobTemplate($JsonString)
            $AnsibleObject.AnsibleTower = $AnsibleTower
            Write-Output $AnsibleObject
            $AnsibleObject = $null
        }
    }
}