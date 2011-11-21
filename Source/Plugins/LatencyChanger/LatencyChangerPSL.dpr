library LatencyChangerPSL;

uses
  SysUtils,
  Classes,
  Windows,
  Main,
  PluginApi,
  logger,
  Latency in 'Latency.pas',
  LatencyConfig in 'LatencyConfig.pas' {ConfigForm};
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
  PluginInfo.Name      := 'PSL-LatencyChanger '+PluginInfo.StarcraftVersion;
  PluginInfo.BwlUpdateUrl := 'http://prosl.net/data/LatencyUpdate/';
  PluginInfo.Description:='PSL-LatencyChanger for '+PluginInfo.StarcraftVersion+' Version '+PluginInfo.GetVersionString+#13#10#13#10+
          'Changes the latency on ALL bnetgames no matter what game name is'#13#10+
          'Only works if ALL players in the game have PSL-LatencyChanger, else you will get disconnects'#13#10#13#10+
          'If you want to play on normal latency use ! in game name. e.g. 1v1!gogo or !2vs2 hunters'#13#10+
          'by MasterOfChaos';
  PluginInfo.Config:=ShowConfigDialog;
  LatencyExclamationMarkSyntax:=true;

  Log('Init complete');
end.
