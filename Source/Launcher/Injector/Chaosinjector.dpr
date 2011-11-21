library Chaosinjector;

uses
  windows,
  classes,
  sysutils,
  util,
  logger,
  streaming,
  plugins,
  asmhelper,
  Plugins_CHL in '..\Launcher\Plugins_CHL.pas',
  Inject_Overwrite in '..\Launcher\Inject_Overwrite.pas';

{$R *.res}

type TInjectedInfoStrings=record
  LauncherExecutable:String;
  LauncherPath:String;
  InjectorExecutable:String;
  InjectorPath:String;
  PluginExecutable:String;
  PluginPath:String;
  GameExecutable:String;
  GamePath:String;
  GameVersion:String;
 end;

type TInjectEvent=function(const InjectInfo:TInjectedInfo):BOOL;stdcall;


function DisplayLocalTextMessage(Msg:PChar):BOOL;stdcall;
begin
  MessageBox(0,Msg,'LocalTextOut',MB_OK or MB_ICONHAND);
  result:=false;
end;

function RegisterCallback(Event:PChar;CallBack:pointer;UserData:pointer;Priority:integer):TCallbackHandle;stdcall;
begin
  result:=0;
end;

function UnRegisterCallback(CallbackHandle:TCallbackHandle):BOOL;stdcall;
begin
  result:=false;
end;

procedure LoadPlugin(const InjectInfo:TInjectedInfo);
var LibHandle:THandle;
    InjectEvent:TInjectEvent;
    EventSuccessfull:boolean;
begin
  Log('Loading plugin... '+InjectInfo.PluginPath);
  LibHandle:=0;
  try
    LibHandle:=LoadLibrary(PChar(InjectInfo.PluginPath));
  except
    Log('Exception in LoadLibrary');
  end;
  if LibHandle=0
    then begin
      Log('Error while loading library. Error: '+GetLastErrorString);
      exit;
    end;
  Log('Successfully loaded library');
  InjectEvent:=GetProcAddress(LibHandle,'Injected');
  if not assigned(InjectEvent)
    then begin
      Log('Calling Injected');
      EventSuccessfull:=false;
      try
        EventSuccessfull:=InjectEvent(InjectInfo);
      except
        Log('Exception in Injected');
      end;
      if not EventSuccessfull then Log('Injected failed');
    end;
end;

procedure ReadInjectedInfo(stm:TStream;out InjectedInfo:TInjectedInfo;out InjectedInfoStrings:TInjectedInfoStrings);
begin
  InjectedInfo.StructSize:=sizeof(InjectedInfo);
  InjectedInfo.LauncherApiMajor:=stm.ReadWord;
  InjectedInfo.LauncherApiMinor:=stm.ReadWord;

  InjectedInfoStrings.LauncherExecutable:=stm.readstring32;
  InjectedInfoStrings.LauncherPath:=stm.readstring32;
  InjectedInfoStrings.PluginExecutable:='';
  InjectedInfoStrings.PluginPath:='';
  InjectedInfoStrings.GamePath:=stm.readstring32;
  InjectedInfoStrings.GameExecutable:=stm.readstring32;
  InjectedInfoStrings.GameVersion:=stm.readstring32;

  InjectedInfo.LauncherExecutable:=PChar(InjectedInfoStrings.LauncherExecutable);
  InjectedInfo.LauncherPath:=PChar(InjectedInfoStrings.LauncherPath);
  InjectedInfo.PluginExecutable:=nil;
  InjectedInfo.PluginPath:=nil;
  InjectedInfo.GamePath:=PChar(InjectedinfoStrings.GamePath);
  InjectedInfo.GameExecutable:=PChar(InjectedInfoStrings.GameExecutable);
  InjectedInfo.GameVersion:=PChar(InjectedInfoStrings.GameVersion);

  InjectedInfo.GameProcessID:=stm.ReadDWord;
  InjectedInfo.GameProcessHandle:=stm.ReadDWord;
  InjectedInfo.GameMainThreadID:=stm.ReadDWord;
  InjectedInfo.GameMainThreadHandle:=stm.ReadDWord;
  InjectedInfo.IsLateActivation:=Stm.ReadByte>0;
  InjectedInfo.RegisterCallback:=RegisterCallback;
  InjectedInfo.UnregisterCallback:=UnRegisterCallback;
  InjectedInfo.DisplayLocalTextMessage:=DisplayLocalTextMessage;
end;

procedure Init;
var stm:TFileStream;
    Count:integer;
    i:integer;
    InjectedInfo:TInjectedInfo;
    InjectedInfoStrings:TInjectedInfoStrings;
    Filename:String;
begin
  try
    stm:=nil;
    try
      stm:=TFilestream.create(changefileext(paramstr(0),'.chi'),fmOpenRead or fmShareDenyWrite);
      ReadInjectedInfo(stm,InjectedInfo,InjectedInfoStrings);
      Count:=stm.ReadInt32;
      for i:=0 to Count-1 do
        begin
          Filename:=stm.ReadStringZT;
          InjectedInfoStrings.PluginExecutable:=Filename;
          InjectedInfoStrings.PluginPath:=ExtractFilePath(Filename);
          InjectedInfo.PluginExecutable:=PChar(InjectedInfoStrings.PluginExecutable);
          InjectedInfo.PluginPath:=PChar(InjectedInfoStrings.PluginPath);
          LoadPlugin(InjectedInfo);
        end;
      CloseHandle(InjectedInfo.GameProcessHandle);
      CloseHandle(InjectedInfo.GameMainThreadHandle);
    finally
      stm.free;
    end;
  except
    on e:exception do
      Log('Fatal Exception('+e.ClassName+')in Init: '+e.Message);
  end;
end;


procedure InitOverwrite;
var stm:TFileStream;
    EntryPoint:Cardinal;
    CodeBackup:String;
begin
  try
    stm:=nil;
    try
      stm:=TFilestream.create(changefileext(paramstr(0),'.chio'),fmOpenRead or fmShareDenyWrite);
      EntryPoint:=stm.ReadDWord;
      CodeBackup:=stm.ReadString32;
      WriteString(EntryPoint,CodeBackup);
      Init;
    finally
      stm.free;
    end;
  except
    on e:exception do
      Log('Fatal Exception('+e.ClassName+')in InitOverwrite: '+e.Message);
  end;
end;


begin

end.
