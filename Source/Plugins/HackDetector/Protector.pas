unit Protector;

interface

procedure ProtectorTimer;


implementation
uses windows,AsmHelper,ScInfo,ScHelper,offsets,Config,logger;
var AntiPausePatch:TNopPatch;

procedure AntiPauseTimer;
var enable:boolean;
begin
  enable:=Settings.AntiPause and (IsIngame);
  if enable and not AntiPausePatch.enabled then Log('Activating AntiPausePatch');
  if not enable and AntiPausePatch.enabled then Log('Deactivating AntiPausePatch');
  AntiPausePatch.enabled:=enable;
end;

procedure ProtectorTimer;
begin
  AntiPauseTimer;
end;

var hStorm:Cardinal;
initialization
  hStorm:=GetModuleHandle('storm.dll');
  if hStorm=0 then Log('Storm.dll not loaded');
  AntiPausePatch:=TNopPatch.create(nil,hStorm+Addresses.AntiPause,2);
finalization
  AntiPausePatch.Free;
end.
