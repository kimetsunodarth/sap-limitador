$logDir = "C:\Program Files\SAP-Limitador\Logs"
if (-not (Test-Path $logDir)) { New-Item -Path $logDir -ItemType Directory -Force }

Start-Transcript -Path "$logDir\Execucao-$(Get-Date -Format 'yyyyMMdd-HHmmss').log" -Append

while ($true) {
    $maxInstances = 1
    
    # Obtém processos do SAP via Get-Process (Nativalmente muito superior ao WMI em VMs e Server TS 2019)
    # Procurando explicitamente pela imagem mestre do SAP Business One
    $allProcesses = Get-Process -IncludeUserName -ErrorAction SilentlyContinue | Where-Object {
        $_.ProcessName -match "SAP Business One|SAPBusinessOne"
    }
    
    if ($allProcesses) {
        # Filtra processos logados em sessão RDP/Terminal
        $processesByUser = $allProcesses | Where-Object { -not [string]::IsNullOrWhiteSpace($_.UserName) } | Group-Object -Property UserName
        
        # Ação para cada usuário infrator
        foreach ($userGroup in $processesByUser) {
            $user = $userGroup.Name
            $processes = $userGroup.Group
        
            if ($processes.Count -gt $maxInstances) {
                # Mapeia as Sessões onde o usuário excedente está logado
                $uniqueSessions = $processes.SessionId | Select-Object -Unique

                foreach ($sess in $uniqueSessions) {
                    Write-Host "--------------------------------------------------------"
                    Write-Host "DATA: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
                    Write-Host "INFRACAO DETECTADA: O usuario $user tentou abrir $($processes.Count) instancias do SAP"
                    Write-Host "Acao executada na sessao RDP -> $sess"

                    # Mensagem amigável de interrupção forçada
                    $message = "AVISO: Voce possui mais de $maxInstances instancia(s) SAP. Fechando tudo e efetuando logoff..."
                    & msg $sess /server:localhost /time:6 $message
                    Start-Sleep -Seconds 2
            
                    # 1. Matar TODOS os processos SAP nativamente por Sessão
                    Write-Host "Matando processos (SAP, B1s, AddOn) na sessao $sess..."
                    $procsInSession = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $sess -and $_.ProcessName -match "SAP|b1s|AddOn|SBO" }
                    foreach ($p in $procsInSession) {
                        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
                        Write-Host " -> $($p.ProcessName) encerrado (PID: $($p.Id))"
                    }

                    # 3. Logoff OBRIGATÓRIO da Sessão RDP
                    Write-Host "Forcando logoff RDP Terminal Server 2019 na sessao $sess..."
                    & logoff $sess
                }
        
                # 2. Limpar Cache local (perfil limpo)
                if ($user -match "\\") {
                    $domain = $user.Split("\")[0]
                    $username = $user.Split("\")[1]
                    Write-Host "Limpando LocalAppData\SAP para o perfil de: $username..."
                    try {
                        $objUser = New-Object System.Security.Principal.NTAccount($domain, $username)
                        $sid = $objUser.Translate([System.Security.Principal.SecurityIdentifier]).Value
                        $profilePath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" -ErrorAction Stop).ProfileImagePath
                        $sapFolder = "$profilePath\AppData\Local\SAP"
                        if (Test-Path $sapFolder) {
                            Remove-Item -Path "$sapFolder\*" -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Host "O cache do SAP foi excluido/esvaziado com sucesso!"
                        }
                    } catch {
                        Write-Host "Erro inesperado ao limpar o cache: $($_.Exception.Message)"
                    }
                }
            }
        }
    }
    
    # Mantém o script em execução (A cada 3 segundos economiza muita CPU em hosts RemoteApp Terminal Server)
    Start-Sleep -Seconds 3
}

Stop-Transcript


