unit Latency;

interface

var LatencyExclamationMarkSyntax:boolean=false;

implementation
uses latencyconfig,windows,main,logger,classes,sysutils,offsets,textout,pluginapi,scinfo,asmhelper;
var CurrentDelay:byte=0;
    CurrentReduceUserLat:boolean=false;
    Backup,BackupUL:String;

{procedure MemDump(const filename:String);
var S:String;
    BytesRead:Cardinal;
    stm:TFilestream;
begin
  setlength(S,$FE000);
  ReadProcessMemory(hProcess,Pointer($00400000),PChar(S),length(S),BytesRead);
  setlength(S,BytesRead);
  stm:=TFilestream.create(filename,fmCreate or fmShareDenyWrite);
  stm.writebuffer(S[1],length(S));
  stm.free;
end;     }


procedure GetDelay(GameName:String;out result:byte;out ReduceUserLat:boolean);
begin
  result:=0;
  ReduceUserLat:=false;
  //Unpatch when leaving game,lobby,etc
  if not IsIngame2 then exit;
  //Only patch while in lobby
  if not IsLobby
    then begin
      result:=CurrentDelay;
      ReduceUserLat:=CurrentReduceUserLat;
      exit;
    end;
  //Get Mode
  if IsBnet
    then begin//BnetMode
      GameName:=GetGameName;
      if LatencyExclamationMarkSyntax and(pos('!',GameName)=0)
        then result:=2;//for PSL
      if length(GameName)<3 then exit;
      delete(Gamename,1,length(GameName)-3);
      if GameName[1]<>'#' then exit;
      if Upcase(GameName[2])<>'L' then exit;
      case GameName[3] of
        'L','l':result:=2;
        '1'..'5':result:=ord(GameName[3])-ord('0');
      end;
    end
    else begin//LanMode
      if Settings.LanLatency1
        then result:=1
        else result:=0;
      ReduceUserLat:=Settings.LANReducedUserLatency;
    end;
end;

procedure Patch(Delay:byte);
var Data:String;
begin
  Log('Patching Latency to '+inttostr(Delay));
  //SendTextInLobby('LatencyChanger '+inttostr(PluginInfo.Major)+'.'+inttostr(PluginInfo.Minor)+PluginInfo.Sub+' enabled. Delay='+inttostr(Delay));
  Data:=#$B8+chr(Delay)+#0#0#0#$90#$90;
  WriteString(Addresses.NetModeLatency,Data,Game.ProcessHandle);
  CurrentDelay:=Delay;
end;

procedure UnPatch;
begin
  Log('Unpatching Latency');
  WriteString(Addresses.NetModeLatency,Backup,Game.ProcessHandle);
  CurrentDelay:=0;
end;

procedure PatchUL;
var Data:String;
begin
  Log('Patching UserLatency');
  //SendTextInLobby('Reduced userlatency enabled');
  Data:=#$BE#$01#$00#$00#$00#$90;
  WriteString(Addresses.ReducedUsetLat,Data,Game.ProcessHandle);
  CurrentReduceUserLat:=true;
end;

procedure UnPatchUL;
begin
  Log('Unpatching UserLatency');
  WriteString(Addresses.ReducedUsetLat,BackupUL,Game.ProcessHandle);
  CurrentReduceUserLat:=false;
end;


procedure LatencyInit;
begin
  CurrentDelay:=0;
  Backup:=ReadString(Addresses.NetModeLatency,7,Game.ProcessHandle);
  BackupUL:=ReadString(Addresses.ReducedUsetLat,6,Game.ProcessHandle);
end;

var InLobbyBefore:boolean=false;

procedure LatencyTimer;
var Delay:byte;
    ReduceUserLat:boolean;
begin
  GetDelay(GetGameName,Delay,ReduceUserLat);
  if Delay<>CurrentDelay
    then begin
      if Delay>0
        then Patch(Delay)
        else UnPatch;
    end;
  if ReduceUserLat<>CurrentReduceUserLat
    then begin
      if ReduceUserLat
        then PatchUL
        else UnPatchUL;
    end;
end;

initialization
  AddInitHandler(LatencyInit,[pmLauncher]);
  AddTimerHandler(LatencyTimer,[pmLauncher]);
end.
