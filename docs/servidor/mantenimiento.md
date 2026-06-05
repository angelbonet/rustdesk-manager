# Mantenimiento

## Ver logs

```bash
docker logs -f hbbs
docker logs -f hbbr
docker logs -f rustdesk-api
```

Para ver las últimas 100 líneas:

```bash
docker logs --tail 100 rustdesk-api
```

## Actualizar contenedores

```bash
cd /opt/rustdesk
docker-compose pull
docker-compose up -d
```

!!! tip "Verificar después de actualizar"
    ```bash
    docker ps | grep rustdesk
    ```

## Backup

Los datos importantes están en `/opt/rustdesk/data/`:

- `id_ed25519` y `id_ed25519.pub` - Claves del servidor
- Base de datos del API server

### Crear backup

```bash
tar -czf rustdesk-backup-$(date +%Y%m%d).tar.gz /opt/rustdesk/data
```

### Restaurar backup

```bash
cd /opt/rustdesk
docker-compose down
tar -xzf rustdesk-backup-YYYYMMDD.tar.gz -C /
docker-compose up -d
```

## Renovar certificados Let's Encrypt

Si configuraste HTTPS:

```bash
certbot renew
systemctl reload nginx
```

!!! note "Renovación automática"
    Certbot configura un cron que renueva automáticamente los certificados antes de que expiren.

## Solución de problemas

### La API no responde

1. Verificar que el contenedor está corriendo:
   ```bash
   docker ps | grep rustdesk-api
   ```

2. Verificar logs:
   ```bash
   docker logs rustdesk-api
   ```

3. Verificar que la clave está correctamente configurada

### El panel web muestra error de autenticación

- Verifica que `RUSTDESK_API_RUSTDESK_KEY` coincide con `id_ed25519.pub`
- Reinicia el contenedor después de cambiar variables de entorno:
  ```bash
  docker-compose restart rustdesk-api
  ```

### Reiniciar todos los servicios

```bash
cd /opt/rustdesk
docker-compose restart
```

### Reinicio completo (destruye y recrea)

```bash
cd /opt/rustdesk
docker-compose down
docker-compose up -d
```

## Monitorización

### Comprobar uso de recursos

```bash
docker stats hbbs hbbr rustdesk-api
```

### Comprobar espacio en disco

```bash
du -sh /opt/rustdesk/data
```
