program LatencyChanger;

uses
  windows,
  util,
  sysutils,
  classes,
  DCPcrypt2,
  DCPmd5,
  dialogs;

function HashMem(const Buf;Size:integer;HashClass:TDCP_hashclass):String;
var BinResult:String;
    Hash:TDCP_hash;
begin
  Hash:=nil;
  try
    Hash:=HashClass.Create(nil);
    Setlength(BinResult,Hash.HashSize div 8);
    Hash.Init();
    Hash.Update(Buf, Size);
    Hash.Final(BinResult[1]);
    result:=StrToHex(BinResult);
  finally
    Hash.Free;
  end;
end;

var hProcess:THandle;
    ProcessID:Cardinal;
    Wnd:hWnd;
    BytesRead:Cardinal;
const CodeStartAddr  =$00401000;
      CodeSize       =$000FD000;
var Stm:TMemorystream;
begin
  EnablePrivilege('SeDebugPrivilege');
  Wnd:=FindWindow(nil,'Brood War');
  if Wnd=0 then raise exception.create('Window not found');
  GetWindowThreadProcessId(Wnd, @ProcessId);
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,true,ProcessID);
  if hProcess=0 then raise exception.create('Could not open process');
  Stm:=TMemoryStream.create;
  Stm.SetSize(CodeSize);
  ReadProcessMemory(hProcess,Pointer(CodeStartAddr),Stm.Memory,Stm.Size,BytesRead);
  if HashMem(Stm.memory^,Stm.Size,TDcp_Md5)<>'6F66408F6FDBA4050D8D4E0ACC0EED5F'
    then stm.savetofile(extractfilepath(paramstr(0))+'ScDump.bin')
    else showmessage('OK');
  stm.free;
end.
