unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,math;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

 function FileToString(const Filename:String):String;
 var stm:TFileStream;
 begin
  stm:=TFilestream.create(Filename,fmOpenRead or fmShareDenyWrite);
  try
    setlength(result,min(high(integer),stm.Size));
    stm.Read(result[1],length(result))
  finally
    stm.free;
  end;
 end;

 procedure StringToFile(const S:String;const Filename:String);
 var stm:TFileStream;
 begin
  stm:=TFilestream.create(Filename,fmCreate or fmShareExclusive);
  try
    stm.Write(S[1],length(S))
  finally
    stm.free;
  end;
 end;
var s,t:String;
    i:integer;
procedure TForm1.FormCreate(Sender: TObject);
begin
  S:=filetostring('kor.txt');
  T:='';
  for i:=1 to length(S)do
    if ord(S[i])>127
     then T:=T+'#'+inttohex(ord(s[i]),2)
     else T:=T+S[i];
  stringtofile(T,'kor.lang');
end;

end.
