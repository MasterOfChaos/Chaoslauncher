unit ReplayUpload;

interface

implementation
uses windows,sysutils,classes,math,main,logger,idhttp,IdMultipartFormData;
var Age:integer;
    LastRepCheck:Cardinal;

function CurrentRepNumber:integer;
var Rec:TSearchrec;
    Error:integer;
 function ExtractNumber(const S:String):integer;
 var i:integer;
 begin
  result:=0;
  i:=1;
  while (i<10)and(i<=length(S))and(S[i]in['0'..'9']) do
   begin
    result:=result*10+ord(S[i])-ord('0');
    inc(i);
   end;
 end;
begin
  result:=0;
  if not directoryexists(Path+'\Maps\Replays\Autoreplay') then exit;
  error:=0;
  try
   error:=FindFirst(Path+'\Maps\Replays\Autoreplay\*.rep', $2F, Rec);//$2F=Normale Datei, kein Verzeichnis
  finally
    while error=0 do
     begin
      result:=max(result,ExtractNumber(rec.Name));
      error:=findnext(Rec);
     end;
    Findclose(rec);
  end;
end;

procedure UploadReplay(const Filename,Url:String);
var http:TIdHttp;
    Params: TIdMultipartFormDataStream;
    HttpResponse:String;
begin
  Log('Uploading replay...');
  http:=nil;
  params:=nil;
  try
    try
      http:=TIdHttp.Create(nil);
      params:=TIdMultipartFormDataStream.create;
      Params.AddFile('Replay', Filename,'application/octet-stream');
      HttpResponse:=HTTP.Post(Url,Params);
      Log('Upload returend '+HttpResponse);
    finally
      params.free;
      http.free;
    end;
    Log('Upload completed successfully');
  except
    on e:exception do
      Log('UploadError: '+e.message);
  end;
end;

procedure CheckRep;
var RepNumber:integer;
    RepName:String;
begin
 if FileAge(Path+'\Maps\Replays\LastReplay.rep')<>age then
  begin
   Log('Uploading Replay');
   Age:=FileAge(Path+'\Maps\Replays\LastReplay.rep');
   if Age=-1 then exit;
   UploadReplay(Path+'\Maps\Replays\LastReplay.rep','url');
   Log('LastReplay: '+inttostr(Age)+' '+Path+'\Maps\Replays\LastReplay.rep');
  end;
end;

procedure Autoreplay_Init;
begin
 Age:=FileAge(Path+'\Maps\Replays\LastReplay.rep');
 Log('LastReplay: '+inttostr(Age)+' '+Path+'\Maps\Replays\LastReplay.rep');
end;

procedure Autoreplay_Timer;
begin
 if gettickcount-lastrepcheck<10000 then exit;
 lastrepcheck:=gettickcount;
 CheckRep;
end;

procedure Autoreplay_Finish;
begin
 CheckRep;
 Age:=FileAge(Path+'\Maps\Replays\LastReplay.rep');
 Log('LastReplay: '+inttostr(Age)+' '+Path+'\Maps\Replays\LastReplay.rep');
end;

begin
 AddInitHandler(Autoreplay_Init,[pmLauncher]);
 AddTimerHandler(Autoreplay_Timer,[pmLauncher]);
 AddFinishHandler(Autoreplay_Finish,[pmLauncher]);
end.
