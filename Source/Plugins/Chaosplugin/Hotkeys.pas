unit Hotkeys;

interface
uses windows,messages,main,config,logger;
procedure Hotkeys_Update;
implementation
const   
      WH_KEYBOARD_LL   =   13;
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
      
procedure SetCapslockOff;
begin
 Log('SetCapslockOff');
  //GetKeyboardState(keyState);
  if (getkeyState(VK_CAPITAL) and 1)<>0//Capslock pressed
    then begin
      // Simulate a key press
      keybd_event( VK_CAPITAL, $45, KEYEVENTF_EXTENDEDKEY,0 );
      // Simulate a key release
      keybd_event( VK_CAPITAL, $45, KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP,0 );
    end;
end;

function LowLevelKeyBoardProc(nCode:   Integer;   awParam:   WPARAM;   alParam:   LPARAM):   LRESULT;   stdcall;
var
    fEatKeyStroke:   Boolean;
    p:   PKBDLLHOOKSTRUCT;
begin
    fEatKeystroke   :=   False;
    if ScActive and(  nCode   =   HC_ACTION)   then
    begin
        case   awParam   of
            WM_KEYDOWN,
            WM_SYSKEYDOWN,
            WM_KEYUP,
            WM_SYSKEYUP:
                begin
                    p   :=   PKBDLLHOOKSTRUCT(alParam);
                    if Settings.DisableWinKeys then
                     begin
                      if p^.vkCode   =   VK_LWIN
                        then fEatKeystroke   :=   True;
                      if p^.vkCode   =   VK_RWIN
                        then fEatKeystroke   :=   True;
                     end;
                    if Settings.DisableCapslock then
                      if (p^.vkCode = VK_CAPITAL)and(p^.flags and LLKHF_INJECTED=0)
                        then begin
                         fEatKeystroke   :=   True;
                        end;
                end;
        end;
    end;
    if   fEatKeyStroke   then
        Result   :=   1
    else
        Result   :=   CallNextHookEx(hhkLowLevelKybd,   nCode,   awParam,   alParam);
end;

procedure InstallHook;
begin
 if hhkLowLevelKybd<>0 then exit;
 Log('Install Hook');
 hhkLowLevelKybd   :=   SetWindowsHookEx(WH_KEYBOARD_LL,   @LowLevelKeyboardProc,   hInstance,   0);
end;

procedure UninstallHook;
begin
 if hhkLowLevelKybd=0 then exit;
 UnhookWindowsHookEx(hhkLowLevelKybd);
 hhkLowLevelKybd:=0;
 Log('Unistall Hook');
end;

procedure Hotkeys_Update;
begin
 if thread=nil then exit;
 if Settings.DisableCapslock or Settings.DisableWinkeys
  then InstallHook
  else UninstallHook;
end;

procedure Hotkeys_Init;
begin
 Hotkeys_Update;
end;

procedure Hotkeys_Finish;
begin
 UninstallHook;
end;

var ActiveBefore:boolean;
procedure Hotkeys_Timer;
begin
  if ScActive and (not ActiveBefore)and Settings.DisableCapslock
    then SetCapslockOff;
  ActiveBefore:=ScActive;
end;

begin
 AddInitHandler(Hotkeys_Init,[pmLauncher]);
 AddFinishHandler(Hotkeys_Finish,[pmLauncher]);
 AddTimerHandler(Hotkeys_Timer,[pmLauncher]);
end.
