# Instalación en macOS

## Requisitos

- macOS 10.15 o superior
- Acceso de administrador
- Archivo `config.txt` configurado

## Método 1: Doble clic

1. Asegúrate de que `config.txt` está configurado
2. Haz doble clic en `Instalar_RustDesk.command`
3. Si macOS muestra un aviso de seguridad:
   - Ve a **Preferencias del Sistema > Seguridad y Privacidad**
   - En la pestaña General, haz clic en **"Abrir igualmente"**
4. Introduce tu contraseña de administrador cuando se solicite
5. Acepta los permisos de Accesibilidad y Grabación de pantalla

## Método 2: Terminal

```bash
cd ~/Downloads/deployment
chmod +x install_rustdesk_mac.sh
./install_rustdesk_mac.sh
```

## Características

- Detecta automáticamente Mac Intel o Apple Silicon
- Descarga la versión correcta de RustDesk
- Configura servidor y contraseña permanente
- Notificación opcional vía Pushover

## Permisos necesarios

Después de instalar, RustDesk necesita permisos para funcionar:

1. Ve a **Preferencias del Sistema > Seguridad y Privacidad > Privacidad**
2. Activa RustDesk en:
   - **Accesibilidad** - Para controlar el equipo
   - **Grabación de pantalla** - Para compartir pantalla

!!! tip "Automatizar permisos"
    En entornos empresariales, puedes usar MDM (Jamf, Mosyle, etc.) para otorgar estos permisos automáticamente.

## Solución de problemas

### "No se puede abrir porque es de un desarrollador no identificado"

Ve a **Preferencias del Sistema > Seguridad y Privacidad > General** y haz clic en "Abrir igualmente".

O desde Terminal:
```bash
xattr -d com.apple.quarantine Instalar_RustDesk.command
```

### RustDesk no puede controlar el ordenador

Verifica que los permisos están activados en:

- **Preferencias del Sistema > Seguridad y Privacidad > Privacidad > Accesibilidad**
- **Preferencias del Sistema > Seguridad y Privacidad > Privacidad > Grabación de pantalla**

### El script no encuentra config.txt

Asegúrate de que `config.txt` está en la misma carpeta que el script.
