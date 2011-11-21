library UnshiftHotkeys;

uses
  sysutils,
  windows,
  messages;

{$R *.res}
var   hHook:THandle;
type PWMChar=^TWMChar;
function GetMsgProc(code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT;stdcall;
begin
  inc(lparam,4);
  if (Code>=0)// Code<0 => do not process message, see MSDN
    and (PMessage(lParam).Msg=WM_CHAR)//only WM_Char gets modified
    then begin
      case PWMChar(lParam).CharCode of
        ord('0'):PWMChar(lParam).CharCode:=ord('�');
        ord('1'):PWMChar(lParam).CharCode:=ord('&');
        ord('2'):PWMChar(lParam).CharCode:=ord('�');
        ord('3'):PWMChar(lParam).CharCode:=ord('"');
        ord('4'):PWMChar(lParam).CharCode:=ord('''');
        ord('5'):PWMChar(lParam).CharCode:=ord('(');
        ord('6'):PWMChar(lParam).CharCode:=ord('-');
        ord('7'):PWMChar(lParam).CharCode:=ord('�');
        ord('8'):PWMChar(lParam).CharCode:=ord('_');
        ord('9'):PWMChar(lParam).CharCode:=ord('�');

        ord('�'):PWMChar(lParam).CharCode:=ord('0');
        ord('&'):PWMChar(lParam).CharCode:=ord('1');
        ord('�'):PWMChar(lParam).CharCode:=ord('2');
        ord('"'):PWMChar(lParam).CharCode:=ord('3');
        ord(''''):PWMChar(lParam).CharCode:=ord('4');
        ord('('):PWMChar(lParam).CharCode:=ord('5');
        ord('-'):PWMChar(lParam).CharCode:=ord('6');
        ord('�'):PWMChar(lParam).CharCode:=ord('7');
        ord('_'):PWMChar(lParam).CharCode:=ord('8');
        ord('�'):PWMChar(lParam).CharCode:=ord('9');
      end;
    end;
  result:=CallNextHookEx(hHook,Code,wParam,longint(lParam));
end;

procedure InstallHook;
var WindowHandle:HWnd;
    ThreadID,ProcessID:Cardinal;
begin
  hHook:=SetWindowsHookEx(WH_GETMESSAGE,GetMsgProc,hInstance,GetCurrentThreadID);
  {WindowHandle:=FindWindow('SWarClass',nil);
  if WindowHandle=0 then raise exception.create('Starcraft Window not found');
  ThreadID:=GetWindowThreadProcessId(FindWindow('SWarClass',nil),ProcessID);
  if GetCurrentProcessID=ProcessID
    then hHook:=SetWindowsHookEx(WH_GETMESSAGE,GetMsgProc,hInstance,ThreadID)
    else raise exception.create('Injected in the wrong process');  }
  if hHook=0 then raise exception.create('Hook creation failed');
end;

begin
  try
    InstallHook;
  except
    on e:exception do
      MessageBox(0,PChar('Exception '+e.ClassName+' : '+e.message),'Exception',MB_OK or MB_ICONERROR);
  end;
end.
