unit ChlApi;

type TObjHandle=type pointer;
type TCallbackFunc=procedure(const ConstParam;var VarParam;var SkipOtherHandlers:LongBool);stdcall;

type TApiVersion=packed record
  ApiMinor:Word;//Major version of LauncherAPI, Must be equal to expected version 
  ApiMajor:Word;//Minor version of LauncherAPI, Must more or equal than the expected version
 end;

const RequiredApiMajor=1;
      RequiredApiMinor=0;

type TCompatibility=type integer;
const coUnknown            = 0;
      coForbidden          = 1;
      coIncompatible       = 2;
      coPartiallyCompatible= 3;
      coCompatible         = 4;
      coRequired           = 5;

type TBanRisk=type integer;
const brUnknown            = 0;
      brNone               = 1;
      brLow                = 2;
      brMedium             = 3;
      brHigh               = 4;

type TLogImportance=type integer;// RFC 3164
const
     liEmergency           = 0; //system is unusable
     liAlert               = 1; //action must be taken immediately
     liCritical            = 2; //critical conditions
     liError               = 3; //error conditions
     liWarning             = 4; //warning conditions
     liNotice              = 5; //normal but significant condition
     liInformational       = 6; //informational messages
     liDebug               = 7; //debug-level messages

type TExecutionContext=type integer;
const
     ecUnknown             = 0;
     ecLauncher            = 1;
     ecInjected            = 2;

const ChlApiDll='chlapi.dll';
 
function ChlApiVersion:TApiVersion;external ChlApiDll;
function ChlGameID:PChar;external ChlApiDll;
function ChlGetProcAddress(Obj:TObjHandle;ID:PChar):pointer;stdcall;external ChlApiDll;
function ChlLog(Module:TObjHandle;Importance:TLogImportance;Message:PChar):BOOL;stdcall;external ChlApiDll;
function ChlGetContext:TExecutionContext;stdcall;external ChlApiDll;

//Gets some global handles
function ChlLauncherHandle:TObjHandle;stdcall;external ChlApiDll;
function ChlGameHandle:TObjHandle;stdcall;external ChlApiDll;
function ChlHelperHandle:TObjHandle;stdcall;external ChlApiDll;

//Read/Write properties
function ChlPropertyExists(Obj:TObjHandle;ID:PChar):BOOL;external ChlApiDll;
function ChlGetStrLen(Obj:TObjHandle;ID:PChar;out StrLen:integer):BOOL;stdcall;external ChlApiDll;//Excluding the terminal #0, so required buffersize is one more
function ChlGetStr(Obj:TObjHandle;ID:PChar;Value:PChar;BufferSize:integer):BOOL;stdcall;external ChlApiDll;
function ChlSetStr(Obj:TObjHandle;ID:PChar;Value:PChar):BOOL;stdcall;external ChlApiDll;
function ChlGetBin(Obj:TObjHandle;ID:PChar;Buffer:pointer;out Size:integer;BufferSize:integer):BOOL;stdcall;external ChlApiDll;
function ChlSetBin(Obj:TObjHandle;ID:PChar;Buffer:pointer;Size:integer):BOOL;stdcall;external ChlApiDll;
function ChlGetBinSize(Obj:TObjHandle;ID:PChar;out Size:integer);stdcall;external ChlApiDll;
function ChlGetInt(Obj:TObjHandle;ID:PChar;out Value:integer):BOOL;stdcall;external ChlApiDll;
function ChlSetInt(Obj:TObjHandle;ID:PChar;Value:integer):BOOL;stdcall;external ChlApiDll;
function ChlGetBool(Obj:TObjHandle;ID:PChar;out Value:BOOL):BOOL;stdcall;external ChlApiDll;
function ChlSetBool(Obj:TObjHandle;ID:PChar;Value:BOOL):BOOL;stdcall;external ChlApiDll;
function ChlGetEvent(Obj:TObjHandler;ID:PChar;out Proc:pointer;out UserData:pointer):BOOL;stdcall;external ChlApiDll;
function ChlSetEvent(Obj:TObjHandle;ID:PChar;Proc:pointer;UserData:pointer):BOOL;stdcall;external ChlApiDll;
function ChlGetVersion(Obj:TObjHandle;ID:PChar;out Version:TVersion):BOOL;stdcall;external ChlApiDll;
function ChlSetVersion(Obj:TObjHandle;ID:PChar;const Version:TVersion):BOOL;stdcall;external ChlApiDll;

//Get a SystemHandle which must be closed with CloseHandle
function ChlOpenSysHandle(Obj:TObjHandle;ID:PChar;out Handle:THandle):BOOL;stdcall;external ChlApiDll;

//Creates an object of the specified type
function ChlCreate(ObjType:PChar):TObjHandle;stdcall;external ChlApiDll;

//Destroys an object
function ChlDestroy(Obj:TObjHandle);stdcall;external ChlApiDll;

//Register to a callback, destroy handle with ChlDestroy afterwards
function ChlCallbackSubscribe(Obj:TObjHandle;ID:PChar;Func:pointer;UserData:pointer;Priority:integer):TObjHandle;stdcall;external ChlApiDll;

//Creates a patch object
function ChlCreatePatch(OwnerPatch:TObjHandle;Name:PChar;Offset:pointer;Size:Cardinal):TObjHandle;stdcall;external ChlApiDll;