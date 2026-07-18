#requires -Version 5
<#
.SYNOPSIS
    Generate strong random credentials as Docker secret files under ./secrets.
.DESCRIPTION
    Creates mysql_root_password.txt and mysql_password.txt if they do not
    already exist. Existing files are left untouched so credentials are never
    silently overwritten. Files are written without a trailing newline.
.EXAMPLE
    ./scripts/generate-secrets.ps1
.EXAMPLE
    ./scripts/generate-secrets.ps1 -Length 40
#>
[CmdletBinding()]
param(
    [ValidateRange(16, 128)]
    [int]$Length = 32
)

$ErrorActionPreference = 'Stop'

$root       = Split-Path -Parent $PSScriptRoot
$secretsDir = Join-Path $root 'secrets'
New-Item -ItemType Directory -Force -Path $secretsDir | Out-Null

function New-Password {
    param([int]$Len)
    $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $bytes = New-Object 'byte[]' $Len
        $rng.GetBytes($bytes)
        -join ($bytes | ForEach-Object { $alphabet[$_ % $alphabet.Length] })
    }
    finally {
        $rng.Dispose()
    }
}

foreach ($name in @('mysql_root_password.txt', 'mysql_password.txt')) {
    $path = Join-Path $secretsDir $name
    if (Test-Path $path) {
        Write-Host "skip   $name (already exists)" -ForegroundColor Yellow
        continue
    }
    $password = New-Password -Len $Length
    # WriteAllText writes no trailing newline — important for MySQL's *_FILE vars.
    [System.IO.File]::WriteAllText($path, $password, [System.Text.UTF8Encoding]::new($false))
    Write-Host "wrote  $name" -ForegroundColor Green
}

Write-Host ""
Write-Host "Secret files are in $secretsDir (git-ignored)." -ForegroundColor Cyan
Write-Host "Next: docker compose up -d" -ForegroundColor Cyan
