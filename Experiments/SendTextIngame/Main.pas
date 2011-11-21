unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,textout,pluginapi;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation
uses util;

{$R *.dfm}
var hProcess:THandle;
    ProcessID:Cardinal;
    wnd:hwnd;
function SendTextInGame(hProcess:THandle;Msg:PChar):BOOL;stdcall;external 'SCMsgUtil.dll';
procedure TForm1.Button1Click(Sender: TObject);
begin
  SendTextInLobby('HiThere'+inttostr(random(100)));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  EnablePrivilege('SeDebugPrivilege');
  Wnd:=FindWindow(nil,'Brood War');
  if Wnd=0 then raise exception.create('Window not found');
  GetWindowThreadProcessId(Wnd, @ProcessId);
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,true,ProcessID);
  Game.ProcessHandle:=hProcess;
  if hProcess=0 then raise exception.create('Could not open process');
end;

end.
