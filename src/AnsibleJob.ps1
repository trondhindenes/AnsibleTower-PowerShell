function Get-AnsibleJob
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$ID
    )

    if ($ID) {
        $result = Invoke-GetAnsibleInternalJsonResult -ItemType "jobs" -Id $ID;
    } else {
        $result = Invoke-GetAnsibleInternalJsonResult -ItemType "jobs";
    }

    if (!$result) {
        # Nothing returned from the call.
        return $null;
    }
    $returnObjs = @();
    foreach ($jsonorg in $result)
    {
        # Shift back to json and let newtonsoft parse it to a strongly named object instead.
        $jsonorgstring = $jsonorg | ConvertTo-Json;
        $org = $JsonParsers.ParseToJob($jsonorgstring);
        $returnObjs += $org;
        $org = $null;

    }

    # Return the job(s).
    $returnObjs;
}

function Invoke-AnsibleJob
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,Position=0,ParameterSetName='ByObj')]
        [AnsibleTower.JobTemplate]$JobTemplate,

        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,Position=0,ParameterSetName='ById')]
        [int]$ID
    )

    if ($JobTemplate)
    {
        $ThisJobTemplate = $JobTemplate
        $ID = $ThisJobTemplate.id
    }
    Else
    {
        $ThisJobTemplate = Get-AnsibleJobTemplate -id $ID;
    }

    if (!$ThisJobTemplate) {
        throw ("Job template with id [{0}] not found" -f $ID);
    }

    Write-Verbose ("Creating job from job template [{0}]" -f $ID);
    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "job_templates" -itemId $id -ItemSubItem "jobs";
    $JobID = $result.id;
    Write-Verbose ("Starting job with id [{0}]" -f $JobID);
    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "jobs" -itemId $JobId -ItemSubItem "start";
    Get-AnsibleJob -ID $JobId
}

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
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,Position=0,ParameterSetName='Job')]
        [AnsibleTower.Job]$Job,

        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,Position=0,ParameterSetName='ID')]
        [int]$ID,

        [int]$Timeout = 3600,
        [int]$Interval = 3
    )

    if ($ID) {
        $Job = Get-AnsibleJob -id $ID;
        if (!$Job) {
            throw ("Failed to get job with id [{0}]" -f $ID)
        }
    }

    Write-Verbose ("Waiting for job [{0}] to finish..." -f $Job.id);
    $startDate = Get-Date;
    $finished = $false;
    while (!$finished)
    {
        if (![string]::IsNullOrEmpty($Job.finished)) {
            Write-Verbose ("Job [{0}] finished." -f $Job.id);
            $finished = $true;
        } else {
            $timeSpan = New-TimeSpan -Start $startDate -End (Get-Date);
            Write-Verbose ("Waiting for job [{0}] to finish. Job status is [{1}]. Elapsed time is [{2}] seconds." -f $Job.id,$Job.status,[math]::Round($timeSpan.TotalSeconds));
            if ($timeSpan.TotalSeconds -ge $Timeout) {
                throw ("Timeout waiting for job [{0}] to finish" -f $Job.id);
            }

            Write-Verbose ("Sleeping [{0}] seconds..." -f $Interval);
            Start-Sleep -Seconds $Interval
        }
        $Job = Get-AnsibleJob -id $Job.id;
    }

    # Return the job object.
    $Job
}
