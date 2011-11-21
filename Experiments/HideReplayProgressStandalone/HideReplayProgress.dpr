program HideReplayProgress;

{$APPTYPE CONSOLE}

uses
  windows,
  util,
  sysutils,
  classes;
var hProcess:THandle;
    ProcessID:Cardinal;
    Wnd:hWnd;
    Written:Cardinal;
    Data:String;
    Delay:byte;
const Address=$00427AAA;
begin
  Data:=#$33#$C0#$90;
  EnablePrivilege('SeDebugPrivilege');
  Wnd:=FindWindow(nil,'Brood War');
  if Wnd=0 then raise exception.create('Window not found');
  GetWindowThreadProcessId(Wnd, @ProcessId);
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,true,ProcessID);
  if hProcess=0 then raise exception.create('Could not open process');
  WriteProcessMemory(hProcess,Pointer(Address),@Data[1],length(Data),Written);
end.
