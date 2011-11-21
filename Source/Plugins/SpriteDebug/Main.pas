unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,offsets, ExtCtrls,util, StdCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    LblSel: TLabel;
    LblSprite: TLabel;
    LblMem: TLabel;
    LblPos: TLabel;
    LblOffset: TLabel;
    Button1: TButton;
    LblMemD: TLabel;
    Memo1: TMemo;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
var hProcess:Cardinal;

const SpriteArray=$629D80;
      ImageArray =$52F5A8;
function OpenScProcess:boolean;
var wnd:hwnd;
    ProcessID:Cardinal;
begin
  result:=False;
  EnablePrivilege('SeDebugPrivilege');
  Wnd:=FindWindow(nil,'Brood War');
  if Wnd=0 then exit;
  GetWindowThreadProcessId(Wnd, @ProcessId);
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,true,ProcessID);
  if hProcess=0 then exit;
  Trainer.OpenProcessHandle(hProcess);
  result:=true;
end;

procedure CloseScProcess;
begin
  Trainer.close;
  closehandle(hProcess);
end;

var S3,S2,SD:String;

procedure TForm1.Button1Click(Sender: TObject);
begin
  s3:=s2;
end;

function IndexFromAddr(Addr,Base,Size,Count:Cardinal):String;
var Index,Remainder:integer;
begin
  if Addr=0
    then begin
      result:='nil';
      exit;
    end;
  if Addr<Base
    then begin
      result:='ErrorLow';
      exit;
    end;
  Addr:=Addr-Base;
  Index:=Addr div size;
  if Index>=Count
    then begin
      result:='ErrorHigh';
      exit;
    end;   
  Remainder:=Addr mod size;
  Result:=inttostr(Index);
  if Remainder<>0
    then result:=result+'+$'+inttohex(Remainder,0);
end;

var txt:TStringlist;
procedure TForm1.Timer1Timer(Sender: TObject);
var LocalPlayer:Cardinal;
    SelectedUnit:Cardinal;
    SelectedSprite:Cardinal;
    S:String;
    i:integer;
    Pos:TPoint;
    Step:integer;
begin
  if not OpenScProcess then exit;
  txt:=nil;
  try
    txt:=Tstringlist.Create;
    LocalPlayer:=Trainer.DWord[Addresses.PlayerID];
    SelectedUnit:=Trainer.DWord[Addresses.PlayerSelection+LocalPlayer*12*4];
    LblSel.caption:=inttohex(SelectedUnit,0);
    if SelectedUnit=0 then exit;
    SelectedSprite:=Trainer.DWord[SelectedUnit+$C];
    LblSprite.caption:=inttohex(SelectedSprite,0);
    setlength(s,36);
    ReadProcessMemory(hProcess,pointer(SelectedSprite),@S[1],length(s),Cardinal(nil^));
    S2:=StrToHex(S);
    LblOffset.Caption:='';
    Step:=2;
    for i:=length(s2) div (Step*2) downto 0 do
      begin
        if i>0 then insert(#13,s2,i*Step*2+1);
        LblOffset.Caption:=inttohex(i*Step,0)+#13+LblOffset.Caption;
      end;
    sd:=s2;
    if s3='' then s3:=s2;
    for i:=1 to length(s2)do
      if (s2[i]=s3[i])and(s2[i]<>#13)
        then sd[i]:=' ';
    LblMemD.caption:=sd;
    LblMem.Caption:=S2;

    txt.clear;
    Pos.X:=Trainer.Word[SelectedSprite+$14];
    Pos.Y:=Trainer.Word[SelectedSprite+$16];
    txt.add('PSprite1 '+IndexFromAddr(Trainer.DWord[SelectedSprite+$0],SpriteArray,36,2500)+' at '+inttohex(Trainer.DWord[SelectedSprite+$0],8));
    txt.add('PSprite2 '+IndexFromAddr(Trainer.DWord[SelectedSprite+$4],SpriteArray,36,2500)+' at '+inttohex(Trainer.DWord[SelectedSprite+$4],8));
    txt.add('Pos X: '+inttostr(Pos.X)+' Y: '+inttostr(pos.Y));
    txt.add('PImage1 '+IndexFromAddr(Trainer.DWord[SelectedSprite+$18],ImageArray,64,5080)+' at '+inttohex(Trainer.DWord[SelectedSprite+$18],8));
    txt.add('PImage2 '+IndexFromAddr(Trainer.DWord[SelectedSprite+$1C],ImageArray,64,5080)+' at '+inttohex(Trainer.DWord[SelectedSprite+$1C],8));
    txt.add('PImage3 '+IndexFromAddr(Trainer.DWord[SelectedSprite+$20],ImageArray,64,5080)+' at '+inttohex(Trainer.DWord[SelectedSprite+$20],8));
    Memo1.text:=txt.text;
  finally
    CloseScProcess;
    txt.free;
  end;
end;

end.
