unit Inject_RemoteThread;

interface

procedure InjectDll_RemoteThread(hProcess:THandle;DllFileName:String);

implementation
uses windows,classes,sysutils,util,logger;

procedure InjectDll_RemoteThread(hProcess:THandle;DllFileName:String);
var hThread:THandle;
    LoadLibAddress:Pointer;
    PathAddress:Pointer;
    BytesWritten:Cardinal;
    ExitCode:Cardinal;
    ThreadID:Cardinal;
begin
  Log('InjectDll_RemoteThread '+DllFileName);
  PathAddress:=nil;
  hThread:=0;
  try
    LoadLibAddress := GetProcAddress(GetModuleHandle('kernel32.dll'), 'LoadLibraryA');
    if(LoadLibAddress=nil)then raise exception.create('LoadLibraryA not found');

    PathAddress := VirtualAllocEx(hProcess, nil, length(DllFileName)+1, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
    if PathAddress=nil then raise exception.create('Could not allocate remote Memory '+GetLastErrorString);

    if not WriteProcessMemory(hProcess, PathAddress, PChar(DllFilename), length(DllFilename)+1, BytesWritten)
      then raise exception.create('WriteProcessMemory failed '+GetLastErrorString);

    hThread := CreateRemoteThread(hProcess, nil, 0, LoadLibAddress, PathAddress, 0, ThreadID);
    if hThread=0 then raise exception.create('CreateRemoteThread failed '+GetLastErrorString);
    

    if WaitForSingleObject(hThread, 30000)=WAIT_TIMEOUT
      then raise exception.create('Remote thread did not terminate');

    GetExitCodeThread(hThread, ExitCode);
    if(ExitCode=0)then raise exception.create('Remote LoadLibrary failed');
  finally
    VirtualFreeEx(hProcess, PathAddress, length(DllFileName)+1, MEM_RELEASE);
    closeHandle(hThread);
  end;
end;

end.
