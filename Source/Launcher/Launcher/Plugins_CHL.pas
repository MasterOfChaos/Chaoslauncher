unit Plugins_CHL;

interface
uses windows,classes,sysutils,update,plugins,versions,util,logger,config;


Type TChlPlugin=class(TPlugin)
{  private
  protected
    hLibrary:HMODULE;
    FUpdateUrl:String;
    FPublicKey:String;
    function GetCompatible(const Version:TGameVersion):TCompatibility;override;
  public
    procedure ShowConfig;override;
    procedure ScSuspended;override;
    constructor Create(const AFilename:String);override;
    destructor Destroy;override;  }
end;

{Type TChlLadder=class(TLadder)
  private
  public
    procedure GetPluginCompatible(var Compatibility:TCompatibility;const FileName:String;const PluginInfo:TPlugin);override;
    function GetGameCompatible(const Version,Filename:String): boolean;override;
    constructor Create(const AName:String;const AGameVersion:String;APluginCompatibilityCheck:TPluginCompatibilityCheckCallback;AUserData:pointer);
end;  }

implementation
const LauncherApiMajor=1;
      LauncherApiMinor=0;
 {

procedure FillLoadInfo(out LoadInfo:TLoadInfo;var LoadInfoStrings:TLoadInfoStrings;Plugin:TChlPlugin);
begin
  fillchar(LoadInfo,sizeof(LoadInfo),0);
  LoadInfo.StructSize:=sizeof(LoadInfo);
  LoadInfo.LauncherApiMajor:=LauncherApiMajor;
  LoadInfo.LauncherApiMinor:=LauncherApiMinor;

  LoadInfoStrings.LauncherExecutable:=paramstr(0);
  LoadInfoStrings.LauncherPath:=extractfilepath(paramstr(0));
  LoadInfoStrings.PluginExecutable:=Plugin.Filename;
  LoadInfoStrings.PluginPath:=extractfilepath(Plugin.Filename);
  LoadInfoStrings.GamePath:=Settings.ScPath;

  UniqueString(LoadInfoStrings.LauncherExecutable);
  UniqueString(LoadInfoStrings.LauncherPath);
  UniqueString(LoadInfoStrings.PluginExecutable);
  UniqueString(LoadInfoStrings.PluginPath);
  UniqueString(LoadInfoStrings.GamePath);

  LoadInfo.LauncherExecutable:=PChar(LoadInfoStrings.LauncherExecutable);
  LoadInfo.LauncherPath:=PChar(LoadInfoStrings.LauncherPath);
  LoadInfo.PluginExecutable:=PChar(LoadInfoStrings.PluginExecutable);
  LoadInfo.PluginPath:=PChar(LoadInfoStrings.PluginPath);
  LoadInfo.GamePath:=PChar(LoadInfoStrings.GamePath);
  LoadInfo.AddLadderFunc:=nil;
end;



procedure PreparePluginInfo(out PluginInfo:TPluginInfo;var PluginInfoStrings:TPluginInfoStrings;Plugin:TChlPlugin);
begin
  fillchar(PluginInfo,Sizeof(PluginInfo),0);
  PluginInfo.StructSize:=sizeof(PluginInfo);
  PluginInfo.Version:=Plugin.Version;//RW, Auto prefilled from Versioninfo-Ressource
  PluginInfo.BanRisk:=-1;//RW, 0=low(no injection),1=medium(injection but no hooks or hooks outside Game-Code),2=high(hooks),-1 Unknown
  PluginInfo.IndependentModule:=false;//RW, Continues working after launcher terminates
  PluginInfo.NeedsInjection:=false;//RW,Should the launcher inject the plugin?
  PluginInfo.AllowLateActivation:=true;//RW, Allow late execution when Starcraft already runs
  PluginInfo.NonHooking:=False;//RW, Hooks no starcraft functions, be carefull in conjunction with RegisterCallback, as that can add hooks too
  PluginInfo.GivesAdvantage:=false;//RW, For plugins like BWCoach, also makes the plugin incompatible with ICCup etc
  PluginInfo.HasConfig:=false;//RW, Plugin has a config

  PluginInfoStrings.VersionName:=VersionToStr(PluginInfo.Version);
  PluginInfoStrings.Author:=Plugin.Author;
  PluginInfoStrings.Description:=Plugin.Description;
  PluginInfoStrings.PluginName:=Plugin.Name;
  PluginInfoStrings.UpdateUrl:=#0;
  PluginInfoStrings.PublicKey:=#0;
  setlength(PluginInfoStrings.PluginName,256+1);//RW, 256 bytes Memory
  setlength(PluginInfoStrings.VersionName,256+1);//RW, 256 bytes Memory, Auto prefilled from Versioninfo-Ressource
  setlength(PluginInfoStrings.Author,256+1);//RW, 256 bytes Memory
  setlength(PluginInfoStrings.Description,65536+1);//RW, 64k bytes Memory
  setlength(PluginInfoStrings.UpdateUrl,1024+1);//RW, 1024 bytes Memory
  setlength(PluginInfoStrings.PublicKey,2048+1);//RW, 2048 bytes Memory
end;
                      }
initialization
end.
