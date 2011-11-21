program Chaoslauncher;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  Plugins in 'Plugins.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
