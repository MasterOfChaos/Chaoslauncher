program LatencyChanger;

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
const Address=$004D925B;
begin
  if paramcount>0
    then Delay:=strtoint(paramstr(1))
    else Delay:=2;
  Data:=#$B8+chr(Delay)+#0#0#0#$90#$90;
  EnablePrivilege('SeDebugPrivilege');
  Wnd:=FindWindow(nil,'Brood War');
  if Wnd=0 then raise exception.create('Window not found');
  GetWindowThreadProcessId(Wnd, @ProcessId);
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,true,ProcessID);
  if hProcess=0 then raise exception.create('Could not open process');
  WriteProcessMemory(hProcess,Pointer(Address),@Data[1],length(Data),Written);
end.
