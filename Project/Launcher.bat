@echo off

:: Copyright (C) 2024 ALFiX, Inc.
:: Any tampering with the program code is forbidden (Запрещены любые вмешательства)

reg add HKLM /F >nul 2>&1
if %errorlevel% neq 0 (
    start "" /wait /I /min powershell -NoProfile -Command "start -verb runas '%~s0'" && exit /b
)

:: Получение информации о текущем языке интерфейса и выход, если язык не ru-RU
for /f "tokens=3" %%i in ('reg query "HKCU\Control Panel\International" /v "LocaleName"') do set WinLang=%%i
if /I "%WinLang%" NEQ "ru-RU" (
    cls
    echo  Error 01: Invalid interface language.
    timeout /t 3 >nul
    exit /b
)

REM Цветной текст
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

:RR
:: Запуск от имени администратора
mode con: cols=92 lines=43 >nul 2>&1
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: Получаем текущую папку BAT-файла
set currentDir=%~dp0
:: Убираем последний слэш
set currentDir=%currentDir:~0,-1%
:: Переходим в родительскую папку
for %%i in ("%currentDir%") do set parentDir=%%~dpi


:AntiZapret_Menu
set "CheckStatus=WithoutChecked"
set "sourcePath=%~dp0"
set "serviceName=GoodbyeZapret"

set "GoodbyeZapret_Current=None"
set "GoodbyeZapret_Config=None"

reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\GoodbyeZapret /v Description >nul 2>&1
if %errorlevel% equ 0 (
   REM Ключ GoodbyeZapret_Version существует.
   for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\GoodbyeZapret" /v "Description" 2^>nul ^| find /i "Description"') do set "GoodbyeZapret_Current=%%b"
)

for /f "usebackq delims=" %%a in ("%~dp0version.txt") do set "GZVER=%%a"


set "GoodbyeZapretVersion=%GZVER%"
cls
title GoodbyeZapret v%GoodbyeZapretVersion% - Launcher

reg query HKCU\Software\ASX\Info /v GoodbyeZapret_Version >nul 2>&1
if %errorlevel% equ 0 (
   REM Ключ GoodbyeZapret_Version существует.
   for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ASX\Info" /v "GoodbyeZapret_Version" 2^>nul ^| find /i "GoodbyeZapret_Version"') do set "GoodbyeZapret_Version_OLD=%%b"
) else (
   REM Ключ GoodbyeZapret_Version не найден.
   reg add "HKCU\Software\ASX\Info" /t REG_SZ /v "GoodbyeZapret_Version" /d "%GoodbyeZapretVersion%" /f >nul
   set "GoodbyeZapret_Version_OLD=None"
)

reg query HKCU\Software\ASX\Info /v GoodbyeZapret_Config >nul 2>&1
if %errorlevel% equ 0 (
   REM Ключ GoodbyeZapret_Version существует.
   for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ASX\Info" /v "GoodbyeZapret_Config" 2^>nul ^| find /i "GoodbyeZapret_Config"') do set "GoodbyeZapret_Config=%%b"
)

reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\GoodbyeZapret /v Description >nul 2>&1
if %errorlevel% equ 0 (
   REM Ключ GoodbyeZapret_Version существует.
   for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\GoodbyeZapret" /v "Description" 2^>nul ^| find /i "Description"') do set "GoodbyeZapret_Current=%%b"
)


if defined GoodbyeZapretVersion (
    reg add "HKCU\Software\ASX\Info" /v "GoodbyeZapret_Version" /t REG_SZ /d "%GoodbyeZapretVersion%" /f >nul 2>&1
)


:GZ_loading_procces
:: Проверка запущенного процесса
tasklist | find /i "Winws.exe" >nul
if %errorlevel% equ 0 (
    echo Процесс %ProcessName% запущен.
) else (
    echo Процесс %ProcessName% не найден.
)

if not defined GoodbyeZapretVersion (
    title GoodbyeZapret v%GoodbyeZapret_Version_OLD% - Launcher
) else (
    title GoodbyeZapret v%GoodbyeZapretVersion% - Launcher
)

cls
echo.
echo.
echo           %COL%[90m_____                 _ _                  ______                    _   
echo          / ____^|               ^| ^| ^|                ^|___  /                   ^| ^|  
echo         ^| ^|  __  ___   ___   __^| ^| ^|__  _   _  ___     / / __ _ _ __  _ __ ___^| ^|_ 
echo         ^| ^| ^|_ ^|/ _ \ / _ \ / _` ^| '_ \^| ^| ^| ^|/ _ \   / / / _` ^| '_ \^| '__/ _ \ __^|
echo         ^| ^|__^| ^| ^(_^) ^| ^(_^) ^| ^(_^| ^| ^|_^) ^| ^|_^| ^|  __/  / /_^| ^(_^| ^| ^|_^) ^| ^| ^|  __/ ^|_ 
echo          \_____^|\___/ \___/ \__,_^|_.__/ \__, ^|\___^| /_____\__,_^| .__/^|_^|  \___^|\__^|
echo                                          __/ ^|                 ^| ^|                 
echo                                         ^|___/                  ^|_^|
echo.

if not "%CheckStatus%"=="Checked" if not "%CheckStatus%"=="WithoutChecked" (
    echo                                    %COL%[90mОшибка: Не удалось провести проверку файлов - Скрипт может быть не стабилен%COL%[37m
    echo.
    echo.
) else (
    echo.
)

REM ================================================================================================

: Длина строки
set "line_length=90"

:: Пример содержимого переменной
set "GoodbyeZapret_Current=Текущий конфиг - %GoodbyeZapret_Current%"

:: Подсчет длины текста
set "text_length=0"
for /l %%A in (1,1,90) do (
    set "char=!GoodbyeZapret_Current:~%%A,1!"
    if "!char!"=="" goto :count_done
    set /a text_length+=1
)
:count_done

:: Расчет количества пробелов
set /a spaces=(line_length - text_length) / 2

:: Формирование строки с пробелами
set "padding="
for /l %%A in (1,1,%spaces%) do set "padding=!padding! "


if "%GoodbyeZapret_Current%" NEQ "None" (
    echo                     %COL%[90m===================================================
    echo %COL%[36m!padding!!GoodbyeZapret_Current! %COL%[37m
    echo                     %COL%[90m===================================================%COL%[37m
    echo.
) else (
echo                     %COL%[37mДобро пожаловать
echo                     %COL%[91mПанель находится в стадии тестирования и может содержать ошибки%COL%[37m
echo.
)

echo                        Выберите конфиг для установки в виде службы
echo.

set "counter=0"
for %%F in ("%sourcePath%Configs\*.bat") do (
    set /a "counter+=1"
    set "CurrentCheckFileName=%%~nxF"
    if !counter! lss 10 (
        echo                      %COL%[36m!counter!. %COL%[37m%%~nF
    ) else (
        echo                     %COL%[36m!counter!. %COL%[37m%%~nF
    )
    set "file!counter!=%%~nxF"
    REM set /a "counter+=1"
)
set /a "lastChoice=counter-1"


if !counter! lss 10 (
    echo.
    echo                      %COL%[36mDS %COL%[37m- %COL%[91mУдалить службу из автозапуска%COL%[37m
) else (
    echo.
    echo                     %COL%[36mDS %COL%[37m- %COL%[91mУдалить службу из автозапуска%COL%[37m
)
REM set "rs=!counter!"
REM set /a "counter+=1"
if !counter! lss 10 (
    echo                       %COL%[36mRC %COL%[37m- %COL%[91mПринудительно переустановить конфиги%COL%[37m
) else (
     echo                     %COL%[36mRC %COL%[37m- %COL%[91mПринудительно переустановить конфиги%COL%[37m
)
if !counter! lss 10 (
    echo                       %COL%[36mST %COL%[37m- %COL%[91mСостояние GoodbyeZapret%COL%[37m
) else (
     echo                     %COL%[36mST %COL%[37m- %COL%[91mСостояние GoodbyeZapret%COL%[37m
)
echo.
echo.
echo                                     Введите номер (%COL%[36m1%COL%[37m-%COL%[36m!counter!%COL%[37m)
set /p "choice=%DEL%                                            %COL%[90m:> "

if "%choice%"=="B" goto GoBack
if "%choice%"=="и" goto GoBack
if "%choice%"=="DS" goto remove_service
if "%choice%"=="ds" goto remove_service
if "%choice%"=="RC" goto ReInstall_GZ
if "%choice%"=="rc" goto ReInstall_GZ
if "%choice%"=="ST" goto CurrentStatus
if "%choice%"=="st" goto CurrentStatus

set "batFile=!file%choice%!"

if not defined batFile (
    echo Неверный выбор. Пожалуйста, попробуйте снова.
    goto :eof
)
 if defined batFile (
     echo.
     echo Устанавливаю службу %serviceName% для файла %batFile%...
     echo %COL%[93mНажмите любую клавишу для подтверждения%COL%[37m
     pause >nul 2>&1
     sc create "%serviceName%" binPath= "cmd.exe /c \"%sourcePath%Configs\%batFile%" start= auto
     reg add "HKCU\Software\ASX\Info" /t REG_SZ /v "GoodbyeZapret_Config" /d "%batFile:~0,-4%" /f >nul
     sc description %serviceName% "%batFile:~0,-4%"
     sc start "%serviceName%" >nul
     if %errorlevel% equ 0 (
         echo Запускаю службу %serviceName%...%COL%[92m
         sc start "%serviceName%" >nul 2>&1
         if %errorlevel% equ 0 (
             echo Служба %serviceName% успешно запущена %COL%[37m
         ) else (
             echo Ошибка при запуске службы
         )
     ) else (
         echo Ошибка при установке службы. Возможно вы забыли перезагрузить пк.
     )
     goto :end
 )



:remove_service
    echo.
    echo Остановка службы %serviceName%...
    net stop %serviceName% >nul 2>&1
    if %errorlevel% equ 0 (
        echo Служба успешно остановлена.
    ) else (
        echo Ошибка при остановке службы или служба уже остановлена.
    )
    echo Удаление службы %serviceName%...
    sc delete %serviceName% >nul 2>&1
    if %errorlevel% equ 0 (
    echo Служба %serviceName% успешно удалена
    tasklist /FI "IMAGENAME eq winws.exe" 2>NUL | find /I /N "winws.exe">NUL
    if "%ERRORLEVEL%"=="0" (
      echo Файл winws.exe в данный момент выполняется.
      taskkill /F /IM winws.exe >nul 2>&1
      net stop "WinDivert" >nul 2>&1
      sc delete "WinDivert" >nul 2>&1
      net stop "WinDivert14" >nul 2>&1
      sc delete "WinDivert14" >nul 2>&1
      echo Файл winws.exe был остановлен.
    ) else (
      echo Файл winws.exe в данный момент не выполняется.
    )
        echo %COL%[92mУдаление успешно завершено. Перезагрузите пк.%COL%[37m
    ) else (
        echo Ошибка при удалении службы
    )
    reg delete "HKCU\Software\ASX\Info" /v "GoodbyeZapret_Config" /f >nul 2>&1
goto :end

:end
echo Нажмите любую клавишу чтобы продолжить...
pause >nul 2>&1
goto AntiZapret_Menu


:CurrentStatus
cls
echo.
echo   Состояние служб GoodbyeZapret
echo   %COL%[90m=============================%COL%[37m
sc query %serviceName% >nul 2>&1
if %errorlevel% equ 0 (
    echo   Служба %serviceName%: %COL%[92mУстановлена и работает%COL%[37m
) else (
    echo   Служба %serviceName%: %COL%[91mНе установлена%COL%[37m
)
tasklist | find /i "Winws.exe" >nul
if %errorlevel% equ 0 (
    echo   Процесс Winws.exe: %COL%[92mЗапущен%COL%[90m
) else (
    echo   Процесс Winws.exe:  %COL%[91Не найден%COL%[90m
)
echo. 
echo.
pause >nul 2>&1
goto GZ_loading_procces


:ReInstall_GZ
cls
title Отключение текущего конфига GoodbyeZapret
net stop %serviceName% >nul 2>&1
echo %COL%[90mУдаление службы %serviceName%...
sc delete %serviceName% >nul 2>&1
echo Файл winws.exe в данный момент выполняется.
taskkill /F /IM winws.exe >nul 2>&1
net stop "WinDivert" >nul 2>&1
sc delete "WinDivert" >nul 2>&1
net stop "WinDivert14" >nul 2>&1
sc delete "WinDivert14" >nul 2>&1
echo Файл winws.exe был остановлен.

title Переустановка конфигов GoodbyeZapret

reg query HKCU\Software\ASX\Info /v GoodbyeZapret_Config >nul 2>&1
if %errorlevel% equ 0 (
   REM Ключ GoodbyeZapret_Version существует.
   for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ASX\Info" /v "GoodbyeZapret_Config" 2^>nul ^| find /i "GoodbyeZapret_Config"') do set "GoodbyeZapret_Config=%%b"
)

if exist "%parentDir%\ASX_GoodbyeZapret_latest.zip" del /s /q /f "%parentDir%\ASX_GoodbyeZapret_latest.zip" >nul 2>&1

curl -g -L -# -o %parentDir%\ASX_GoodbyeZapret_latest.zip "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Utilities/ASX_GoodbyeZapret/ASX_GoodbyeZapret.zip" >nul 2>&1
call:AZ_FileChecker
if not "%CheckStatus%"=="Checked" (
    echo     %COL%[91m   Ошибка: Не удалось провести проверку файла%COL%[37m
    goto AntiZapret_Menu
)

    if exist "%parentDir%\ASX_GoodbyeZapret_latest.zip" (
        start "" "%~dp0Extract.bat"
        ren "%parentDir%\ASX_GoodbyeZapret_latest" "ASX_GoodbyeZapret_%GoodbyeZapretVersion%"
        del "%parentDir%\ASX_GoodbyeZapret_latest.zip" >nul 2>&1
    ) else (
        echo Ошибка: Не удалось скачать файл ASX_GoodbyeZapret.zip. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке ASX_GoodbyeZapret.zip >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack 
    )

title Настройка конфига GoodbyeZapret

echo Устанавливаю службу %serviceName% для файла %GoodbyeZapret_Config%...

(
sc create "%serviceName%" binPath= "cmd.exe /c \"%sourcePath%Configs\%GoodbyeZapret_Config%.bat\"" start= auto
sc description %serviceName% "%GoodbyeZapret_Config%" ) >nul 2>&1
sc start "%serviceName%" >nul 2>&1
sc start "%serviceName%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Служба %serviceName% успешно запущена %COL%[37m
) else (
    echo Ошибка при запуске службы %serviceName%
)
goto AntiZapret_Menu


:AZ_FileChecker
set "FileSize=0"
set "CheckStatus=Checked"
REM set "file=%ASX-Directory%\Files\Downloads\%FileName%"
set "Check_FilePatch=%ASX-Directory%\Files\Downloads\ASX_GoodbyeZapret.zip"
set "Check_FileName=ASX_GoodbyeZapret.zip"

for %%I in ("%Check_FilePatch%") do set FileSize=%%~zI

if not exist "%Check_FilePatch%" ( 
    set "CheckStatus=NoChecked"
    REM echo     %COL%[91m   └ Ошибка: Не удалось провести проверку файла%COL%[37m
    echo [ERROR] %TIME% - Не удалось провести проверку файла - %Check_FileName% не найден >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto GoBack
)

if not defined FileSize (
    set "CheckStatus=NoChecked"
    REM echo     %COL%[91m   └ Ошибка: Не удалось провести проверку файла%COL%[37m
    echo [ERROR] %TIME% - Не удалось провести проверку файла %Check_FileName% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    echo.
    del /Q "%Check_FilePatch%"
    goto GoBack
)
if %FileSize% LSS 100 (
    set "CheckStatus=NoChecked"
    REM echo     %COL%[91m   └ Ошибка: Файл не прошел проверку. Возможно, он поврежден %COL%[37m
    echo [ERROR] %TIME% - Файл %Check_FileName% поврежден или URL не доступен ^(Size %FileSize%^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
    echo.
    del /Q "%Check_FilePatch%"
    goto GoBack
)
goto :eof

:AZ_FileChecker_2
set "FileSize=0"
set "CheckStatus=Checked"
REM set "file=%ASX-Directory%\Files\Downloads\%FileName%"
set "Check_FilePatch=%TEMP%\GZ_Updater.bat"
set "Check_FileName=GZ_Updater.bat"

for %%I in ("%Check_FilePatch%") do set FileSize=%%~zI

if not exist "%Check_FilePatch%" ( 
    set "CheckStatus=NoChecked"
    REM echo     %COL%[91m   └ Ошибка: Не удалось провести проверку файла%COL%[37m
    echo [ERROR] %TIME% - Не удалось провести проверку файла - %Check_FileName% не найден >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto GoBack
)

if not defined FileSize (
    set "CheckStatus=NoChecked"
    REM echo     %COL%[91m   └ Ошибка: Не удалось провести проверку файла%COL%[37m
    echo [ERROR] %TIME% - Не удалось провести проверку файла %Check_FileName% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    echo.
    del /Q "%Check_FilePatch%"
    goto GoBack
)
if %FileSize% LSS 100 (
    set "CheckStatus=NoChecked"
    REM echo     %COL%[91m   └ Ошибка: Файл не прошел проверку. Возможно, он поврежден %COL%[37m
    echo [ERROR] %TIME% - Файл %Check_FileName% поврежден или URL не доступен ^(Size %FileSize%^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
    echo.
    del /Q "%Check_FilePatch%"
    goto GoBack
)
goto :eof

:GZ_First_launch
md "%ASX-Directory%\Files\Resources\ASX_GoodbyeZapret" >nul 2>&1

if exist "%ASX-Directory%\Files\Downloads\ASX_GoodbyeZapret.zip" del /s /q /f "%ASX-Directory%\Files\Downloads\ASX_GoodbyeZapret.zip" >nul 2>&1

curl -g -L -# -o %ASX-Directory%\Files\Downloads\ASX_GoodbyeZapret.zip "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Utilities/ASX_GoodbyeZapret/ASX_GoodbyeZapret.zip" >nul 2>&1
call:AZ_FileChecker
if not "%CheckStatus%"=="Checked" (
    echo     %COL%[91m   Ошибка: Не удалось провести проверку файла%COL%[37m
    goto AntiZapret_Menu
)

    if exist "%ASX-Directory%\Files\Downloads\ASX_GoodbyeZapret.zip" (
        chcp 850 >nul 2>&1 
        powershell -NoProfile Expand-Archive '%ASX-Directory%\Files\Downloads\ASX_GoodbyeZapret.zip' -DestinationPath '%ASX-Directory%\Files\Resources\ASX_GoodbyeZapret' >nul 2>&1
        chcp 65001 >nul 2>&1
        del "%ASX-Directory%\Files\Downloads\ASX_GoodbyeZapret.zip" >nul 2>&1
    ) else (
        echo Ошибка: Не удалось скачать файл ASX_GoodbyeZapret.zip. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке ASX_GoodbyeZapret.zip >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack 
    )

for %%i in ("DiscordFix.bat" "DiscordFix_Beeline-Rostelekom.bat" "DiscordFix_MGTS.bat" "UltimateFix.bat" "UltimateFix_ALT.bat" "UltimateFix_ALT_v2_MGTS.bat" "UltimateFix_ALT_v2_Beeline-Rostelekom.bat" "UltimateFix_ALT_v2.bat" "UltimateFix_ALT_Beeline-Rostelekom.bat" "UltimateFix_ALT_MGTS.bat" "UltimateFix_Beeline-Rostelekom.bat" "UltimateFix_MGTS.bat" "YoutubeFix.bat" "YoutubeFix_ALT.bat" "YoutubeFix_ALT_MGTS.bat" "YoutubeFix_MGTS.bat") do (
        title ASX - GoodbyeZapret %%~i
        curl -g -L -# -o "%ASX-Directory%\Files\Resources\ASX_GoodbyeZapret\%%~i" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_GoodbyeZapret/GZ-configs/%%~i" >nul 2>&1
)
goto :eof