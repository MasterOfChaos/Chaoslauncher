unit tvants;

interface
type TTvAntData=record
  Name:String;
  BaseUrl:String;
  Referer:String;
  procedure Run;
end;

var TvAntsData:array of TTvAntData;
procedure AddTvAnt(const Name,BaseUrl,Referer:String);

implementation
uses windows,idhttp,sysutils,shellapi,util,logger;

procedure AddTvAnt(const Name,BaseUrl,Referer:String);
begin
  setlength(TvAntsData,length(TvAntsData)+1);
  TvAntsData[high(TvAntsData)].Name:=Name;
  TvAntsData[high(TvAntsData)].BaseUrl:=BaseUrl;
  TvAntsData[high(TvAntsData)].Referer:=Referer;
end;

function GetTVAntsUrl(const BaseUrl,Referer:String):String;
var http:TIdHttp;
begin
  http:=nil;
  try
    http:=TIdHttp.Create(nil);
    http.Request.Referer:=Referer;
    result:=http.Get(BaseUrl+inttostr(random(100000)));
  finally
    http.free;
  end;
end;


{ TTvAntData }

procedure TTvAntData.Run;
var s:String;
    error:integer;
begin
  Log('Start TvAnt '+Name);
  Log('BaseUrl: '+BaseUrl);
  Log('Referer: '+Referer);
  s:=GetTvAntsUrl(BaseUrl,Referer);
  Log('DirectUrl: '+s);
  //if pos('tvants:',s)=0 then raise exception.create('Invalid TvAnts url'#13#10+s);
  error:=shellexecute(0,'open',PChar(s),'','',SW_Normal);
  if error<=32 then raise exception.create('Error starting TvAnts '+inttostr(error));  
end;
initialization
  //AddTvAnt('Sc2.org OGN','http://www.sc2.org/ogn/getogntvants.asp?_myRandom=','http://www.sc2.org/LiveBroadcast/tabid/55/Default.aspx');
  //AddTvAnt('Sc2.org MBC','http://www.sc2.org/mbc/getmbctvants.asp?_myRandom=','http://www.sc2.org/LiveBroadcast/tabid/55/Default.aspx');
  AddTvAnt('YaoYuan OGN','http://www.yaoyuan.com/getcode/getlocalmms.php?id=5&_myRandom=','http://www.yaoyuan.com/live.php');
  //AddTvAnt('YaoYuan OGN WMP','http://www.yaoyuan.com/getcode/getlocalmms.php?id=2&_myRandom=','http://www.yaoyuan.com/live.php');
  AddTvAnt('YaoYuan MBC','http://www.yaoyuan.com/getcode/getlocalmms.php?id=4&_myRandom=','http://www.yaoyuan.com/live.php');
  //AddTvAnt('YaoYuan MBC WMP','http://www.yaoyuan.com/getcode/getlocalmms.php?id=1&_myRandom=','http://www.yaoyuan.com/live.php');
  //AddTvAnt('YaoYuan PPLive','http://www.yaoyuan.com/getcode/getlocalmms.php?id=3&_myRandom=','http://www.yaoyuan.com/live.php');
end.
