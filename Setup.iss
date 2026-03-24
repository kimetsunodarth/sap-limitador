[Setup]
AppName=Limitador de Instâncias SAP
AppVersion=1.1.0
AppPublisher=Desenvolvido por João Melo e editado por Rodolfo Combinato
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={commonpf64}\SAP-Limitador
OutputDir=.\Output
OutputBaseFilename=SAP-Limitador-Setup. 1.1.0
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
WizardStyle=modern

[Files]
Source: ".\Files\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Run]
Filename: "powershell.exe"; \
Parameters: "-ExecutionPolicy Bypass -File ""{app}\Install-Script.ps1"""; \
Flags: runascurrentuser waituntilterminated;

[UninstallRun]
Filename: "powershell.exe"; \
Parameters: "-ExecutionPolicy Bypass -File ""{app}\Uninstall-Script.ps1"""; \
Flags: runascurrentuser waituntilterminated;

[Code]
var
  CustomCreditLabel: TLabel;

procedure InitializeWizard;
begin
  CustomCreditLabel := TLabel.Create(WizardForm);
  CustomCreditLabel.Parent := WizardForm;
  CustomCreditLabel.Caption := 'Desenvolvido por Joao Melo e editado por Rodolfo Combinato';
  CustomCreditLabel.Font.Color := clRed;
  CustomCreditLabel.Left := 15;
  CustomCreditLabel.Top := WizardForm.ClientHeight - 31;
  CustomCreditLabel.AutoSize := True;
end;