@echo off
setlocal enabledelayedexpansion
title PUSH MODS
set "MODS=%~dp0.."
cd /d "%MODS%"

cls
echo.
echo    =============================
echo      PUSH MODS TO THE SERVER
echo    =============================
echo.

where git >nul 2>nul
if errorlevel 1 goto no_git

echo   [1/4] Checking access...
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | findstr /C:"successfully authenticated" >nul
if errorlevel 1 goto no_access
echo         OK
goto access_ok

:no_git
echo.
echo   [ERROR] Git is not installed on this computer.
echo.
echo   PUSH needs Git to work. To install it:
echo.
echo     1. Open this link in your browser:
echo        https://git-scm.com/download/win
echo.
echo     2. Download the file and run it.
echo        (leave all default options - just click Next)
echo.
echo     3. When installation is done, close this window
echo        and run PUSH.bat again.
echo.
pause
exit /b 1

:no_access
set "SSHDIR=%USERPROFILE%\.ssh"
set "KEY=%SSHDIR%\id_ed25519"
if not exist "%KEY%" (
  if not exist "%SSHDIR%" mkdir "%SSHDIR%"
  ssh-keygen -t ed25519 -N "" -f "%KEY%" -C "MegaPenis-SMP" >nul 2>&1
  if errorlevel 1 (
    echo   [ERROR] Could not create the access key.
    echo   OpenSSH is built into Windows 10/11.
    echo.
    pause
    exit /b 1
  )
)
echo.
echo   ============================================
echo     ACCESS REQUIRED
echo   ============================================
echo.
echo   Send the key below to the admin to get access:
echo.
type "%KEY%.pub"
echo.
echo   ============================================
echo.
echo   The key was copied to the clipboard.
echo   Just paste it to the admin in any message.
echo.
echo   When the admin grants access, run this script again.
echo.
pause
exit /b 1

:access_ok
echo   [2/4] Preparing your mods...

if exist "%MODS%\.git" goto repo_exists

echo   [..] Repository not found. Initializing...
git init >nul 2>&1
git remote add origin git@github.com:AutisticEblan/MegaPenis-SMP.git >nul 2>&1
git fetch origin >nul 2>&1
if errorlevel 1 (
  echo   [ERROR] Could not reach the server.
  echo   Check your internet connection and try again.
  echo.
  pause
  exit /b 1
)
git reset --hard origin/main >nul 2>&1
git branch -M main >nul 2>&1
echo         OK

:repo_exists
git remote set-url origin git@github.com:AutisticEblan/MegaPenis-SMP.git >nul 2>&1
for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set "BR=%%i"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "BACKUP=%~dp0_backup\push_%TS%"
set "BK=0"
for /f "delims=" %%f in ('git ls-files -o --exclude-standard -- "*.jar"') do (
  if "!BK!"=="0" mkdir "%BACKUP%" >nul 2>&1
  copy "%%f" "%BACKUP%\" >nul 2>&1
  set "BK=1"
)
echo         OK

echo   [3/4] Sending your mods...
git add -A >nul 2>&1
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "mods update %TS%" >nul 2>&1
  if errorlevel 1 (
    echo.
    echo   [ERROR] Could not save changes.
    echo   Set your name and email in git:
    echo     git config --global user.name "YourName"
    echo     git config --global user.email "you@example.com"
    echo   Then run this script again.
    echo.
    pause
    exit /b 1
  )
  set "HAS=1"
) else (
  set "HAS=0"
)
git pull origin %BR% --rebase >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ERROR] Could not update from the server.
  echo   Your mods are safe in a backup:  %BACKUP%
  echo   Ask the admin for help.
  echo.
  pause
  exit /b 1
)
git push origin %BR% >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ERROR] Could not send mods to the server.
  echo   Check your access and try again.
  echo.
  pause
  exit /b 1
)
echo         OK

cls
if "!HAS!"=="1" (
  echo.
  echo   =============================
  echo      DONE - MODS SENT!
  echo   =============================
  echo.
  echo   Your mods were sent to the server.
) else (
  echo.
  echo   =============================
  echo      UP TO DATE
  echo   =============================
  echo.
  echo   Nothing new to send - the server is up to date.
)
echo.
pause
