library Chaoscoach;

uses
  SysUtils,
  Classes,
  Windows,
  dialogs,
  Main,
  Logger,
  PluginAPI,
  offsets,
  Coach in 'Coach.pas',
  CoachConfig in 'CoachConfig.pas' {ConfigForm},
  AntiICC in 'AntiICC.pas';

{$E bwl}

{$R *.res}

procedure ShowConfigDialog;
begin
   try
     ConfigForm:=TConfigForm.create(nil);
     Configform.ShowModal;
   finally
     Configform.Free;
   end;
end;

begin
  PluginInfo.StarcraftBuild  :=13;
  PluginInfo.StarcraftVersion:='1.16.1';
  PluginInfo.Name            :='Chaoscoach for '+PluginInfo.StarcraftVersion;
  PluginInfo.BwlUpdateUrl    :='http://winner.cspsx.de/Starcraft/Tool/CoachUpdate';
  PluginInfo.Description     :='Chaoscoach for '+PluginInfo.StarcraftVersion+' Version '+PluginInfo.GetVersionString+#13#10#13#10+
                               'by MasterOfChaos';
  //PluginInfo.Config:=ShowConfigDialog;
  AntiIccEnabled:=true;
  Log('Init complete');
end.
