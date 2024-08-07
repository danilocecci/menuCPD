@echo off
title NETCONFIG
CHCP 1252 >NUL
@REM mode con: cols=82 lines=10

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Começo do processo de adquirir privilégios de Administrador ::
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
ECHO Verificando e adquirindo permissões de Administrador
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

echo Baixando a versão NovoServ...
echo.

set path="C:\Program Files\WinRAR\";%path%

curl -k https://www.cloudpma.net/index.php/s/xwc7TxLfBRerzSk/download -o %userprofile%\Downloads\NovoServ.zip && echo. && winrar x -ibck %userprofile%\Downloads\NovoServ.zip %userprofile%\Downloads\ && echo Download e extração concluídos com sucesso. && timeout 1 >nul && start "" "%userprofile%\Downloads\Instala NOVOSERV 2024\InstaladorNovoserv.exe" & echo. && echo Obrigado por utilizar mais uma ferramenta DCecci! && timeout 3 >nul