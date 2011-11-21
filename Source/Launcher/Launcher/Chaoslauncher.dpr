program Chaoslauncher;

uses
  windows,
  shellapi,
  sysutils,
  Forms,
  logger,
  Main in 'Main.pas' {ChaoslauncherForm},
  Plugins in 'Plugins.pas',
  Tools in 'Tools.pas',
  Plugins_BWL in 'Plugins_BWL.pas',
  Plugins_DLL in 'Plugins_DLL.pas',
  tvants in 'tvants.pas',
  OneInstance in 'OneInstance.pas',
  Update in 'Update.pas',
  Config in 'Config.pas',
  Plugins_AdvLoader in 'Plugins_AdvLoader.pas' {AdvLoaderConfig},
  Inject_RemoteThread in 'Inject_RemoteThread.pas',
  Plugins_ICCup in 'Plugins_ICCup.pas' {ICCupConfigForm},
  crypto in 'crypto.pas',
  Plugins_CHL in 'Plugins_CHL.pas',
  Inject_Overwrite in 'Inject_Overwrite.pas',
  Inject in 'Inject.pas',
  CHL_Helper in 'CHL_Helper.pas',
  Launcher_Game in 'Launcher_Game.pas',
  Plugins_BWL4 in 'Plugins_BWL4.pas',
  PluginsBWL5 in 'PluginsBWL5.pas';

{$R *.res}
begin
  try
    if not IsFirstInstance
      then begin
        Log('Already running');
        ActivateOldInstance;
        exit;
      end;

    if Updater.InstallUpdates
      then begin
        Log('Quit to install updates');
        exit;
      end;

    Application.Initialize;
    Application.Title := 'Chaoslauncher';
    Application.CreateForm(TChaoslauncherForm, ChaoslauncherForm);
  Application.Run;
  finally
    InstanceEnded;
  end;
  if RestartLauncher
    then begin
      Log('Restart launcher');
      shellexecute(0,'open',PChar(paramstr(0)),'',PChar(extractfilepath(paramstr(0))),sw_normal);
    end;
end.
