# Configuración inicial

Después de instalar RustDesk Manager, necesitas conectarlo con tu servidor API RustDesk.

## Pasos

1. Abre **Ajustes** (icono de engranaje en la esquina superior derecha)
2. En la sección **Servidor**, introduce:

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| **URL del servidor** | Dirección completa de tu API | `https://rustdesk.tudominio.com:21443` |
| **Usuario** | Usuario administrador de la API | `admin` |
| **Contraseña** | Contraseña del usuario | `********` |

3. Haz clic en **Probar conexión** para verificar
4. Si la conexión es exitosa, haz clic en **Guardar**

!!! success "Sincronización automática"
    Una vez configurado, la app sincronizará automáticamente los equipos registrados en tu servidor cada 60 segundos.

## Ajustes adicionales

### Idioma

Selecciona tu idioma preferido: Español, English o Français.

### Contraseña por defecto

Define una contraseña que se aplicará automáticamente a los nuevos equipos sincronizados.

### Intervalos

- **Sincronización**: Cada cuántos segundos consultar nuevos equipos (por defecto: 60)
- **Estado**: Cada cuántos segundos actualizar el estado online/offline (por defecto: 30)

## ¿No tienes servidor?

Si aún no has montado tu servidor RustDesk, consulta la [Guía del servidor](../servidor/index.md) para instalarlo paso a paso.

## Siguiente paso

Continúa con el [Manual de uso](manual.md) para aprender a gestionar tus equipos.
