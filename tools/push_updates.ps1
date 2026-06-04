param(
  [string]$Message = "Update weekly paper summary",
  [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

Set-Location $Root

git add README.md STORAGE_POLICY.md .gitignore reports sources papers docs tools
$changes = git status --short

if (-not $changes) {
  Write-Output "No changes to commit."
  exit 0
}

git commit -m $Message
git push

Write-Output "Committed and pushed: $Message"
