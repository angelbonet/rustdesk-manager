#
# Instalador automatico de RustDesk para Windows
# Ejecutar desde Instalar_RustDesk.bat (se eleva solo a administrador)
#

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# === CARGAR CONFIGURACION ===
$configFile = Join-Path $scriptDir "config.txt"

if (-not (Test-Path $configFile)) {
    [System.Windows.Forms.MessageBox]::Show(
        "No se encuentra config.txt en esta carpeta.`nCopia config.txt.example, renombralo a config.txt y rellena los datos.",
        "Error de configuracion", "OK", "Error") 2>$null
    Write-Host "Error: No se encuentra config.txt en esta carpeta." -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

function Get-Cfg {
    param([string]$key)
    $line = Get-Content $configFile | Where-Object { $_ -match "^$key=" } | Select-Object -First 1
    if ($line) { return ($line -replace "^$key=", "").Trim() }
    return ""
}

$RENDEZVOUS_SERVER = Get-Cfg "RENDEZVOUS_SERVER"
$KEY               = Get-Cfg "KEY"
$PASSWORD          = Get-Cfg "PASSWORD"
$PUSHOVER_TOKEN    = Get-Cfg "PUSHOVER_TOKEN"
$PUSHOVER_USER     = Get-Cfg "PUSHOVER_USER"

if (-not $RENDEZVOUS_SERVER -or $RENDEZVOUS_SERVER -eq "tu-servidor.com") {
    Write-Host "Error: Configura RENDEZVOUS_SERVER en config.txt" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"; exit 1
}
if (-not $KEY -or $KEY -eq "tu_clave_publica_aqui") {
    Write-Host "Error: Configura KEY en config.txt" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"; exit 1
}
if (-not $PASSWORD -or $PASSWORD -eq "tu_contrasena_aqui") {
    Write-Host "Error: Configura PASSWORD en config.txt" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"; exit 1
}

# ===========================

$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Instalando RustDesk..." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Obtener la ultima version
Write-Host "[1/4] Obteniendo ultima version..." -ForegroundColor Yellow
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/rustdesk/rustdesk/releases/latest" -UseBasicParsing
    $latestVersion = $release.tag_name -replace '^v', ''
} catch {
    Write-Host "Error: No se pudo obtener la version de GitHub." -ForegroundColor Red
    Read-Host "Presiona Enter para salir"; exit 1
}

Write-Host "Version: $latestVersion" -ForegroundColor Green

$downloadUrl = "https://github.com/rustdesk/rustdesk/releases/download/$latestVersion/rustdesk-$latestVersion-x86_64.exe"
$tempPath    = Join-Path $env:TEMP "rustdesk_installer.exe"

# Descargar
Write-Host ""
Write-Host "[2/4] Descargando..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing
    Write-Host "Descarga completada." -ForegroundColor Green
} catch {
    Write-Host "Error al descargar: $_" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"; exit 1
}

# Instalar
Write-Host ""
Write-Host "[3/4] Instalando..." -ForegroundColor Yellow
Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

Start-Process -FilePath $tempPath -ArgumentList "--silent-install" -Wait -NoNewWindow
Start-Sleep -Seconds 4

Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
Write-Host "RustDesk instalado." -ForegroundColor Green

# Configurar servidor
Write-Host ""
Write-Host "[4/4] Configurando servidor..." -ForegroundColor Yellow

$configDir = "$env:APPDATA\RustDesk\config"
New-Item -ItemType Directory -Path $configDir -Force | Out-Null

@"
rendezvous_server = '${RENDEZVOUS_SERVER}:21116'
nat_type = 1
serial = 0
unlock_pin = ''
trusted_devices = ''

[options]
key = '$KEY'
relay-server = '$RENDEZVOUS_SERVER'
custom-rendezvous-server = '$RENDEZVOUS_SERVER'
direct-server = 'Y'
direct-access-port = '21118'
"@ | Out-File -FilePath "$configDir\RustDesk2.toml" -Encoding UTF8 -Force

Write-Host "Servidor configurado: $RENDEZVOUS_SERVER" -ForegroundColor Green

# Localizar rustdesk.exe
$rustdeskPath = @(
    "$env:ProgramFiles\RustDesk\rustdesk.exe",
    "${env:ProgramFiles(x86)}\RustDesk\rustdesk.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

$rustdeskId = "no disponible"
if ($rustdeskPath) {
    Start-Process $rustdeskPath
    Start-Sleep -Seconds 5

    $rustdeskId = & $rustdeskPath --get-id 2>$null
    if (-not $rustdeskId) {
        Start-Sleep -Seconds 4
        $rustdeskId = & $rustdeskPath --get-id 2>$null
    }
    if (-not $rustdeskId) { $rustdeskId = "no disponible" }

    & $rustdeskPath --password $PASSWORD 2>$null | Out-Null
} else {
    Write-Host "Aviso: No se encontro rustdesk.exe. Abre RustDesk manualmente." -ForegroundColor Yellow
}

Write-Host "ID: $rustdeskId" -ForegroundColor Green

# Notificacion Pushover
$hostname = $env:COMPUTERNAME
$fecha    = Get-Date -Format "yyyy-MM-dd HH:mm"

if ($PUSHOVER_TOKEN -and $PUSHOVER_USER) {
    try {
        Invoke-RestMethod -Uri "https://api.pushover.net/1/messages.json" -Method Post -Body @{
            token   = $PUSHOVER_TOKEN
            user    = $PUSHOVER_USER
            title   = "RustDesk instalado: $hostname"
            message = "ID: $rustdeskId`nPassword: $PASSWORD`nEquipo: $hostname`nVersion: $latestVersion`nFecha: $fecha"
        } | Out-Null
    } catch {}
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Instalacion completada!" -ForegroundColor Green
Write-Host "  ID:      $rustdeskId" -ForegroundColor Green
Write-Host "  Version: $latestVersion" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Read-Host "Presiona Enter para cerrar"
