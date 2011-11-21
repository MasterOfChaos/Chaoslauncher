unit OneInstance;

interface
uses windows,messages;

var IsFirstInstance:boolean;
procedure ActivateOldInstance;
procedure InstanceEnded;
const WM_ShowInstance =WM_User+1;

implementation


var AllowSetForegroundWindow:function (ProcessId:Cardinal):BOOL;stdcall;



procedure ActivateOldInstance;
var
  WindowHandle:THandle;
  Temp: DWORD;
  ProcessID:Cardinal;
begin
  WindowHandle:=FindWindow('TChaoslauncherForm',nil);//Chaoslauncher main window
  if (WindowHandle=0) then Exit;
  GetWindowThreadProcessID(WindowHandle,ProcessID);
  if assigned(AllowSetForegroundWindow)
    then AllowSetForegroundWindow(ProcessID);
  ShowWindow(WindowHandle, SW_SHOW);  //Does not work because of Delphibugs
  //SetForegroundWindow(WindowHandle);
  //ShowWindow(WindowHandle, SW_Hide);  //Does not work because of Delphibugs
  SendMessageTimeout(WindowHandle, //Handle of old Instance
                     WM_ShowInstance,//Userdefind msg
                     0,  //LParam
                     0,  //WParam
                     SMTO_ABORTIFHUNG or SMTO_NORMAL,   //Flags
                     8000, //Timeout
                     temp);//Result
end;
var Mutex:THandle;

procedure InstanceEnded;
begin
  if Mutex<>0 then CloseHandle(Mutex);
  Mutex:=0;
end;

initialization
  Mutex:=0;
  SetLastError(0);
  Mutex:=CreateMutex(nil,false,'Chaoslauncher {9198835E-72C9-488E-A6E5-48918D904856}');
  IsFirstInstance:=GetLastError=0;
  AllowSetForegroundWindow:=GetProcAddress(GetModuleHandle('User32.dll'),'AllowSetForegroundWindow');
finalization
  if Mutex<>0 then CloseHandle(Mutex);
end.
