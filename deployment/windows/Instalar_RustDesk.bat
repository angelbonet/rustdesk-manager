@echo off
REM ============================================================
REM  Instalador de RustDesk para Windows
REM  Doble clic para ejecutar (se eleva a administrador solo)
REM ============================================================

REM Elevar a administrador si hace falta
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

REM Cambiar al directorio del script y ejecutar PowerShell
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_rustdesk_windows.ps1"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: El instalador ha fallado con codigo %errorlevel%
    echo Captura esta pantalla y reporta el error.
)
pause
