@ECHO OFF
CHCP 65001
CLS
mode 65,25

echo [101;93m Teste de conexão [0m
echo.

echo | set /p="IP Público: " 
curl http://ifconfig.me/ip
echo.

echo | set /p="IP Local: "
for /f "tokens=2,3 delims={,}" %%a in ('"WMIC NICConfig where IPEnabled="True" get IPAddress /value | find "I""') do echo %%~a
echo.

timeout 1 >nul

for /f "tokens=2,3 delims={,}" %%a in ('"WMIC NICConfig where IPEnabled="True" get DefaultIPGateway /value | find "I" "') do set gateway=%%~a

if %gateway% equ 192.168.0.1 (set server=192.168.0.2) else (set server=192.168.1.5)

set /A counter=0

echo | set /p="Conexão com seu roteador... " 
ping -n 1 %gateway% | findstr /r /c:"[0-9] *ms" > nul 2> nul
IF ERRORLEVEL 1 (echo [31m✕ Sem conexão[0m) ELSE (echo [32m✓ Conectado[0m && set /A counter=counter+1)
echo.


echo | set /p="Conexão com o Servidor da NovoServ... " 
ping -n 1 %server% | findstr /r /c:"[0-9] *ms" > nul 2> nul
IF ERRORLEVEL 1 (echo [31m✕ Sem conexão[0m) ELSE (echo [32m✓ Conectado[0m && set /A counter=counter+1)
echo.

echo | set /p="Conexão com a internet... " 
ping -n 1 google.com | findstr /r /c:"[0-9] *ms" > nul 2> nul
IF ERRORLEVEL 1 (echo [31m✕ Sem conexão[0m) ELSE (echo [32m✓ Conectado[0m && set /A counter=counter+1)
echo.

timeout 2 >nul

echo | set /p="Resultado: " 

if %counter% equ 3 (echo [32mEstá tudo certo com a sua conexão![0m)
if %counter% lss 3 (echo [31mAlgo não está certo! Entre em contato conosco.[0m && echo [32mWhatsApp: 3702-1027[0m && Echo. && ipconfig)
echo.

echo Obrigado por utilizar mais uma ferramenta de DCecci!
echo Pressione qualquer tecla para fechar!
pause >nul