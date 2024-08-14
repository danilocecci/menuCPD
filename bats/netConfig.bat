@echo off
title NETCONFIG
CHCP 65001 >NUL

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

:start
for /f "tokens=4*" %%i in ('netsh interface ip show interfaces ^| find "Ethernet"') do set etherName= %%j
set etherName=!etherName:~1!

@color f4
@echo ----------------------------------------------------------------------------------
@echo ATEN��O: AS CONFIGURA��ES A SEGUIR PODEM MUDAR O COMPORTAMENTO DO SEU COMPUTADOR!
@echo SIGA EM FRENTE SOMENTE COM AJUDA DO DEPARTAMENTO DE INFORM�TICA!
@echo ----------------------------------------------------------------------------------
@echo Voc� est� em contato com o Departamento de inform�tica?
@echo [1] SIM
@echo [2] N�O
@set /p safe= Escolha: 
@if %safe% equ 1 goto reset 
@if %safe% equ 2 goto thanks

:reset
cls
color 7
goto conexao

:erroConexao
cls
echo "%conexao%" n�o � uma op��o v�lida!
echo Vamos tentar novamente!
echo.

:conexao
cls
@getmac
echo.
echo O que deseja configurar?
echo [1] IP FIXO
echo [2] DHCP
echo [3] RESTAURAR IP
echo [4] GUARDAR IP
set /p conexao= Escolha: 
if %conexao% lss 1 goto erroConexao
if %conexao% equ 2 goto DHCP
if %conexao% equ 3 goto restauraIP
if %conexao% equ 4 goto guardaIP
if %conexao% gtr 4 goto erroConexao

:local
echo.
echo Qual � o local de acesso?
echo [1] INTERNO
echo [2] EXTERNO
set /p local= Escolha: 
if %local% lss 1 goto local
if %local% equ 1 set faixa=0& goto ip
if %local% gtr 2 goto local

:faixa
echo.
set /p faixa= Qual � a faixa de IP? 
set /p confirmaFaixa= Faixa "%faixa%" est� correta? [S/N] 
if %confirmaFaixa% neq s goto faixa

:ip
echo.
set /p ip= Qual ser� o IP final desta m�quina? 
set /p cofirmaIp= IP final %ip% est� correto? [S/N] 
if %cofirmaIp% neq s goto ip

:setarIP
netsh interface ipv4 set address name="!etherName!" static 192.168.%faixa%.%ip% 255.255.255.0 192.168.%faixa%.1 >NUL & netsh interface ipv4 set dnsservers name="!etherName!" static 192.168.%faixa%.1 >NUL
goto thanks

:DHCP
netsh interface ipv4 set address name="!etherName!" dhcp >NUL & netsh interface ipv4 set dnsservers name="!etherName!" dhcp >NUL
goto thanks

:restauraIP
if exist "%userprofile%\ip.txt" (
    echo Arquivo de configura��o de IP encontrado!
    echo Definindo novas configura��es de IP! & timeout 1 >nul

    setlocal enabledelayedexpansion
    set counter=0
    for /f "tokens=*" %%a In (%userprofile%\ip.txt) do (
        set /a counter+=1
        set "config[!counter!]=%%a" 
        )
    set config[ >NUL
    
    set ip=!config[1]!
    set mascara=!config[2]!
    set gateway=!config[3]!
    set dns=!config[4]!

    netsh interface ipv4 set address name="!etherName!" static !ip! !mascara! !gateway! >NUL & netsh interface ipv4 set dnsservers name="!etherName!" static !dns! >NUL
    goto thanks
    ) else (
        echo N�o existe um arquivo de IP da pasta de usu�rio. & timeout 2 >NUL
        cls
        goto conexao
        )

    endlocal

:guardaIP
for /f "tokens=3 delims=: " %%i in ('netsh interface ip show config name^="!etherName!" ^| findstr /c:"DHCP"') do @set isDHCP=%%i

IF !isDHCP! equ N�o (
    echo Salvando configura��es de backup em "%userprofile%\ip.txt"...
    for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "v4"') do @for /f "tokens=* delims= " %%j in ("%%i") do echo %%j > %userprofile%\ip.txt
    for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "Sub"') do @for /f "tokens=* delims= " %%j in ("%%i") do echo %%j >> %userprofile%\ip.txt
    for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "Gateway"') do @for /f "tokens=* delims= " %%j in ("%%i") do echo %%j >> %userprofile%\ip.txt
    for /f "tokens=2 delims=:" %%i in ('ipconfig -all ^| find "Servidores DNS"') do @for /f "tokens=* delims= " %%j in ("%%i") do echo %%j >> %userprofile%\ip.txt
    ) else (
        echo Seu IP est� din�mico, por tanto n�o sou capaz de salvar as configura��es de IP! & echo Voltando para o menu principal... & timeout 3 >NUL & goto conexao
        )


:thanks
echo.
echo Obrigado por utilizar uma ferramenta do Danilo (2024) :D
timeout /t 3 >nul