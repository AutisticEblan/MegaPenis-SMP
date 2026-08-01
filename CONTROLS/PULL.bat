@echo off
setlocal enabledelayedexpansion
title PULL - sync mods from repository
set "MODS=%~dp0.."
cd /d "%MODS%"

echo ============================================================
echo   PULL - download mods from the repository
echo ============================================================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git is not installed. Download: https://git-scm.com/download/win
  echo.
  pause
  exit /b 1
)

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "BACKUP=%~dp0_backup\%TS%"
mkdir "%BACKUP%" 2>nul

echo [1/3] Backing up your own mods to: %BACKUP%
set "HAS=0"
for /f "delims=" %%f in ('git ls-files -o --exclude-standard -- "*.jar"') do (
  copy "%%f" "%BACKUP%\" >nul 2>nul
  echo   - your mod: %%f
  set "HAS=1"
)
for /f "delims=" %%f in ('git diff --name-only -- "*.jar"') do (
  copy "%%f" "%BACKUP%\" >nul 2>nul
  echo   - modified: %%f
  set "HAS=1"
)
if "!HAS!"=="0" echo   no personal mods found.

git checkout -- "*.jar" 2>nul

echo [2/3] Updating mods from the repository...
git pull origin main
if errorlevel 1 (
  echo.
  echo [ERROR] Sync failed.
  echo Your mods are saved in: %BACKUP%
  echo If there is a conflict, restore your mod from backup with a different name.
  pause
  exit /b 1
)

echo [3/3] Done!
echo.
echo Mods updated from the repository.
echo Your own mods (if any) are saved in: %BACKUP%
pause
