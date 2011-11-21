unit CoachConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TConfigForm = class(TForm)
    Script: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  ConfigForm: TConfigForm;

implementation

{$R *.dfm}

procedure TConfigForm.FormCreate(Sender: TObject);
var sr:TSearchrec;
    error:integer;
begin
 try
   error:=Findfirst(extractfilepath(paramstr(0))+'\Coach\*.lua',faAnyfile-faDirectory,sr);
   while error=0 do
     begin
       Script.items.add(changefileext(sr.Name,''));
       error:=FindNext(sr);
     end;
 finally
   findclose(sr);
 end;
end;

end.
