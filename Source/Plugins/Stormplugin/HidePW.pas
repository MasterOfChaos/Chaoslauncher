unit HidePW;

interface

implementation
uses asmhelper,main,sysutils,offsets,scinfo;

var HidePWPatch:TCallPatch;
    HidePWHook:THookFunction;
    PwAddr:PChar;
procedure HidePWFunc(var CPU:TCPUState);
begin
  PwAddr:=#5'<Hidden>';
  CPU.edi.p:=PwAddr;
end;

procedure HidePWTimer;
begin
  HidePWPatch.Enabled:=IsBNet and IsLobby;
end;

procedure HidePWInit;
begin
  PwAddr:=PPChar(Addresses.HidePW+1)^;
  HidePWHook:=THookFunction.create(HidePWFunc);
  HidePWPatch:=TCallPatch.Create(nil,Addresses.HidePW,HidePWHook);
end;

procedure HidePWFinish;
begin
  FreeAndNil(HidePWPatch);
  FreeAndNil(HidePWHook);
end;

initialization
  {AddInitHandler(HidePWInit,[pmInjected]);
  AddFinishHandler(HidePWFinish,[pmInjected]);
  AddTimerHandler(HidePWTimer,[pmInjected]);}
end.
