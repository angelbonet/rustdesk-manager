# HTTPS y seguridad

Para acceder al panel web de forma segura, configura un reverse proxy con HTTPS.

## Requisitos

- Un dominio apuntando a tu servidor
- Nginx instalado
- Certbot para Let's Encrypt

## Instalación

### 1. Instalar Nginx y Certbot

=== "Ubuntu/Debian"
    ```bash
    apt install nginx certbot python3-certbot-nginx
    ```

=== "CentOS/RHEL"
    ```bash
    yum install nginx certbot python3-certbot-nginx
    ```

### 2. Crear configuración de Nginx

```bash
nano /etc/nginx/sites-available/rustdesk-api
```

```nginx
server {
    listen 443 ssl http2;
    server_name rustdesk.tu-dominio.com;

    ssl_certificate /etc/letsencrypt/live/rustdesk.tu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rustdesk.tu-dominio.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:21114;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. Activar y obtener certificado

```bash
ln -s /etc/nginx/sites-available/rustdesk-api /etc/nginx/sites-enabled/
certbot --nginx -d rustdesk.tu-dominio.com
systemctl reload nginx
```

## Verificar

Accede a `https://rustdesk.tu-dominio.com`

!!! success "Conexión segura"
    Ahora puedes acceder al panel web de forma segura con HTTPS.

## Renovación automática

Certbot configura automáticamente un cron para renovar los certificados. Puedes verificarlo:

```bash
certbot renew --dry-run
```

## Configurar RustDesk Manager

En RustDesk Manager, usa la URL HTTPS en la configuración:

- **URL del servidor:** `https://rustdesk.tu-dominio.com`

## Siguiente paso

Consulta la guía de [Mantenimiento](mantenimiento.md) para backups y actualizaciones.
