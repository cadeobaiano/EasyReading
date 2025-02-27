# Script para gerar valores base64 para o GitHub Actions
Write-Host "Gerando valores base64 para configuração do GitHub Actions..." -ForegroundColor Cyan

# Keystore
$keystorePath = "android\app\keystore\easyreading-release.keystore"
$keystoreBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystorePath))
Write-Host "`n=== KEYSTORE_BASE64 (Copie todo o valor abaixo) ===" -ForegroundColor Green
Write-Host "----------------------------------------"
Write-Host $keystoreBase64
Write-Host "----------------------------------------`n"

# Firebase Config
$firebaseConfigPath = "android\app\google-services.json"
$firebaseConfigBase64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($firebaseConfigPath))
Write-Host "`n=== FIREBASE_CONFIG (Copie todo o valor abaixo) ===" -ForegroundColor Green
Write-Host "----------------------------------------"
Write-Host $firebaseConfigBase64
Write-Host "----------------------------------------`n"

Write-Host "`nInstruções:" -ForegroundColor Yellow
Write-Host "1. Copie o valor entre as linhas de traços para cada secret" -ForegroundColor White
Write-Host "2. Adicione no GitHub como secrets separados" -ForegroundColor White
