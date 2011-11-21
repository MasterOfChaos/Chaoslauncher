unit versions;

interface

type TVersion=packed array[0..3]of Word;

function GetFileVersionValue(const Filename: String;const Key:String):String;
function GetFileVersionRec(const Filename: String;out Version:TVersion):boolean;
function VersionToStr(const Version:TVersion):String;
function CompareVersions(const Version1,Version2:TVersion):integer;
function ParseVersion(VersionStr:String):TVersion;
function GetLocalizedVersionValue(const Filename: String;const Key:String):String;
function GetModuleVersion:TVersion;
function GetProgramVersion:TVersion;

implementation
uses windows,sysutils,util;

function ParseVersion(VersionStr:String):TVersion;
  function PopInteger(var S:String):integer;
  begin
    result:=0;
    while (length(S)>0) and (S[1]in['0'..'9']) do
     begin
      result:=result*10+ord(S[1])-ord('0');
      delete(s,1,1);
     end;
    while (length(S)>0) and not(S[1]in['0'..'9']) do
      delete(s,1,1);
  end;
begin
  result[0]:=PopInteger(VersionStr);
  result[1]:=PopInteger(VersionStr);
  result[2]:=PopInteger(VersionStr);
  result[3]:=PopInteger(VersionStr);
end;

{ use GetLocalizedVersionValue(Filename: String,'FileVersion') or
      GetLocalizedVersionValue(Filename: String,'ProductVersion')

var   beginning1:String='F'#0'i'#0'l'#0'e'#0;
      beginning2:String='V'#0'e'#0'r'#0's'#0'i'#0'o'#0'n';  //Avoid self triggering

function GetFileVersionStr(const Filename:String):String;
var VersionPosition:integer;
begin
 result:=FileToString(Filename);
 VersionPosition:=pos(beginning1+beginning2+#0#0#0#0#0,result);
 if VersionPosition>0
   then begin
     delete(result,1,VersionPosition+length(beginning1+beginning2)+3);
     result:=copy(result,1,pos(#0#0,result)-1);
     result:=RemoveChars(result,[#0]);
     result:=stringreplace(result,'Version ','',[]);
   end
   else result:='';
end;}

type TLangAndCodepage=packed record
  Language:Word;
  Codepage:Word;
end;

function GetLocalizedVersionValue(const Filename: String;const Key:String):String;
var
    s:String;
    Lac:TLangAndCodepage;
begin
  result:='';
  s:=GetFileVersionValue(Filename,'\VarFileInfo\Translation');
  if length(s)<sizeof(TLangAndCodepage)then exit;
  LaC:=TLangAndCodepage((@S[1])^);
  result:=GetFileVersionValue(Filename,'\StringFileInfo\'+inttohex(Lac.Language,4)+inttohex(Lac.Codepage,4)+'\'+Key);
end;


function GetFileVersionValue(const Filename: String;const Key:String):String;
var
  VersionInfoSize    :Cardinal;
  TempDW             :Cardinal;
  VersionInfo        :Pointer;
  VersionValue       :Pointer;
  VersionValueSize   :Cardinal;

begin
  result:='';
  VersionInfoSize := GetFileVersionInfoSize(PChar(Filename),TempDW);
  if VersionInfoSize=0 then exit;//No Info available

  GetMem(VersionInfo, VersionInfoSize);
  FillChar(VersionInfo^,VersionInfoSize,0);
  try
    if not GetFileVersionInfo(PChar(Filename), 0,VersionInfoSize, VersionInfo)then exit;
    if not VerQueryValue(VersionInfo, PChar(Key), VersionValue, VersionValueSize) then exit;
    if VersionValueSize=0 then exit;
    setlength(result,VersionValueSize);
    UniqueString(result);
    move(VersionValue^,result[1],length(result));
  finally
    FreeMem(VersionInfo,VersionInfoSize);
  end;
end;

function GetFileVersionRec(const Filename: String;out Version:TVersion):boolean;
var  FixedFileInfo: PVSFixedFileInfo;
  s: String;
begin
  Version[0]:=0;
  Version[1]:=0;
  Version[2]:=0;
  Version[3]:=0;
  result:=false;
  s:=GetFileVersionValue(Filename,'\');
  if length(s)<sizeof(TVSFixedFileInfo) then exit;
  FixedFileInfo:=@S[1];
  Version[0]:=FixedFileInfo.dwFileVersionMS shr 16;
  Version[1]:=FixedFileInfo.dwFileVersionMS and $FFFF;
  Version[2]:=FixedFileInfo.dwFileVersionLS shr 16;
  Version[3]:=FixedFileInfo.dwFileVersionLS and $FFFF;
end;

function VersionToStr(const Version:TVersion):String;
begin
  result:=inttostr(Version[0])+'.'+inttostr(Version[1]);
  if (Version[2]<>0)or (Version[3]<>0)
    then result:=result+'.'+inttostr(Version[2]);
  if Version[3]<>0
    then result:=result+'.'+inttostr(Version[3]);
  if result='0.0' then result:='';
end;

function CompareVersions(const Version1,Version2:TVersion):integer;
var
  i: Integer;
begin
  result:=0;
  for i:=3 downto 0 do
   begin
     if Version1[i]>Version2[i] then result:=1;
     if Version1[i]<Version2[i] then result:=-1;
    end;
end;

var FModuleVersion:TVersion;
    FModuleVersionChecked:boolean=false;
function GetModuleVersion:TVersion;
begin
  if not FModuleVersionChecked
    then GetFileVersionRec(GetModuleFilename,FModuleVersion);
  FModuleVersionChecked:=true;
  result:=FModuleVersion;
end;

var FProgramVersion:TVersion;
    FProgramVersionChecked:boolean=false;
function GetProgramVersion:TVersion;
begin
  if not FProgramVersionChecked
    then GetFileVersionRec(paramstr(0),FProgramVersion);
  FProgramVersionChecked:=true;
  result:=FProgramVersion;
end;



end.
