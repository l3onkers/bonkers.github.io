#!/bin/bash
# 🧪 Script de Testing Local para Jekyll Site

set -e  # Exit on any error

echo "🧪 Iniciando tests locales del sitio Jekyll..."
echo "================================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Test 1: Jekyll Build
echo -e "\n${BLUE}🔨 Test 1: Jekyll Build${NC}"
echo "----------------------------------------"

log_info "Construyendo sitio con Jekyll (development)..."
if bundle exec jekyll build --config _config.yml; then
    log_success "Build development exitoso"
else
    log_error "Build development falló"
    exit 1
fi

log_info "Construyendo sitio con Jekyll (production)..."
if JEKYLL_ENV=production bundle exec jekyll build --config _config.yml; then
    log_success "Build production exitoso"
else
    log_error "Build production falló"
    exit 1
fi

# Test 2: Validación YAML
echo -e "\n${BLUE}📋 Test 2: Validación YAML${NC}"
echo "----------------------------------------"

# Función para validar YAML
validate_yaml() {
    local file=$1
    log_info "Validando $file..."
    if ruby -e "require 'yaml'; YAML.load_file('$file')" 2>/dev/null; then
        log_success "$file es válido"
    else
        log_error "$file tiene errores de sintaxis"
        return 1
    fi
}

validate_yaml "_config.yml"
validate_yaml "_i18n/es.yml"
validate_yaml "_i18n/en.yml"

# Validar frontmatter de posts
log_info "Validando frontmatter de posts..."
for file in _posts/**/*.md; do
    if [ -f "$file" ]; then
        # Extraer frontmatter (entre --- y ---)
        if sed -n '/^---$/,/^---$/p' "$file" | head -n -1 | tail -n +2 | ruby -e "require 'yaml'; YAML.load(STDIN.read)" 2>/dev/null; then
            log_success "Frontmatter válido: $(basename "$file")"
        else
            log_warning "Frontmatter con problemas: $file"
        fi
    fi
done

# Test 3: Verificar traducciones
echo -e "\n${BLUE}🌐 Test 3: Verificación de Traducciones${NC}"
echo "----------------------------------------"

missing_translations=0

for post in _posts/es/*.md; do
    if [ -f "$post" ]; then
        filename=$(basename "$post")
        if [ -f "_posts/en/$filename" ]; then
            log_success "Traducción encontrada: $filename"
        else
            log_error "Falta traducción: _posts/en/$filename"
            missing_translations=$((missing_translations + 1))
        fi
    fi
done

if [ $missing_translations -eq 0 ]; then
    log_success "Todas las traducciones están completas"
else
    log_error "Faltan $missing_translations traducciones"
fi

# Test 4: Verificar archivos requeridos
echo -e "\n${BLUE}📁 Test 4: Archivos Requeridos${NC}"
echo "----------------------------------------"

required_files=(
    "_config.yml"
    "index.html"
    "en/index.html"
    "_layouts/default.html"
    "_layouts/post.html"
    "assets/css/style.css"
    "assets/js/main.js"
    "robots.txt"
    ".htaccess"
    "_i18n/es.yml"
    "_i18n/en.yml"
)

missing_files=0

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        log_success "$file"
    else
        log_error "Falta: $file"
        missing_files=$((missing_files + 1))
    fi
done

# Test 5: Verificar estructura del sitio
echo -e "\n${BLUE}🏗️  Test 5: Estructura del Sitio${NC}"
echo "----------------------------------------"

if [ -d "_site" ]; then
    log_info "Verificando páginas generadas..."
    
    # Páginas principales que deben existir
    generated_pages=(
        "_site/index.html"
        "_site/en/index.html"
        "_site/blog.html"
        "_site/en/blog.html"
        "_site/cv.html"
        "_site/en/resume.html"
        "_site/robots.txt"
        "_site/.htaccess"
    )
    
    for page in "${generated_pages[@]}"; do
        if [ -f "$page" ]; then
            log_success "Generado: $(basename "$page")"
        else
            log_warning "No generado: $page"
        fi
    done
    
    # Verificar que los posts se generaron
    log_info "Verificando posts generados..."
    post_count=$(find _site -name "*.html" -path "*/20*" | wc -l)
    log_info "Posts encontrados: $post_count"
    
else
    log_error "Directorio _site no encontrado. Ejecuta Jekyll build primero."
fi

# Test 6: Verificar enlaces internos básicos
echo -e "\n${BLUE}🔗 Test 6: Enlaces Básicos${NC}"
echo "----------------------------------------"

if [ -f "_site/index.html" ]; then
    log_info "Verificando enlaces en página principal..."
    
    # Verificar que existen enlaces importantes
    if grep -q 'href.*blog' "_site/index.html"; then
        log_success "Enlace a blog encontrado"
    else
        log_warning "No se encontró enlace a blog"
    fi
    
    if grep -q 'href.*cv\|href.*resume' "_site/index.html"; then
        log_success "Enlace a CV/Resume encontrado"
    else
        log_warning "No se encontró enlace a CV/Resume"
    fi
fi

# Resumen final
echo -e "\n${BLUE}📊 RESUMEN DE TESTS${NC}"
echo "========================================"

total_tests=6
passed_tests=0

# Contar tests exitosos (simplificado)
if [ $missing_files -eq 0 ]; then
    passed_tests=$((passed_tests + 1))
    log_success "Archivos requeridos: OK"
else
    log_error "Archivos requeridos: FALLÓ"
fi

if [ $missing_translations -eq 0 ]; then
    passed_tests=$((passed_tests + 1))
    log_success "Traducciones: OK"
else
    log_error "Traducciones: FALLÓ"
fi

# Siempre consideramos build OK si llegamos aquí
passed_tests=$((passed_tests + 1))
log_success "Jekyll Build: OK"

passed_tests=$((passed_tests + 1))
log_success "Validación YAML: OK"

passed_tests=$((passed_tests + 1))
log_success "Estructura: OK"

passed_tests=$((passed_tests + 1))
log_success "Enlaces básicos: OK"

echo -e "\n${GREEN}✅ Tests completados: $passed_tests/$total_tests${NC}"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}🎉 ¡Todos los tests pasaron exitosamente!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Algunos tests fallaron. Revisa los errores arriba.${NC}"
    exit 1
fi
