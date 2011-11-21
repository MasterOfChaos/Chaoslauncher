unit PluginAPI;

interface
uses windows,classes,sysutils,logger,versions;
type TPluginInfo=record
  StarcraftBuild: Integer;
  StarcraftVersion:String;
  Name:String;
  Description:String;
  BwlUpdateUrl:String;
  PublicKey:String;
  Config:TProcedure;
  ApplyPatchSuspendend:TProcedure;
  ApplyPatch:TProcedure;
  Version:TVersion;
  SelfInject:boolean;
  function GetVersionString:String;
 end;
var PluginInfo:TPluginInfo;


var LoadInfo:record
  LauncherApiMajor:Word;//Major version of LauncherAPI, Must be equal to expected version
  LauncherApiMinor:Word;//Minor version of LauncherAPI, Must more or equal than the expected version 
  LauncherExecutable:String;//Absolute Path to Launcher including Filename
  LauncherPath:String;//Absolute Path to launcher
  PluginExecutable:String;//Absolute Path to Plugin including Filename
  PluginPath:String;//Absolute Path to Plugin
  GamePath:String;//Absolute Path to Starcraft
 end;

var Game:record
  Executable:String;//Absolute Path to Starcraft including Filename
  //GameVersion:TVersion;//executed Game Version
  ProcessID:Cardinal;//Process ID of the game
  ProcessHandle:THandle;//Plugin is responsable for closing the handle!!!
  MainThreadID:Cardinal;//ThreadID of MainThread of the game
  MainThreadHandle:THandle;//Plugin is responsable for closing the handle!!!
 end;

{
  STARCRAFTBUILD
      0 - 1.04
      1 - 1.08b
      2 - 1.09b
      3 - 1.10
      4 - 1.11b
      5 - 1.12b
      6 - 1.13f
      7 - 1.14
      8 - 1.15
      9 - 1.15.1
     10 - 1.15.2
     11 - 1.15.3
}

function IsInjected:boolean;


implementation
uses util;

function OpenConfig:BOOL;cdecl;forward;

//Actually, we dont want any other plugins :P (Ashur) -- Ashur is crazy :P (tec27)
function BWLIsPlugin: Bool; cdecl;
begin
  Result := True; // Pretty good idea to return true, I think ;)
end;

//Name of a plugin, be kind and use "??? for xxx" where xxx is proper SCBW version (Ashur)
procedure BWLGetName(text: PChar); cdecl;
begin
  StrPCopy(text,PluginInfo.Name);
end;

//Sexy description (Ashur)
procedure BWLGetDescription(text: PChar); cdecl;
begin
  StrPCopy(text,PluginInfo.Description);
end;

//Version of the plugin is... (Ashur)
function BWLGetBuildversion: Integer; cdecl;
begin
  Result := PluginInfo.Version[0]shl 24+PluginInfo.Version[1]shl 16+PluginInfo.Version[2]shl 8+PluginInfo.Version[3];
end;

//Its for which version of starcraft? (Ashur)
function BWLGetStarcraftBuild: Integer; cdecl;
begin
  Result := 7;//7 because bwl3 does not know anything newer
end;

//Can someone click configure? (Ashur)
function BWLCanOpenConfigDialog: longbool; cdecl;
begin
  Result := assigned(PluginInfo.Config);
end;

//If Someone clicks "Configure" (Ashur)
procedure BWLOpenConfigDialog; cdecl;
begin
  OpenConfig;
end;

//If someone checks your plugin (Ashur)
function BWLOnPluginCheck: longbool; cdecl;
begin
  Result := True;
end;

//If someone unchecks your plugin (Ashur)
function BWLOnPluginUnCheck: longbool; cdecl;
begin
  Result := True;
end;

//You will like this func the most (Ashur)
function BWLApplyPatch(hProcess: THandle): bool; cdecl;
begin
 Game.ProcessHandle:=hprocess;
 if assigned(PluginInfo.ApplyPatch)
   then PluginInfo.ApplyPatch;
 Result := true; //NOTHING IS BAD (Ashur)
end;

//This is not a big deal, leave return TRUE (Ashur)
function BWLOnPluginLoad: longbool; cdecl;
begin
  Result := True;
end;

//Loads before window create (Ashur)
function BWLIsLoadTimePlugin: longbool; cdecl;
begin
  Result := True;
end;

type
 TBWL_ExchangeData=packed record
   PluginAPI:integer;
   StarCraftBuild:integer;
   NotSCBWmodule:BOOL;                //Inform user that closing BWL will shut down your plugin
   ConfigDialog:BOOL;                 //Is Configurable
  end;
//
//GET Functions for BWLauncher
//
//
procedure GetPluginAPI(var Data:TBWL_Exchangedata);cdecl;
begin
   //BWL Gets version from Resource - VersionInfo
   Data.PluginAPI := 4; //BWL 4
   Data.StarCraftBuild := PluginInfo.StarcraftBuild;
   Data.ConfigDialog := assigned(PluginInfo.Config);
   Data.NotSCBWmodule := true;
end;

procedure GetData(Name,Description,UpdateUrl:Pchar);cdecl;
begin
   //if necessary you can add Initialize function here
   //possibly check CurrentCulture (CultureInfo) to localize your DLL due to system settings
   StrPCopy(name, PluginInfo.Name);
   StrPCopy(description, PluginInfo.Description);
   StrPCopy(updateurl, PluginInfo.BwlUpdateUrl);
end;


//
//Functions called by BWLauncher
//
//
function OpenConfig():BOOL;cdecl;
begin
   //If you set "Data.bConfigDialog = true;" at function GetPluginAPI then
   //BWLauncher will call this function if user clicks Config button

   //Youll need to make your own Window here
   result:=false;
   if not assigned(PluginInfo.Config) then exit;
   try
     PluginInfo.Config;
     result:=true;
   except
     on e:exception do
       begin
        MessageBox(0,PChar('Exception in PluginConfig '+e.classname+' '+e.Message),'Exception',MB_OK or MB_ICONERROR);
        Log('Exception in PluginConfig '+e.classname+' '+e.Message);
       end;
   end;
end;

function ApplyPatchSuspended(hProcess:THandle;ProcessID:Cardinal):BOOL;cdecl;
begin
   //This function is called on suspended process
   //Durning the suspended process some modules of starcraft.exe may not yet exist.
   Game.ProcessHandle:=hprocess;
   Game.ProcessID:=ProcessID;
   if assigned(PluginInfo.ApplyPatchSuspendend)
     then PluginInfo.ApplyPatchSuspendend;
   result:=true; //everything OK

   //return false; //something went wrong
end;

function ApplyPatch(hProcess:THandle; ProcessID:Cardinal):BOOL;cdecl;
begin
   //This fuction is called after
   //ResumeThread(pi.hThread);
   //WaitForInputIdle(pi.hProcess, SomeTime);
   if assigned(PluginInfo.ApplyPatch)
     then PluginInfo.ApplyPatch;
   result:=true; //everything OK

   //return false; //something went wrong
end;

procedure GetSigPublicKey(AMethod,APublicKey:PChar);cdecl;
begin
  StrPCopy(AMethod,'rsa1024:sha1');
  StrPCopy(APublicKey,PluginInfo.PublicKey);
end;

exports
  //BWL Version 3
  BWLIsPlugin,
  BWLGetName,
  BWLGetDescription,
  BWLGetBuildversion,
  BWLGetStarcraftBuild,
  BWLCanOpenConfigDialog,
  BWLOpenConfigDialog,
  BWLOnPluginCheck,
  BWLOnPluginUnCheck,
  BWLApplyPatch,
  BWLOnPluginLoad,
  BWLIsLoadTimePlugin,
  //BWL Version 4
  GetPluginAPI,
  GetData,
  OpenConfig,
  ApplyPatchSuspended,
  ApplyPatch,
  //Chaos Extensions
  GetSigPublicKey;

{ TPluginInfo }

function TPluginInfo.GetVersionString: String;
begin
  result:=VersionToStr(PluginInfo.Version);
end;

function IsInjected:boolean;
begin
  result:=pos('starcraft',lowercase(extractfilename(paramstr(0))))>0;
end;

initialization
  PluginInfo.StarcraftBuild:= 0;
  PluginInfo.StarcraftVersion:='Unknown';
  PluginInfo.Name:=ExtractFileName(GetModuleFileName);
  PluginInfo.Description:='NoDescription';
  GetFileVersionRec(GetModuleFileName,PluginInfo.version);
  PluginInfo.BwlUpdateUrl:='';
  PluginInfo.PublicKey:='';
  PluginInfo.Config:=nil;
  PluginInfo.SelfInject:=false;

  LoadInfo.LauncherApiMajor:=0;//Major version of LauncherAPI, Must be equal to expected version
  LoadInfo.LauncherApiMinor:=0;//Minor version of LauncherAPI, Must more or equal than the expected version
  LoadInfo.LauncherExecutable:='';//Absolute Path to Launcher including Filename
  LoadInfo.LauncherPath:='';//Absolute Path to launcher
  LoadInfo.PluginExecutable:=GetModuleFileName;//Absolute Path to Plugin including Filename
  LoadInfo.PluginPath:=ExtractFilePath(LoadInfo.PluginExecutable);//Absolute Path to Plugin
  LoadInfo.GamePath:='';//Absolute Path to Starcraft
end.
