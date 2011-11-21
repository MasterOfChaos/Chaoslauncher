unit Config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,registry, ActnList, ExtCtrls,shellapi,versions;

type
  TConfigForm = class(TForm)
    OK: TButton;
    Cancel: TButton;
    PageControl1: TPageControl;
    General: TTabSheet;
    Ingame: TTabSheet;
    SpoofDetector: TCheckBox;
    GroupMessages: TComboBox;
    Label1: TLabel;
    Features: TGroupBox;
    MinHack: TCheckBox;
    Multicommand: TCheckBox;
    NukeAnywhere: TCheckBox;
    Rallypoint: TCheckBox;
    Automine: TCheckBox;
    MulticommandThreshold: TComboBox;
    IngameDetectors: TCheckBox;
    AntiPause: TCheckBox;
    Apply: TButton;
    Debug: TTabSheet;
    LogActions: TCheckBox;
    LogNOPs: TCheckBox;
    ActionList1: TActionList;
    ShowDebugTab: TAction;
    About: TTabSheet;
    About_Name: TLabel;
    About_By: TLabel;
    Image1: TImage;
    About_Website: TLabel;
    Label2: TLabel;
    WebsiteICCup: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SetSettings(Sender: TObject);
    procedure GetSettings(Sender: TObject);
    procedure ShowDebugTabExecute(Sender: TObject);
    procedure About_WebsiteClick(Sender: TObject);
    procedure WebsiteICCupClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

type TSettings=record
  IngameDetectors:boolean;
  SpoofDetector:boolean;
  AntiPause:boolean;
  GroupMessages:integer;
  Minhack:boolean;
  Multicommand:boolean;
  MulticommandThreshold:integer;
  MulticommandThresholdEffective:integer;
  NukeAnywhere:boolean;
  RallyPoint:boolean;
  Automine:boolean;
  DebugVisible:boolean;
  LogActions:boolean;
  LogNOPs:boolean;
  procedure Load;
  procedure Save;
end;
var Settings:TSettings;

implementation

{$R *.dfm}

procedure TConfigForm.About_WebsiteClick(Sender: TObject);
begin
   shellexecute(0,'open','http://winner.cspsx.de/Starcraft','','',SW_SHOW);
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
  PageControl1.ActivePageIndex:=0;
  About_Name.caption:=stringreplace('HackDetector Version %1','%1',VersionToStr(GetModuleVersion),[rfReplaceAll]);
end;

procedure TConfigForm.GetSettings(Sender: TObject);
begin
  IngameDetectors.Checked:=Settings.IngameDetectors;
  SpoofDetector.Checked:=Settings.SpoofDetector;
  AntiPause.Checked:=Settings.AntiPause;
  Minhack.Checked:=Settings.Minhack;
  Multicommand.Checked:=Settings.Multicommand;
  NukeAnywhere.Checked:=Settings.NukeAnywhere;
  RallyPoint.Checked:=Settings.RallyPoint;
  Automine.Checked:=Settings.Automine;

  Debug.TabVisible:=Settings.DebugVisible or
                    Settings.LogActions or
                    Settings.LogNOPs;
  LogActions.Checked:=Settings.LogActions;
  LogNOPs.Checked:=Settings.LogNOPs;

  if Settings.MulticommandThreshold>1
    then MultiCommandThreshold.itemindex:=Settings.MulticommandThreshold-1
    else MultiCommandThreshold.itemindex:=0;
  GroupMessages.itemindex:=Settings.GroupMessages div 15;
end;

procedure TConfigForm.SetSettings(Sender: TObject);
begin
  Settings.IngameDetectors:=IngameDetectors.checked;
  Settings.SpoofDetector:=SpoofDetector.checked;
  Settings.AntiPause:=AntiPause.checked;
  Settings.Minhack:=Minhack.checked;
  Settings.Multicommand:=Multicommand.checked;
  Settings.NukeAnywhere:=NukeAnywhere.checked;
  Settings.RallyPoint:=RallyPoint.checked;
  Settings.Automine:=Automine.checked;

  Settings.DebugVisible:=Debug.Tabvisible;
  Settings.LogActions:=LogActions.checked;
  Settings.LogNOPs:=LogNOPs.checked;

  if MulticommandThreshold.ItemIndex>0
    then Settings.MulticommandThreshold:=MulticommandThreshold.ItemIndex+1
    else Settings.MulticommandThreshold:=0;
  Settings.GroupMessages:=GroupMessages.itemindex*15;
  Settings.Save;
end;

procedure TConfigForm.ShowDebugTabExecute(Sender: TObject);
begin
  Debug.TabVisible:=not Debug.TabVisible;
end;

procedure TConfigForm.WebsiteICCupClick(Sender: TObject);
begin
  shellexecute(0,'open','http://sc.iccup.com','','',SW_SHOW);
end;

{ TSettings }

procedure TSettings.Load;
var ini:TRegistryIniFile;
begin
  ini:=nil;
  try
    ini:=TRegistryIniFile.create('Software\BWProgrammers\HackDetector');
    IngameDetectors:=ini.ReadBool('General','IngameDetectors',true);
    SpoofDetector:=ini.ReadBool('General','SpoofDetector',false);
    AntiPause:=ini.ReadBool('General','AntiPause',true);
    GroupMessages:=ini.ReadInteger('Ingame','GroupMessages',30);
    MinHack:=ini.ReadBool('Ingame','MinHack',true);
    Multicommand:=ini.ReadBool('Ingame','Multicommand',true);
    MulticommandThreshold:=ini.ReadInteger('Ingame','MulticommandThreshold',0);

    DebugVisible:=ini.ReadBool('Debug','DebugVisible',false);
    LogActions:=ini.ReadBool('Debug','LogActions',false);
    LogNOPs:=ini.ReadBool('Debug','LogNOPs',false);


    if MulticommandThreshold<>0
      then MulticommandThresholdEffective:=MulticommandThreshold
      else MulticommandThresholdEffective:=3;
    NukeAnywhere:=ini.ReadBool('Ingame','NukeAnywhere',true);
    RallyPoint:=ini.ReadBool('Ingame','RallyPoint',true);
    Automine:=ini.ReadBool('Ingame','AutoMine',true);
  finally
    ini.free;
  end;
end;

procedure TSettings.Save;
var ini:TRegistryIniFile;
begin
  ini:=nil;
  try
    ini:=TRegistryIniFile.create('Software\BWProgrammers\HackDetector');
    ini.WriteBool('General','IngameDetectors',IngameDetectors);
    ini.WriteBool('General','SpoofDetector',SpoofDetector);
    ini.WriteBool('General','AntiPause',AntiPause);

    ini.WriteInteger('Ingame','GroupMessages',GroupMessages);
    ini.WriteBool('Ingame','MinHack',MinHack);
    ini.WriteBool('Ingame','Multicommand',Multicommand);
    ini.WriteInteger('Ingame','MulticommandThreshold',MulticommandThreshold);
    ini.WriteBool('Ingame','NukeAnywhere',NukeAnywhere);
    ini.WriteBool('Ingame','RallyPoint',RallyPoint);
    ini.WriteBool('Ingame','AutoMine',Automine);

    ini.WriteBool('Debug','DebugVisible',DebugVisible);
    ini.WriteBool('Debug','LogActions',LogActions);
    ini.WriteBool('Debug','LogNOPs',LogNOPs);
  finally
    ini.free;
  end;
end;


initialization
  Settings.load;
end.
