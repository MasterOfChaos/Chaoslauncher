unit Plugins_BWL;

interface
uses update;
procedure BwlUpdateCheck(AUpdater:TUpdater;Url,Filename:String;var desc:String;const PluginName:String);

implementation
uses idhttp,classes,versions,logger,util,sysutils,crypto;

procedure BwlUpdateCheck(AUpdater:TUpdater;Url,Filename:String;var desc:String;const PluginName:String);
var http:TIdHttp;
    sl:TStringlist;
    Version:TVersion;
    i:integer;
    compressed:boolean;
begin
  Assert(AUpdater<>nil,'BwlUpdateCheck called with Updater=nil');
  if Url='' then exit;//No Update
  if Url[length(Url)]<>'/'
    then Url:=Url+'/';
  Log('url: '+url);
  http:=nil;
  //http.OnWork
  sl:=nil;
  try
    http:=TIdHttp.create;
    http.Request.UserAgent:='Chaoslauncher '+VersionToStr(GetProgramVersion)+' Win'+GetWindowsVersionStrShort;
    http.ConnectTimeout:=1000;
    sl:=TStringlist.create;
    try
      sl.text:=http.get(url+'update');
    except
      on e:exception do
      begin
        LogException(e,'BwlUpdateCheck http.get(update)');
        exit;
      end;
    end;
    if sl.count<>2
      then begin
        Log('Invalid Updatefile');
        exit;
      end;
    GetFileVersionRec(Filename,Version);
    if uppercase(md5(FileToString(Filename)))=uppercase(sl[0]) then exit;
    if CompareVersions(ParseVersion(sl[1]),Version)<0 then exit;
    Log('Update needed');
    desc:=desc+#13#10+PluginName;
    desc:=desc+#13#10+VersionToStr(Version)+' -> '+sl[1];
    compressed:=false;
    try
      sl.text:=http.get(url+'extupdate');
      for i:=0 to sl.count-1 do
        if sl[i]='compressed' then compressed:=true;
    except
    end;
    if compressed
      then AUpdater.AddFile(Filename,url+'compressed',[ufCompressed])
      else AUpdater.AddFile(Filename,url+'binary');
  finally
    http.Free;
    sl.free;
  end;
end;

end.
