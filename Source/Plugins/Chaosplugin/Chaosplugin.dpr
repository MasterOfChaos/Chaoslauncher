library Chaosplugin;

uses
  SysUtils,
  Classes,
  Windows,
  dialogs,
  logger,
  Main in '..\Common\Main.pas',
  PluginAPI in '..\Common\PluginAPI.pas',
  Offsets in '..\Common\Offsets.pas',
  Autoreplay in 'Autoreplay.pas',
  Friendfollow in 'Friendfollow.pas',
  Config in 'Config.pas' {ConfigForm},
  Chatsave in 'Chatsave.pas',
  Hotkeys in 'Hotkeys.pas',
  RepAnalyser in 'RepAnalyser.pas',
  MouseSettings in 'MouseSettings.pas',
  JoinAlert in 'JoinAlert.pas',
  DownloadStatus in 'DownloadStatus.pas',
  Replayslot in 'Replayslot.pas';

{$E bwl}

{$R *.res}
{$R ChaospluginSound.res}

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
  PluginInfo.Name      := 'Chaosplugin for '+PluginInfo.StarcraftVersion;
  PluginInfo.Description:='Chaos-Plugin for '+PluginInfo.StarcraftVersion+' Version '+PluginInfo.GetVersionString+#13#10#13#10+
                'Simple but usefull features for starcraft'#13#10+
                'Autoreplay, Friendfollow, Chatsave, disable Win-Keys/Capslock, ReplaySlotmaker'#13#10#13#10+
                'by MasterOfChaos';
  PluginInfo.BwlUpdateUrl := 'http://winner.cspsx.de/Starcraft/Tool/Update/';
  {PluginInfo.PublicKey       := '731B:'+
                     '21D979248837F05AB338E3FE985A4B34B7693F6A8BCDF55C4C66F4BA'+
                     'B6B1AA1785BD9E0107AE00F8991E36B232D83C420A48E439BD19F7FD'+
                     'F682F3973E988A6F6890C21EEB669A42FD20EB03C747534327072296'+
                     '6F700561680042AA877D51F8C3EB920A9005BB9103A2B42E71A8C611'+
                     '971F3B0B89798BDD4308AD83FEFA539E';    }
  PluginInfo.Config:=ShowConfigDialog;
  Log('Init complete');
end.
