unit Plugins_DLL;

interface
uses windows,sysutils,classes,util,plugins,update,inifiles;
Type TInjPlugin=class(TPlugin)
  protected
    FScVersion:String;
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
uses Inject_RemoteThread,versions;

{ TDllPlugin }

procedure TInjPlugin.CheckForUpdates(AUpdater: TUpdater;var desc:String);
begin

end;

function TInjPlugin.GetCompatible(const Version:TGameVersion):TCompatibility;
begin
  if (version.version=FScVersion)or(lowercase(FScVersion)='all')
    then result:=coCompatible
    else result:=coIncompatible;
  if FScVersion='' then result:=coUnknown;
end;

class function TInjPlugin.HandlesFile(const Filename, Ext: String): boolean;
begin
  result:=ext='.inj';
end;

constructor TInjPlugin.Create(const AFilename: String);
var ini:TInifile;
begin
  inherited;
  ini:=nil;
  try
    GetInfoFromVersioninfo(changefileext(AFilename,'.dll'));
    ini:=Tinifile.create(AFilename);
    FDescription:=ini.ReadString('Plugin','Description',FDescription);
    FName:=ini.ReadString('Plugin','Name',FName);
    FAuthor:=ini.ReadString('Plugin','Author',FAuthor);
    FVersion:=ParseVersion(ini.ReadString('Plugin','Version',VersionToStr(FVersion)));
    FScVersion:=ini.ReadString('Plugin','ScVersion','');
  finally
    ini.free;
  end;
end;

destructor TInjPlugin.Destroy;
begin

  inherited;
end;

procedure TInjPlugin.ScSuspended;
begin
  inherited;

end;

procedure TInjPlugin.ScWindowCreated;
begin
  inherited;
  InjectDll_RemoteThread(GameInfo.hProcess,changefileext(FFilename,'.dll'));
end;

procedure TInjPlugin.ShowConfig;
begin
  inherited;

end;

end.
