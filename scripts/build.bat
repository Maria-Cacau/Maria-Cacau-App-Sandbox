@echo off
REM Setup do projeto no Windows: cria o venv e instala as dependencias.
REM Use: scripts\build.bat [extra] — extra e o grupo de dependencias opcionais
REM do pyproject.toml (default: dev)
REM
REM SANDBOX: mudanca temporaria de teste do fluxo de release via Actions —
REM quando promover pro -App de verdade, aplicar o mesmo ajuste la.

set VENV_NAME=venv
set EXTRA=%1
if "%EXTRA%"=="" set EXTRA=dev

REM Verifica Python
where python >nul 2>&1
if errorlevel 1 (
    echo ERRO: Python nao encontrado. Instale em python.org e adicione ao PATH.
    exit /b 1
)

REM Cria o venv se nao existir
if not exist "%VENV_NAME%\" (
    echo Criando ambiente virtual...
    python -m venv %VENV_NAME%
)

REM Instala o pacote e suas dependencias
call %VENV_NAME%\Scripts\activate.bat
python -m pip install --upgrade pip
python -m pip install -e ".[%EXTRA%]"

REM Registra a pasta de hooks do projeto
git config core.hooksPath .githooks

REM direnv e opcional no Windows — o VS Code detecta o venv automaticamente
where direnv >nul 2>&1
if not errorlevel 1 (
    direnv allow
) else (
    echo.
    echo AVISO: direnv nao encontrado - ativacao automatica do venv nao disponivel.
    echo Para instalar: scoop install direnv  ou  choco install direnv
)

echo.
echo Setup concluido. Para ativar o venv manualmente:
echo     %VENV_NAME%\Scripts\activate.bat

REM O 'where direnv' la em cima pode ter deixado o errorlevel em 1 mesmo em
REM caso de sucesso (echo nao reseta errorlevel). Fixa o codigo de saida aqui
REM para nao propagar esse falso-negativo pra quem chamar este script.
exit /b 0
