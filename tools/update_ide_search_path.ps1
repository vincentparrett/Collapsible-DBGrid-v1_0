param(
  [string]$BdsVersion = "37.0"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$bin = Join-Path $root "bin"
$dcp = Join-Path $env:PUBLIC "Documents\Embarcadero\Studio\$BdsVersion\Dcp"

New-Item -ItemType Directory -Force -Path $dcp | Out-Null

$dcus = @(
  "CollapsibleDBGrid.Core.dcu",
  "CollapsibleDBGrid.Data.dcu",
  "VCL.CollapsibleDBGrid.dcu",
  "FMX.CollapsibleDBGrid.dcu"
)

foreach ($dcu in $dcus) {
  $source = Join-Path $bin $dcu
  if (Test-Path -LiteralPath $source) {
    Copy-Item -LiteralPath $source -Destination $dcp -Force
  }
}

$libraryPath = "HKCU:\Software\Embarcadero\BDS\$BdsVersion\Library\Win32"
if (Test-Path $libraryPath) {
  $sourcePaths = @(
    (Join-Path $root "src\Common"),
    (Join-Path $root "src\VCL"),
    (Join-Path $root "src\FMX")
  )
  $current = (Get-ItemProperty -Path $libraryPath -Name "Search Path")."Search Path"
  foreach ($sourcePath in $sourcePaths) {
    if ($current.Split(';') -notcontains $sourcePath) {
      $current = "$current;$sourcePath"
    }
  }
  Set-ItemProperty -Path $libraryPath -Name "Search Path" -Value $current
}

Write-Host "Updated DCUs and Win32 search path for BDS $BdsVersion"
