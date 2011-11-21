program LatencyChanger;

uses
  windows,
  util,
  sysutils,
  classes,
  DCPcrypt2,
  DCPmd5,
  dialogs;

function GetStreamHash(AStream: TStream; AHashClass: TDCP_hashclass): String;
var
  Buff: Array of Byte;
  BuffSize: Integer;
  i: Integer;
  Hash: TDCP_hash;
begin
  Hash := AHashClass.Create(nil);
  try
    BuffSize := Hash.HashSize div 8;
    SetLength(Buff, BuffSize);
    ZeroMemory(@Buff[0], BuffSize);

    Hash.Init();
    AStream.Position := 0;
    Hash.UpdateStream(AStream, AStream.Size);
    Hash.Final(Buff[0]);

    Result := '';
    for i:=0 to BuffSize-1 do begin
      Result := Result + IntToHex(Buff[i], 2);
    end;
  finally
    Hash.Free;
    SetLength(Buff, 0);
  end;
end;

var hProcess:THandle;
    ProcessID:Cardinal;
    Wnd:hWnd;
    BytesRead:Cardinal;
const START_ADDR    = $00401000;
      END_ADDR      = $004FE000;
var Stm:TMemorystream;
var a:Cardinal;
begin
  EnablePrivilege('SeDebugPrivilege');
  Wnd:=FindWindow(nil,'Brood War');
  if Wnd=0 then raise exception.create('Window not found');
  GetWindowThreadProcessId(Wnd, @ProcessId);
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,true,ProcessID);
  if hProcess=0 then raise exception.create('Could not open process');
  Stm:=TMemoryStream.create;
  Stm.SetSize(END_ADDR-START_ADDR);
  ReadProcessMemory(hPRocess,Pointer(START_ADDR),Stm.Memory,Stm.Size,BytesRead);
  if GetStreamHash(Stm,TDcp_Md5)<>'6F66408F6FDBA4050D8D4E0ACC0EED5F'
    then stm.savetofile(extractfilepath(paramstr(0))+'ScDump.bin')
    else showmessage('OK');
  stm.free;
end.
