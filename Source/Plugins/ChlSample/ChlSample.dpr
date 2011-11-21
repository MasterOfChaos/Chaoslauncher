library ChlSample;
var ChaosAPI:TChaosAPI;
    Plugin:TObjHandle;
    Module:TObjHandle;
    ProcessHandle:THandle;
procedure Config(UserData:pointer);stdcall;
begin
  //show config here
end;

procedure Compatible(UserData:pointer;var Compatibility:TCompatibility);stdcall;
var Version:TVersion;
begin 
  //return 4 for always on/required, don't use this setting without a good cause 
  //return 3 for fully compatible 
  //return 2 for partially compatible 
  //return 1 for incompatible 
  //return 0 for forbidden, don't use this setting without a good cause 
  //Normally you can ignore the Ladder-Param, usefull for plugins which only work on a certain ladder
  ChaosAPI.GetVersion(GameHandle,'Version',Version);
  if (Version[0]=1)and(Version[1]=15)and(Version[2]=2)) 
    then Compatibility:=coCompatible;//Fully compatible with 1.15.2
    else Compatibility:=coIncompatible;//incompatible with all other versions 
end;

procedure Start(UserData:pointer);
begin
  //Game has just started, called in launcher process
  ChaosApi.OpenSysHandle(GameHandle,'ProcessHandle',ProcessHandle);
end;

procedure Stop(UserData:pointer);
begin
  //Game has terminated, called in launcher process
  CloseHandle(ProcessHandle);
  ProcessHandle:=nil;
end;

function Chl1_Load(ModuleHandle:TObjHandle):BOOL;
begin
  result:=false;
  ChaosAPI:=AChaosAPI;
  Module:=ChaosApi.ModuleHandle;
  
  //Check Compatibility with launcher
  if (ChaosAPI.ApiMajor<>RequiredApiMajor)or(ChaosAPI.ApiMinor<RequiredApiMajor)
    then begin
      Log(ModuleName,liError,'Incompatible API, expected '+intostr(RequiredApiMajor)+'.'+RequiredApiMinor);
      exit;
    end;
  if ChaosAPI.StructSize<sizeof(TChaosAPI)
    then begin
      Log(ModuleName,liError,'ChaosAPI struct too small, expected '+inttostr(sizeof(TChaosAPI)));
      exit;
    end;
  if ChaosAPI.GameID<>'Starcraft'
    then begin
      Log(ModuleName,liError,'This is a plugin for Starcraft');
      exit;
    end;
  //Set module info
  ChaosApi.SetStr(Module,'UpdateUrl','bwl:http://yoursite/sampleplugin');//Url of the updates. Use bwl prefix to use the same updateformat as bwl-plugins
  ChaosApi.SetStr(Module,'ChlSample');
  
  //Register a plugin
  Plugin:=ChaosApi.Create('Plugin');
  ChaosApi.SetStr(Plugin,'Name','ChaosSamplePlugin');//Name defaults to VersionInfo.ProductName
  ChaosApi.SetStr(Plugin,'Author','PluginMaker');//Author defaults to VersionInfo.Company
  ChaosApi.SetStr(Plugin,'Description','Boring plugin which does nothing :(');//Description defaults to VersionInfo.Description
  ChaosApi.SetInt(Plugin,'BanRisk',brLow);//Probability of ban resulting from plugin usage
  ChaosApi.SetBool(Plugin,'IndependentModule',false);//Continues working after launcher terminates 
  ChaosApi.SetBool(Plugin,'NeedsInjection',false);//Should the launcher inject the plugin? 
  ChaosApi.SetBool(Plugin,'AllowLateActivation',false);//Allow late execution when the game already runs 
  ChaosApi.SetBool(Plugin,'NonHooking',true);//Hooks no the game functions, be carefull in conjunction with RegisterCallback, as that can add hooks too 
  ChaosApi.SetBool(Plugin,'GivesAdvantage',false);//For plugins like BWCoach, also makes the plugin incompatible with ICCup etc 
  ChaosApi.SetEvent(Plugin,'OnConfig',Config,nil);//Function which shows the Config
  ChaosApi.SetEvent(Plugin,'OnIsCompatible',Compatible,nil);//function which checks if the plugin is compatible 
  ChaosApi.SetEvent(Plugin,'OnStart',Start,nil);//called after the game process is created
  ChaosApi.SetEvent(Plugin,'OnStop',Stop,nil);//called after the game process has terminated

  result:=true;
end;