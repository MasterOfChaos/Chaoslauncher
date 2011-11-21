unit Autoreplay;

interface

implementation
uses windows,sysutils,classes,math,main,repanalyser,logger,config;
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

function FilterCharacters(const s:String):string;
var i:integer;
begin
 result:='';
 if settings.AutoreplayRemoveSpecialcharacters
  then begin
    for I := 1 to length(s) do
      if (s[i]in ['A'..'Z','a'..'z','0'..'9']) then result:=result+s[i];
  end
  else begin
    for I := 1 to length(s) do
     if not (s[i]in [#0..#31,'<','>',':','/','\','|','"','*','?',' ']) then result:=result+s[i];
  end;
end;


function GetRepName(const Filename,RepName:String):String;
var info:TReplayInfo;
    i:integer;
    space,nickspace:integer;
begin
 result:=RepName;
 fillchar(info,sizeof(info),0);
 if assigned(GetReplayInfo)then GetReplayInfo(pchar(Filename),info) else Log('RepAnalyser not loaded');
 if info.InfoVersion<>1 then begin Log('Call to RepAnalyser failed, incompatible Version');exit;end;
 if settings.AutoreplayIncludeGamename and
   ((length(info.gamename)>4)or not(settings.AutoreplayNoShortNames))
   then result:=result+' '+FilterCharacters(info.GameName);
 if settings.AutoreplayIncludeRaces and not settings.AutoreplayIncludePlayernames
  then begin
    result:=result+' ';
    for i := 0 to info.PlayerCount - 1 do
     case info.PlayerRace[i] of
       0:result:=result+'Z';
       1:result:=result+'T';
       2:result:=result+'P';
      end;
  end;
 if settings.AutoreplayIncludePlayernames
   then begin
    space:=27-(length(result)+info.PlayerCount);
    for i := 0 to info.PlayerCount-1 do
      begin
        info.playername[i]:=filtercharacters(info.playername[i]);
        if info.PlayerType[i]=1 then info.playername[i]:='Comp';
        nickspace:=ceil(space/(info.PlayerCount-i));
        if settings.AutoreplayIncludeRaces then nickspace:=nickspace-1;
        nickspace:=min(nickspace,length(info.playername[i]));
        result:=result+' '+copy(info.PlayerName[i],1,nickspace);
        space:=space-nickspace;
        if settings.AutoreplayIncludeRaces
          then begin
            case info.PlayerRace[i] of
              0:result:=result+'Z';
              1:result:=result+'T';
              2:result:=result+'P';
            end;
            space:=space-1;
          end;
      end;
   end;
end;

procedure CheckRep;
var RepNumber:integer;
    RepName:String;
//    Names:String;
begin
 if Settings.Autoreplay=false then exit;
 if FileAge(Path+'\Maps\Replays\LastReplay.rep')<>age then
  begin
   Log('Saving Autoreplay');
   Age:=FileAge(Path+'\Maps\Replays\LastReplay.rep');
   if Age=-1 then exit;   
   Repnumber:=CurrentRepNumber+1;
   forcedirectories(Path+'\Maps\Replays\Autoreplay');
   RepName:=inttostr(RepNumber);
   while length(RepName)<4 do
     Repname:='0'+Repname;
   Repname:=GetRepname(Path+'\Maps\Replays\LastReplay.rep',Repname);
   if not copyfile(pchar(Path+'\Maps\Replays\LastReplay.rep'),pchar(Path+'\Maps\Replays\Autoreplay\'+Repname+'.rep'),true)
     then MessageBox(0,'Replaysave failed','Error',MB_OK or MB_ICONERROR);
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
