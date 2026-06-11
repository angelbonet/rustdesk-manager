#!/bin/bash
#
# Instalador automatico de RustDesk para macOS
# Doble clic en Instalar_RustDesk.command para ejecutar
#

set -e

cd "$(dirname "$0")"

# === CARGAR CONFIGURACION ===
CONFIG_FILE="config.txt"

if [ ! -f "$CONFIG_FILE" ]; then
    osascript -e 'display dialog "No se encuentra config.txt en esta carpeta.\nCopia config.txt.example, renombralo a config.txt y rellena los datos." buttons {"Cerrar"} default button 1 with title "Error de configuracion" with icon stop' 2>/dev/null || true
    echo "Error: No se encuentra config.txt en esta carpeta."
    exit 1
fi

get_config() {
    grep "^$1=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '\r'
}

RENDEZVOUS_SERVER=$(get_config "RENDEZVOUS_SERVER")
KEY=$(get_config "KEY")
PASSWORD=$(get_config "PASSWORD")
PUSHOVER_TOKEN=$(get_config "PUSHOVER_TOKEN")
PUSHOVER_USER=$(get_config "PUSHOVER_USER")

if [ -z "$RENDEZVOUS_SERVER" ] || [ "$RENDEZVOUS_SERVER" = "tu-servidor.com" ]; then
    echo "Error: Configura RENDEZVOUS_SERVER en config.txt"; exit 1
fi
if [ -z "$KEY" ] || [ "$KEY" = "tu_clave_publica_aqui" ]; then
    echo "Error: Configura KEY en config.txt"; exit 1
fi
if [ -z "$PASSWORD" ] || [ "$PASSWORD" = "tu_contrasena_aqui" ]; then
    echo "Error: Configura PASSWORD en config.txt"; exit 1
fi

# ===========================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Instalando RustDesk...${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# Detectar arquitectura
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    ARCH_SUFFIX="aarch64"
    echo -e "${YELLOW}Procesador: Apple Silicon${NC}"
elif [ "$ARCH" = "x86_64" ]; then
    ARCH_SUFFIX="x86_64"
    echo -e "${YELLOW}Procesador: Intel${NC}"
else
    echo -e "${RED}Error: Arquitectura no soportada: $ARCH${NC}"; exit 1
fi

# Obtener la ultima version
echo -e "${YELLOW}Obteniendo ultima version disponible...${NC}"
LATEST_VERSION=$(curl -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest \
    | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/' | tr -d '"')

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}Error: No se pudo obtener la ultima version de GitHub.${NC}"; exit 1
fi

echo -e "${GREEN}Version: ${LATEST_VERSION}${NC}"
DMG_URL="https://github.com/rustdesk/rustdesk/releases/download/${LATEST_VERSION}/rustdesk-${LATEST_VERSION}-${ARCH_SUFFIX}.dmg"

# Descargar
TEMP_DIR=$(mktemp -d)
DMG_FILE="$TEMP_DIR/rustdesk.dmg"

echo ""
echo -e "${YELLOW}[1/4] Descargando...${NC}"
curl -L -o "$DMG_FILE" "$DMG_URL" --progress-bar

# Instalar
echo ""
echo -e "${YELLOW}[2/4] Instalando...${NC}"
MOUNT_POINT=$(hdiutil attach "$DMG_FILE" -nobrowse 2>/dev/null | grep "/Volumes" | awk '{print $3}')

pkill -f "RustDesk" 2>/dev/null || true
sleep 1

[ -d "/Applications/RustDesk.app" ] && rm -rf "/Applications/RustDesk.app"
cp -R "$MOUNT_POINT/RustDesk.app" /Applications/
hdiutil detach "$MOUNT_POINT" -quiet
rm -rf "$TEMP_DIR"

echo -e "${GREEN}RustDesk instalado en /Applications${NC}"

# Configurar servidor
echo ""
echo -e "${YELLOW}[3/4] Configurando servidor...${NC}"
CONFIG_DIR="$HOME/Library/Preferences/com.carriez.RustDesk"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/RustDesk2.toml" << EOF
rendezvous_server = '${RENDEZVOUS_SERVER}:21116'
nat_type = 1
serial = 0
unlock_pin = ''
trusted_devices = ''

[options]
key = '${KEY}'
relay-server = '${RENDEZVOUS_SERVER}'
custom-rendezvous-server = '${RENDEZVOUS_SERVER}'
direct-server = 'Y'
direct-access-port = '21118'
EOF

echo -e "${GREEN}Servidor configurado: ${RENDEZVOUS_SERVER}${NC}"

# Arrancar, obtener ID y establecer contrasena
echo ""
echo -e "${YELLOW}[4/4] Iniciando RustDesk...${NC}"
open -g /Applications/RustDesk.app
sleep 4

RUSTDESK_ID=$(/Applications/RustDesk.app/Contents/MacOS/RustDesk --get-id 2>/dev/null || echo "")
if [ -z "$RUSTDESK_ID" ]; then
    sleep 4
    RUSTDESK_ID=$(/Applications/RustDesk.app/Contents/MacOS/RustDesk --get-id 2>/dev/null || echo "no disponible")
fi

sudo /Applications/RustDesk.app/Contents/MacOS/RustDesk --password "$PASSWORD" 2>/dev/null || true

echo -e "${GREEN}ID: ${RUSTDESK_ID}${NC}"

# Notificacion Pushover
HOSTNAME=$(scutil --get ComputerName 2>/dev/null || hostname)
if [ -n "$PUSHOVER_TOKEN" ] && [ -n "$PUSHOVER_USER" ]; then
    curl -s \
        -F "token=${PUSHOVER_TOKEN}" \
        -F "user=${PUSHOVER_USER}" \
        -F "title=RustDesk instalado: ${HOSTNAME}" \
        -F "message=ID: ${RUSTDESK_ID}
Password: ${PASSWORD}
Equipo: ${HOSTNAME}
Version: ${LATEST_VERSION}
Fecha: $(date '+%Y-%m-%d %H:%M')" \
        https://api.pushover.net/1/messages.json > /dev/null 2>&1 || true
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Instalacion completada!${NC}"
echo -e "${GREEN}  ID:      ${RUSTDESK_ID}${NC}"
echo -e "${GREEN}  Version: ${LATEST_VERSION}${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

osascript -e "display dialog \"RustDesk instalado correctamente.\n\nID: ${RUSTDESK_ID}\nVersion: ${LATEST_VERSION}\" buttons {\"Cerrar\"} default button 1 with title \"RustDesk\" with icon note" 2>/dev/null || true

echo -e "${GREEN}Instalacion finalizada. Puedes cerrar esta ventana.${NC}"
echo ""
