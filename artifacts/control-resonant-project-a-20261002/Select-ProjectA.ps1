[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('install','restore')][string]$Action,
    [Parameter(Mandatory=$true)][string]$GameExe,
    [string]$NgxCore,
    [string]$DlssDll,
    [ValidateSet(11,13)][int]$Preset = 11,
    [switch]$AsyncInterop
)

$ErrorActionPreference = 'Stop'
$artifact = Split-Path -Parent $MyInvocation.MyCommand.Path
$package = Join-Path $artifact 'd4r-windows-rdna4-game'
$runner = Join-Path $package 'windows-game.ps1'
$zip = Join-Path $artifact 'd4r-windows-rdna4-20261002.zip'
$expected = '5b9a47e9d0c9a042567c2096eb8eaafb0a28473614b656865d794a39f5165d8e'
$download = 'https://github.com/xdfnx-dev/d4r/releases/download/windows-rdna4-dev-20261002-a346d76/d4r-windows-rdna4-20261002.zip'

if (!(Test-Path -LiteralPath $GameExe -PathType Leaf)) { throw "Game executable not found: $GameExe" }
if (!(Test-Path -LiteralPath $runner -PathType Leaf)) {
    if (!(Test-Path -LiteralPath $zip -PathType Leaf)) {
        Write-Host 'Fetching pinned native-Windows d4r package...'
        Invoke-WebRequest -Uri $download -OutFile $zip -UseBasicParsing
    }
    $actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected) { throw "d4r archive hash mismatch: $actual" }
    Expand-Archive -LiteralPath $zip -DestinationPath $package -Force
}

if ($Action -eq 'restore') {
    & $runner -Action restore -GameExe $GameExe
    exit $LASTEXITCODE
}

if (!$NgxCore -or !(Test-Path -LiteralPath $NgxCore -PathType Leaf)) { throw 'Install requires -NgxCore pointing to your local _nvngx.dll.' }
if (!$DlssDll -or !(Test-Path -LiteralPath $DlssDll -PathType Leaf)) { throw 'Install requires -DlssDll pointing to your local nvngx_dlss.dll.' }

$gameDir = Split-Path -Parent ([IO.Path]::GetFullPath($GameExe))
$projectBMarkers = @('OptiScaler.ini','OptiScaler.dll','dxgi.dll') | ForEach-Object { Join-Path $gameDir $_ } | Where-Object { Test-Path -LiteralPath $_ }
if ($projectBMarkers.Count -gt 0) {
    Write-Host 'Existing OptiScaler/proxy files detected. d4r windows-game.ps1 will preserve replaced files in its guarded backup before Project A is activated.'
}

$args = @('-GameExe',$GameExe,'-NgxCore',$NgxCore,'-DlssDll',$DlssDll,'-Preset',$Preset)
if ($AsyncInterop) { $args += '-AsyncInterop' }
& $runner @args
exit $LASTEXITCODE
