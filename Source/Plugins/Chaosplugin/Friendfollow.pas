unit Friendfollow;

interface

implementation
uses windows,sysutils,main,logger;
const FriendJoinStr:array[0..3]of string=(
  'hat sich in ein Starcraft Broodwar-Spiel mit dem Namen # eingeklinkt',
  'hat sich in ein Starcraft-Spiel mit dem Namen # eingeklinkt',
  'entered a Starcraft Broodwar game called #.',
  'entered a Starcraft game called #.');
procedure FollowFriend;
var ParentHWND,HWND:integer;
    ItemCount:integer;
    i:integer;
    pos1:integer;
    s,s0,st:string;
    Len:integer;
    Dummy:Cardinal;
    found:boolean;
    FriendJoinStr1,FriendJoinStr2:String;
const  LB_GETCOUNT             = $018B;
       LB_GETTEXTLEN           = $018A;
       LB_GETTEXT              = $0189;
       WM_LBUTTONDOWN          = $0201;
       WM_LBUTTONUP            = $0202;
       WM_SETTEXT              = $000C;
begin
 Log('Follow Friend');
 //BNet Channel Dialog
 ParentHWND:=FindwindowA('SDlgDialog','');
 if ParentHWND=0 then exit;
 //Dritte Listbox=chatfenster
 HWND:=0;
 HWND:=FindWindowExA(ParentHWND,HWND,'Listbox',nil);
 HWND:=FindWindowExA(ParentHWND,HWND,'Listbox',nil);
 HWND:=FindWindowExA(ParentHWND,HWND,'Listbox',nil);
 if HWND=0 then exit;
 ItemCount:=SendMessageA(HWND,LB_GETCOUNT,0,0);
 if ItemCount=LB_ERR then exit;
 for i := 0 to ItemCount - 1 do
  begin
    len:=SendMessageA(HWND,LB_GETTEXTLEN,i,0);
    if len=LB_ERR then break;
    setlength(s0,len);
    SendMessageA(HWND,LB_GETTEXT,i,integer(pchar(s0)));
    s:=s+s0;
  end;
 s:=stringreplace(s,#9#$11,' ',[rfReplaceAll]);
 for i := 0 to length(FriendJoinStr) - 1 do
  begin
   st:=s;
   found:=false;
   repeat
    friendjoinstr1:=copy(FriendJoinStr[i],1,pos('#',FriendJoinStr[i])-1);
    friendjoinstr2:=copy(FriendJoinStr[i],pos('#',FriendJoinStr[i])+1,length(FriendJoinStr[i]));
    pos1:=pos(FriendJoinStr1,st);
    found:=found or (pos1>0);
    if pos1>0 then delete(st,1,pos1+length(FriendJoinStr1)-1);
   until pos1=0;
   if found
     then begin
       st:=copy(st,1,pos(friendjoinstr2,st)-1);
       Log('Joining Game '+st);
       //Finde Joinbutton, = 4. Button im Standard BNET-Dialog
       HWND:=FindWindowExA(ParentHWND,0,'Button',nil);
       HWND:=FindWindowExA(ParentHWND,HWND,'Button',nil);
       HWND:=FindWindowExA(ParentHWND,HWND,'Button',nil);
       HWND:=FindWindowExA(ParentHWND,HWND,'Button',nil);
       //Klicken
       SendMessageA(HWND,WM_LBUTTONDOWN,0,0);
       SendMessageTimeOutA(HWND,WM_LBUTTONUP,0,0,SMTO_NORMAL,500,Dummy);
       //Neuen Dialog finden
       ParentHWND:=0;
       repeat
        ParentHWND:=FindWindowExA(0,ParentHWND,'SDlgDialog','');
        HWND:=FindWindowExA(ParentHWND,0,'StormCombobox',nil);
       until (ParentHWND=0)or(HWND<>0);
       //Spielname
       HWND:=FindWindowExA(ParentHWND,0,'Edit','');
       //Setzen
       SendMessageA(HWND,WM_SETTEXT,0,integer(pchar(st)));
       {//Passwort
       HWND:=FindWindowExA(ParentHWND,0,'Edit','');
       //Klicken
       SendMessageA(HWND,WM_LBUTTONDOWN,0,0);
       SendMessageTimeOutA(HWND,WM_LBUTTONUP,0,0,SMTO_NORMAL,500,Dummy);}
       exit;
     end;
  end;
end;

procedure Friendfollow_Timer;
begin
 //Strg+F
 if ScActive
   and checkkey(vk_control)and not(checkkey(vk_menu))and checkkey(ord('F'))
   then FollowFriend;
end;

begin
 AddTimerHandler(Friendfollow_Timer,[pmLauncher]);
end.
