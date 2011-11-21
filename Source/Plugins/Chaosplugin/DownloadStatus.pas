unit DownloadStatus;

interface

implementation
uses windows,main,offsets,config,scinfo;

procedure DownloadStatusTimer();
var i:byte;
begin
  if not Settings.DownloadStatus then exit;
  if not IsLobby then exit;
  for i := 0 to 7 do
    if Trainer.DWord[Addresses.DownloadStatus+4*i]=100
      then Trainer.DWord[Addresses.DownloadStatus+4*i]:=101;
end;

initialization
  AddTimerHandler(DownloadStatusTimer,[pmLauncher]);
end.
