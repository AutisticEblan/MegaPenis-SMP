@echo off
setlocal enabledelayedexpansion
title PUSH - send mods to repository
set "MODS=%~dp0.."
cd /d "%MODS%"

echo ============================================================
echo   PUSH - send your mods to the repository
echo ============================================================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git is not installed. Download: https://git-scm.com/download/win
  echo.
  pause
  exit /b 1
)

echo [1/4] Checking SSH access to GitHub...
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | findstr /C:"successfully authenticated" >nul
if errorlevel 1 (
  echo.
  echo [ERROR] No SSH access.
  echo Run GET_ACCESS.bat, send the key to the admin and wait for access.
  pause
  exit /b 1
)
echo [OK] Access granted.

git remote set-url origin git@github.com:AutisticEblan/MegaPenis-SMP.git 2>nul

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "BACKUP=%~dp0_backup\push_%TS%"
mkdir "%BACKUP%" 2>nul
echo [2/4] Backing up your own mods to: %BACKUP%
for /f "delims=" %%f in ('git ls-files -o --exclude-standard -- "*.jar"') do (
  copy "%%f" "%BACKUP%\" >nul 2>nul
  echo   - your mod: %%f
)

echo [3/4] Committing your changes...
git add -A
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "mods update %TS%"
  if errorlevel 1 (
    echo [ERROR] Commit failed. Check git config user.name and user.email.
    pause
    exit /b 1
  )
  echo [OK] Changes committed.
) else (
  echo [OK] Nothing to commit.
)

echo [4/4] Pulling latest changes and sending to the repository...
git pull origin main --rebase
if errorlevel 1 (
  echo [ERROR] Update conflict. Your mods are in: %BACKUP%
  pause
  exit /b 1
)

git push origin main
if errorlevel 1 (
  echo [ERROR] Push failed. Check access via GET_ACCESS.bat.
  pause
  exit /b 1
)
echo [OK] Successfully sent to the repository!
echo Backup: %BACKUP%
pause
