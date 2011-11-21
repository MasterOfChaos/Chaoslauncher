unit TextOut;

interface
{$Q-}
procedure SendTextInLobby(const Msg:String);

implementation
uses windows,logger,sysutils,patcher,offsets,util,pluginapi;

type TDoSendText=packed record
  Code1:byte;
  Param1:Cardinal;
  Code2:byte;
  Param2:Cardinal;
  code3:byte;
end;

procedure SendTextInLobby(const Msg:String);
var hThread:THandle;
    MsgAddr:Pointer;
    MemAddr:Pointer;
    BytesWritten:Cardinal;
    ThreadID:Cardinal;
    ExitCode:Cardinal;
    DoSendText:TDoSendText;
begin
  if Game.ProcessHandle=0 then raise exception.create('Starcraft not running');
  //if Trainer.DWord[Addresses.Lobby]=0 then exception.create('Not in lobby');

  hThread:=0;
  MemAddr:=nil;
  try
    MemAddr := VirtualAllocEx(Game.ProcessHandle, nil, sizeof(TDoSendText)+length(Msg)+1, MEM_RESERVE or MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    if MemAddr=nil then raise exception.create('Could not allocate remote Memory '+GetLastErrorString);
    Cardinal(MsgAddr):=Cardinal(MemAddr)+sizeof(TDoSendText);

    DoSendText.Code1:=$BF;//mov EDX,Const
    DoSendText.Param1:=Cardinal(MsgAddr);
    DoSendText.Code2:=$E8;//call reladdr
    DoSendText.Param2:=Addresses.SendTextLobby-Cardinal(MemAddr)-10;
    DoSendText.Code3:=$C3;//ret

    if not WriteProcessMemory(Game.ProcessHandle, MemAddr, @DoSendText, sizeof(DoSendText), BytesWritten)
      then raise exception.create('WriteProcessMemory(Code) failed '+GetLastErrorString);
    if not WriteProcessMemory(Game.ProcessHandle, MsgAddr, PChar(Msg), length(Msg)+1, BytesWritten)
      then raise exception.create('WriteProcessMemory2(Msg) failed '+GetLastErrorString);

    hThread := CreateRemoteThread(Game.ProcessHandle, nil, 0, MemAddr, nil, 0, ThreadID);
    if hThread=0 then raise exception.create('CreateRemoteThread failed '+GetLastErrorString);

    if WaitForSingleObject(hThread, 30000)=WAIT_TIMEOUT
      then raise exception.create('Remote thread did not terminate');

    GetExitCodeThread(hThread, ExitCode);
    if(ExitCode=0)then raise exception.create('Remote SendTextInLobby failed');
  finally
    VirtualFreeEx(Game.ProcessHandle, MemAddr, sizeof(TDoSendText)+length(Msg)+1, MEM_RELEASE);
    closeHandle(hThread);
  end;
end;

end.
