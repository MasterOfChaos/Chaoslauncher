library MultipleInstance;

uses
  AsmHelper;

{$R *.res}
const S=#$E9#$89#$00#$00#$00#$90;


begin
  WriteString($004DFFF0,S);
end.
