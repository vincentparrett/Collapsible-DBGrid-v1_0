param(
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$bds = Get-Process bds -ErrorAction SilentlyContinue
if ($bds -and -not $Force) {
  Write-Warning "Delphi IDE is running and may lock package BPL files. Close bds.exe or rerun with -Force."
  exit 2
}

& (Join-Path $PSScriptRoot "build_components.ps1")
