@echo off
chcp 866 >nul
setlocal enabledelayedexpansion
title PULL MODS
set "MODS=%~dp0.."
cd /d "%MODS%"

cls
echo.
echo   ---------------------------------
echo     PULL MODS - обновить моды
echo   ---------------------------------
echo.

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "BACKUP=%~dp0_backup\%TS%"

where git >nul 2>nul
if errorlevel 1 goto no_git
if not exist "%MODS%\.git" goto no_git

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
echo   [1/2] Сохраняем твои моды...   OK

git pull origin main >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ОШИБКА] Не удалось обновить моды.
  echo   Твои моды в безопасности:  %BACKUP%
  echo   Если конфликтует мод - восстанови его
  echo   из бэкапа под другим именем.
  echo.
  pause
  exit /b 1
)
echo   [2/2] Обновляем моды...   OK
goto done

:no_git
powershell -NoProfile -ExecutionPolicy Bypass -Command "$b='%BACKUP%'; New-Item -ItemType Directory -Path $b -Force | Out-Null; Copy-Item (Join-Path (Split-Path '%~dp0' -Parent) '*.jar') $b -ErrorAction SilentlyContinue"
echo   [1/2] Сохраняем твои моды...   OK

powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $m=(Split-Path '%~dp0' -Parent); $u='https://github.com/AutisticEblan/MegaPenis-SMP/archive/refs/heads/main.zip'; $t=Join-Path $env:TEMP ('mp_pull_'+[guid]::NewGuid().ToString('N')); $z=$t+'.zip'; Invoke-WebRequest -Uri $u -OutFile $z -UseBasicParsing; Expand-Archive -Path $z -DestinationPath $t -Force; $j=Get-ChildItem -Path $t -Recurse -Filter '*.jar'; if($j.Count -eq 0){exit 1}; $j | ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $m $_.Name) -Force }; Remove-Item -LiteralPath $z,$t -Recurse -Force -ErrorAction SilentlyContinue; exit 0"
if errorlevel 1 (
  echo.
  echo   [ОШИБКА] Не удалось обновить моды.
  echo   Проверь интернет и попробуй снова.
  echo.
  pause
  exit /b 1
)
echo   [2/2] Обновляем моды...   OK

:done
cls
echo.
echo   ---------------------------------
echo     Готово!
echo   ---------------------------------
echo.
echo   Моды обновлены.
if exist "%BACKUP%\*.jar" (
  echo.
  echo   Твои личные моды сохранены тут:
  echo   %BACKUP%
)
echo.
pause