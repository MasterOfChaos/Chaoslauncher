library ForceLanLatency;

uses
  SysUtils,
  Classes,
  asmhelper,
  offsets;

{$R *.res}
const s=#$B8#2#0#0#0#$90#$90;
begin
  WriteString(Addresses.NetModeLatency,s);
end.
