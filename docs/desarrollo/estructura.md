# Estructura del proyecto

```
rustdesk-manager/
├── electron/           # Proceso principal Electron
│   ├── main.js         # Ventana principal y ciclo de vida
│   └── preload.js      # Bridge seguro para renderer
├── server/             # Servidor Express (backend)
│   ├── index.js        # Rutas API REST
│   ├── database.js     # SQLite via sql.js
│   ├── config.js       # Gestión de configuración
│   ├── api.js          # Cliente HTTP para API RustDesk
│   └── i18n.js         # Traducciones (ES/EN/FR)
├── templates/          # Frontend
│   └── index.html      # UI principal (Tailwind CSS + Nunjucks)
├── static/             # Assets estáticos
│   ├── logo.png        # Logo abDatabase
│   └── icon.png        # Icono de la app
├── build/              # Recursos de compilación
│   ├── icon.icns       # Icono macOS
│   ├── icon.ico        # Icono Windows
│   └── icon.png        # Icono genérico
├── dist/               # Builds compilados (ignorado en git)
│   ├── *.dmg           # Instalador macOS
│   └── *.exe           # Instalador Windows
├── deployment/         # Scripts de despliegue RustDesk
├── docs/               # Documentación (MkDocs)
└── mkdocs.yml          # Configuración MkDocs Material
```

## Tecnologías

| Componente | Tecnología | Versión |
|------------|------------|---------|
| Framework desktop | Electron | 28.x |
| Runtime | Node.js | 18+ |
| Servidor web | Express | 5.x |
| Base de datos | sql.js (SQLite en WebAssembly) | 1.14 |
| Plantillas | Nunjucks | 3.2 |
| CSS | Tailwind CSS | 3.x (CDN) |
| Empaquetado | electron-builder | 24.x |

## Almacenamiento de datos

Los datos del usuario se guardan fuera del directorio de la aplicación:

| Sistema | Ubicación |
|---------|-----------|
| macOS | `~/Library/Application Support/rustdesk-manager/` |
| Windows | `%APPDATA%/rustdesk-manager/` |

Archivos:

- `rustdesk_manager.db` - Base de datos SQLite
- `config.json` - Configuración del servidor

## Scripts npm

```bash
npm start          # Inicia Electron en modo desarrollo
npm run build:mac  # Compila DMG para macOS (universal)
npm run build:win  # Compila EXE para Windows (x64)
npm run build:all  # Compila para ambas plataformas
```
