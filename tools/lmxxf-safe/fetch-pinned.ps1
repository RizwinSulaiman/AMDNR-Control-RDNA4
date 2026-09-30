param(
    [ValidateSet('strict','latest-release','latest-audited')]
    [string]$Track = 'strict',
    [string]$Destination
)

$ErrorActionPreference = 'Stop'
$pinPath = Join-Path $PSScriptRoot 'pin.json'
$pin = Get-Content -LiteralPath $pinPath -Raw | ConvertFrom-Json

switch ($Track) {
    'strict' { $commit = $pin.strict_bit_exact.commit; $fetchRef = 'refs/tags/0.35' }
    'latest-release' { $commit = $pin.latest_release.commit; $fetchRef = 'refs/tags/0.38' }
    'latest-audited' { $commit = $pin.latest_audited_main.commit; $fetchRef = 'refs/heads/main' }
}

$remote = $pin.upstream
$heads = git ls-remote $remote
if ($LASTEXITCODE -ne 0) { throw 'Unable to query lmxxf upstream.' }
if (-not (($heads -join "`n") -match [regex]::Escape($commit))) {
    # Release commits may no longer be a ref tip; verify by a bounded fetch below when materializing.
    Write-Host "Pin is not a current ref tip: $commit"
}

Write-Host "lmxxf track: $Track"
Write-Host "commit:      $commit"
Write-Host "upstream:    $remote"

if ($Destination) {
    $dest = [IO.Path]::GetFullPath($Destination)
    if (Test-Path -LiteralPath $dest) { throw "Destination already exists: $dest" }
    New-Item -ItemType Directory -Path $dest | Out-Null
    git -C $dest init --quiet
    if ($LASTEXITCODE -ne 0) { throw 'git init failed.' }
    git -C $dest remote add origin $remote
    git -C $dest -c protocol.version=2 fetch --depth=1 --filter=blob:none origin $fetchRef
    if ($LASTEXITCODE -ne 0) { throw "Pinned commit could not be fetched: $commit" }
    git -C $dest checkout --detach FETCH_HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Pinned checkout failed.' }
    $actual = (git -C $dest rev-parse HEAD).Trim()
    if ($actual -ne $commit) { throw "Pin mismatch: expected $commit, got $actual" }
    Write-Host "materialized: $dest"
}

