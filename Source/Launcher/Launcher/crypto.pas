unit crypto;

interface

function BufferToHex(const Buffer;Size:integer):String;
procedure HexToBuffer(const S:String;out Buffer;Size:integer);
function md5(const S:String):String;
function sha1(const S:String):String;
function RsaSign(const S,PrivateKey:String):String;
function RsaVerify(const S,PublicKey,Signature:String):boolean;

implementation
uses sysutils,dcpmd5,dcpsha1,LbRSA,LbAsym;

function BufferToHex(const Buffer;Size:integer):String;
var i:integer;
begin
  result:='';
  for i:= 0 to Size-1 do
    result:= result + IntToHex(TByteArray(Buffer)[i],2);
end;

procedure HexToBuffer(const S:String;out Buffer;Size:integer);
var i:integer;
begin
  if length(S)<>Size*2 then raise exception.create('Buffer size missmatch');
  for i:=0 to Size-1 do
    TByteArray(Buffer)[i]:=StrToInt('$'+S[i*2]+S[i*2+1]);
end;

function md5(const S:String):String;
var Hash:TDCP_md5;
    Digest:array[0..128 div 8-1]of byte;//md5=128bit=16byte
begin
  hash:=nil;
  try
    Hash:= TDCP_md5.Create(nil);          // create the hash
    if length(Digest)*8<>Hash.GetHashSize then raise exception.create('wrong hashbuffer size');
    Hash.Init;                                   // initialize it
    Hash.UpdateStr(S);       // hash the stream contents
    Hash.Final(Digest);                          // produce the digest
    result:=BufferToHex(Digest,length(Digest));
  finally
    hash.free;
  end;
end;

function sha1(const S:String):String;
var Hash:TDCP_sha1;
    Digest:array[0..160 div 8-1]of byte;//md5=128bit=16byte
begin
  hash:=nil;
  try
    Hash:= TDCP_sha1.Create(nil);          // create the hash
    if length(Digest)*8<>Hash.GetHashSize then raise exception.create('wrong hashbuffer size');
    Hash.Init;                                   // initialize it
    Hash.UpdateStr(S);       // hash the stream contents
    Hash.Final(Digest);                          // produce the digest
    result:=BufferToHex(Digest,length(Digest));
  finally
    hash.free;
  end;
end;

function RsaSign(const S,PrivateKey:String):String;
var sig:TLbRSASSA;
    i:integer;
begin
  sig:=nil;
  i:=pos(':',PrivateKey);
  try
    sig:=TLbRSASSA.Create(nil);
    sig.HashMethod:=hmSha1;
    sig.KeySize:=aks1024;
    sig.PrivateKey.ExponentAsString:=copy(PrivateKey,1,i-1);
    sig.PrivateKey.ModulusAsString:=copy(PrivateKey,i+1);
    sig.SignString(S);
    result:=sig.Signature.IntStr;
  finally
    sig.Free;
  end;
end;

function RsaVerify(const S,PublicKey,Signature:String):boolean;
var sig:TLbRSASSA;
    i:integer;
    SigBuf:String;
begin
  sig:=nil;
  result:=false;
  i:=pos(':',PublicKey);
  if i=0 then exit;
  try
    sig:=TLbRSASSA.Create(nil);
    sig.HashMethod:=hmSha1;
    sig.KeySize:=aks1024;
    sig.PublicKey.ExponentAsString:=copy(PublicKey,1,i-1);
    sig.PublicKey.ModulusAsString:=copy(PublicKey,i+1);
    if odd(length(Signature)) then raise exception.create('Odd hexsignature string');
    setlength(SigBuf,length(Signature)div 2);
    HexToBuffer(Signature,SigBuf[1],length(SigBuf));
    sig.Signature.CopyBuffer(SigBuf[1],length(SigBuf));
    sig.Signature.Trim;
    result:=sig.VerifyString(S);
    sig.Free;
  except
    result:=false;
    sig.Free;
  end;
end;

end.
