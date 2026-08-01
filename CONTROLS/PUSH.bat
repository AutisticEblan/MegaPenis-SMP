@echo off
chcp 866 >nul
setlocal enabledelayedexpansion
title PUSH MODS
set "MODS=%~dp0.."
cd /d "%MODS%"

cls
echo.
echo    ---------------------------------
echo      PUSH MODS - отправить моды
echo    ---------------------------------
echo.

where git >nul 2>nul
if errorlevel 1 goto no_git

:check_access
echo   [1/4] Проверка доступа...
ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | findstr /C:"successfully authenticated" >nul
if errorlevel 1 goto no_access
echo         OK
goto access_ok

:no_git
echo.
echo   ---------------------------------
echo     Нужен Git, скачаем?
echo   ---------------------------------
echo.
echo   Git нужен, чтобы отправлять моды.
echo   Скачаем автоматически?
echo   (нужен интернет, ~50 МБ)
echo   Может появиться окно с вопросом -
echo   нажми в нём "Да".
echo.
set "ANS="
set /p "ANS=   Enter - скачать, N - отменить: "
if /i "%ANS%"=="N" exit /b 1

:winget_install
echo.
echo   Скачиваю Git, подожди...
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements --silent --disable-interactivity
if errorlevel 1 goto no_git_manual
set "PATH=%PATH%;C:\Program Files\Git\cmd;C:\Program Files\Git\bin;C:\Program Files (x86)\Git\cmd;C:\Program Files (x86)\Git\bin"
where git >nul 2>nul
if errorlevel 1 goto no_git_manual
echo.
echo   Git готов, продолжаю...
echo.
goto check_access

:no_git_manual
echo.
echo   ---------------------------------
echo     Не получилось автоматически
echo   ---------------------------------
echo.
echo   Установи Git сам:
echo.
echo     1. Открой в браузере:
echo        https://git-scm.com/download/win
echo.
echo     2. Скачай и запусти файл.
echo        (везде жми Next)
echo.
echo     3. Запусти PUSH.bat снова.
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
    echo.
    echo   [ОШИБКА] Не удалось создать ключ.
    echo   OpenSSH встроен в Windows 10/11.
    echo.
    pause
    exit /b 1
  )
)
clip < "%KEY%.pub" >nul 2>&1
echo.
echo   ---------------------------------
echo     Поделись ключом с админом!
echo   ---------------------------------
echo.
echo   Ключ скопирован в буфер обмена!
echo.
echo   Отправь его админу, для выдачи доступа.
echo.
echo   Потом запусти PUSH.bat снова.
echo.
pause
exit /b 1

:access_ok
echo   [2/4] Подготовка модов...

if exist "%MODS%\.git" goto repo_exists

echo   [..] Репозиторий не найден. Инициализация...
git init >nul 2>&1
git remote add origin git@github.com:AutisticEblan/MegaPenis-SMP.git >nul 2>&1
git fetch origin >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ОШИБКА] Не удалось связаться с сервером.
  echo   Проверь интернет и попробуй снова.
  echo.
  pause
  exit /b 1
)
git reset --hard origin/main >nul 2>&1
git branch -M main >nul 2>&1
echo         OK

:repo_exists
git remote set-url origin git@github.com:AutisticEblan/MegaPenis-SMP.git >nul 2>&1
for /f %%i in ('git config user.name') do set "GN=%%i"
if not defined GN git config user.name "%USERNAME%" >nul 2>&1
for /f %%i in ('git config user.email') do set "GE=%%i"
if not defined GE git config user.email "%USERNAME%@megapenis" >nul 2>&1
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "BACKUP=%~dp0_backup\push_%TS%"
set "BK=0"
for /f "delims=" %%f in ('git ls-files -o --exclude-standard -- "*.jar"') do (
  if "!BK!"=="0" mkdir "%BACKUP%" >nul 2>&1
  copy "%%f" "%BACKUP%\" >nul 2>&1
  set "BK=1"
)
echo         OK

echo   [3/4] Отправка модов...
git add -A >nul 2>&1
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "mods update %TS%" >nul 2>&1
  if errorlevel 1 (
    echo.
    echo   [ОШИБКА] Не удалось сохранить изменения.
    echo.
    pause
    exit /b 1
  )
  set "HAS=1"
) else (
  set "HAS=0"
)
git pull origin main --rebase >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ОШИБКА] Не удалось обновиться с сервера.
  echo   Твои моды в безопасности:  %BACKUP%
  echo   Обратись к админу.
  echo.
  pause
  exit /b 1
)
git push origin main >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ОШИБКА] Не удалось отправить моды на сервер.
  echo   Проверь доступ и попробуй снова.
  echo.
  pause
  exit /b 1
)
echo         OK

cls
if "!HAS!"=="1" (
  echo.
  echo   ---------------------------------
  echo     Готово!
  echo   ---------------------------------
  echo.
  echo   Моды отправлены на сервер.
) else (
  echo.
  echo   ---------------------------------
  echo     Обновлено!
  echo   ---------------------------------
  echo.
  echo   Новых изменений нет - на сервере
  echo   уже всё свежее.
)
echo.
pause