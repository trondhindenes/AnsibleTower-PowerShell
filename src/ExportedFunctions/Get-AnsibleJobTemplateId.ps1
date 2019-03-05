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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$Name,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )

    Write-Warning "Get-AnsibleJobTemplateID is deprecated.  Use (Get-AnsibleJobTemplate -Name '').Id instead.  This command will be removed in a future version."

    (Get-AnsibleJobTemplate -Name $Name -AnsibleTower $AnsibleTower).id
}