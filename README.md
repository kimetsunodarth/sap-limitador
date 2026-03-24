# SAP Limitador

Um serviço de segundo plano desenvolvido em PowerShell para monitorar e limitar o número de instâncias do SAP Business One e AddOns por usuário em servidores Windows ou instâncias RDS. 

## Funcionalidades
- Monitoramento contínuo das instâncias do processo `SAP Business One` via WMI.
- Limite de abertura flexível (Padrão: **1 instância**).
- Ao detectar violação do limite (ex: abertura acidental de segundo SAP), o script atua de forma rigorosa para limpar a sessão que pode estar travando:
  1. Encerra agressivamente todos os processos correlatos (`SAP Business One.exe`, `b1s.exe`, `AddOn*`, `SBO*`) abertos **exclusivamente** pelo usuário infrator.
  2. Resolve o perfil do usuário e esvazia sua pasta pessoal de cache e logs do SAP (`%LocalAppData%\SAP`).
  3. Realiza o `logoff` forçado da sessão local/remota do Windows do usuário para liberar os recursos do servidor inequivocadamente.

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
