# 🛠️ Makefile para Jekyll Site
# Uso: make [comando]

.PHONY: help install build serve test test-local clean deps

# Configuración por defecto
JEKYLL_ENV ?= development
PORT ?= 4000

help: ## 📋 Mostrar ayuda
	@echo "🛠️  Comandos disponibles:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

install: ## 📦 Instalar dependencias
	@echo "📦 Instalando dependencias..."
	bundle install

deps: install ## 📦 Alias para install

build: ## 🔨 Construir sitio
	@echo "🔨 Construyendo sitio ($(JEKYLL_ENV))..."
	JEKYLL_ENV=$(JEKYLL_ENV) bundle exec jekyll build --config _config.yml

build-prod: ## 🚀 Construir sitio para producción
	@echo "🚀 Construyendo sitio para producción..."
	$(MAKE) build JEKYLL_ENV=production

serve: ## 🌐 Servir sitio localmente
	@echo "🌐 Sirviendo sitio en http://localhost:$(PORT)..."
	bundle exec jekyll serve --config _config.yml --port $(PORT) --livereload

serve-prod: ## 🌐 Servir sitio en modo producción
	@echo "🌐 Sirviendo sitio en modo producción..."
	$(MAKE) serve JEKYLL_ENV=production

test: build ## 🧪 Ejecutar tests completos
	@echo "🧪 Ejecutando tests..."
	bundle exec rspec spec/ --format documentation

test-local: ## 🧪 Ejecutar tests locales rápidos
	@echo "🧪 Ejecutando tests locales..."
ifeq ($(OS),Windows_NT)
	powershell -ExecutionPolicy Bypass -File scripts/test.ps1
else
	bash scripts/test.sh
endif

test-html: build ## 🔍 Verificar HTML y enlaces
	@echo "🔍 Verificando HTML y enlaces..."
	bundle exec htmlproofer _site --disable-external --allow-hash-href

test-yaml: ## 📋 Verificar archivos YAML
	@echo "📋 Verificando archivos YAML..."
	ruby -e "require 'yaml'; YAML.load_file('_config.yml')"
	ruby -e "require 'yaml'; YAML.load_file('_i18n/es.yml')"
	ruby -e "require 'yaml'; YAML.load_file('_i18n/en.yml')"
	@echo "✅ Todos los archivos YAML son válidos"

clean: ## 🧹 Limpiar archivos generados
	@echo "🧹 Limpiando archivos generados..."
	rm -rf _site
	rm -rf .jekyll-cache
	rm -rf .sass-cache

fresh: clean build ## 🆕 Build limpio desde cero

dev: clean install serve ## 🚀 Setup completo para desarrollo

check-deps: ## 🔍 Verificar dependencias
	@echo "🔍 Verificando dependencias..."
	@command -v ruby >/dev/null 2>&1 || { echo "❌ Ruby no está instalado"; exit 1; }
	@command -v bundle >/dev/null 2>&1 || { echo "❌ Bundler no está instalado"; exit 1; }
	@command -v node >/dev/null 2>&1 || { echo "⚠️  Node.js no está instalado (opcional)"; }
	@echo "✅ Dependencias principales verificadas"

status: ## 📊 Mostrar estado del proyecto
	@echo "📊 Estado del proyecto:"
	@echo "  Ruby: $$(ruby --version)"
	@echo "  Bundler: $$(bundle --version)"
	@echo "  Jekyll: $$(bundle exec jekyll --version)"
	@echo "  Posts ES: $$(find _posts/es -name '*.md' | wc -l)"
	@echo "  Posts EN: $$(find _posts/en -name '*.md' | wc -l)"
	@echo "  Último build: $$(if [ -d _site ]; then echo 'Existe'; else echo 'No encontrado'; fi)"

setup: ## 🛠️  Setup inicial del proyecto
	@echo "🛠️  Configurando proyecto..."
	$(MAKE) check-deps
	$(MAKE) install
	@echo "✅ Proyecto configurado correctamente"
	@echo "💡 Ejecuta 'make dev' para iniciar desarrollo"

# Comandos de Git y versionado
tag: ## 🏷️  Crear nuevo tag (uso: make tag VERSION=v0.9.1-beta)
ifndef VERSION
	@echo "❌ Especifica VERSION. Ejemplo: make tag VERSION=v0.9.1-beta"
	@exit 1
endif
	@echo "🏷️  Creando tag $(VERSION)..."
	git tag -a $(VERSION) -m "Release $(VERSION)"
	git push origin $(VERSION)
	@echo "✅ Tag $(VERSION) creado y subido"

release: test build-prod ## 🚀 Preparar release
	@echo "🚀 Preparando release..."
	@echo "✅ Tests pasaron, build de producción completado"
	@echo "💡 Ejecuta 'make tag VERSION=vX.X.X' para crear el tag"

# Meta comandos
all: clean install build test ## 🎯 Ejecutar pipeline completo
