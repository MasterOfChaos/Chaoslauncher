program BwlReleaser;
uses
  sysutils,
  classes,
  math,
  dialogs,md5,zlib,crypto;

{$R *.res}

function Compress(const s:String):String;
var StrStm:TStringStream;
    CompStm:TCompressionStream;
begin
  try
    StrStm:=TStringStream.create('');
    CompStm:=TCompressionStream.Create(clMax,StrStm);
    CompStm.WriteBuffer(s[1],length(S));
    FreeAndNil(CompStm);
    result:=StrStm.DataString;
  finally
    CompStm.free;
    StrStm.free;
  end;
end;

const beginning='F'#0'i'#0'l'#0'e'#0'V'#0'e'#0'r'#0's'#0'i'#0'o'#0'n'#0#0#0;

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
function RemoveChar(const S:String;C:Char):String;
var i:integer;
begin
  result:='';
  for I := 0 to length(S)do
   if s[i]<>c then result:=result+S[i];
end;

var s:String;
    c:String;
    h:String;
    PrivateKey:String;
    Sig:String;
    path:String;
begin
 path:=extractfilepath(paramstr(1));
 S:=FileToString(paramstr(1));
 StringToFile(S,path+'binary');
 c:=Compress(s);
 StringToFile(C,path+'compressed');
 h:=MD5_Hash2String(MD5_Hash_OverBuffer(@S[1],length(S)));
 delete(S,1,pos(beginning,s)+length(beginning));
 s:=copy(S,1,pos(#0#0,s)-1);
 S:=RemoveChar(S,#0);
 S:=h+#13#10+s;
 StringToFile(S,path+'update');
 if paramcount<2 then exit;
 PrivateKey:=FileToString(paramstr(2));
 Sig:=RsaSign(S,PrivateKey);
 StringToFile(Sig,path+'signature');
end.
