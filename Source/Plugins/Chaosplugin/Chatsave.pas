unit Chatsave;

interface
uses windows,classes,sysutils,main,logger;
implementation
procedure SaveChat;
var ParentHWND,HWND:integer;
    sl:TStringlist;
    i,itemcount,len:integer;
    s:String;
const  LB_GETCOUNT             = $018B;
       LB_GETTEXTLEN           = $018A;
       LB_GETTEXT              = $0189;
begin
 Log('Saving Chat');
 sl:=nil;
 try
 //BNet Channel Dialog
  ParentHWND:=FindwindowA('SDlgDialog','');
  if ParentHWND=0 then exit;
  //Dritte Listbox=chatfenster
  HWND:=0;
  HWND:=FindWindowExA(ParentHWND,HWND,'Listbox',nil);
  HWND:=FindWindowExA(ParentHWND,HWND,'Listbox',nil);
  HWND:=FindWindowExA(ParentHWND,HWND,'Listbox',nil);
  if HWND=0 then exit;
  sl:=TStringlist.create;
  ItemCount:=SendMessageA(HWND,LB_GETCOUNT,0,0);
  if ItemCount=LB_ERR then exit;
  for i := 0 to ItemCount - 1 do
   begin
    len:=SendMessageA(HWND,LB_GETTEXTLEN,i,0);
    if len=LB_ERR then break;
    setlength(s,len);
    SendMessageA(HWND,LB_GETTEXT,i,integer(pchar(s)));
    sl.add(s);
   end;
  forcedirectories(Path+'\Chats');
  sl.savetofile(Path+'\Chats\'+stringreplace(DateTimeToStr(now())+'.txt',':','-',[rfReplaceAll]));
  Log('Chat saved');
 finally
  sl.free;
 end;
end;

procedure Chatsave_Timer;
begin
 //Strg+S
 if ScActive and checkkey(vk_control)and checkkey(ord('S')) then Savechat;
end;

begin
 AddTimerHandler(ChatSave_Timer,[pmLauncher]);
end.
