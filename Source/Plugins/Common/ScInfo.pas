unit ScInfo;
//Functions to get info from Starcraft
//All functions in this file have to work from the launcher process and when injected

interface
uses patcher;

type TPlayerID=type byte;

//Checks the requirenments for an observer
function IsPotentialObserver(PlayerNr:TPlayerID):boolean;
//Returns the double of the sum of supply for all races
function GetDoubleSupply(PlayerNr:TPlayerID):integer;
//Ingame only while playing, not lobby etc
function IsIngame:boolean;
//Connected to bnet?
function IsBNet:boolean;
//Regards Lobby,Briefing etc as ingame too
function IsIngame2:boolean;

function IsLobby:boolean;
//Does not check for ingame, but only if it is a replay
function IsReplay:boolean;
//Ingamechat
function IsChatting:boolean;
//Gametime in frames
function GetTime:Cardinal;
function GetGameName:String;
function GetMinerals(PlayerNr:TPlayerID):integer;
function GetVespine(PlayerNr:TPlayerID):integer;
function GetLocalPlayer:TPlayerID;
function GetLocalFaction:TPlayerID;
function GetPlayerName(Player: TPlayerID): string;

var Trainer:TTrainer;
procedure OpenScInfo(ProcessHandle:THandle);
procedure CloseScInfo;

implementation
uses pluginapi,windows,offsets,util;

function IsPotentialObserver(PlayerNr:TPlayerID):boolean;
begin
  result:=(GetDoubleSupply(PlayerNr)<=2)
          and(GetMinerals(PlayerNr)<=50)
          and(GetVespine(PlayerNr)=0);
end;

function GetDoubleSupply(PlayerNr:TPlayerID):integer;
begin
  result:=Trainer.DWord[addresses.Supply +4*PlayerNr]+
          Trainer.DWord[addresses.Psy    +4*PlayerNr]+
          Trainer.DWord[addresses.Control+4*PlayerNr];
end;

function IsIngame:boolean;
begin
  result:=Trainer.DWord[Addresses.Ingame]<>0;
end;

function IsIngame2:boolean;
begin
  result:=Trainer.DWord[Addresses.Ingame2]<>0;
end;

function IsLobby:boolean;
begin
  result:=Trainer.DWord[Addresses.Lobby]<>0
end;

function GetTime:Cardinal;
begin
  result:=Trainer.DWord[Addresses.Time];
end;

function IsBNet:boolean;
begin
  result:=Trainer.DWord[Addresses.BNet]<>0;
end;

function IsReplay:boolean;
begin
  result:=Trainer.DWord[Addresses.Replay]<>0;
end;

function IsChatting:boolean;
begin
  result:=Trainer.DWord[Addresses.Chatting]<>0;
end;

function GetGameName:String;
begin
  result:=Trainer.ReadStrZT(Addresses.GameName,24);
end;

function GetMinerals(PlayerNr:TPlayerID):integer;
begin
  result:=Trainer.DWord[Addresses.Minerals+4*PlayerNr];
end;

function GetVespine(PlayerNr:TPlayerID):integer;
begin
  result:=Trainer.DWord[Addresses.Vespine+4*PlayerNr];
end;

function GetLocalPlayer:TPlayerID;
begin
  result:=Trainer.Byte[Addresses.PlayerID];
end;

function GetLocalFaction:TPlayerID;
begin
  result:=Trainer.Byte[Addresses.FactionID];
end;

function GetPlayerName(Player: TPlayerID): string;
begin
  result:=Trainer.ReadStrZT(Addresses.PlayerNames+36*Player,24);
end;

//

procedure OpenScInfo(ProcessHandle:THandle);
begin
  Trainer.OpenProcessHandle(ProcessHandle);
end;

procedure CloseScInfo;
begin
  Trainer.close;
end;

initialization
  Trainer:=TTrainer.create;
finalization
  Trainer.free;
end.
