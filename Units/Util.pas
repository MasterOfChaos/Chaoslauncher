unit Util;
{*******************************************************************************
Copyright 2008 MasterOfChaos
DelphiWinner@gmx.de
Licence: Completely free
*******************************************************************************}
interface
uses windows,classes;

//File
function FileToString(const Filename:String):String;
procedure StringToFile(const S:String;const Filename:String);

//Windows
function EnablePrivilege(const Priv:String):boolean;
function GetErrorString(Error:DWord):String;
function GetLastErrorString:String;
function GetModuleFilename(hModule:THandle):String; overload;
function GetModuleFilename:String; overload;
function GetWindowsVersionStr:String;
function GetWindowsVersionStrShort:String;
function ModuleFromAddr(Addr:pointer):hModule;
function GetFileSize(const Filename:String):Int64;

//Strings
type TCharSet=set of Char;

procedure Str_ClearTo(var S:String;const SubStr:String);
function Str_CopyTo(const S,SubStr:String):String;
function Str_RemoveChars(const S:String;C:TCharSet):String;
function Str_CountChars(const S:String;C:TCharSet):integer;
procedure Str_FitZeroTerminated(var S:String);
function Str_Hash(S:PChar):Cardinal; overload;
function Str_Hash(const S:String):Cardinal; overload;
procedure Str_ConcatMem(var S:String;const Mem;Size:integer);
function Str_Reverse(const S:String):String;
function Str_Replace(const S,OldPattern,NewPattern:String):String;
function Str_ReplaceAll(const S,OldPattern,NewPattern:String):String;
function Str_CopyLeft(const S:String;Count:integer):String;inline;
function Str_CopyRight(const S:string;Count:integer):String;inline;
function Str_StripHtmlTags(const S:String):String;

//Conversion
function IntToStr(Value: Integer; Digits: Integer;Filler:char='0'): string; overload;
function IntToStr(Value: Int64; Digits: Integer;Filler:char='0'): string; overload;
function BoolToStr(Value:boolean):String;
function MemToHex(const Buf;Size:integer):String;
function StrToHex(const S:String):String;
function MemToStr(const Mem;Size:integer):String;

type TSimpleMsgType=(smtNotice,smtWarning,smtError);
procedure SimpleMessageBox(MsgType:TSimpleMsgType;const MsgText:String);

//Uses IsDebuggerPresent api, and returns false if it is not present
function Debugged:boolean;

type THotkeyModifiers=(hmShift,hmCtrl,hmAlt);
     THotkeyModifierSet=set of THotkeyModifiers;
function IsKeyPressed(Key:Word):boolean;overload;
function IsKeyPressed(Key:Word;const Modifiers:THotkeyModifierSet):boolean;overload;

type TLoadFromStream=procedure(Stream:TStream)of object;
procedure LoadFromResource(LoadFromStream:TLoadFromStream;Module:hModule;const ResName,ResType:String);

implementation
uses sysutils,math,strutils;

function GetLastErrorString:String;
begin
 result:=GetErrorString(GetLastError);
end;

function GetErrorString(Error:DWord):String;
begin
 result:='';
 if error=0 then exit;
 setlength(result,255);
 setlength(result,FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS,
    nil,
    Error,
    0,
    @result[1],
    254,
    nil ));
 if result='' then result:='Unknown Error';
 result:=result+'('+inttostr(Error)+')';
end;

function FileToString(const Filename:String):String;
var stm:TFileStream;
begin
  stm:=TFilestream.create(Filename,fmOpenRead or fmShareDenyWrite);
  try
    setlength(result,min(high(integer),stm.Size));
    stm.Read(result[1],length(result))
  finally
    stm.free;
  end;
end;

procedure StringToFile(const S:String;const Filename:String);
var stm:TFileStream;
begin
  stm:=TFilestream.create(Filename,fmCreate or fmShareExclusive);
  try
    stm.Write(S[1],length(S))
  finally
    stm.free;
  end;
end;

function Str_RemoveChars(const S:String;C:TCharSet):String;
var i:integer;
begin
  result:='';
  for I := 1 to length(S)do
   if not (s[i] in c) then result:=result+S[i];
end;

function Str_CountChars(const S:String;C:TCharSet):integer;
var i:integer;
begin
  result:=0;
  for i:=1 to length(s)do
    if s[i]in C then inc(result);
end;

function EnablePrivilege(const Priv:String):boolean;
var
  rl: Cardinal;
  hToken: Cardinal;
  tkp: TOKEN_PRIVILEGES;
  p:^token_privileges;
begin
   p:=nil;
   hToken:=0;
   try
     result:=true;
     if Win32Platform <> VER_PLATFORM_WIN32_NT then exit;
     result:=false;
     if not OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)
       then exit;
     if not LookupPrivilegeValue(nil, Pchar(Priv), tkp.Privileges[0].Luid)
       then exit;
     tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
     tkp.PrivilegeCount := 1;
     AdjustTokenPrivileges(hToken, False, tkp, 0, p^, rl);
     if GetLastError <> ERROR_SUCCESS then exit;
     result:=true;
   finally
     if hToken<>0 then CloseHandle(hToken);
   end;
end;

function GetModuleFilename(hModule:THandle):String;
begin
  setlength(result,Max_Path+1);
  windows.GetModuleFilename(hModule,PChar(result),length(result)+1);
  setlength(result,strlen(PChar(result)));
end;

function GetModuleFilename:String;
begin
  result:=GetModuleFilename(hInstance);
end;

function GetWindowsVersionStr:String;
var
  VerInfo: TOSVersionInfo;
begin
  result:='';

  ZeroMemory(@VerInfo, SizeOf(TOSVersionInfo));
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);

  if GetVersionEx(VerInfo) then begin
    if (VerInfo.dwPlatformId = VER_PLATFORM_WIN32_NT)then result:=result+'NT ';
    result:=result+inttostr(VerInfo.dwMajorVersion)+'.';
    result:=result+inttostr(VerInfo.dwMinorVersion)+'.';
    result:=result+inttostr(VerInfo.dwBuildNumber)+' ';
    result:=result+VerInfo.szCSDVersion;
  end;
end;

function GetWindowsVersionStrShort:String;
var
  VerInfo: TOSVersionInfo;
begin
  result:='';

  ZeroMemory(@VerInfo, SizeOf(TOSVersionInfo));
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);

  if GetVersionEx(VerInfo) then begin
    if (VerInfo.dwPlatformId = VER_PLATFORM_WIN32_NT)then result:=result+'NT';
    result:=result+inttostr(VerInfo.dwMajorVersion)+'.';
    result:=result+inttostr(VerInfo.dwMinorVersion);
  end;
end;

var GetModuleHandleEx:function (Flags:Cardinal;ModuleName:PChar;out Handle:hModule):BOOL;stdcall;
const GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS       =4;
      GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT =2;
function ModuleFromAddr(Addr:pointer):hModule;
var Handle:hModule;
begin
  result:=0;
  if not assigned(GetModuleHandleEx) then GetModuleHandleEx:=GetProcAddress(GetModuleHandle('Kernel32.dll'),'GetModuleHandleEx');
  if not assigned(GetModuleHandleEx) then exit;//Only available on XP or later
  if not GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS or GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,Addr,Handle)then exit;
  result:=Handle;
end;

function GetFileSize(const Filename:String):Int64;
var sr:TSearchRec;
begin
  if FindFirst(fileName, faAnyFile, sr )=0 then
     result:=Int64(sr.FindData.nFileSizeHigh) shl 32+Int64(sr.FindData.nFileSizeLow)
  else
     result := -1;
  FindClose(sr) ;
end;

procedure Str_ClearTo(var S:String;const SubStr:String);
var p:integer;
begin
  p:=pos(SubStr,s);
  if p=0 then raise exception.create('SubStr not found');
  delete(s,1,p+length(SubStr)-1);
end;

function Str_CopyTo(const S,SubStr:String):String;
var p:integer;
begin
  p:=pos(SubStr,s);
  if p=0 then raise exception.create('SubStr not found');
  result:=copy(s,1,p-1);
end;

function IntToStr(Value: Integer; Digits: Integer;Filler:char): string; overload;
begin
  result:=IntToStr(Value);
  while length(result)<digits do
   result:='0'+result;
end;

function IntToStr(Value: Int64; Digits: Integer;Filler:char): string; overload;
begin
  result:=IntToStr(Value);
  while length(result)<digits do
   result:='0'+result;
end;

function BoolToStr(Value:boolean):String;
begin
  if value
    then result:='1'
    else result:='0';
end;

function MemToHex(const Buf;Size:integer):String;
var
  i: Integer;
begin
  result:='';
  for i:=0 to size-1 do
   result:=result+inttohex(PByteArray(@Buf)[i],2);
end;

function StrToHex(const S:String):String;
begin
  result:=MemToHex(S[1],length(S));
end;

procedure Str_FitZeroTerminated(var S:String);
begin
  setlength(S,StrLen(PChar(S)));
end;

function Str_Hash(S:PChar):Cardinal;overload;
var c:char;
// Berkeley DataBase
// see http://www.fantasy-coders.de/projects/gh/html/x435.html
begin
  result:=0;
  c:=S^;
  while c<>#0 do
   begin
    c:=S^;
    result := ord(c) + (result shl 6) + (result shl 16) - result;//hash*$1003f+c
    inc(s);
   end;
end;

function Str_Hash(const S:String):Cardinal;overload;
var c:char;
    pc:PChar;
    i:integer;
begin
  result:=0;
  pc:=PChar(S);
  for i:=1 to length(S)do
   begin
    c:=pc^;
    result := ord(c) + (result shl 6) + (result shl 16) - result;//hash*$1003f+c
    inc(pc);
   end;
end;

function MemToStr(const Mem;Size:integer):String;
begin
  setlength(result,size);
  move(mem,result[1],Size);
end;

procedure Str_ConcatMem(var S:String;const Mem;Size:integer);
var OrgLen:integer;
begin
  OrgLen:=length(S);
  setlength(S,length(S)+Size);
  move(Mem,S[OrgLen+1],Size);
end;

function Str_Reverse(const S:String):String;
var i,L:integer;
begin
  setlength(result,length(s));
  L:=length(S)+1;
  for i:=1 to length(s)do
    result[i]:=S[L-i];
end;

function Str_Replace(const S,OldPattern,NewPattern:String):String;
var i:integer;
begin
  i:=Pos(OldPattern,S);
  if i=0//Not found
    then result:=S
    else result:=copy(s,1,i-1)+NewPattern+copy(s,i+length(oldpattern));
end;

function Str_ReplaceAll(const S,OldPattern,NewPattern:String):String;
var i1,i2:integer;
begin
  i1:=1;
  i2:=Pos(OldPattern,S);
  if i2=0
    then begin
      result:=S;
      exit;
    end;
  result:='';
  repeat
    result:=result+copy(s,i1,i2-i1);
    result:=result+NewPattern;
    i1:=i2+length(oldPattern);
    i2:=posex(OldPattern,S,i1);
  until i2=0;
end;

function Str_CopyLeft(const S:String;Count:integer):String;inline;
begin
  result:=copy(s,1,count);
end;

function Str_CopyRight(const S:string;Count:integer):String;inline;
begin
  result:=copy(s,length(S)+1-Count,Count);
end;

function Str_StripHtmlTags(const S:String):String;
var i:integer;
    deleting:boolean;
begin
  deleting:=false;
  result:='';
  for i:=1 to length(s)do
   begin
    if (s[i]='<')or(s[i]='<') then deleting:=true;
    if not deleting then result:=result+s[i];
    if s[i]='>' then deleting:=false;
   end;
end;

procedure SimpleMessageBox(MsgType:TSimpleMsgType;const MsgText:String);
var Caption:String;
    Icon:Cardinal;
begin
  case MsgType of
    smtNotice:
      begin
        Caption:='Notice';
        Icon:=MB_ICONINFORMATION;
      end;
    smtWarning:
      begin
        Caption:='Warning';
        Icon:=MB_ICONWARNING;
      end;
    smtError:
      begin
        Caption:='Error';
        Icon:=MB_ICONERROR;
      end;
    else raise exception.create('Unkown SimpleMessageBox type');
  end;
  MessageBox(0,
             PChar(MsgText),
             PChar(Caption),
             Icon or MB_OK);
end;

function Debugged:boolean;
var IsDebuggerPresent:function():BOOL;stdcall;
begin
  IsDebuggerPresent:=GetProcAddress(GetModuleHandle('kernel32.dll'),'IsDebuggerPresent');
  result:=assigned(IsDebuggerPresent)and IsDebuggerPresent();
  result:=result or (DebugHook<>0);
end;

function IsKeyPressed(Key:Word):boolean;
begin
  result:=GetKeyState(Key)and 128<>0;
end;

function IsKeyPressed(Key:Word;const Modifiers:THotkeyModifierSet):boolean;
begin
  result:=
     IsKeyPressed(Key)and
     (IsKeyPressed(vk_Control)=(hmCtrl in Modifiers))and
     (IsKeyPressed(vk_Shift)=(hmShift in Modifiers))and
     (IsKeyPressed(vk_Menu)=(hmAlt in Modifiers));
end;

procedure LoadFromResource(LoadFromStream:TLoadFromStream;Module:hModule;const ResName,ResType:String);
var stm:TResourceStream;
begin
  stm:=TResourceStream.create(Module,ResName,PChar(ResType));
  try
    LoadFromStream(Stm);
  finally
    stm.free;
  end;
end;

end.
