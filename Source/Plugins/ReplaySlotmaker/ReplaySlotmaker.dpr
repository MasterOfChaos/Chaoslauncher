library ReplaySlotmaker;

uses
  SysUtils,
  Classes,
  Windows,
  Main in 'Main.pas',
  Logger in 'Logger.pas',
  Offsets in 'Offsets.pas',
  ReplaySlot in 'ReplaySlot.pas';

{$E bwl}

{$R *.res}
begin
  StarcraftBuild  := 10;
  Plugin_Major    := 0;
  Plugin_Minor    := 3;
  Plugin_Sub      := '';
  StarcraftVersion:='1.15.2';
  PluginName      := 'ReplaySlotmaker '+StarcraftVersion;
  PluginUpdateUrl := 'http://winner.cspsx.de/Starcraft/Tool/ReplayslotUpdate/';
  Log('Init complete');
  PluginDescription:=:='ReplaySlotmaker for '+StarcraftVersion+' Version '+inttostr(Plugin_Major)+'.'+inttostr(Plugin_Minor)+Plugin_Sub+#13#10#13#10+
          'Allows up to 8 player to join a replay with less than 8 slots'#13#10+
          'Offsets by qet'#13#10+
          'bwl conversion by MasterOfChaos';  
  Log('Init complete');
end.
