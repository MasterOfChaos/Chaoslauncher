unit Config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,settingshelper,registry;

type
  TConfigForm = class(TForm)
    cbHideReplayProgress: TCheckBox;
    cbUnshiftHotkeys: TCheckBox;
    BOK: TButton;
    BCancel: TButton;
    BApply: TButton;
    cbSelectionCircles: TCheckBox;
    cbUnshiftHotkeysLayout: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure Save(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  ConfigForm: TConfigForm;

type TSettings=class(TCustomSettings)
    HideReplayProgress:boolean;
    UnshiftHotkeys:boolean;
    UnshiftHotkeysLayout:integer;
    SelectionCircles:boolean;
    procedure RegisterSettings;override;
  end;
var Settings:TSettings;


implementation

{$R *.dfm}

{ TSettings }

procedure TSettings.RegisterSettings;
begin
  inherited;
  BoolSetting('General\HideReplayProgress','cbHideReplayProgress',HideReplayProgress,false);
  BoolSetting('General\UnshiftHotkeys','cbUnshiftHotkeys',UnshiftHotkeys,false);
  BoolSetting('General\SelectionCircles','cbSelectionCircles',SelectionCircles,false);
  IntSetting('General\UnshiftHotkeysLayout','cbUnshiftHotkeysLayout',UnshiftHotkeysLayout,0);
end;

procedure TConfigForm.Save(Sender: TObject);
begin
  Settings.SaveGui(self);
  Settings.Save;
end;

procedure TConfigForm.FormShow(Sender: TObject);
begin
  Settings.LoadGui(self);
end;

initialization
  Settings:=TSettings.create('Software\BWProgrammers\Stormplugin');
finalization
  Settings.free;
end.
