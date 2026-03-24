<#
DESENVOLVIDO POR: João Melo
DATA: 13/05/2025
VERSÃO: 2.0
#>

$installDir = "${env:ProgramFiles}\SAP-Limitador"
$serviceName = "SAPLimitador"

try {
    # 1. Parar e remover serviço
    if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
        Stop-Service $serviceName -Force
        & "$installDir\nssm.exe" remove $serviceName confirm
    }

    # 2. Remover arquivos (exceto logs para possível análise)
    $itemsToKeep = @("Service.log", "Service-Errors.log")
    Get-ChildItem -Path $installDir | Where-Object { $_.Name -notin $itemsToKeep } | Remove-Item -Force -Recurse

    Write-Host "✅ Desinstalação concluída com sucesso!"
    Write-Host "   Desenvolvido por João Melo - 13/05/2025"
} catch {
    Write-Host "❌ Erro na desinstalação: $($_.Exception.Message)"
}

# Manter a pasta se houver logs para análise
if ((Get-ChildItem -Path $installDir -File).Count -eq 0) {
    Remove-Item -Path $installDir -Force
}