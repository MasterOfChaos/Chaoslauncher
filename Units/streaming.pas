unit streaming;

interface
uses classes,sysutils;
Type EStreamAccess=class(Exception);

Type TCustomMemoryStreamEx=class(TCustomMemoryStream)
  private
    FCanRead:boolean;
    FCanWrite:boolean;
  protected
    procedure SetAccess(ACanRead,ACanWrite:Boolean);
  public
    function Write(const Buffer; Count: Longint): Longint; override;
    property CanRead:boolean read FCanRead;
    property CanWrite:boolean read FCanWrite;
end;

Type TPointerStream=class(TCustomMemoryStreamEx)
  public
    procedure SetAccess(ACanRead,ACanWrite:Boolean);
    procedure SetPointer(Ptr: Pointer; Size: Longint);
end;


type
   TStreamHelper = class helper for TStream
     //String
     function ReadStringZT:AnsiString;overload;  //Not binary safe
     function ReadStringZT(MaxLength:integer):AnsiString;overload;//Not binary safe
     procedure WriteStringZT(const S:AnsiString);//Not binary safe
     function ReadString32:AnsiString;
     procedure WriteString32(const S:AnsiString);
     function ReadString16:AnsiString;
     procedure WriteString16(const S:AnsiString);
     function ReadStringRaw(Len:integer):AnsiString;
     procedure WriteStringRaw(const S:AnsiString);

     //WideString
     function ReadWideStringZT:WideString;overload;  //Not binary safe
     function ReadWideStringZT(MaxLength:integer):WideString;overload;//Not binary safe
     procedure WriteWideStringZT(const S:WideString);//Not binary safe
     function ReadWideString32:WideString;
     procedure WriteWideString32(const S:WideString);
     function ReadWideString16:WideString;
     procedure WriteWideString16(const S:WideString);
     function ReadWideStringRaw(MaxLength:integer):WideString;
     procedure WriteWideStringRaw(const S:WideString);

     //Integer
     function ReadByte:Byte;
     function ReadWord:Word;
     function ReadDWord:Longword;
     function ReadInt8:shortint;
     function ReadInt16:smallint;
     function ReadInt32:longint;
     function ReadInt64:longint;
     procedure WriteByte(value:byte);
     procedure WriteBytes(const values:array of byte);
     procedure WriteWord(value:word);
     procedure WriteWords(const values:array of word);
     procedure WriteDWord(value:longword);
     procedure WriteDWords(const values:array of longword);
     procedure WriteInt8(value:shortint);
     procedure WriteInt8s(const values:array of shortint);
     procedure WriteInt16(value:smallint);
     procedure WriteInt16s(const values:array of smallint);
     procedure WriteInt32(value:longint);
     procedure WriteInt32s(const values:array of longint);
     procedure WriteInt64(value:int64);
     procedure WriteInt64s(const values:array of int64);

     //Variable sized Integers, see rfc3284
     function ReadVarUInt:Cardinal;
     function ReadVarUInt64:int64;
     procedure WriteVarUInt(value:Cardinal);
     procedure WriteVarUInts(const values:array of Cardinal);
     procedure WriteVarUInt64(value:int64);
     procedure WriteVarUInt64s(const values:array of int64);

     //Other primitive types
     function ReadAnsiChar:AnsiChar;
     procedure WriteAnsiChar(value:AnsiChar);
     function ReadWideChar:WideChar;
     procedure WriteWideChar(value:WideChar);     
     function ReadBool:boolean;
     procedure WriteBool(value:boolean);
     function ReadPointer:Pointer;
     procedure WritePointer(p:pointer);

     //Floatingpoint
     function ReadFloat:single;
     function ReadDouble:double;
     function ReadExtended:extended;
     procedure WriteFloat(value:single);
     procedure WriteFloats(const values:array of single);
     procedure WriteDouble(value:Double);
     procedure WriteDoubles(const values:array of Double);
     procedure WriteExtended(value:Extended);
     procedure WriteExtendeds(const values:array of Extended);
   end;

implementation

{ TPointerStream }

procedure TCustomMemoryStreamEx.SetAccess(ACanRead, ACanWrite: Boolean);
begin
  FCanRead:=ACanRead;
  FCanWrite:=ACanWrite;
end;

function TCustomMemoryStreamEx.Write(const Buffer; Count: Integer): Longint;
begin
  if not CanWrite then raise EStreamAccess.create('Can''t not write to readonly stream');
  if count>Size-Position then count:=Size-Position;
  move(Buffer,Pointer(int64(Memory)+Position)^,Count);
  result:=count;
end;

{ TPointerStream }

procedure TPointerStream.SetAccess(ACanRead, ACanWrite: Boolean);
begin
  inherited;
end;

procedure TPointerStream.SetPointer(Ptr: Pointer; Size: Integer);
begin
  inherited;
end;

{ TStreamHelper }

function TStreamHelper.ReadAnsiChar: AnsiChar;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadBool: boolean;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadByte: Byte;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadDouble: double;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadDWord: Longword;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadExtended: extended;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadFloat: single;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadInt16: smallint;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadInt32: longint;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadInt64: longint;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadInt8: shortint;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadPointer: Pointer;
begin
  ReadBuffer(result,sizeof(result));
end;

function TStreamHelper.ReadStringZT: AnsiString;
var c:char;
begin
  result:='';
  ReadBuffer(c,1);
  while c<>#0 do
   begin
     result:=result+c;
     ReadBuffer(c,1);
   end;
end;

function TStreamHelper.ReadVarUInt: Cardinal;
var b:byte;
begin
  result:=0;
  repeat
    b:=ReadByte;
    result:=(result shl 7) or (b and $7F);
  until b and $80=0;
end;

function TStreamHelper.ReadVarUInt64: int64;
var b:byte;
begin
  result:=0;
  repeat
    b:=ReadByte;
    result:=(result shl 7) or (b and $7F);
  until b and $80=0;
end;

function TStreamHelper.ReadString16: String;
begin
  ReadStringRaw(ReadWord);
end;

function TStreamHelper.ReadString32: String;
begin
  ReadStringRaw(ReadDWord);
end;

function TStreamHelper.ReadStringRaw(Len: integer): AnsiString;
begin
  setlength(result,Len);
  readbuffer(result[1],length(result));
end;

function TStreamHelper.ReadStringZT(MaxLength: integer): AnsiString;
begin
  raise exception.create('Not Implemented');
end;

function TStreamHelper.ReadWideChar: WideChar;
begin
  raise exception.create('Not Implemented');
end;

function TStreamHelper.ReadWideString16: WideString;
begin
  raise exception.create('Not Implemented');
end;

function TStreamHelper.ReadWideString32: WideString;
begin
  raise exception.create('Not Implemented');
end;

function TStreamHelper.ReadWideStringRaw(MaxLength: integer): WideString;
begin
  raise exception.create('Not Implemented');
end;

function TStreamHelper.ReadWideStringZT(MaxLength: integer): WideString;
begin
  raise exception.create('Not Implemented');
end;

function TStreamHelper.ReadWideStringZT: WideString;
begin
  raise exception.create('Not Implemented');
end;

function TStreamHelper.ReadWord: Word;
begin
  ReadBuffer(result,sizeof(result));
end;

procedure TStreamHelper.WriteAnsiChar(value: AnsiChar);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteBool(value: boolean);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteByte(value: byte);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteBytes(const values: array of byte);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteDouble(value: Double);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteDoubles(const values: array of Double);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteDWord(value: longword);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteDWords(const values: array of longword);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteExtended(value: Extended);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteExtendeds(const values: array of Extended);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteFloat(value: single);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteFloats(const values: array of single);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteInt16(value: smallint);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteInt16s(const values: array of smallint);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteInt32(value: Integer);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteInt32s(const values: array of Integer);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteInt64(value: int64);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteInt64s(const values: array of int64);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteInt8(value: shortint);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteInt8s(const values: array of shortint);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WritePointer(p: pointer);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteStringZT(const S: String);
begin
  WriteBuffer(S,length(S)+1);
end;

procedure TStreamHelper.WriteVarUInt(value: Cardinal);
begin
  if value>=1 shl 28 then
    WriteByte((value shr 28) and $7F or $80);
  if value>=1 shl 21 then
    WriteByte((value shr 21) and $7F or $80);
  if value>=1 shl 14 then
    WriteByte((value shr 14) and $7F or $80);
  if value>=1 shl 7 then
    WriteByte((value shr 7) and $7F or $80);
  WriteByte((value shr 0) and $7F);
end;

procedure TStreamHelper.WriteVarUInt64(value: int64);
begin
  if value>=1 shl 56 then
    WriteByte((value shr 28) and $7F or $80);
  if value>=1 shl 49 then
    WriteByte((value shr 28) and $7F or $80);
  if value>=1 shl 42 then
    WriteByte((value shr 28) and $7F or $80);
  if value>=1 shl 35 then
    WriteByte((value shr 28) and $7F or $80);
  if value>=1 shl 28 then
    WriteByte((value shr 28) and $7F or $80);
  if value>=1 shl 21 then
    WriteByte((value shr 21) and $7F or $80);
  if value>=1 shl 14 then
    WriteByte((value shr 14) and $7F or $80);
  if value>=1 shl 7 then
    WriteByte((value shr 7) and $7F or $80);
  WriteByte((value shr 0) and $7F);
end;

procedure TStreamHelper.WriteVarUInt64s(const values: array of int64);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteVarUInts(const values: array of Cardinal);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteString16(const S: String);
begin
  if length(S)>$FFFF then raise exception.create('String too long');
  WriteWord(length(S));
  WriteBuffer(S[1],length(S));
end;

procedure TStreamHelper.WriteString32(const S: String);
begin
  WriteDWord(length(S));
  WriteBuffer(S[1],length(S));
end;

procedure TStreamHelper.WriteStringRaw(const S: AnsiString);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteWideChar(value: WideChar);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteWideString16(const S: WideString);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteWideString32(const S: WideString);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteWideStringRaw(const S: WideString);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteWideStringZT(const S: WideString);
begin
  raise exception.create('Not Implemented');
end;

procedure TStreamHelper.WriteWord(value: word);
begin
  WriteBuffer(value,sizeof(value));
end;

procedure TStreamHelper.WriteWords(const values: array of word);
begin
  raise exception.create('Not Implemented');
end;

end.
