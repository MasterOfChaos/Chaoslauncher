unit ChlApi;
interface

type TObjHandle=type pointer;
type TCallbackFunc=procedure(const ConstParam;var VarParam;var SkipOtherHandlers:LongBool);stdcall;

type TExecutionContext=type integer;
const
     ecUnknown             = 0;
     ecInjected            = 2;

var
ChlGetContext:function:TExecutionContext;stdcall;

//Gets some global handles
ChlHelperHandle:function:TObjHandle;stdcall;

//Destroys an object
ChlDestroy:procedure(Obj:TObjHandle);stdcall;

//Register to a callback, destroy handle with ChlDestroy afterwards
ChlCallbackSubscribe: function (Obj:TObjHandle;ID:PChar;Func:pointer;UserData:pointer;Priority:integer):TObjHandle;stdcall;

implementation
uses windows,sysutils,util;
const ChlApiDll='chlapi.dll';

var hChlApi:hModule;
    ChlFilename:String;
function FindChlApi(Path:string):String;overload;
begin
  result:='';
  while path<>'' do
   begin
    if fileexists(Path+ChlApiDll)
      then begin
        result:=Path+ChlApiDll;
        exit;
      end;
    if path<>'' then delete(path,length(path),1);
    path:=extractfilepath(path);
   end;
end;

function FindChlApi:String;overload;
begin
  result:=FindChlApi(extractfilepath(GetModuleFileName));
  if result<>'' then exit;  
  result:=FindChlApi(extractfilepath(paramstr(0)));
end;

function GetChlFunc(const Name:String):pointer;
begin
  result:=GetProcAddress(hChlApi,PChar(Name));
  if result=nil then raise exception.create('Could not find function '+Name+' in '+ChlFilename);
end;

initialization
  ChlFilename:=FindChlApi;
  if ChlFilename='' then raise exception.create('Could not find '+ChlApiDll);
  hChlApi:=LoadLibrary(Pchar(ChlFilename));
  if hChlApi=0 then raise exception.create('Could not load '+ChlFilename+' '+GetLastErrorString);
  ChlGetContext:=GetChlFunc('ChlGetContext');
  ChlHelperHandle:=GetChlFunc('ChlHelperHandle');
  ChlDestroy:=GetChlFunc('ChlDestroy');
  ChlCallbackSubscribe:=GetChlFunc('ChlCallbackSubscribe');
finalization
  FreeLibrary(hChlApi);
end.