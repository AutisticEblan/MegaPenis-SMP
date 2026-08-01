param(
  [ValidateSet('backup','update')]
  [string]$Action = 'update'
)
$ErrorActionPreference = 'Stop'
$mods = Split-Path $PSScriptRoot -Parent
$backupRoot = Join-Path $PSScriptRoot '_backup'
$TS = Get-Date -Format 'yyyyMMdd_HHmmss'

if ($Action -eq 'backup') {
  $backup = Join-Path $backupRoot $TS
  New-Item -ItemType Directory -Path $backup -Force | Out-Null
  Copy-Item (Join-Path $mods '*.jar') $backup -ErrorAction SilentlyContinue
  exit 0
}

$backup = Join-Path $backupRoot $TS
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Copy-Item (Join-Path $mods '*.jar') $backup -ErrorAction SilentlyContinue

$url = 'https://github.com/AutisticEblan/MegaPenis-SMP/archive/refs/heads/main.zip'
$tmp = Join-Path $env:TEMP ('mp_pull_' + $TS)
$zip = $tmp + '.zip'
try {
  Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
  Expand-Archive -Path $zip -DestinationPath $tmp -Force
  $repoJars = Get-ChildItem -Path $tmp -Recurse -Filter '*.jar'
  foreach ($f in $repoJars) {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $mods $f.Name) -Force
  }
  if ($repoJars.Count -gt 0) {
    exit 0
  } else {
    exit 1
  }
} finally {
  Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
}
