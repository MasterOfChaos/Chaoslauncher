unit ReplaySlot;

interface

implementation
uses main,logger,offsets,config,scinfo;

procedure ReplaySlotTimer;
begin
  if not Settings.ReplaySlotmaker then exit;
  if IsLobby and IsReplay and
     (Trainer.Byte[Addresses.ReplaySlot1]<8)//Playercount<8
    then begin
      Log('Making Replayslots');
      Trainer.Byte[Addresses.ReplaySlot1]:=8;
      Trainer.Byte[Addresses.ReplaySlot2]:=8;
    end;
end;

initialization
  AddTimerHandler(ReplaySlotTimer,[pmLauncher]);
end.
