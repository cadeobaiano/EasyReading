# Verifica se está rodando como administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Por favor, execute como administrador!"
    exit
}

# Locais possíveis do Node.js
$nodePaths = @(
    "C:\Program Files\nodejs",
    "C:\Program Files (x86)\nodejs"
)

# Encontra o diretório do Node.js
$nodeDir = $null
foreach ($path in $nodePaths) {
    if (Test-Path $path) {
        $nodeDir = $path
        break
    }
}

if ($null -eq $nodeDir) {
    Write-Error "Node.js não encontrado! Verifique se está instalado."
    exit 1
}

# Obtém o PATH atual
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

# Verifica se o Node.js já está no PATH
if ($currentPath -like "*$nodeDir*") {
    Write-Host "Node.js já está no PATH do sistema."
} else {
    # Adiciona Node.js ao PATH
    $newPath = "$currentPath;$nodeDir"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Host "Node.js foi adicionado ao PATH do sistema."
}

# Verifica a instalação
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine")
Write-Host "Verificando a instalação..."
Write-Host "Node.js versão:"
& "$nodeDir\node.exe" --version
Write-Host "NPM versão:"
& "$nodeDir\npm.cmd" --version

Write-Host "`nPronto! Por favor, reinicie seu terminal ou VS Code para que as alterações tenham efeito."
