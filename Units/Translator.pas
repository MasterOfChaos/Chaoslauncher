unit Translator;
interface
uses windows,classes,controls,menus,actnlist,sysutils,comctrls,stdctrls;

Procedure Translate(const Component:TComponent;Path:String='');overload;
function Translate(const Name: String; const Args: array of const): String; overload;
function Translate(const Name: String): String; overload;

procedure CreateTranslationTable(const Component:TComponent;const Filename:String);overload;
procedure CreateTranslationTable(const Component:TComponent;List:TStrings);overload;
function UnicodeToMultibyte(CodePage:Cardinal;const Unicode:WideString):String;

function CurrentLanguage: String;
function CurrentCharset: byte;
procedure SetLanguage(Data:TStrings);
procedure LoadLanguage(const NewLanguage:String);
procedure GetLanguages(Languages:TStrings);

implementation
uses inifiles;
Type TMyControl=class(TControl);
var LangData:TStringlist;
    CurLang:String;
    CurCharset:byte;
{function WidestringToMultibyte(const S:WideString):String;
begin
 setlength(result,WideCharToMultiByte(949,0,PWidechar(S),length(S),nil,0,nil,nil));
 WideCharToMultiByte(949,0,PWideChar(S),length(S),PChar(result),length(result),nil,nil);
end;   }

procedure SetLanguage(Data:TStrings);
begin
  LangData.Assign(Data);
  LangData.Sorted:=true;
end;

Function Translate(const Name: string; const Args: array of const): String; overload;
begin
 Result:=Format(Translate(Name),Args);
end;

var hexval:array[char]of byte;
Function Translate(const Name: string;const Default:String): String; overload;
var i,j:Integer;
begin
 i := LangData.IndexOfName(Name);
 if (I>-1)
  then Result:=LangData.Values[Name]
  else raise Exception.Create('String not translated: "'+Name+'"');
 Result:=StringReplace(result,'\r',#13,[rfReplaceAll]);
 Result:=StringReplace(result,'\n',#10,[rfReplaceAll]);
 Result:=StringReplace(result,'\\','\',[rfReplaceAll]);
 j:=1;
 i:=1;
 while i<=length(result)do
  if result[i]='#'
   then begin
    if i+2>length(result) then raise exception.Create('Invalid # escape');
    result[j]:=chr(hexval[result[i+1]]*16+hexval[result[i+2]]);
    i:=i+3;
    j:=j+1;
   end
   else begin
     inc(i);
     inc(j);
   end;       
 if Result='NoTranslate' then result:=Default; 
end;

Function Translate(const Name: string): String; overload;
begin
 result:=Translate(Name,'NoTranslate');
 if result='NoTranslate' then raise exception.create('NoTranslate for a String which must be translated');
end;

function CurrentLanguage:String;
begin
 Result:=CurLang;
end;

function CurrentCharset: byte;
begin
  Result:=CurCharset;
end;

Procedure Translate(const Component:TComponent;Path:String='');overload;
var i:integer;
begin
 //Pfad anpassen
 if Path=''
  then Path:=Component.Name
  else Path:=Path+'.'+Component.Name;
 //Eigenschaften ?ersetzen
 if (Component is TControl)and(TMyControl(Component).Caption<>'')then TMyControl(Component).Caption:=Translate(Path+'.Caption',TMyControl(Component).Caption);
 if (Component is TControl)and(TControl(Component).Hint<>'')then TMyControl(Component).Hint:=Translate(Path+'.Hint',TMyControl(Component).Hint);
 if (Component is TMenuItem)and(TMenuItem(Component).Caption<>'')and(TMenuItem(Component).Action=nil)then TMenuItem(Component).Caption:=Translate(Path+'.Caption',TMenuItem(Component).Caption);
 if (Component is TMenuItem)and(TMenuItem(Component).Hint<>'')and(TMenuItem(Component).Action=nil)then TMenuItem(Component).Hint:=Translate(Path+'.Hint',TMenuItem(Component).Hint);
 if (Component is TCustomAction)and(TCustomAction(Component).Caption<>'')then TCustomAction(Component).Caption:=Translate(Path+'.Caption',TCustomAction(Component).Caption);
 if (Component is TCustomAction)and(TCustomAction(Component).Hint<>'')then TCustomAction(Component).Hint:=Translate(Path+'.Hint',TCustomAction(Component).Hint);
 if (Component is TTabControl)and(TTabControl(Component).Tabs.text<>'')then TTabControl(Component).Tabs.text:=Translate(Path+'.Tabs',TTabControl(Component).Tabs.text);
 if (Component is TCustomComboBox)and(TCustomComboBox(Component).items.text<>'')then TCustomComboBox(Component).items.text:=Translate(Path+'.Items',TCustomComboBox(Component).items.text);
 if (Component is TCustomListBox)and(TCustomListBox(Component).items.text<>'')then TCustomListBox(Component).items.text:=Translate(Path+'.Items',TCustomListBox(Component).Items.text);
 //Unterkomponenten ?ersetzen
 for i:=0 to Component.ComponentCount-1do
  Translate(Component.Components[i],Path);
end;

procedure CreateTranslationTable(const Component:TComponent;const Filename:String);overload;
var List:TStringlist;
begin
 List:=TStringlist.create;
 try
  CreateTranslationTable(Component,List);
  List.savetofile(Filename);
 finally
  List.free;
 end;
end;

procedure LoadLanguage(const NewLanguage:String);
var stm:TResourceStream;
    sl,sl2:TStringlist;
    Codepage:Cardinal;
    i:integer;
begin
  stm:=nil;
  sl:=nil;
  sl2:=nil;
  CurLang:=NewLanguage;
  try
   //Load Translations from Ressources
   stm:=TResourceStream.CreateFromId(hInstance,1,'TRANSLATION');
   sl:=TStringlist.create;
   sl.LoadFromStream(stm);
   sl2:=TStringlist.create;
   sl2.Assign(sl);

   //Find Section [NewLanguage]
   while (sl.count>0)and(lowercase(sl[0])<>'['+lowercase(NewLanguage)+']')do
     sl.delete(0);
   sl.delete(0);
   i:=pos(#13#10'[',sl.text);
   if i>0 then sl.Text:=copy(sl.text,1,i-1);

   //Find Section [notranslate]
   while (sl2.count>0)and(lowercase(sl2[0])<>'['+'notranslate'+']')do
     sl2.delete(0);
   sl2.delete(0);
   i:=pos(#13#10'[',sl2.text);
   if i>0 then sl2.Text:=copy(sl2.text,1,i-1);

   sl.AddStrings(sl2);
   if sl.Values['Codepage']<>''
     then codepage:=strtoint(sl.Values['Codepage'])
     else codepage:=1250;

   if sl.Values['Charset']<>''
     then CurCharset:=strtoint(sl.Values['Charset'])
     else CurCharset:=1;

   sl.Text:=UnicodeToMultibyte(Codepage,Utf8Decode(sl.text));

   LangData.Assign(sl);
  finally
    stm.free;
    sl.free;
    sl2.free;
  end;
end;

procedure GetLanguages(Languages:TStrings);
var stm:TResourceStream;
    sl:TStringlist;
    i:integer;
begin
  Languages.clear;
  sl:=nil;
  stm:=nil;
  try
    sl:=TStringlist.create;
    stm:=TResourceStream.CreateFromId(hInstance,1,'TRANSLATION');
    sl.LoadFromStream(stm);
    for i:=0 to sl.Count-1 do
      if (length(sl[i])>2)and(sl[i][1]='[')and(sl[i][length(sl[i])]=']')and(lowercase(sl[i])<>'[notranslate]')
        then Languages.add(copy(sl[i],2,length(sl[i])-2));
  finally
    stm.free;
    sl.free;
  end;
end;

function UnicodeToMultibyte(CodePage:Cardinal;const Unicode:WideString):String;
begin
  setlength(result,WideCharToMultiByte(CodePage,0,PWideChar(Unicode),length(Unicode),nil,0,nil,nil));
  setlength(result,WideCharToMultiByte(CodePage,0,PWideChar(Unicode),length(Unicode),PChar(result),length(result),nil,nil)-1);
end;

procedure CreateTranslationTable(const Component:TComponent;List:TStrings);overload;
   function Escape(const S:String):String;
   begin
    result:=S;
    result:=stringreplace(result,'\','\\',[rfReplaceAll]);
    result:=stringreplace(result,#13,'\r',[rfReplaceAll]);
    result:=stringreplace(result,#10,'\n',[rfReplaceAll]);
   end;
 
   procedure AddComponent(const Component:TComponent;Path:String);
   var i:integer;
   begin
    //Pfad anpassen
    if Path=''
     then Path:=Component.Name
     else Path:=Path+'.'+Component.Name;
    //Eigenschaften speichern
    if (Component is TControl)and(TMyControl(Component).Caption<>'')then List.add(Path+'.Caption='+Escape(TMyControl(Component).Caption));
    if (Component is TControl)and(TControl(Component).Hint<>'')then List.add(Path+'.Hint='+Escape(TMyControl(Component).Hint));
    if (Component is TMenuItem)and(TMenuItem(Component).Caption<>'')and(TMenuItem(Component).Action=nil)then List.add(Path+'.Caption='+Escape(TMenuItem(Component).Caption));
    if (Component is TMenuItem)and(TMenuItem(Component).Hint<>'')and(TMenuItem(Component).Action=nil)then List.add(Path+'.Hint='+Escape(TMenuItem(Component).Hint));
    if (Component is TCustomAction)and(TCustomAction(Component).Caption<>'')then List.add(Path+'.Caption='+Escape(TCustomAction(Component).Caption));
    if (Component is TCustomAction)and(TCustomAction(Component).Hint<>'')then List.add(Path+'.Hint='+Escape(TCustomAction(Component).Hint));
    if (Component is TTabControl)and(TTabControl(Component).Tabs.text<>'')then List.add(Path+'.Tabs='+Escape(TTabControl(Component).Tabs.text));
    if (Component is TCustomComboBox)and(TCustomComboBox(Component).Items.text<>'')then List.add(Path+'.Items='+Escape(TCustomComboBox(Component).Items.text));
    if (Component is TCustomListBox)and(TCustomListBox(Component).Items.text<>'')then List.add(Path+'.Items='+Escape(TCustomListBox(Component).Items.text));
    //Unterkomponenten speichern
    for i:=0 to Component.ComponentCount-1do
     AddComponent(Component.Components[i],Path);
   end;
begin
  List.clear;
  AddComponent(Component,'');
end;
var i:Char;
initialization
 LangData:=TStringList.Create;
 LangData.Sorted:=true;
 CurCharset:=1;
 CurLang:='';
 for i := #0 to #255 do
  hexval[i]:=0;
 for i := '0'to '9'do
  hexval[i]:=ord(i)-ord('0');
 for i := 'A'to 'Z'do
  hexval[i]:=ord(i)-ord('A')+10;
 for i := 'a'to 'z'do
  hexval[i]:=ord(i)-ord('a')+10;
finalization
 LangData.Free;
end.
