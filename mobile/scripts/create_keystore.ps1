# Script para criar o keystore de produção para o aplicativo EasyReading
# Este script deve ser executado apenas uma vez para criar o keystore

# Certifique-se de que o diretório keystore existe
$keystoreDir = ".\android\app\keystore"
if (!(Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Path $keystoreDir -Force
    Write-Host "Diretório keystore criado: $keystoreDir" -ForegroundColor Green
}

# Informações do keystore
$keystorePath = "$keystoreDir\easyreading-release.keystore"
$storePassword = Read-Host "Digite a senha para o keystore" -AsSecureString
$plainStorePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))

$keyAlias = "easyreading-key"
$keyPassword = Read-Host "Digite a senha para a chave (deixe em branco para usar a mesma senha do keystore)" -AsSecureString
$plainKeyPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))

# Se a senha da chave estiver em branco, use a senha do keystore
if ($plainKeyPassword -eq "") {
    $plainKeyPassword = $plainStorePassword
}

# Informações para o certificado
$dName = "CN=EasyReading, OU=Mobile, O=EasyReading, L=Sao Paulo, ST=SP, C=BR"
$validity = 10000 # Validade em dias

# Comando para criar o keystore
$keytoolCmd = "keytool -genkey -v -keystore `"$keystorePath`" -alias $keyAlias -keyalg RSA -keysize 2048 -validity $validity -storepass $plainStorePassword -keypass $plainKeyPassword -dname `"$dName`""

try {
    Write-Host "Criando keystore de produção..." -ForegroundColor Yellow
    Invoke-Expression $keytoolCmd
    
    if (Test-Path $keystorePath) {
        Write-Host "Keystore criado com sucesso em: $keystorePath" -ForegroundColor Green
        
        # Armazena os valores em um arquivo de ambiente local (que deve ser ignorado pelo git)
        $envFile = ".env.local"
        "KEYSTORE_PATH=$keystorePath
KEY_ALIAS=$keyAlias
# As senhas devem ser configuradas como variáveis de ambiente seguras
# KEYSTORE_PASSWORD=
# KEY_PASSWORD=" | Out-File -FilePath $envFile -Encoding utf8
        
        Write-Host "Arquivo .env.local criado. Configure as senhas como variáveis de ambiente seguras." -ForegroundColor Cyan
        Write-Host "IMPORTANTE: NÃO cometa este arquivo ou o keystore para o controle de versão!" -ForegroundColor Red
        
        # Informações para configurar o CI/CD
        Write-Host "`nPara configurar o CI/CD, adicione as seguintes variáveis de ambiente secretas:`n" -ForegroundColor Magenta
        Write-Host "KEYSTORE_PATH: $keystorePath" -ForegroundColor White
        Write-Host "KEY_ALIAS: $keyAlias" -ForegroundColor White
        Write-Host "KEYSTORE_PASSWORD: [sua_senha]" -ForegroundColor White
        Write-Host "KEY_PASSWORD: [sua_senha]" -ForegroundColor White
    } else {
        Write-Host "Erro ao criar o keystore. Verifique as mensagens acima." -ForegroundColor Red
    }
} catch {
    Write-Host "Erro ao criar o keystore: $_" -ForegroundColor Red
}
