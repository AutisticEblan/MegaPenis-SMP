@echo off
setlocal enabledelayedexpansion
title PULL MODS
set "MODS=%~dp0.."
cd /d "%MODS%"

cls
echo.
echo    =============================
echo      UPDATE MODS FROM SERVER
echo    =============================
echo.

where git >nul 2>nul
if errorlevel 1 goto no_git

if not exist "%MODS%\.git" goto no_git

echo   [1/2] Saving your mods...
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "BACKUP=%~dp0_backup\%TS%"
set "BK=0"
for /f "delims=" %%f in ('git ls-files -o --exclude-standard -- "*.jar"') do (
  if "!BK!"=="0" mkdir "%BACKUP%" >nul 2>&1
  copy "%%f" "%BACKUP%\" >nul 2>&1
  set "BK=1"
)
for /f "delims=" %%f in ('git diff --name-only -- "*.jar"') do (
  if "!BK!"=="0" mkdir "%BACKUP%" >nul 2>&1
  copy "%%f" "%BACKUP%\" >nul 2>&1
  set "BK=1"
)
git checkout -- "*.jar" >nul 2>&1
echo         OK

echo   [2/2] Updating mods...
git pull origin main >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ERROR] Could not update mods.
  echo   Your mods are safe in a backup:  %BACKUP%
  echo   If a mod conflicts, restore it from the backup
  echo   with a different file name.
  echo.
  pause
  exit /b 1
)
echo         OK
goto done

:no_git
echo   [1/2] Saving your mods...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$m=(Split-Path '%~dp0' -Parent); $b=Join-Path '%~dp0_backup' (Get-Date -Format 'yyyyMMdd_HHmmss'); New-Item -ItemType Directory -Path $b -Force | Out-Null; Copy-Item (Join-Path $m '*.jar') $b -ErrorAction SilentlyContinue"
echo         OK

echo   [2/2] Downloading and updating mods...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$m=(Split-Path '%~dp0' -Parent); $b=Join-Path '%~dp0_backup' (Get-Date -Format 'yyyyMMdd_HHmmss'); New-Item -ItemType Directory -Path $b -Force | Out-Null; Copy-Item (Join-Path $m '*.jar') $b -ErrorAction SilentlyContinue; $u='https://github.com/AutisticEblan/MegaPenis-SMP/archive/refs/heads/main.zip'; $t=Join-Path $env:TEMP ('mp_pull_'+[guid]::NewGuid().ToString('N')); $z=$t+'.zip'; Invoke-WebRequest -Uri $u -OutFile $z -UseBasicParsing; Expand-Archive -Path $z -DestinationPath $t -Force; $j=Get-ChildItem -Path $t -Recurse -Filter '*.jar'; if($j.Count -eq 0){exit 1}; $j | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $m $_.Name) -Force }; Remove-Item -LiteralPath $z,$t -Recurse -Force -ErrorAction SilentlyContinue; exit 0"
if errorlevel 1 (
  echo.
  echo   [ERROR] Could not update mods.
  echo   Check your internet connection and try again.
  echo.
  pause
  exit /b 1
)
echo         OK

:done
cls
echo.
echo   =============================
echo      DONE - MODS UPDATED!
echo   =============================
echo.
echo   Your mods are up to date.
echo.
pause
