@echo off
setlocal
title GET_ACCESS - repository access

echo ============================================================
echo   GET_ACCESS - get push access to the mods repository
echo ============================================================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Git is not installed.
  echo Download and install: https://git-scm.com/download/win
  echo.
  pause
  exit /b 1
)

set "SSHDIR=%USERPROFILE%\.ssh"
set "KEY=%SSHDIR%\id_ed25519"

if exist "%KEY%" (
  echo [OK] SSH key already exists: %KEY%
) else (
  echo [..] SSH key not found. Creating a new one...
  if not exist "%SSHDIR%" mkdir "%SSHDIR%"
  ssh-keygen -t ed25519 -N "" -f "%KEY%" -C "MegaPenis-SMP"
  if errorlevel 1 (
    echo [ERROR] Failed to create the key.
    echo OpenSSH is built into Windows 10/11, or install Git.
    pause
    exit /b 1
  )
  echo [OK] Key created.
)

echo.
echo ============================================================
echo   SEND THIS KEY TO THE ADMIN TO GET PUSH ACCESS:
echo ============================================================
echo.
type "%KEY%.pub"
echo.
echo ============================================================
type "%KEY%.pub" | clip
echo [OK] Key copied to clipboard - paste it to the admin (Ctrl+V).
echo.

cd /d "%~dp0.."
git remote set-url origin git@github.com:AutisticEblan/MegaPenis-SMP.git 2>nul
echo [OK] Remote set to SSH.
echo.

echo Checking connection to GitHub...
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | findstr /C:"successfully authenticated" >nul
if errorlevel 1 (
  echo [WARNING] No access yet. Send the key to the admin and wait.
  echo After access is granted, just run PUSH.bat
) else (
  echo [OK] Access granted! You can run PUSH.bat now
)
echo.
pause
