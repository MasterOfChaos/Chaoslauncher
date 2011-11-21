unit LatencyPSL;

interface

implementation
uses windows,main,logger,classes,sysutils,offsets,textout,pluginapi;
var CurrentDelay:byte=0;
    CurrentReduceUserLat:boolean=false;

function GetGameName:String;
var read:Cardinal;
begin
  setlength(result,24);
  ReadProcessMemory(hProcess,Pointer(Addresses.GameName),PChar(Result),length(result),read);
  setlength(result,strlen(PChar(result)));
end;

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
  if Trainer.DWord[Addresses.Ingame2]=0 then exit;
  //Only patch while in lobby
  if Trainer.DWord[Addresses.Lobby]=0
    then begin
      result:=CurrentDelay;
      ReduceUserLat:=CurrentReduceUserLat;
      exit;
    end;
  if pos('!',GameName)>0
    then result:=2
    else result:=0;
end;

procedure Patch(Delay:byte);
var Data:String;
    Written:Cardinal;
begin
  Log('Patching Latency to '+inttostr(Delay));
  SendTextInLobby('LatencyChanger '+inttostr(PluginInfo.Major)+'.'+inttostr(PluginInfo.Minor)+PluginInfo.Sub+' enabled. Delay='+inttostr(Delay));
  Data:=#$B8+chr(Delay)+#0#0#0#$90#$90;
  WriteProcessMemory(hProcess,Pointer(Addresses.NetModeLatency),@Data[1],length(Data),Written);
  if Written<>cardinal(length(Data)) then Log('Write Error');
  CurrentDelay:=Delay;
end;

procedure UnPatch;
var Data:String;
    Written:Cardinal;
begin
  Log('Unpatching Latency');
  Data:=#$8B#$04#$95#$70#$CE#$51#$00;
  WriteProcessMemory(hProcess,Pointer(Addresses.NetModeLatency),@Data[1],length(Data),Written);
  if Written<>cardinal(length(Data)) then Log('Write Error');
  CurrentDelay:=0;
end;

procedure PatchUL;
var Data:String;
    Written:Cardinal;
begin
  Log('Patching UserLatency');
  SendTextInLobby('Reduced userlatency enabled');
  Data:=#$BE#$01#$00#$00#$00#$90;
  WriteProcessMemory(hProcess,Pointer(Addresses.ReducedUsetLat),@Data[1],length(Data),Written);
  if Written<>cardinal(length(Data)) then Log('Write Error');
  CurrentReduceUserLat:=true;
end;

procedure UnPatchUL;
var Data:String;
    Written:Cardinal;
begin
  Log('Unpatching UserLatency');
  Data:=#$8B#$35#$90#$F0#$57#$00;
  WriteProcessMemory(hProcess,Pointer(Addresses.ReducedUsetLat),@Data[1],length(Data),Written);
  if Written<>cardinal(length(Data)) then Log('Write Error');
  CurrentReduceUserLat:=false;
end;


procedure LatencyInit;
begin
  CurrentDelay:=0;
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
