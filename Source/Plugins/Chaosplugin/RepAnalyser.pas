unit RepAnalyser;

interface
uses windows,logger,util,sysutils;
type TShortString32=String[31];
Type TReplayInfo=packed record
  InfoVersion:integer;
  GameName:TShortString32;
  MapName:TShortString32;
  PlayerCount:integer;
  PlayerName:array[0..7]of TShortString32;
	PlayerRace:array[0..7]of byte;
	PlayerType:array[0..7]of byte;
end;
Type PReplayInfo=^TReplayInfo;
var GetReplayInfo:function(Filename:PChar;var Info:TReplayInfo):BOOL;cdecl;

implementation
var LibHandle:HModule;
    Filename:String;
initialization
 LibHandle:=0;
 setlength(Filename,Max_Path+1);
 Filename:=GetModuleFilename;
 Filename:=Extractfilepath(Filename)+'RepAnalyser.dll';
 if FileExists(Filename)
   then LibHandle:=LoadLibrary(PChar(Filename));
 if LibHandle<>0
  then begin
    Log('Load ReplayAnalyser.dll '+'successful');
    GetReplayInfo:=GetProcAddress(LibHandle,'GetReplayInfo');
    if not assigned(GetReplayInfo) then Log('Could not find procaddress for GetReplayInfo');
  end
  else begin
    Log('Load ReplayAnalyser.dll '+GetLastErrorString);
    GetReplayInfo:=nil;
  end;
finalization
 freelibrary(LibHandle);
end.
