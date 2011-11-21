unit Coach;

interface
uses windows,classes,sysutils,graphics,main,lua,patcher,logger,sound,pluginapi,offsets,scinfo,dialogs,util;
type TGamedata=record
 PlayerID,
 Minerals,Vespine,
 //Building,
 Ingame,
 Time,
 Population,PopAndBuild,
 Larva,
 Race,
 //2x of displayed Supply etc
 Supply,Control,Psy,
 MaxSupply,MaxControl,MaxPsy:Cardinal;
end;
var Data:TGameData;
    CoachDir:string;
implementation
var LS:Lua_State;
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
 LS:=nil;
 raise ELuaPanic.create('Luapanic: '+S);
end;

function LuaInclude(L:lua_State): Integer; cdecl;
var text:String;
begin
  if (lua_gettop(L)=0)then LuaL_error(L,'No params passed to MessageBox');
  text:=LuaD_ToString(L,1);
  text:=StringReplace(text,'..','',[rfReplaceAll]);
  lua_dofile(L,PChar(coachdir+text+'.lua'));
  result:=0;
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
 PlaySound(CoachDir+Name,Delay);
 result:=0;
end;

function LuaMessageBox(L: lua_State): Integer; cdecl;
var text:String;
begin
 if (lua_gettop(L)=0)then LuaL_error(L,'No params passed to MessageBox');
 text:=LuaD_ToString(L,1);
 showmessage(text);
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
 
 lua_pushcfunction(LS,LuaSound);
 lua_setglobal(LS,'Sound');
 lua_pushcfunction(LS,LuaInclude);
 lua_setglobal(LS,'include');
 
 sl:=TStringlist.create;
 try
   sl.loadfromfile(Scriptname);
   LuaD_TestError(luaL_loadbuffer(LS,PChar(sl.text),length(sl.text),pchar(scriptname)));
   LuaD_TestError(Lua_PCall(LS,0,0,0));
 finally
   sl.free;
 end;

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

procedure ReadGameData(var Data:TGamedata);
begin
 Data.PlayerID   := trainer.DWord[Addresses.PlayerID];
 Data.Ingame     := trainer.DWord[Addresses.Ingame];
 Data.Time       := trainer.DWord[Addresses.Time];
 Data.Minerals   := trainer.DWord[Addresses.Minerals+4*Data.PlayerID];
 Data.Vespine    := trainer.DWord[Addresses.Vespine+4*Data.PlayerID];
 Data.Supply     := trainer.DWord[Addresses.Supply+4*Data.PlayerID];
 Data.Control    := trainer.DWord[Addresses.Control+4*Data.PlayerID];
 Data.Psy        := trainer.DWord[Addresses.Psy+4*Data.PlayerID];
 Data.MaxSupply  := trainer.DWord[Addresses.MaxSupply+4*Data.PlayerID];
 Data.MaxControl := trainer.DWord[Addresses.MaxControl+4*Data.PlayerID];
 Data.MaxPsy     := trainer.DWord[Addresses.MaxPsy+4*Data.PlayerID];
 Data.Population := trainer.DWord[Addresses.Population+4*Data.PlayerID];
 Data.PopAndBuild:= trainer.DWord[Addresses.PopAndBuild+4*Data.PlayerID];
 Data.Larva      := trainer.DWord[Addresses.Larva+4*Data.PlayerID];
 Data.Race       := trainer.DWord[Addresses.Race+72*Data.PlayerID];
end;

procedure Coach_Init;
begin
end;

procedure Coach_Finish;
begin
  Lua_Finish;
end;


procedure Coach_Timer;
var IngameBefore:Boolean;
begin
  ingamebefore:=data.ingame<>0;
  ReadGameData(Data);
  if not ingamebefore and (data.ingame<>0) then Lua_Init;
  if ingamebefore and not (data.ingame<>0) then Lua_Finish;
  if LS=nil then exit;
  if lua_gettop(LS)<>0 then Log('Stack not empty at timerstart');
  lua_newtable(LS);

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

  lua_pushstring(LS,'Larva');
  lua_pushnumber(LS,Data.Larva);
  lua_settable(LS,-3);

  lua_pushstring(LS,'Race');
  case Data.Race of
    0:lua_pushstring(LS,'Z');
    1:lua_pushstring(LS,'T');
    2:lua_pushstring(LS,'P');
    else lua_pushnil(LS);
   end;
  lua_settable(LS,-3);

  lua_pushstring(LS,'Time');
  lua_pushnumber(LS,Data.Time);
  lua_settable(LS,-3);

  lua_pushstring(LS,'SecondsFastest');
  lua_pushnumber(LS,Data.Time*0.042);
  lua_settable(LS,-3);

  lua_setglobal(LS,'Player');

  Lua_GetGlobal(LS,'Timer');
  try
    if not Lua_IsNil(LS,-1)
      then LuaD_TestError(lua_pcall(LS,0,0,0))
      else lua_pop(LS,1);
  except
    on e:exception do
      ShowAndLogException(e,'Chaoscoach: in LuaTimer');
  end;
end;



initialization
  CoachDir:=extractfilepath(util.GetModuleFilename)+'Coach\';
  Scriptname:=CoachDir+'default.lua';
  AddInitHandler(Coach_Init,[pmLauncher]);
  AddTimerHandler(Coach_Timer,[pmLauncher]);
  AddFinishHandler(Coach_Finish,[pmLauncher]);
finalization
end.
