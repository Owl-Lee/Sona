<#!
.SYNOPSIS
Builds the Windows Release and refreshes the desktop shortcut.
#>

[CmdletBinding()]
param()

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$flutter = Join-Path $projectRoot '..\work\flutter-sdk\flutter\bin\flutter.bat'
$python = 'C:\Users\RebootBase\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'

if (-not (Test-Path -LiteralPath $flutter -PathType Leaf)) {
  throw "Bundled Flutter SDK was not found: $flutter"
}
if (-not (Test-Path -LiteralPath $python -PathType Leaf)) {
  throw "Bundled Python runtime was not found: $python"
}

& $python (Join-Path $PSScriptRoot 'prepare_windows_icon.py')
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& $flutter build windows --release
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& (Join-Path $PSScriptRoot 'update_windows_desktop_shortcut.ps1')
