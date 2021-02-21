echo off & color 4 & cls 
:: auto elevates to admin for ease of use 
:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"

  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)
 goto :start
 :: end of auto elevate

:start 
title NisaY Spoofer version 1.2
mode 60,15
cls
echo.
echo                  Spoofer FiveM by NisaY                    
echo.                                                           
echo ------------------------------------------------------------
echo                 [1] Materiel                               
echo                 [2] Suppression des fichiers locaux        
echo                 [3] Xbox suppression                       
echo ------------------------------------------------------------
echo                     Copyright NisaY                        
echo.                                                           
choice /c:123 /n
if %errorlevel% equ 1 goto :curHWID
if %errorlevel% equ 2 goto :folderclean
if %errorlevel% equ 3 goto :xboxclean

:curHWID
setlocal EnableDelayedExpansion
cls
set /a "lo=1"

for /f "skip=1 tokens=1" %%a in ('wmic diskdrive get serialnumber') do (
   set "disk=%%a"
   goto :n2
)
:n2
cls
:: bios serial 
for /f "skip=1 tokens=1" %%b in ('wmic bios get serialnumber') do (
   set "bios=%%b"
   goto :n3
)
:n3
for /f "skip=1 tokens=1" %%c in ('wmic cpu get serialnumber') do (
    set "cpu=%%c"
    goto :n4
)
:n4
for /f "delims= skip=1" %%d in ('wmic baseboard get serialnumber') do (
    set "baseb=%%d"
    goto :n5
)
:n5
for /f "skip=1 tokens=1" %%e in ('wmic MEMORYCHIP get serialnumber') do (
   if "!lo!" equ "1" (
      set "ram1=%%e"
   ) else (
      if "!lo!" equ "2" (
         set "ram2=%%e"  
      ) else (
         goto :n6
      )
   )
   set /a "lo=!lo!+1"
)
:n6
for /f "skip=1" %%f in ('wmic csproduct get UUID') do (
   set "uuid=%%f"
   goto :n7
)
:n7
if "%cpu%" equ "To" set "cpu=To be filled"
goto :resultsHWID

:resultsHWID
echo.
echo --------------------------------------------------------
echo      * Disque local: %disk%
echo      * Bios: %bios%
echo      * Processeur: %cpu%
echo      * Carte mere: %baseb%
echo      * Ram: %ram1%, %ram2%
echo      * UUID: %uuid%
echo --------------------------------------------------------
echo.
echo.
echo.------------------------------------------------------------
echo           ^<appuyez sur une touche pour continuer^>
echo ------------------------------------------------------------
pause>nul
goto :start

:folderclean
call :getDiscordVersion
cls
del /s /f /q "%appdata%\CitizenFX" >nul 2>nul 
del /s /f /q "%appdata%\DigitalEntitlements" >nul 2>nul
del /s /f /q "%appdata%\Discord\%discordVersion%\modules\discord_rpc" >nul 2>nul
call :errorcheck
cls
echo. 
echo ------------------------------------------------------------
echo                     Et c'est fini boyard :)
echo ------------------------------------------------------------
echo.
echo.          
echo.
echo.
echo.
echo.
echo.  
echo               ^<appuyez sur une touche pour continuer^>    
pause >nul
goto :start  
:getDiscordVersion
for /d %%a in ("%appdata%\Discord\*") do (
   set "varLoc=%%a"
   goto :d1
)
:d1
for /f "delims=\ tokens=7" %%z in ('echo %varLoc%') do (
   set "discordVersion=%%z"
)
goto :EOF

:xboxclean
cls
powershell -Command "& {Get-AppxPackage -AllUsers xbox | Remove-AppxPackage}" >NUL 2>NUL
sc stop XblAuthManager >NUL 2>NUL
sc stop XblGameSave >NUL 2>NUL
sc stop XboxNetApiSvc >NUL 2>NUL
sc stop XboxGipSvc >NUL 2>NUL
sc delete XblAuthManager >NUL 2>NUL
sc delete XblGameSave >NUL 2>NUL
sc delete XboxNetApiSvc >NUL 2>NUL
sc delete XboxGipSvc >NUL 2>NUL
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\xbgm" /f >NUL 2>NUL
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /disable >NUL 2>NUL
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /disable >NUL 2>NUL
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >NUL 2>NUL
call :errorcheck
cls
echo. 
echo ------------------------------------------------------------                   
echo                     C'est fini boyard :) 
echo ------------------------------------------------------------
echo.
echo.          
echo.
echo.
echo.
echo.
echo.  
echo               ^<appuyez sur une touche pour continuer^>    
pause >nul
goto :start  

:errorcheck 
if %errorlevel% EQU 1 (
    cls
    echo Failed. 
    timeout /t 3 >nul 2>nul
    exit /b
) else (
    rem do nothing :)
    goto :eof
)

@echo off
set hostspath=%windir%\System32\drivers\etc\hosts
echo 127.0.0.1 xboxlive.com >> %hostspath%
echo 127.0.0.1 user.auth.xboxlive.com >> %hostspath%
echo 127.0.0.1 presence-heartbeat.xboxlive.com >> %hostspath%

rd %userprofile%\AppData\Local\DigitalEntitlements /q /s
exit


//By Nisay


// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
// Copyright NisaY 
