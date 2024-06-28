@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

rem Lista todas as impressoras com números correspondentes
echo Impressoras Disponíveis:
echo ------------------------
set "counter=1"
for /f "tokens=2 delims==" %%a in ('wmic printer get name /value ^| find "="') do (
    echo !counter!. %%a
    set /a counter+=1
)

rem Solicita ao usuário que escolha uma impressora pelo número
set /p escolha="Digite o número da impressora desejada: "

rem Encontra o nome da impressora correspondente ao número escolhido
set "printerName="
set "counter=1"
for /f "tokens=2 delims==" %%a in ('wmic printer get name /value ^| find "="') do (
    if !counter! equ %escolha% set "printerName=%%a"
    set /a counter+=1
)

rem Verifica se o usuário escolheu uma opção válida
if not defined printerName (
    echo Opção inválida. Execute o script novamente e escolha um número válido.
    goto :eof
)

rem Define a impressora escolhida como padrão
rundll32 printui.dll,PrintUIEntry /y /n "%printerName%"

echo A impressora "%printerName%" foi definida como padrão.

endlocal
