$script:AnsibleUrl = $null;
$script:TowerApiUrl = $null;
$script:AnsibleCredential = $null;


# Load Json
$NewtonSoftJsonPath = join-path $PSScriptRoot "AnsibleTowerClasses\AnsibleTower\AnsibleTower\bin\Release\Newtonsoft.Json.dll"
Add-Type -Path $NewtonSoftJsonPath

# Compile the .net classes
$ClassPath = Join-Path $PSScriptRoot "AnsibleTowerClasses\AnsibleTower\AnsibleTower\DataTypes.cs"
$Code = Get-Content -Path $ClassPath -Raw
Add-Type -TypeDefinition $Code -ReferencedAssemblies $NewtonSoftJsonPath

# Load the json parsers to have it handy whenever.
$JsonParsers = New-Object AnsibleTower.JsonFunctions

#D ot-source/Load the other powershell scripts
Get-ChildItem "*.ps1" -path $PSScriptRoot | where {$_.Name -notmatch "test"} |  ForEach-Object { . $_.FullName }

function Disable-CertificateVerification
{
    <#
    .SYNOPSIS
    Disables Certificate verification. Use this when using Tower with 'troublesome' certificates, such as self-signed.
    #>

    # Danm you here-strings for messing up my indendation!!
    Add-Type @" 
    using System.Net; 
    using System.Security.Cryptography.X509Certificates; 
     
    public class NoSSLCheckPolicy : ICertificatePolicy { 
        public NoSSLCheckPolicy() {} 
        public bool CheckValidationResult( 
            ServicePoint sPoint, X509Certificate cert, 
            WebRequest wRequest, int certProb) { 
            return true; 
        } 
    } 
"@ 
    [System.Net.ServicePointManager]::CertificatePolicy = new-object NoSSLCheckPolicy
}

function Join-AnsibleUrl
{
    <#
    .SYNOPSIS
    Joins url parts together into a valid Tower url.

    .PARAMETER Parts
    Url parts that will be joined together.

    .EXAMPLE
    Join-AnsibleUrl 'https://tower.domain.com','api','v1','job_templates'

    .OUTPUTS
    Combined url with a trailing slash.
    #>
    param(
        [string[]]$Parts
    )

    return (($Parts | ? { $_ } | % { $_.trim('/').trim() } | ? { $_ } ) -join '/') + '/';
}

function Get-AnsibleResourceUrl
{
    <#
    .SYNOPSIS
    Gets the url part for a Tower API resource of function.

    .PARAMETER Resource
    The resource name to get the API url for.

    .EXAMPLE
    Get-AnsibleResourceUrl 'job_templates'
    Returns: "/api/v1/job_templates/"

    .OUTPUTS
    API url part for the specified resource, e.g. "/api/v1/job_templates/"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Resource
    )

    $result = Invoke-RestMethod -Uri $script:TowerApiUrl -Credential $script:AnsibleCredential;
    if (!$result) {
        throw "Failed to access the Tower api list";
    }
    if (!$result.$Resource) {
        throw ("Failed to find the url for resource [{0}]" -f $Resource);
    }

    return $result.$Resource;
}

function Invoke-GetAnsibleInternalJsonResult
{
    param(
        [Parameter(Mandatory=$true)]
        $ItemType,

        $Id,
        $ItemSubItem
    )

    if (!$script:AnsibleUrl -or !$script:AnsibleCredential) {
        throw "You need to connect first, use Connect-AnsibleTower";
    }

    $ItemApiUrl = Get-AnsibleResourceUrl $ItemType

    if ($id) {
        $ItemApiUrl = Join-AnsibleUrl $ItemApiUrl, $id
    }

    if ($ItemSubItem) {
        $ItemApiUrl = Join-AnsibleUrl $ItemApiUrl, $ItemSubItem
    }

    $params = @{
        'Uri' = Join-AnsibleUrl $script:AnsibleUrl,$ItemApiUrl;
        'Credential' = $script:AnsibleCredential;
        'ErrorAction' = 'Stop';
    }

    Write-Verbose ("Invoke-GetAnsibleInternalJsonResult: Invoking url [{0}]" -f $params.Uri);
    $invokeResult = Invoke-RestMethod @params;
    if ($invokeResult.id) {
        return $invokeResult
    }
    Elseif ($invokeResult.results) {
        return $invokeResult.results
    }
}

Function Invoke-PostAnsibleInternalJsonResult
{
    param(
        [Parameter(Mandatory=$true)]
        $ItemType,

        $itemId,
        $ItemSubItem,
        $InputObject
    )

    if (!$script:AnsibleUrl -or !$script:AnsibleCredential) {
        throw "You need to connect first, use Connect-AnsibleTower";
    }

    $ItemApiUrl = Get-AnsibleResourceUrl $ItemType

    if ($itemId) {
        $ItemApiUrl = Join-AnsibleUrl $ItemApiUrl, $itemId
    }

    if ($ItemSubItem) {
        $ItemApiUrl = Join-AnsibleUrl $ItemApiUrl, $ItemSubItem
    }
    $params = @{
        'Uri' = Join-AnsibleUrl $script:AnsibleUrl, $ItemApiUrl;
        'Credential' = $script:AnsibleCredential;
        'Method' = 'Post';
        'ContentType' = 'application/json';
        'ErrorAction' = 'Stop';
    }
    if ($InputObject) {
        $params.Add("Body",($InputObject | ConvertTo-Json -Depth 99))
    }
    
    Write-Verbose ("Invoke-PostAnsibleInternalJsonResult: Invoking url [{0}]" -f $params.Uri);
    return Invoke-RestMethod @params
}

Function Invoke-PutAnsibleInternalJsonResult
{
    Param (
        $ItemType,
        $InputObject
    )

    if (!$script:AnsibleUrl -or !$script:AnsibleCredential) {
        throw "You need to connect first, use Connect-AnsibleTower";
    }
    $ItemApiUrl = Get-AnsibleResourceUrl $ItemType

    $id = $InputObject.id

    $ItemApiUrl = Join-AnsibleUrl $ItemApiUrl, $id

    $params = @{
        'Uri' = Join-AnsibleUrl $script:AnsibleUrl, $ItemApiUrl;
        'Credential' = $script:AnsibleCredential;
        'Method' = 'Put';
        'ContentType' = 'application/json';
        'Body' = ($InputObject | ConvertTo-Json -Depth 99);
        'ErrorAction' = 'Stop';
    }

    Write-Verbose ("Invoke-PutAnsibleInternalJsonResult: Invoking url [{0}]" -f $params.Uri);
    return Invoke-RestMethod @params;
}

function Connect-AnsibleTower
{
    <#
    .SYNOPSIS
    Connects to the Tower API and returns the user details.
    
    .PARAMETER Credential
    Credential to authenticate with at the Tower API.

    .PARAMETER TowerUrl
    Url of the Tower host, e.g. https://ansible.mydomain.local

    .PARAMETER DisableCertificateVerification
    Disables Certificate verification. Use when Tower responds with 'troublesome' certificates, such as self-signed.

    .EXAMPLE
    Connect-AnsibleTower -Credential (Get-Credential) -TowerUrl 'https://ansible.domain.local'

    User is prompted for credentials and then connects to the Tower host at 'https://ansible.domain.local'. User details are displayed in the output.

    .EXAMPLE
    $me = Connect-AnsibleTower -Credential $myCredential -TowerUrl 'https://ansible.domain.local' -DisableCertificateVerification

    Connects to the Tower host at 'https://ansible.domain.local' using the credential supplied in $myCredential. Any certificate errors are ignored.
    User details beloning to the specified credential are in the $me variable.
    #>
    param (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$true)]
        [string]$TowerUrl,

        [Switch]$DisableCertificateVerification
    )

    if ($DisableCertificateVerification)
    {
        Disable-CertificateVerification;
    }

    if ($TowerUrl -match "/api") {
        throw "Specify the URL without the /api part"    
    }

    try
    {
        Write-Verbose "Determining current Tower API version url..."
        $TestUrl = Join-AnsibleUrl $TowerUrl, 'api'
        Write-Verbose "TestUrl=$TestUrl"
        $result = Invoke-RestMethod -Uri $TestUrl -ErrorAction Stop
        if (!$result.current_version) {
            throw "Could not determine current version of Tower API";
        }
        $TowerApiUrl = Join-AnsibleUrl $TowerUrl, $result.current_version
    }
    catch
    {
       throw ("Could not connect to Tower api url: " + $_.Exception.Message);
    }
    

    Write-Verbose "Logging in to Tower..."
    try
    {
        $meUri = Join-AnsibleUrl $TowerApiUrl, 'me'
        $meResult = Invoke-RestMethod -Uri $meUri -Credential $Credential -ErrorAction Stop;
        if (!$meResult -or !$meResult.results) {
            throw "Could not authenticate to Tower";
        }
        $me = $JsonParsers.ParseToUser((ConvertTo-Json ($meResult.results | select -First 1)));
    }
    Catch
    {
        throw "Could not authenticate: " + $_.Exception.Message;
    }

    # Connection and login success.

    $script:AnsibleUrl = $TowerUrl;
    $script:TowerApiUrl = $TowerApiUrl;
    $script:AnsibleCredential = $Credential;

    return $me;
}
