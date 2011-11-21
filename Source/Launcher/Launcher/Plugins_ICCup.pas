unit Plugins_ICCup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,plugins_bwl,util,logger,plugins,idhttp,dcpmd5,update,inifiles,registry,rtlconsts,plugins_bwl4;

type
  TICCupConfigForm = class(TForm)
    LanLatency: TCheckBox;
    OK: TButton;
    Cancel: TButton;
    GatewayRegister: TButton;
    procedure CancelClick(Sender: TObject);
    procedure OKClick(Sender: TObject);
    procedure Save();
    procedure Load();
    procedure UpdateGateway();
    procedure FormCreate(Sender: TObject);
    procedure GatewayRegisterClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

Type TIccPlugin=class(TBwl4Plugin)
  protected
    FUseInternalConfig:boolean;
    function GetCompatible(const Version:TGameVersion):TCompatibility;override;
  public
    class function HandlesFile(const Filename,Ext: String):boolean;override;
    procedure ScSuspended;override;
    procedure ShowConfig;override;
    procedure CheckForUpdates(AUpdater:TUpdater;var desc:String);override;
    constructor Create(const AFilename:String);override;
end;

type TIccLadder=class(TLadder)
  protected
    FPlugin:TIccPlugin;
  public
    procedure GetPluginCompatible(var Compatibility:TCompatibility;const Version:TGameVersion;const PluginInfo:TPlugin);override;
    function GetGameCompatible(const Version:TGameVersion): boolean;override;
    constructor Create(APlugin:TIccPlugin);
end;

implementation
uses versions;

{$R *.dfm}

const ICCupGatewayName='The Abyss (ICCup)';
      ICCupGatewayServer='sc.theabyss.ru';
      ICCupGatewayTimezone=3;

procedure Reg_ReadMultiLine(Reg:TRegistry;const Name:String;Data:TStrings);
var S:String;
    i:integer;
    size:integer;
begin
  Data.clear;
  size:=reg.GetDataSize(Name);
  if size<=0 then exit;
  setlength(S,size);
  reg.ReadBinaryData(Name,S[1],length(S));
  delete(s,length(s),1);//Make terminating double #0 a single #0
  while s<>'' do
   begin
    i:=pos(#0,s);
    if i=0 then i:=length(s);
    Data.Add(copy(S,1,i-1));
    delete(S,1,i);
   end;
end;

procedure Reg_WriteMultiLine(Reg:TRegistry;const Name:String;Data:TStrings);
var S:String;
    i:integer;
begin
  for i := 0 to Data.Count-1 do
    S:=S+Data[i]+#0;
  S:=S+#0;//Terminating doube #0
  if RegSetValueEx(Reg.CurrentKey, PChar(Name), 0, REG_MULTI_SZ, @S[1],length(S)) <> ERROR_SUCCESS
    then raise ERegistryException.CreateResFmt(@SRegSetDataFailed, [Name]);
end;

procedure AddGateWay(const Name,Server:String;Timezone:integer);
var Reg:TRegistry;
    SL:TStringlist;
begin
 reg:=nil;
 sl:=nil;
 try
   reg:=TRegistry.create;
   sl:=TStringlist.create;
   reg.RootKey:=HKey_Current_User;
   reg.OpenKey('Software\Battle.net\Configuration',true);
   reg_ReadMultiLine(Reg,'Battle.net gateways',sl);
   sl.insert(2,Server);
   sl.insert(3,inttostr(Timezone));
   sl.insert(4,Name);
   reg_WriteMultiLine(Reg,'Battle.net gateways',sl);
 finally
   reg.free;
   sl.free;
 end;
end;

function IsGatewayRegistered(const NameOrServer:String):boolean;
var Reg:TRegistry;
    SL:TStringlist;
    i:integer;
begin
 reg:=nil;
 sl:=nil;
 result:=false;
 try
   reg:=TRegistry.create;
   sl:=TStringlist.create;
   reg.RootKey:=HKey_Current_User;
   reg.OpenKey('Software\Battle.net\Configuration',true);
   reg_ReadMultiLine(Reg,'Battle.net gateways',sl);
   for I := 2 to sl.count - 1 do
    if sl[i]=NameOrServer then result:=true;
 finally
   reg.free;
   sl.free;
 end;
end;

procedure RemoveGateway(const NameOrServer:String);
var Reg:TRegistry;
    SL:TStringlist;
    i,gatewaystart:integer;
begin
 reg:=nil;
 sl:=nil;
 try
   reg:=TRegistry.create;
   sl:=TStringlist.create;
   reg.RootKey:=HKey_Current_User;
   reg.OpenKey('Software\Battle.net\Configuration',true);
   reg_ReadMultiLine(Reg,'Battle.net gateways',sl);
   for i:=sl.count - 1 downto 2 do
    if lowercase(sl[i])=lowercase(NameOrServer)
     then begin
      gatewaystart:=i-(i-2) mod 3;
      sl.Delete(gatewaystart);
      sl.Delete(gatewaystart);
      sl.Delete(gatewaystart);
     end;
   reg_WriteMultiLine(Reg,'Battle.net gateways',sl);
 finally
   reg.free;
   sl.free;
 end;
end;


procedure TICCupConfigForm.CancelClick(Sender: TObject);
begin
  close;
end;

procedure TICCupConfigForm.FormCreate(Sender: TObject);
begin
  Load;
  UpdateGateway;
end;

procedure TICCupConfigForm.GatewayRegisterClick(Sender: TObject);
begin
  if IsGatewayRegistered(ICCupGatewayServer)
    then RemoveGateway(ICCupGatewayServer)
    else AddGateWay(ICCupGatewayName,ICCupGatewayServer,ICCupGatewayTimezone);
  UpdateGateway;
end;

procedure TICCupConfigForm.Load;
var ini:TInifile;
begin
  ini:=nil;
  try
    ini:=TInifile.create(extractfilepath(paramstr(0))+'iccup.ini');
    LanLatency.checked:=Ini.ReadBool('ICC', 'LL', True);
  finally
    ini.free;
  end;
end;

procedure TICCupConfigForm.OKClick(Sender: TObject);
begin
  Save;
  close;
end;

procedure TICCupConfigForm.Save;
var ini:TInifile;
begin
  ini:=nil;
  try
    ini:=TInifile.create(extractfilepath(paramstr(0))+'iccup.ini');
    Ini.WriteBool('ICC', 'LL', LanLatency.checked);
  finally
    ini.free;
  end;
end;


procedure TICCupConfigForm.UpdateGateway;
begin
  if IsGatewayRegistered(ICCupGatewayServer)
    then GatewayRegister.Caption:='Remove Gateway'
    else GatewayRegister.Caption:='Add Gateway';
end;

{ TIccPlugin }

procedure TIccPlugin.CheckForUpdates(AUpdater: TUpdater; var desc: String);
var http:TIdHttp;
    sl:TStringlist;
    newversion:TVersion;
begin
  Log('Update ICCup Antihack');
  sl:=nil;
  http:=nil;
  try
    http:=TIdHttp.create;
    http.ConnectTimeout:=2000;
    sl:=TStringlist.create;
    try
      sl.text:=http.get('http://www.iccup.com/launcher/Update.info');
    except
      on e:exception do
      begin
        LogException(e,'TIccPlugin.CheckForUpdates http.get(Update.info)');
        exit;
      end;
    end;
    newversion:=ParseVersion(sl.Values['#version']);
    if CompareVersions(newversion,Version)=0 then exit;
    Log('Update needed');
    desc:=desc+#13#10+'ICCup Antihack';
    desc:=desc+#13#10+VersionToStr(Version)+' -> '+VersionToStr(NewVersion);
    AUpdater.AddFile(Filename,'http://www.iccup.com/launcher/iccscbn.icc');
  finally
    sl.Free;
    http.Free;
  end;
end;

function TIccPlugin.GetCompatible(const Version:TGameVersion):TCompatibility;
var AVersion:TGameVersion;
begin
  AVersion:=Version;
  //Hack for Icc 1.3.0.79
  if (FVersion[0]=1)and
     (FVersion[1]=3)and
     (FVersion[2]=0)and
     (FVersion[3]=79)
   then AVersion.Version:='1.15.2';
  result:=inherited GetCompatible(AVersion);
  if not(lowercase(extractfilename(Version.Filename))='starcraft.exe')then result:=coIncompatible;
  if not (Version.Ladder is TIccLadder) then result:=coForbidden;
  if result=coCompatible then result:=coRequired;
end;

class function TIccPlugin.HandlesFile(const Filename, Ext: String): boolean;
begin
  result:=lowercase(extractfilename(Filename))='iccscbn.icc'
end;

constructor TIccPlugin.Create(const AFilename: String);
begin
  inherited;
  FUseInternalConfig:=FHasConfig;
  FHasConfig:=true;
  AddLadder(TIccLadder.create(self));
  if (FVersion[0]=0)and
     (FVersion[1]=0)and
     (FVersion[2]=0)and
     (FVersion[3]=0)
   then begin
     FVersion[0]:=1;
     FVersion[1]:=2;
     FVersion[2]:=0;
     FVersion[3]:=38;
   end;
end;

procedure TIccPlugin.ScSuspended;
begin
  if not IsGatewayRegistered(ICCupGatewayServer)
    then raise exception.create('ICCup-Gateway not available. Add it in the settings of the ICCup-Plugin');
  inherited;
end;

procedure TIccPlugin.ShowConfig;
var Form:TICCupConfigForm;
begin
  if FUseInternalConfig
    then inherited
    else begin
      Form:=nil;
      try
        Form:=TICCupConfigForm.create(nil);
        Form.ShowModal;
      finally
        Form.Free;
      end;
    end;
end;

{ TIccLadder }

constructor TIccLadder.Create;
begin
  FName:='ICCup';
  FPlugin:=APlugin;
end;

function TIccLadder.GetGameCompatible(const Version:TGameVersion): boolean;
var Version2:TGameVersion;
begin
  Version2:=Version;
  Version2.Ladder:=self;
  result:=FPlugin.GetCompatible(version2)>=coCompatible;
end;

procedure TIccLadder.GetPluginCompatible(var Compatibility: TCompatibility;
  const Version:TGameVersion; const PluginInfo: TPlugin);
begin
  inherited;
  if (lowercase(extractfilename(PluginInfo.Filename))<>'iccscbn.icc')and
     (lowercase(extractfilename(PluginInfo.Filename))<>'chaosplugin.bwl')and
     (lowercase(extractfilename(PluginInfo.Filename))<>'cpusavior.bwl')and
     (lowercase(extractfilename(PluginInfo.Filename))<>'wmode.bwl')
   then Compatibility:=coForbidden;
end;

end.
