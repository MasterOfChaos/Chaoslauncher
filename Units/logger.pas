unit logger;

interface
uses windows,classes,sysutils,util,SyncObjs;
//var LogPrefix:String='';

procedure Log(S:String;Clear:boolean=false);
procedure LogException(e:Exception;const Location:String='Unknown');
procedure ShowAndLogException(e:Exception;const Location:String='Unknown');

implementation
var Crit:TCriticalSection;

procedure Log(S:String;Clear:boolean=false);
var Stm:TFileStream;
begin
  if crit=nil then exit;
  try
  Stm:=nil;
    try
      Crit.Acquire;
      if clear
        then Stm:=TFileStream.create(changefileext(GetModuleFilename,'.log'),fmCreate or fmShareDenyWrite)
        else Stm:=TFileStream.create(changefileext(GetModuleFilename,'.log'),fmOpenReadWrite or fmShareDenyWrite);
      Stm.Position:=Stm.Size;
      S:=DateTimeToStr(now)+' '+inttostr(GetCurrentProcessID)+' '+S+#13#10;
      Stm.WriteBuffer(S[1],length(S));
    finally
      Stm.Free;
      Crit.Release;
    end;
  except
    //Log may not throw exceptions
  end;
end;

function ExceptionLogMsg(e:exception;const Location:String):String;
begin
  result := 'Exception at: '+location+' class: '+E.classname+' msg: '+ E.Message;
end;

function ExceptionShowMsg(e:exception;const Location:String):String;
begin
  result := E.Message;
  if lowercase(e.classname)<>'exception'
    then result:=result+#13+'Class: '+e.classname;
end;

procedure LogException(e:Exception;const Location:String);
begin
  Log(ExceptionLogMsg(e,Location));
end;

procedure ShowAndLogException(e:Exception;const Location:String);
begin
  Log(ExceptionLogMsg(e,Location));
  MessageBox(0,PChar(ExceptionShowMsg(e,Location)), 'Exception', MB_OK + MB_ICONSTOP);
end;

initialization
  Crit:=TCriticalSection.create;
  Log('Logging started',true);
finalization
  Log('Logging ended');
  FreeAndNil(Crit);
end.
