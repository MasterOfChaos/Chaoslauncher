unit Patcher;

interface

uses
  Windows,Sysutils;

type
  TCustomPatch = class(TObject)
  private
    FLittleEndFirst: boolean;
    function GetByte(Index: Cardinal): byte;
    function GetDWord(Index: Cardinal): Cardinal;
    function GetLongInt(Index: Cardinal): Longint;
    function GetShortInt(Index: Cardinal): ShortInt;
    function GetSmallInt(Index: Cardinal): SmallInt;
    function GetWord(Index: Cardinal): Word;
    procedure SetByte(Index: Cardinal; const Value: byte);
    procedure SetDWord(Index: Cardinal; const Value: Cardinal);
    procedure SetLongInt(Index: Cardinal; const Value: Longint);
    procedure SetShortInt(Index: Cardinal; const Value: ShortInt);
    procedure SetSmallInt(Index: Cardinal; const Value: SmallInt);
    procedure SetWord(Index: Cardinal; const Value: Word);

  protected
  public
   procedure Read (Index:cardinal;Size:integer;var   x;LittleEndFirst:boolean);virtual;abstract;
   Procedure Write(Index:cardinal;Size:integer;const x;LittleEndFirst:boolean);virtual;abstract;
   Property Byte[Index: Cardinal]:byte read GetByte write SetByte;
   Property Word[Index: Cardinal]:Word read GetWord write SetWord;
   Property DWord[Index: Cardinal]:Cardinal read GetDWord write SetDWord;
   Property ShortInt[Index: Cardinal]:ShortInt read GetShortInt write SetShortInt;
   Property SmallInt[Index: Cardinal]:SmallInt read GetSmallInt write SetSmallInt;
   Property LongInt[Index: Cardinal]:Longint read GetLongInt write SetLongInt;
   Property LittleEndFirst:boolean read FLittleEndFirst write FLittleEndFirst;
   function ReadStrZT(Addr:Cardinal;MaxSize:integer):String;
   {Property SetStr[Index: Cardinal]:string write SetStr_;
   Property GetHex[Index: Cardinal]:String read GetHex_;
   Property SetHex[Index: Cardinal]:String write SetHex_; }
  end;

type TPatch=class(TCustomPatch)
  private
    FFilename: String;
  protected
   F:file of Byte;
  public
   procedure Read (Index:Cardinal;Size:integer;var   x;LittleEndFirst:boolean);override;
   Procedure Write(Index:Cardinal;Size:integer;const x;LittleEndFirst:boolean);override;
   Property Filename:String read FFilename;
   Constructor create(Filename:string);overload;
   Constructor create;overload;
   destructor Destroy;override;
   procedure Open(Filename:String);
   procedure Close;
 end;

type TTrainer=class(TCustomPatch)
  private
    function GetRunning: boolean;
  protected
   WindowHandle: Integer;
   ProcessId: Integer;
   ThreadId: Integer;
   ProcessHandle: THandle;
   OwnsHandle:boolean;
  public
   property Running:boolean read GetRunning;
   procedure Read (Index:Cardinal;Size:integer;var   x;LittleEndFirst:boolean);override;
   Procedure Write(Index:Cardinal;Size:integer;const x;LittleEndFirst:boolean);override;
   Constructor Create;
   destructor Destroy;override;
   procedure OpenWindowHandle(Handle:integer);
   procedure OpenProcessHandle(Handle:integer);
   procedure OpenProcessID(ProcessID:integer);
   procedure Close;
 end;

implementation
uses util;
Type Bytearray=array of byte;

{ TCustomPatch }


function TCustomPatch.GetByte(Index: Cardinal): byte;
begin
 read(index,1,result,LittleEndFirst);
end;


procedure TCustomPatch.SetByte(Index: Cardinal; const Value: byte);
begin
 write(index,1,value,LittleEndFirst);
end;

function TCustomPatch.GetDWord(Index: Cardinal): Cardinal;
begin
 read(index,4,result,LittleEndFirst);
end;

function TCustomPatch.GetLongInt(Index: Cardinal): Longint;
begin
 read(index,4,result,LittleEndFirst);
end;

function TCustomPatch.GetShortInt(Index: Cardinal): ShortInt;
begin
 read(index,1,result,LittleEndFirst);
end;

function TCustomPatch.GetSmallInt(Index: Cardinal): SmallInt;
begin
 read(index,2,result,LittleEndFirst);
end;

function TCustomPatch.GetWord(Index: Cardinal): Word;
begin
 read(index,2,result,LittleEndFirst);
end;

function TCustomPatch.ReadStrZT(Addr: Cardinal; MaxSize: integer): String;
begin
  setlength(result,MaxSize);
  UniqueString(result);
  fillchar(Pchar(result)^,length(result),0);
  Read(Addr,MaxSize,PChar(result)^,false);
  Str_FitZeroTerminated(result);
end;

procedure TCustomPatch.SetDWord(Index: Cardinal; const Value: Cardinal);
begin
 write(index,4,value,LittleEndFirst);
end;

procedure TCustomPatch.SetLongInt(Index: Cardinal; const Value: Longint);
begin
 write(index,4,value,LittleEndFirst);
end;

procedure TCustomPatch.SetShortInt(Index: Cardinal; const Value: ShortInt);
begin
 write(index,1,value,LittleEndFirst);
end;

procedure TCustomPatch.SetSmallInt(Index: Cardinal; const Value: SmallInt);
begin
 write(index,2,value,LittleEndFirst);
end;

procedure TCustomPatch.SetWord(Index: Cardinal; const Value: Word);
begin
 write(index,2,value,LittleEndFirst);
end;




{ TPatch }

constructor TPatch.create(Filename: string);
begin
 create;
 open(filename);
end;

procedure TPatch.Close;
begin
 closefile(F);
end;

constructor TPatch.create;
begin
 inherited;
 LittleEndFirst:=true;
end;

destructor TPatch.destroy;
begin
 close;
 inherited;
end;

procedure TPatch.Open(Filename: String);
begin
 close;
 assignfile(f,filename);
 FFilename:=filename;
 reset(f);
end;

procedure TPatch.Read(Index:Cardinal;Size:integer; var x;LittleEndFirst:boolean);
var z:integer;
    b:system.byte;
    P:pByte;
begin
 seek(f,Index);
 for z:=0 to size-1 do
  begin
   p:=@x;
   if LittleEndFirst then inc(P,z) else inc(P,size-1-z);
   system.read(f,b);
   p^:=b;
  end;
end;

procedure TPatch.Write(Index:Cardinal;Size:integer;const x;LittleEndFirst:boolean);
var z:integer;
    b:system.byte;
    P:pByte;
begin
 seek(f,Index);
 for z:=0 to size-1 do
  begin
   p:=@x;
   if LittleEndFirst then inc(P,z) else inc(P,size-1-z);
   b:=p^;
   system.write(f,b);
  end;
end;

{ TTrainer }

constructor TTrainer.create;
begin
 inherited;
 processhandle:=INVALID_HANDLE_VALUE;
 ownshandle:=false;
end;

destructor TTrainer.destroy;
begin
  close;
  inherited;
end;


procedure TTrainer.Read(Index:Cardinal;Size:integer; var x;
  LittleEndFirst: boolean);
var a:Cardinal;
begin
  if processhandle=INVALID_HANDLE_VALUE then raise exception.Create('Application not opened');
  if not Running then raise exception.create('Application terminated');
  if Index<$10000 then raise exception.Create('Thou shalt not follow the NULL pointer, for chaos and madness await thee at its end.');
  ReadProcessMemory(ProcessHandle, ptr(Index),  @x, Size, a);
end;

procedure TTrainer.Write(Index:Cardinal;Size:integer; const x;
  LittleEndFirst: boolean);
var a:Cardinal;
begin
  if processhandle=INVALID_HANDLE_VALUE then raise exception.Create('Application not opened');
  if not Running then raise exception.create('Application terminated');
  if Index<$10000 then raise exception.Create('Thou shalt not follow the NULL pointer, for chaos and madness await thee at its end.');
  WriteProcessMemory(ProcessHandle, ptr(Index),  @x, Size, a);
end;

procedure TTrainer.Close;
begin
  if ProcessHandle=INVALID_HANDLE_VALUE then exit;
  if OwnsHandle then CloseHandle(ProcessHandle);
  ProcessHandle:=INVALID_HANDLE_VALUE;
end;


procedure TTrainer.OpenWindowHandle(Handle: integer);
begin
  if ProcessHandle<>INVALID_HANDLE_VALUE then raise exception.create('Already opened');
  if handle=0 then raise exception.create('Invalid Handle');
  WindowHandle := Handle;
  OwnsHandle:=true;
  ThreadId := GetWindowThreadProcessId(WindowHandle, @ProcessId);
  ProcessHandle := OpenProcess(PROCESS_ALL_ACCESS, False, ProcessId);
end;

procedure TTrainer.OpenProcessHandle(Handle: integer);
begin
  if ProcessHandle<>INVALID_HANDLE_VALUE then raise exception.create('Already opened');
  ProcessHandle:=Handle;
  OwnsHandle:=false;
end;

procedure TTrainer.OpenProcessID(ProcessID: integer);
begin
  if ProcessHandle<>INVALID_HANDLE_VALUE then raise exception.create('Already opened');
  self.ProcessId:=ProcessID;
  OwnsHandle:=true;
  ProcessHandle := OpenProcess(PROCESS_ALL_ACCESS, False, ProcessId);
end;

function TTrainer.GetRunning: boolean;
var Code:Cardinal;
begin
 code:=0;
 result:=true;
 if ProcessHandle=0 then exit;
 if ProcessHandle<>INVALID_HANDLE_VALUE
  then
   begin
    GetExitCodeProcess(ProcessHandle,Code);
    result:=code=Still_active
   end
  else result:=false;
end;

end.
