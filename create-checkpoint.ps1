# Adiciona Git ao Path
$env:Path += ";C:\Program Files\Git\cmd"
$gitExe = "C:\Program Files\Git\cmd\git.exe"

# Configurações iniciais do Git
& $gitExe config --global user.name "EasyReading Developer"
& $gitExe config --global user.email "dev@easyreading.com"

# Inicializa o repositório Git se ainda não existir
if (-not (Test-Path .git)) {
    & $gitExe init
    Write-Host "Repositório Git inicializado"
}

# Cria arquivo .gitignore
@"
# Arquivos de build
build/
*.apk
*.ipa

# Arquivos de configuração local
.env
.env.local
google-services.json
GoogleService-Info.plist

# Dependências
node_modules/
.pub-cache/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies

# IDEs e editores
.idea/
.vscode/
*.iml
*.iws
.DS_Store

# Logs e backups
*.log
*.bak
"@ | Out-File -FilePath .gitignore -Encoding UTF8

# Adiciona todos os arquivos ao Git
& $gitExe add .

# Cria o commit com timestamp atual
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
& $gitExe commit -m "Checkpoint - Progresso salvo até $timestamp"

# Cria backup local
$backupName = "EasyReading_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
Compress-Archive -Path * -DestinationPath $backupName -Force

# Gera relatório
@"
=== Relatório de Checkpoint ===
Data/Hora: $timestamp

1. Status do Git:
$((& $gitExe status) | Out-String)

2. Arquivos incluídos no commit:
$((& $gitExe diff --name-only HEAD^) | Out-String)

3. Backup local criado:
$backupName

4. Próximos passos:
- Verifique o backup em: $backupName
- Configure um repositório remoto (GitHub, GitLab, etc.)
- Execute 'git push' para sincronizar com o repositório remoto

=== Fim do Relatório ===
"@ | Out-File -FilePath "checkpoint_report.txt" -Encoding UTF8

Write-Host "Checkpoint concluído! Verifique o arquivo 'checkpoint_report.txt' para mais detalhes."
