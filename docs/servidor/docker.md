# Instalación con Docker

Esta guía detalla la instalación del servidor RustDesk usando Docker Compose.

## Requisitos previos

### Hardware

- Cualquier servidor con Linux (VPS, NAS, Raspberry Pi, máquina virtual...)
- Mínimo 512 MB RAM, 1 GB recomendado
- Conexión a Internet estable

### Software

- Docker y Docker Compose
- Acceso root o sudo

## Instalación

### 1. Crear estructura de directorios

```bash
mkdir -p /opt/rustdesk/data
cd /opt/rustdesk
```

### 2. Crear docker-compose.yml

```yaml
version: '3.8'

services:
  hbbs:
    image: rustdesk/rustdesk-server:latest
    container_name: hbbs
    command: hbbs
    network_mode: host
    volumes:
      - ./data:/root
    restart: unless-stopped

  hbbr:
    image: rustdesk/rustdesk-server:latest
    container_name: hbbr
    command: hbbr
    network_mode: host
    volumes:
      - ./data:/root
    depends_on:
      - hbbs
    restart: unless-stopped

  rustdesk-api:
    image: lejianwen/rustdesk-api:latest
    container_name: rustdesk-api
    network_mode: host
    environment:
      - RUSTDESK_API_RUSTDESK_ID_SERVER=127.0.0.1:21116
      - RUSTDESK_API_RUSTDESK_RELAY_SERVER=127.0.0.1:21117
      - RUSTDESK_API_RUSTDESK_API_SERVER=http://127.0.0.1:21114
      - RUSTDESK_API_RUSTDESK_KEY=<TU_CLAVE_PUBLICA>
      - TZ=Europe/Madrid
    depends_on:
      - hbbs
      - hbbr
    restart: unless-stopped
```

### 3. Iniciar los servicios

```bash
docker-compose up -d
```

### 4. Obtener la clave pública

La primera vez que hbbs arranca, genera un par de claves en `/opt/rustdesk/data/`:

```bash
cat /opt/rustdesk/data/id_ed25519.pub
```

!!! important "Guarda esta clave"
    La necesitarás para:
    
    - Configurar la variable `RUSTDESK_API_RUSTDESK_KEY`
    - Configurar los clientes RustDesk
    - Configurar RustDesk Manager

### 5. Actualizar la clave en docker-compose

Edita `docker-compose.yml` y reemplaza `<TU_CLAVE_PUBLICA>` con la clave obtenida:

```bash
nano docker-compose.yml
docker-compose up -d
```

## Verificar instalación

### Comprobar que los servicios están corriendo

```bash
docker ps | grep rustdesk
```

Deberías ver los 3 contenedores: `hbbs`, `hbbr`, `rustdesk-api`

### Acceder al panel web

Abre en el navegador: `http://tu-servidor:21114`

!!! warning "Credenciales por defecto"
    Usuario: `admin` / Contraseña: `admin`
    
    **¡Cámbiala inmediatamente!**

## Siguiente paso

Configura los [puertos y firewall](red.md) para permitir conexiones externas.
