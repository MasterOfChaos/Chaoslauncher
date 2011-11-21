unit Inject_Overwrite;

interface
uses windows,util,logger,classes,sysutils,streaming;

procedure InjectOverwrite(hProcess:THandle;const ScCode:String;const InjectHelper:String;const UserData:String);

implementation

function GetEntryPoint(const Code:String):Cardinal;
var PeBegin:Cardinal;
    PeOptBegin:Cardinal;
    RelativeEntrypoint:Cardinal;
    ImageBase:Cardinal;
begin;
  //Find start of PE-Header
  if length(Code)<$3C+4 then raise exception.create('Exe too small');
  PeBegin:=Cardinal((@Code[$3C+1])^);
  //I don't care about Mini-Exes
  if PeBegin+100>Cardinal(length(Code)) then raise exception.create('Invalid PE offset');
  //Check PE signature
  if Cardinal((@Code[peBegin+1])^)<>$4550 then raise exception.create('Invalid PE Signature');
  //Find optional PE-Header
  PeOptBegin:=PeBegin+20+4;
  //Get type of optional PE-Header
  case Word((@Code[PeOptBegin+1])^) of
   $10B:;//PE32 => OK
   $20B:raise exception.create('PE32Plus not supported');
   else raise exception.create('Unknown Magicbytes for optional PE-Header');
  end;
  //Get Entrypoint relative to Imagebase
  RelativeEntrypoint:=Cardinal((@Code[PeOptBegin+16+1])^);
  //Get Image-Baseaddress
  ImageBase:=Cardinal((@Code[PeOptBegin+28+1])^);
  //Get Absolute Entrypoint
  result:=RelativeEntrypoint+ImageBase;
end;

procedure InjectOverwrite(hProcess:THandle;const ScCode:String;const InjectHelper:String;const UserData:String);
var EntryPoint:Cardinal;
    Backup:String;
    Data:TMemoryStream;
    pLoadLib:Pointer;
    pInitOverwrite:Pointer;
    BytesIO:Cardinal;
    FilenameAddr:Cardinal;
    hLib:hModule;
    FileStm:TFileStream;
const CodeSize=20;
begin
  Assert(sizeof(Pointer)=4,'Not 64 bit safe');
  Data:=nil;
  hLib:=0;
  FileStm:=nil;
  try
    Log('InjectOverwrite');
    EntryPoint:=GetEntryPoint(ScCode);
    pLoadLib := GetProcAddress(GetModuleHandle('kernel32.dll'), 'LoadLibraryA');
    FilenameAddr:=EntryPoint+CodeSize;
    Data.WriteByte($68);//Push
    Data.WriteDWord(FilenameAddr);
    Data.WriteByte($E8);//Call
    Data.WriteDWord(Cardinal(pLoadLib)-EntryPoint-Data.Position-4);
    //Push Address of Entrypoint-4 so InitOverwrite returns to the normal entrypoint
    Data.WriteByte($68);//Push
    Data.WriteDWord(EntryPoint);
    //Call LoadLibrary
    Data.WriteByte($E9);//JMP
    hLib:=LoadLibrary(PChar(InjectHelper));
    if hLib=0 then raise exception.create('Could not load '+InjectHelper+' '+GetLastErrorString);
    pInitOverwrite:=GetProcAddress(hLib,'InitOverwrite');
    if pInitOverwrite=nil then raise exception.create('InitOverwrite not found');
    Data.WriteDWord(Cardinal(pInitOverwrite)-EntryPoint-Data.Position-4);
    assert(Data.Size=CodeSize,'Codesize missmatch');
    Data.WriteStringZT(InjectHelper);

    setlength(Backup,Data.Size);
    if not ReadProcessMemory(hProcess,Pointer(EntryPoint),@Backup[1],length(Backup),BytesIO)
      then raise exception.create('ReadProcessMemory failed'+GetLastErrorString);
    if not WriteProcessMemory(hProcess,Pointer(EntryPoint),Data.Memory,Data.Size,BytesIO)
      then raise exception.create('WriteProcessMemory failed'+GetLastErrorString);
    FileStm:=TFileStream.Create(changefileext(injecthelper,'.chio'),fmCreate or fmShareExclusive);
    FileStm.WriteDWord(EntryPoint);
    FileStm.WriteString32(Backup);
  finally
    FreeLibrary(hLib);
    data.free;
    FileStm.free;
  end;
end;

end.
