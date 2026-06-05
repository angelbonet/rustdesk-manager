#
# Instalador automático de RustDesk para Windows
#
# USO: Click derecho en Instalar_RustDesk.bat > "Ejecutar como administrador"
#
# CONFIGURACIÓN: Edita config.txt con los datos de tu servidor
#

# === CARGAR CONFIGURACIÓN ===
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptPath "config.txt"

if (-not (Test-Path $configFile)) {
    Write-Host "Error: No se encuentra el archivo config.txt" -ForegroundColor Red
    Write-Host "Crea el archivo config.txt con la configuracion de tu servidor."
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Función para leer valores del config
function Get-ConfigValue {
    param([string]$key)
    $content = Get-Content $configFile | Where-Object { $_ -match "^$key=" }
    if ($content) {
        return ($content -replace "^$key=", "").Trim()
    }
    return $null
}

$RENDEZVOUS_SERVER = Get-ConfigValue "RENDEZVOUS_SERVER"
$RELAY_SERVER = Get-ConfigValue "RELAY_SERVER"
$KEY = Get-ConfigValue "KEY"
$PASSWORD = Get-ConfigValue "PASSWORD"
$PUSHOVER_TOKEN = Get-ConfigValue "PUSHOVER_TOKEN"
$PUSHOVER_USER = Get-ConfigValue "PUSHOVER_USER"
$RUSTDESK_VERSION = Get-ConfigValue "RUSTDESK_VERSION"

# Validar configuración obligatoria
if (-not $RENDEZVOUS_SERVER -or $RENDEZVOUS_SERVER -eq "tu-servidor.com") {
    Write-Host "Error: Configura RENDEZVOUS_SERVER en config.txt" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

if (-not $KEY -or $KEY -eq "tu_clave_publica_aqui") {
    Write-Host "Error: Configura KEY en config.txt" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

if (-not $PASSWORD -or $PASSWORD -eq "tu_contraseña_aqui") {
    Write-Host "Error: Configura PASSWORD en config.txt" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Valores por defecto
if (-not $RELAY_SERVER) { $RELAY_SERVER = $RENDEZVOUS_SERVER }
if (-not $RUSTDESK_VERSION) { $RUSTDESK_VERSION = "1.4.6" }

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "     Instalador automatico de RustDesk                         " -ForegroundColor Green
Write-Host "     Servidor: $RENDEZVOUS_SERVER                              " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

# Detectar arquitectura
$arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "i686" }
Write-Host "Arquitectura detectada: $arch" -ForegroundColor Yellow

$downloadUrl = "https://github.com/rustdesk/rustdesk/releases/download/$RUSTDESK_VERSION/rustdesk-$RUSTDESK_VERSION-$arch.exe"

$tempDir = [System.IO.Path]::GetTempPath()
$installerPath = Join-Path $tempDir "rustdesk_installer.exe"

Write-Host ""
Write-Host "[1/7] Descargando RustDesk v$RUSTDESK_VERSION..." -ForegroundColor Yellow

$ProgressPreference = 'SilentlyContinue'
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Descarga completada." -ForegroundColor Green
} catch {
    Write-Host "Error al descargar: $_" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "[2/7] Cerrando RustDesk si esta abierto..." -ForegroundColor Yellow
Get-Process -Name "rustdesk" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "[3/7] Instalando RustDesk..." -ForegroundColor Yellow
try {
    Start-Process -FilePath $installerPath -ArgumentList "--silent-install" -Wait -NoNewWindow
    Write-Host "RustDesk instalado." -ForegroundColor Green
} catch {
    Write-Host "Intentando instalacion alternativa..." -ForegroundColor Yellow
    Start-Process -FilePath $installerPath -Wait
}

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "[4/7] Configurando servidor..." -ForegroundColor Yellow

$configDir = "$env:APPDATA\RustDesk\config"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

$configContent = @"
rendezvous_server = '$RENDEZVOUS_SERVER`:21116'
nat_type = 1
serial = 0
unlock_pin = ''
trusted_devices = ''

[options]
key = '$KEY'
relay-server = '$RELAY_SERVER'
custom-rendezvous-server = '$RENDEZVOUS_SERVER'
direct-server = 'Y'
direct-access-port = '21118'
"@

$configPath = Join-Path $configDir "RustDesk2.toml"
$configContent | Out-File -FilePath $configPath -Encoding UTF8 -Force
Write-Host "Configuracion del servidor guardada" -ForegroundColor Green

Write-Host ""
Write-Host "[5/7] Iniciando RustDesk para generar ID..." -ForegroundColor Yellow

$rustdeskPath = "${env:ProgramFiles}\RustDesk\rustdesk.exe"
if (-not (Test-Path $rustdeskPath)) {
    $rustdeskPath = "${env:ProgramFiles(x86)}\RustDesk\rustdesk.exe"
}

if (Test-Path $rustdeskPath) {
    Start-Process $rustdeskPath
    Start-Sleep -Seconds 5

    Write-Host ""
    Write-Host "[6/7] Configurando contrasena permanente..." -ForegroundColor Yellow

    # Obtener ID
    $rustdeskId = & $rustdeskPath --get-id 2>$null
    if ($rustdeskId) {
        Write-Host "ID de RustDesk: $rustdeskId" -ForegroundColor Green

        # Establecer contraseña
        try {
            Start-Process -FilePath $rustdeskPath -ArgumentList "--password", $PASSWORD -Wait -NoNewWindow -Verb RunAs
            Write-Host "Contrasena establecida." -ForegroundColor Green
        } catch {
            Write-Host "Nota: Establece la contrasena manualmente en Ajustes > Seguridad" -ForegroundColor Yellow
        }
    } else {
        $rustdeskId = "ID no disponible"
    }
} else {
    Write-Host "RustDesk no encontrado en la ruta esperada" -ForegroundColor Yellow
    $rustdeskId = "No instalado"
}

Write-Host ""
Write-Host "[7/7] Enviando notificacion..." -ForegroundColor Yellow

$hostname = $env:COMPUTERNAME
$fecha = Get-Date -Format "yyyy-MM-dd HH:mm"

if ($PUSHOVER_TOKEN -and $PUSHOVER_USER) {
    try {
        $body = @{
            token = $PUSHOVER_TOKEN
            user = $PUSHOVER_USER
            title = "RustDesk instalado: $hostname"
            message = "ID: $rustdeskId`nPassword: $PASSWORD`nEquipo: $hostname`nArquitectura: $arch`nFecha: $fecha"
        }

        $response = Invoke-RestMethod -Uri "https://api.pushover.net/1/messages.json" -Method Post -Body $body
        if ($response.status -eq 1) {
            Write-Host "Notificacion enviada correctamente" -ForegroundColor Green
        }
    } catch {
        Write-Host "No se pudo enviar la notificacion" -ForegroundColor Yellow
    }
} else {
    Write-Host "Notificaciones Pushover no configuradas" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[Limpieza] Eliminando archivos temporales..." -ForegroundColor Yellow
Remove-Item $installerPath -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  Instalacion completada!                                      " -ForegroundColor Green
Write-Host "                                                               " -ForegroundColor Green
Write-Host "  ID: $rustdeskId                                              " -ForegroundColor Green
Write-Host "  Servidor: $RENDEZVOUS_SERVER                                 " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""

Read-Host "Presiona Enter para cerrar"
