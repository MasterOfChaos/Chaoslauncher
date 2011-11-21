unit Plugins;

interface
uses windows,sysutils;
type
 TBWL_ExchangeData=packed record
   PluginAPI:integer;
   StarCraftBuild:integer;
   NotSCBWmodule:BOOL;                //Inform user that closing BWL will shut down your plugin
   ConfigDialog:BOOL;                 //Is Configurable
  end;
Type TGetPluginAPI_Proc=procedure (var Data:TBWL_Exchangedata);cdecl;

Type TPlugin=class
  Name:String;
  Path:String;
  StarCraftBuild:integer;
  ConfigDialog:Boolean;
  Handle:Cardinal;
  GetPluginAPI:TGetPluginAPI_Proc;
end;
type TLauncher=class
  StarcraftExe:String;
  StarCraftBuild:integer;
  function AddPlugin(const Path:String):boolean;
  procedure Launch;
end;

implementation
{ TLauncher }

function TLauncher.AddPlugin(const Path: String): boolean;
var Plugin:TPlugin;
begin
  Plugin:=TPlugin.create;
  try
    Plugin.Path:=Path;
    Plugin.Handle:=LoadLibrary(PChar(Path));
    if Plugin.Handle=0 then raise exception.create('LoadLibrary on "'+Path+'" failed');
    GetProcAddress(Plugin.Handle,'GetPluginAPI');
  except
    FreeLibrary(Plugin.Handle);
    Plugin.free;
  end;
end;

procedure TLauncher.Launch;
var info:TProcessInformation;
begin
  if not CreateProcess(
      PChar(StarcraftExe),//Exe
      nil,  //CmdLine
      nil,  //ProcessAttributes
      nil,  //ThreadAttributes
      false,//InheritHandles
      CREATE_SUSPENDED,//CreationFlags
      nil,  //Environment
      PChar(ExtractFilePath(StarcraftExe)),//Path
      nil,  //StartupInfo
      @info)//ProcessInfo
    then raise exception.create('Could not launch Starcraft');

end;

end.
