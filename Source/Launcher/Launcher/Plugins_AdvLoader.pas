unit Plugins_AdvLoader;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,update,plugins, ExtCtrls,StdCtrls,inifiles,spin,registry,util,filectrl,Launcher_Game;

Type
TAdvLoaderConfig=class;

TAdvLoaderProperty=class
  public
    PropertyType:integer;
    Desc:String;
    Name:String;
    function ToString:String;virtual;abstract;
    procedure FromString(S:String);virtual;abstract;
    constructor create(ini:TIniFile; Form:TAdvLoaderConfig;const Name:String);virtual;
end;

TAdvLoaderPlugin=class(TPlugin)
  protected
    procedure SetEnabled(const Value: boolean);override;
  public
    function ConfigFile:String;virtual;abstract;
    procedure LoadEnabled;override;
    procedure CheckForUpdates(AUpdater:TUpdater;var desc:String);override;
    procedure ShowConfig;override;
    procedure ScSuspended;override;
    procedure ScWindowCreated;override;
    constructor Create(const AFilename:String);override;
end;

TAdvLoaderPlugin1=class(TAdvLoaderPlugin)
  protected
    function GetCompatible(const Version:TGameVersion):TCompatibility;override;
  public
    function ConfigFile:String;override;
    constructor Create(const AFilename:String);override;
    class function HandlesFile(const Filename,Ext: String):boolean;override;
end;

TAdvLoaderPlugin2=class(TAdvLoaderPlugin)
  protected
    function GetCompatible(const Version:TGameVersion):TCompatibility;override;
  public
    function ConfigFile:String;override;
    constructor Create(const AFilename:String);override;
    class function HandlesFile(const Filename,Ext: String):boolean;override;
end;

  TAdvLoaderConfig = class(TForm)
    PropertyPanel: TPanel;
    ButtonPanel: TPanel;
    OK: TButton;
    Cancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure OkClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    Plugin:TAdvLoaderPlugin;
    Position:integer;
    Properties:array of TAdvLoaderProperty;
    procedure UpdatePosition(Control:TControl);
 end;

procedure InjectAdvLoader;
function AdvPluginPath:String;
function AdvPath:String;

implementation
uses config,inject_remotethread,versions;
{$R *.dfm}

type TAdvPluginInfo=packed record
  Lang:PChar;
  Key:PChar;
  Value:PChar;
 end;
type PAdvPluginInfo=^TAdvPluginInfo;
     TPluginInfoProc=function:PAdvPluginInfo;

function GetAdvPluginList:String;
var reg:TRegistry;
begin
  reg:=nil;
  try
    reg:=TRegistry.create;
    reg.RootKey:=HKey_Local_Machine;
    reg.OpenKeyReadOnly('SOFTWARE\Blizzard Entertainment\Starcraft\AdvLoader');
    setlength(result,10000);
    fillchar(result[1],length(result),0);
    setlength(result,reg.ReadBinaryData('PluginList',result[1],length(result)));
  except
    result:=#0#0;
  end;
  reg.free;
end;

function GetAdvHelperFilename:String;
begin
  result:=AdvPluginPath+'injhlp.dll';
end;

procedure SetAdvPluginList(S:String);
var reg:TRegistry;
begin
  reg:=nil;
  try
    reg:=TRegistry.create;
    reg.RootKey:=HKey_Local_Machine;
    reg.OpenKey('SOFTWARE\Blizzard Entertainment\Starcraft\AdvLoader',true);
    UniqueString(S);
    reg.WriteBinaryData('PluginList',S[1],length(S));
  finally
    reg.free;
  end;
end;

procedure AdvPluginListAdd(var List:String;const Plugin:String);
var i:integer;
begin
  i:=pos(lowercase(Plugin)+#0,lowercase(List));
  if i<>0 then exit;
  delete(List,length(List)-1,2);//Remove #0#0 for termination
  List:=List+Plugin+#0+#0#0;//add #0 for the string and #0#0 for termination
end;

procedure AdvPluginListRemove(var List:String;const Plugin:String);
var i:integer;
begin
  i:=pos(lowercase(Plugin)+#0,lowercase(List));
  if i=0 then exit;
  delete(List,i,length(Plugin)+1);
end;

procedure InjectAdvLoader;
var BackupList,S:String;
    SRec:TSearchRec;
    Error:integer;
    Window:HWND;
    WindowThreadId:Cardinal;
    InjHlp:THandle;
    HookProc:pointer;
    hHook:THandle;
    MsgResult:Cardinal;
begin
  InjHlp:=0;
  hHook:=0;
  MsgResult:=0;
  try
    BackupList:=GetAdvPluginList;
    S:=Backuplist;
    Error:=FindFirst(AdvPluginPath+'*.bwl',faAnyfile and not faDirectory,SRec);
    while Error=0 do
    begin
      AdvPluginListAdd(S,SRec.Name);
      Error:=FindNext(SRec);
    end;
    if (Error<>ERROR_NO_MORE_FILES)and(Error<>ERROR_FILE_NOT_FOUND)
      then raise exception.create('Search for AdvLoader .bwl plugins failed '+GetErrorString(Error));
    SetAdvPluginList(S);
    InjectDll_RemoteThread(GameInfo.hProcess,GetAdvHelperFilename);
    {Window:=FindWindow('SWarClass',nil);
    if window=0
      then raise exception.create('Starcraft not found '+GetLastErrorString);
    WindowThreadId := GetWindowThreadProcessId(window,nil);
    InjHlp:=LoadLibrary(PChar(GetAdvHelperFilename));
    if InjHlp=0 then raise exception.create('Could not load injectionhelper '+GetLastErrorString);
    HookProc := GetProcAddress(InjHlp,'_GetMsgProc@12');
    if HookProc=nil then raise exception.create('Could find _GetMsgProc in InjHlp.dll '+GetLastErrorString);
    hHook:=SetWindowsHookEx(WH_GETMESSAGE,HookProc,InjHlp,WindowThreadId);
    if hHook=0
      then raise exception.create('Could not add hook '+GetLastErrorString);
    if InjHlp<>0
     then begin
      freelibrary(InjHlp);
      InjHlp:=0;
     end;
    if SendMessageTimeout( Window,WM_NULL,0,0,0,10000,MsgResult)=0
      then raise exception.create('Starcraft did not react to message in time '+GetLastErrorString);}
  finally
    if InjHlp<>0 then freelibrary(InjHlp);
    SetAdvPluginList(BackupList);
  end;
end;

{ TAdvLoaderPlugin }

procedure TAdvLoaderPlugin.CheckForUpdates(AUpdater: TUpdater;var desc:String);
begin
  inherited;

end;

constructor TAdvLoaderPlugin.Create(const AFilename: String);
begin
  inherited;
  FName:=stringreplace(changefileext(Extractfilename(AFilename),''),'_',' ',[rfReplaceAll]);
  FHasConfig:=fileexists(Configfile)and (GetFileSize(Configfile)>0);
end;

procedure TAdvLoaderPlugin.LoadEnabled;
begin
  FEnabled:=pos(lowercase(extractfilename(filename)),lowercase(GetAdvPluginlist))=0;
end;

procedure TAdvLoaderPlugin.ScSuspended;
begin
  inherited;

end;

procedure TAdvLoaderPlugin.ScWindowCreated;
begin
  inherited;

end;

procedure TAdvLoaderPlugin.SetEnabled(const Value: boolean);
var S,f:String;
begin
  FEnabled:=Value;
  S:=GetAdvPluginList;
  f:=extractfilename(Filename);
  if enabled
    then AdvPluginListRemove(s,f)
    else AdvPluginListAdd(s,f);
  SetAdvPluginList(S)
end;

procedure TAdvLoaderPlugin.ShowConfig;
var Form:TAdvLoaderConfig;
begin
  Form:=nil;
  try
    Form:=TAdvLoaderConfig.create(nil);
    Form.Plugin:=self;
    Form.ShowModal;
  finally
    Form.free;
  end;
end;

Type TAdvLoaderIntegerProperty=class(TAdvLoaderProperty)
  public
    spinedit:TSpinEdit;
    function ToString:String;override;
    procedure FromString(S:String);override;
    constructor create(ini:TIniFile; Form:TAdvLoaderConfig;const Name:String);override;
end;

Type TAdvLoaderStringProperty=class(TAdvLoaderProperty)
  public
    edit:TEdit;
    function ToString:String;override;
    procedure FromString(S:String);override;
    constructor create(ini:TIniFile; Form:TAdvLoaderConfig;const Name:String);override;
end;

Type TAdvLoaderBooleanProperty=class(TAdvLoaderProperty)
  public
    Check:TCheckbox;
    function ToString:String;override;
    procedure FromString(S:String);override;
    constructor create(ini:TIniFile; Form:TAdvLoaderConfig;const Name:String);override;
end;

Type TAdvLoaderFilenameProperty=class(TAdvLoaderProperty)
  public
    edit:TEdit;
    button:TButton;
    Filter:String;
    procedure ShowFileDialog(Sender: TObject);
    procedure ShowDirectoryDialog(Sender: TObject);
    function ToString:String;override;
    procedure FromString(S:String);override;
    constructor create(ini:TIniFile; Form:TAdvLoaderConfig;const Name:String);override;
end;

{ TAdvLoaderConfig }

procedure TAdvLoaderConfig.OkClick(Sender: TObject);
var i:integer;
    ini:TInifile;
begin
  ini:=nil;
  try
    ini:=TInifile.Create(changefileext(Plugin.Filename,'.ini'));
    for i:=0 to length(Properties)-1do
      ini.writestring('Main',properties[i].Name,Properties[i].ToString);
  finally
    ini.free;
  end;
end;

procedure TAdvLoaderConfig.FormShow(Sender: TObject);
var ini:TInifile;
    props:TStringlist;
    i:integer;
    PropType:integer;
    Prop:TAdvLoaderProperty;
begin
  ini:=nil;
  props:=nil;
  Position:=8;
  Prop:=nil;
  Caption:=Plugin.Name+'-Config';
  try
    props:=TStringlist.create;
    ini:=TInifile.Create(Plugin.ConfigFile);
    ini.ReadSection('Main',props);
    for i := 0 to props.Count-1 do
     begin
       PropType:=ini.ReadInteger(props[i],'type',-1);
       case PropType of
         -1:raise exception.create('No type given for '+props[i]);
         0:Prop:=TAdvLoaderIntegerProperty.create(ini,self,props[i]);
         1:Prop:=TAdvLoaderBooleanProperty.create(ini,self,props[i]);
         2:Prop:=TAdvLoaderFilenameProperty.create(ini,self,props[i]);
         else raise exception.create('Unkown type '+inttostr(PropType)+' for '+props[i]);
       end;
       setlength(Properties,length(Properties)+1);
       Properties[high(Properties)]:=Prop;
       Prop.FromString(ini.ReadString('Main',props[i],''));
       inc(Position,4);
     end;
    PropertyPanel.height:=Position;
  finally
    props.free;
    ini.Free;
  end;
end;

procedure TAdvLoaderConfig.UpdatePosition(Control: TControl);
begin
  Position:=Control.Top+Control.Height+4;
end;

{ TAdvLoaderProperty }

constructor TAdvLoaderProperty.create(ini: TIniFile; Form:TAdvLoaderConfig; const Name: String);
begin
  self.Name:=Name;
  PropertyType:=ini.ReadInteger(Name,'type',-1);
  Desc:=ini.ReadString(Name,'Description_ENG',Name);
end;

{ TAdvLoaderIntegerProperty }

constructor TAdvLoaderIntegerProperty.create(ini: TIniFile;
  Form: TAdvLoaderConfig; const Name: String);
var Lab:TLabel;
begin
  inherited;
  Lab:=TLabel.create(Form);
  Lab.parent:=Form.PropertyPanel;
  Lab.caption:=Desc;
  Lab.Top:=Form.Position;
  Lab.Left:=8;
  Form.UpdatePosition(Lab);
  SpinEdit:=TSpinEdit.create(Form);
  SpinEdit.Parent:=Form.PropertyPanel;
  SpinEdit.Top:=Form.Position;
  SpinEdit.Left:=8;
  SpinEdit.MinValue:=ini.ReadInteger(Name,'min',low(integer));
  SpinEdit.MaxValue:=ini.ReadInteger(Name,'max',high(integer));
  SpinEdit.Increment:=ini.ReadInteger(Name,'inc',1);
  Form.UpdatePosition(SpinEdit);
end;

procedure TAdvLoaderIntegerProperty.FromString(S: String);
begin
  inherited;
  SpinEdit.Value:=strtoint(s);
end;

function TAdvLoaderIntegerProperty.ToString: String;
begin
  result:=inttostr(SpinEdit.Value);
end;

{ TAdvLoaderStringProperty }

constructor TAdvLoaderStringProperty.create(ini: TIniFile;
  Form: TAdvLoaderConfig; const Name: String);
var lab:TLabel;
begin
  inherited;
  Lab:=TLabel.create(Form);
  Lab.parent:=Form.PropertyPanel;
  Lab.caption:=Desc;
  Lab.Top:=Form.Position;
  Lab.Left:=8;
  Form.UpdatePosition(Lab);
  Edit:=TEdit.create(Form);
  Edit.Parent:=Form.PropertyPanel;
  Edit.Top:=Form.Position;
  Edit.Left:=8;
  Form.UpdatePosition(Edit);
end;

procedure TAdvLoaderStringProperty.FromString(S: String);
begin
  edit.text:=S;
end;

function TAdvLoaderStringProperty.ToString: String;
begin
  result:=edit.text;
end;

{ TAdvLoaderBooleanProperty }

constructor TAdvLoaderBooleanProperty.create(ini: TIniFile;
  Form: TAdvLoaderConfig; const Name: String);
begin
  inherited;
  Check:=TCheckbox.create(Form);
  Check.parent:=Form.PropertyPanel;
  Check.caption:=Desc;
  Check.Top:=Form.Position;
  Check.Left:=8;
  Form.UpdatePosition(Check);
end;

procedure TAdvLoaderBooleanProperty.FromString(S: String);
begin
  check.checked:=strtoint(s)>0;
end;

function TAdvLoaderBooleanProperty.ToString: String;
begin
  if check.checked
    then result:='1'
    else result:='0';
end;

{ TAdvLoaderFilenameProperty }

procedure TAdvLoaderFilenameProperty.ShowDirectoryDialog(Sender: TObject);
var dir:String;
begin
  dir:=edit.text;
  if SelectDirectory(Desc,'',dir,[sdNewUI])
    then edit.text:=dir;
end;

procedure TAdvLoaderFilenameProperty.ShowFileDialog(Sender: TObject);
var dlg:TOpenDialog;
begin
  dlg:=nil;
  try
    dlg:=TOpenDialog.Create(nil);
    dlg.FileName:=Edit.Text;
    dlg.InitialDir:=extractfilepath(Edit.Text);
    dlg.Options:=[ofHideReadOnly,ofFileMustExist,ofEnableSizing,ofNoChangeDir];
    dlg.Filter:=Filter+'|All Files(*.*)|*.*';
    if dlg.execute
      then Edit.text:=dlg.FileName;
  finally
    dlg.free;
  end;
end;

constructor TAdvLoaderFilenameProperty.create(ini: TIniFile;
  Form: TAdvLoaderConfig; const Name: String);
var lab:TLabel;
begin
  inherited;
  Lab:=TLabel.create(Form);
  Lab.parent:=Form.PropertyPanel;
  Lab.caption:=Desc;
  Lab.Top:=Form.Position;
  Lab.Left:=8;
  Form.UpdatePosition(Lab);
  Edit:=TEdit.create(Form);
  Edit.Parent:=Form.PropertyPanel;
  Edit.Top:=Form.Position;
  Edit.Left:=8;
  Edit.Width:=185;
  Form.UpdatePosition(Edit);
  Button:=TButton.create(form);
  Button.Left:=Edit.Left+Edit.width;
  Button.Top:=Edit.top;
  Button.Width:=Edit.Height;
  Button.Height:=Edit.Height;
  Button.Caption:='...';
  Button.Parent:=Form.PropertyPanel;
  Filter:=ini.ReadString(Name,'Filters','');
  if Filter=''
    then Button.OnClick:=ShowDirectoryDialog
    else Button.OnClick:=ShowFileDialog;
end;

procedure TAdvLoaderFilenameProperty.FromString(S: String);
begin
  edit.text:=s;
end;

function TAdvLoaderFilenameProperty.ToString: String;
begin
  result:=edit.Text;
end;

var FAdvPluginPath:string;
    FAdvPath:string;

function AdvPluginPath:string;
begin
  result:=FAdvPluginPath;
end;

function AdvPath:String;
begin
  result:=FAdvPath;
end;

procedure UpdateAdvPluginPath;
var reg:TRegistry;
begin
  reg:=nil;
  try
    reg:=TRegistry.create;
    reg.RootKey:=HKEY_LOCAL_MACHINE;
    reg.OpenKeyReadOnly('SOFTWARE\Blizzard Entertainment\Starcraft\AdvLoader');
    FAdvPath:=reg.ReadString('InstallPath')+'\';
    FAdvPluginPath:=FAdvPath+'Plugins\';
    if FAdvPluginPath='' then FAdvPluginPath:=GamePath+'Plugins\';
  finally
    reg.free;
  end;
end;

{ TAdvLoaderPlugin1 }

function TAdvLoaderPlugin1.ConfigFile: String;
begin
  result:=changefileext(Filename,'.ini');
end;

constructor TAdvLoaderPlugin1.Create(const AFilename: String);
var GetInfo:TPluginInfoProc;
    hLibrary:THandle;
    hInjHlp:THandle;
    Info:PAdvPluginInfo;
    DescFound:boolean;
begin
  inherited;
  hInjHlp:=0;
  hLibrary:=0;
  try
    hInjHlp:=LoadLibrary(PChar(GetAdvHelperFilename));
    if hInjHlp=0 then raise exception.create('Could not load InjHlp.dll when loading "'+Filename+'"'#13#10'Error: '+GetLastErrorString);
    hLibrary:=LoadLibrary(PChar(Filename));
    if hLibrary=0 then raise exception.create('Could not load Plugin "'+Filename+'"'#13#10'Error: '+GetLastErrorString);
    GetInfo:=GetProcAddress(hLibrary,'GetBWPPluginInfo');
    if not assigned(GetInfo) then raise exception.create('bwp plugin does not contain GetBWPPluginInfo');
    Info:=GetInfo();
    if info=nil then exit;
    DescFound:=false;
    while (info.Key<>nil)and(info.Key<>'') do
     begin
      if (uppercase(info.Key)='INFO')and(not DescFound)then FDescription:=Info.Value;
      if (uppercase(info.Key)='INFO')and(uppercase(info.Lang)='ENG')then FDescription:=Info.Value;
      inc(info);
     end;
    FDescription:=StringReplace(FDescription,#9,'',[rfReplaceAll]);
    FDescription:=StringReplace(FDescription,#1,'',[rfReplaceAll]);
    FDescription:=StringReplace(FDescription,#2,'',[rfReplaceAll]);
    FDescription:=StringReplace(FDescription,#3,'',[rfReplaceAll]);
    FDescription:=StringReplace(FDescription,#6,'',[rfReplaceAll]);
  finally
    if hLibrary<>0 then freelibrary(hLibrary);
    if hInjHlp<>0 then freelibrary(hInjHlp);
  end;
end;


function TAdvLoaderPlugin1.GetCompatible(
  const Version: TGameVersion): TCompatibility;
begin
  //Old api is available for 1.15.1 and 1.15.2
  if (Version.Version='1.15.1')or
     (Version.Version='1.15.2')
    then result:=coCompatible
    else result:=coIncompatible;
end;

class function TAdvLoaderPlugin1.HandlesFile(const Filename,
  Ext: String): boolean;
begin
  result:=(ext='.bwp')and not(directoryexists(AdvPluginPath+'Options'));
end;

{ TAdvLoaderPlugin2 }

function TAdvLoaderPlugin2.ConfigFile: String;
begin
  result:=AdvPath+'Plugins\Options\'+changefileext(extractfilename(filename),'.ini');
end;

constructor TAdvLoaderPlugin2.Create(const AFilename: String);
var stm:TResourceStream;
    hLibrary:HMODULE;
    sl:TStringlist;
    i:integer;
begin
  inherited;
  hLibrary:=0;
  stm:=nil;
  sl:=nil;
  try
    hLibrary:=LoadLibraryEx(PChar(Filename),0,LOAD_LIBRARY_AS_DATAFILE);
    stm:=TResourceStream.CreateFromID(hLibrary,110,PChar(23));
    sl:=TStringlist.create;
    setlength(FDescription,stm.size);
    stm.ReadBuffer(PChar(FDescription)^,length(FDescription));
    delete(FDescription,1,pos('<body',lowercase(FDescription)));
    delete(FDescription,1,pos('>',FDescription));
    delete(FDescription,pos('</body>',lowercase(FDescription)),length(FDescription));
    FDescription:=Str_StripHtmlTags(FDescription);
    FDescription:=StringReplace(FDescription,#9,' ',[rfReplaceAll]);
    FDescription:=StringReplace(FDescription,#10,'',[rfReplaceAll]);
    FDescription:=StringReplace(FDescription,#13,#13#10,[rfReplaceAll]);
    FDescription:=StringReplace(FDescription,'&nbsp;',' ',[rfReplaceAll,rfIgnoreCase]);
    FDescription:=StringReplace(FDescription,'&amp;','&',[rfReplaceAll,rfIgnoreCase]);
    FDescription:=StringReplace(FDescription,'&lt;','<',[rfReplaceAll,rfIgnoreCase]);
    FDescription:=StringReplace(FDescription,'&gt;','>',[rfReplaceAll,rfIgnoreCase]);
    sl.Text:=FDescription;
    for i:=sl.count-1 downto 0 do
      begin
        sl[i]:=trim(sl[i]);
        if sl[i]='' then sl.delete(i);
      end;
    FDescription:=sl.Text;
  finally
    sl.Free;
    stm.free;
    if hLibrary<>0 then FreeLibrary(hLibrary);
  end;
end;

function TAdvLoaderPlugin2.GetCompatible(
  const Version: TGameVersion): TCompatibility;
begin
  //New api is only available for 1.16.1
  if (Version.Version='1.16.1')
    then result:=coCompatible
    else result:=coIncompatible;
end;

class function TAdvLoaderPlugin2.HandlesFile(const Filename,
  Ext: String): boolean;
begin
  result:=(ext='.bwp')and(directoryexists(AdvPluginPath+'Options'));
end;

begin
  UpdateAdvPluginPath;
end.
