param(
  [string]$BdsVersion = "37.0"
)

$ErrorActionPreference = "Stop"
& (Join-Path $PSScriptRoot "build_components.ps1")

$root = Split-Path -Parent $PSScriptRoot
$bin = Join-Path $root "bin"
$commonRoot = Join-Path $env:PUBLIC "Documents\Embarcadero\Studio\$BdsVersion"
$bplOut = Join-Path $commonRoot "Bpl"
$dcpOut = Join-Path $commonRoot "Dcp"

New-Item -ItemType Directory -Force -Path $bplOut | Out-Null
New-Item -ItemType Directory -Force -Path $dcpOut | Out-Null

Get-ChildItem -LiteralPath $bin -Filter "*CollapsibleDBGrid*.bpl" |
  Copy-Item -Destination $bplOut -Force
Get-ChildItem -LiteralPath $bin -Filter "*CollapsibleDBGrid*.dcp" |
  Copy-Item -Destination $dcpOut -Force
Get-ChildItem -LiteralPath $bin -Filter "*CollapsibleDBGrid*.dcu" |
  Copy-Item -Destination $dcpOut -Force

$designPackages = @(
  (Join-Path $bplOut "FMXCollapsibleDBGridDesign.bpl"),
  (Join-Path $bplOut "VCLCollapsibleDBGridDesign.bpl")
)

$regPath = "HKCU:\Software\Embarcadero\BDS\$BdsVersion\Known Packages"
if (-not (Test-Path $regPath)) {
  throw "RAD Studio registry key not found: $regPath"
}

foreach ($package in $designPackages) {
  if (-not (Test-Path -LiteralPath $package)) {
    throw "Built design package not found: $package"
  }
  New-ItemProperty -Path $regPath -Name $package -Value "CollapsibleDBGrid" -PropertyType String -Force | Out-Null
  Write-Host "Registered $package"
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
  Write-Host "Updated Win32 library search path"
}
