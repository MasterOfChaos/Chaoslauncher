unit HideReplayProgress;
interface
implementation
uses main,asmhelper,offsets,config,logger,pluginapi,util,ScInfo;
const Code=#$33#$C0#$90;
var Orig:String;
var Patched:boolean=false;

procedure Patch;
begin
  if Patched then exit;
  Log('Activating HideReplayProgress');
  Orig:=ReadString(Addresses.HideReplayProgress,length(Code),Game.ProcessHandle);
  WriteString(Addresses.HideReplayProgress,Code,Game.ProcessHandle);
  Patched:=True;
end;

procedure UnPatch;
begin
  if not Patched then exit;
  Log('Deactivating HideReplayProgress');
  WriteString(Addresses.HideReplayProgress,Orig,Game.ProcessHandle);
  patched:=false;
end;

var toggling:boolean;
procedure HideReplayProgressTimer;
var hotkeyactive:boolean;
begin
  hotkeyactive:=iskeypressed(ord('H'),[hmCtrl])and
      ScActive and IsIngame and IsReplay;
  if hotkeyactive and not toggling
    then begin
      settings.HideReplayProgress:=not settings.HideReplayProgress;
      settings.Save;
      Log('Toggle HideReplayprogress. New state: '+booltostr(settings.HideReplayProgress));
    end;
  toggling:=hotkeyactive;

  if Settings.HideReplayProgress and
     IsIngame and IsReplay
    then Patch
    else UnPatch;
end;

initialization
  AddTimerHandler(HideReplayProgressTimer,[pmLauncher]);
end.
