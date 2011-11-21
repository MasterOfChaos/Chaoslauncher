unit CHL_Helper;

interface
uses versions;

function IsMainThread:boolean;

type TObjHandle=pointer;
     TCreateProc        =procedure(ObjType:TClass);
     TSimpleEvent       =procedure of object;
     TSetStrEvent       =procedure(const Value:String;var OK:boolean)of object;
     TGetStrEvent       =procedure(out Value:String;var OK:boolean)of object;
     TSetIntEvent       =procedure(const Value:integer;var OK:boolean)of object;
     TGetIntEvent       =procedure(out Value:integer;var OK:boolean)of object;
     TSetBoolEvent      =procedure(const Value:boolean;var OK:boolean)of object;
     TGetBoolEvent      =procedure(out Value:boolean;var OK:boolean)of object;
     TSetEventEvent     =procedure(constProc:pointer;const UserData:pointer)of object;
     TGetEventEvent     =procedure(out Proc:pointer;out UserData:pointer)of object;
     TSetVersionEvent   =procedure(const Version:TVersion;var OK:boolean)of object;
     TGetVersionEvent   =procedure(out Version:TVersion;var OK:boolean)of object;
     TOpenSysHandleEvent=procedure(out Handle:THandle;var OK:boolean)of object;

{procedure RegisterObjType(ObjType:TClass;Create:TCreateProc;AfterCreate:TSimpleEvent;CanFree:boolean;const Description:String);
procedure RegisterStrProperty(ObjType:TClass;const ID:String;Getter:TGetStrEvent;Setter:TSetStrEvent;const Description:String);
procedure RegisterIntProperty(ObjType:TClass;const ID:String;Getter:TGetIntEvent;Setter:TSetIntEvent;const Description:String);
procedure RegisterBoolProperty(ObjType:TClass;const ID:String;Getter:TGetBoolEvent;Setter:TSetBoolEvent;const Description:String);
procedure RegisterEventProperty(ObjType:TClass;const ID:String;Getter:TGetEventEvent;Setter:TSetEventEvent;const Description:String);
//procedure RegisterBoolProperty(ObjType:TClass;const ID:String;


//  function AddCallback(Func:pointer;UserData:pointer;Priority:integer;out CallbackHandle:TObjHandle):TChlObject;
     }
implementation
uses windows,classes,sysutils,inifiles,Contnrs;
var   FMainThreadID:Cardinal;

function IsMainThread:boolean;
begin
  result:=GetCurrentThreadID=FMainThreadID;
end;

type TMyBucketList=class(TCustomBucketList)
  private
    FBucketMask:Cardinal;
    FInsignificantLowerBits:byte;
  protected
    function BucketFor(AItem: Pointer): Integer; override;
  public
    constructor Create(ABucketCount:Cardinal;AInsignificantLowerBits:byte);
end;

var ObjTypes:TMyBucketList;

{procedure RegisterObjType(ObjType:TClass;Create:TCreateProc;AfterCreate:TSimpleEvent;CanFree:boolean);
begin

end;  }


{ TMyBucketList }

function TMyBucketList.BucketFor(AItem: Pointer): Integer;
begin
  result:=(Cardinal(AItem)shr FInsignificantLowerBits)and FBucketMask;
end;

constructor TMyBucketList.Create(ABucketCount:Cardinal;AInsignificantLowerBits:byte);
begin
  if ABucketCount=0 then raise exception.create('Bucket count must be at least 1');
  if (ABucketCount-1)xor ABucketCount<>0 then raise exception.create('Bucketcount must be a power of two');
  inherited Create;
  BucketCount:=ABucketCount;
  FBucketMask:=ABucketCount-1;
  FInsignificantLowerBits:=AInsignificantLowerBits;
end;

procedure Init;
begin
  FMainThreadID:=GetCurrentThreadID;
  //ObjTypes:=TMyBucketList.create(256,6);

end;

procedure FreeBucket(AInfo, AItem, AData: Pointer; out AContinue: Boolean);
begin
   TObject(AData).free;
end;

procedure Finish;
begin
  ObjTypes.ForEach(FreeBucket);
  ObjTypes.free;
end;

initialization
  init;
finalization

end.
