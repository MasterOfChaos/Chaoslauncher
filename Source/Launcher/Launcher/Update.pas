unit Update;

interface
uses sysutils,util,idhttp;
type EUpdateFailed=class(Exception);
     EUpdateInvalidTempPath=class(EUpdateFailed);

type
TUpdateFlag=(ufCompressed,ufIncremental);
TUpdateFlags=set of TUpdateflag;

TUpdater=class;

TUpdateModule=class
  private
    FUpdater: TUpdater;
  protected
  public
    procedure CheckForUpdates(var desc:String);virtual;abstract;
    property Updater:TUpdater read FUpdater;
    constructor Create(AUpdater:TUpdater);
end;

TUpdateFile=record
    Url:String;
    TempName:String;
    RealName:String;
    md5:String;
    Flags:TUpdateFlags;
  end;


TUpdater=class
  private
    GetModuleCount: integer;
    FFiles:array of TUpdateFile;
    FModules:array of TUpdateModule;
    FTempPath: String;
    function GetModule(Index:integer):TUpdateModule;
    procedure SetTempPath(const Value: String);
    function GetFileCount: integer;
    procedure AddModule(Module:TUpdateModule);
  protected
  public
    property Modules[Index:integer]:TUpdateModule read GetModule;
    property ModuleCount:integer read GetModuleCount;
    property TempPath:String read FTempPath write SetTempPath;
    property FileCount:integer read GetFileCount;
    function CheckForUpdates(out desc:String):boolean;
    procedure DownloadUpdates;
    function InstallUpdates:boolean;
    procedure AddFile(ARealName,AUrl:String;Flags:TUpdateFlags=[]);
    destructor Destroy;override;
end;


var Updater:TUpdater;
    UpdatesReady:boolean=false;
    RestartLauncher:boolean=false;
implementation
uses windows,classes,shellapi,logger,zlib;

function Decompress(const S:String):String;
var dcs: TDecompressionStream;
    ssIn:TStringStream;
    ssOut:TStringStream;
    buf:array[0..1023]of byte;
    bread:integer;
begin
  ssIn:=nil;
  dcs:=nil;
  ssOut:=nil;
  try
    ssIn:=TStringStream.create(S);
    dcs:=TDecompressionStream.Create(ssIn);
    ssOut:=TStringStream.create('');
    repeat
      bread:=dcs.Read(buf,sizeof(buf));
      ssOut.Write(buf,bread);
    until bread<>sizeof(buf);
    result:=ssOut.DataString;
  finally
    ssIn.free;
    dcs.free;
    ssOut.free;
  end;
end;

{ TUpdater }

procedure TUpdater.AddFile(ARealName,AUrl:String;Flags:TUpdateFlags);
begin
  SetLength(FFiles,length(FFiles)+1);
  FFiles[high(FFiles)].Url:=AUrl;
  FFiles[high(FFiles)].RealName:=ARealName;
  FFiles[high(FFiles)].TempName:='Temp'+inttostr(high(FFiles))+'.upd';
  FFiles[high(FFiles)].Flags:=Flags;
end;

procedure TUpdater.AddModule(Module: TUpdateModule);
begin
  SetLength(FModules,length(FModules)+1);
  FModules[high(FModules)]:=Module;
end;

function TUpdater.CheckForUpdates(out desc:String): boolean;
var i:integer;
begin
  desc:='';
  setlength(FFiles,0);
  for I := 0 to length(FModules)-1 do
    FModules[i].CheckForUpdates(desc);
  result:=length(FFiles)>0;
end;

destructor TUpdater.Destroy;
var i:integer;
begin
  for i := 0 to length(FModules)-1 do
    FModules[i].free;
  inherited;
end;

procedure TUpdater.DownloadUpdates;
var i:integer;
    http:TIdHttp;
    updateinfo:String;
    data:String;
begin
  Log('Downloading updates');
  forcedirectories(TempPath);
  http:=nil;
  updateinfo:='';
  try
    http:=TIdHttp.create(nil);
    http.ConnectTimeout:=1000;
    for I := 0 to length(FFiles)-1 do
      begin
        Log('downloading '+FFiles[i].Url);
        try
          data:=http.Get(FFiles[i].Url)
        except
          on e:exception do
           begin
            LogException(e,'TUpdater.DownloadUpdates http.get('+FFiles[i].Url+')');
            exit;
          end;
         end;
        if ufCompressed in FFiles[i].Flags
          then Data:=Decompress(Data);
        StringToFile(data,TempPath+FFiles[i].Tempname);
        UpdateInfo:=UpdateInfo+FFiles[i].RealName+#13#10;
      end;
    Log('downloads complete');
    StringToFile(UpdateInfo,TempPath+'UpdateInfo.dat');
    UpdatesReady:=true;
  finally
    http.free;
  end;
end;

function TUpdater.GetFileCount: integer;
begin
  result:=length(FFiles);
end;

function TUpdater.GetModule(Index: integer): TUpdateModule;
begin
  if (Index<0)or(Index>high(FModules))
    then raise ERangeError.create('Invalid Index '+inttostr(Index));
  result:=FModules[Index];
end;

function TUpdater.InstallUpdates:boolean;
begin
  result:=false;
  if FileExists(TempPath+'UpdateInfo.dat')
    then begin
      result:=true;
      ShellExecute(0,'open',PChar(extractfilepath(paramstr(0))+'ChaosUpdater.exe'),PChar('/install "'+paramstr(0)+'" "'+TempPath+'"'),'',sw_normal);
    end;
end;

procedure TUpdater.SetTempPath(const Value: String);
begin
  FTempPath := Value;
end;

{ TUpdateModule }

constructor TUpdateModule.Create(AUpdater: TUpdater);
begin
  inherited Create;
  Assert(AUpdater<>nil,'TUpdateModule.Create called with Updater=nil');
  FUpdater:=AUpdater;
  AUpdater.AddModule(self);
end;

initialization
  Updater:=TUpdater.create;
  Updater.TempPath:=extractfilepath(paramstr(0))+'Temp\';
finalization
  Updater.free;
end.
