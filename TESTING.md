# 🧪 Testing Guide - Jekyll Site

## 📋 Tipos de Tests Implementados

### 🔥 **Tests Automáticos (GitHub Actions)**
- **Jekyll Build**: Verifica que el sitio compile sin errores
- **Validación HTML**: Comprueba HTML5 válido y accesibilidad
- **Validación de Contenido**: Verifica traducciones y estructura
- **Performance**: Tests de Lighthouse y optimización

### 🖥️ **Tests Locales**
- **Script PowerShell**: `scripts/test.ps1` (Windows)
- **Script Bash**: `scripts/test.sh` (Linux/Mac)
- **RSpec**: Tests unitarios detallados
- **HTML-Proofer**: Verificación de enlaces

## 🚀 Cómo Ejecutar Tests

### **Requisitos Previos**
```bash
# Instalar Ruby (Windows)
# Descargar desde: https://rubyinstaller.org/

# Verificar instalación
ruby --version
gem --version

# Instalar Bundler
gem install bundler

# Instalar dependencias del proyecto
bundle install
```

### **Ejecutar Tests Locales**

#### **Windows (PowerShell)**
```powershell
# Test rápido
.\scripts\test.ps1

# Test con verbose
.\scripts\test.ps1 -Verbose
```

#### **Linux/Mac (Bash)**
```bash
# Test rápido
bash scripts/test.sh

# Hacer ejecutable primero
chmod +x scripts/test.sh
./scripts/test.sh
```

#### **RSpec (Detallado)**
```bash
# Ejecutar todos los tests
bundle exec rspec

# Tests específicos
bundle exec rspec spec/site_spec.rb

# Con formato detallado
bundle exec rspec --format documentation

# Solo tests rápidos
bundle exec rspec --tag ~slow
```

#### **Makefile (Recomendado)**
```bash
# Ver comandos disponibles
make help

# Setup inicial
make setup

# Tests completos
make test

# Tests locales rápidos
make test-local

# Solo validación YAML
make test-yaml

# Solo HTML y enlaces
make test-html
```

## 📊 Qué Verifican los Tests

### **✅ Build y Configuración**
- Jekyll compila sin errores (dev y prod)
- Archivos YAML válidos (_config.yml, traducciones)
- Plugins y dependencias funcionan

### **✅ Estructura y Contenido**
- Archivos requeridos presentes
- Páginas principales generadas
- Posts organizados por idioma
- Traducciones completas (ES ↔ EN)

### **✅ HTML y Accesibilidad**
- HTML5 válido
- Enlaces internos funcionan
- Meta tags correctos
- Accesibilidad básica

### **✅ Performance**
- Tamaño de archivos CSS/JS
- Lighthouse scores
- Optimización de imágenes

### **✅ Seguridad**
- Meta robots para no-indexing
- Headers de seguridad (.htaccess)
- No exposición de versiones

## 🔄 Integración Continua

### **GitHub Actions (.github/workflows/test.yml)**
Los tests se ejecutan automáticamente en:
- ✅ Push a `main`
- ✅ Pull Requests
- ✅ Creación de tags
- ✅ Releases
- ✅ Manualmente

### **Resultados**
- **✅ Pass**: Todo correcto, deploy procede
- **❌ Fail**: Errores encontrados, deploy bloqueado
- **📊 Reports**: Lighthouse y artefactos disponibles

## 🛠️ Configuración Avanzada

### **HTML-Proofer Options**
```ruby
# En spec/site_spec.rb
options = {
  check_external_hash: false,    # No verificar fragmentos externos
  disable_external: true,        # Solo enlaces internos
  allow_hash_href: true,         # Permitir href="#"
  check_html: true,              # Validar HTML
  check_img_http: false,         # No verificar HTTP en imágenes
  enforce_https: false           # No forzar HTTPS
}
```

### **Personalizar Tests**
```ruby
# Agregar test personalizado en spec/site_spec.rb
it "has custom validation" do
  # Tu validación aquí
  expect(something).to be_something
end
```

## 📋 Comandos de Testing Rápidos

```bash
# Desarrollo diario
make dev                    # Instalar + servir + watch

# Antes de commit
make test-local            # Tests rápidos

# Antes de release
make test                  # Tests completos
make build-prod           # Build de producción

# Debugging
make test-yaml             # Solo YAML
make clean && make build   # Build limpio
```

## 🎯 Best Practices

### **✅ Hacer**
- Ejecutar tests antes de cada commit
- Verificar builds de producción
- Mantener traducciones sincronizadas
- Revisar reports de Lighthouse

### **❌ Evitar**
- Commits que rompen el build
- Traducciones incompletas
- Enlaces rotos
- Archivos de gran tamaño sin optimizar

## 🔍 Troubleshooting

### **Error: Ruby no encontrado**
```bash
# Windows: Instalar Ruby desde rubyinstaller.org
# Mac: brew install ruby
# Linux: sudo apt install ruby-full
```

### **Error: Bundle no encontrado**
```bash
gem install bundler
```

### **Error: Tests fallan localmente**
```bash
# Limpiar y reinstalar
make clean
bundle install
make build
```

### **Error: HTML-Proofer falla**
```bash
# Ejecutar solo validación básica
make test-yaml
make build
```

## 📈 Métricas de Calidad

### **Targets Recomendados**
- ✅ Build time: < 30 segundos
- ✅ CSS size: < 100KB
- ✅ JS size: < 50KB
- ✅ Lighthouse Score: > 90
- ✅ Accessibility: > 95
- ✅ HTML validation: 0 errores

### **Monitoreo**
- GitHub Actions dashboard
- Lighthouse reports en artefactos
- RSpec outputs detallados
- Performance tracking en PRs
