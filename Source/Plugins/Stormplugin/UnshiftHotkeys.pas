unit UnshiftHotkeys;
interface
uses dialogs;
implementation
uses windows,messages,sysutils,pluginapi,main,config,logger,offsets,scinfo;

var   hHook:THandle;
type PWMChar=^TWMChar;

const NumNum='0123456789';
      Nums:array[0..1]of string=
        ('à&é"''(-è_ç', //Fr
         'à&é"''(§è!ç');//Be
function GetMsgProc(code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT;stdcall;
var i,i2:integer;
begin
  result:=0;
  try
    if Settings.UnshiftHotkeys and
       IsIngame and
      (not IsChatting)and
      (Code>=0)and// Code<0 => do not process message, see MSDN
      (PMessage(lParam+4).Msg=WM_CHAR)//only WM_Char gets modified
      then begin
        i:=pos(chr(PWMChar(lParam+4).CharCode),NumNum);
        i2:=pos(chr(PWMChar(lParam+4).CharCode),Nums[Settings.UnshiftHotkeysLayout]);
        if i>0 then PWMChar(lParam+4).CharCode:=ord(Nums[Settings.UnshiftHotkeysLayout][i]);
        if i2>0 then PWMChar(lParam+4).CharCode:=ord(NumNum[i2]);
      end;
    result:=CallNextHookEx(hHook,Code,wParam,longint(lParam));
  except
    on e:exception do
      Log('Exception in MessageHook '+e.Message);
  end;
end;

var Installed:boolean=false;

procedure InstallHook;
var WindowHandle:HWnd;
    ThreadID,ProcessID:Cardinal;
begin
  //ThreadID:=GetCurrentThreadID;
  if Installed then exit;
  WindowHandle:=FindWindow('SWarClass',nil);
  if WindowHandle=0 then exit;//raise exception.create('Starcraft Window not found');
  Log('Activating UnshiftHotkeys');
  Installed:=true;
  ThreadID:=GetWindowThreadProcessId(FindWindow('SWarClass',nil),ProcessID);
  if GetCurrentProcessID=ProcessID
    then hHook:=SetWindowsHookEx(WH_GETMESSAGE,GetMsgProc,hInstance,ThreadID)
    else raise exception.create('Injected in the wrong process');
  if hHook=0 then raise exception.create('Hook creation failed');
end;

procedure UnshiftTimer;
begin
  if IsInjected and Settings.UnshiftHotkeys then InstallHook;
end;

initialization
  AddTimerHandler(UnshiftTimer,[pmInjected]);
end.
