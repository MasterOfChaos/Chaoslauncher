library PSL;

uses
  SysUtils,
  Classes,
  Windows,
  dialogs,
  logger,
  Main in '..\Common\Main.pas',
  PluginAPI in '..\Common\PluginAPI.pas',
  Offsets in '..\Common\Offsets.pas',
  LatencyPSL in 'LatencyPSL.pas',
  ReplayUpload in 'ReplayUpload.pas';

{$E bwl}

{$R *.res}

{procedure ShowConfigDialog;
begin
   try
     ConfigForm:=TConfigForm.create(nil);
     Configform.ShowModal;
   finally
     Configform.Free;
   end;
end;}

begin
  PluginInfo.StarcraftBuild  := 10;
  PluginInfo.Major    := 0;
  PluginInfo.Minor    := 1;
  PluginInfo.Sub      := '';
  PluginInfo.StarcraftVersion:='1.15.2';
  PluginInfo.Name      := 'PSL-Ladder Plugin';
  PluginInfo.Description:='PSL for '+PluginInfo.StarcraftVersion+' Version '+PluginInfo.GetVersionString+#13#10#13#10+
                'Plugin for the PSL-Ladder'#13#10+
                'Offers Replayupload and low latency'+
                'Changes the latency on ALL bnetgames whose gamename does not contain an exclamationmark(!) somwhere';
  PluginInfo.BwlUpdateUrl := '<FillYourUpdateUrlHere>';
  //PluginInfo.Config:=ShowConfigDialog;
  Log('Init complete');
end.
