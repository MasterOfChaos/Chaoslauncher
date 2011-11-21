unit SettingsHelper;

interface
uses stdctrls,inifiles,registry,controls,classes,sysutils;
type TSerializerMode=(smNone,smLoad,smSave,smLoadGUI,smSaveGUI,smReset);

type TCustomSettings=class
  private
    FIni: TCustominifile;
    FMode: TSerializerMode;
    FRegPath: String;
    FRootControl: TWinControl;
    FAutoLoad:boolean;
    procedure CheckState;
  protected
    property Mode:TSerializerMode read FMode;
    property Ini:TCustominifile read FIni;
    property RootControl:TWinControl read FRootControl;
    procedure RegisterSettings;virtual;abstract;
    procedure BoolSetting(const Name,ControlName:string;var Setting:boolean;Default:boolean);
    procedure IntSetting(const Name, ControlName: string;var Setting: integer; Default: integer);
  public
    property RegPath:String read FRegPath;
    constructor Create(const ARegPath:String;AAutoLoad:boolean=true);
    procedure Save;virtual;
    procedure Load;virtual;
    procedure LoadGui(RootControl:TWinControl);virtual;
    procedure SaveGui(RootControl:TWinControl);virtual;
    procedure Reset;virtual;
    procedure AfterConstruction;override;
end;

implementation

procedure GetSectionAndKey(const Name:String;out section,key:String);
var i:integer;
begin
  i:=pos('\',Name);
  section:=copy(Name,1,i-1);
  key:=copy(Name,i+1);
end;

function FindControl(RootControl:TWinControl;const Name:String):TControl;
begin
  result:=RootControl.FindChildControl(Name);
  if result=nil then raise exception.create('Control '+Name+' not found in '+RootControl.Name);
end;

procedure TCustomSettings.AfterConstruction;
begin
  inherited;
  Reset;
  if FAutoLoad then Load;
end;

procedure TCustomSettings.BoolSetting(const Name,ControlName:string;var Setting:boolean;Default:boolean);
var section,key:String;
    CheckBox:TCheckBox;
begin
  case Mode of
    smLoad:
      begin
        GetSectionAndKey(Name,Section,Key);
        Setting:=ini.ReadBool(section,key,setting);
      end;
    smSave:
      begin
        GetSectionAndKey(Name,Section,Key);
        ini.writeBool(section,key,Setting);
      end;
    smLoadGUI:
      begin
        Checkbox:=FindControl(RootControl,ControlName)as TCheckbox;
        Checkbox.Checked:=Setting;
      end;
    smSaveGUI:
      begin
        Checkbox:=FindControl(RootControl,ControlName)as TCheckbox;
        Setting:=Checkbox.Checked;
      end;
    smReset:Setting:=Default;
  end;
end;

procedure TCustomSettings.CheckState;
begin
  Assert(Fini=nil,'Settings: ini not nil');
  Assert(Mode=smNone,'Settings: Mode not none');
  Assert(FRootControl=nil,'Settings: RootControl not nil');
  Assert(FRegpath<>'','Settings: RegPath empty');
end;

constructor TCustomSettings.Create(const ARegPath:String;AAutoLoad:boolean=true);
begin
  FMode:=smNone;
  FIni:=nil;
  FRegPath:=ARegPath;
  FRootControl:=nil;
  FAutoLoad:=AAutoLoad;
  CheckState;
end;

procedure TCustomSettings.IntSetting(const Name, ControlName: string;
  var Setting: integer; Default: integer);
var section,key:String;
    ComboBox:TComboBox;
begin
  case Mode of
    smLoad:
      begin
        GetSectionAndKey(Name,Section,Key);
        Setting:=ini.ReadInteger(section,key,setting);
      end;
    smSave:
      begin
        GetSectionAndKey(Name,Section,Key);
        ini.writeinteger(section,key,Setting);
      end;
    smLoadGUI:
      begin
        combobox:=FindControl(RootControl,ControlName)as Tcombobox;
        combobox.itemindex:=Setting;
      end;
    smSaveGUI:
      begin
        combobox:=FindControl(RootControl,ControlName)as Tcombobox;
        Setting:=combobox.ItemIndex;
      end;
    smReset:Setting:=Default;
  end;
end;


procedure TCustomSettings.Load;
begin
  CheckState;
  try
    FMode:=smLoad;
    Fini:=TRegistryInifile.Create(RegPath);
    RegisterSettings;
  finally
    FMode:=smNone;
    FreeAndNil(Fini);
  end;
end;

procedure TCustomSettings.LoadGui(RootControl: TWinControl);
begin
  CheckState;
  try
    FMode:=smLoadGUI;
    FRootControl:=RootControl;
    RegisterSettings;
  finally
    FMode:=smNone;
    FRootControl:=nil;
  end;
end;

procedure TCustomSettings.Reset;
begin
  CheckState;
  try
    FMode:=smReset;
    RegisterSettings;
  finally
    FMode:=smNone;
  end;
end;

procedure TCustomSettings.Save;
begin
  CheckState;
  try
    FMode:=smSave;
    Fini:=TRegistryInifile.Create(RegPath);
    RegisterSettings;
  finally
    FMode:=smNone;
    FreeAndNil(Fini);
  end;
end;

procedure TCustomSettings.SaveGui(RootControl: TWinControl);
begin
  CheckState;
  try
    FMode:=smSaveGUI;
    FRootControl:=RootControl;
    RegisterSettings;
  finally
    FMode:=smNone;
    FRootControl:=nil;
  end;
end;

end.
