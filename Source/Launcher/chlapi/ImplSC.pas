unit ImplSC;

interface
uses Callbacks,Sync;

var ActionCallback:TCallbackList;
    TimerCallback:TCallbackList;
    IngameCallback:TCallbackList;
    Ingame2Callback:TCallbackList;

function IsInjected:boolean;

implementation
uses logger,windows,sysutils,classes,offsets;
var FIsInjected:boolean;

function IsInjected:boolean;
begin
  result:=FIsInjected;
end;

procedure Timer;
begin
  TimerCallback.Call(nil^,nil^);
end;

type TTimerThread=class(TThread)
  protected
    procedure Execute; override;
  public
end;

var OldIngame:boolean;

procedure TestIngame;
var IngameInfo:packed record
    Ingame:ByteBool;
  end;
var NewIngame:boolean;
begin
  NewIngame:=PCardinal(Addresses.Ingame)^<>0;
  if OldIngame=NewIngame then exit;
  OldIngame:=NewIngame;
  Log('Ingame '+inttostr(integer(NewIngame)));
  IngameInfo.Ingame:=NewIngame;
  IngameCallback.Call(IngameInfo,nil^);
end;

procedure TestIngame2;
var IngameInfo:packed record
    Ingame:ByteBool;
  end;
var NewIngame:boolean;
begin
  NewIngame:=PCardinal(Addresses.Ingame2)^<>0;
  if OldIngame=NewIngame then exit;
  OldIngame:=NewIngame;
  Log('Ingame2 '+inttostr(integer(NewIngame)));
  IngameInfo.Ingame:=NewIngame;
  Ingame2Callback.Call(IngameInfo,nil^);
end;

{ TTimerThread }

procedure TTimerThread.Execute;
begin
  inherited;
  while not Terminated do
    begin
      sleep(100);
      try
        AquireHelperMutex;
        TestIngame;
        TestIngame2;
        Timer;
      finally
        ReleaseHelperMutex;
      end;
    end;
end;

var TimerThread:TTimerThread;

procedure InitInjected;
begin
  ActionCallback:=TCallbackList.create('Action');
  TimerCallback:=TCallbackList.create('Timer');
  IngameCallback:=TCallbackList.create('Ingame');
  Ingame2Callback:=TCallbackList.create('Ingame2');
  TimerThread:=TimerThread.create(true);
  TimerThread.FreeOnTerminate:=false;
  TimerThread.Resume;
end;

procedure FinishInjected;
begin
  Ingame2Callback.free;
  IngameCallback.free;
  ActionCallback.free;
  TimerCallback.free;
end;

initialization
  FIsInjected:=pos('starcraft',extractfilename(paramstr(0)))>0;
  if IsInjected then InitInjected;
finalization
  TimerThread.free;
  if IsInjected then FinishInjected;
end.
