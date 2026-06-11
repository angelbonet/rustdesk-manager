#!/bin/bash
#
# Instalador de RustDesk para macOS
# Doble clic para ejecutar
#
# SI macOS LO BLOQUEA:
#   1. Ve a Preferencias del Sistema > Seguridad y Privacidad
#   2. En la pestaña General, haz clic en "Abrir igualmente"
#   O desde Terminal: xattr -d com.apple.quarantine Instalar_RustDesk.command
#

cd "$(dirname "$0")"
./install_rustdesk_mac.sh
