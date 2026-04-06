[CmdletBinding()]
param(
    [string]$Component = "dan-web",
    [string]$InstallDir = (Join-Path (Get-Location) "dan-runtime"),
    [string]$Version = "latest",
    [string]$CpaBaseUrl = "",
    [string]$CpaToken = "",
    [string]$MailApiUrl = "",
    [string]$MailApiKey = "",
    [int]$Threads = 68,
    [int]$OtpRetryCount = 12,
    [int]$OtpRetryIntervalSeconds = 5,
    [string]$WebToken = "linuxdo",
    [string]$ClientApiToken = "linuxdo",
    [int]$Port = 25666,
    [string]$DefaultProxy = ""
)

$ErrorActionPreference = 'Stop'

$repoOwner = 'uton88'
$repoName = 'dan-binary-releases'
$defaultDomainsApiUrl = 'https://gpt-up.icoa.pp.ua/v0/management/domains'

function Resolve-DomainsApiUrl {
    param([string]$BaseUrl)

    if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
        return $defaultDomainsApiUrl
    }

    $trimmed = $BaseUrl.Trim().TrimEnd('/')
    if ($trimmed.EndsWith('/v0/management/domains', [System.StringComparison]::OrdinalIgnoreCase)) {
        return $trimmed
    }
    if ($trimmed.EndsWith('/v0/management', [System.StringComparison]::OrdinalIgnoreCase)) {
        return "$trimmed/domains"
    }
    return "$trimmed/v0/management/domains"
}

switch ($Component) {
    'dan' {}
    'dan-web' {}
    'dan-token-refresh' {}
    default { throw "Unsupported component: $Component" }
}

switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
    'X64' { $arch = 'amd64' }
    'Arm64' { $arch = 'arm64' }
    default { throw "Unsupported architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)" }
}

$assetName = "$Component-windows-$arch.exe"
$releaseBase = if ($Version -eq 'latest') {
    "https://github.com/$repoOwner/$repoName/releases/latest/download"
} else {
    "https://github.com/$repoOwner/$repoName/releases/download/$Version"
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $InstallDir 'config') | Out-Null

$binaryPath = Join-Path $InstallDir "$Component.exe"
$shaPath = Join-Path $InstallDir 'SHA256SUMS.txt'

Invoke-WebRequest "$releaseBase/$assetName" -OutFile $binaryPath
Invoke-WebRequest "$releaseBase/SHA256SUMS.txt" -OutFile $shaPath

$expectedHash = (Select-String -Path $shaPath -Pattern ([regex]::Escape($assetName) + '$')).Line.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)[0]
$actualHash = (Get-FileHash -Algorithm SHA256 -Path $binaryPath).Hash.ToLowerInvariant()
if ($actualHash -ne $expectedHash.ToLowerInvariant()) {
    throw "Checksum verification failed for $assetName"
}

$domainsApiUrl = Resolve-DomainsApiUrl $CpaBaseUrl
Write-Host "Fetching domains from: $domainsApiUrl"
$domainsPayload = Invoke-RestMethod $domainsApiUrl
$domains = @($domainsPayload.domains | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($domains.Count -eq 0) {
    throw "Domains API returned an empty or invalid domains list: $domainsApiUrl"
}

$config = [ordered]@{
    ak_file = 'ak.txt'
    rk_file = 'rk.txt'
    token_json_dir = 'codex_tokens'
    server_config_url = ''
    server_api_token = ''
    domain_report_url = ''
    upload_api_url = 'https://example.com/v0/management/auth-files'
    upload_api_token = 'replace-me'
    oauth_issuer = 'https://auth.openai.com'
    oauth_client_id = 'app_EMoamEEZ73f0CkXaXp7hrann'
    oauth_redirect_uri = 'http://localhost:1455/auth/callback'
    enable_oauth = $true
    oauth_required = $true
}
$config | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $InstallDir 'config.json')

$webConfig = [ordered]@{
    target_min_tokens = 15000
    auto_fill_start_gap = 1
    check_interval_minutes = 1
    manual_default_threads = $Threads
    manual_register_retries = 3
    otp_retry_count = $OtpRetryCount
    otp_retry_interval_seconds = $OtpRetryIntervalSeconds
    web_token = $WebToken
    client_api_token = $ClientApiToken
    client_notice = ''
    minimum_client_version = ''
    enabled_email_domains = $domains
    mail_domain_options = $domains
    default_proxy = $DefaultProxy
    use_registration_proxy = -not [string]::IsNullOrWhiteSpace($DefaultProxy)
    cpa_base_url = $CpaBaseUrl
    cpa_token = $CpaToken
    mail_api_url = $MailApiUrl
    mail_api_key = $MailApiKey
    port = $Port
}
$webConfig | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $InstallDir 'config\web_config.json')

Write-Host ""
Write-Host "Installed to: $InstallDir"
Write-Host "Binary: $binaryPath"
Write-Host "Config: $(Join-Path $InstallDir 'config\web_config.json')"
Write-Host ""
Write-Host "Start command:"
Write-Host "  Set-Location '$InstallDir'; .\$Component.exe"
