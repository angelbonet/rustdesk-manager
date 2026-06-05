#!/bin/bash
#
# Instalador automático de RustDesk para macOS
#
# USO: Doble clic en Instalar_RustDesk.command
#
# CONFIGURACIÓN: Edita config.txt con los datos de tu servidor
#

set -e

cd "$(dirname "$0")"

# === CARGAR CONFIGURACIÓN ===
CONFIG_FILE="config.txt"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: No se encuentra el archivo config.txt"
    echo "Crea el archivo config.txt con la configuración de tu servidor."
    exit 1
fi

# Función para leer valores del config
get_config() {
    grep "^$1=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2- | tr -d '\r'
}

RENDEZVOUS_SERVER=$(get_config "RENDEZVOUS_SERVER")
RELAY_SERVER=$(get_config "RELAY_SERVER")
KEY=$(get_config "KEY")
PASSWORD=$(get_config "PASSWORD")
PUSHOVER_TOKEN=$(get_config "PUSHOVER_TOKEN")
PUSHOVER_USER=$(get_config "PUSHOVER_USER")
RUSTDESK_VERSION=$(get_config "RUSTDESK_VERSION")

# Validar configuración obligatoria
if [ -z "$RENDEZVOUS_SERVER" ] || [ "$RENDEZVOUS_SERVER" = "tu-servidor.com" ]; then
    echo "Error: Configura RENDEZVOUS_SERVER en config.txt"
    exit 1
fi

if [ -z "$KEY" ] || [ "$KEY" = "tu_clave_publica_aqui" ]; then
    echo "Error: Configura KEY en config.txt"
    exit 1
fi

if [ -z "$PASSWORD" ] || [ "$PASSWORD" = "tu_contraseña_aqui" ]; then
    echo "Error: Configura PASSWORD en config.txt"
    exit 1
fi

# Valores por defecto
[ -z "$RELAY_SERVER" ] && RELAY_SERVER="$RENDEZVOUS_SERVER"
[ -z "$RUSTDESK_VERSION" ] && RUSTDESK_VERSION="1.4.6"

# === COLORES PARA MENSAJES ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Instalador automático de RustDesk                      ║${NC}"
echo -e "${GREEN}║     Servidor: ${RENDEZVOUS_SERVER}${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detectar arquitectura
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    echo -e "${YELLOW}Detectado: Mac con Apple Silicon (ARM)${NC}"
    DMG_URL="https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/rustdesk-${RUSTDESK_VERSION}-aarch64.dmg"
elif [ "$ARCH" = "x86_64" ]; then
    echo -e "${YELLOW}Detectado: Mac con Intel (x86_64)${NC}"
    DMG_URL="https://github.com/rustdesk/rustdesk/releases/download/${RUSTDESK_VERSION}/rustdesk-${RUSTDESK_VERSION}-x86_64.dmg"
else
    echo -e "${RED}Error: Arquitectura no soportada: $ARCH${NC}"
    exit 1
fi

# Crear directorio temporal
TEMP_DIR=$(mktemp -d)
DMG_FILE="$TEMP_DIR/rustdesk.dmg"

echo ""
echo -e "${YELLOW}[1/7] Descargando RustDesk v${RUSTDESK_VERSION}...${NC}"
curl -L -o "$DMG_FILE" "$DMG_URL" --progress-bar

echo ""
echo -e "${YELLOW}[2/7] Montando imagen de disco...${NC}"
MOUNT_POINT=$(hdiutil attach "$DMG_FILE" -nobrowse | grep "/Volumes" | awk '{print $3}')
echo "Montado en: $MOUNT_POINT"

echo ""
echo -e "${YELLOW}[3/7] Instalando RustDesk...${NC}"
# Cerrar RustDesk si está corriendo
pkill -f "RustDesk" 2>/dev/null || true
sleep 1

# Copiar a Aplicaciones
if [ -d "/Applications/RustDesk.app" ]; then
    echo "Eliminando versión anterior..."
    rm -rf "/Applications/RustDesk.app"
fi
cp -R "$MOUNT_POINT/RustDesk.app" /Applications/
echo "RustDesk instalado en /Applications"

# Desmontar DMG
hdiutil detach "$MOUNT_POINT" -quiet

echo ""
echo -e "${YELLOW}[4/7] Configurando servidor...${NC}"
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
relay-server = '${RELAY_SERVER}'
custom-rendezvous-server = '${RENDEZVOUS_SERVER}'
direct-server = 'Y'
direct-access-port = '21118'
EOF

echo "Configuración del servidor guardada"

echo ""
echo -e "${YELLOW}[5/7] Iniciando RustDesk para generar ID...${NC}"
open -g /Applications/RustDesk.app
sleep 3

# Obtener el ID
RUSTDESK_ID=$(/Applications/RustDesk.app/Contents/MacOS/RustDesk --get-id 2>/dev/null || echo "")

if [ -z "$RUSTDESK_ID" ]; then
    echo -e "${YELLOW}Esperando a que RustDesk genere el ID...${NC}"
    sleep 5
    RUSTDESK_ID=$(/Applications/RustDesk.app/Contents/MacOS/RustDesk --get-id 2>/dev/null || echo "ID no disponible")
fi

echo -e "${GREEN}ID de RustDesk: ${RUSTDESK_ID}${NC}"

echo ""
echo -e "${YELLOW}[6/7] Configurando contraseña permanente...${NC}"

# Traer Terminal al frente
osascript -e 'tell application "Terminal" to activate' 2>/dev/null || true
sleep 1

echo ""
echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
echo -e "${RED}  ESCRIBE TU CONTRASEÑA DE ADMINISTRADOR DEL MAC            ${NC}"
echo -e "${RED}  (la contraseña no se ve mientras escribes, es normal)     ${NC}"
echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
echo ""

if sudo /Applications/RustDesk.app/Contents/MacOS/RustDesk --password "$PASSWORD" 2>/dev/null; then
    echo ""
    echo -e "${GREEN}Contraseña permanente establecida${NC}"
else
    echo ""
    echo -e "${YELLOW}No se pudo establecer automáticamente.${NC}"
    echo -e "${YELLOW}Configúrala manualmente: RustDesk > Ajustes > Seguridad${NC}"
fi

echo ""
echo -e "${YELLOW}[7/7] Enviando notificación...${NC}"

# Obtener nombre del equipo
HOSTNAME=$(scutil --get ComputerName 2>/dev/null || hostname)

# Enviar a Pushover si está configurado
if [ -n "$PUSHOVER_TOKEN" ] && [ -n "$PUSHOVER_USER" ]; then
    PUSH_RESPONSE=$(curl -s -F "token=${PUSHOVER_TOKEN}" \
        -F "user=${PUSHOVER_USER}" \
        -F "title=RustDesk instalado: ${HOSTNAME}" \
        -F "message=ID: ${RUSTDESK_ID}
Password: ${PASSWORD}
Equipo: ${HOSTNAME}
Arquitectura: ${ARCH}
Fecha: $(date '+%Y-%m-%d %H:%M')" \
        https://api.pushover.net/1/messages.json 2>/dev/null)

    if echo "$PUSH_RESPONSE" | grep -q '"status":1'; then
        echo -e "${GREEN}Notificación enviada correctamente${NC}"
    else
        echo -e "${YELLOW}No se pudo enviar la notificación${NC}"
    fi
else
    echo -e "${YELLOW}Notificaciones Pushover no configuradas${NC}"
fi

echo ""
echo -e "${YELLOW}Limpiando archivos temporales...${NC}"
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ¡Instalación completada!                                  ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║  ID: ${RUSTDESK_ID}${NC}"
echo -e "${GREEN}║  Servidor: ${RENDEZVOUS_SERVER}${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Diálogo final
osascript -e 'display dialog "¡Instalación completada!\n\nID: '"${RUSTDESK_ID}"'\n\nRustDesk te pedirá los permisos necesarios cuando intentes conectar." buttons {"Cerrar"} default button 1 with title "RustDesk instalado" with icon note'

echo ""
echo -e "${GREEN}Instalación finalizada. Ya puedes cerrar esta ventana.${NC}"
echo ""
