function Invoke-AnsibleJob
{
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,Position=0,ParameterSetName='ByObj')]
        [AnsibleTower.JobTemplate]$JobTemplate,

        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,Position=0,ParameterSetName='ById')]
        [int]$ID,

        [Parameter(ParameterSetName="ById")]
        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        if ($JobTemplate) {
            $ThisJobTemplate = $JobTemplate
            $ID = $ThisJobTemplate.id
        } Else {
            $ThisJobTemplate = Get-AnsibleJobTemplate -id $ID -AnsibleTower $AnsibleTower
        }

        if (!$ThisJobTemplate) {
            Write-Error "Job template with id [$ID] not found" -ErrorAction Stop
            return
        }

        Write-Verbose "Creating job from job template [$Id]"
        $result = Invoke-PostAnsibleInternalJsonResult -ItemType "job_templates" -itemId $id -ItemSubItem "jobs" -AnsibleTower $AnsibleTower
        $JobID = $result.id
        if(!$JobID) {
            Write-Error "Failed to create job for job template ID [$ID]" -ErrorAction Stop
            return
        }
        Write-Verbose "Starting job with id [$JobID]"
        $result = Invoke-PostAnsibleInternalJsonResult -ItemType "jobs" -itemId $JobId -ItemSubItem "start" -AnsibleTower $AnsibleTower
        Get-AnsibleJob -ID $JobId -AnsibleTower $AnsibleTower
    }
}