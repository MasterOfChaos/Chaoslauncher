unit AntiICC;

interface

var AntiIccEnabled:boolean;

implementation
uses Main,sysutils,forms;
var AntihackForm:TForm;

procedure AntiICC_Init;
begin
  if not AntiIccEnabled then exit;
  if AntihackForm<>nil then raise exception.create('Internal Plugin Error AHF');
  AntihackForm:=TForm.create(nil);
  AntihackForm.Caption:='{C633A3A8-32DF-4C3A-AE04-48031E43F463}';
  AntihackForm.HandleNeeded;
end;

procedure AntiICC_Finish;
begin
  FreeAndNil(AntihackForm);
end;


initialization
  AddInitHandler(AntiICC_Init,[pmLauncher]);
  AddFinishHandler(AntiICC_Finish,[pmLauncher]);
end.
