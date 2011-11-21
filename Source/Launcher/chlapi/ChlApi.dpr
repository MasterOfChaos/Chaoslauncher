library ChlApi;

uses
  SysUtils,
  Classes,
  Callbacks in 'Callbacks.pas',
  ImplSC in 'ImplSC.pas',
  Sync in 'Sync.pas';

{$R *.res}

type TObjHandle=type pointer;

function ChlHelperHandle:TObjHandle;stdcall;
begin
  result:=TObjHandle(-1);
end;

//Destroys an object
procedure ChlDestroy(Obj:TObjHandle);stdcall;
begin
  TObject(Obj).free;
end;


//Register to a callback, destroy handle with ChlDestroy afterwards
function ChlCallbackSubscribe(Obj:TObjHandle;ID:PChar;Func:pointer;UserData:pointer;Priority:integer):TObjHandle;stdcall;
var sID:String;
    CallbackList:TCallbackList;
begin
  try
    AquireHelperMutex;
    result:=nil;
    if Obj<>ChlHelperHandle then exit;
    sID:=lowercase(String(ID));
    CallbackList:=nil;
    if sID='action' then CallbackList:=ActionCallback;
    if sID='timer' then CallbackList:=TimerCallback;
    if sID='ingame' then CallbackList:=IngameCallback;
    if sID='ingame2' then CallbackList:=Ingame2Callback;
    if CallbackList<>nil
      then result:=TCallback.create(CallbackList,Func,UserData,Priority);
  finally
    ReleaseHelperMutex;
  end;
end;

type TExecutionContext=type integer;
const
     ecUnknown             = 0;
     ecInjected            = 2;

function ChlGetContext:TExecutionContext;stdcall;
begin
  result:=0;
  if IsInjected then result:=2;
end;

exports ChlGetContext,ChlHelperHandle,ChlCallbackSubscribe,ChlDestroy;

begin
end.
