unit Plugins;

interface
uses windows,classes,sysutils,util,logger,math,forms,update,versions,Launcher_game;

type
TLadder=class;

TCompatibility=(coUnknown,coForbidden,coIncompatible,coPartiallyCompatible,coCompatible,coRequired);
TBanRisk=(brError,brUnknown,brNone,brLow,brMedium,brHigh);

TGameVersion=record
  Name:String;
  Version:String;
  Filename:String;
  Ladder:TLadder;
 end;


TGameInfo=record
  hProcess:THandle;
  hThread:THandle;
  ProcessID:Cardinal;
  ThreadID:Cardinal;
  Suspended:boolean;
  Version:TGameVersion;
  procedure Clear;
  function Running:boolean;
 end;


TPlugin=class
  private
    FRunIncompatible: boolean;
    procedure SetRunIncompatible(const Value: boolean);
  protected
    FName: String;
    FHasConfig: boolean;
    FIndependentModule: boolean;
    FDescription: String;
    FAuthor: String;
    FVersion: TVersion;
    FBanRisk: TBanRisk;
    FFilename: String;
    FEnabled: boolean;
    FNeedsInjection: boolean;
    procedure SetEnabled(const Value: boolean);virtual;
    function GetCompatible(const Version:TGameVersion):TCompatibility;virtual;abstract;
    procedure GetInfoFromVersioninfo(const AFilename:string);
  public
    property Filename:String read FFilename;
    property HasConfig:boolean read FHasConfig;
    property IndependentModule:boolean read FIndependentModule;
    property Name:String read FName;
    property Description:String read FDescription;
    property Version:TVersion read FVersion;
    property Author:String read FAuthor;
    property BanRisk:TBanRisk read FBanRisk;
    property RunIncompatible:boolean read FRunIncompatible write SetRunIncompatible;
    property Enabled:boolean read FEnabled write SetEnabled;
    property NeedsInjection:boolean read FNeedsInjection;
    procedure LoadEnabled;virtual;
    function Compatible(const Version:TGameVersion):TCompatibility;
    function CanRun(const Version:TGameVersion):boolean;
    function CouldRun(const Version:TGameVersion):boolean;
    class function HandlesFile(const Filename,Ext: String):boolean;virtual;abstract;
    procedure ShowConfig;virtual;abstract;
    procedure ScSuspended;virtual;abstract;
    procedure ScWindowCreated;virtual;abstract;
    constructor Create(const AFilename:String);virtual;
    procedure CheckForUpdates(AUpdater:TUpdater;var desc:String);virtual;abstract;
end;

TLadder=class
  private
  protected
    FName: String;
  public
    property Name:String read FName;
    procedure GetPluginCompatible(var Compatibility:TCompatibility;const Version:TGameVersion;const PluginInfo:TPlugin);virtual;abstract;
    function GetGameCompatible(const Version:TGameVersion): boolean;virtual;abstract;
end;

var PluginData:array of TPlugin;
    VersionData:array of TGameVersion;
    LadderData:array of TLadder;

var LauncherInfo:record
    Path:String;
  end;
var GameInfo:TGameInfo;
var LatestVersion:integer=-1;

procedure UpdateScRunning;
procedure LoadPlugins;
procedure UnloadPlugins;
procedure GetGameVersions(const Path:String);
procedure StartGame(Version:TGameVersion;AProcessID:Cardinal=0);
procedure AddLadder(Ladder:TLadder);
function CompatibilityToStr(Compatibility:TCompatibility):String;
function BanRiskToStr(BanRisk:TBanRisk):String;
procedure AddGameVersion(const GameVersion:TGameVersion);

implementation

uses Plugins_BWL4,Plugins_DLL,Plugins_AdvLoader,Plugins_ICCup,inject,config;

Type TPluginUpdateModule=class(TUpdateModule)
  protected
  public
    Plugin:TPlugin;
    procedure CheckForUpdates(var desc:String);override;
end;

procedure LoadPlugins;

 procedure FindInDirectory(const Path:String;const Filter:String);
 var DirError:integer;
    DirSRec:TSearchRec;
    PlugSRec:TSearchRec;
    PlugError:integer;
    Plugin:TPlugin;
    Ext:String;
    Filename:String;
 begin
   //Plugins im Ordner durchsuchen
   PlugError:=FindFirst(Path+DirSRec.Name+Filter,faAnyfile and not faDirectory,PlugSRec);
   while PlugError=0 do
    begin
      try
        Filename:=Path+DirSRec.Name+PlugSRec.Name;
        Ext:=lowercase(ExtractFileExt(Filename));
        Plugin:=nil;
        if TBwl4Plugin.HandlesFile(Filename,ext) then Plugin:=TBwl4Plugin.create(Filename);
        if TIccPlugin.HandlesFile(Filename,ext) then Plugin:=TIccPlugin.create(Filename);
        if TInjPlugin.HandlesFile(Filename,ext) then Plugin:=TInjPlugin.create(Filename);
        if TAdvLoaderPlugin1.HandlesFile(Filename,ext) then Plugin:=TAdvLoaderPlugin1.create(Filename);
        if TAdvLoaderPlugin2.HandlesFile(Filename,ext) then Plugin:=TAdvLoaderPlugin2.create(Filename);
        if Plugin<>nil
         then begin
           Log('Plugin loaded '+Plugin.Name);
           setlength(PluginData,length(PluginData)+1);
           PluginData[high(PluginData)]:=Plugin;
         end;
      except
        on e:exception do
          ShowAndLogException(E,'FindInDirectory '+PlugSRec.Name);
      end;
      PlugError:=FindNext(PlugSRec);
    end;
  if (PlugError<>ERROR_NO_MORE_FILES)and(PlugError<>ERROR_FILE_NOT_FOUND)and(PlugError<>ERROR_PATH_NOT_FOUND)
    then MessageBox(0,PChar('Search for plugins failed '+GetErrorString(PlugError)), 'Error', MB_OK + MB_ICONSTOP);

  DirError:=FindFirst(Path+'*.*',faAnyfile,DirSRec);
  //Ordner Durchsuchen
  while DirError=0 do
   begin
     if (DirSRec.Attr and faDirectory=0)//No Directory
       or(DirSRec.Name='..')//Parentdirectory
       or(DirSRec.Name='.')//CurrentDirectory
       then begin
         DirError:=FindNext(DirSRec);
         continue;
       end;
     FindInDirectory(Path+DirSRec.Name+'\',Filter);
     DirError:=FindNext(DirSRec);
   end;
  if (DirError<>ERROR_NO_MORE_FILES)and(DirError<>ERROR_FILE_NOT_FOUND)and(DirError<>ERROR_PATH_NOT_FOUND)
    then MessageBox(0,PChar('Search for pluginsubdirectories failed '+GetErrorString(DirError)), 'Error', MB_OK + MB_ICONSTOP);
 end;

begin
  setlength(PluginData,0);
  FindInDirectory(extractfilepath(paramstr(0)),'*.*');
  FindInDirectory(AdvPluginPath,'*.bwp');
end;

function CompatibilityToStr(Compatibility:TCompatibility):String;
begin
  case Compatibility of
    coUnknown:            result:='Unknown';
    coForbidden:          result:='Forbidden';
    coIncompatible:       result:='Incompatible';
    coPartiallyCompatible:result:='Partially compatible';
    coCompatible:         result:='Compatible';
    coRequired:           result:='Required';
    else                  result:='Error';
  end;
end;

function BanRiskToStr(BanRisk:TBanRisk):String;
begin
  case BanRisk of
    brUnknown:result:='Unknown ban risk';
    brNone:result:='No ban risk';
    brLow:result:='Low ban risk';
    brMedium:result:='Medium ban risk';
    brHigh:result:='High ban risk';
    else result:='Error';
  end;
end;

procedure UnloadPlugins;
var i:integer;
begin
  for i := 0 to length(PluginData)-1 do
    PluginData[i].Free;
  setlength(PluginData,0);
end;


procedure UpdateScRunning;
var error:integer;
begin
  //Sc terminated?
  SetLastError(0);
  if (GameInfo.hProcess<>0)and(WaitForSingleObject(GameInfo.hProcess,0)<>WAIT_TIMEOUT)
    then try
      error:=getlasterror;
      if error<>0 then raise exception.create('ProcessHandle Error: '+inttostr(error)+GetErrorString(error));
      CloseHandle(GameInfo.hProcess);
      CloseHandle(GameInfo.hThread);
    finally
      GameInfo.Clear;
    end;
end;

function CompareGameVersions(const Version1,Version2:TGameVersion):integer;
begin
  //Numeric comparison
  result:=CompareVersions(ParseVersion(Version1.Version), ParseVersion(Version2.Version));
  //If no difference use lexical comparison
  if (result=0)and(Version1.Version>Version2.Version) then result:=1;
  if (result=0)and(Version1.Version<Version2.Version) then result:=1;
  //highest priority: laddername and ladder after nonladder
  if (Version1.ladder<>nil)and(Version2.ladder=nil) then result:=+1;
  if (Version1.ladder=nil)and(Version2.ladder<>nil) then result:=-1;
  if (Version1.ladder<>nil)and(Version2.ladder<>nil)
   then begin
     if Version1.Ladder.Name>Version2.Ladder.Name then result:=+1;
     if Version1.Ladder.Name<Version2.Ladder.Name then result:=-1;
   end;
end;

procedure SortVersions(L, R: Integer);
var
  I, J, P: Integer;
  Temp:TGameVersion;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while CompareGameVersions(VersionData[I],VersionData[P])<0 do Inc(I);
      while CompareGameVersions(VersionData[J],VersionData[P])>0 do Dec(J);
      if I <= J then
      begin
        Temp:=VersionData[I];
        VersionData[I]:=VersionData[J];
        VersionData[J]:=Temp;
        if P = I then
          P := J
        else if P = J then
          P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then SortVersions(L, J);
    L := I;
  until I >= R;
end;

procedure AddGameVersion(const GameVersion:TGameVersion);
begin
  setlength(VersionData,length(VersionData)+1);
  VersionData[high(VersionData)]:=GameVersion;
end;

procedure AddLadder(Ladder:TLadder);
begin
  setlength(LadderData,length(LadderData)+1);
  LadderData[high(LadderData)]:=Ladder;
end;

procedure AddLadders;
var iv,il:integer;
    GameVersion:TGameVersion;
begin
  //Add Ladders
  for iv := 0 to length(VersionData) - 1 do
    for il:=0 to length(LadderData)-1do
      if LadderData[il].GetGameCompatible(VersionData[iv])
        then begin
          GameVersion:=VersionData[iv];
          GameVersion.Ladder:=LadderData[il];
          GameVersion.Name:=LadderData[il].Name+' '+GameVersion.Version;
          AddGameVersion(GameVersion);
        end;
end;

function StringsAllContainContent(const Strings:array of String):boolean;
var i:integer;
begin
  result:=true;
  for i:=0 to length(Strings)-1do
    if Strings[i]='' then
      result:=false;
end;

function StringsFirstLetterIdentical(const Strings:array of String):boolean;
var i:integer;
begin
  result:=true;
  for i:=0 to length(Strings)-1do
    if Strings[i][1]<>Strings[0][1]
      then result:=false;
end;

function StringsLastLetterIdentical(const Strings:array of String):boolean;
var i:integer;
begin
  result:=true;
  for i:=0 to length(Strings)-1do
    if Strings[i][length(Strings[i])]<>Strings[0][length(Strings[0])]
      then result:=false;
end;

procedure StringsDeleteFirstChar(var Strings:array of String);
var i:integer;
begin
  for i:=0 to length(Strings)-1do
    delete(Strings[i],1,1);
end;

procedure StringsDeleteLastChar(var Strings:array of String);
var i:integer;
begin
  for i:=0 to length(Strings)-1do
    delete(Strings[i],length(Strings[1]),1);
end;

procedure GetUniqueStringParts(var Strings:array of String);
begin
  while StringsAllContainContent(Strings) and StringsFirstLetterIdentical(Strings) do
    StringsDeleteFirstChar(Strings);
  while StringsAllContainContent(Strings) and StringsLastLetterIdentical(Strings) do
    StringsDeleteLastChar(Strings);
end;

procedure SortGameVersions;
var iv:integer;
    FilenameMe,FilenameOther:String;
begin
  //Sort
  if length(VersionData)>0
    then SortVersions(0,length(VersionData)-1);
  //Give duplicates unique names, requires a sorted list
  {if length(VersionData)>1 then
    for iv := 1 to length(VersionData)-1 do
     begin
       if VersionData[iv-1].Name<>VersionData[iv].Name then continue;//No Duplicate

       FilenameMe:=VersionData[iv].Filename;
       FilenameOther:=VersionData[iv-1].Filename;
       GetUniqueStringParts(FilenameMe,FilenameOther);
       FilenameMe:=trim(FilenameMe);
       if FilenameMe<>'' then FilenameMe:=' ('+FilenameMe+')';
       VersionData[iv].Name:=VersionData[iv].Name+NameSuffix;
     end;    }
  //Sort again, as the renaming could have changed the order
  if length(VersionData)>0
    then SortVersions(0,length(VersionData)-1);
end;

procedure GetGameVersions;
var iv:Integer;
begin
  Log('Get Starcraftversions');
  setlength(VersionData,0);
  GameListVersions;
  AddLadders;
  SortGameVersions;
  //Find latest version with no ladder
  LatestVersion:=-1;
  for iv := 0 to length(VersionData)-1 do
    if VersionData[iv].ladder=nil then LatestVersion:=iv;
end;

procedure StartGame(Version:TGameVersion;AProcessID:Cardinal=0);
var ProcessInfo:TProcessInformation;
    StartupInfo:TStartupInfo;
    i:integer;
    S:String;
    NeedsInjection:boolean;
    NeedsAdvInjection:boolean;
    wnd:THandle;
    error:Cardinal;
    StartTime:Cardinal;
begin
  UpdateScRunning;
  if GameInfo.Running then raise exception.create(GameName+' is already running');
  if (AProcessID=0)and(GameFindProcessID<>0) then raise exception.create('An external instance of'+GameName+' is already running');
  try
    GameInfo.Clear;
    Log('Starting Game '+Version.Name+' '+Version.Filename);
    for i := 0 to length(PluginData)-1 do
     begin
       if not PluginData[i].CanRun(Version) then continue;
       S:=PluginData[i].Name+' Version '+VersionToStr(PluginData[i].Version);
       S:=S+' '+CompatibilityToStr(PluginData[i].compatible(Version));
       if PluginData[i].RunIncompatible
         then S:=S+' RunIncompatible';
       Log(S);
     end;
    if not EnablePrivilege('SeDebugPrivilege')
      then begin
        error:=GetLastError;
        Log('Could not obtain SeDebugPrivilege '+GetErrorString(error));
        if settings.WarnNoAdmin
          then SimpleMessageBox(smtWarning,
                                'Could not obtain SeDebugPrivilege'#13#10+
                                'Some plugins might not work correctly or cause errors'#13#10+
                                'You need to be admin and if you are using vista you have to set the adminflag in the properties of Chaoslauncher.exe'#13#10+
                                GetErrorString(error));
      end
      else Log('Obtained DebugPrivilege');
    if AProcessID=0
      then begin
        Log('CreateProcess');
        fillchar(ProcessInfo,sizeof(Processinfo),0);
        fillchar(StartupInfo,sizeof(StartupInfo),0);
        if not CreateProcess(PChar(Version.Filename),nil,nil,nil,false,CREATE_SUSPENDED,nil,PChar(extractfilepath(Version.filename)),StartupInfo,ProcessInfo)
          then raise exception.create('Could not start Starcraft '#13#10+GetLastErrorString+#13#10+Version.Filename);
        GameInfo.hProcess:=ProcessInfo.hProcess;
        GameInfo.hThread:=ProcessInfo.hThread;
        GameInfo.ProcessID:=ProcessInfo.dwProcessId;
        GameInfo.ThreadID:=ProcessInfo.dwThreadId;
        GameInfo.Suspended:=true;
      end
      else begin
        Log('OpenProcess');
        GameInfo.hProcess:=OpenProcess(PROCESS_ALL_ACCESS,false,AProcessID);
        if GameInfo.hProcess=0 then raise exception.create('Could not attach to Starcraft'#13#10+GetLastErrorString);
        GameInfo.hThread:=0;
        GameInfo.ProcessID:=AProcessID;
        GameInfo.ThreadID:=0;
        GameInfo.Suspended:=false;
      end;
    GameInfo.Version:=Version;
    NeedsInjection:=false;
    NeedsAdvInjection:=false;
    for i := 0 to length(PluginData)-1 do
      if PluginData[i].CanRun(Version)then
        begin
          if PluginData[i].NeedsInjection then
            NeedsInjection:=true;
          if PluginData[i] is TAdvLoaderPlugin then
            NeedsAdvInjection:=true;
        end;
    UpdateScRunning;
    if not GameInfo.Running then raise exception.create('Starcraft no longer running');

    Log('Call ScSuspended for all active Plugins');
    for i := 0 to length(PluginData)-1 do
      if PluginData[i].CanRun(Version)then
        try
          PluginData[i].ScSuspended;
        except
          on E:Exception do
            ShowAndLogException(E,'StartGame ScSuspended '+PluginData[i].Name);
        end;
    if NeedsInjection
    then begin
      Log('Injecting');
      //DoInject(imOverwrite,RunInfo,Version);
    end;
    Log('ResumeThread');
    if AProcessID=0 then ResumeThread(GameInfo.hThread);
    Log('WaitForInputIdle');
    StartTime:=GetTickCount();
    while FindWindow('SWarClass',nil)=0 do
    begin
      if GetTickCount()-StartTime>60000
        then raise exception.Create('Sc startup timeout'#13#10+GetLastErrorString);
      sleep(100);
    end;
    //if WaitForInputIdle(GameInfo.hProcess,60000)<>0
    //  then SimpleMessageBox(smtWarning,'Sc startup timeout'#13#10+GetLastErrorString);
    UpdateScRunning;
    if GameInfo.hProcess=0 then raise exception.create('Starcraft no longer running');
    if NeedsAdvInjection
    then begin
      Log('Injecting AdvLoader helper');
      InjectAdvLoader;
      Log('Injection successfull');
    end;
    Log('Call ScWindowCreated for all active Plugins');
    for i := 0 to length(PluginData)-1 do
      if PluginData[i].CanRun(Version) then
        try
          PluginData[i].ScWindowCreated;
        except
          on E:Exception do
            ShowAndLogException(E,'StartGame ScWindowCreated '+PluginData[i].Name);
        end;
    Log('Starting Starcraft completed');
  except
    CloseHandle(GameInfo.hProcess);
    CloseHandle(GameInfo.hThread);
    GameInfo.Clear;
    raise;
  end;
  wnd:=FindWindow('SWarClass',nil);
  SendMessage(wnd,$402,0,0);
end;

{ TPlugin }

function TPlugin.CanRun(const Version:TGameVersion):boolean;
begin
  result:=enabled and CouldRun(Version);
end;

function TPlugin.Compatible(const Version: TGameVersion): TCompatibility;
begin
  result:=GetCompatible(Version);
  if Version.Ladder<>nil
    then Version.Ladder.GetPluginCompatible(result,Version,self);
end;

function TPlugin.CouldRun(const Version: TGameVersion): boolean;
begin
  case compatible(Version) of
    coUnknown     :result:=RunIncompatible;
    coForbidden   :result:=false;
    coIncompatible:result:=RunIncompatible;
    coPartiallyCompatible,
    coCompatible,
    coRequired    :result:=true;
    else result:=false;
  end;
end;

constructor TPlugin.Create(const AFilename: String);
var UpdateModule:TPluginUpdateModule;
begin
  FFilename:=AFilename;
  FHasConfig:=false;
  FIndependentModule:=false;
  FNeedsInjection:=false;
  FBanRisk:=brUnknown;
  FRunIncompatible:=false;
  UpdateModule:=TPluginUpdateModule.Create(Updater);
  UpdateModule.Plugin:=self;
  FName:=changefileext(extractfilename(AFilename),'');
  FDescription:='No Description';
  GetInfoFromVersioninfo(AFilename);
end;

procedure TPlugin.GetInfoFromVersioninfo(const AFilename: string);
var AName,ADescription:String;
begin
  AName:=GetLocalizedVersionValue(AFilename,'ProductName');
  Str_FitZeroTerminated(AName);
  AName:=trim(AName);
  if AName<>'' then FName:=AName;
  ADescription:=GetLocalizedVersionValue(AFilename,'FileDescription');
  Str_FitZeroTerminated(ADescription);
  ADescription:=trim(ADescription);
  if FDescription='' then FDescription:=ADescription;
  GetFileVersionRec(AFilename,FVersion);
  FAuthor:=GetLocalizedVersionValue(AFilename,'CompanyName');
  Str_FitZeroTerminated(FAuthor);
  FAuthor:=trim(FAuthor);
end;

procedure TPlugin.LoadEnabled;
begin
  FEnabled:=ini.ReadBool('PluginsEnabled',Name,false);
end;

procedure TPlugin.SetEnabled(const Value: boolean);
begin
  FEnabled := Value;
  ini.WriteBool('PluginsEnabled',Name,FEnabled);
end;

procedure TPlugin.SetRunIncompatible(const Value: boolean);
begin
  FRunIncompatible := Value;
end;

{ TBwlUpdaterModule }

procedure TPluginUpdateModule.CheckForUpdates(var desc:String);
begin
  Assert(self<>nil,'PluginUpdateModule.CheckForUpdates called on nil');
  Assert(Updater<>nil,'PluginUpdateModule.CheckForUpdates called with Updater=nil');
  Assert(Plugin<>nil,'PluginUpdateModule.CheckForUpdates called with Plugin=nil');
  Plugin.CheckForUpdates(Updater,desc);
end;

{ TGameInfo }

procedure TGameInfo.Clear;
begin
  GameInfo.hProcess:=0;
  GameInfo.hThread:=0;
  GameInfo.ProcessID:=0;
  GameInfo.ThreadID:=0;
  Suspended:=false;
end;

function TGameInfo.Running: boolean;
begin
  result:=hProcess<>0;
end;

initialization
  GameInfo.Clear;
  LauncherInfo.Path:=extractfilepath(paramstr(0));
finalization
  UnloadPlugins;
end.
