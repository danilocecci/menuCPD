@echo off
CHCP 65001 >NUL

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Come�o do processo de adquirir privil�gios de Administrador
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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
:--------------------------------------

::::::::::::::::::::::::::::
::START CODING
::::::::::::::::::::::::::::

title Update menuCPD

echo Iniciando a atualização do menuCPD
cd %userprofile%\Downloads
echo.

echo Baixando a nova versão... 
curl -LJO https://github.com/danilocecci/menuCPD/archive/refs/heads/main.zip >nul &
echo.

timeout 2 >nul

echo Extraindo arquivo...
"C:\Program Files\WinRAR\WinRAR.exe" x %userprofile%\Downloads\menuCPD-main.zip 
echo.

echo Fechando menuCPD...
taskkill /f /im mshta.exe 
echo.

timeout 2 >nul

echo Copiando nova versão...
xcopy "%userprofile%\Downloads\menuCPD-main\" "%userprofile%\Documents\MenuCPD\" /e /y
echo.

timeout 2 >nul

echo Iniciando menuCPD...
start %userprofile%\Documents\MenuCPD\menuCPD.hta
echo.

echo Apagando arquivos baixados...
rmdir /s /q "%userprofile%\Downloads\menuCPD-main\"
del "%userprofile%\Downloads\menuCPD-main.zip"

echo 'Obrigado por utilizar mais uma ferramenta DCecci 2024!'
