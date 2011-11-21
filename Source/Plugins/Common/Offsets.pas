unit Offsets;

interface
type  TAddresses=record
       //Starcraft.exe
       LobbyPlayerinfo,
       NetModeLatency,
       ReducedUsetLat,
       GameName       :Cardinal;
       BNet           :Cardinal;
       Ingame         :Cardinal;
       Lobby          :Cardinal;
       SendTextLobby  :Cardinal;
       //Briefing       :Cardinal;
       DownloadStatus :Cardinal;
       ReplaySlot1    :Cardinal;
       Replay         :Cardinal;
       FactionID,
       PlayerID,
       Minerals,
       Vespine,
       //Building,
       Time,
       Population,
       PopAndBuild,
       Larva,
       Race,
       //2x of displayed Supply etc
       Supply,
       Control,
       Psy,
       MaxSupply,
       MaxControl,
       MaxPsy,
       HideReplayProgress,
       LocalTextOutIngame,
       LocalTextOutLobby,
       PlayerNames,
       ActionHook,
       PlayerSelection,
       PlayerColors,
       LagScreenDelay,
       Chatting,
       TeamMelee,
       UnitCounts,
       UnitCountsWithBuild,
       HidePW,
       //storm.dll
       Ingame2,
       ReplaySlot2,
       AntiPause      :Cardinal;
      end;
var Addresses:TAddresses;

const Addresses1151:TAddresses=(
       LobbyPlayerInfo:$57EEE8;
      );

const Addresses1152:TAddresses=(
       LobbyPlayerInfo: $0057EEE8;
       NetModeLatency : $004D925B; //Code
       ReducedUsetLat : $00485807; //Code
       GameName       : $005967E4;
       BNet           : $006D5EB0; //DW
       Ingame         : $006D11D4; //DW
       Lobby          : $0068ED08;
       SendTextLobby  : $00470BD0; //Code
       //Briefing       :$00655498;
       DownloadStatus : $0068F4E4;
       ReplaySlot1    : $00596805; //byte
       Replay         : $006D0EFC; //DW
       PlayerID       : $00512684; //DW
       Minerals       : $0057F0D8; //DW, +4*Player
       Vespine        : $0057F108; //DW, +4*Player
       Time           : $0057F224; //DW
       Population     : $00581DFC; //DW, +4*Player
       PopAndBuild    : $00581DCC; //DW, +4*Player
       Larva          : $0058545C; //DW, +4*Player
       Race           : $0059B404; //DW, +72*Player
       //2x of displayed Supply etc
       Supply         : $005821EC; //DW, +4*Player
       Control        : $0058215C; //DW, +4*Player
       Psy            : $0058227C; //DW, +4*Player
       MaxSupply      : $005821BC; //DW, +4*Player
       MaxControl     : $0058212C; //DW, +4*Player
       MaxPsy         : $0058224C; //DW, +4*Player
       HideReplayProgress:$00427AAA;//Code
       LocalTextOutIngame:$0048CD60;//Code
       PlayerNames    : $0057EEEB;
       ActionHook     : $00486A33; //Hook
       PlayerSelection: $006284D0; //array
       PlayerColors   : $00581DBE; //array

       Ingame2        : $1505C4B8; //DW
       ReplaySlot2    : $1505E418; //byte
      );

const Addresses1153:TAddresses=(
       LobbyPlayerInfo: $0057EEE8; //data
       NetModeLatency : $004D92BB; //code
       ReducedUsetLat : $00485837; //code
       GameName       : $005967E4; //string
       Bnet           : $006D5EB0; //LongBool
       Ingame         : $006D11D4; //DW
       Lobby          : $0068ED08; //data
       SendTextLobby  : $00470C20; //func
       DownloadStatus : $0068F4E4; //data
       ReplaySlot1    : $00596805; //byte
       Replay         : $006D0EFC; //DW
       FactionID      : $00512684; //DW
       PlayerID       : $00512688; //DW
       Time           : $0057F224; //DW
       //2x of displayed Supply etc
       Supply         : $005821EC; //DW, +4*Player
       Control        : $0058215C; //DW, +4*Player
       Psy            : $0058227C; //DW, +4*Player
       HideReplayProgress:$00427ADA;//Code
       LocalTextOutIngame:$0048CD90; //Func
       LocalTextOutLobby:$004B8D10;//Func
       PlayerNames    : $0057EEEB; //data
       ActionHook     : $00486A63; //Hook
       PlayerSelection: $006284D0; //array
       PlayerColors   : $00581DBE; //array
       LagScreenDelay : $004862CF;//DW inside code
       Chatting       : $0068C12C;//DW
       UnitCounts     : $00584DCC;//array[0..MaxUnit,0..11]of DWord
       UnitCountsWithBuild:$0058230C;//array[0..MaxUnit,0..11]of DWord

       Ingame2        : $1505E37C; //ByteBool (internally it is the max number of players atm)
       ReplaySlot2    : $1505E37C; //byte
       AntiPause      :    $1F737;//relative to storm.dll
      );


const Addresses1160:TAddresses=(
       LobbyPlayerInfo: $0057EEC8; //data
       NetModeLatency : $004D94EB; //code
       ReducedUsetLat : $004859D7; //code
       GameName       : $005967DC; //string
       Bnet           : $006D5EA8; //LongBool
       Ingame         : $006D11CC; //DW
       Lobby          : $0068ED00; //data
       DownloadStatus : $0068F4DC; //data
       ReplaySlot1    : $005967FD; //byte
       Replay         : $006D0EF4; //DW
       HideReplayProgress:$00427AAA;//Code
       LagScreenDelay : $004864AF;//DW inside code
       Chatting       : $0068C124;//DW
       HidePW         : $004B8B90; //Code

       Ingame2        : $1505BC08; //ByteBool (internally it is the max number of players atm)
       ReplaySlot2    : $1505BC08; //byte
      );

const Addresses1161:TAddresses=(
       LobbyPlayerInfo: $0057EEE8; //data
       NetModeLatency : $004D962B; //code
       ReducedUsetLat : $004859D7; //code
       GameName       : $005967FC; //string
       Bnet           : $006D5ED0; //LongBool
       Ingame         : $006D11EC; //DW
       Lobby          : $0068ED20; //data
       DownloadStatus : $0068F4FC; //data
       ReplaySlot1    : $0059681D; //byte
       Replay         : $006D0F14; //DW

       PlayerID       : $00512684; //DW
       Minerals       : $0057F0F0; //DW, +4*Player
       Vespine        : $0057F120; //DW, +4*Player
       Time           : $0057F23C; //DW
       Population     : $00581E14; //DW, +4*Player
       PopAndBuild    : $00581DE4; //DW, +4*Player
       Larva          : $00585474; //DW, +4*Player
       Race           : $0059B41C; //DW, +72*Player
       //2x of displayed Supply etc
       Supply         : $00582204; //DW, +4*Player
       Control        : $00582174; //DW, +4*Player
       Psy            : $00582294; //DW, +4*Player
       MaxSupply      : $005821D4; //DW, +4*Player
       MaxControl     : $00582144; //DW, +4*Player
       MaxPsy         : $00582264; //DW, +4*Player

       HideReplayProgress:$00427ABA;//Code
       PlayerNames    : $0057EEEB; //data
       LagScreenDelay : $004865BF;//DW inside code
       Chatting       : $0068C144;//DW
       UnitCounts     : $00584DE4;//array[0..MaxUnit,0..11]of DWord
       UnitCountsWithBuild: $00582324;//array[0..MaxUnit,0..11]of DWord

       Ingame2        : $1505BBC8; //ByteBool (internally it is the max number of players atm)
       ReplaySlot2    : $1505BBC8; //byte
      );


implementation

initialization
  Addresses:=Addresses1161;
finalization
end.
