library LatencyChanger;

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
  PluginInfo.Name      := 'LatencyChanger for '+PluginInfo.StarcraftVersion;
  PluginInfo.BwlUpdateUrl := 'http://winner.cspsx.de/Starcraft/Tool/LatencyUpdate/';
  PluginInfo.Description:='LatencyChanger for '+PluginInfo.StarcraftVersion+' Version '+PluginInfo.GetVersionString+#13#10#13#10+
          'Changes the latency on BNet-games which end on #LL or #L1 ... #L5'#13#10+
          '#LL sets latency to 2 (like on Lan)'#13#10+
          '#L1 ... #L5 sets latency to the supplied number'#13#10+
          'For LAN-games use the settings. On LAN the settings have to be the same or all players'#13#10+
          'Only works if ALL players in the game have LatencyChanger, else you will get disconnects'#13#10#13#10+
          'by MasterOfChaos';
  PluginInfo.Config:=ShowConfigDialog;

  Log('Init complete');
end.
