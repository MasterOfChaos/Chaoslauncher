unit Inject;

interface
uses Plugins;

Type TInjectionMethod=(imOverwrite);
procedure SaveInjectInfo(const Version:TGameVersion);

implementation
uses windows,classes,sysutils,util,Inject_Overwrite,streaming;
const InjectionHelper='ChaosInjector.dll';

procedure SaveInjectInfo(const Version:TGameVersion);
var stm:TFileStream;
begin
  stm:=nil;
  try
    if not fileexists(LauncherInfo.Path+InjectionHelper)
      then raise exception.Create('Injectionhelper ('+InjectionHelper+') not found');
    if GetFileVersion(paramstr(0))<>GetFileVersion(LauncherInfo.Path+Injectionhelper)
      then raise exception.Create('Incompatible Injectionhelper version');
    Stm:=TFileStream.Create(changefileext(LauncherInfo.Path+injectionhelper,'.chio'),fmCreate or fmShareExclusive);
  finally
    stm.free;
  end;
end;


end.
