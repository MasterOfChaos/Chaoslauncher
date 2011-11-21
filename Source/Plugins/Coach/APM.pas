unit APM;

interface
uses windows,messages,main,logger,graphics,sysutils;
procedure apm_Update;
implementation
const
      WH_KEYBOARD_LL   =   13;
      WH_MOUSE_LL      =   14;
      LLKHF_ALTDOWN    =   $00000020;
      LLKHF_INJECTED   =   $00000010;
    
  type
      tagKBDLLHOOKSTRUCT   =   record
          vkCode:   DWORD;
          scanCode:   DWORD;
          flags:   DWORD;
          time:   DWORD;
          dwExtraInfo:   DWORD;
      end;
      KBDLLHOOKSTRUCT   =   tagKBDLLHOOKSTRUCT;
      LPKBDLLHOOKSTRUCT   =   ^KBDLLHOOKSTRUCT;
      PKBDLLHOOKSTRUCT   =   ^KBDLLHOOKSTRUCT;
  var
      hhkLowLevelKybd:   HHOOK;
      hhkLowLevelMouse:   HHOOK;

var ApmCounter:real;
    LastTick:Cardinal;
procedure DrawApm;
var Canvas:TCanvas;
var CurrentTick,TimeDiff:Cardinal;
begin
 CurrentTick:=gettickcount;
 TimeDiff:=CurrentTick-LastTick;
 ApmCounter:=ApmCounter*exp(-Timediff/15000);
 LastTick:=CurrentTick;
 if hWindow=0 then exit;
 Canvas:=TCanvas.create;
 Canvas.Handle:=GetDC(hWindow);
 Canvas.textout(520,330,'APM: '+inttostr(round(ApmCounter*4)));
 ReleaseDC(hWindow,Canvas.Handle);
 Canvas.free;
end;

procedure Action();
begin
 ApmCounter:=ApmCounter+1;
 DrawApm;
end;



function LowLevelMouseProc(nCode:   Integer;   awParam:   WPARAM;   alParam:   LPARAM):   LRESULT;   stdcall;
var
    p:   PKBDLLHOOKSTRUCT;
begin
  if ScActive and(  nCode   =   HC_ACTION)and
   ((awParam=WM_LBUTTONDOWN)or(awParam=WM_RBUTTONDOWN)) then
    begin
     Action();
    end;
  Result   :=   CallNextHookEx(hhkLowLevelMouse,   nCode,   awParam,   alParam);
end;


function LowLevelKeyBoardProc(nCode:   Integer;   awParam:   WPARAM;   alParam:   LPARAM):   LRESULT;   stdcall;
var
    p:   PKBDLLHOOKSTRUCT;
begin
  if ScActive and(  nCode   =   HC_ACTION)and(awParam=WM_KEYUP) then
    begin
     p:=PKBDLLHOOKSTRUCT(alParam);
     if not (p.vkCode in [vk_control,vk_space,vk_shift,vk_menu,vk_capital,vk_lcontrol,vk_rcontrol,vk_lshift,vk_rshift,vk_lmenu,vk_rmenu])
      then Action();
    end;
  Result   :=   CallNextHookEx(hhkLowLevelKybd,   nCode,   awParam,   alParam);
end;

procedure InstallHook;
begin
 if hhkLowLevelKybd<>0 then exit;
 Log('Install Hook');
 hhkLowLevelKybd   :=   SetWindowsHookEx(WH_KEYBOARD_LL,   @LowLevelKeyboardProc,   hInstance,   0);
 hhkLowLevelMouse  :=   SetWindowsHookEx(WH_MOUSE_LL,   @LowLevelMouseProc,   hInstance,   0);
end;

procedure UninstallHook;
begin
 if hhkLowLevelKybd=0 then exit;
 UnhookWindowsHookEx(hhkLowLevelKybd);
 UnhookWindowsHookEx(hhkLowLevelMouse);
 hhkLowLevelKybd:=0;
 Log('Unistall Hook');
end;

procedure apm_Update;
begin
 if thread=nil then exit;
 //if Settings.DisableCapslock or Settings.DisableWinkeys
 // then InstallHook
 // else UninstallHook;
 InstallHook;
end;

procedure apm_Init;
begin
 apm_Update;
end;

procedure apm_Finish;
begin
 UninstallHook;
end;

procedure apm_Timer;
begin
 DrawAPM;
end;

begin
 //AddInitHandler(apm_Init);
 //AddFinishHandler(apm_Finish);
 //AddTimerHandler(apm_Timer);
end.

