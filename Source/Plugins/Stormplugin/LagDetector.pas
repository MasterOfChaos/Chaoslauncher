unit LagDetector;

interface

implementation
uses main,offsets,util,classes,logger,scinfo;

function ShouldActivate:boolean;
begin
  result:=IsInGame and IsKeyPressed(ord('L'),[hmCtrl]);
end;

var enabled:boolean=false;

procedure LagInit;
begin
  enabled:=false;
  if Trainer.DWord[addresses.LagScreenDelay]<>2500 then SimpleMessageBox(smtError,'LagDetector not compatible with this SC');
end;

procedure LagTimer;
var enable:boolean;
begin
  enable:=ShouldActivate;
  if enable=enabled then exit;
  if enable
    then begin
      Trainer.DWord[addresses.LagScreenDelay]:=0;
      Log('Enable LagDetector');
    end
    else begin
      Trainer.DWord[addresses.LagScreenDelay]:=2500;
      Log('Disable LagDetector');
    end;
  enabled:=enable;
end;

initialization
  AddInitHandler(LagInit,[pmLauncher]);
  AddTimerHandler(LagTimer,[pmLauncher]);
end.
