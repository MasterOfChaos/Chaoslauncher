unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,inifiles;

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

const UnitCount=228;
var ini:TInifile;
    UnitsDat:TStream;
    Names:Tstringlist;
procedure Output(const Name:string;Start:integer;Size:byte);
var Value:integer;
    i:integer;
begin
  if (size=0)or (size>sizeof(value)) then raise exception.Create('Invalid size');
  UnitsDat.position:=start;
  for i:=0 to UnitCount-1 do
    begin
      Value:=0;
      UnitsDat.ReadBuffer(Value,size);
      Ini.WriteInteger(Names[i],Name,Value);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ini:=nil;
  UnitsDat:=nil;
  names:=nil;
  try
    ini:=TInifile.create(extractfilepath(paramstr(0))+'Units.ini');
    UnitsDat:=TfileStream.create(extractfilepath(paramstr(0))+'Units.dat',fmOpenRead or fmShareDenyWrite);
    names:=TStringlist.create;
    names.loadfromfile(extractfilepath(paramstr(0))+'Units.txt');
    Output('Mineral',$3A0C,2);
    Output('Vespine',$3BD4,2);
    Output('HP',$C55,4);
  finally
    ini.free;
    UnitsDat.Free;
  end;
end;

end.
