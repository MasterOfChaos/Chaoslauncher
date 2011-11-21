unit MouseSettings;

interface

function GetMouseSpeed:integer;
procedure UpdateMouseSettings;

implementation
uses windows,registry,sysutils,config,main,forms;

var active:boolean=false;

function GetMouseSpeed:integer;
begin
 SystemParametersInfo(SPI_GETMOUSESPEED,0,@result,0);
end;

procedure SetMouseSpeed(Newspeed:integer);
begin
 SystemParametersInfo(SPI_SETMOUSESPEED,0,pointer(NewSpeed),0);
end;

procedure RestoreMouseSettings;
var ini:TRegistryInifile;
    speed:integer;
begin
 ini:=nil;
 try
   ini:=TRegistryIniFile.create('Software\Chaosplugin');
   speed:=ini.ReadInteger('Mouse','SavedSpeed',0);
   if speed<>0 then SetMouseSpeed(speed);
   ini.DeleteKey('Mouse','SavedSpeed');
 finally
   ini.free;
 end;
end;


procedure UpdateMouseSettings;

  procedure SaveMouseSettings;
  var ini:TRegistryInifile;
  begin
   ini:=nil;
   try
     ini:=TRegistryInifile.create('Software\Chaosplugin');
     ini.WriteInteger('Mouse','SavedSpeed',GetMouseSpeed);
   finally
     ini.free;
   end;
  end;

var activate:boolean;
begin
  Activate:=ScActive and Settings.DifferentMousesettings and (Settings.Mousespeed>0);
  if Settings.MousesettingsFullscreenOnly and (Screen.Width>640)and(Screen.Height>480)
    then Activate:=false;
  if active=activate then exit;
  RestoreMouseSettings;
  if Activate
   then begin
     SaveMouseSettings;
     SetMouseSpeed(Settings.MouseSpeed);
   end;
  active:=activate;
end;

procedure MouseSettingsTimer;
begin
  UpdateMouseSettings;
end;

procedure MouseSettingsFinish;
begin
  MouseSettingsTimer;
end;

initialization
 RestoreMouseSettings;
 AddTimerHandler(MouseSettingsTimer,[pmLauncher]);
 AddFinishHandler(MouseSettingsFinish,[pmLauncher]);
finalization
 RestoreMouseSettings;
end.
