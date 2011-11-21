library SCMsgUtil;

uses
  windows;

{$R *.res}
const Offset:Cardinal=$48CD60;
type TDoSendText=packed record
  Code1:byte;
  Param1:Cardinal;
  Code2:Word;
  Code3:byte;
  Param3:Cardinal;
  code4:byte;
end;

function SendTextInGame(hProcess:THandle;Msg:PChar):BOOL;stdcall;
var hThread:THandle;
    MsgAddr:Pointer;
    MemAddr:Pointer;
    BytesWritten:Cardinal;
    ThreadID:Cardinal;
    ExitCode:Cardinal;
    DoSendText:TDoSendText;
begin
  result:=false;
  hThread:=0;
  MemAddr:=nil;
  try
    MemAddr := VirtualAllocEx(hProcess, nil, sizeof(TDoSendText)+length(Msg)+1, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    if MemAddr=nil then exit;
    Cardinal(MsgAddr):=Cardinal(MemAddr)+sizeof(TDoSendText);
    DoSendText.Code1:=$BF;//mov EDI,Const
    DoSendText.Param1:=Cardinal(MsgAddr);
    DoSendText.Code2:=$C033;
    DoSendText.Code3:=$E8;//call reladdr
    DoSendText.Param3:=Offset-Cardinal(MemAddr)-12;
    DoSendText.Code4:=$C3;//ret

    if not WriteProcessMemory(hProcess, MemAddr, @DoSendText, sizeof(DoSendText), BytesWritten)
      then exit;
    if not WriteProcessMemory(hProcess, MsgAddr, PChar(Msg), length(Msg)+1, BytesWritten)
      then exit;
      

    hThread := CreateRemoteThread(hProcess, nil, 0, MemAddr, nil, 0, ThreadID);
    if hThread=0 then exit;

    if WaitForSingleObject(hThread, 30000)=WAIT_TIMEOUT
      then exit;

    GetExitCodeThread(hThread, ExitCode);
    if(ExitCode=0)then exit;
  finally
    VirtualFreeEx(hProcess, MemAddr, sizeof(TDoSendText)+length(Msg)+1, MEM_RELEASE);
    closeHandle(hThread);
  end;
  result:=true;
end;

exports
   SendTextInGame;
begin
end.
