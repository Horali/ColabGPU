# Helper script to manage and execute on the Google Colab GPU instance
param(
    [string]$HostName,
    [string]$SetHost,
    [string]$Push,
    [string]$Pull,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Command
)

$Workspace = $PSScriptRoot
$Cloudflared = Join-Path $Workspace "cloudflared.exe"
$Key = Join-Path $Workspace "colab_key"
$HostFile = Join-Path $Workspace ".host"

# Handle -SetHost
if ($SetHost) {
    $cleanHost = $SetHost -replace '^https?://', '' -replace '/.*$', ''
    Set-Content -Path $HostFile -Value $cleanHost
    Write-Host "Updated Colab tunnel host to: $cleanHost" -ForegroundColor Green
    exit 0
}

# Resolve HostName
if (-not $HostName) {
    if (Test-Path $HostFile) {
        $HostName = (Get-Content $HostFile -Raw).Trim()
    } else {
        $HostName = "talks-adventure-refers-href.trycloudflare.com"
    }
}

# Auto-download cloudflared if missing
if (-not (Test-Path $Cloudflared)) {
    Write-Host "cloudflared.exe not found. Downloading..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe" -OutFile $Cloudflared
}

# Auto-generate SSH key if missing
if (-not (Test-Path $Key)) {
    Write-Host "colab_key not found. Generating new SSH key pair..." -ForegroundColor Cyan
    & ssh-keygen -t ed25519 -f $Key -N '""'
    Write-Host "New key created! Add this public key to Colab:" -ForegroundColor Yellow
    Get-Content "$Key.pub"
    exit 0
}

$Proxy = "`"$Cloudflared`" access ssh --hostname %h"

if ($Push) {
    Write-Host "Uploading $Push to Colab /content/..." -ForegroundColor Cyan
    & scp -i $Key -o StrictHostKeyChecking=no -o "ProxyCommand=$Proxy" $Push "root@${HostName}:/content/"
    exit $LASTEXITCODE
}

if ($Pull) {
    Write-Host "Downloading $Pull from Colab..." -ForegroundColor Cyan
    & scp -i $Key -o StrictHostKeyChecking=no -o "ProxyCommand=$Proxy" "root@${HostName}:${Pull}" .
    exit $LASTEXITCODE
}

if ($Command.Count -gt 0) {
    $cmdString = $Command -join " "
    & ssh -i $Key -o StrictHostKeyChecking=no -o "ProxyCommand=$Proxy" "root@$HostName" $cmdString
} else {
    & ssh -i $Key -o StrictHostKeyChecking=no -o "ProxyCommand=$Proxy" "root@$HostName"
}
