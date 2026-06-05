# Instalación en Windows

## Requisitos

- Windows 10 o superior
- Acceso de administrador
- Archivo `config.txt` configurado

## Archivos necesarios

Todos estos archivos deben estar en la misma carpeta:

- `Instalar_RustDesk.bat`
- `install_rustdesk_windows.ps1`
- `config.txt`

## Instalación

1. Asegúrate de que `config.txt` está configurado
2. Haz clic derecho en `Instalar_RustDesk.bat`
3. Selecciona **"Ejecutar como administrador"**
4. Espera a que termine la instalación

!!! note "Windows SmartScreen"
    Si Windows SmartScreen bloquea el archivo, haz clic en **"Más información"** > **"Ejecutar de todos modos"**.

## Características

- Descarga RustDesk automáticamente
- Instala silenciosamente
- Configura servidor y contraseña permanente
- Notificación opcional vía Pushover

## Solución de problemas

### El script no se ejecuta

Haz clic derecho > **"Ejecutar como administrador"**

### "Error: Configura X en config.txt"

Abre `config.txt` y rellena los valores requeridos:

```ini
RENDEZVOUS_SERVER=tu-servidor.com
KEY=tu-clave-publica
PASSWORD=contraseña
```

### PowerShell muestra error de políticas

Si ves un error sobre políticas de ejecución, ejecuta PowerShell como administrador y ejecuta:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### RustDesk se instala pero no conecta

1. Verifica que los valores en `config.txt` son correctos
2. Asegúrate de que el servidor está accesible desde este equipo
3. Comprueba que el firewall de Windows permite RustDesk
