library HAutoSaveGame;

uses
  windows,
  SysUtils,
  Classes,
  asmhelper,
  util,
  logger,
  offsets,
  pluginapi,
  strings,
  Injector in 'Injector.pas',
  ScHelper in 'ScHelper.pas';

{$E bwl}

{$R *.res}


Type TTimerThread=class(TThread)
  protected
    procedure Execute;override;
end;

var AutosavePatch:TCallPatch;

{ TTimerThread }

procedure TTimerThread.Execute;
var enable:boolean;
begin
  while not terminated do
    try
      enable:=PCardinal(Addresses.Ingame)^<>0;
      if enable and not ActionPatch.enabled then Log('Activating Autosave');
      if not enable and ActionPatch.enabled then Log('Deactivating Autosave');
      AutoSavePatch.enabled:=enable;
      sleep(50);
    except
      on e:exception do
       begin
         SimpleMessageBox(smtError,e.message);
         Log('Exception in TimerThread '+e.Message);
       end;
    end;
end;

procedure ApplyPatch;
begin
  Log('ApplyPatch');
  Inject(Game.ProcessHandle);
end;

procedure OnInjected;
begin
  Log('Injected');
  try
    AutoSaveFunc:=THookFunction.create(LLAutoSaveHandler,0);
    AutoSavePatch:=TCallPatch.create(nil,$4C49C9,AutoSaveFunc);
    TTimerThread.create(false);
  except
      on e:exception do
       begin
         SimpleMessageBox(smtError,e.message);
         Log('Exception in Startup '+e.Message);
       end;
  end;
end;

begin
  PluginInfo.StarcraftBuild  := 10;
  PluginInfo.Major    := 0;
  PluginInfo.Minor    := 1;
  PluginInfo.Sub      := '';
  PluginInfo.StarcraftVersion:='1.15.2';
  PluginInfo.Name      := 'AutoSaver for '+PluginInfo.StarcraftVersion;
  PluginInfo.Description:='AutoSaver for '+PluginInfo.StarcraftVersion+' Version '+PluginInfo.GetVersionString+#13#10#13#10+
                'Autosave on playerdrop'#13#10#13#10+
                'by MasterOfChaos';
  PluginInfo.BwlUpdateUrl := 'http://winner.cspsx.de/Starcraft/Tool/AutosaveUpdate/';
  PluginInfo.ApplyPatch:=ApplyPatch;
  Log('Init complete');
  if pos('starcraft',lowercase(extractfilename(paramstr(0))))>0
    then OnInjected;
end.
