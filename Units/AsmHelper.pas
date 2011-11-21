unit AsmHelper;

interface
uses classes;
type TCPURegister32=packed record
  function hex:String;
  case integer of
   0:(int:integer;);
   1:(uint:cardinal;);
   2:(p:pointer;);
   3:(pb:pbyte;);
   4:(pw:pword;);
   5:(pd:pcardinal;);
   6:(pc:pchar;);
   7:(b:packed array[0..3] of byte);
   8:(w:packed array[0..1] of word);
end;

type TAddress=packed record
  class operator Implicit(APointer : Pointer): TAddress;inline;
  class operator Implicit(AUInt : Cardinal): TAddress;inline;
  function Hex:String;
  case integer of
    0:(p:pointer);
    1:(uint:Cardinal);
end;

type TCardinalArray=array[0..1shl 29-2]of Cardinal;
     PCardinalArray=^TCardinalArray;
type TCPUStack=type PCardinalArray;
type TCPUFlags32=type Cardinal;
type TCPUState=packed record   //Warning, layout is assumed in hardcoded asmcode
  private
    FMaxStackImbalance:integer;
    FOrigESP:Cardinal;
  public
    eax,ebx,ecx,edx,
    esp,ebp,esi,edi:TCPURegister32;
    Flags:TCPUFlags32;
    function Stack:TCPUStack;inline;
    procedure Push(Value:Cardinal);overload;
    procedure Push(Value:integer);overload;inline;
    procedure Push(Value:Pointer);overload;inline;
    function Pop:TCPURegister32;
    procedure SetStackImbalance(NewImbalance:integer;SafeStack0:boolean=false);
    function GetStackImbalance:integer;inline;
    function ToString:String;
end;

type TFunctionCallRegisters=packed record
  public
    eax,ebx,ecx,edx,esi,edi:TCPURegister32;
    Flags:TCPUFlags32;
    procedure FromCPUState(const State:TCPUState);
    procedure ToCPUState(out State:TCPUState);
end;

type TLowLevelFunction=procedure (var CPU:TCPUState);

function AddrToHex(const Addr:Cardinal):String;overload;
function AddrToHex(const Addr:pointer):String;overload;
function AddrToHex(const Addr:TCPURegister32):String;overload;

type THookFunction=class
  protected
    FPCode:TAddress;
    RefCount:integer;
  public
    property PCode:TAddress read FPCode;
    constructor Create(Func:TLowLevelFunction;MaxStackImbalance:integer=0);
    destructor Destroy;override;
end;

type TPatch=class
  private
    FApplied: boolean;
    FChilds:TList;
    FOwner:TPatch;
    FEnabled: boolean;
    procedure SetApplied(const Value: boolean);
    procedure AddChild(Child:TPatch);
    procedure RemoveChild(Child:TPatch);
    procedure SetEnabled(const Value: boolean);
    procedure UpdateApplied;
    function GetChildCount: integer;
    function GetChilds(Index: integer): TPatch;
  protected
    procedure DoApply;virtual;abstract;
    procedure DoRestore;virtual;abstract;
  public
    property Applied:boolean read FApplied;
    property Enabled:boolean read FEnabled write SetEnabled;
    property Owner:TPatch read FOwner;
    property Childs[Index:integer]:TPatch read GetChilds;
    property ChildCount:integer read GetChildCount;
    procedure AfterConstruction;override;
    constructor Create(AOwner:TPatch);
    destructor Destroy;override;
end;

type TPatchGroup=class(TPatch)
  protected
    procedure DoApply;override;
    procedure DoRestore;override;
end;


type TStringPatch=class(TPatch)
  private
    FBackup:String;
    FAddr:TAddress;
    function GetStr:String;
  protected
    FStr:String;
    FStrValid:boolean;
    function GetString:String;virtual;abstract;
    procedure DoApply;override;
    procedure DoRestore;override;
  public
    property Addr:TAddress read FAddr;
    property Str:String read GetStr;
    constructor Create(AOwner:TPatch;AAddr:TAddress);
end;

type TManualStringPatch=class(TStringPatch)
  private
  protected
    function GetString:String;override;
  public
    constructor Create(AOwner:TPatch;AAddr:TAddress;const S:String);
end;


type THookPatch=class(TStringPatch)
  private
    FHook: THookFunction;
  protected
  published
  public
    property Hook:THookFunction read FHook;
    constructor Create(AOwner:TPatch;AAddr:TAddress;AHook:THookFunction);
    destructor Destroy;override;
end;

type TCallPatch=class(THookPatch)
  private
    FNOPs: integer;
    FRetAfter: boolean;
  protected
    function GetString:String;override;
  public
    property RetAfter:boolean read FRetAfter;
    property NOPs:integer read FNOPs;
    constructor Create(AOwner:TPatch;AAddr:TAddress;AHook:THookFunction;ARetAfter:boolean=false;ANOPs:integer=0);
end;

type TRawCallPatch=class(TStringPatch)
  private
    FNOPs: integer;
    FRetAfter: boolean;
    FFunc:pointer;
  protected
    function GetString:String;override;
  public
    property Func:pointer read FFunc;
    property RetAfter:boolean read FRetAfter;
    property NOPs:integer read FNOPs;
    constructor Create(AOwner:TPatch;AAddr:TAddress;AFunc:pointer;ARetAfter:boolean=false;ANOPs:integer=0);
end;

type TNOPPatch=class(TStringPatch)
  private
    FCount: integer;
  published
    function GetString:String;override;
  public
    property Count:integer read FCount;
    constructor Create(AOwner:TPatch;AAddr:TAddress;ACount:integer);
end;


type TDynamicDWordArray=array of Cardinal;
procedure CallFunction(Func:TAddress;var Registers:TFunctionCallRegisters;var StackData:TDynamicDWordArray);overload;
procedure CallFunction(Func:TAddress;var Registers:TFunctionCallRegisters;StackData:array of const);overload;

function WriteString(Addr:TAddress;const S:String;hProcess:THandle=0):boolean;
function WriteMemory(Addr:TAddress;p:pointer;size:integer;hProcess:THandle=0):boolean;
function ReadString(Addr:TAddress;Length:integer;hProcess:THandle=0):String;
function GetAsmCallPatch(Addr:TAddress;const Func:TAddress;const NOPs:integer=0;RetAfter:boolean=false):String;
function GetAsmJumpPatch(Addr:TAddress;const Func:TAddress):String;
//procedure AsmJumpPatch(Addr:Cardinal;const Func:pointer;const NOPs:Cardinal=0);
type TIATArray=array of PPointer;
type TPointerArray=array of Pointer;
function FindIATs(ImportingModule:HModule;ExportingDllName,FuncName:PChar):TIATArray;
function SetIATs(ImportingModule:HModule;ExportingDllName,FuncName:PChar;pNewFunc:pointer):TPointerArray;
procedure SetIATs2(ImportingModule:HModule;ExportingDllName,FuncName:PChar;pNewFunc:pointer);

implementation
uses windows,util,logger,sysutils,rtlconsts;

const CPUStateSize=44;
      MagicMaxStackImbalance     =$BEAF0001;
      MagicMaxStackImbalanceBytes=$BEAF0002;
      MagicFunction              =$BEAF0003;
      MagicEndOfFunction         =$BEAF0000;
var   LowLevelFunctionWrapperSize:cardinal;
//Stacklayout CPUState,StackImbalance,RetAddr
procedure LowLevelFunctionWrapper;
asm
  PUSHFD;
  sub esp,(CPUStateSize-4)//4 for PUSHFD
  sub esp,MagicMaxStackImbalanceBytes;
  //esp now points to beginning of CPUState
  mov [esp+08],eax;//CPU.eax
  mov eax,esp;
  add eax,(CPUStateSize-4)+8  //4 for retaddr and 4 for PUSHFD
  add eax,MagicMaxStackImbalanceBytes;
  //eax now points behind RetAddr
  mov [esp+00],MagicMaxStackImbalance;//CPU.FMaxStackImbalance
  mov [esp+04],eax;//CPU.FOrigESP
  //               //CPU.eax already filled in
  mov [esp+12],ebx;//CPU.ebx
  mov [esp+16],ecx;//CPU.ecx
  mov [esp+20],edx;//CPU.edx
  mov [esp+24],eax;//CPU.esp, eax=esp before entering the WrapperFunction
  mov [esp+28],ebp;//CPU.ebp
  mov [esp+32],esi;//CPU.esi
  mov [esp+36],edi;//CPU.edi
  sub eax,8;
  //eax now points to the pushed Flags
  mov eax,[eax]
  mov [esp+40],eax //CPU.Flags
  mov eax,esp;//CPU as first param
  db $E8;//Call
  dd MagicFunction;
  mov eax,[esp+24];//CPU.esp
  sub eax,4;
  mov [esp+24],eax;
  //[esp+24] now points to RetAddr
  mov eax,esp
  add esp,40    //esp points at CPU.flags
  POPFD;        //pop the FLAGS
  //mov does not change the FLAGS
  mov esp,eax   //restore esp, points to beginning of CPUState
  mov eax,[esp+08];//CPU.eax
  mov ebx,[esp+12];//CPU.ebx
  mov ecx,[esp+16];//CPU.ecx
  mov edx,[esp+20];//CPU.edx
  mov ebp,[esp+28];//CPU.ebp
  mov esi,[esp+32];//CPU.esi
  mov edi,[esp+36];//CPU.edi
  mov esp,[esp+24];//CPU.esp
  ret;
  dd MagicEndOfFunction;
end;

function GetLowLevelFunctionWrapperSize:integer;
var Addr:pointer;
begin
  Addr:=@LowLevelFunctionWrapper;
  while DWord(Addr^)<>MagicEndOfFunction do
   begin
     inc(Cardinal(Addr));
   end;
  result:=Cardinal(Addr)-Cardinal(@LowLevelFunctionWrapper);
end;

function WriteMemory(Addr:TAddress;p:pointer;size:integer;hProcess:THandle=0):boolean;
var OldProtect,OldProtect2:Cardinal;
begin
  result:=false;
  if hProcess=0
    then try
      if not VirtualProtect(pointer(Addr),size,PAGE_EXECUTE_READWRITE,OldProtect)
        then Log('WriteMemory($'+Addr.hex+','''+MemToHex(p^,size)+''') failed in first VirtualProtect with '+GetLastErrorString);
      move(p^,Addr.p^,size);
      if not VirtualProtect(pointer(Addr),size,OldProtect,OldProtect2)
        then Log('WriteMemory($'+Addr.hex+','''+MemToHex(p^,size)+''') failed in second VirtualProtect with '+GetLastErrorString);
      result:=true;
    except
      on e:exception do
        Log('WriteMemory($'+Addr.hex+','''+MemToHex(p^,size)+''') caused an exeptio in move '+e.message);
    end
    else try
      if not VirtualProtectEx(hProcess,pointer(Addr),size,PAGE_EXECUTE_READWRITE,OldProtect)
        then Log('WriteMemory($'+Addr.hex+','''+MemToHex(p^,size)+''') failed in first VirtualProtect with '+GetLastErrorString);
      if not WriteProcessMemory(hProcess,Pointer(Addr),p,size,Cardinal(nil^))
        then raise exception.create('WriteProcessMemory failed '+GetLastErrorString);
      if not VirtualProtectEx(hProcess,pointer(Addr),size,OldProtect,OldProtect2)
        then Log('WriteMemory($'+Addr.hex+','''+MemToHex(p^,size)+''') failed in second VirtualProtect with '+GetLastErrorString);
      result:=true;
    except
      on e:exception do
        Log('WriteMemory($'+Addr.hex+','''+MemToHex(p^,size)+''') caused an exeption in move '+e.message);
    end;
end;

function WriteString(Addr:TAddress;const S:String;hProcess:THandle=0):boolean;
begin
  result:=WriteMemory(Addr,PChar(S),length(S),hProcess);
end;

function ReadString(Addr:TAddress;Length:integer;hProcess:THandle=0):String;
begin
  setlength(result,Length);
  UniqueString(result);
  if hProcess=0
    then move(Pointer(Addr)^,result[1],Length)
    else if not ReadProcessMemory(hProcess,Pointer(Addr),Pchar(result),length,PCardinal(nil)^)
      then raise exception.create('ReadProcessMemory failed '+GetLastErrorString);
end;

function GetAsmCallPatch(Addr:TAddress;const Func:TAddress;const NOPs:integer;RetAfter:boolean):String;
var i:integer;
    RelPointer:Cardinal;
begin
  setlength(result,5);
  result[1]:=#$E8;
  RelPointer:=Cardinal(int64(Func.uint)-int64(Addr.uint)-5);
  move(RelPointer,result[2],4);
  if RetAfter
    then result:=result+#$C3;
  for i:=0 to NOPs-1 do
    result:=result+#$90;
end;

function GetAsmJumpPatch(Addr:TAddress;const Func:TAddress):String;
var RelPointer:Cardinal;
begin
  setlength(result,5);
  result[1]:=#$E9;
  RelPointer:=Cardinal(int64(Func.uint)-int64(Addr.uint)-5);
  move(RelPointer,result[2],4);
end;

{procedure AsmJumpPatch(Addr:Cardinal;const Func:pointer;const NOPs:Cardinal);
var i:integer;
    S:String;
    RelPointer:Cardinal;
begin
  setlength(S,NOPs+5);
  S[1]:=#$E9;
  RelPointer:=Cardinal(Func)-Addr-5;
  move(RelPointer,S[2],4);
  for i:=0 to NOPs-1 do
    S[6+i]:=#$90;
  WriteString(Addr,S);
end;   }
procedure CallFunction(Func:TAddress;var Registers:TFunctionCallRegisters;var StackData:TDynamicDWordArray);
var esp1,esp2,StackCount:Cardinal;
begin
 StackCount:=length(StackData);
 asm
  //Save Delphregisters
  pushfd;
  pushad;
  mov esp1,esp;
  //Push all Stackparams
  mov eax,StackCount;
  mov ebx,[StackData];
  mov ebx,[ebx];
  @pushloop:
  sub eax,1;
  push [ebx+eax*4]
  cmp eax,0;
  jne @pushloop;

  //Load Registers&Flags from the Registers-Parameter
  mov eax,[registers]
  push [eax+24];
  mov edi,[eax+20];
  mov esi,[eax+16];
  mov edx,[eax+12];
  mov ecx,[eax+08];
  mov ebx,[eax+04];
  mov eax,[eax+00];
  popfd;
  //Call the function
  call Func;

  //Save Registers&Flags to the Registers-Parameter
  pushfd;
  push eax;
  mov eax,[registers]
  pop [eax+00];
  mov [eax+04],ebx;
  mov [eax+08],ecx;
  mov [eax+12],edx;
  mov [eax+16],esi;
  mov [eax+20],edi;
  pop [eax+24];
  mov esp2,esp;

  //Restore DelphiRegisters
  mov esp,esp1;
  popad;
  popfd;
  mov esp,esp2;
 end;
 setlength(StackData,(esp1-esp2)shr 2);
 move(pointer(esp2)^,Pointer(StackData)^,esp1-esp2);
 asm
  mov esp,esp1;
  popad;
  popfd;
 end;
end;

procedure CallFunction(Func:TAddress;var Registers:TFunctionCallRegisters;StackData:array of const);overload;
var stack:TDynamicDWordArray;
    i:integer;
begin
  setlength(stack,length(StackData));
  for i:=0 to length(StackData)-1do
   case StackData[i].VType of
      vtInteger:    Stack[i]:=Cardinal(StackData[i].VInteger);
      vtBoolean:    Stack[i]:=Cardinal(StackData[i].VBoolean);
      vtChar:       Stack[i]:=Cardinal(StackData[i].VChar);
      vtExtended:   Stack[i]:=Cardinal(StackData[i].VExtended);
      vtPointer:    Stack[i]:=Cardinal(StackData[i].VPointer);
      vtPChar:      Stack[i]:=Cardinal(StackData[i].VPChar);
      vtObject:     Stack[i]:=Cardinal(StackData[i].VObject);
      vtClass:      Stack[i]:=Cardinal(StackData[i].VClass);
      vtWideChar:   Stack[i]:=Cardinal(StackData[i].VWideChar);
      vtPWideChar:  Stack[i]:=Cardinal(StackData[i].VPWideChar);
      vtAnsiString: Stack[i]:=Cardinal(StackData[i].VAnsiString);
      vtCurrency:   Stack[i]:=Cardinal(StackData[i].VCurrency);
      vtVariant:    Stack[i]:=Cardinal(StackData[i].VVariant);
      vtInterface:  Stack[i]:=Cardinal(StackData[i].VInterface);
      vtWideString: Stack[i]:=Cardinal(StackData[i].VWideString);
      vtInt64:      Stack[i]:=Cardinal(StackData[i].VInt64);
     else raise exception.create('Type not supported for StackData');
   end;
  CallFunction(Func,Registers,Stack);
end;

function AddrToHex(const Addr:Cardinal):String;
begin
  result:=inttohex(Addr,8);
end;

function AddrToHex(const Addr:pointer):String;
begin
  result:=inttohex(Cardinal(Addr),8);
end;

function AddrToHex(const Addr:TCPURegister32):String;
begin
  result:=inttohex(Addr.uint,8);
end;

type TIMAGE_IMPORT_DESCRIPTOR=packed record
  OriginalFirstThunk:Cardinal;
  TimeDateStamp:Cardinal;
  ForwarderChain:Cardinal;
  Name:Cardinal;
  FirstThunk:Cardinal;
 end;
type PIMAGE_IMPORT_DESCRIPTOR=^TIMAGE_IMPORT_DESCRIPTOR;

function FindIATs(ImportingModule:HModule;ExportingDllName,FuncName:PChar):TIATArray;
var pDosHeader:PImageDosHeader;
    pNTHeaders:PImageNtHeaders;
    pImportDesc:PIMAGE_IMPORT_DESCRIPTOR;
    pThunk:PCardinal;
    pOldFunc:pointer;
    ModName:PChar;
    ExportingModule:hModule;
    ImportDescOffset:Cardinal;
begin
  if (importingmodule=0) then raise exception.create('Importing module must not be nil');

  result:=nil;
  //Get exporting module
  ExportingModule:=GetModuleHandle(ExportingDllName);
  if ExportingModule=0
    then raise exception.create('Exporting module not loaded');

  //Get the address it is currently exporting
  pOldFunc:=GetProcAddress(ExportingModule,FuncName);
  if pOldFunc=nil
    then raise exception.create(ExportingDllName+' does not export the function '+FuncName);

  //Get Image DOS Header
  pDosHeader := PImageDosHeader(ImportingModule);
  if pDosHeader.e_magic<>IMAGE_DOS_SIGNATURE
    then raise exception.create('Invalid Executable: Corrupted DOS Signature');

  // Get NTHeaders
  pNTHeaders:=PImageNTHeaders(Cardinal(pDosHeader)+Cardinal(pDosHeader._lfanew));
  if pNTHeaders.Signature<>IMAGE_NT_SIGNATURE
    then raise exception.create('Invalid Executable: Corrupted NT Signature');

  // Get Imports Section
  ImportDescOffset:=pNTHeaders.OptionalHeader.
                    DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;
  if ImportDescOffset=0//No Imports Section
    then exit;
  pImportDesc:=PIMAGE_IMPORT_DESCRIPTOR(ImportingModule+ImportDescOffset);

  //Find import section for the module
  while pImportDesc.Name<>0 do
   begin
    ModName := PChar(ImportingModule+pImportDesc.Name);
    if Uppercase(ExportingDllName)=Uppercase(ModName)
      then begin
        // Get a pointer to the found module's import address table (IAT)
        pThunk := PCardinal(ImportingModule+pImportDesc.FirstThunk);

        // Find the function
        while pThunk^<>0 do
        begin
          if pThunk^=Cardinal(pOldFunc)
            then begin
              setlength(result,length(result)+1);
              result[high(result)]:=PPointer(pThunk);
            end;
          inc(pThunk);
        end;
      end;
    inc(pImportDesc);
   end;
end;


function SetIATs(ImportingModule:HModule;ExportingDllName,FuncName:PChar;pNewFunc:pointer):TPointerArray;
var IATs:TIATArray;
    i:integer;
begin
  result:=nil;
  //A nil IAT entry damages the IAT table
  if pNewFunc=nil then raise exception.create('Don''t hook using a nil function');
  result:=nil;
  Log('Hooking IAT for '+ExportingDllName+'::'+FuncName+' in module '+GetModuleFilename(ImportingModule));
  IATs:=FindIATs(ImportingModule,ExportingDllName,FuncName);
  if length(IATs)=0
    then begin
      Log('Warning: No IAT present');
      exit;
    end;
  setlength(Result,length(IATs));
  for I := 0 to length(IATs)-1 do
   begin
    result[i]:=IATs[i]^;
    Log('Patching IAT at '+TAddress(IATs[i]).Hex+' ('+TAddress(IATs[i]^).Hex+'=>'+TAddress(pNewFunc).Hex+')');
    WriteMemory(IATs[i],@pNewFunc,sizeof(pNewFunc));
   end;
end;

procedure SetIATs2(ImportingModule:HModule;ExportingDllName,FuncName:PChar;pNewFunc:pointer);
var OrgIATs:TPointerArray;
    i:integer;
begin
  OrgIATs:=SetIATs(ImportingModule,ExportingDllName,FuncName,pNewFunc);
  for I:=0 to length(OrgIATs)-1do
    if OrgIATs[i]<>GetProcAddress(GetModuleHandle(ExportingDllName),FuncName)
      then Log('Warning '+ExportingDllName+'::'+FuncName+' already hooked by '+GetModuleFilename(ModuleFromAddr(OrgIATs[i]))
             +'. Old hook was overwritten, which might cause the other module to malfunction');
end;

{ TCPUState }

function TCPUState.GetStackImbalance: integer;
begin
  result:=esp.uint-FOrigESP;
end;

function TCPUState.Pop: TCPURegister32;
var RetAddr:pointer;
begin
  RetAddr:=ppointer(esp.uint-4)^;
  result.uint:=esp.pd^;
  inc(esp.uint,4);
  ppointer(esp.uint-4)^:=RetAddr;
end;

procedure TCPUState.Push(Value: Pointer);
begin
  Push(Cardinal(Value));
end;

procedure TCPUState.Push(Value: integer);
begin
  Push(Cardinal(Value));
end;

procedure TCPUState.Push(Value: Cardinal);
begin
  SetStackImbalance(GetStackImbalance+1);
  Stack[0]:=Value;
end;

procedure TCPUState.SetStackImbalance(NewImbalance:integer;SafeStack0:boolean=false);
var RetAddr:pointer;
    Stack0:Cardinal;
begin
  if NewImbalance>FMaxStackImbalance
    then begin
      Log('StackImbalance is larger than allowed');
      raise exception.Create('StackImbalance is larger than allowed');
    end;
  RetAddr:=ppointer(esp.uint-4)^;
  if SafeStack0 then Stack0:=Stack[0];
  esp.int:=FOrigESP-NewImbalance;
  if SafeStack0 then Stack[0]:=Stack0;
  ppointer(esp.uint-4)^:=RetAddr;
end;

function TCPUState.Stack: TCPUStack;
begin
  result:=TCPUStack(esp);
end;

function TCPUState.ToString: String;
begin
    result:=
    'eax='+eax.hex+#13#10+
    'ebx='+ebx.hex+#13#10+
    'ecx='+ecx.hex+#13#10+
    'edx='+edx.hex+#13#10+
    'esp='+esp.hex+#13#10+
    'ebp='+ebp.hex+#13#10+
    'esi='+esi.hex+#13#10+
    'edi='+edi.hex+#13#10+
    'efl='+AddrToHex(flags);
end;

{ TCPURegister32 }

function TCPURegister32.hex: String;
begin
  result:=AddrToHex(self);
end;

{ THookFunction }

constructor THookFunction.Create(Func: TLowLevelFunction;
  MaxStackImbalance: integer);
var Addr:pointer;
    p:PCardinal;
    OldProtect:Cardinal;
    i:integer;
begin
  RefCount:=0;
  FPCode:=nil;
  addr:=VirtualAlloc(nil,LowLevelFunctionWrapperSize,MEM_COMMIT,PAGE_READWRITE);
  if addr=nil
    then raise exception.create('THookFunction.Create failed in VirtualAlloc '+GetLastErrorString);
  move((@LowLevelFunctionWrapper)^,addr^,LowLevelFunctionWrapperSize);
  p:=addr;
  for i:=0 to LowLevelFunctionWrapperSize-4 do
   begin
      if p^=MagicMaxStackImbalance
        then p^:=MaxStackImbalance;
      if p^=MagicMaxStackImbalanceBytes
        then p^:=MaxStackImbalance;
      if p^=MagicFunction
        then begin
          p^:=Cardinal(int64(@Func)-int64(p)-4);
        end;
     inc(Cardinal(p));//1 byte, not 1 DWord further!
   end;
  OldProtect:=0;
  if not VirtualProtect(addr,LowLevelFunctionWrapperSize,PAGE_EXECUTE,OldProtect)
    then raise exception.create('THookFunction.Create failed in VirtualProtect '+GetLastErrorString);
  FPCode:=addr;
end;

destructor THookFunction.Destroy;
begin
  if RefCount>0
    then raise exception.create('HookFunction destroyed before Hooks. RefCount='+inttostr(RefCount));
  if pCode.p<>nil then
    if not VirtualFree(pCode.p,LowLevelFunctionWrapperSize,MEM_RELEASE)
      then Log('THookFunction.Destroy failed in VirtualFree '+GetLastErrorString);
  inherited;
end;

{ TCallPatch }

constructor THookPatch.Create(AOwner:TPatch;AAddr: TAddress; AHook: THookFunction);
begin
  inherited Create(AOwner,AAddr);
  FHook:=AHook;
  inc(Hook.RefCount);
end;

destructor THookPatch.Destroy;
begin
  dec(Hook.RefCount);
  inherited;
end;

procedure TPatch.AddChild(Child: TPatch);
begin
  if FChilds=nil then FChilds:=TList.create;
  FChilds.Add(Child)
end;

procedure TPatch.AfterConstruction;
begin
  inherited;
  Enabled:=Owner<>nil;
end;

constructor TPatch.Create(AOwner:TPatch);
begin
  FApplied:=false;
  FEnabled:=False;
  FOwner:=AOwner;
  if Owner<>nil
    then Owner.AddChild(self);
  Enabled:=Owner<>nil;
end;

destructor TPatch.Destroy;
begin
  Enabled:=false;
  if FOwner<>nil then Owner.RemoveChild(self);
  while ChildCount>0 do
    Childs[0].free;
  FChilds.free;
  inherited;
end;

function TPatch.GetChildCount: integer;
begin
  if FChilds=nil
    then result:=0
    else result:=FChilds.Count;
end;

function TPatch.GetChilds(Index: integer): TPatch;
begin
  if FChilds=nil then TList.Error(@SListIndexError, Index);
  result:=TPatch(FChilds[Index]);
end;

procedure TPatch.RemoveChild(Child: TPatch);
begin
  FChilds.Remove(Child);
  if FChilds.Count=0 then FreeAndNil(FChilds);
end;

procedure TPatch.SetApplied(const Value: boolean);
var i:integer;
begin
  if Value=FApplied then exit;
  if Value
    then DoApply
    else DoRestore;
  FApplied:=Value;
  for i:=0 to ChildCount-1 do
    Childs[i].UpdateApplied;
end;

procedure TPatch.SetEnabled(const Value: boolean);
begin
  if FEnabled=Value then exit;
  FEnabled := Value;
  UpdateApplied;
end;

procedure TPatch.UpdateApplied;
begin
  if Owner=nil
    then SetApplied(Enabled)
    else SetApplied(Enabled and Owner.Applied);
end;

{ TCallPatch }

constructor TCallPatch.Create(AOwner:TPatch;AAddr: TAddress; AHook: THookFunction;
  ARetAfter: boolean; ANOPs: integer);
begin
  inherited Create(AOwner,AAddr,AHook);
  FNOPs:=ANOPs;
  FRetAfter:=ARetAfter;
end;

function TCallPatch.GetString: String;
begin
  result:=GetAsmCallPatch(Addr,Hook.PCode,NOPs,RetAfter);
end;

{ TStringPatch }

constructor TStringPatch.Create(AOwner:TPatch;AAddr:TAddress);
begin
  inherited Create(AOwner);
  FAddr:=AAddr;
  FStrValid:=false;
end;

procedure TStringPatch.DoApply;
begin
  inherited;
  FBackup:=ReadString(Addr,length(Str));
  WriteString(Addr,Str);
end;

procedure TStringPatch.DoRestore;
begin
  inherited;
  WriteString(Addr,FBackup);
end;

function TStringPatch.GetStr: String;
begin
  if not FStrValid then FStr:=GetString;
  result:=FStr;
end;

{ TAddress }

class operator TAddress.Implicit(APointer: Pointer): TAddress;
begin
  result.p:=APointer;
end;

function TAddress.Hex: String;
begin
  result:=IntToHex(uint,8);
end;

class operator TAddress.Implicit(AUInt: Cardinal): TAddress;
begin
  result.uint:=AUInt;
end;

{ TPatchGroup }

procedure TPatchGroup.DoApply;
begin
  //Do Nothing
end;

procedure TPatchGroup.DoRestore;
begin
  //Do Nothing
end;

{ TFunctionCallRegisters }

procedure TFunctionCallRegisters.FromCPUState(const State: TCPUState);
begin
  eax:=State.eax;
  ebx:=State.ebx;
  ecx:=State.ecx;
  edx:=State.edx;
  edi:=State.edi;
  esi:=State.esi;
  flags:=State.Flags;
end;

procedure TFunctionCallRegisters.ToCPUState(out State: TCPUState);
begin
  State.eax:=eax;
  State.ebx:=ebx;
  State.ecx:=ecx;
  State.edx:=edx;
  State.edi:=edi;
  State.esi:=esi;
  State.flags:=Flags;
end;

{ TNOPPatch }

constructor TNOPPatch.Create(AOwner: TPatch; AAddr: TAddress; ACount: integer);
begin
  inherited Create(AOwner,AAddr);
  FCount:=ACount;
end;

function TNOPPatch.GetString: String;
var
  i: Integer;
begin
 setlength(result,Count);
 for i:=1 to Count do
   result[i]:=#$90;//NOP
end;

{ TManualStringPatch }

constructor TManualStringPatch.Create(AOwner: TPatch; AAddr: TAddress;
  const S: String);
begin
  inherited Create(AOwner,AAddr);
  FStr:=S;
end;

function TManualStringPatch.GetString: String;
begin
  result:=FStr;
end;

{ TRawCallPatch }

constructor TRawCallPatch.Create(AOwner: TPatch; AAddr: TAddress;
  AFunc: pointer; ARetAfter: boolean; ANOPs: integer);
begin
  inherited Create(AOwner,AAddr);
  FNOPs:=ANOPs;
  FRetAfter:=ARetAfter;
  FFunc:=AFunc;
end;

function TRawCallPatch.GetString: String;
begin
  result:=GetAsmCallPatch(Addr,Func,NOPs,RetAfter);
end;

initialization
  LowLevelFunctionWrapperSize:=GetLowLevelFunctionWrapperSize;
end.
