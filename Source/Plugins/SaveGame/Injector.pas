unit Injector;

interface

function Inject(hProcess:THandle):boolean;

implementation
uses windows,sysutils,util;

function Inject(hProcess:THandle):boolean;
var Filename:String;
    RemoteStr, LoadLibAddr: Pointer;
    hThread:THandle;
begin
  result:=false;
  Filename:=GetModuleFileName;

  if not FileExists(Filename)
    then begin
      SimpleMessageBox(smtError,'Could not find HackDetector mainfile');
      exit;
    end;
  // Our CreateRemoteThread Dll Injector :)
  LoadLibAddr := GetProcAddress(GetModuleHandle('kernel32.dll'),'LoadLibraryA');
  RemoteStr := VirtualAllocEx(hProcess,nil,length(Filename)+1,MEM_COMMIT or MEM_RESERVE,PAGE_READWRITE);
  WriteProcessMemory(hProcess,RemoteStr,PChar(Filename),length(Filename)+1,Cardinal(nil^));
  hThread := CreateRemoteThread(hProcess,nil,0,LoadLibAddr, RemoteStr, 0, Cardinal(nil^));
  if hThread = 0
    then begin
      SimpleMessageBox(smtError,PChar('Remote thread creation failed. Error Code: ' + IntToStr(GetLastError())));
      exit;
    end;
  result:=true;
end;

end.
