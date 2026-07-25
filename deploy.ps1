# Copies the source page into the Pages output folder and deploys it.
# Usage:  .\deploy.ps1
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

New-Item -ItemType Directory -Force (Join-Path $root 'public') | Out-Null
Copy-Item (Join-Path $root 'nms-vr.html') (Join-Path $root 'public\index.html') -Force
Write-Host "Staged public\index.html"

npx wrangler pages deploy (Join-Path $root 'public') `
  --project-name no-mans-sky-vr --branch main --commit-dirty=true

Write-Host "`nLive at https://no-mans-sky-vr.pages.dev/"
