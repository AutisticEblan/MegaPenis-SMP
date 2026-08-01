@echo off
setlocal enabledelayedexpansion
title SETUP - admin setup
set "MODS=%~dp0.."
cd /d "%MODS%"

cls
echo.
echo    =============================
echo      SETUP - ADMIN SETUP
echo    =============================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo   [ERROR] Git is not installed.
  echo   Download and install it:  https://git-scm.com/download/win
  echo   Then run this script again.
  echo.
  pause
  exit /b 1
)
echo   [1/3] Git found.

echo   [2/3] Checking SSH access...
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | findstr /C:"successfully authenticated" >nul
if errorlevel 1 goto make_key
echo         OK
goto check_repo

:make_key
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
echo   Add this key to your GitHub account:
echo   (GitHub - Settings - SSH and GPG keys - New SSH key)
echo.
type "%KEY%.pub"
echo.
echo   ============================================
echo   The key was copied to the clipboard (Ctrl+V).
echo.
echo   Press Enter after you have added the key.
pause >nul
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | findstr /C:"successfully authenticated" >nul
if errorlevel 1 (
  echo   [ERROR] Access still not detected. Try again later.
  echo.
  pause
  exit /b 1
)
echo         OK

:check_repo
if exist "%MODS%\.git" goto done

echo   [3/3] Initializing repository...
git init >nul 2>&1
git remote add origin git@github.com:AutisticEblan/MegaPenis-SMP.git >nul 2>&1
git branch -M main >nul 2>&1
git pull origin main
if errorlevel 1 (
  echo.
  echo   [ERROR] Could not fetch mods from the repository.
  echo   Check your internet connection and try again.
  echo.
  pause
  exit /b 1
)
git checkout -- . >nul 2>&1
echo         OK

:done
cls
echo.
echo   =============================
echo      SETUP COMPLETE!
echo   =============================
echo.
echo   The repository is ready.
echo   Use PULL.bat to update mods, PUSH.bat to send them.
echo.
pause
