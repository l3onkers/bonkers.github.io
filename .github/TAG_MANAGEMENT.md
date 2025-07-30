# 🏷️ Gestión de Tags - Guía de Referencia

## 📋 Comandos Básicos

### Crear tags locales
```bash
# Tag simple
git tag v0.9.1-beta

# Tag anotado con mensaje
git tag -a v0.9.1-beta -m "Descripción de la versión"

# Tag anotado con mensaje multilínea
git tag -a v1.0.0 -m "🎉 Versión 1.0.0 - Sitio Web Público

✨ Características finales:
- Sitio completo y optimizado
- Contenido finalizado
- Indexación habilitada
- Testing completo realizado"
```

### Gestionar tags
```bash
# Listar tags locales
git tag -l

# Listar tags remotos
git ls-remote --tags origin

# Ver información de un tag
git show v0.9.0-beta

# Eliminar tag local
git tag -d v0.9.0-beta

# Eliminar tag remoto
git push origin --delete v0.9.0-beta
```

### Subir tags
```bash
# Subir tag específico
git push origin v0.9.1-beta

# Subir todos los tags
git push origin --tags
```

### Trabajar con versiones
```bash
# Cambiar a un tag específico
git checkout v0.9.0-beta

# Crear branch desde un tag
git checkout -b hotfix-v0.9.0 v0.9.0-beta

# Ver diferencias desde un tag
git diff v0.9.0-beta..HEAD

# Ver commits desde un tag
git log v0.9.0-beta..HEAD --oneline
```

## 🎯 Estrategia de Versionado

### Esquema recomendado:
- `v0.x.x-beta` → Versiones en desarrollo
- `v0.x.x-rc` → Release candidates
- `v1.0.0` → Primera versión pública estable
- `v1.x.x` → Versiones públicas con nuevas funcionalidades
- `v2.0.0` → Cambios mayores (breaking changes)

### Ejemplos prácticos:
- `v0.9.0-beta` ← Estado actual
- `v0.9.1-beta` → Pequeñas correcciones
- `v0.10.0-rc` → Release candidate
- `v1.0.0` → Versión final pública
- `v1.1.0` → Nuevas funcionalidades
- `v1.1.1` → Hotfixes

## 🛡️ Buenas Prácticas

### ✅ Hacer
- Usar tags anotados con mensajes descriptivos
- Seguir semantic versioning
- Crear releases desde tags importantes
- Proteger tags de versión con repository rules
- Documentar cambios en cada tag

### ❌ Evitar
- Eliminar tags que ya están en production
- Reutilizar números de versión
- Tags sin mensaje descriptivo
- Cambiar tags después de publicar releases
