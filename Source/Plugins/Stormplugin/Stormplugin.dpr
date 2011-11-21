library Stormplugin;

uses
  SysUtils,
  Classes,
  Windows,
  dialogs,
  logger,
  Main in '..\Common\Main.pas',
  PluginAPI in '..\Common\PluginAPI.pas',
  Offsets in '..\Common\Offsets.pas',
  HideReplayProgress in 'HideReplayProgress.pas',
  Config in 'Config.pas' {ConfigForm},
  LagDetector in 'LagDetector.pas',
  SettingsHelper in '..\Common\SettingsHelper.pas',
  UnshiftHotkeys in 'UnshiftHotkeys.pas',
  SelectionCircles in 'SelectionCircles.pas',
  HidePW in 'HidePW.pas';

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
  PluginInfo.StarcraftBuild  := 13;
  PluginInfo.StarcraftVersion:='1.16.1';
  PluginInfo.Name      := 'Stormplugin for '+PluginInfo.StarcraftVersion;
  PluginInfo.Description:='Stormplugin for '+PluginInfo.StarcraftVersion+' Version '+PluginInfo.GetVersionString+#13#10#13#10+
                'Additional Features for Starcraft which require codepatching'#13#10+
                'Hide replayprogress, unshift hotkeys,...'#13#10#13#10+
                'by MasterOfChaos';
  PluginInfo.BwlUpdateUrl := 'http://winner.cspsx.de/Starcraft/Tool/StormUpdate/';
  PluginInfo.Config:=ShowConfigDialog;
  PluginInfo.SelfInject:=true;
  Log('Init complete');
end.
