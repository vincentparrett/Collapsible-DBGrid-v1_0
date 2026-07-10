param(
  [string]$Config = "Debug",
  [string]$Platform = "Win32"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$packages = @(
  "CommonCollapsibleDBGridRuntime.dpk",
  "FMXCollapsibleDBGridRuntime.dpk",
  "FMXCollapsibleDBGridDesign.dpk",
  "VCLCollapsibleDBGridRuntime.dpk",
  "VCLCollapsibleDBGridDesign.dpk"
)

function Find-Dcc32 {
  $candidates = @(
    "${env:ProgramFiles(x86)}\Embarcadero\Studio\37.0\bin\dcc32.exe",
    "${env:ProgramFiles(x86)}\Embarcadero\Studio\23.0\bin\dcc32.exe",
    "${env:ProgramFiles(x86)}\Embarcadero\Studio\22.0\bin\dcc32.exe",
    "${env:ProgramFiles(x86)}\Embarcadero\Studio\21.0\bin\dcc32.exe"
  )
  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) { return $candidate }
  }
  $cmd = Get-Command dcc32.exe -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  throw "Could not find dcc32.exe. Open a RAD Studio command prompt or add Delphi bin to PATH."
}

$dcc32 = Find-Dcc32
$outDir = Join-Path $root "bin"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

Push-Location (Join-Path $root "packages")
try {
  foreach ($package in $packages) {
    Write-Host "Building $package"
    & $dcc32 "-B" "-Q" "-N0$outDir" "-LE$outDir" "-LN$outDir" "-U..\src\Common;..\src\FMX;..\src\VCL" $package
    if ($LASTEXITCODE -ne 0) { throw "Build failed for $package" }
  }
}
finally {
  Pop-Location
}
