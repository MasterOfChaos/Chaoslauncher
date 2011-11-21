program Chaosupdater;

uses
  windows,
  shellapi,
  sysutils,
  classes,
  util,
  logger;

{$R *.res}

var TempPath,Launcher,LauncherPath:String;
    sl:TStringlist;
    i:integer;
begin
  try
    if (Paramcount<3)or(lowercase(Paramstr(1))<>'/install')
      then raise exception.create('This program cannot be started manually');
    sleep(2000);
    Launcher:=paramstr(2);
    Launcherpath:=extractfilepath(Launcher);
    TempPath:=Paramstr(3);
    if not fileexists(TempPath+'UpdateInfo.dat')
      then raise exception.create('No downloaded updates available');
    sl:=TStringlist.create;
    try
      sl.LoadFromFile(TempPath+'UpdateInfo.dat');
      for i := 0 to sl.count-1 do
        begin
          if not movefileex(PChar(TempPath+'Temp'+inttostr(i)+'.upd'),PChar(sl[i]),MOVEFILE_COPY_ALLOWED or MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH)
            then SimpleMessageBox(smtError,'Could not replace '+sl[i]+#13+GetLastErrorString);
        end;
    finally
      sl.free;
      deletefile(PChar(TempPath+'UpdateInfo.dat'));
      RemoveDirectory(PChar(TempPath));
    end;
    shellexecute(0,'open',PChar(Launcher),'',PChar(ExtractFilePath(Launcher)),sw_normal);
  except
    on e:exception do
      ShowAndLogException(e);
  end;
end.
