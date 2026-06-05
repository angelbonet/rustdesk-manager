# Contribuir

## Requisitos de desarrollo

- Node.js 18+
- npm 9+
- Git

## Setup

```bash
# Clonar repositorio
git clone https://github.com/abdatabase/rustdesk-manager.git
cd rustdesk-manager

# Instalar dependencias
npm install

# Ejecutar en modo desarrollo
npm start
```

## Flujo de trabajo

1. Crea un fork del repositorio
2. Crea una rama para tu feature: `git checkout -b feature/mi-feature`
3. Haz tus cambios
4. Prueba que todo funciona: `npm start`
5. Commit: `git commit -m "Añade mi feature"`
6. Push: `git push origin feature/mi-feature`
7. Abre un Pull Request

## Estilo de código

- Usa 4 espacios para indentación
- Nombres de variables en camelCase
- Nombres de archivos en kebab-case
- Comenta solo lo no obvio

## Compilar para producción

```bash
# Solo macOS
npm run build:mac

# Solo Windows
npm run build:win

# Ambos
npm run build:all
```

Los instaladores se generan en `dist/`.

## Documentación

La documentación usa MkDocs Material. Para previsualizarla:

```bash
pip install mkdocs-material
mkdocs serve
```

Abre `http://localhost:8000` en tu navegador.

## Reportar bugs

Abre un issue en [GitHub Issues](https://github.com/abdatabase/rustdesk-manager/issues) con:

- Versión de RustDesk Manager
- Sistema operativo
- Pasos para reproducir
- Comportamiento esperado vs actual
- Capturas de pantalla si aplica
