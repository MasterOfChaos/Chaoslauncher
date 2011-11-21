unit Main;

interface
uses classes,windows,messages,sysutils,registry,inifiles,logger,pluginapi,scinfo,injector;

Type TMyThread=class(TThread)
  procedure Init;
  procedure Finish;
  procedure Timer;
  procedure Execute; override;
end;

type TPluginMode=(pmUnknown,pmLauncher,pmInjected);
     TValidPluginMode=pmLauncher..pmInjected;
     TValidPluginModeSet=set of TValidPluginMode;
//Type TTimerProc=procedure(var Delay:Word);
var thread:TMyThread;
    path:String;
    ScActive:boolean;
    Mode:TPluginMode;

procedure AddInitHandler(Proc:TProcedure;Modes:TValidPluginModeSet);
procedure AddTimerHandler(Proc:TProcedure;Modes:TValidPluginModeSet);
procedure AddFinishHandler(Proc:TProcedure;Modes:TValidPluginModeSet);
function CheckKey(Key:integer):boolean;
procedure MainInit;

implementation
{ TMyThread }
var keys:array of record key:integer;pressed:boolean;end;
type THandler=record
  Proc:TProcedure;
  Modes:TValidPluginModeSet;
end;
var InitHandlers:array of THandler;
    FinishHandlers:array of THandler;
    TimerHandlers:array of THandler;{of record
      proc:TTimerProc;
      Delay:Word;
      LastCall:Cardinal;
     end;           }
//var LastRun:cardinal;
procedure TMyThread.Init;
var reg:TRegistry;
    i:integer;
    ini:TInifile;
    temppath:String;
begin
 Log('Thread start init');
 reg:=nil;
 try
  reg:=TRegistry.create;
  reg.RootKey:=HKEY_LOCAL_MACHINE;
  reg.OpenKeyReadOnly('SOFTWARE\Blizzard Entertainment\Starcraft');
  path:=reg.ReadString('InstallPath')
 finally
  reg.free;
 end;
 ini:=nil;
 if fileexists(extractfilepath(paramstr(0))+'iccup.ini')
  then
   try
    ini:=TInifile.create(extractfilepath(paramstr(0))+'iccup.ini');
    temppath:=extractfilepath(ini.ReadString('StarCraft: Brood War','MainExe',''));
    if (Temppath<>'')and(temppath[length(Temppath)]='\') then delete(temppath,length(temppath),1);
    if temppath<>'' then Path:=temppath;
   finally
    ini.free;
   end;
 if path='' then Log('Starcraft not properly installed. Registrykeys missing');
 ScActive:=false;
 OpenScInfo(Game.ProcessHandle);
 Log('Running Inithandlers');
 for i := 0 to length(InitHandlers) - 1 do
  try
    if Mode in InitHandlers[i].Modes
      then InitHandlers[i].Proc();
  except
    on e:exception do
      Log('Exception in Inithandler+'+inttostr(i)+' '+e.Message);
  end;
 Log('Thread init complete');
end;

procedure TMyThread.Finish;
var i:integer;
begin
 ScActive:=false;
 Log('Running FinishHandlers');
 for i := 0 to length(FinishHandlers) - 1 do
  try
    if Mode in FinishHandlers[i].Modes
      then FinishHandlers[i].Proc();
  except
    on e:exception do
      Log('Exception in Finishhandler+'+inttostr(i)+' '+e.Message);
  end;
  CloseScInfo;
  Log('Finishhandlers completed');
end;

procedure TMyThread.Timer;
var i:integer;
begin
 for i := 0 to length(TimerHandlers) - 1 do
  try
    if Mode in TimerHandlers[i].Modes
      then TimerHandlers[i].Proc();
  except
    on e:exception do
      Log('Exception in Timerhandler+'+inttostr(i)+' '+e.Message);
  end;
end;

procedure TMyThread.Execute;
var fProcessID:Cardinal;
var Msg: TMsg;
begin
  inherited;
  try
    try
     Init;
     SetTimer(0,1,50,nil);
     while GetMessage(Msg, 0, 0, 0) do
      try
       //Mit SC beenden
       if WaitForSingleObject(game.ProcessHandle,0)<>WAIT_TIMEOUT
         then begin
           Log('The game has terminated');
           break;
         end;
       //Aktives Fenster=SC?
       GetWindowThreadProcessId(GetForegroundWindow(),fProcessID);
       ScActive:=fProcessID=Game.ProcessID;
       //Nachrichten
       TranslateMessage(Msg);
       DispatchMessage(Msg);
       //timer
       if Msg.message =WM_TIMER then timer;
       //tasten l?chen
       setlength(keys,0);
      except
        on e:exception do
          Log('Exception in Mainloop+'+' '+e.Message);
      end;
    finally
     KillTimer(0,1);
     Finish;
     thread:=nil;
    end;
  except
    on e:exception do
      Log('Exception in Mainthread+'+' '+e.Message);
  end;
end;

procedure MainInitLauncher;
begin
  Main.Mode:=pmLauncher;
  MainInit;
  if PluginInfo.SelfInject then Inject(Game.ProcessHandle);
end;

procedure MainInitInjected;
begin
  Main.Mode:=pmInjected;
  DuplicateHandle( GetCurrentProcess,GetCurrentProcess,GetCurrentProcess,@Game.ProcessHandle,0,false,DUPLICATE_SAME_ACCESS);
  MainInit;
end;


procedure MainInit;
begin
 if thread<>nil
  then begin
   log('Thread already running');
   raise exception.create('Mainthread already running');
  end;
 thread:=TMyThread.create(true);
 thread.Priority:=tpLower;
 thread.FreeOnTerminate:=true;
 Log('Starting Thread');
 thread.Resume;
end;

procedure AddInitHandler(Proc:TProcedure;Modes:TValidPluginModeSet);
begin
 setlength(InitHandlers,length(InitHandlers)+1);
 InitHandlers[high(InitHandlers)].Proc:=Proc;
 InitHandlers[high(InitHandlers)].Modes:=Modes;
end;

procedure AddTimerHandler(Proc:TProcedure;Modes:TValidPluginModeSet);
begin
 setlength(TimerHandlers,length(TimerHandlers)+1);
 TimerHandlers[high(TimerHandlers)].Proc:=Proc;
 TimerHandlers[high(TimerHandlers)].Modes:=Modes;
end;

procedure AddFinishHandler(Proc:TProcedure;Modes:TValidPluginModeSet);
begin
 setlength(FinishHandlers,length(FinishHandlers)+1);
 FinishHandlers[high(FinishHandlers)].Proc:=Proc;
 FinishHandlers[high(FinishHandlers)].Modes:=Modes;
end;

function CheckKey(Key:integer):boolean;
var i:integer;
begin
 for i:= 0 to length(keys) - 1 do
  if keys[i].key=key
   then begin
     result:=keys[i].pressed;
     exit;
   end;
 setlength(keys,length(keys)+1);
 keys[high(keys)].key:=key;
 keys[high(keys)].pressed:=getasynckeystate(Key)or 1<>1;
 result:=keys[high(keys)].pressed;
end;

initialization
  Mode:=pmUnknown;
  ScActive:=false;
  PluginInfo.ApplyPatchSuspendend:=MainInitLauncher;
  if IsInjected then MainInitInjected;
finalization
end.
