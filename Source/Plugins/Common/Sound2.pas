unit Sound;

interface
uses classes,sysutils,logger,dxsounds,windows,forms;
procedure PlaySound(const Name:string;Delay:integer);
procedure InitSound;
procedure FinishSound;
implementation
var waves:TDXWavelist;
    dxsound:TDXSound;
    lastplayed:TStringList;
    form:TCustomForm;
procedure PlaySound(const Name:string;Delay:integer);
var item:TWaveCollectionItem;
    i:integer;
    s:string;
    time:integer;
begin
 if (dxsound=nil)or(waves=nil)then raise exception.create('Sound not initialized');
 s:=lastplayed.Values[name];
 if s='' then s:='0';
 time:=gettickcount-strtoint(s);
 if time<Delay*1000then exit;
 lastplayed.Values[name]:=inttostr(gettickcount);

 Log('Sound("'+Name+'",'+inttostr(Delay)+')');
 i:=waves.Items.indexOf(Name);
 if i>=0
  then item:=waves.items[i]
  else begin
    item:=waves.Items.add as TWaveCollectionItem;
    item.Wave.LoadFromFile('Coach\'+Name+'.wav');
    item.Restore;
    //item.Wave.Size*1000 div item.Wave.Format.nAvgBytesPerSec+100;
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

end.
