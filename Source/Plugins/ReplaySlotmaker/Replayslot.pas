unit ReplaySlot;

interface

implementation
uses main,logger,offsets;

procedure ReplaySlotTimer;
begin
  if (Trainer.DWord[Addresses.Lobby]<>0)and//Is in the lobby
     (Trainer.DWord[Addresses.Replay]=1)and//Is a replay
     (Trainer.Byte[Addresses.ReplaySlot1]<8)//Playercount<8
    then begin
      Log('Making Replayslots');
      Trainer.Byte[Addresses.ReplaySlot1]:=8;
      Trainer.Byte[Addresses.ReplaySlot2]:=8;
    end;
end;

initialization
  AddTimerHandler(ReplaySlotTimer);
end.
