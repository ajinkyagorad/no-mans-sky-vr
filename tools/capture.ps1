# Renders the game headlessly and saves PNGs for the README.
# Usage:  powershell -File tools\capture.ps1
# Chrome writes harmless notices to stderr; don't let that abort the run.
$ErrorActionPreference = 'Continue'
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $root 'docs\img'
New-Item -ItemType Directory -Force $out | Out-Null

$chrome = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chrome)) { $chrome = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe" }

$page = "file:///" + (Join-Path $root 'nms-vr.html').Replace('\', '/')
$shots = 'surface', 'markers', 'cockpit', 'orbit', 'galaxy', 'system', 'holomap', 'mission'
if ($args.Count -gt 0) { $shots = $args }   # e.g. capture.ps1 galaxy system

foreach ($s in $shots) {
  $png = Join-Path $out "$s.png"
  $profile = Join-Path $env:TEMP "nmsvr-shot-$s"
  & $chrome --headless=new --disable-gpu-sandbox --enable-unsafe-swiftshader `
    --use-angle=swiftshader --window-size=1600,900 --hide-scrollbars `
    --disable-logging --log-level=3 --no-first-run --disable-extensions `
    --disable-features=Translate,MediaRouter --no-default-browser-check `
    --virtual-time-budget=45000 --user-data-dir="$profile" `
    --screenshot="$png" "$page`?shot=$s" | Out-Null
  if (Test-Path $png) {
    $kb = [math]::Round((Get-Item $png).Length / 1KB)
    Write-Host ("  {0,-9} {1,6} KB" -f $s, $kb)
  } else {
    Write-Host ("  {0,-9} FAILED" -f $s)
  }
  Remove-Item $profile -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host "`nSaved to docs\img"
