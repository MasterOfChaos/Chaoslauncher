unit Config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,shellapi,main,registry,logger, ComCtrls, ExtCtrls,translator,pluginapi;

type
  TConfigForm = class(TForm)
    OK: TButton;
    Cancel: TButton;
    Pages: TPageControl;
    Page_General: TTabSheet;
    page_autoreplay: TTabSheet;
    Autoreplay: TCheckBox;
    DisableWinkeys: TCheckBox;
    DisableCapslock: TCheckBox;
    Autoreplay_Gamename: TCheckBox;
    Autoreplay_Playernames: TCheckBox;
    Autoreplay_NoShortnames: TCheckBox;
    Autoreplay_IncludeRaces: TCheckBox;
    Autoreplay_Excludenicks: TCheckBox;
    Autoreplay_Excludenicklist: TEdit;
    Autoreplay_RemoveSpecialcharacters: TCheckBox;
    Mouse: TTabSheet;
    DifferentMousesettings: TCheckBox;
    Mousespeed: TTrackBar;
    Default: TButton;
    About: TTabSheet;
    About_Pluginname: TLabel;
    About_By: TLabel;
    Image1: TImage;
    About_Website: TLabel;
    Apply: TButton;
    Language: TComboBox;
    JoinAlert: TCheckBox;
    LanguageLabel: TLabel;
    Translator: TLabel;
    DownloadStatus: TCheckBox;
    JoinAlertOnlyOutside: TCheckBox;
    ReplaySlotmaker: TCheckBox;
    Credits: TLabel;
    MouseSettings_FullscreenOnly: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Autoreplay_GamenameClick(Sender: TObject);
    procedure Autoreplay_ExcludenicksClick(Sender: TObject);
    procedure Autoreplay_PlayernamesClick(Sender: TObject);
    procedure DefaultClick(Sender: TObject);
    procedure DifferentMousesettingsClick(Sender: TObject);
    procedure About_WebsiteClick(Sender: TObject);
    procedure LanguageChange(Sender: TObject);
    procedure JoinAlertClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  ConfigForm: TConfigForm;
  Settings:record
    Autoreplay:boolean;
    DisableWinkeys:boolean;
    DisableCapslock:boolean;
    AutoreplayIncludeGamename:boolean;
    AutoreplayNoShortNames:boolean;
    AutoreplayIncludePlayernames:boolean;
    AutoreplayExcludeNicks:boolean;
    AutoreplayExcludeNickList:String;
    AutoreplayIncludeRaces:boolean;
    AutoreplayRemoveSpecialcharacters:boolean;
    DifferentMousesettings:boolean;
    Mousespeed:integer;
    Language:integer;
    JoinAlert:boolean;
    DownloadStatus:boolean;
    JoinAlertOnlyOutside:boolean;
    ReplaySlotmaker:boolean;
    MousesettingsFullscreenOnly:boolean;
    //FriendFollow:boolean;
   end;
implementation
uses hotkeys,mousesettings,inifiles;
{$R *.dfm}
{$R ChaospluginLang.res}

procedure SaveSettings;
var ini:TRegistryInifile;
begin
 ini:=nil;
 try
   ini:=TRegistryInifile.create('Software\Chaosplugin');
   ini.WriteBool('General','Autoreplay',Settings.Autoreplay);
   ini.WriteBool('General','DisableWinkeys',Settings.DisableWinkeys);
   ini.WriteBool('General','DisableCapslock',Settings.DisableCapslock);
   ini.WriteBool('General','JoinAlert',Settings.JoinAlert);
   ini.WriteBool('General','DownloadStatus',Settings.DownloadStatus);
   ini.WriteBool('General','JoinAlertOnlyOutside',Settings.JoinAlertOnlyOutside);
   ini.WriteBool('General','ReplaySlotmaker',Settings.ReplaySlotmaker);
   //ini.WriteBool('General','FriendFollow',Settings.FriendFollow);
   ini.WriteInteger('General','Language',Settings.Language);
   ini.WriteBool('Autoreplay','IncludeGamename',Settings.AutoreplayIncludeGamename);
   ini.WriteBool('Autoreplay','NoShortnames',Settings.AutoreplayNoShortNames);
   ini.WriteBool('Autoreplay','IncludePlayernames',Settings.AutoreplayIncludePlayernames);
   ini.WriteBool('Autoreplay','IncludeRaces',Settings.AutoreplayIncludeRaces);
   ini.WriteBool('Autoreplay','ExcludeNicks',Settings.AutoreplayExcludeNicks);
   ini.WriteString('Autoreplay','ExcludeNickList',Settings.AutoreplayExcludeNickList);
   ini.WriteBool('Autoreplay','RemoveSpecialCharacters',Settings.AutoreplayRemoveSpecialCharacters);
   ini.WriteBool('Mouse','DifferentSettings',Settings.DifferentMouseSettings);
   ini.WriteBool('Mouse','FullscreenOnly',Settings.MousesettingsFullscreenOnly);
   if Settings.DifferentMouseSettings
    then ini.WriteInteger('Mouse','Speed',Settings.MouseSpeed)
    else ini.DeleteKey('Mouse','Speed');
 finally
   ini.free;
 end;
 Log('Saving Settings');
end;

procedure LoadSettings;
var ini:TRegistryInifile;
begin
 ini:=nil;
 try
   ini:=TRegistryInifile.create('Software\Chaosplugin');
   Settings.Autoreplay:=ini.ReadBool('General','Autoreplay',Settings.Autoreplay);
   Settings.DisableWinkeys:=ini.ReadBool('General','DisableWinkeys',Settings.DisableWinkeys);
   Settings.DisableCapslock:=ini.ReadBool('General','DisableCapslock',Settings.DisableCapslock);
   Settings.JoinAlert:=ini.ReadBool('General','JoinAlert',Settings.JoinAlert);
   Settings.DownloadStatus:=ini.ReadBool('General','DownloadStatus',Settings.DownloadStatus);
   Settings.JoinAlertOnlyOutside:=ini.ReadBool('General','JoinAlertOnlyOutside',Settings.JoinAlertOnlyOutside);
   Settings.ReplaySlotmaker:=ini.ReadBool('General','ReplaySlotmaker',Settings.ReplaySlotmaker);
   //Settings.FriendFollow:=ini.ReadBool('General','FriendFollow',Settings.FriendFollow);
   Settings.Language:=ini.ReadInteger('General','Language',Settings.Language);
   Settings.AutoreplayIncludeGamename:=ini.ReadBool('Autoreplay','IncludeGamename',Settings.AutoreplayIncludeGamename);
   Settings.AutoreplayNoShortNames:=ini.ReadBool('Autoreplay','NoShortnames',Settings.AutoreplayNoShortNames);
   Settings.AutoreplayIncludePlayernames:=ini.ReadBool('Autoreplay','IncludePlayernames',Settings.AutoreplayIncludePlayernames);
   Settings.AutoreplayIncludeRaces:=ini.ReadBool('Autoreplay','IncludeRaces',Settings.AutoreplayIncludeRaces);
   Settings.AutoreplayExcludeNicks:=ini.ReadBool('Autoreplay','ExcludeNicks',Settings.AutoreplayExcludeNicks);
   Settings.AutoreplayExcludeNickList:=ini.ReadString('Autoreplay','ExcludeNickList',Settings.AutoreplayExcludeNickList);
   Settings.AutoreplayRemoveSpecialCharacters:=ini.ReadBool('Autoreplay','RemoveSpecialCharacters',Settings.AutoreplayRemoveSpecialCharacters);
   Settings.DifferentMouseSettings:=ini.ReadBool('Mouse','DifferentSettings',Settings.DifferentMouseSettings);
   Settings.MouseSettingsFullscreenOnly:=ini.ReadBool('Mouse','FullscreenOnly',Settings.MouseSettingsFullscreenOnly);
   Settings.MouseSpeed:=ini.ReadInteger('Mouse','Speed',GetMouseSpeed);
 finally
   ini.free;
 end;
 Log('Loading Settings');
end;

procedure TConfigForm.About_WebsiteClick(Sender: TObject);
begin
 shellexecute(0,'open','http://winner.cspsx.de/Starcraft','','',SW_SHOW);
end;

procedure TConfigForm.Autoreplay_ExcludenicksClick(Sender: TObject);
begin
 Autoreplay_ExcludeNickList.Enabled:=Autoreplay_Playernames.checked and Autoreplay_Excludenicks.Checked;
end;

procedure TConfigForm.Autoreplay_GamenameClick(Sender: TObject);
begin
 Autoreplay_NoShortNames.enabled:=Autoreplay_Gamename.checked;
end;

procedure TConfigForm.Autoreplay_PlayernamesClick(Sender: TObject);
begin
 Autoreplay_ExcludeNicks.Enabled:=Autoreplay_Playernames.checked;
 Autoreplay_ExcludeNickList.Enabled:=Autoreplay_Playernames.checked and Autoreplay_Excludenicks.Checked;
end;

procedure TConfigForm.DefaultClick(Sender: TObject);
begin
 UpdateMouseSettings;
 Settings.Mousespeed:=GetMouseSpeed;
 MouseSpeed.position:=Settings.Mousespeed;
end;

procedure TConfigForm.DifferentMousesettingsClick(Sender: TObject);
begin
 MouseSpeed.Enabled:=DifferentMouseSettings.Checked;
end;

procedure TConfigForm.FormCreate(Sender: TObject);
begin
 pages.ActivePageIndex:=0;
 GetLanguages(Language.items);
 if DebugHook<>0 then CreateTranslationTable(Self,'Config.tpl');
end;

procedure TConfigForm.FormShow(Sender: TObject);
begin
 Log('Show Configform');
 try
   Language.ItemIndex:=Settings.Language;
   LanguageChange(sender);
 except
   on e:exception do
     MessageBox(0,PChar(e.message), PChar('Language Error'), MB_OK or MB_ICONSTOP);
 end;
 Autoreplay.checked:=Settings.Autoreplay;
 DisableWinkeys.checked:=Settings.DisableWinkeys;
 DisableCapslock.checked:=Settings.DisableCapslock;
 DownloadStatus.checked:=Settings.DownloadStatus;
 JoinAlertOnlyOutside.Checked:=Settings.JoinAlertOnlyOutside;
 ReplaySlotmaker.Checked:=Settings.ReplaySlotmaker;
 //FriendFollow.checked:=Settings.FriendFollow;
 Autoreplay_Gamename.checked:=Settings.AutoreplayIncludeGamename;
 Autoreplay_NoShortNames.checked:=Settings.AutoreplayNoShortNames;
 Autoreplay_Playernames.checked:=Settings.AutoreplayIncludePlayernames;
 Autoreplay_IncludeRaces.checked:=Settings.AutoreplayIncludeRaces;
 Autoreplay_ExcludeNicks.checked:=Settings.AutoreplayExcludeNicks;
 Autoreplay_ExcludeNickList.text:=Settings.AutoreplayExcludeNickList;
 Autoreplay_RemoveSpecialcharacters.checked:=Settings.AutoreplayRemoveSpecialcharacters;
 DifferentMouseSettings.Checked:=Settings.DifferentMousesettings;
 MouseSettings_FullscreenOnly.Checked:=Settings.MouseSettingsFullscreenOnly;
 Mousespeed.Position:=Settings.Mousespeed;
 JoinAlert.Checked:=Settings.JoinAlert;
 UpdateMouseSettings;

 //About_Pluginname.caption:=StringReplace(About_Pluginname.caption,'%1',PluginInfo.GetVersionString,[rfReplaceAll]);
 //About_Pluginname.caption:=StringReplace(About_Pluginname.caption,'%2',PluginInfo.StarcraftVersion,[rfReplaceAll]);
end;

procedure TConfigForm.JoinAlertClick(Sender: TObject);
var Filename:String;
begin
 setlength(Filename,Max_Path+1);
 GetModuleFilename(hInstance,PChar(Filename),length(Filename)+1);
 setlength(Filename,strlen(PChar(Filename)));

 //Not relevant when sound is embedded
 {if JoinAlert.Checked then
   if not fileexists(extractfilepath(Filename)+'JoinAlert.wav')then
     begin
       JoinAlert.checked:=false;
       showmessage(translate('SoundMissingWarning',['JoinAlert.wav']));
     end;   }
end;

procedure TConfigForm.LanguageChange(Sender: TObject);
var i:integer;
begin
 Self.Font.Charset:=ANSI_CHARSET;
 i:=Language.ItemIndex;
 LoadLanguage(Language.text);//Language.Text);
 Font.Charset:=CurrentCharset;
 Translate(Self);
 Language.ItemIndex:=i;
 About_Pluginname.caption:=StringReplace(About_Pluginname.caption,'%1',PluginInfo.GetVersionString,[rfReplaceAll]);
 About_Pluginname.caption:=StringReplace(About_Pluginname.caption,'%2',PluginInfo.StarcraftVersion,[rfReplaceAll]);
end;

procedure TConfigForm.ApplyClick(Sender: TObject);
begin
 Settings.Autoreplay:=Autoreplay.checked;
 //Settings.UnshiftHotkeys:=UnshiftHotkeys.checked;
 Settings.DisableWinkeys:=DisableWinkeys.checked;
 Settings.DisableCapslock:=DisableCapslock.checked;
 Settings.JoinAlert:=JoinAlert.Checked;
 Settings.DownloadStatus:=DownloadStatus.Checked;
 Settings.JoinAlertOnlyOutside:=JoinAlertOnlyOutside.checked;
 settings.ReplaySlotmaker:=ReplaySlotmaker.checked;
 //Settings.FriendFollow:=FriendFollow.Checked;
 Settings.Language:=Language.ItemIndex;
 Settings.AutoreplayIncludeGamename:=Autoreplay_Gamename.checked;
 Settings.AutoreplayNoShortNames:=Autoreplay_NoShortNames.checked;
 Settings.AutoreplayIncludePlayernames:=Autoreplay_Playernames.checked;
 Settings.AutoreplayIncludeRaces:=Autoreplay_IncludeRaces.checked;
 Settings.AutoreplayExcludeNicks:=Autoreplay_ExcludeNicks.checked;
 Settings.AutoreplayExcludeNickList:=Autoreplay_ExcludeNickList.text;
 Settings.AutoreplayRemoveSpecialcharacters:=Autoreplay_RemoveSpecialcharacters.checked;
 Settings.DifferentMousesettings:=DifferentMouseSettings.Checked;
 Settings.MousesettingsFullscreenOnly:=Mousesettings_FullscreenOnly.Checked;
 Settings.Mousespeed:=MouseSpeed.Position;
 Hotkeys_Update;
 UpdateMouseSettings;
 SaveSettings;
 //byte(Settings.Keyboard):=Keyboard.itemindex;
end;

begin
 Settings.Autoreplay:=true;
 Settings.DisableWinkeys:=false;
 Settings.DisableCapslock:=false;
 Settings.AutoreplayIncludeGamename:=false;
 Settings.AutoreplayNoShortNames:=true;
 Settings.AutoreplayIncludePlayernames:=true;
 Settings.AutoreplayIncludeRaces:=true;
 Settings.AutoreplayRemoveSpecialcharacters:=true;
 Settings.AutoreplayExcludeNickList:='';
 Settings.AutoreplayExcludeNicks:=false;
 Settings.DifferentMousesettings:=false;
 Settings.Mousespeed:=GetMouseSpeed;
 Settings.Language:=0;
 Settings.JoinAlert:=false;
 Settings.JoinAlertOnlyOutside:=false;
 Settings.ReplaySlotmaker:=true;
 //Settings.FriendFollow:=true;
 Settings.DownloadStatus:=false;
 //Settings.UnshiftHotkeys:=false;
 Settings.MousesettingsFullscreenOnly:=false;
 LoadSettings;
end.
