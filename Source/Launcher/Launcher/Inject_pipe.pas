unit Inject;

interface
uses Plugins;

Type TInjectionMethod=(imOverwrite);
procedure DoInject(InjectionMethod:TInjectionMethod;RunInfo:TRunInfo);

implementation
uses windows,classes,sysutils,Inject_Overwrite,streaming,util;


function WaitForStream(stm:TStream;TimeOut:integer;MinBytes:integer=1):boolean;
var Start:Cardinal;
begin
  Start:=GetTickCount;
  while Start+TimeOut>GetTickCount do
   begin
     if AvailableBytesInPipe(hPipe)>=MinBytes
       then begin
         result:=true;
         exit;
       end;
     sleep(1);
   end;
  result:=false;
end;

procedure DoInject(InjectionMethod:TInjectionMethod;RunInfo:TRunInfo);
var hPipe:THandle;
    stm:THandleStream;
const PIPE_REJECT_REMOTE_CLIENTS   =$00000008;
      FILE_FLAG_FIRST_PIPE_INSTANCE=$00080000;
begin
  hPipe:=0;
  stm:=nil;
  try
    hPipe:=CreateNamedPipe('ChaoslauncherInjection{529EB46C-A85C-4D4F-BB5A-6D2853B8D79A}',//Name
      PIPE_ACCESS_DUPLEX or FILE_FLAG_FIRST_PIPE_INSTANCE,//OpenMode
      PIPE_TYPE_BYTE or PIPE_READMODE_BYTE or PIPE_WAIT or PIPE_REJECT_REMOTE_CLIENTS,//PipeMode
      1,//MaxInstances
      $10000,//OutBufferSize
      $10000,//InBufferSize,
      1000,//DefaultTimeOut
      nil);//SecurityAttributes
    if hPipe=0 then raise exception('Error while injecting, could not create Pipe: '+GetLastErrorString);
    stm:=THandleStream.create(hPipe);
    case InjectionMethod of
       imOverwrite:InjectOverwrite(hPipe,FileToString(RunInfo.ScExecutable),RunInfo.LauncherPath+'ChaosInjector.dll',hProcess);
       else raise exception.create('Unknown injection method');
    end;
    if not WaitForPipe(hPipe,5000) then raise exception.create('Injectionhelper does not respond');

  finally
    stm.free;    
    if hPipe<>0
      then begin
        if not FlushFileBuffers(hPipe)then Log('Error while injecting, could not FlushFileBuffers: '+GetLastErrorString);
        if not DisconnectNamedPipe(hPipe)then Log('Error while injecting, could not DisconnectNamedPipe: '+GetLastErrorString);
        if not CloseHandle(hPipe)then Log('Error while injecting, could not close Pipe handle: '+GetLastErrorString);
      end;
  end;
end;


end.
