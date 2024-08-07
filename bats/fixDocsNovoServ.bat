@echo off
title fixDocsNovoServ
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

echo | set /p="Instalando CrystalQRCode... " &
call "C:\NOVOSERV\Componentes\CrystalQRCode\Install.bat" >nul &
IF ERRORLEVEL 1 (echo [31m✕ Erro[0m) ELSE (echo [32m✓ Sucesso![0m)

echo | set /p="Extraindo SoapToolkit... " &
IF EXIST "%userprofile%\SOAP\soapsdk.msi" (echo | set /p="SOAPToolkit encontrado " & echo [32m✓ Sucesso![0m & goto installSOAP) &
"C:\NOVOSERV\Componentes\SoapToolkit30.EXE" /T:"%userprofile%\SOAP" /C &
IF ERRORLEVEL 1 (echo [31m✕ Erro[0m) ELSE (echo [32m✓ Sucesso![0m)

:installSOAP
echo | set /p="Instalando SoapToolkit... " &
msiexec /package %userprofile%\SOAP\soapsdk.msi /quiet &
IF ERRORLEVEL 1 (echo [31m✕ Erro[0m) ELSE (echo [32m✓ Sucesso![0m)

echo.
echo Obrigado por utilizar mais uma ferramenta DCecci!
timeout 1 >nul