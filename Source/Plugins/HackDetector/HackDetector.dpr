library HackDetector;

uses
  windows,
  SysUtils,
  Classes,
  asmhelper,
  util,
  logger,
  offsets,
  pluginapi,
  forms,
  Detector in 'Detector.pas',
  ScHelper,
  AntiSpoof in 'AntiSpoof.pas',
  Config in 'Config.pas' {ConfigForm},
  Protector in 'Protector.pas',
  ScInfo in '..\Common\ScInfo.pas';

{$R *.res}

{$E bwl}
var ActionHandlerReplacedOffset:cardinal;

procedure ActionHandler(TimeStamp:Cardinal;Player:byte;ActionID:byte;const Params;ParamSize:integer);
begin
  DetectorActionHandler(TimeStamp,Player,ActionID,Params,ParamSize);
  If (Settings.LogActions)and
     ((ActionID<>Action_NOP)or(Settings.LogNOPs))
     then Log(inttostr(TimeStamp,8)+' '+inttostr(Player,2)+' '+inttostr(ActionID,3)+' '+MemToHex(Params,ParamSize));
end;

procedure LLActionHandler(var CPU:TCPUState);
var Player:byte;
    ActionID:byte;
    Params:String;
    TimeStamp:Cardinal;
    PlayerAddr:Cardinal;
begin
  try
    CPU.EAX.uint:=PCardinal(ActionHandlerReplacedOffset)^;
    setlength(Params,CPU.edi.uint-1);
    ActionID:=CPU.esi.pb^;
    PlayerAddr:=PCardinal(Addresses.ActionHook-7)^-4;
    Player:=PByte(PlayerAddr)^;
    TimeStamp:=GetTime;//Global Timestamp variable
    move(Pointer(CPU.esi.uint+1)^,PChar(Params)^,length(params));
    ActionHandler(TimeStamp,Player,ActionID,PChar(Params)^,length(params));
  except
    on e:exception do
      begin
        SimpleMessageBox(smtError,e.message);
        Log('Exception in ActionHandler '+e.Message);
      end;
  end;
end;

Type TTimerThread=class(TThread)
  protected
    procedure Execute;override;
end;

var ActionFunc:THookFunction;
    ActionPatch:TCallPatch;

{ TTimerThread }

{procedure Timer(const ConstParam;var VarParam;var SkipOtherHandlers:LongBool);stdcall;
begin
  AntiSpoofTimer;
  ProtectorTimer;
end;

procedure Ingame(const ConstParam;var VarParam;var SkipOtherHandlers:LongBool);stdcall;
begin

end;           }

procedure TTimerThread.Execute;
var enable:boolean;
begin
  while not terminated do
    try
      enable:=IsIngame2;
      if enable and not ActionPatch.enabled then Log('Activating HackDetector');
      if not enable and ActionPatch.enabled then Log('Deactivating HackDetector');
      ActionPatch.enabled:=enable;
      sleep(50);
    except
      on e:exception do
       begin
         SimpleMessageBox(smtError,e.message);
         Log('Exception in TimerThread '+e.Message);
       end;
    end;
end;

procedure OnInjected;
begin
  Log('Injected');
  try
    ActionHandlerReplacedOffset:=PCardinal(Addresses.ActionHook+1)^;
    ActionFunc:=THookFunction.create(LLActionHandler,0);
    ActionPatch:=TCallPatch.create(nil,Addresses.ActionHook,ActionFunc);
    TTimerThread.create(false);
  except
      on e:exception do
       begin
         SimpleMessageBox(smtError,e.message);
         Log('Exception in Startup '+e.Message);
       end;
  end;
end;

procedure ShowConfig;
var Form:TConfigForm;
begin
  Form:=nil;
  try
    Form:=TConfigForm.create(nil);
    Form.showmodal;
  finally
    Form.free;
  end;
end;

begin
  PluginInfo.StarcraftBuild  := 11;
  PluginInfo.StarcraftVersion:='1.15.3';
  PluginInfo.Name      := 'HackDetector for '+PluginInfo.StarcraftVersion;
  PluginInfo.Description:='HackDetector for '+PluginInfo.StarcraftVersion+' Version '+PluginInfo.GetVersionString+#13#10#13#10+
                'Detects: Automine, Multicommand, Zerg-Mineralhack and Nuke-anywhere'#13#10#13#10+
                'by MasterOfChaos';
  PluginInfo.BwlUpdateUrl := 'http://winner.cspsx.de/Starcraft/Tool/HackDetectorUpdate/';
  PluginInfo.Config:=ShowConfig;
  PluginInfo.SelfInject:=true;
  Log('Init complete');
  if IsInjected
    then OnInjected;
end.
