function Get-AnsibleJobTemplateID
{
    <#
    .SYNOPSIS
    Gets the job template ID from a job template name.

    .EXAMPLE
    Get-AnsibleJobTemplateID -Name 'Demo Job Template'

    .EXAMPLE
    'Demo Job Template' | Get-AnsibleJobTemplateID

    .OUTPUTS
    The job ID.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$Name
    )

	# We should be passing a search term here, prevents from passing all jobs via the REST call.
    (Get-AnsibleJobTemplate | Where-Object { $_.name -eq $Name }).id
}

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
    [CmdletBinding(DefaultParameterSetName='Name')]
    Param (
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='Name')]
        [string]$Name,

        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='ID')]
        [int]$ID
    )

    if ($Name) {
        $ID = Get-AnsibleJobTemplateID -Name $Name
        if (!$ID) {
            throw ("Failed to get the ID for job template named [{0}]" -f $Name)
        }
    }

    if ($ID) {
        $return = Invoke-GetAnsibleInternalJsonResult -ItemType "job_templates" -Id $ID
    } else {
        $return = Invoke-GetAnsibleInternalJsonResult -ItemType "job_templates"
    }

    if (!$return)
    {
        # Nothing returned from the call
        return
    }

    $returnObjs = @()
    foreach ($jsonorg in $return)
    {
        # Shift back to json and let newtonsoft parse it to a strongly named object instead
        $jsonorgstring = $jsonorg | ConvertTo-Json
        $org = $JsonParsers.ParseToJobTemplate($jsonorgstring)
        $returnObjs += $org;
        $org = $null

    }
    #return the things
    $returnObjs
}


function Invoke-AnsibleJobTemplate
{
    <#
    .SYNOPSIS
    Runs an Ansible job template.

	.PARAMETER Name
	Name of the Ansible job template.

	.PARAMETER ID
	ID of the Ansible job template.

	.PARAMETER Data
	Any additional data to be supplied to Tower in order to run the job template. Most common is "extra_vars".
	Supply a normal Powershell hash table. It will be converted to JSON. See the examples for more information.

    .EXAMPLE
    Invoke-AnsibleJobTemplate -Name 'Demo Job Template'

    Runs a job for job template named 'Demo Job Template'.

    .EXAMPLE
    $job = Invoke-AnsibleJobTemplate -ID 5

    Runs a job for job template with ID 5.

    .EXAMPLE
    $jobTemplateData = @{
        "extra_vars" = @{
            'var1' = 'value1';
            'var2' = 'value2';
        };
    }
    $job = Invoke-AnsibleJobTemplate -Name 'My Ansible Job Template' -Data $jobTemplateData

    Launches job template named 'My Ansible Job Template' and passes extra variables for the job to run with.

    .OUTPUTS
    Strongly typed job object.
    #>

    [CmdletBinding(DefaultParameterSetName='Name')]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='Name')]
        [string]$Name,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='ID')]
        [int]$ID,

		[Object]$Data
    )

    if ($Name) {
        $ID = Get-AnsibleJobTemplateID -Name $Name
        if (!$ID) {
            throw ("Failed to get the ID for job template named [{0}]" -f $Name)
        }
    }

	$params = @{
		ItemType = 'job_templates';
		itemId = $ID;
		ItemSubItem = 'launch';
	};
	if ($Data) {
		$params.Add('InputObject', $Data);
	}
    $result = Invoke-PostAnsibleInternalJsonResult @params;
    if (!$result -and !$result.id) {
        throw ("Failed to start job for job template ID [{0}]" -f $ID);
    }
    Get-AnsibleJob -id $result.id
}
