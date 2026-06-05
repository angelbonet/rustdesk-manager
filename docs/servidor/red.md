# Configuración de red

## Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                           INTERNET                               │
│                                                                  │
│  Clientes RustDesk se conectan a tu-servidor.com                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      ROUTER / FIREWALL                           │
│                                                                  │
│  NAT de puertos:                                                 │
│  • 21115 TCP      → Servidor (NAT type test)                    │
│  • 21116 TCP+UDP  → Servidor (hbbs - ID Server)                 │
│  • 21117 TCP      → Servidor (hbbr - Relay)                     │
│  • 21118 TCP      → Servidor (Web client, opcional)             │
│  • 21114 TCP      → Servidor (API, opcional)                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         TU SERVIDOR                              │
│                    (VPS, NAS, Raspberry Pi...)                   │
│                                                                  │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐    │
│   │    hbbs     │  │    hbbr     │  │    rustdesk-api     │    │
│   │  (ID Srv)   │  │   (Relay)   │  │   (Panel web/API)   │    │
│   │             │  │             │  │                     │    │
│   │ :21115 TCP  │  │ :21117 TCP  │  │ :21114 TCP          │    │
│   │ :21116 TCP  │  │             │  │                     │    │
│   │ :21116 UDP  │  │             │  │                     │    │
│   └─────────────┘  └─────────────┘  └─────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

## Puertos necesarios

| Puerto | Protocolo | Servicio | Obligatorio |
|--------|-----------|----------|-------------|
| 21115 | TCP | NAT type test | Sí |
| 21116 | TCP | ID Server | Sí |
| 21116 | UDP | ID Server (hole punching) | Sí |
| 21117 | TCP | Relay Server | Sí |
| 21118 | TCP | Web client | No |
| 21114 | TCP | API Server | No* |

!!! note "API Server"
    El puerto 21114 es obligatorio si usas RustDesk Manager o el panel web.

## Configuración del router

### Opción A: IP fija

Si tu proveedor de Internet te da IP fija, simplemente apunta tu dominio a esa IP.

### Opción B: IP dinámica con DDNS

Usa un servicio de DNS dinámico:

- [DuckDNS](https://www.duckdns.org/) (gratuito)
- [No-IP](https://www.noip.com/) (gratuito con limitaciones)
- [Cloudflare](https://www.cloudflare.com/) (gratuito, requiere dominio propio)

Configura tu router o un cliente DDNS para actualizar la IP automáticamente.

### Port Forwarding

Crea reglas de NAT/Port Forwarding en tu router:

```
Puerto externo    Protocolo    IP interna       Puerto interno
21115             TCP          <IP-SERVIDOR>    21115
21116             TCP+UDP      <IP-SERVIDOR>    21116
21117             TCP          <IP-SERVIDOR>    21117
21118             TCP          <IP-SERVIDOR>    21118
21114             TCP          <IP-SERVIDOR>    21114
```

!!! tip "IP del servidor"
    Reemplaza `<IP-SERVIDOR>` con la IP local de tu servidor (ej: 192.168.1.100)

## Verificar puertos

### Desde otra red

```bash
nc -zv tu-servidor.com 21116
nc -zv tu-servidor.com 21117
```

### Servicios online

- [yougetsignal.com/tools/open-ports/](https://www.yougetsignal.com/tools/open-ports/)
- [portchecker.co](https://portchecker.co/)

## Solución de problemas

### Los clientes no conectan

1. **Verificar puertos:** Asegúrate de que están abiertos y redirigidos correctamente
2. **Verificar clave:** La clave en el cliente debe coincidir con la del servidor
3. **Verificar firewall:** Tanto en el router como en el servidor

### Conexiones siempre via relay (lentas)

- El puerto **UDP 21116** debe estar abierto (necesario para hole punching)
- Algunos NAT simétricos impiden conexiones P2P

## Siguiente paso

Configura [HTTPS y seguridad](https.md) para acceder al panel de forma segura.
