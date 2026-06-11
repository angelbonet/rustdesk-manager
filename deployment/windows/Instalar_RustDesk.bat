@echo off
REM ============================================================
REM  Instalador de RustDesk para Windows
REM  Doble clic para ejecutar (se eleva a administrador solo)
REM ============================================================

REM Elevar a administrador si hace falta
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

REM Ejecutar el script PowerShell desde la misma carpeta
powershell -ExecutionPolicy Bypass -File "%~dp0install_rustdesk_windows.ps1"
