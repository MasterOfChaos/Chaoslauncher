unit AntiSpoof;

interface

procedure AntiSpoofTimer;

implementation
uses windows,sysutils,offsets,ScHelper,util,asmhelper,logger,keyvalue,config,ScInfo;

var CheckedNicks:TSortKeyValue;
    CurrentNick:String;

const nsUnknown =0;
      nsOK      =1;
      nsSpoof   =2;
      nsOther   =-1;

function GetDisplayNick(const S:String):String;
var Status:String;
begin
  result:=S;
  if S='' then exit;

  Status:=CheckedNicks[lowercase(S)];

  if Status=IntToStr(nsOK) then result:=#6+S;
  if Status=IntToStr(nsSpoof) then result:=#7+S;
end;

var OrigStrCompare:function (P1,P2:PChar):integer;cdecl;
    OrigStrCopy:function (P1,P2:PChar;Count:integer):integer;stdcall;
    OrigLobbyBNetMsg:pointer;
    SendBnetCmd:procedure (S:PChar);stdcall;

function PlayerNumFromNickAddress(Addr:Pointer):integer;
var Offset:Cardinal;
    PlayerNum:Cardinal;
    Remainder:Cardinal;
begin
  result:=-1;
  Offset:=Cardinal(int64(Addr)-int64(Addresses.PlayerNames));

  PlayerNum:=Offset div 36;
  Remainder:=Offset mod 36;
  if PlayerNum>MaxPlayers-1 then exit;
  if Remainder<>0 then exit;
  result:=PlayerNum;
end;

function Nick_StrCompare(P1,P2:PChar):integer;cdecl;
var S1,S2:String;
    PlayerNum:integer;
begin
  result:=0;
  try
    //Normal compare
    result:=OrigStrCompare(P1,P2);

    PlayerNum:=PlayerNumFromNickAddress(P1);
    if PlayerNum<0 then exit;

    //It is a player
    S1:=GetPlayerName(PlayerNum);
    S1:=GetDisplayNick(S1);
    S2:=P2;
    result:=CompareStr(S1,S2);
  except
    on e:exception do
      SimpleMessageBox(smtError,e.message);
  end;
end;

function Nick_Copy(Dest,Src:PChar;Count:integer):integer;stdcall;
var PlayerNum:integer;
    S:String;
begin
  if not(assigned(OrigStrCopy)) then SimpleMessageBox(smtError,'storm.dll #501 not found');
  PlayerNum:=PlayerNumFromNickAddress(Src);
  if PlayerNum<0
    then begin//No Player
      result:=OrigStrCopy(Dest,Src,Count);
    end
    else begin
      S:=GetPlayerName(PlayerNum);
      S:=GetDisplayNick(S);
      result:=OrigStrCopy(Dest,PChar(S),Count);
    end;
end;


procedure SendWhois(const Name:String);
begin
  Log('/whois '+Name);
  SendBnetCmd(PChar('/whois '+Name));
end;

function CheckMsg(Nick,GameName,Msg:String):integer;
var ContainsGamename,ContainsNick:boolean;
    IngameMsg:boolean;
    OutgameMsg:boolean;
    OtherMsg:boolean;
    OrgMsg:String;
    Named:boolean;
procedure CheckTemplate(var State:boolean;const MsgTemplate:String;IsNamed:boolean);
var Len:integer;
begin
  Len:=Length(Msg);
  Msg:=StringReplace(Msg,MsgTemplate,'',[rfReplaceAll]);
  if length(Msg)<>len
    then begin
      State:=true;
      if IsNamed then Named:=true;
    end;
end;

begin
  OrgMsg:=Msg;
  msg:=lowercase(msg);
  Named:=false;
  //Is a message indicating that the player is in a game
  //Also removes mainpart of message
  IngameMsg:=false;
  CheckTemplate(IngameMsg,' is using starcraft: broodwars and is currently in  game ',true);//ICCup
  CheckTemplate(IngameMsg,' is using starcraft: broodwars and is currently in private game ',true);//ICCup
  CheckTemplate(IngameMsg,'you are using starcraft: broodwars and are currently in  game ',false);//ICCup
  CheckTemplate(IngameMsg,'you are using starcraft: broodwars and are currently in private game ',false);//ICCup
  CheckTemplate(IngameMsg,'is using starcraft broodwar in game ',true);//BNet
  CheckTemplate(IngameMsg,'is using starcraft broodwar in the password protected game ',true);//BNet
  CheckTemplate(IngameMsg,', using starcraft broodwar in game ',false);//BNet
  CheckTemplate(IngameMsg,', using starcraft broodwar in the password protected game ',false);//BNet

  //Is a message indicating that the player is not in a game
  //Also removes mainpart of message
  OutgameMsg:=false;
  CheckTemplate(OutgameMsg,' is using starcraft: broodwars and is currently in channel ',true);//ICCup
  CheckTemplate(OutgameMsg,'unknown user.',false);//ICCup
  CheckTemplate(OutgameMsg,'user was last seen on',false);//ICCup
  CheckTemplate(OutgameMsg,'that user is not logged on.',false);//BNet
  CheckTemplate(IngameMsg,'is using starcraft broodwar in channel ',true);//BNet

  OtherMsg:=false;
  CheckTemplate(OtherMsg,'''s record:',False);//BNet
  CheckTemplate(OtherMsg,'too many server requests',False);//Bnet
  CheckTemplate(OtherMsg,'normal games:',false);//BNet
  CheckTemplate(OtherMsg,'ladder games:',false);//Bnet
  if pos(lowercase(Nick),lowercase(GameName))>0
    then begin
      Log('Gamename=Nick');
      result:=nsUnknown;
      exit;
    end;

  //Msg contains nick?
  //also removes nick from msg
  ContainsNick:=false;
  CheckTemplate(ContainsNick,lowercase(Nick),false);

  //Msg contains GameName
  ContainsGameName:=pos(lowercase(GameName),Msg)>0;
  result:=nsUnknown;

  if IngameMsg and ContainsGameName
    then result:=nsOK;
  if IngameMsg and not ContainsGameName
    then result:=nsSpoof;
  if OutGameMsg
    then result:=nsSpoof;
  if Named and not ContainsNick then result:=nsOther;
  if OtherMsg then result:=nsOther;
  
  
  Log('Nick:"'+nick+'" Game:"'+GameName+'" Msg:"'+msg+'" OrgMsg:"'+OrgMsg+'"');
  if IngameMsg then Log('IngameMsg');
  if OutgameMsg then Log('OutgameMsg');
  if OtherMsg then Log('OtherMsg');
end;

procedure CheckNext;
var player:integer;
begin
  if CurrentNick<>'' then exit;
  CurrentNick:='';
  for player:=0 to MaxPlayers-1 do
   if CheckedNicks[lowercase(GetPlayerName(player))]=''
     then begin
       CurrentNick:=GetPlayerName(player);
       if CurrentNick='' then continue;
       SendWhois(CurrentNick);
       exit;
     end;
end;

var AntiSpoofPatches:TPatchGroup;
    LobbyBNetMsgHook:THookFunction;
    LobbyTickHook:THookFunction;


procedure AntiSpoofTimer;
var enable:boolean;
begin
  enable:=Settings.SpoofDetector and(IsLobby);
  if enable and not AntiSpoofPatches.enabled then Log('Activate Antispoof');
  if not enable and AntiSpoofPatches.enabled
    then begin
      Log('Deactivate Antispoof');
      CheckedNicks.clear;
      CurrentNick:='';
    end;
  AntiSpoofPatches.enabled:=enable;
end;

procedure LobbyBNetMsg(var CPU:TCPUState);
var Registers:TFunctionCallRegisters;
    pMsg:PChar;
    Msg:String;
    DisplayMsg:boolean;
    State:integer;
begin
  pMsg:=PChar(CPU.Stack[0]);
  Msg:=pMsg;
  CPU.SetStackImbalance(-4);
  DisplayMsg:=true;//CurrentNick='';
  if CurrentNick<>''
    then begin
      State:=CheckMsg(CurrentNick,GetGameName,Msg);
      if State>=0
        then begin
          CheckedNicks[lowercase(CurrentNick)]:=inttostr(State);
          CurrentNick:='';
        end;
      if State>0 then DisplayMsg:=false;
    end;
  if not DisplayMsg then exit;
  Registers.FromCPUState(CPU);
  CallFunction(OrigLobbyBNetMsg,Registers,[pMsg]);
  Registers.ToCPUState(CPU);
end;

var LastCheck:Cardinal;
procedure LobbyTick(var CPU:TCPUState);
begin
  //replaced code
  cpu.esi:=cpu.edx;
  cpu.eax.uint:=PWord(cpu.esi.uint+$C)^;
  if gettickcount-lastcheck<500 then exit;
  lastcheck:=gettickcount;
  CheckNext;
end;

initialization
{  CheckedNicks:=TRecommendedKeyValue.create;
  OrigStrCompare:=Pointer($409CD0);
  OrigLobbyBNetMsg:=Pointer($4B8EC0);
  SendBNetCmd:=Pointer($47FA10);
  AntiSpoofPatches:=TPatchGroup.create(nil);
  LobbyBNetMsgHook:=THookFunction.create(LobbyBnetMsg);
  LobbyTickHook:=THookFunction.create(LobbyTick);
  TRawCallpatch.Create(AntiSpoofPatches,$409D46,@Nick_StrCompare);
  TRawCallpatch.Create(AntiSpoofPatches,$451BE6,@Nick_Copy);
  TCallpatch.Create(AntiSpoofPatches,$47FB2F,LobbyBNetMsgHook);
  TCallpatch.Create(AntiSpoofPatches,$4B9926,LobbyTickHook,false,1);
  OrigStrCopy:=GetProcAddress(GetModuleHandle('storm.dll'),PChar(501));
finalization
  AntiSpoofPatches.free;
  CheckedNicks.free;}
end.
