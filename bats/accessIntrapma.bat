@echo off
title accessIntrapma
CHCP 65001 >NUL
@REM mode con: cols=82 lines=10

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Come�o do processo de adquirir privil�gios de Administrador ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
ECHO.

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
ECHO.
ECHO *****************************************************
ECHO Verificando e adquirindo permiss�es de Administrador
ECHO *****************************************************

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
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::
::::::::START CODING::::::::
::::::::::::::::::::::::::::


FOR /F "tokens=3*" %%G IN ('netsh interface show interface ^| FIND "Ether"') DO SET adpaterName=%%H &

ECHO A IntraPMA.net está prestes a abrir
ECHO.

ECHO | SET /p="Verificando servidor de DNS do Google... " & TIMEOUT 1 > nul &
NETSH interface ipv4 delete dnsservers "%adpaterName:~0,-1%" address=8.8.8.8 >nul &
IF ERRORLEVEL 1 (echo [33mSem alteração no servidor DNS[0m) ELSE (echo [32m✓ Removido com sucesso![0m) &

TIMEOUT 1 >nul
ECHO.
ECHO | SET /p="Tentar abrir https://www.intrapma.net no seu navegador... " & timeout 1 >nul
START "chrome" "https://www.intrapma.net" &
IF ERRORLEVEL 1 (echo [31m✕ Erro[0m) ELSE (echo [32m✓ Sucesso![0m) &

ECHO.
ECHO Obrigado por utilizar mais uma ferramenta DCecci!
TIMEOUT 2 >nul