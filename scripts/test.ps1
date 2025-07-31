# 🧪 Script de Testing Local para Jekyll Site (PowerShell)
# Uso: .\scripts\test.ps1

param(
    [switch]$Verbose
)

# Configuración de colores
$Host.UI.RawUI.ForegroundColor = "White"

function Write-Info {
    param($Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

function Write-Success {
    param($Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Header {
    param($Message)
    Write-Host "`n🔷 $Message" -ForegroundColor Cyan
    Write-Host ("=" * 50) -ForegroundColor Cyan
}

# Inicializar contadores
$TotalTests = 6
$PassedTests = 0

Write-Header "Iniciando tests locales del sitio Jekyll"

try {
    # Test 1: Jekyll Build
    Write-Header "Test 1: Jekyll Build"
    
    Write-Info "Construyendo sitio con Jekyll (development)..."
    $buildResult = bundle exec jekyll build --config _config.yml
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Build development exitoso"
        $PassedTests++
    } else {
        Write-Error "Build development falló"
        throw "Jekyll build failed"
    }
    
    Write-Info "Construyendo sitio con Jekyll (production)..."
    $env:JEKYLL_ENV = "production"
    $buildProdResult = bundle exec jekyll build --config _config.yml
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Build production exitoso"
    } else {
        Write-Error "Build production falló"
        throw "Jekyll production build failed"
    }

    # Test 2: Validación YAML
    Write-Header "Test 2: Validación YAML"
    
    $yamlFiles = @("_config.yml", "_i18n/es.yml", "_i18n/en.yml")
    $yamlValid = $true
    
    foreach ($file in $yamlFiles) {
        if (Test-Path $file) {
            Write-Info "Validando $file..."
            try {
                # Usar Ruby para validar YAML
                $validation = ruby -e "require 'yaml'; YAML.load_file('$file'); puts 'valid'"
                if ($validation -eq "valid") {
                    Write-Success "$file es válido"
                } else {
                    Write-Error "$file tiene errores de sintaxis"
                    $yamlValid = $false
                }
            } catch {
                Write-Error "Error validando $file"
                $yamlValid = $false
            }
        } else {
            Write-Error "Archivo no encontrado: $file"
            $yamlValid = $false
        }
    }
    
    if ($yamlValid) {
        $PassedTests++
        Write-Success "Validación YAML completada"
    }

    # Test 3: Verificar traducciones
    Write-Header "Test 3: Verificación de Traducciones"
    
    $missingTranslations = 0
    $esPostsPath = "_posts/es"
    $enPostsPath = "_posts/en"
    
    if (Test-Path $esPostsPath) {
        $esPosts = Get-ChildItem -Path $esPostsPath -Filter "*.md"
        foreach ($post in $esPosts) {
            $correspondingEnPost = Join-Path $enPostsPath $post.Name
            if (Test-Path $correspondingEnPost) {
                Write-Success "Traducción encontrada: $($post.Name)"
            } else {
                Write-Error "Falta traducción: $correspondingEnPost"
                $missingTranslations++
            }
        }
    }
    
    if ($missingTranslations -eq 0) {
        $PassedTests++
        Write-Success "Todas las traducciones están completas"
    } else {
        Write-Error "Faltan $missingTranslations traducciones"
    }

    # Test 4: Verificar archivos requeridos
    Write-Header "Test 4: Archivos Requeridos"
    
    $requiredFiles = @(
        "_config.yml",
        "index.html",
        "en/index.html",
        "_layouts/default.html",
        "_layouts/post.html",
        "assets/css/style.css",
        "assets/js/main.js",
        "robots.txt",
        ".htaccess",
        "_i18n/es.yml",
        "_i18n/en.yml"
    )
    
    $missingFiles = 0
    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Success $file
        } else {
            Write-Error "Falta: $file"
            $missingFiles++
        }
    }
    
    if ($missingFiles -eq 0) {
        $PassedTests++
        Write-Success "Todos los archivos requeridos están presentes"
    }

    # Test 5: Verificar estructura del sitio
    Write-Header "Test 5: Estructura del Sitio"
    
    if (Test-Path "_site") {
        Write-Info "Verificando páginas generadas..."
        
        $generatedPages = @(
            "_site/index.html",
            "_site/en/index.html",
            "_site/blog.html",
            "_site/en/blog.html",
            "_site/cv.html",
            "_site/en/resume.html",
            "_site/robots.txt",
            "_site/.htaccess"
        )
        
        $generatedPagesCount = 0
        foreach ($page in $generatedPages) {
            if (Test-Path $page) {
                Write-Success "Generado: $(Split-Path $page -Leaf)"
                $generatedPagesCount++
            } else {
                Write-Warning "No generado: $page"
            }
        }
        
        # Contar posts generados
        $postFiles = Get-ChildItem -Path "_site" -Recurse -Filter "*.html" | Where-Object { $_.FullName -match "20\d{2}" }
        Write-Info "Posts encontrados: $($postFiles.Count)"
        
        if ($generatedPagesCount -ge 6) {
            $PassedTests++
            Write-Success "Estructura del sitio verificada"
        }
    } else {
        Write-Error "Directorio _site no encontrado. Ejecuta Jekyll build primero."
    }

    # Test 6: Verificar enlaces básicos
    Write-Header "Test 6: Enlaces Básicos"
    
    if (Test-Path "_site/index.html") {
        $indexContent = Get-Content "_site/index.html" -Raw
        
        $linksFound = 0
        if ($indexContent -match 'href.*blog') {
            Write-Success "Enlace a blog encontrado"
            $linksFound++
        } else {
            Write-Warning "No se encontró enlace a blog"
        }
        
        if ($indexContent -match 'href.*(cv|resume)') {
            Write-Success "Enlace a CV/Resume encontrado"
            $linksFound++
        } else {
            Write-Warning "No se encontró enlace a CV/Resume"
        }
        
        if ($linksFound -ge 1) {
            $PassedTests++
            Write-Success "Enlaces básicos verificados"
        }
    }

} catch {
    Write-Error "Error durante la ejecución de tests: $($_.Exception.Message)"
}

# Resumen final
Write-Header "RESUMEN DE TESTS"

Write-Host "`n📊 Resultados:" -ForegroundColor Cyan
Write-Host "Tests ejecutados: $TotalTests" -ForegroundColor White
Write-Host "Tests exitosos: $PassedTests" -ForegroundColor Green
Write-Host "Tests fallidos: $($TotalTests - $PassedTests)" -ForegroundColor Red

if ($PassedTests -eq $TotalTests) {
    Write-Host "`n🎉 ¡Todos los tests pasaron exitosamente!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️  Algunos tests fallaron. Revisa los errores arriba." -ForegroundColor Yellow
    exit 1
}
