# Script para analisar o tamanho do build e realizar verificações pré-release

Write-Host "Iniciando análise do build e verificações pré-release..." -ForegroundColor Cyan

# Verifica se flutter está instalado
try {
    $flutterVersion = (flutter --version) | Select-Object -First 1
    Write-Host "Flutter: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "Erro: Flutter não encontrado no PATH." -ForegroundColor Red
    exit 1
}

# Limpa builds anteriores
Write-Host "Limpando builds anteriores..." -ForegroundColor Yellow
flutter clean

# Obtém as dependências
Write-Host "Instalando dependências..." -ForegroundColor Yellow
flutter pub get

# Executa análise de código
Write-Host "Analisando código..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "Análise de código falhou. Verifique os erros antes de continuar." -ForegroundColor Red
    exit 1
}

# Executa testes
Write-Host "Executando testes..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Testes falharam. Verifique os erros antes de continuar." -ForegroundColor Red
    exit 1
}

# Constrói e analisa o tamanho do APK
Write-Host "Construindo e analisando o APK..." -ForegroundColor Yellow
flutter build apk --analyze-size
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build do APK falhou. Verifique os erros antes de continuar." -ForegroundColor Red
    exit 1
}

# Constrói e analisa o tamanho do AppBundle
Write-Host "Construindo e analisando o AppBundle..." -ForegroundColor Yellow
flutter build appbundle --analyze-size
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build do AppBundle falhou. Verifique os erros antes de continuar." -ForegroundColor Red
    exit 1
}

# Verifica o tamanho do APK
$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length / 1MB
    Write-Host "Tamanho do APK: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
    
    # Aviso se o APK for muito grande
    if ($apkSize -gt 100) {
        Write-Host "AVISO: O APK está muito grande (>100MB). Considere otimizar o tamanho." -ForegroundColor Yellow
    }
}

# Verifica o tamanho do AppBundle
$aabPath = "build\app\outputs\bundle\release\app-release.aab"
if (Test-Path $aabPath) {
    $aabSize = (Get-Item $aabPath).Length / 1MB
    Write-Host "Tamanho do AppBundle: $([math]::Round($aabSize, 2)) MB" -ForegroundColor Cyan
}

Write-Host "Verificações pré-release completas!" -ForegroundColor Green
