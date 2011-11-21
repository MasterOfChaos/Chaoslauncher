library SelectionCircles;

uses
  windows,
  SysUtils,
  Classes,
  dialogs,
  util,
  main,
  offsets,
  logger,
  AsmHelper in '..\..\Common\AsmHelper.pas';

{$R *.res}

var SelectionCirclesPatches:TPatchGroup;
    CircleNeededNoTeam:TNOPPatch;
    CircleNeededYourself:TNOPPatch;
    GetTeamCount:TManualStringPatch;
    CreateCircle:TCallPatch;
    DrawCircle:TCallPatch;
    CreateCircleHook:THookFunction;
    DrawCircleHook:THookFunction;
    SaveGlobalPlayerColor1Hook:THookFunction;
    SaveGlobalPlayerColor2Hook:THookFunction;
    CreateCircleHotkey:TManualStringPatch;
    ShowCircleHotkey:TNOPPatch;
    GlobalPlayerColor1Patch:TCallPatch;
    GlobalPlayerColor2Patch:TCallPatch;
    GlobalPlayerColor:Cardinal;

var SaveGlobalPlayerColor2Backup:Cardinal;

const AddTeamCircleInnerAddr     = $004996E0;//???
      AddTeamCircleOuterAddr     = $004E61E0;//3
      CircleNeededAddr           = $00499DF0;//3
      ColorTableAddr             = $005240B8;//u
      GlobalColorAddr            = $0050CDC2;//u
      DrawCircleInnerAddr        = $0040AC2E;//3
      DrawCircleOuterAddr        = $004D5010;//3
      PlayerColorTableAddr       = $00581DBE;//u
      SaveGlobalPlayerColor1Addr = $004C22B1;//3
      SaveGlobalPlayerColor2Addr = $0049AC9B;//3
      GlobalPlayerColorAddr      = $0051267C;//u
      ShowCircleHotkeyAddr       = $004996FC;//3
      CreateCircleHotkeyAddr     = $00496773;//3
      GetTeamCounAddr            = $00485460;//3

const GetTeamCounStr=#$B0#$08#$C3#$90#$90;//Mov Al,8;ret;nop;nop;
      CreateCircleHotkeyStr=#$8B#$D1#$83#$C2#$03#$90;//mov EDX,ECX; add EDX,3;nop

procedure SaveGlobalPlayerColor1Func(var CPU:TCPUState);
begin
  PCardinal(CPU.EBP.uint-4)^:=CPU.ESI.uint;
  PCardinal(CPU.EBP.uint-8)^:=0;
  GlobalPlayerColor:=PCardinal(GlobalPlayerColorAddr)^;
end;

procedure SaveGlobalPlayerColor2Func(var CPU:TCPUState);
begin
  PCardinal(CPU.eax.uint*4+SaveGlobalPlayerColor2Backup)^:=CPU.esi.uint;
  GlobalPlayerColor:=CPU.EDI.uint;
end;


procedure CreateCircleFunc(var CPU:TCPUState);
var Registers:TFunctionCallRegisters;
    esibackup:TCPURegister32;
begin
  CPU.ecx.uint:=PByte(CPU.EAX.uint+$4C)^;
  CPU.edx.uint:=3+GlobalPlayerColor;//3+PlayerNumber
  esibackup:=CPU.esi;
  CPU.esi.uint:=PCardinal(CPU.EAX.uint+$C)^;
  Registers.FromCPUState(CPU);
  CallFunction(AddTeamCircleInnerAddr,Registers,[CPU.edx.uint]);
  Registers.ToCPUState(CPU);
  CPU.esi:=esibackup;
end;

procedure DrawCircleFunc(var CPU:TCPUState);
var Registers:TFunctionCallRegisters;
    ColorNr,BaseColor,PlayerNr:Byte;
    ColorA,ColorB:Cardinal;
    BackupA,BackupB:Cardinal;
begin
  registers.FromCPUState(CPU);
  ColorNr:=CPU.Stack[3];
  if ColorNr<=2
    then begin
      ColorA:=PCardinal(ColorNr*8+ColorTableAddr+4)^;
      ColorB:=PCardinal(ColorNr*8+ColorTableAddr)^;
    end
    else begin
      PlayerNr:=ColorNr-3;
      BaseColor:=PByte(PlayerColorTableAddr+PlayerNr)^;
      ColorA:=(BaseColor shl 16) or (BaseColor shl 8) or BaseColor;
      ColorB:=ColorA;
    end;
  BackupA:=PCardinal(GlobalColorAddr+4)^;
  BackupB:=PCardinal(GlobalColorAddr)^;
  PCardinal(GlobalColorAddr+4)^:=ColorA;
  PCardinal(GlobalColorAddr)^:=ColorB;
  CallFunction(DrawCircleInnerAddr,Registers,[CPU.Stack[1],CPU.Stack[2],0]);
  PCardinal(GlobalColorAddr+4)^:=BackupA;
  PCardinal(GlobalColorAddr)^:=BackupB;
  CPU.SetStackImbalance(-12,true);
end;

procedure CirclesInit;
begin
  Log('Init SelectionCircles');
  try
    SaveGlobalPlayerColor2Backup:=PCardinal(SaveGlobalPlayerColor2Addr+3)^;

    CreateCircleHook:=THookFunction.Create(CreateCircleFunc);
    DrawCircleHook:=THookFunction.Create(DrawCircleFunc);
    SaveGlobalPlayerColor1Hook:=THookFunction.create(SaveGlobalPlayerColor1Func);
    SaveGlobalPlayerColor2Hook:=THookFunction.create(SaveGlobalPlayerColor2Func);

    SelectionCirclesPatches:=TPatchGroup.create(nil);
    CircleNeededNoTeam:=TNopPatch.create(SelectionCirclesPatches,CircleNeededAddr+$12,2);
    CircleNeededYourself:=TNopPatch.create(SelectionCirclesPatches,CircleNeededAddr+$1C,2);
    CreateCircle:=TCallPatch.Create(SelectionCirclesPatches,AddTeamCircleOuterAddr,CreateCircleHook,true);
    CreateCircleHotkey:=TManualStringPatch.create(SelectionCirclesPatches,CreateCircleHotkeyAddr,CreateCircleHotkeyStr);
    ShowCircleHotkey:=TNOPPatch.create(SelectionCirclesPatches,ShowCircleHotkeyAddr,2);
    DrawCircle:=TCallPatch.Create(SelectionCirclesPatches,DrawCircleOuterAddr,DrawCircleHook,true);
    GetTeamCount:=TManualStringPatch.create(SelectionCirclesPatches,GetTeamCounAddr,GetTeamCounStr);
    GlobalPlayerColor1Patch:=TCallPatch.create(SelectionCirclesPatches,SaveGlobalPlayerColor1Addr,SaveGlobalPlayerColor1Hook,false,5);
    GlobalPlayerColor2Patch:=TCallPatch.create(SelectionCirclesPatches,SaveGlobalPlayerColor2Addr,SaveGlobalPlayerColor2Hook,false,2);
  except
    on e:exception do
     showmessage('Exception '+e.message);
  end;
  Log('Init SelectionCircles completed');
end;

procedure CirclesFinish;
begin
  Log('Finishing SelectionCircles');
end;

procedure CirclesTimer;
begin
  try
    if not SelectionCirclesPatches.Enabled
      then begin//disabled
        //Replay=>enable
        if (PDWord(addresses.Ingame)^>0)and
           (PDWord(addresses.Replay)^>0)
           then begin
             Log('Entering Replay=>Enable SelectionCircles');
             SelectionCirclesPatches.Enabled:=true;
           end;
        //Obsmode=>enable
        if (PDWord(addresses.Ingame)^>0)and
           (PDWord(addresses.Replay)^=0)and
           (PDWord(addresses.Time)^<2857)and
           //2857=2min=120sec/0.042SecPerFrame on fastest
           (PDWord(addresses.Supply +4*PDWord(addresses.PlayerID)^)^+
            PDWord(addresses.Psy    +4*PDWord(addresses.PlayerID)^)^+
            PDWord(addresses.Control+4*PDWord(addresses.PlayerID)^)^
            <=2)//1 supply, doubled in memory
          then begin
            Log('Observermode=>Enable SelectionCircles');
            SelectionCirclesPatches.Enabled:=true;
          end;
      end
      else begin//enabled
        //not ingame=>disable
       if not (PDWord(addresses.Ingame)^>0)
         then begin
           Log('Left game=> disabling SelectionCircles');
           SelectionCirclesPatches.Enabled:=false;
         end;
        {//no Obsmode=>disable
        if (PDWord(addresses.Ingame)^>0)and
           (PDWord(addresses.Replay)^=0)and
           //2857=2min=120sec/0.042SecPerFrame on fastest
           (PDWord(addresses.Supply +4*PDWord(addresses.PlayerID)^)^+
            PDWord(addresses.Psy    +4*PDWord(addresses.PlayerID)^)^+
            PDWord(addresses.Control+4*PDWord(addresses.PlayerID)^)^
            >2)//1 supply, doubled in memory
          then begin
            Log('No Observermode=>Disable SelectionCircles');
            SelectionCirclesPatches.Enabled:=false;
          end; }
      end;
  except
    on e:exception do
     begin
      Log('Exception in thread '+e.classname+' : '+e.Message);
      showmessage('Exception in thread '+e.classname+' : '+e.Message);
     end;
  end;
end;
Type TTimerThread=class(TThread)
  protected
    procedure Execute;override;
end;


{ TTimerThread }

procedure TTimerThread.Execute;
begin
  CirclesInit;
  while not terminated do
    begin
      CirclesTimer;
      sleep(100);
    end;
  CirclesFinish;
end;

begin
  TTimerThread.create(false);
  //TTimerThread.Create(false);
  //AddInitHandler(CirclesInit);
  //AddFinishHandler(CirclesFinish);
  //AddTimerHandler(CirclesTimer);
end.
