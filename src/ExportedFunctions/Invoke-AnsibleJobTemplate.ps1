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

    [CmdletBinding(DefaultParameterSetName='Filter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='Filter')]
        [string]$Name,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName='ID')]
        [int]$ID,

		[Object]$Data,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        if ($Name) {
            $ID = (Get-AnsibleJobTemplate -Name $Name -AnsibleTower $AnsibleTower).Id
            if (!$ID) {
                Write-Error "Failed to get the ID for job template named [$Name]" -ErrorAction Stop
                return
            }
        }

        $params = @{
            ItemType = 'job_templates'
            itemId = $ID
            ItemSubItem = 'launch'
        }
        if ($Data) {
            $params.Add('InputObject', $Data)
        }
        $result = Invoke-PostAnsibleInternalJsonResult @params -AnsibleTower $AnsibleTower
        if (!$result -and !$result.id) {
            Write-Error "Failed to start job for job template ID [$ID]" -ErrorAction Stop
            return
        } else {
            Get-AnsibleJob -id $result.id -AnsibleTower $AnsibleTower
        }
    }
}