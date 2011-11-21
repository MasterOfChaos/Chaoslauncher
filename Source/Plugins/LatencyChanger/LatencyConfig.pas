unit LatencyConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,registry;

type
  TConfigForm = class(TForm)
    OK: TButton;
    Button2: TButton;
    LANLatency1: TCheckBox;
    LANReducedUserLatency: TCheckBox;
    procedure OKClick(Sender: TObject);
    procedure GetSettings(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  ConfigForm: TConfigForm;

var Settings:record
    LanLatency1:boolean;
    LANReducedUserLatency:boolean;
  end;

implementation

{$R *.dfm}

procedure DefaultSettings;
begin
  Settings.LanLatency1:=false;
  Settings.LANReducedUserLatency:=false;
end;

procedure LoadSettings;
var ini:TRegistryInifile;
begin
  ini:=nil;
  try
    ini:=TRegistryInifile.Create('Software\Chaosplugin\Latency');
    Settings.LanLatency1:=ini.ReadBool('Latency','LanLatency1',Settings.LanLatency1);
    Settings.LANReducedUserLatency:=ini.ReadBool('Latency','LANReducedUserLatency',Settings.LANReducedUserLatency);
  finally
    ini.free;
  end;
end;

procedure SaveSettings;
var ini:TRegistryInifile;
begin
  ini:=nil;
  try
    ini:=TRegistryInifile.Create('Software\Chaosplugin\Latency');
    ini.WriteBool('Latency','LanLatency1',Settings.LanLatency1);
    ini.WriteBool('Latency','LANReducedUserLatency',Settings.LANReducedUserLatency);
  finally
    ini.free;
  end;
end;

procedure TConfigForm.OKClick(Sender: TObject);
begin
  Settings.LanLatency1:=ConfigForm.LANLatency1.checked;
  Settings.LANReducedUserLatency:=ConfigForm.LANReducedUserLatency.checked;
  SaveSettings;
end;

procedure TConfigForm.GetSettings(Sender: TObject);
begin
  ConfigForm.LANLatency1.checked:=Settings.LanLatency1;
  ConfigForm.LANReducedUserLatency.checked:=Settings.LANReducedUserLatency;
end;

initialization
  DefaultSettings;
  LoadSettings;
end.
