@echo off
REM ============================================================
REM  Instalador de RustDesk para Windows
REM  Click derecho > Ejecutar como administrador
REM ============================================================

echo.
echo ============================================================
echo   Instalador automatico de RustDesk
echo ============================================================
echo.

REM Verificar si PowerShell está disponible
where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell no esta disponible en este sistema.
    echo Por favor, instala RustDesk manualmente.
    pause
    exit /b 1
)

REM Ejecutar el script PowerShell
powershell -ExecutionPolicy Bypass -File "%~dp0install_rustdesk_windows.ps1"

echo.
pause
