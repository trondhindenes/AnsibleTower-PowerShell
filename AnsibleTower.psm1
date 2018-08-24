$script:AnsibleUrl = $null;
$script:TowerApiUrl = $null;
$script:AnsibleCredential = $null;
$script:AnsibleResourceUrlCache = @{};
$script:AnsibleUseBasicAuth = $false;
$script:AnsibleBasicAuthHeaders = $null;

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

    $cachedUrl = $script:AnsibleResourceUrlCache[$Resource];
    if ($cachedUrl) {
        return $cachedUrl;
    }

    $args = @{
        Uri = $script:TowerApiUrl;
    };
    if ($script:AnsibleUseBasicAuth)
    {
        Write-Verbose "Get-AnsibleResourceUrl: Using Basic Authentication";
        $args.Add('Headers',$script:AnsibleBasicAuthHeaders);
    }
    else
    {
        Write-Verbose "Get-AnsibleResourceUrl: Using detected Authentication";
        $args.Add('Credential',$script:AnsibleCredential);
    }
    $result = Invoke-RestMethod @args;
    if (!$result) {
        throw "Failed to access the Tower api list";
    }
    if (!$result.$Resource) {
        throw ("Failed to find the url for resource [{0}]" -f $Resource);
    }

    $script:AnsibleResourceUrlCache.Add($Resource,$result.$Resource);

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

    if (!$script:AnsibleUrl -and (!$script:AnsibleCredential -or !$script:AnsibleBasicAuthHeaders)) {
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
        'Uri' = (Join-AnsibleUrl $script:AnsibleUrl,$ItemApiUrl);
        'ErrorAction' = 'Stop';
    }
    if ($id -eq $null -and $ItemSubItem -eq $null) {
        Write-Verbose "Appending ?page_size=1000 to url";
        $params.Uri +=  '?page_size=1000';
    }

    if ($script:AnsibleUseBasicAuth)
    {
        Write-Verbose "Invoke-GetAnsibleInternalJsonResult: Using Basic Authentication";
        $params.Add('Headers',$script:AnsibleBasicAuthHeaders);
    }
    else
    {
        Write-Verbose "Invoke-GetAnsibleInternalJsonResult: Using detected Authentication";
        $params.Add('Credential',$script:AnsibleCredential);
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

    if (!$script:AnsibleUrl -and (!$script:AnsibleCredential -or !$script:AnsibleBasicAuthHeaders)) {
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
        'Method' = 'Post';
        'ContentType' = 'application/json';
        'ErrorAction' = 'Stop';
    }
    if ($InputObject) {
        $params.Add("Body",($InputObject | ConvertTo-Json -Depth 99))
    }
    
    if ($script:AnsibleUseBasicAuth)
    {
        Write-Verbose "Invoke-GetAnsibleInternalJsonResult: Using Basic Authentication";
        $params.Add('Headers',$script:AnsibleBasicAuthHeaders);
    }
    else
    {
        Write-Verbose "Invoke-GetAnsibleInternalJsonResult: Using detected Authentication";
        $params.Add('Credential',$script:AnsibleCredential);
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

    if (!$script:AnsibleUrl -and (!$script:AnsibleCredential -or !$script:AnsibleBasicAuthHeaders)) {
        throw "You need to connect first, use Connect-AnsibleTower";
    }
    $ItemApiUrl = Get-AnsibleResourceUrl $ItemType

    $id = $InputObject.id

    $ItemApiUrl = Join-AnsibleUrl $ItemApiUrl, $id

    $params = @{
        'Uri' = Join-AnsibleUrl $script:AnsibleUrl, $ItemApiUrl;
        'Method' = 'Put';
        'ContentType' = 'application/json';
        'Body' = ($InputObject | ConvertTo-Json -Depth 99);
        'ErrorAction' = 'Stop';
    }

    if ($script:AnsibleUseBasicAuth)
    {
        Write-Verbose "Invoke-GetAnsibleInternalJsonResult: Using Basic Authentication";
        $params.Add('Headers',$script:AnsibleBasicAuthHeaders);
    }
    else
    {
        Write-Verbose "Invoke-GetAnsibleInternalJsonResult: Using detected Authentication";
        $params.Add('Credential',$script:AnsibleCredential);
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

    .PARAMETER UserName
    Username for connecting to AnsibleTower.

    .PARAMETER Password
    Password of type SecureString for the UserName.

    .PARAMETER PlainPassword
    Password in plain text for the UserName.

    .PARAMETER TowerUrl
    Url of the Tower host, e.g. https://ansible.mydomain.local

    .PARAMETER DisableCertificateVerification
    Disables Certificate verification. Use when Tower responds with 'troublesome' certificates, such as self-signed.

    .PARAMETER BasicAuth
    Forces the AnsibleTower module to use Basic authentication when communicating with AnsibleTower.

    .EXAMPLE
    Connect-AnsibleTower -Credential (Get-Credential) -TowerUrl 'https://ansible.domain.local'

    User is prompted for credentials and then connects to the Tower host at 'https://ansible.domain.local'. User details are displayed in the output.

    .EXAMPLE
    $me = Connect-AnsibleTower -Credential $myCredential -TowerUrl 'https://ansible.domain.local' -DisableCertificateVerification

    Connects to the Tower host at 'https://ansible.domain.local' using the credential supplied in $myCredential. Any certificate errors are ignored.
    User details beloning to the specified credential are in the $me variable.

    .EXAMPLE
    $me = Connect-AnsibleTower -UserName srvcAsnible -Password $securePassword -BasicAuth -TowerUrl 'https://ansible.domain.local'

    Connects to the Tower host at 'https://ansible.domain.local' using the specified UserName and Password. The username and password are send with each request to force basic authentication.
    #>
    param (
        [Parameter(Mandatory=$true, ParameterSetName="Credential")]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$true, ParameterSetName="SecurePassword")]
        [Parameter(ParameterSetName="PlainPassword")]
        [string]$UserName,
        [Parameter(Mandatory=$true, ParameterSetName="PlainPassword")]
        [string]$PlainPassword,
        [Parameter(Mandatory=$true, ParameterSetName="SecurePassword")]
        [securestring]$Password,

        [Parameter(Mandatory=$true)]
        [string]$TowerUrl,

        [Switch]$BasicAuth,
        
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
        [System.Uri]$uri = $TowerUrl;
        if ($uri.Scheme -eq "https")
        {
            Write-Verbose "TowerURL scheme is https. Enforcing TLS 1.2";
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
        }
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

    try
    {
        switch($PsCmdlet.ParameterSetName)
        {
            "Credential" {
                Write-Verbose "Extracting username and password from credential";
                $UserName = $Credential.UserName;
                $PlainPassword = $Credential.GetNetworkCredential().Password;
            }
            "PlainPassword" {
                Write-Verbose "Constructing credential object from UserName and PlainPassword";
                $Credential = New-Object System.Management.Automation.PSCredential ($UserName, (ConvertTo-SecureString $PlainPassword -AsPlainText -Force));
            }
            "SecurePassword" {
                Write-Verbose "Constructing credential object from UserName and SecurePassword";
                $Credential = New-Object System.Management.Automation.PSCredential ($UserName, $Password);
                $PlainPassword = $Credential.GetNetworkCredential().Password;
            }
        }

        $params = @{
            Uri = Join-AnsibleUrl $TowerApiUrl, 'me';
            ErrorAction = 'Stop';
        };
        
        if ($BasicAuth.IsPresent)
        {
            Write-Verbose "Constructing headers for Basic Authentication.";
            $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($UserName):$($PlainPassword)"));
            $headers = @{
                Authorization = "Basic $encodedCreds"
            }
            $script:AnsibleUseBasicAuth = $true;
            $params.Add('Headers', $headers);
        }
        else {
            Write-Verbose "Using credential for authentication."
            $params.Add('Credential', $Credential);
        }

        Write-Verbose "Connecting to AnsibleTower, requesting the /me function."
        $meResult = Invoke-RestMethod @params;
        if (!$meResult -or !$meResult.results) {
            throw "Could not authenticate to Tower";
        }
        $me = $JsonParsers.ParseToUser((ConvertTo-Json ($meResult.results | select -First 1)));
        Write-Verbose "Connection to AnsibleTower successful."
    }
    Catch
    {
        throw "Could not authenticate: " + $_.Exception.Message;
    }

    # Connection and login success.

    $script:AnsibleUrl = $TowerUrl;
    $script:TowerApiUrl = $TowerApiUrl;
    $script:AnsibleCredential = $Credential;
    $script:AnsibleBasicAuthHeaders = $headers;

    return $me;
}
