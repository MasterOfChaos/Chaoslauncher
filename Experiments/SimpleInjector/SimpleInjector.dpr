library SimpleInjector;

uses
  SysUtils,
  Classes,
  windows;

{$R *.res}

var sl:TStringlist;
    i:Integer;
    hLib:THandle;
begin
  sl:=nil;
  try
    sl:=TStringlist.create;
    sl.LoadFromFile(paramstr(0)+'.injlist');
    for i:=0 to sl.count-1do
      try
        if sl[i]='' then continue;
        if sl[i]='#' then continue;
        
        hLib:=LoadLibrary(PChar(sl[i]));
        if hLib=0
          then MessageBox(0,PChar('LoadLibary failed '+inttostr(GetLastError)),'Error',MB_ICONERROR or MB_OK);
      except
        on e:exception do
          MessageBox(0,PChar('Exception '+e.ClassName+' : '+e.Message),'Exception',MB_ICONERROR or MB_OK);
      end;
  finally
    sl.free;
  end;
end.
