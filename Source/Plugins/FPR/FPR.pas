unit FPR;

interface
uses versions,classes;

type TFPRHeader=packed record
  Magic:array[0..7]of char;
  HeaderSize:integer;
  FormatVersionMinor:Word;
  FormatVersionMajor:Word;
  Author:string[64];
  Recorded:TDateTime;
  PlayerNumber:byte;
  PlayerType:byte;
  ScVersion:TVersion;
  function Valid:boolean;
end;

type TOperationMode=(omRead,omWrite);

type TFirstPersonReplay=class
  private
    FMode: TOperationMode;
    FStream: TStream;
    FHeader: TFPRHeader;
  published
  public
    property Header:TFPRHeader read FHeader;
    property Stream:TStream read FStream;
    property Mode:TOperationMode read FMode;
    procedure WriteHeader(AHeader:TFPRHeader);
    constructor create(AStream:TStream;AMode:TOperationMode);
end;

implementation


{ TFirstPersonReplay }

constructor TFirstPersonReplay.create(AStream: TStream; AMode: TOperationMode);
begin
  FStream:=AStream;
  FMode:=AMode;

end;

procedure TFirstPersonReplay.WriteHeader(AHeader: TFPRHeader);
begin
  if Mode<>omWrite then raise EInvalidOperation.create('Write to a readonly FPR');
end;

{ TFPRHeader }

function TFPRHeader.Valid: boolean;
begin
  result:=Magic='ScFprMoC';
end;

end.
