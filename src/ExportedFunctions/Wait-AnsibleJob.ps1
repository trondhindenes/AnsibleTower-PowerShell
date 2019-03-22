function Wait-AnsibleJob
{
    <#
    .SYNOPSIS
    Waits for an Ansible job to finish.

    .DESCRIPTION
    Waits for an Ansible job to finish by monitoring the 'finished' property of the job.
    Every Interval the job details are requested and while 'finished' is empty the job is considered to be still running.
    When the job is finished, the function returns. The caller must analyse the job state and/or result.
    Inspect the status, failed and result_output properties for more information on the job result.

    If the Timeout has expired an exception is thrown.

    .PARAMETER Job
    The Job object as returned by Get-AnsibleJob or Invoke-AnsibleJobTemplate.

    .PARAMETER ID
    The job ID.

    .PARAMETER Timeout
    The timeout in seconds to wait for the job to finish.

    .PARAMETER Interval
    The interval in seconds at which the job status is inspected.

    .EXAMPLE
    $job = Invoke-AnsibleJobTemplate 'Demo Job Template'
    Wait-AnsibleJob -ID $job.id

    Starts a new job for job template 'Demo Job Template' and then waits for the job to finish. Inspect the $job properties status, failed and result_stdout for more details.

    .EXAMPLE
    $job = Invoke-AnsibleJobTemplate 'Demo Job Template' | Wait-AnsibleJob -Interval 1

    Starts a new job for job template 'Demo Job Template' and then waits for the job to finish by polling every second. Inspect the $job properties status, failed and result_stdout for more details.

    .EXAMPLE
    $job = Invoke-AnsibleJobTemplate 'Demo Job Template' | Wait-AnsibleJob -Interval 5 -Timeout 60

    Starts a new job for job template 'Demo Job Template' and then waits for the job to finish by polling every 5 seconds. If the job did not finish after 60 seconds, an exception is thrown.
    Inspect the $job properties status, failed and result_stdout for more details.

    .OUTPUTS
    The job object.
    #>
    [CmdletBinding(DefaultParameterSetName='Job')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true,Position=0,ParameterSetName='Job')]
        [AnsibleTower.Job]$Job,

        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,Position=0,ParameterSetName='ID')]
        [int]$ID,

        [int]$Timeout = 3600,
        [int]$Interval = 3,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        if($Job) {
            $AnsibleTower = $Job.AnsibleTower
            $Id = $Job.Id
        }

        $StartDate = Get-Date

        do {
            $Job = Get-AnsibleJob -Id $Id -AnsibleTower $AnsibleTower
            if(!$Job) {
                Write-Error "Failed to get job with id [$ID]" -ErrorAction Stop
                return
            }
            if(![string]::IsNullOrEmpty($Job.Finished)) {
                Write-Verbose "Job [$($Job.Id)] finished"
            } else {
                $timespan = (Get-Date) - $startDate
                Write-Verbose "Waiting for job [$($Job.Id)] to finish.  Job status is [$($Job.Status)].  Elapsed time is [$([math]::Round($TimeSpan.TotalSeconds))] seconds."
                if ($TimeSpan.TotalSeconds -ge $Timeout) {
                    Write-Error "Timeout waiting for job [$($Job.Id)] to finish"
                    return
                }

                Write-Verbose "Sleeping [$Interval] seconds..."
                Start-Sleep -Seconds $Interval
            }
        } while (!$Job.Finished)

        # Return the job object.
        $Job
    }
}
