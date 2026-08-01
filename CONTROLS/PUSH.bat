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
if errorlevel 1 goto no_access
echo [OK] Access granted.
goto access_ok

:no_access
echo.
echo [INFO] No SSH access found. Setting up your key...
set "SSHDIR=%USERPROFILE%\.ssh"
set "KEY=%SSHDIR%\id_ed25519"
if exist "%KEY%" (
  echo [OK] SSH key already exists: %KEY%
) else (
  if not exist "%SSHDIR%" mkdir "%SSHDIR%"
  ssh-keygen -t ed25519 -N "" -f "%KEY%" -C "MegaPenis-SMP"
  if errorlevel 1 (
    echo [ERROR] Failed to create SSH key. OpenSSH is built into Windows 10/11.
    pause
    exit /b 1
  )
  echo [OK] SSH key created.
)
echo.
echo ============================================================
echo  SEND THIS KEY TO THE ADMIN TO GET PUSH ACCESS:
echo ============================================================
type "%KEY%.pub"
echo ============================================================
type "%KEY%.pub" | clip
echo [OK] Key copied to clipboard - paste it to the admin (Ctrl+V).
echo.
echo After the admin grants access, just run PUSH.bat again.
pause
exit /b 1

:access_ok
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
  echo [ERROR] Push failed. Check access via SSH key.
  pause
  exit /b 1
)
echo [OK] Successfully sent to the repository!
echo Backup: %BACKUP%
pause
