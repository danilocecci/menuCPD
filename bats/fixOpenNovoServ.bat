@echo off
title fixOpenNovoServ
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

::: PARÂMETROS NOVOSERV :::


::: REG COMP :::
:countRegCompLines
FOR /F "tokens=* USEBACKQ" %%g IN (`FINDSTR /N "^.*$" C:\NOVOSERV\Componentes\RegComp.bat ^| find /c ":"`) do (SET regCompLines=%%g)
IF %regCompLines% GEQ 20 (goto fixRegComp) else (goto runRegComp)

:fixRegComp
ECHO | set /p="Consertando o Registrador de Componentes... "

SetLocal DisableDelayedExpansion
Set "SrcFile=C:\NOVOSERV\Componentes\RegComp.bat"
If Not Exist "%SrcFile%" Exit /B
Copy /Y "%SrcFile%" "%SrcFile%.bak">Nul 2>&1||Exit /B
(   Set "Line="
    For /F "UseBackQ Delims=" %%A In ("%SrcFile%.bak") Do (
        SetLocal EnableDelayedExpansion
        If Defined Line Echo !Line!
        EndLocal
        Set "Line=%%A"))>"%SrcFile%"
EndLocal

IF ERRORLEVEL 1 (echo [31m✕ Erro[0m) ELSE (echo [32m✓ Sucesso![0m)
timeout 2 >nul &

:runRegComp
echo | set /p="Executando Registrador de Componentes do NovoServ... " &
pushd C:\NOVOSERV\Componentes\
call "C:\NOVOSERV\Componentes\RegComp.bat" >nul &
IF %ERRORLEVEL% neq 4 (echo [31m✕ Erro[0m) ELSE (echo [32m✓ Sucesso![0m)
ECHO.

::: GERA KEY :::
ECHO | set /p="Abrindo Gerenciador de Parâmetros do NovoServ... " &
"C:\NOVOSERV\Componentes\Gerenciador de Parametros.exe" 
IF ERRORLEVEL 1 (echo [31m✕ Erro[0m) ELSE (echo [32m✓ Sucesso![0m)
ECHO.

ECHO Obrigado por utilizar mais uma ferramenta DCecci.

timeout 3 >nul