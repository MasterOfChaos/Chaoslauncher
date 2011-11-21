unit RawMemory;

interface

type TMultiPointer=record
  class operator Implicit(APointer : Pointer): TMultiPointer;inline;
  case integer of
   1:(uint:cardinal;);
   2:(p:pointer;);
   3:(pb:pbyte;);
   4:(pw:pword;);
   5:(pd:pcardinal;);
   6:(pc:pchar;);
end;

type TBuffer=record
  Addr,EndAddr:TMultiPointer;
  function Size:integer;inline;
  function SliceLeft(Size:integer):TBuffer;
  function SliceRight(Size:integer):TBuffer;
  function SliceFrom(Start:integer):TBuffer;
  function Slice(Start,Size:integer):TBuffer;
  function TryCopyFrom(const Buffer:TBuffer;Size:integer):boolean;
  procedure CopyFrom(const Buffer:TBuffer;Size:integer);
end;
type PBuffer=^TBuffer;

type TParseState=Record
  Buf:TBuffer;
  Pos:TMultiPointer;
  procedure Read(var ABuf;ASize:integer);inline;
  function ReadByte:byte;inline;
End;

function Buffer(Start:pointer;Size:integer):TBuffer;
function ParseState(const Buf:TBuffer):TParseState;

implementation

{ TMultiPointer }

class operator TMultiPointer.Implicit(APointer: Pointer): TMultiPointer;
begin
  result.p:=APointer;
end;

{ TParseState }

procedure TParseState.Read(var ABuf; ASize: cardinal);
begin
  if Pos.uint+ASize>=Buf.EndAddr.uint
    then raise exception.create('ReadPastTheEnd');
  
end;

function TParseState.ReadByte: byte;
begin
  result:=Buf.Addr.pb^;
  inc(Buf.Addr.uint);
end;

{ TBuffer }

procedure TBuffer.CopyFrom(const Buffer: TBuffer; Size: integer);
begin

end;

function TBuffer.Size: integer;
begin
  result:=AddrEnd.uint-Addr.uint;
end;

function TBuffer.Slice(Start, Size: integer): TBuffer;
begin

end;

function TBuffer.SliceFrom(Start: integer): TBuffer;
begin

end;

function TBuffer.SliceLeft(Size: integer): TBuffer;
begin

end;

function TBuffer.SliceRight(Size: integer): TBuffer;
begin

end;

function TBuffer.TryCopyFrom(const Buffer: TBuffer; Size: integer): boolean;
begin

end;

function Buffer(Start:pointer;Size:integer):TBuffer;
begin
  result.Addr.p:=Start;
  result.Size:=Size;
end;

function ParseState(const Buf:TBuffer):TParseState;
begin

end;

end.
