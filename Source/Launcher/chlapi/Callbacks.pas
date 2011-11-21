unit Callbacks;

interface
uses Contnrs;

type

TCallbackFunc=procedure(const ConstParam;var VarParam;UserData:Pointer;var SkipOtherHandlers:LongBool);stdcall;

TCallbackList=class;

TCallback=class
   private
     FFunc:TCallbackFunc;
     FUserData:pointer;
     FList:TCallbackList;
     FPriority: integer;
   public
     function Name:string;
     property Priority:integer read FPriority;
     procedure Call(const ConstParam;var VarParam;var SkipOtherHandlers:boolean);
     constructor Create(AList:TCallbackList;AFunc:TCallbackFunc;AUserData:Pointer;APriority:integer);
     destructor Destroy;override;
 end;

TCallbackList=class
  private
    FCallbacks:TObjectList;
    FName: String;
  public
    property Name:String read FName;
    procedure Add(ACallback:TCallback);
    procedure Remove(ACallback:TCallback);
    procedure Call(const ConstParam;var VarParam);
    constructor Create(const AName:String);
    destructor Destroy;override;
  end;

implementation
uses windows,sysutils,util,logger;
{ TCallback }

procedure TCallback.Call(const ConstParam; var VarParam;var SkipOtherHandlers:boolean);
var lbSkipOtherHandlers:LongBool;
begin
  lbSkipOtherHandlers:=SkipOtherHandlers;
  FFunc(ConstParam,VarParam,FUserData,lbSkipOtherHandlers);
  SkipOtherHandlers:=lbSkipOtherHandlers;
end;

constructor TCallback.Create(AList:TCallbackList;AFunc: TCallbackFunc; AUserData: Pointer;APriority:integer);
begin
  FFunc:=AFunc;
  FUserData:=AUserData;
  FPriority:=APriority;
  FList:=nil;
  AList.add(self);
  FList:=AList;
end;

destructor TCallback.Destroy;
begin
  if FList<>nil
    then FList.Remove(self);
  inherited;
end;

function TCallback.Name: string;
var Module:hModule;
begin
  result:='Func: '+inttohex(Cardinal(@FFunc),8)+' UD: '+inttohex(Cardinal(FUserData),1)+' Prio:'+inttostr(Priority);
  Module:=ModuleFromAddr(@FFunc);
  if Module=0 then exit;
  result:=extractfilename(GetModuleFilename(Module))+'+'+inttohex(Cardinal(@FFunc)-Module,1)+' '+result;
end;

{ TCallbackList }

procedure TCallbackList.Add(ACallback: TCallback);
var i:integer;
begin
  i:=0;
  while (i<FCallbacks.Count)and(TCallback(FCallbacks[i]).priority>ACallback.Priority) do
    inc(i);
  FCallbacks.Insert(i,ACallback);
  Log('AddCallback '+Name+' '+ACallback.Name);
end;

procedure TCallbackList.Call(const ConstParam; var VarParam);
var i:integer;
    SkipOtherHandlers:boolean;
begin
  SkipOtherHandlers:=false;
  for i:=0 to FCallbacks.count-1 do
    begin
      try
        TCallback(FCallbacks[i]).Call(ConstParam,VarParam,SkipOtherHandlers);
      except
        Log('Error in Callback '+Name+' '+TCallback(FCallbacks[i]).Name);
      end;
      if SkipOtherHandlers then break;
    end;
end;

constructor TCallbackList.Create;
begin
  FName:=AName;
  FCallbacks:=TObjectList.Create;
end;

destructor TCallbackList.Destroy;
begin
  FCallbacks.free;
  inherited;
end;

procedure TCallbackList.Remove(ACallback: TCallback);
begin
  Log('RemoveCallback '+Name+' '+ACallback.Name);
  FCallbacks.Remove(ACallback);
end;

end.
