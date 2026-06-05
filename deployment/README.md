# Scripts de Instalación Automática de RustDesk

Estos scripts instalan RustDesk y lo configuran automáticamente con tu servidor.

## Configuración inicial

**Antes de usar los instaladores, configura tu servidor:**

1. Abre el archivo `config.txt`
2. Rellena los valores con los datos de tu servidor:
   - `RENDEZVOUS_SERVER` - Dirección de tu servidor
   - `KEY` - Clave pública del servidor
   - `PASSWORD` - Contraseña para los clientes
3. Guarda el archivo

El archivo `config.txt` contiene datos sensibles. **No lo subas a repositorios públicos.**

---

## Para macOS

### Archivo: `Instalar_RustDesk.command`

**Instrucciones para el usuario:**

1. Asegúrate de que `config.txt` está configurado
2. Haz doble clic en `Instalar_RustDesk.command`
3. Si macOS muestra un aviso de seguridad:
   - Ve a **Preferencias del Sistema > Seguridad y Privacidad**
   - En la pestaña General, haz clic en **"Abrir igualmente"**
4. Introduce tu contraseña de administrador cuando se solicite
5. Acepta los permisos de Accesibilidad y Grabación de pantalla

### Alternativa: Terminal

```bash
cd ~/Downloads/deployment
chmod +x install_rustdesk_mac.sh
./install_rustdesk_mac.sh
```

**Características:**
- Detecta automáticamente Mac Intel o Apple Silicon
- Descarga la versión correcta de RustDesk
- Configura servidor y contraseña permanente
- Notificación opcional via Pushover

---

## Para Windows

### Archivos necesarios:

- `Instalar_RustDesk.bat`
- `install_rustdesk_windows.ps1`
- `config.txt`

**Instrucciones para el usuario:**

1. Asegúrate de que `config.txt` está configurado
2. Haz clic derecho en `Instalar_RustDesk.bat`
3. Selecciona **"Ejecutar como administrador"**
4. Espera a que termine la instalación

**Nota:** Si Windows SmartScreen bloquea el archivo, haz clic en "Más información" > "Ejecutar de todos modos".

---

## Archivos incluidos

| Archivo | Descripción |
|---------|-------------|
| `config.txt` | **Configuración del servidor** (editar antes de usar) |
| `Instalar_RustDesk.command` | Launcher macOS (doble clic) |
| `install_rustdesk_mac.sh` | Script de instalación macOS |
| `Instalar_RustDesk.bat` | Launcher Windows (doble clic) |
| `install_rustdesk_windows.ps1` | Script de instalación Windows |

---

## Distribución a clientes

### Para tu uso personal

Configura `config.txt` una vez y usa los instaladores en todos los equipos.

### Para distribución pública

1. **No incluyas** `config.txt` en la distribución
2. Proporciona un `config.txt.example` con valores de ejemplo
3. Los usuarios deben crear su propio `config.txt`

---

## Notificaciones Pushover (opcional)

Si configuras las credenciales de Pushover en `config.txt`, recibirás una notificación cada vez que se instale RustDesk en un equipo con:

- Nombre del equipo
- ID de RustDesk generado
- Contraseña configurada
- Fecha y hora

Obtén tus credenciales en [pushover.net](https://pushover.net)

---

## Actualizar versión de RustDesk

Edita `RUSTDESK_VERSION` en `config.txt`:

```
RUSTDESK_VERSION=1.4.6
```

Consulta las versiones disponibles en [github.com/rustdesk/rustdesk/releases](https://github.com/rustdesk/rustdesk/releases)

---

## Solución de problemas

### macOS: "No se puede abrir porque es de un desarrollador no identificado"

Ve a Preferencias del Sistema > Seguridad y Privacidad > General y haz clic en "Abrir igualmente".

O desde Terminal:
```bash
xattr -d com.apple.quarantine Instalar_RustDesk.command
```

### macOS: RustDesk no puede controlar el ordenador

Debes dar permisos en:
- Preferencias del Sistema > Seguridad y Privacidad > Privacidad > **Accesibilidad**
- Preferencias del Sistema > Seguridad y Privacidad > Privacidad > **Grabación de pantalla**

### Windows: El script no se ejecuta

Haz clic derecho > "Ejecutar como administrador"

### Windows: "Error: Configura X en config.txt"

Abre `config.txt` y rellena los valores requeridos.
