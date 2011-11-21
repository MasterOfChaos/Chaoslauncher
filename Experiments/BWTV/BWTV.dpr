library BWTV;

uses
  AsmHelper,
  logger,
  sysutils;

{$R *.res}

var SaveReplayAddr:Cardinal;
const EndReplayFrameTrampAddr        =$4CD9F3;//Empty space near EndReplayFrameAddr
      EndReplayFrameAddr             =$4CDA1C;
const EndReplayFrameCode             =#$EB#$D5#$90;//JMP Short EndReplayFrameTrampAddr;NOP
      EndReplayFrameTrampJumpBackCode=#$88#$4A#$FF#$EB#$22;//JMP Short EndReplayFrameAddr+3

procedure SaveReplay(const RepName:String);
asm
  pushad;
  push 1;
  //RepName is already in EAX
  Call pointer(SaveReplayAddr);
  popad;
end;

procedure OnEndReplayFrame(Frame:Cardinal;const Buf;Size:integer);
begin
  Log(inttostr(Frame)+' '+MemToHex(Buf,Size)+' '+inttostr(Size));
end;

procedure EndReplayFrameFunc(var CPU:TCPUState);
begin
  OnEndReplayFrame(PCardinal(CPU.EDX.uint-5)^, CPU.EDX.p^,CPU.ecx.b[0]);
end;

var BWTVRecorderPatches:TPatchGroup;
    EndReplayFrame:TManualStringPatch;
    EndReplayFrameTrampJumpBack:TManualStringPatch;
    EndReplayFrameTramp:TCallPatch;
    EndReplayFrameHook:THookFunction;
begin
  SaveReplayAddr:=$4DF6A0;
  EndReplayFrameHook:=THookFunction.create(EndReplayFrameFunc);
  BWTVRecorderPatches:=TPatchGroup.create(nil);
  EndReplayFrame:=TManualStringPatch.create(BWTVRecorderPatches,EndReplayFrameAddr,EndReplayFrameCode);
  EndReplayFrameTramp:=TCallPatch.create(BWTVRecorderPatches,EndReplayFrameTrampAddr,EndReplayFrameHook);
  EndReplayFrameTrampJumpBack:=TManualStringPatch.create(BWTVRecorderPatches,EndReplayFrameTrampAddr+5,EndReplayFrameTrampJumpBackCode);
  BWTVRecorderPatches.Enabled:=true;
  //SaveReplay('BWTV');
end.
