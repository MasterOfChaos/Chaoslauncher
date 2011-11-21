unit ScHelper;

interface

type TUnit=packed record
  Res1:packed array[1..$4C]of byte;
  FactionID:byte;
  Res2:packed array[1..$17]of byte;
  unitID:Word;
  Res3:packed array[1..$76]of byte;
  StatusFlags:Cardinal;
  Res4:packed array[1..$70]of byte;
 end;
type PUnit=^TUnit;

const Action_NOP      = $37;
      Action_Move     = $14;
      Action_Select   = $09;
      Action_Hotkey   = $13;

const MaxPlayers      = 12;
      MaxSelection    = 12;

const Zerg_Larva                    = $23;
      Terran_Nuke                   = $0E;

const ColorChar_Red   =#$08;

const sfNoBuilding      = 1 shl 17;

type TPlayerSelectionData=array[0..11]of array[0..11]of PUnit;
var PlayerSelection:^TPlayerSelectionData=nil;
function ColorToColorCode(Color:byte):char;
function FactionColor(Faction:byte):byte;
function FactionColorCode(Faction:byte):char;
function GetPlayerName(Player:byte):String;
function GetPlayerFaction(Player:byte):byte;
function GetColoredPlayerName(Player:byte):String;
function GetGameName:String;

procedure LocalTextOut_Ingame(const S:String);
procedure LocalTextOut_Lobby(const S:String;Color:cardinal);
procedure LocalTextOut(const S:String);

function GetStormFilename(hProcess:THandle):string;
function GetStarcraftFilename(hProcess:THandle):String;

implementation
uses offsets,util,logger,scinfo;
//const PlayerTextColors:array[0..11]of byte=($0F,$16,$10,$11,$0E,$08,$17,$15,$18,$19,$1B,$1C);

procedure LocalTextOut_Ingame(const S:String);
asm
  pushad;
  mov edi,eax;
  mov eax,0;
  mov ecx, Addresses.LocalTextOutIngame;
  call ecx;
  popad;
end;

procedure LocalTextOut_Lobby(const S:String;Color:cardinal);
asm
  pushad;
  push color;
  mov ecx,[$5999D4];
  mov eax,S;
  call Addresses.LocalTextOutLobby;
  popad;
end;

procedure LocalTextOut(const S:String);
begin
  Log(S);
  if IsInGame
    then LocalTextOut_Ingame(S)
    else if IsLobby
    then LocalTextOut_Lobby(S,$12)
    else Log('Unsupported gamemode. Msg not displayed');
end;

function ColorToColorCode(Color:byte):char;
begin
  case Color of
    $6F:result:=#$08;
    $A5:result:=#$0E;
    $9F:result:=#$0F;
    $A4:result:=#$10;
    $9C:result:=#$11;
    $13:result:=#$15;
    $54:result:=#$16;
    $87:result:=#$17;
    $B9:result:=#$18;
    $88:result:=#$19;
    $86:result:=#$1B;
    $33:result:=#$1C;
    $4D:result:=#$1D;
    $9A:result:=#$1E;
    $80:result:=#$1F;
    else result:=#2;
  end;
end;

function FactionColor(Faction:byte):byte;
begin
  result:=PByte(Addresses.PlayerColors+Faction)^;
end;

function FactionColorCode(Faction:byte):char;
begin
  result:=ColorToColorCode(FactionColor(Faction));
end;

function GetPlayerName(Player:byte):String;
begin
  setlength(result,24);
  move(Pointer(Addresses.PlayerNames+36*Player)^,result[1],length(result));
  Str_FitZeroTerminated(result);
end;

function GetColoredPlayerName(Player:byte):String;
begin
  result:=FactionColorCode(GetPlayerFaction(Player))+GetPlayerName(Player);
end;

function GetPlayerFaction(Player:byte):byte;
begin
  result:=Player;//PByte(Addresses.PlayerNames-1+36*Player)^;
end;

function GetGameName:String;
begin
  setlength(result,24);
  move(Pointer(Addresses.GameName)^,result[1],length(result));
  Str_FitZeroTerminated(result);
end;

function GetStormFilename(hProcess:THandle):string;
begin

end;

function GetStarcraftFilename(hProcess:THandle):String;
begin

end;

initialization
  PlayerSelection:=pointer(Addresses.PlayerSelection);
end.
