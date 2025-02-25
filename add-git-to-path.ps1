# Adiciona Git ao PATH do sistema
$gitPath = 'C:\Program Files\Git\cmd'
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')

if (-not $currentPath.Contains($gitPath)) {
    try {
        [Environment]::SetEnvironmentVariable('Path', $currentPath + ';' + $gitPath, 'Machine')
        Write-Host "Git foi adicionado ao PATH do sistema com sucesso!"
    }
    catch {
        Write-Host "Erro ao adicionar Git ao PATH. Execute este script como administrador."
        Write-Host "Erro: $_"
    }
}
else {
    Write-Host "Git já está no PATH do sistema."
}

# Verifica se o Git está funcionando
try {
    $gitVersion = git --version
    Write-Host "Git está funcionando corretamente: $gitVersion"
}
catch {
    Write-Host "Não foi possível executar o Git. Tente reiniciar o PowerShell."
}
