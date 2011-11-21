unit sound;

interface

procedure PlaySound(const Name:string;Delay:integer;Res:boolean=false);
procedure InitSound;
procedure FinishSound;

implementation
uses windows,classes,sysutils,forms,dxsounds,logger,main,util;
var waves:TDXWavelist;
    dxsound:TDXSound;
    lastplayed:TStringList;
    form:TCustomForm;
procedure PlaySound(const Name:string;Delay:integer;Res:boolean=false);
var item:TWaveCollectionItem;
    i:integer;
    s:string;
    time:Cardinal;
    Filename1,Filename2:String;
begin
 InitSound;
 s:=lastplayed.Values[name];
 if s='' then s:='0';
 time:=gettickcount-cardinal(strtoint64(s));
 if time<Delay*1000then exit;
 lastplayed.Values[name]:=inttostr(gettickcount);

 Log('Sound("'+Name+'",'+inttostr(Delay)+')');
 i:=waves.Items.indexOf(Name);
 if i>=0
  then item:=waves.items[i]
  else begin
    item:=waves.Items.add as TWaveCollectionItem;
    if res
      then LoadFromResource(item.Wave.LoadFromStream,hInstance,Name,'Sound')
      else begin
        Filename1:=extractfilepath(GetModuleFilename)+Name+'.wav';
        Filename2:=Name+'.wav';
        if fileexists(Filename1)
          then item.Wave.LoadFromFile(Filename1)
          else if fileexists(Filename2)
            then item.Wave.LoadFromFile(Filename2)
            else Log('Sound does not exist');
      end;
    item.Restore;
  end;
  item.Play(false);
end;

procedure InitSound;
begin
 if (dxsound<>nil)or(waves<>nil)then exit;
 form:=TForm.create(nil);
 dxsound:=TDxSound.create(form);
 dxsound.Options:=[soGlobalFocus];
 dxsound.Initialize;
 waves:=TDXWavelist.create(nil);
 waves.DXSound:=dxsound;
 lastplayed:=TStringlist.create;
end;

procedure FinishSound;
begin
 waves.free;
 waves:=nil;
 dxsound.free;
 dxsound:=nil;
 lastplayed.free;
 lastplayed:=nil;
 form.free;
 form:=nil;
end;

initialization
 waves:=nil;
 dxsound:=nil;
 AddFinishHandler(FinishSound,[pmLauncher]);
finalization
 FinishSound;
end.
