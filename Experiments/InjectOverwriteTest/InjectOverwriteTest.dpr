program InjectOverwriteTest;

{$APPTYPE CONSOLE}

uses
  windows,
  util,
  sysutils,
  classes,
  inject_overwrite;
var hProcess:THandle;
    stm:TMemorystream;
begin
  EnablePrivilege('SeDebugPrivilege');
  hProcess:=OpenProcess(PROCESS_ALL_ACCESS,true,232);
  stm:=TMemorystream.create;
  injectoverwrite(stm,filetostring('D:\Games\Starcraft\Starcraft.exe'),extractfilepath(paramstr(0))+'Chaosinjector.dll',hProcess);
end.
