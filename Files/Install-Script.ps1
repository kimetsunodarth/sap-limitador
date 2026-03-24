<#
DESENVOLVIDO POR: João Melo
DATA: 13/05/2025
VERSÃO: 2.0
#>

$installDir = $PSScriptRoot
$serviceName = "SAPLimitador"

# 1. Criar pasta de instalação
if (-not (Test-Path $installDir)) {
    New-Item -Path $installDir -ItemType Directory -Force | Out-Null
}

# 2. Adicionar arquivo de créditos e descrição
@"
SAP Limitador de Instâncias
---------------------------
Descrição: Este serviço (SAPLimitador) monitora as sessões do
Terminal Server / RemoteApp e impede que os usuários excedam o
limite estipulado de instâncias abertas do SAP Business One.
Ao detectar infração, ele encerra todos os processos SAP do usuário
na respectiva sessão, limpa o seu cache e faz o logoff do RDP.

DESENVOLVIDO POR: João Melo e Rodolfo Combinato
DATA: 13/05/2025
VERSÃO: 2.0
"@ | Out-File "$installDir\CREDITOS.txt"

# 3. Cópia segura de arquivos
$filesToCopy = @(
    "Limitador-SAP.ps1",
    "nssm.exe",
    "Uninstall-Script.ps1"  # Novo script de desinstalação
)

foreach ($file in $filesToCopy) {
    $source = Join-Path -Path $PSScriptRoot -ChildPath $file
    $destination = Join-Path -Path $installDir -ChildPath $file
    
    if ((Test-Path $source) -and (-not (Test-Path $destination))) {
        Copy-Item -Path $source -Destination $destination -Force
    }
}

# 4. Comando de instalação do serviço (mantido igual)
$nssmPath = "$installDir\nssm.exe"
$psScriptPath = "$installDir\Limitador-SAP.ps1"
$installCmd = "`"$nssmPath`" install $serviceName `"powershell.exe`" `"-ExecutionPolicy Bypass -File \`"$psScriptPath\`"`""

# 5. Execução
try {
    cmd /c $installCmd
    cmd /c "`"$nssmPath`" set $serviceName Start SERVICE_AUTO_START"
    cmd /c "`"$nssmPath`" set $serviceName AppStdout `"$installDir\Service.log`""
    
    Start-Service $serviceName
    Write-Host "✅ Serviço 'SAPLimitador' instalado com sucesso!"
    Write-Host "   Desenvolvido por João Melo - 13/05/2025"
} catch {
    Write-Host "❌ Erro na instalação: $($_.Exception.Message)"
}