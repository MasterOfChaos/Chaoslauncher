unit Coach;

interface
uses windows,classes,sysutils,graphics,main,lua,patcher,logger,sound;
type TGamedata=record
 PlayerID,
 Minerals,Vespine,
 Building,
 Ingame,
 Population,PopAndBuild,
 //Larva,
 //2x of displayed Supply etc
 Supply,Control,Psy,
 MaxSupply,MaxControl,MaxPsy:Cardinal;
end;

const Addresses:TGamedata=(
       PlayerID   : $00512684;
       Minerals   : $0057F0D8; //DW, +4*Player
       Vespine    : $0057F108; //DW, +4*Player
       Ingame     : $006D5250; //DW
       Population : $00581DFC; //DW, +4*Player
       PopAndBuild: $00581DCC; //DW, +4*Player
       //Larva      : $0058299C;
       //2x of displayed Supply etc
       Supply     : $005821EC; //DW, +4*Player
       Control    : $0058215C; //DW, +4*Player
       Psy        : $0058227C; //DW, +4*Player
       MaxSupply  : $005821BC; //DW, +4*Player
       MaxControl : $0058212C; //DW, +4*Player
       MaxPsy     : $0058224C; //DW, +4*Player
      );
var Data:TGameData;
(*const UnitsAddress=Pointer($63D630);
      UnitRecordSize=328;
Type
PSCUnit=^TSCUnit;
TSCUnit=packed record
  pPrev:Cardinal; // 0x00
  pNext:Cardinal; // 0x04
  mana:byte; // 0x08
  hp:Word; // 0x09
  unknown1:array[1..$0d]of byte; // 0x0b
  posX:Word; // 0x18
  posY:Word; // 0x1a
  reverse2:array[1..$48]of byte; // 0x1c
  objectType:byte; // 0x64
  unknown3:array[1..$7]of byte; // 0x65
  pNext2:Cardinal; // 0x6c
  unknown4:array[1..$10]of byte; // 0x70
  pInThisUnit:Cardinal; // 0x80, correlative transporter
  unknown5:array[1..$13]of byte; // 0x84
  STATUS_VALUE:byte {ATTACHED = 6, LAUNCHING = 7};
  status:byte; // 0x97, ATTACHED: Interceptors were attached to Carrier
  // LAUNCHING: Interceptors is launching an attack
  unknown6:array [1..$28]of byte; // 0x98
  pFollowWith:Cardinal; // 0xc0, Carrier's Interceptor
end;     *)


implementation
var LS:Lua_State;
    mem:TTrainer;
    Scriptname:String;
type
  ELua=class(Exception);
  ELuaError=class(ELua);
  ELuaPanic=class(ELua);
  ELuaNoState=class(ELua);

procedure luaD_pushstring(L: lua_State; const s: String);
begin
  lua_pushlstring(l,@s[1],length(s));
end;

function luaD_tostring(L: lua_State; idx: Integer): String;
begin
 setlength(result,Lua_StrLen(L,idx));
 move(Lua_ToString(L,idx)^,result[1],length(result));
end;

function LuaPanic(L: lua_State): Integer; cdecl;
var s:String;
begin
 S:=luaD_tostring(L,-1);
 Lua_Close(L);
 raise ELuaPanic.create('Luapanic: '+S);
end;

procedure LuaD_TestError(ReturnCode:integer);
var s:String;
begin
 Case Returncode of
  0:;
  LUA_ERRRUN   : S:='Run';
  LUA_ERRFILE  : S:='File';
  LUA_ERRSYNTAX: S:='Syntax';
  LUA_ERRMEM   : S:='Memory';
  LUA_ERRERR   : S:='Errorhandler';
  else           S:='Unknown'+inttostr(ReturnCode);
 End;
 if Returncode<>0 then
  raise ELuaError.create('Lua-'+S+'-Error:'#13#10+LuaD_ToString(LS,-1));
end;

function LuaSound(L: lua_State): Integer; cdecl;
var Name:String;
    Delay:integer;
begin
 if not lua_isstring(L,1) then luaL_error(L,'String expected as Soundname');
 if (lua_gettop(L)>=2)and not lua_isnumber(L,2) then LuaL_error(L,'Integer expected as Sounddelay');
 Name:=LuaD_ToString(L,1);
 if lua_gettop(L)>=2 then Delay:=round(lua_tonumber(L,2))else Delay:=0;
 PlaySound(Name,Delay);
 result:=0;
end;

procedure Lua_Init;
var sl:TStringlist;
begin
 if ls<>nil then exit; 
 InitSound;
 LS:=lua_open();
 lua_atpanic(LS,LuaPanic);
 if LS=nil then raise exception.create('Luainitfehler');
 luaopen_base(LS);             // opens the basic library
 luaopen_table(LS);            // opens the table library
 luaopen_string(LS);           // opens the string lib.
 luaopen_math(LS);             // opens the math lib.
 lua_pop(LS,4);
 sl:=TStringlist.create;
 try
   sl.loadfromfile(Scriptname);
   LuaD_TestError(luaL_loadbuffer(LS,PChar(sl.text),length(sl.text),pchar(scriptname)));
   LuaD_TestError(Lua_PCall(LS,0,0,0));
 finally
   sl.free;
 end;
 lua_pushcfunction(LS,LuaSound);
 lua_setglobal(LS,'Sound');

 Lua_GetGlobal(LS,'StartGame');
 if not Lua_IsNil(LS,-1)
  then LuaD_TestError(lua_pcall(LS,0,0,0))
  else lua_pop(LS,1);
end;

procedure Lua_Finish;
begin
 if ls=nil then exit;
 Lua_GetGlobal(LS,'EndGame');
 if not Lua_IsNil(LS,-1)
  then LuaD_TestError(lua_pcall(LS,0,0,0))
  else lua_pop(LS,1);
 lua_close(LS);
 LS:=nil;
 FinishSound;
end;

procedure ReadGameData(const Addresses:TGamedata;var Data:TGamedata);
begin
 Data.PlayerID   := mem.DWord[Addresses.PlayerID];
 Data.Ingame     := mem.DWord[Addresses.Ingame];
 Data.Minerals   := mem.DWord[Addresses.Minerals+4*Data.PlayerID];
 Data.Vespine    := mem.DWord[Addresses.Vespine+4*Data.PlayerID];
 Data.Building   := mem.DWord[Addresses.Building+4*Data.PlayerID];
 Data.Supply     := mem.DWord[Addresses.Supply+4*Data.PlayerID];
 Data.Control    := mem.DWord[Addresses.Control+4*Data.PlayerID];
 Data.Psy        := mem.DWord[Addresses.Psy+4*Data.PlayerID];
 Data.MaxSupply  := mem.DWord[Addresses.MaxSupply+4*Data.PlayerID];
 Data.MaxControl := mem.DWord[Addresses.MaxControl+4*Data.PlayerID];
 Data.MaxPsy     := mem.DWord[Addresses.MaxPsy+4*Data.PlayerID];
 Data.Population := mem.DWord[Addresses.Population+4*Data.PlayerID];
 Data.PopAndBuild:= mem.DWord[Addresses.PopAndBuild+4*Data.PlayerID];
 //Data.Larva      := mem.DWord[Addresses.Larva+4*Data.PlayerID];
end;

procedure Coach_Init;
begin
 mem:=TTrainer.createprocesshandle(hProcess);
end;

procedure Coach_Finish;
begin
 Lua_Finish;
 mem.free;
 mem:=nil;
end;


procedure Coach_Timer;
var IngameBefore:Boolean;
begin
 ingamebefore:=data.ingame<>0;
 ReadGameData(Addresses,Data);
 if not ingamebefore and (data.ingame<>0) then Lua_Init;
 if ingamebefore and not (data.ingame<>0) then Lua_Finish;
 if LS=nil then exit;
 if lua_gettop(LS)<>0 then Log('Stack not empty at timerstart');
 lua_getglobal(LS,'Player');
 if Lua_IsNil(LS,-1)
  then begin
   lua_pop(LS,1);
   lua_newtable(LS);
  end;
 lua_pushstring(LS,'Minerals');
 lua_pushnumber(LS,Data.Minerals);
 lua_settable(LS,-3);

 lua_pushstring(LS,'Vespine');
 lua_pushnumber(LS,Data.Vespine);
 lua_settable(LS,-3);

 lua_pushstring(LS,'Supply');
 lua_pushnumber(LS,Data.Supply*0.5);
 lua_settable(LS,-3);

 lua_pushstring(LS,'MaxSupply');
 lua_pushnumber(LS,Data.MaxSupply*0.5);
 lua_settable(LS,-3);

 lua_pushstring(LS,'Psy');
 lua_pushnumber(LS,Data.Psy*0.5);
 lua_settable(LS,-3);

 lua_pushstring(LS,'MaxPsy');
 lua_pushnumber(LS,Data.MaxPsy*0.5);
 lua_settable(LS,-3);

 lua_pushstring(LS,'Control');
 lua_pushnumber(LS,Data.Control*0.5);
 lua_settable(LS,-3);

 lua_pushstring(LS,'MaxControl');
 lua_pushnumber(LS,Data.MaxControl*0.5);
 lua_settable(LS,-3);

 lua_pushstring(LS,'Population');
 lua_pushboolean(LS,Data.Population<>0);
 lua_settable(LS,-3);

 lua_pushstring(LS,'PopulationBuilding');
 lua_pushnumber(LS,Data.PopAndBuild-Data.Population);
 lua_settable(LS,-3);

 //lua_pushstring(LS,'Larva');
 //lua_pushboolean(LS,Data.Larva<>0);
 //lua_settable(LS,-3);


 lua_setglobal(LS,'Player');

 Lua_GetGlobal(LS,'Timer');
 if not Lua_IsNil(LS,-1)
  then LuaD_TestError(lua_pcall(LS,0,0,0))
  else lua_pop(LS,1);
end;



initialization
 Scriptname:='Coach\default.lua';
 AddInitHandler(Coach_Init);
 AddTimerHandler(Coach_Timer);
 AddFinishHandler(Coach_Finish);
finalization
end.
