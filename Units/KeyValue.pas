unit KeyValue;

interface

type TStringComperator=function (const S1: string; const S2: string): Integer;

type TAbstractKeyValue=class
  published
    function GetValue(const Key: String): String;virtual;abstract;
    procedure SetValue(const Key, Value: String);virtual;abstract;
  public
    property Values[const Key:String]:String read GetValue write SetValue;default;
    function Count:integer;virtual;abstract;
    procedure Clear;virtual;abstract;
end;

type TAbstractIndexedKeyValue=class(TAbstractKeyValue)
  public
    function GetKeyAt(Index:integer):String;virtual;abstract;
    function GetValueAt(Index:integer):String;virtual;abstract;
end;

type TSortKeyValue=class(TAbstractIndexedKeyValue)
  private
    FValues:array of String;
    FKeys:array of String;
    FCount:integer;
    FStringComperator:TStringComperator;
    FLastIndex:integer;
    procedure Insert(Index:integer;const Key,Value:String);
    procedure Remove(Index:integer);
    function Find(const Key:String;out Index:integer):boolean;
  published
    function GetValue(const Key: String): String;override;
    procedure SetValue(const Key, Value: String);override;
  public
    property Values[const Key:String]:String read GetValue write SetValue;default;
    function Count:integer;override;
    procedure Clear;override;
    constructor Create;overload;
    constructor Create(AStringComperator:TStringComperator);overload;
    function GetKeyAt(Index:integer):String;override;
    function GetValueAt(Index:integer):String;override;
end;

type TRecommendedIndexedKeyValue=TSortKeyValue;
     TRecommendedKeyValue=TSortKeyValue;

implementation
uses sysutils;

{ TSortKeyValue }

procedure TSortKeyValue.Clear;
begin
  if FCount=0 then exit;
  FCount:=0;
  setlength(FKeys,0);
  setlength(FValues,0);
end;

function TSortKeyValue.Count: integer;
begin
  result:=FCount;
end;

constructor TSortKeyValue.Create;
begin
  Create(SysUtils.CompareStr);
end;

constructor TSortKeyValue.Create(AStringComperator: TStringComperator);
begin
  FStringComperator:=AStringComperator;
  FCount:=0;
end;

function TSortKeyValue.Find(const Key: String; out Index: integer): boolean;
var
  LowerBound:integer;
  UpperBound:Integer;
  CurrentIndex:integer;
  CompareResult:Integer;
begin
  result:=false;
  LowerBound:=0;
  UpperBound:=FCount-1;
  if FLastIndex<FCount
    then CurrentIndex:=FLastIndex
    else CurrentIndex:=UpperBound shr 1;
  while LowerBound <= UpperBound do
  begin
    CompareResult:=CompareStr(FKeys[CurrentIndex],Key);
    if CompareResult<0
      then LowerBound:=CurrentIndex+1
      else begin
        if CompareResult=0 then
        begin
          LowerBound:=CurrentIndex;
          Result := True;
          break;
        end;
       UpperBound:=CurrentIndex-1;
      end;
    CurrentIndex:=(UpperBound+LowerBound)shr 1;//Middle
    end;
  Index:=LowerBound;
  FLastIndex:=Index;
end;

function TSortKeyValue.GetKeyAt(Index: integer): String;
begin
  result:=FKeys[Index];
end;

function TSortKeyValue.GetValue(const Key: String): String;
var Index:integer;
begin
  if Find(Key,Index)
    then result:=FValues[Index]
    else result:='';
end;

function TSortKeyValue.GetValueAt(Index: integer): String;
begin
  result:=FValues[Index];
end;

procedure TSortKeyValue.Insert(Index: integer; const Key, Value: String);
var i:integer;
begin
  FCount:=FCount+1;
  setlength(FKeys,FCount);
  setlength(FValues,FCount);
  for i:=FCount-1 downto Index+1 do
    begin
      FKeys[i]:=FKeys[i-1];
      FValues[i]:=FValues[i-1];
    end;
  FKeys[Index]:=Key;
  FValues[Index]:=Value;
end;

procedure TSortKeyValue.Remove(Index: integer);
var i:integer;
begin
  for i:=index to FCount-2 do
    begin
      FKeys[i]:=FKeys[i+1];
      FValues[i]:=FValues[i+1];
    end;
  FCount:=FCount-1;
  setlength(FKeys,FCount);
  setlength(FValues,FCount);
end;

procedure TSortKeyValue.SetValue(const Key, Value: String);
var Index:integer;
begin
  if Value<>''
    then begin
      if Find(Key,Index)
        then FValues[Index]:=Value
        else Insert(Index,Key,Value);
    end
    else begin
      if Find(Key,Index)
        then Remove(Index);
    end;
end;

end.
