unit Plugins_BWL4;

interface
uses windows,sysutils,classes,util,logger,plugins,versions,update,plugins_bwl,crypto;

Type TBwl4Plugin=class(TPlugin)
  private
    procedure GetPluginApi;
    procedure GetSigPublicKey;
    procedure GetData;
  protected
    FScVersion:integer;
    hLibrary:HMODULE;
    FUpdateUrl:String;
    FPublicKey:String;
    function GetCompatible(const Version:TGameVersion):TCompatibility;override;
  public
    class function HandlesFile(const Filename,Ext: String):boolean;override;
    procedure CheckForUpdates(AUpdater:TUpdater;var desc:String);override;
    procedure ShowConfig;override;
    procedure ScSuspended;override;
    procedure ScWindowCreated;override;
    constructor Create(const AFilename:String);override;
    destructor Destroy;override;
end;

implementation

type
 TBWL_ExchangeData=packed record
   PluginAPI:integer;
   StarCraftBuild:integer;
   NotSCBWmodule:BOOL;                //Inform user that closing BWL will shut down your plugin
   ConfigDialog:BOOL;                 //Is Configurable
  end;

type
     TApplyPatchSuspended=function(hProcess:THandle;ProcessID:Cardinal):BOOL;cdecl;
     TApplyPatch=function(hProcess:THandle;ProcessID:Cardinal):BOOL;cdecl;
     TOpenConfig=function():BOOL;cdecl;
     TGetData=procedure (Name,Description,UpdateUrl:Pchar);cdecl;
     TGetPluginAPI=procedure (var Data:TBWL_Exchangedata);cdecl;
     TGetSigPublicKey=procedure(Method,Key:PChar);cdecl;

{ TBwlPlugin }

procedure TBwl4Plugin.CheckForUpdates(AUpdater:TUpdater;var desc:String);
begin
  Assert(self<>nil,'TBwlPlugin.CheckForUpdates called on nil');
  Log('Updateing '+Name);
  BwlUpdateCheck(AUpdater,FUpdateUrl,Filename,desc,Name);
end;

function Bwl4VersionIDToString(VersionID:integer):String;
begin
  case VersionID of
    -1:result:='All';
     0:result:='1.04';
     1:result:='1.08b';
     2:result:='1.09b';
     3:result:='1.10';
     4:result:='1.11b';
     5:result:='1.12b';
     6:result:='1.13f';
     7:result:='1.14.0';
     8:result:='1.15.0';
     9:result:='1.15.1';
    10:result:='1.15.2';
    11:result:='1.15.3';
    12:result:='1.16.0';
    13:result:='1.16.1';
    else result:='Unknown';
  end;
end;

function TBwl4Plugin.GetCompatible(const Version:TGameVersion):TCompatibility;
var VersionStr:String;
begin
  VersionStr:=Bwl4VersionIDToString(FScVersion);
  if VersionStr='Unknown'
    then raise exception.create('Chaoslauncher does not support this SC-Version. Update your launcher, or contact me if no update is available');
  if (VersionStr='All')or(VersionStr=Version.Version)
    then result:=coCompatible
    else result:=coIncompatible;
end;

procedure Pos2(var Position:integer;const substr: string; const str: string);
var temp:integer;
begin
  temp:=pos(Substr,str);
  if temp>0 then Position:=temp+length(substr)-1;
end;

function ExtractAuthorFromDescription(Description:String):String;
var AuthorPos:integer;
    i:integer;
begin
  AuthorPos:=0;
  pos2(AuthorPos,'by ',lowercase(Description));
  pos2(AuthorPos,'author ',lowercase(Description));
  pos2(AuthorPos,'author: ',lowercase(Description));
  if AuthorPos>0 then begin
    result:=Description;
    delete(result,1,AuthorPos);
    i:=length(result);
    while i>0 do
     begin
       if result[i]in[#13,#10,#9] then
         setlength(result,i-1);
       dec(i);
     end;
  end
  else result:='';
end;


procedure TBwl4Plugin.GetData;
var GetDataCallback:TGetData;
    AName,ADescription,AUpdateUrl,AAuthor:String;
begin
  GetDataCallback:=GetProcAddress(hLibrary,'GetData');
  if not assigned(GetDataCallback) then raise exception.create('Could not call GetData in '+Filename);
  setlength(AName,1024);
  AName[1]:=#0;
  setlength(ADescription,8192);
  ADescription[1]:=#0;
  setlength(AUpdateUrl,1024);
  AUpdateUrl[1]:=#0;
  try
    GetDataCallback(PChar(AName),PChar(ADescription),PChar(AUpdateUrl));
  except
    Log('Exception in GetData');
    SimpleMessageBox(smtError,'Exception in GetData');
    raise;
  end;
  Str_FitZeroTerminated(AName);
  Str_FitZeroTerminated(ADescription);
  Str_FitZeroTerminated(AUpdateUrl);
  if AName<>'' then FName:=AName;
  FUpdateUrl:=AUpdateUrl;
  if ADescription<>'' then FDescription:=ADescription;
  GetFileVersionRec(Filename,FVersion);
  AAuthor:=ExtractAuthorFromDescription(ADescription);
  if FAuthor='' then FAuthor:=AAuthor;
end;


procedure TBwl4Plugin.GetPluginApi;
var Data:TBWL_ExchangeData;
    GetPluginAPICallback:TGetPluginApi;
begin
  //Default values
  Data.StarCraftBuild:=0;
  Data.PluginAPI:=0;
  Data.ConfigDialog:=false;
  Data.NotSCBWmodule:=false;

  //Get and Call Function from Plugin
  GetPluginApiCallback:=GetProcAddress(hLibrary,'GetPluginAPI');
  if not assigned(GetPluginApiCallback) then raise exception.create('Could not call GetPluginAPI in '+Filename);
  try
    GetPluginApiCallback(Data);
  except
    Log('Exception in GetPluginAPI');
    SimpleMessageBox(smtError,'Exception in GetPluginAPI');
    raise;
  end;

  //Save info obtained from Plugin
  if Data.PluginApi<>4 then raise exception.create('Incompatible BWL-Api Version, 4 expected in '+Filename);
  FIndependentModule:=not Data.NotSCBWmodule;
  FHasConfig:=Data.ConfigDialog;
  FScVersion:=Data.StarCraftBuild;
end;


procedure TBwl4Plugin.GetSigPublicKey;
var GetSigPublicKeyCallback:TGetSigPublicKey;
    APublicKey,ASigMethod:String;
begin
  GetSigPublicKeyCallback:=GetProcAddress(hLibrary,'GetSigPublicKey');
  FPublicKey:='';
  if assigned(GetSigPublicKeyCallback)
    then begin
      setlength(APublicKey,8192);
      APublicKey[1]:=#0;
      setlength(ASigMethod,1024);
      ASigMethod[1]:=#0;
      try
        GetSigPublicKeyCallback(PChar(ASigMethod),PChar(APublicKey));
      except
        Log('Exception in GetSigPublicKey');
        SimpleMessageBox(smtError,'Exception in GetSigPublicKey');
        raise;
      end;
      Str_FitZeroTerminated(APublicKey);
      Str_FitZeroTerminated(ASigMethod);
      if ASigMethod='rsa1024:sha1'
        then FPublicKey:=APublicKey;
    end;
  if FPublicKey<>'' then Log('Signature found '+sha1(FPublicKey));
end;

class function TBwl4Plugin.HandlesFile(const Filename,Ext: String):boolean;
begin
  result:=ext='.bwl';
end;

constructor TBwl4Plugin.Create(const AFilename: String);
begin
  //Load
  Log('Loading BWL4-Plugin '+AFilename);
  inherited;
  hLibrary:=LoadLibrary(PChar(Filename));
  if hLibrary=0 then raise exception.create('Could not load Plugin "'+Filename+'"'#13#10'Error: '+GetLastErrorString);
  GetPluginApi;
  GetSigPublicKey;
  GetData;
end;

destructor TBwl4Plugin.Destroy;
begin
  Log('Unloading Plugin '+Name);
  FreeLibrary(hLibrary);
  inherited;
end;

procedure TBwl4Plugin.ScSuspended;
var ApplyPatchSuspended:TApplyPatchSuspended;
begin
  Log('ApplyPatchSuspended for '+Name);
  ApplyPatchSuspended:=GetProcAddress(hLibrary,'ApplyPatchSuspended');
  if not assigned(ApplyPatchSuspended)
    then raise exception.create('Could not call ApplyPatchSuspended in '+Filename);
  if not ApplyPatchSuspended(GameInfo.hProcess,GameInfo.ProcessID)
    then raise exception.create('Error in ApplyPatchSuspended in '+Filename);
end;

procedure TBwl4Plugin.ScWindowCreated;
var ApplyPatch:TApplyPatch;
begin
  Log('ApplyPatch for '+Name);
  ApplyPatch:=GetProcAddress(hLibrary,'ApplyPatch');
  if not assigned(ApplyPatch)
    then raise exception.create('Could not call ApplyPatch in '+Filename);
  if not ApplyPatch(GameInfo.hProcess,GameInfo.ProcessID)
    then raise exception.create('Error in ApplyPatch in '+Filename);
end;


procedure TBwl4Plugin.ShowConfig;
var OpenConfig:TOpenConfig;
begin
  OpenConfig:=GetProcAddress(hLibrary,'OpenConfig');
  if not assigned(OpenConfig)
    then raise exception.create('Could not call OpenConfig in '+Filename);
  if not OpenConfig()
    then raise exception.create('Error in OpenConfig in '+Filename);
end;

end.
