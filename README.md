# SAP Limitador

Um serviço de segundo plano desenvolvido em PowerShell para monitorar e limitar o número de instâncias do SAP Business One e AddOns por usuário em servidores Windows ou instâncias RDS. 

## Funcionalidades
- Monitoramento contínuo das instâncias do processo `SAP Business One` via WMI.
- Limite de abertura flexível (Padrão: **1 instância**).
- Ao detectar violação do limite (ex: abertura acidental de segundo SAP), o script atua de forma cirurgica e agressiva para limpar a sessão travada:
  1. Encerra na hora todos os processos correlatos (`SAP Business One.exe`, `b1s.exe`, `AddOn*`, `SBO*`) abertos **exclusivamente** na Sessão (Session ID RDP) pelo usuário infrator (Get-Process native call).
  2. Preserva integralmente a pasta pessoal de cache e AppData do usuário (nenhum arquivo é corrompido ou apagado pós-logoff).
  3. Realiza o `logoff` acompanhado da destruição física (Reset WinStation - `rwinsta`) da sessão RDP do Windows para liberar os recursos do servidor e impedir que a sessão fique como "Desconectada".

## Instalação
1. Execute o setup automatizado `.exe` gerado pelo projeto.
2. O instalador copiará os arquivos essenciais para o diretório `C:\Program Files\SAP-Limitador` de sua máquina.
3. O instalador registra o script `.ps1` como um Serviço Nativo de Sistema NT usando a ferramenta Open-Source **NSSM**.
4. O processo fica executando periodicamente validando processos abertos.

## Alteração do Limite
1. Abra `C:\Program Files\SAP-Limitador\Limitador-SAP.ps1` com bloco de notas.
2. Altere a variável `$maxInstances = 1` para o número que desejar e reinicie o serviço `SAPLimitador` via Windows Services (services.msc).

## Compilação
Caso realize alterações personalizadas no código, recompile o arquivo de instalação abrindo `Setup.iss` usando o Inno Setup Compiler (`iscc.exe`).
