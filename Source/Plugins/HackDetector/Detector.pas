unit Detector;

interface

procedure DetectorActionHandler(TimeStamp:Cardinal;Player:byte;ActionID:byte;const Params;ParamSize:integer);
implementation
uses ScHelper,classes,sysutils,util,keyvalue,logger,config;

var ActionCounter:array[0..MaxPlayers-1]of TAbstractIndexedKeyValue;
    LastAction:array[0..MaxPlayers-1]of integer;
    MultiCommandFalsePositiveNotice:boolean=false;

procedure FinishFrame(TimeStamp:Cardinal);
var player:integer;
    i:integer;
    MaxCount:integer;
    Count:integer;
    TotalCount:integer;
begin
  for player:=0 to MaxPlayers-1 do
    begin
      MaxCount:=0;
      TotalCount:=0;
      for i:=0 to ActionCounter[player].Count-1 do
        begin
          //Log(ActionCounter[player].GetKeyAt(i)+'='+ActionCounter[player].GetValueAt(i));
          Count:=StrToInt(ActionCounter[player].GetValueAt(i));
          TotalCount:=TotalCount+Count;
          if Count>MaxCount then MaxCount:=Count;
        end;
      ActionCounter[player].clear;
      if (Settings.IngameDetectors)and(Settings.MultiCommand)
        and (TimeStamp>5)and(MaxCount>=Settings.MulticommandThresholdEffective)
        then begin
          LocalTextOut(#$08'MultiCommandHack('#$17+IntToStr(MaxCount)+#$08'): '+GetColoredPlayerName(Player)+#$1E' in frame '+inttostr(Timestamp));
          if not MultiCommandFalsePositiveNotice
            then LocalTextOut('');
          MultiCommandFalsePositiveNotice:=true;
        end;
      if (Settings.IngameDetectors)and(Settings.AutoMine)
        and (TimeStamp<=5)and(TotalCount>=4)
        then LocalTextOut(#$08'Automine: '+GetColoredPlayerName(Player)+#$1E' in frame '+inttostr(Timestamp));
      LastAction[player]:=-1;
    end;
end;

function CheckZergMinhack(TimeStamp:Cardinal;Player:byte;ActionID:byte;const Params;ParamSize:integer):boolean;
var UnitIndex:integer;
begin
  result:=false;
  if ActionID<>$20 then exit;//Not CancelTrain
  for UnitIndex:=0 to MaxSelection-1 do
    if (PlayerSelection[Player,UnitIndex]<>nil) and
       (PlayerSelection[Player,UnitIndex].unitID
       in [Zerg_Larva])
      then result:=true;
end;

function CheckNukeHack(TimeStamp:Cardinal;Player:byte;ActionID:byte;const Params;ParamSize:integer):boolean;
var UnitIndex:integer;
begin
  result:=false;
  if ActionID<>Action_Select then exit;
  for UnitIndex:=0 to MaxSelection-1 do
    if (PlayerSelection[Player,UnitIndex]<>nil) and
       (PlayerSelection[Player,UnitIndex].unitID
       in [Terran_Nuke])
      then result:=true;
end;

function CheckRallyPoint(TimeStamp:Cardinal;Player:byte;ActionID:byte;const Params;ParamSize:integer):boolean;
begin
  //Rally exploit is triggered if a move command is issued to a unit
  //not owned by the commanding player
  result:=false;
  if ActionID<>Action_Move then exit;
  if PlayerSelection[Player,0]=nil then exit;
  if PlayerSelection[Player,0].FactionID=GetPlayerFaction(Player) then exit;
  //if PlayerSelection[Player,0].StatusFlags and sfNoBuilding<>0 then exit;
  result:=true;
end;

var CurrentTimeStamp:Cardinal;
procedure DetectorActionHandler(TimeStamp:Cardinal;Player:byte;ActionID:byte;const Params;ParamSize:integer);
var ActionStr:String;
    CounterValue:integer;
begin
  if TimeStamp<>CurrentTimeStamp then FinishFrame(CurrentTimeStamp);
  CurrentTimeStamp:=TimeStamp;
  if player>12 then exit;//Invalid
  If ActionID=Action_NOP then exit;
  if (Settings.IngameDetectors)and(Settings.Minhack)
    and CheckZergMinhack(TimeStamp,Player,ActionID,Params,ParamSize)
    then LocalTextOut(ColorChar_Red+'Zerg-Mineralhack: '+GetColoredPlayerName(Player)+#$1E' in frame '+inttostr(Timestamp));
  if (Settings.IngameDetectors)and(Settings.NukeAnywhere)
    and CheckNukeHack(TimeStamp,Player,ActionID,Params,ParamSize)
    then LocalTextOut(ColorChar_Red+'Nuke-Hack: '+GetColoredPlayerName(Player)+#$1E' in frame '+inttostr(Timestamp));
  if (Settings.IngameDetectors)and(Settings.RallyPoint)
    and CheckRallyPoint(TimeStamp,Player,ActionID,Params,ParamSize)
    then LocalTextOut(ColorChar_Red+'Rally-Hack: '+GetColoredPlayerName(Player)+#$1E' in frame '+inttostr(Timestamp));
  //MultiCommand check
 if(LastAction[player]=Action_Select)and not(ActionID in[Action_Select,Action_Hotkey])
    then begin
      ActionStr:=MemToHex(ActionID,sizeof(ActionID))+MemToHex(Params,ParamSize);
      CounterValue:=StrToIntDef(ActionCounter[player][ActionStr],0);
      ActionCounter[player][ActionStr]:=IntToStr(CounterValue+1);
    end;
  LastAction[player]:=ActionID;
end;

procedure Init;
var player:integer;
begin
  for player:=0 to MaxPlayers-1 do
    ActionCounter[player]:=TRecommendedIndexedKeyValue.create;
end;

procedure Finish;
var player:integer;
begin
  for player:=0 to MaxPlayers-1 do
    ActionCounter[player].free;
end;

initialization
  init;
finalization
  finish;
end.
