unit Tools;

interface
uses windows,shellapi,sysutils,classes,util,math;
Type TTool=class
  public
    Name:String;
    Path:String;
    Params:String;
    procedure Run;
end;

var ToolData:array of TTool;

procedure LoadTools;
procedure SaveTools;

implementation
uses config,inifiles;

procedure LoadTools;
var sl:TStringlist;
    i,count:integer;
begin
  sl:=nil;
  try
    sl:=TStringlist.create;
    ini.readsection('ToolNames',sl);
    Count:=sl.count;
    setlength(ToolData,Count);
    for I := 0 to Count-1 do
     begin
       ToolData[i]:=TTool.create;
       ToolData[i].Name:=ini.ReadString('ToolNames',sl[i],'');
       ToolData[i].Path:=ini.ReadString('ToolPaths',sl[i],'');
       ToolData[i].Params:=ini.ReadString('ToolParams',sl[i],'');
     end;
  finally
    sl.free;
  end;
end;

procedure SaveTools;
var i:integer;
begin
  ini.EraseSection('ToolNames');
  ini.EraseSection('ToolParams');
  ini.EraseSection('ToolPath');
  for I := 0 to length(ToolData)-1 do
   begin
     ini.WriteString('ToolNames',inttostr(i),ToolData[i].Name);
     ini.WriteString('ToolParams',inttostr(i),ToolData[i].Params);
     ini.WriteString('ToolPaths',inttostr(i),ToolData[i].Path);
   end;
end;

{ TTool }

procedure TTool.Run;
begin
  shellexecute(0,'open',PChar(Path),PChar(Params),PChar(extractfilepath(path)),SW_SHOW);
end;

procedure FreeTools;
var i:integer;
begin
  for I := 0 to Length(ToolData)-1 do
    ToolData[i].free;
  setlength(ToolData,0);
end;

initialization
finalization
  FreeTools;
end.
