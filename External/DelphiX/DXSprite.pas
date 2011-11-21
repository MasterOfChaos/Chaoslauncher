unit DXSprite;

interface
                                    
{$INCLUDE DelphiXcfg.inc}

uses
  Windows, SysUtils, Classes, DXClass, DXDraws, DirectX,games,math;


type

  {  ESpriteError  }

  ESpriteError = class(Exception);

  {  TSprite  }

  TSpriteEngine = class;

  TSprite = class
  private
    FEngine: TSpriteEngine;
    FParent: TSprite;
    FList: TList;
    FDeaded: Boolean;
    FDrawList: TList;
    FCollisioned: Boolean;
    FMoved: Boolean;
    FVisible: Boolean;
    FX: Double;
    FY: Double;
    FZ: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FCenterY: double;
    FCenterX: double;
    FAngle: double;
    fsy: double;
    fsx: double;
    fSpeed: double;
    fAccY: double;
    fAccX: double;
    procedure Add(Sprite: TSprite);
    procedure Remove(Sprite: TSprite);
    procedure AddDrawList(Sprite: TSprite);
    procedure Collision2;
    procedure Draw;
    function GetClientRect: TRect;
    function GetCount: Integer;
    function GetItem(Index: Integer): TSprite;
    function GetWorldX: Double;
    function GetWorldY: Double;
    procedure SetZ(Value: Integer);
    function GetLeft: Double;
    function GetTop: Double;
    procedure SetLeft(const Value: Double);
    procedure SetTop(const Value: Double);
    function GetWorldLeft: Double;
    function GetWorldTop: Double;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); virtual;
    procedure DoDraw; virtual;
    procedure DoMove(MoveCount: Integer); virtual;
    //procedure DoInterpolate;virtual;
    function GetBoundsRect: TRect; virtual;
    function TestCollision(Sprite: TSprite): Boolean; virtual;
    procedure Die;virtual;
  public
    timepassed:real;
    constructor Create(AParent: TSprite); virtual;
    destructor Destroy; override;
    procedure Clear;
    function Collision: Integer;
    procedure Dead;
    procedure Move(MoveCount: Integer);
    function GetSpriteAt(Left, Top: Integer): TSprite;

    procedure Advance(Len:double);overload;
    procedure Advance(Len:double;Angle:double);overload;
    procedure NearAngle(DestAngle,Speed:Real);overload;
    function Dist(X,Y:double;World:boolean=false):double;overload;
    function Dist(Sprite:TSprite;World:boolean=true):double;overload;
    function Dist(X1,Y1,x2,y2:double):double;overload;

    function AngleTo(X,Y:double;World:boolean=false):double;overload;
    function AngleTo(x1,y1,x2,y2:double):double;overload;
    function AngleTo(Sprite:TSprite;World:boolean=true):Double;overload;

    property BoundsRect: TRect read GetBoundsRect;
    property ClientRect: TRect read GetClientRect;
    property Collisioned: Boolean read FCollisioned write FCollisioned;
    property Count: Integer read GetCount;
    property Engine: TSpriteEngine read FEngine;
    property Items[Index: Integer]: TSprite read GetItem; default;
    property Moved: Boolean read FMoved write FMoved;
    property Parent: TSprite read FParent;
    property Visible: Boolean read FVisible write FVisible;
    property Width: Integer read FWidth write FWidth;
    property X:double read fx write fx;
    property Y:double read fy write fy;
    property Sx:double read fsx write fsx;
    property Sy:double read fsy write fsy;
    property AccX:double read fAccX write fAccX;
    property AccY:double read fAccY write fAccY;
    property Speed:double read fSpeed write FSpeed;
    property CenterX:double read FCenterX write FCenterX;
    property CenterY:double read FCenterY write FCenterY;
    property WorldX: Double read GetWorldX;
    property WorldY: Double read GetWorldY;
    property WorldLeft: Double read GetWorldLeft;
    property WorldTop : Double read GetWorldTop;
    property Height: Integer read FHeight write FHeight;
    property Left: Double read GetLeft write SetLeft;
    property Top: Double read GetTop write SetTop;
    property Z: Integer read FZ write SetZ;
    property Angle: double read FAngle write FAngle;
  end;

  {  TImageSprite  }

  TImageSprite = class(TSprite)
  private
    FAnimCount: Integer;
    FAnimLooped: Boolean;
    FAnimPos: Double;
    FAnimSpeed: Double;
    FAnimStart: Integer;
    FImage: TPictureCollectionItem;
    FPixelCheck: Boolean;
    FTile: Boolean;
    FTransparent: Boolean;
    function GetDrawImageIndex: Integer;
    function GetDrawRect: TRect;
    procedure SetImage(Img : TPictureCollectionItem);
  protected
    procedure DoDraw; override;
    procedure DoMove(MoveCount: Integer); override;
    function GetBoundsRect: TRect; override;
    function TestCollision(Sprite: TSprite): Boolean; override;
  public
    constructor Create(AParent: TSprite); override;
    property AnimCount: Integer read FAnimCount write FAnimCount;
    property AnimLooped: Boolean read FAnimLooped write FAnimLooped;
    property AnimPos: Double read FAnimPos write FAnimPos;
    property AnimSpeed: Double read FAnimSpeed write FAnimSpeed;
    property AnimStart: Integer read FAnimStart write FAnimStart;
    property PixelCheck: Boolean read FPixelCheck write FPixelCheck;
    property Image: TPictureCollectionItem read FImage write SetImage;
    property Tile: Boolean read FTile write FTile;
  end;

  {  TImageSpriteEx  }

  TImageSpriteEx = class(TImageSprite)
  private
    FAlpha: byte;
    FDrawMode: TDrawMode;
    //FSize:real;
    {$ifdef dummy}  //For class completetion
    FHeight: integer;
    FWidth: integer;
    {$endif}
    procedure SetWidth(const Value: integer);
    procedure SetHeight(const Value: integer);
  protected
    procedure DoDraw; override;
    function GetBoundsRect: TRect; override;
    function TestCollision(Sprite: TSprite): Boolean; override;
  public
    property Width:integer read FWidth write SetWidth;
    property Height:integer read FHeight write SetHeight;
    property DrawMode:TDrawMode read FDrawMode write FDrawMode;
    property Alpha:byte read FAlpha write FAlpha;
    constructor Create(AParent: TSprite); override;
  end;
  {  TShadowSprite  }
  TShadowSprite = class(TImageSpriteEx)
  private
    FRotate: boolean;
    procedure SetRotate(const Value: boolean);
    procedure SetImage(const Value: TPictureCollectionItem);
  protected
    procedure DoDraw; override;
  public
    property Image: TPictureCollectionItem read FImage write SetImage;
    procedure SizeShadow;
    property Rotate:boolean read FRotate write SetRotate;
    constructor Create(AParent: TSprite); override;
  end;

  {  TBackgroundSprite  }

  TBackgroundSprite = class(TSprite)
  private
    FImage: TPictureCollectionItem;
    FCollisionMap: Pointer;
    FMap: Pointer;
    FMapWidth: Integer;
    FMapHeight: Integer;
    FTile: Boolean;
    function GetCollisionMapItem(Left, Top: Integer): Boolean;
    function GetChip(Left, Top: Integer): Integer;
    procedure SetChip(Left, Top: Integer; Value: Integer);
    procedure SetCollisionMapItem(Left, Top: Integer; Value: Boolean);
    procedure SetMapHeight(Value: Integer);
    procedure SetMapWidth(Value: Integer);
    procedure SetImage(Img : TPictureCollectionItem);
  protected
    procedure DoDraw; override;
    function GetBoundsRect: TRect; override;
    function TestCollision(Sprite: TSprite): Boolean; override;
  public
    constructor Create(AParent: TSprite); override;
    destructor Destroy; override;
    procedure SetMapSize(AMapWidth, AMapHeight: Integer);
    property Chips[Left, Top: Integer]: Integer read GetChip write SetChip;
    property CollisionMap[Left, Top: Integer]: Boolean read GetCollisionMapItem write SetCollisionMapItem;
    property Image: TPictureCollectionItem read FImage write SetImage;
    property MapHeight: Integer read FMapHeight write SetMapHeight;
    property MapWidth: Integer read FMapWidth write SetMapWidth;
    property Tile: Boolean read FTile write FTile;
  end;

  {  TSpriteEngine  }

  TSpriteEngine = class(TSprite)
  private
    FAllCount: Integer;
    FCollisionCount: Integer;
    FCollisionDone: Boolean;
    FCollisionRect: TRect;
    FCollisionSprite: TSprite;
    FDeadList: TList;
    FDrawCount: Integer;
    FSurface: TDirectDrawSurface;
    //FSurfaceRect: TRect;
    procedure SetSurface(Value: TDirectDrawSurface);
    function GetSurfaceRect: TRect;
  public
    constructor Create(AParent: TSprite); override;
    destructor Destroy; override;
    procedure Dead;
    procedure Draw;
    property AllCount: Integer read FAllCount;
    property DrawCount: Integer read FDrawCount;
    property Surface: TDirectDrawSurface read FSurface write SetSurface;
    property SurfaceRect: TRect read GetSurfaceRect;
  end;

  {  EDXSpriteEngineError  }

  EDXSpriteEngineError = class(Exception);

  {  TCustomDXSpriteEngine  }

  TCustomDXSpriteEngine = class(TComponent)
  private
    FDXDraw: TCustomDXDraw;
    FEngine: TSpriteEngine;
    procedure DXDrawNotifyEvent(Sender: TCustomDXDraw; NotifyType: TDXDrawNotifyType);
    procedure SetDXDraw(Value: TCustomDXDraw);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOnwer: TComponent); override;
    destructor Destroy; override;
    procedure Dead;
    procedure Draw;
    procedure Move(MoveCount: Integer);
    property DXDraw: TCustomDXDraw read FDXDraw write SetDXDraw;
    property Engine: TSpriteEngine read FEngine;
  end;

  {  TDXSpriteEngine  }

  TDXSpriteEngine = class(TCustomDXSpriteEngine)
  published
    property DXDraw;
  end;

implementation

uses DXConsts;

function Mod2(i, i2: Integer): Integer;
begin
  Result := i mod i2;
  if Result<0 then
    Result := i2+Result;
end;

function Mod2f(i: Double; i2: Integer): Double;
begin
  if i2=0 then
    Result := i
  else
  begin
    Result := i-Trunc(i/i2)*i2;
    if Result<0 then
      Result := i2+Result;
  end;
end;

{  TSprite  }

constructor TSprite.Create(AParent: TSprite);
begin
  inherited Create;
  FParent := AParent;
  if FParent<>nil then
  begin
    FParent.Add(Self);
    if FParent is TSpriteEngine then
      FEngine := TSpriteEngine(FParent)
    else
      FEngine := FParent.Engine;
    Inc(FEngine.FAllCount);
  end;

  FCollisioned := True;
  FMoved := True;
  FVisible := True;
  Width:=0;
  Height:=0;
  //CenterX:=0.5;
  //CenterY:=0.5;
end;

destructor TSprite.Destroy;
begin
  Clear;
  if FParent<>nil then
  begin
    Dec(FEngine.FAllCount);
    FParent.Remove(Self);
    FEngine.FDeadList.Remove(Self);
  end;
  FList.Free;
  FDrawList.Free;
  inherited Destroy;
end;

procedure TSprite.Add(Sprite: TSprite);
begin
  if FList=nil then
  begin
    FList := TList.Create;
    FDrawList := TList.Create;
  end;
  FList.Add(Sprite);
  AddDrawList(Sprite);
end;

procedure TSprite.Remove(Sprite: TSprite);
begin
  FList.Remove(Sprite);
  FDrawList.Remove(Sprite);
  if FList.Count=0 then
  begin
    FList.Free;
    FList := nil;
    FDrawList.Free;
    FDrawList := nil;
  end;
end;

procedure TSprite.AddDrawList(Sprite: TSprite);
var
  L, H, I, C: Integer;
begin
  L := 0;
  H := FDrawList.Count - 1;
  while L <= H do
  begin
    I := (L + H) div 2;
    C := TSprite(FDrawList[I]).Z-Sprite.Z;
    if C < 0 then L := I + 1 else
      H := I - 1;
  end;
  FDrawList.Insert(L, Sprite);
end;

procedure TSprite.Clear;
begin
  while Count>0 do
    Items[Count-1].Free;
end;

function TSprite.Collision: Integer;
var
  i: Integer;
begin
  Result := 0;
  if (FEngine<>nil) and (not FDeaded) and (Collisioned) then
  begin
    with FEngine do
    begin
      FCollisionCount := 0;
      FCollisionDone := False;
      FCollisionRect := Self.BoundsRect;
      FCollisionSprite := Self;

      for i:=0 to Count-1 do
        Items[i].Collision2;

      Result := FCollisionCount;
    end;
  end;
end;

procedure TSprite.Collision2;
var
  i: Integer;
begin
  if Collisioned then
  begin
    if (Self<>FEngine.FCollisionSprite) and OverlapRect(BoundsRect, FEngine.FCollisionRect) and
      FEngine.FCollisionSprite.TestCollision(Self) and TestCollision(FEngine.FCollisionSprite) then
    begin
      Inc(FEngine.FCollisionCount);
      FEngine.FCollisionSprite.DoCollision(Self, FEngine.FCollisionDone);
      if (not FEngine.FCollisionSprite.Collisioned) or (FEngine.FCollisionSprite.FDeaded) then
      begin
        FEngine.FCollisionDone := True;
      end;
    end;
    if FEngine.FCollisionDone then Exit;
    for i:=0 to Count-1 do
      Items[i].Collision2;
  end;
end;

procedure TSprite.Dead;
begin
  if (FEngine<>nil) and (not FDeaded) then
  begin
    FDeaded := True;
    FEngine.FDeadList.Add(Self);
  end;
end;

procedure TSprite.DoMove;
begin
 x:=x+sx*MoveCount*0.001+0.5*AccX*sqr(MoveCount*0.001);
 y:=y+sy*MoveCount*0.001+0.5*AccY*sqr(MoveCount*0.001);
 sx:=sx+AccX*MoveCount*0.001;
 sy:=sy+AccY*MoveCount*0.001;
end;

procedure TSprite.DoDraw;
begin
end;

procedure TSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
end;

function TSprite.TestCollision(Sprite: TSprite): Boolean;
begin
  Result := True;
end;

procedure TSprite.Move(MoveCount: Integer);
var
  i: Integer;
begin
  timepassed:=MoveCount*0.001;
  if FMoved then
  begin
    DoMove(MoveCount);
    for i:=0 to Count-1 do
      Items[i].Move(MoveCount);
  end;
end;

procedure TSprite.Draw;
var
  i: Integer;
  Drawed:boolean;
begin
  Drawed:=FEngine=nil;
  if FVisible then
  begin
    if FDrawList<>nil then
    begin
      for i:=0 to FDrawList.Count-1 do
       begin
        if not Drawed and (TSprite(FDrawList[i]).z>=0) then
          if OverlapRect(FEngine.SurfaceRect, BoundsRect) then
           begin
            DoDraw;
            Inc(FEngine.FDrawCount);
            Drawed:=true;
           end;
        TSprite(FDrawList[i]).Draw;
       end;
    end;
   if not Drawed  then
    if OverlapRect(FEngine.SurfaceRect, BoundsRect) then
     begin
      DoDraw;
      Inc(FEngine.FDrawCount);
     end;
  end;
end;

function TSprite.GetSpriteAt(Left, Top: Integer): TSprite;

  procedure Collision_GetSpriteAt(Left, Top: Double; Sprite: TSprite);
  var
    i: Integer;
    X2, Y2: Double;
  begin
    if Sprite.Visible and PointInRect(Point(Round(Left), Round(Top))
    , Bounds(Round(Sprite.Left), Round(Sprite.Top), Sprite.Width, Sprite.Height)) then
    begin
      if (Result=nil) or (Sprite.Z>Result.Z) then
        Result := Sprite;
    end;

    X2 := Left-Sprite.Left;
    Y2 := Top-Sprite.Top;
    for i:=0 to Sprite.Count-1 do
      Collision_GetSpriteAt(X2, Y2, Sprite.Items[i]);
  end;

var
  i: Integer;
  X2, Y2: Double;
begin
  Result := nil;

  X2 := Left-Self.Left;
  Y2 := Top-Self.Top;
  for i:=0 to Count-1 do
    Collision_GetSpriteAt(X2, Y2, Items[i]);
end;                                    

function TSprite.GetBoundsRect: TRect;
begin
  Result := Bounds(Trunc(WorldLeft), Trunc(WorldTop), Width, Height);
end;

function TSprite.GetClientRect: TRect;
begin
  Result := Bounds(0, 0, Width, Height);
end;

function TSprite.GetCount: Integer;
begin
  if FList<>nil then
    Result := FList.Count
  else
    Result := 0;
end;

function TSprite.GetItem(Index: Integer): TSprite;
begin
  if FList<>nil then
    Result := FList[Index]
  else
    raise ESpriteError.CreateFmt(SListIndexError, [Index]);
end;

function TSprite.GetWorldX: Double;
begin
  if Parent<>nil then
    Result := Parent.WorldX+x
  else
    Result := x;
end;

function TSprite.GetWorldY: Double;
begin
  if Parent<>nil then
    Result := Parent.WorldY+y
  else
    Result := y;
end;

procedure TSprite.SetZ(Value: Integer);
begin
  if FZ<>Value then
  begin
    FZ := Value;
    if Parent<>nil then
    begin
      Parent.FDrawList.Remove(Self);
      Parent.AddDrawList(Self);
    end;
  end;
end;

function TSprite.GetLeft: Double;
begin
 result:=x-CenterX*Width;
end;

function TSprite.GetTop: Double;
begin
 result:=y-CenterY*Height;
end;

procedure TSprite.SetLeft(const Value: Double);
begin
 x:=value+CenterX*Width;
end;

procedure TSprite.SetTop(const Value: Double);
begin
 y:=value+CenterY*Height;
end;

procedure TSprite.Advance(Len: double);
begin
 Advance(Len,angle);
end;

procedure TSprite.Advance(Len, Angle: double);
begin
 X:=X+GetX(Angle,Len);
 Y:=Y+GetY(Angle,Len);
end;

procedure TSprite.NearAngle(DestAngle, Speed: Real);
begin
 Angle:=Games.nearangle(Angle,DestAngle,Speed);
end;

function TSprite.GetWorldLeft: Double;
begin
 result:=WorldX-X+Left;
end;

function TSprite.GetWorldTop: Double;
begin
 result:=WorldY-Y+Top;
end;

function TSprite.AngleTo(Sprite: TSprite; World: boolean): Double;
begin
 if World then result:=AngleTo(WorldX,WorldY,Sprite.worldX,Sprite.WorldY)
          else result:=AngleTo(self.x,self.y,Sprite.X,Sprite.Y);
end;

function TSprite.AngleTo(X, Y: double; World: boolean): double;
begin
 if World then result:=AngleTo(WorldX,WorldY,x,y)
          else result:=AngleTo(self.x,self.y,x,y);
end;

function TSprite.AngleTo(x1, y1, x2, y2:double): double;
begin
 result:=Games.angleTo(x1,y1,x2,y2);
end;

function TSprite.Dist(Sprite: TSprite; World: boolean): double;
begin
 if World then result:=Dist(WorldX,WorldY,Sprite.WorldX,Sprite.WorldY)
          else result:=Dist(X,Y,Sprite.X,Sprite.Y);
end;

function TSprite.Dist(X, Y: double; World: boolean): double;
begin
 if World then result:=Dist(WorldX,WorldY,X,Y)
          else result:=Dist(self.X,self.Y,X,Y);
end;

function TSprite.Dist(X1, Y1, x2, y2: double): double;
begin
 result:=Games.dist(x1,y1,x2,y2);
end;


{procedure TSprite.DoInterpolate;
begin

end; }

procedure TSprite.Die;
begin
 dead;
end;

{  TImageSprite  }

constructor TImageSprite.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  FTransparent := True;
  CenterX:=0.5;
  CenterY:=0.5;

end;

procedure TImageSprite.SetImage(Img : TPictureCollectionItem);
begin
  FImage:=Img;
  Width:=Img.Width;
  Height:=Img.Height;
end;

function TImageSprite.GetBoundsRect: TRect;
var
  dx, dy: Integer;
begin
  dx := Trunc(WorldLeft);
  dy := Trunc(WorldTop);
  if FTile then
  begin
    dx := Mod2(dx, FEngine.SurfaceRect.Right+Width);
    dy := Mod2(dy, FEngine.SurfaceRect.Bottom+Height);

    if dx>FEngine.SurfaceRect.Right then
      dx := (dx-FEngine.SurfaceRect.Right)-Width;

    if dy>FEngine.SurfaceRect.Bottom then
      dy := (dy-FEngine.SurfaceRect.Bottom)-Height;
  end;

  Result := Bounds(dx, dy, Width, Height);
end;

procedure TImageSprite.DoMove(MoveCount: Integer);
begin
  FAnimPos := FAnimPos + FAnimSpeed*MoveCount;

  if FAnimLooped then
  begin
    if FAnimCount>0 then
      FAnimPos := Mod2f(FAnimPos, FAnimCount)
    else
      FAnimPos := 0;
  end else
  begin
    if FAnimPos>=FAnimCount then
    begin
      FAnimPos := FAnimCount-1;
      FAnimSpeed := 0;
    end;
    if FAnimPos<0 then
    begin
      FAnimPos := 0;
      FAnimSpeed := 0;
    end;
  end;
  inherited;
end;

function TImageSprite.GetDrawImageIndex: Integer;
begin
  Result := FAnimStart+Trunc(FAnimPos);
end;

function TImageSprite.GetDrawRect: TRect;
begin
  Result := BoundsRect;
  //???
  OffsetRect(Result, (Width-Image.Width) div 2, (Height-Image.Height) div 2);
end;

procedure TImageSprite.DoDraw;
var
  ImageIndex: Integer;
  r: TRect;
begin
  if not(assigned(image))then raise exception.create('No Image selected for '+self.ClassName);
  ImageIndex := GetDrawImageIndex;
  r := GetDrawRect;
  Image.Draw(FEngine.Surface, r.Left, r.Top, ImageIndex);
end;

function ImageCollisionTest(suf1, suf2: TDirectDrawSurface; const rect1, rect2: TRect;
  x1,y1,x2,y2: Integer; DoPixelCheck: Boolean): Boolean;

  function ClipRect(var DestRect: TRect; const DestRect2: TRect): Boolean;
  begin
    with DestRect do
    begin
      Left := Max(Left, DestRect2.Left);
      Right := Min(Right, DestRect2.Right);
      Top := Max(Top, DestRect2.Top);
      Bottom := Min(Bottom, DestRect2.Bottom);

      Result := (Left < Right) and (Top < Bottom);
    end;
  end;

type
  PRGB = ^TRGB;
  TRGB = packed record
    R, G, B: Byte;
  end;
var
  ddsd1, ddsd2: DDSURFACEDESC;
  r1, r2: TRect;
  tc1, tc2: DWORD;
  Left, Top, w, h: Integer;
  P1, P2: Pointer;
begin
  r1 := rect1;
  with rect2 do r2 := Bounds(x2-x1, y2-y1, Right-Left, Bottom-Top);

  Result := OverlapRect(r1, r2);

  if (suf1=nil) or (suf2=nil) then Exit;

  if DoPixelCheck and Result then
  begin
    {  Get Overlapping rectangle  }
    with r1 do r1 := Bounds(Max(x2-x1, 0), Max(y2-y1, 0), Right-Left, Bottom-Top);
    with r2 do r2 := Bounds(Max(x1-x2, 0), Max(y1-y2, 0), Right-Left, Bottom-Top);

    ClipRect(r1, rect1);
    ClipRect(r2, rect2);

    w := Min(r1.Right-r1.Left, r2.Right-r2.Left);
    h := Min(r1.Bottom-r1.Top, r2.Bottom-r2.Top);

    ClipRect(r1, bounds(r1.Left, r1.Top, w, h));
    ClipRect(r2, bounds(r2.Left, r2.Top, w, h));
                               
    {  Pixel check !!!  }
    ddsd1.dwSize := SizeOf(ddsd1);
    if suf1.Lock(r1, ddsd1) then
    begin
      try
        ddsd2.dwSize := SizeOf(ddsd2);
        if (suf1=suf2) or suf2.Lock(r2, ddsd2) then
        begin
          try
            if suf1=suf2 then ddsd2 := ddsd1;
            if ddsd1.ddpfPixelFormat.dwRGBBitCount<>ddsd2.ddpfPixelFormat.dwRGBBitCount then Exit;
                                     
            {  Get transparent color  }
            tc1 := ddsd1.ddckCKSrcBlt.dwColorSpaceLowValue;
            tc2 := ddsd2.ddckCKSrcBlt.dwColorSpaceLowValue;

            case ddsd1.ddpfPixelFormat.dwRGBBitCount of
              8 : begin
                    for Top:=0 to h-1 do
                    begin
                      P1 := Pointer(Integer(ddsd1.lpSurface)+Top*ddsd1.lPitch);
                      P2 := Pointer(Integer(ddsd1.lpSurface)+Top*ddsd2.lPitch);
                      for Left:=0 to w-1 do
                      begin
                        if (PByte(P1)^<>tc1) and (PByte(P2)^<>tc2) then Exit;
                        Inc(PByte(P1));
                        Inc(PByte(P2));
                      end;
                    end;
                  end;
              16: begin
                    for Top:=0 to h-1 do
                    begin
                      P1 := Pointer(Integer(ddsd1.lpSurface)+Top*ddsd1.lPitch);
                      P2 := Pointer(Integer(ddsd1.lpSurface)+Top*ddsd2.lPitch);
                      for Left:=0 to w-1 do
                      begin
                        if (PWord(P1)^<>tc1) and (PWord(P2)^<>tc2) then Exit;
                        Inc(PWord(P1));
                        Inc(PWord(P2));
                      end;
                    end;
                  end;
              24: begin
                    for Top:=0 to h-1 do
                    begin
                      P1 := Pointer(Integer(ddsd1.lpSurface)+Top*ddsd1.lPitch);
                      P2 := Pointer(Integer(ddsd1.lpSurface)+Top*ddsd2.lPitch);
                      for Left:=0 to w-1 do
                      begin
                        with PRGB(P1)^ do if (R shl 16) or (G shl 8) or B<>tc1 then Exit;
                        with PRGB(P2)^ do if (R shl 16) or (G shl 8) or B<>tc2 then Exit;
                        Inc(PRGB(P1));
                        Inc(PRGB(P2));
                      end;
                    end;
                  end;
              32: begin
                    for Top:=0 to h-1 do
                    begin
                      P1 := Pointer(Integer(ddsd1.lpSurface)+Top*ddsd1.lPitch);
                      P2 := Pointer(Integer(ddsd1.lpSurface)+Top*ddsd2.lPitch);
                      for Left:=0 to w-1 do
                      begin
                        if (PDWORD(P1)^<>tc1) and (PDWORD(P2)^<>tc2) then Exit;
                        Inc(PDWORD(P1));
                        Inc(PDWORD(P2));
                      end;
                    end;
                  end;
            end;
          finally
            if suf1<>suf2 then suf2.UnLock;
          end;
        end;
      finally
        suf1.UnLock;
      end;
    end;

    Result := False;
  end;
end;

function TImageSprite.TestCollision(Sprite: TSprite): Boolean;
var
  img1, img2: Integer;
  b1, b2: TRect;
begin
  if (Sprite is TImageSprite) and FPixelCheck and not(Sprite is TImageSpriteEx)then
  begin
    b1 := GetDrawRect;
    b2 := TImageSprite(Sprite).GetDrawRect;

    img1 := GetDrawImageIndex;
    img2 := TImageSprite(Sprite).GetDrawImageIndex;

    Result := ImageCollisionTest(Image.PatternSurfaces[img1], TImageSprite(Sprite).Image.PatternSurfaces[img2],
      Image.PatternRects[img1], TImageSprite(Sprite).Image.PatternRects[img2],
      b1.Left, b1.Top, b2.Left, b2.Top, True);
  end else
    Result := inherited TestCollision(Sprite);
end;

{  TImageSpriteEx  }

constructor TImageSpriteEx.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  FAlpha := 255;
  DrawMode:=dmNormal;
end;

procedure TImageSpriteEx.DoDraw;
begin
  if not(assigned(image))then raise exception.create('No Image selected for '+self.ClassName);
  Image.DrawImage(FEngine.FSurface,round(WorldX),round(WorldY),width,height,GetDrawImageIndex,Centerx,centery,angle,alpha,drawmode);
end;

function TImageSpriteEx.GetBoundsRect: TRect;
begin
  Result := Rect(floor(WorldX-CenterX*width*cos(Angle/(2*pi))-CenterY*height*sin(Angle/(2*pi))),
                 floor(WorldY-CenterX*width*sin(Angle/(2*pi))-CenterY*height*cos(Angle/(2*pi))),
                 ceil (WorldX+(1-CenterX)*width*cos(Angle/(2*pi))+(1-CenterY)*height*sin(Angle/(2*pi))),
                 ceil (WorldY-(1-CenterX)*width*sin(Angle/(2*pi))+(1-CenterY)*height*cos(Angle/(2*pi))));
  //Result := Rect(floor(WorldX-FSize),floor(WorldY-FSize),ceil(WorldX+FSize),ceil(WorldY+FSize));
end;

procedure TImageSpriteEx.SetHeight(const Value: integer);
begin
  FHeight := Value;
  //FSize:=ceil(sqrt(sqr(FWidth)+sqr(FHeight)));
end;

procedure TImageSpriteEx.SetWidth(const Value: integer);
begin
  FWidth := Value;
  //FSize:=ceil(sqrt(sqr(FWidth)+sqr(FHeight)));
end;

function TImageSpriteEx.TestCollision(Sprite: TSprite): Boolean;
begin
  if Sprite is TImageSpriteEx then
  begin
    Result := OverlapRect(Bounds(Trunc(Sprite.WorldLeft), Trunc(Sprite.WorldTop), Sprite.Width, Sprite.Height),
      Bounds(Trunc(WorldLeft), Trunc(WorldTop), Width, Height));
  end else
  begin
    Result := OverlapRect(Sprite.BoundsRect, Bounds(Trunc(WorldLeft), Trunc(WorldTop), Width, Height));
  end;
end;

{  TBackgroundSprite  }

constructor TBackgroundSprite.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Collisioned := False;
end;

destructor TBackgroundSprite.Destroy;
begin
  SetMapSize(0, 0);
  inherited Destroy;
end;

procedure TBackgroundSprite.DoDraw;
var
  _x, _y, cx, cy, cx2, cy2, c, ChipWidth, ChipHeight: Integer;
  StartX, StartY, EndX, EndY, StartX_, StartY_, OfsX, OfsY, dWidth, dHeight: Integer;
  r: TRect;
begin
  if Image=nil then Exit;

  if (FMapWidth<=0) or (FMapHeight<=0) then Exit;

  r := Image.PatternRects[0];
  ChipWidth := r.Right-r.Left;
  ChipHeight := r.Bottom-r.Top;

  dWidth := (FEngine.SurfaceRect.Right+ChipWidth) div ChipWidth+1;
  dHeight := (FEngine.SurfaceRect.Bottom+ChipHeight) div ChipHeight+1;

  _x := Trunc(WorldLeft);
  _y := Trunc(WorldTop);

  OfsX := _x mod ChipWidth;
  OfsY := _y mod ChipHeight;

  StartX := _x div ChipWidth;
  StartX_ := 0;

  if StartX<0 then
  begin
    StartX_ := -StartX;
    StartX := 0;
  end;

  StartY := _y div ChipHeight;
  StartY_ := 0;

  if StartY<0 then
  begin
    StartY_ := -StartY;
    StartY := 0;
  end;

  EndX := Min(StartX+FMapWidth-StartX_, dWidth);
  EndY := Min(StartY+FMapHeight-StartY_, dHeight);

  if FTile then
  begin
    for cy:=-1 to dHeight do
    begin
      cy2 := Mod2((cy-StartY+StartY_), FMapHeight);
      for cx:=-1 to dWidth do
      begin
        cx2 := Mod2((cx-StartX+StartX_), FMapWidth);
        c := Chips[cx2, cy2];
        if c>=0 then
          Image.Draw(FEngine.Surface, cx*ChipWidth+OfsX, cy*ChipHeight+OfsY, c);
      end;
    end;
  end else
  begin
    for cy:=StartY to EndY-1 do
      for cx:=StartX to EndX-1 do
      begin
        c := Chips[cx-StartX+StartX_, cy-StartY+StartY_];
        if c>=0 then
          Image.Draw(FEngine.Surface, cx*ChipWidth+OfsX, cy*ChipHeight+OfsY, c);
      end;
  end;
end;

function TBackgroundSprite.TestCollision(Sprite: TSprite): Boolean;
var
  b, b1, b2: TRect;
  cx, cy, ChipWidth, ChipHeight: Integer;
  r: TRect;
begin
  Result := True;
  if Image=nil then Exit;
  if (FMapWidth<=0) or (FMapHeight<=0) then Exit;

  r := Image.PatternRects[0];
  ChipWidth := r.Right-r.Left;
  ChipHeight := r.Bottom-r.Top;



  b1 := Sprite.BoundsRect;
  b2 := BoundsRect;

  IntersectRect(b, b1, b2);

  OffsetRect(b, -Trunc(WorldLeft), -Trunc(WorldTop));
  OffsetRect(b1, -Trunc(WorldLeft), -Trunc(WorldTop));

  for cy:=(b.Top-ChipHeight+1) div ChipHeight to b.Bottom div ChipHeight do
    for cx:=(b.Left-ChipWidth+1) div ChipWidth to b.Right div ChipWidth do
      if CollisionMap[Mod2(cx, MapWidth), Mod2(cy, MapHeight)] then
      begin
        if OverlapRect(Bounds(cx*ChipWidth, cy*ChipHeight, ChipWidth, ChipHeight), b1) then Exit;
      end;

  Result := False;
end;

function TBackgroundSprite.GetChip(Left, Top: Integer): Integer;
begin
  if (Left>=0) and (Left<FMapWidth) and (Top>=0) and (Top<FMapHeight) then
    Result := PInteger(Integer(FMap)+(Top*FMapWidth+Left)*SizeOf(Integer))^
  else
    Result := -1;
end;

type
  PBoolean = ^Boolean;

function TBackgroundSprite.GetCollisionMapItem(Left, Top: Integer): Boolean;
begin
  if (Left>=0) and (Left<FMapWidth) and (Top>=0) and (Top<FMapHeight) then
    Result := PBoolean(Integer(FCollisionMap)+(Top*FMapWidth+Left)*SizeOf(Boolean))^
  else
    Result := False;
end;

function TBackgroundSprite.GetBoundsRect: TRect;
begin
  if FTile then
    Result := FEngine.SurfaceRect
  else
  begin
    if Image<>nil then
      Result := Bounds(Trunc(WorldLeft), Trunc(WorldTop),
        Image.Width*FMapWidth, Image.Height*FMapHeight)
    else
      Result := Rect(0, 0, 0, 0);
  end;
end;

procedure TBackgroundSprite.SetChip(Left, Top: Integer; Value: Integer);
begin
  if (Left>=0) and (Left<FMapWidth) and (Top>=0) and (Top<FMapHeight) then
    PInteger(Integer(FMap)+(Top*FMapWidth+Left)*SizeOf(Integer))^ := Value;
end;

procedure TBackgroundSprite.SetCollisionMapItem(Left, Top: Integer; Value: Boolean);
begin
  if (Left>=0) and (Left<FMapWidth) and (Top>=0) and (Top<FMapHeight) then
    PBoolean(Integer(FCollisionMap)+(Top*FMapWidth+Left)*SizeOf(Boolean))^ := Value;
end;

procedure TBackgroundSprite.SetMapHeight(Value: Integer);
begin
  SetMapSize(FMapWidth, Value);
end;

procedure TBackgroundSprite.SetMapWidth(Value: Integer);
begin
  SetMapSize(Value, FMapHeight);
end;

procedure TBackgroundSprite.SetImage(Img : TPictureCollectionItem);
BEGIN
  FImage:=Img;
  Width:=FMapWidth*Img.Width;
  Height:=FMapHeight*Img.Height;
END;

procedure TBackgroundSprite.SetMapSize(AMapWidth, AMapHeight: Integer);
begin
  if (FMapWidth<>AMapWidth) or (FMapHeight<>AMapHeight) then
  begin
    if (AMapWidth<=0) or (AMapHeight<=0) then
    begin
      AMapWidth := 0;
      AMapHeight := 0;
    end;
    {else
    begin
    FWidth:=AMapWidth*Image.Width;
    FHeight:=AMapHeight*Image.Height;
    end;
    }
    FMapWidth := AMapWidth;
    FMapHeight := AMapHeight;

    ReAllocMem(FMap, FMapWidth*FMapHeight*SizeOf(Integer));
    FillChar(FMap^, FMapWidth*FMapHeight*SizeOf(Integer), 0);

    ReAllocMem(FCollisionMap, FMapWidth*FMapHeight*SizeOf(Boolean));
    FillChar(FCollisionMap^, FMapWidth*FMapHeight*SizeOf(Boolean), 1);
  end;
end;

{  TSpriteEngine  }

constructor TSpriteEngine.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  FDeadList := TList.Create;
end;

destructor TSpriteEngine.Destroy;
begin
  FDeadList.Free;
  inherited Destroy;
end;

procedure TSpriteEngine.Dead;
begin
  while FDeadList.Count>0 do
    TSprite(FDeadList[FDeadList.Count-1]).Free;
end;

procedure TSpriteEngine.Draw;
begin
  FDrawCount := 0;
  inherited Draw;
end;

procedure TSpriteEngine.SetSurface(Value: TDirectDrawSurface);
begin
  FSurface := Value;
  if FSurface<>nil then
  begin
    Width := SurfaceRect.Right-SurfaceRect.Left;
    Height := SurfaceRect.Bottom-SurfaceRect.Top;
  end;
end;

function TSpriteEngine.GetSurfaceRect: TRect;
begin
 result:= FSurface.ClientRect;
end;

{  TCustomDXSpriteEngine  }

constructor TCustomDXSpriteEngine.Create(AOnwer: TComponent);
begin
  inherited Create(AOnwer);
  FEngine := TSpriteEngine.Create(nil);
end;

destructor TCustomDXSpriteEngine.Destroy;
begin                     
  FEngine.Free;
  inherited Destroy;
end;

procedure TCustomDXSpriteEngine.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (DXDraw=AComponent) then
    DXDraw := nil;
end;

procedure TCustomDXSpriteEngine.Dead;
begin
  FEngine.Dead;
end;

procedure TCustomDXSpriteEngine.Draw;
begin
  if (FDXDraw<>nil) and (FDXDraw.Initialized) then
    FEngine.Draw;
end;

procedure TCustomDXSpriteEngine.Move(MoveCount: Integer);
begin
  FEngine.Move(MoveCount);
end;

procedure TCustomDXSpriteEngine.DXDrawNotifyEvent(Sender: TCustomDXDraw;
  NotifyType: TDXDrawNotifyType);
begin
  case NotifyType of
    dxntDestroying: DXDraw := nil;
    dxntInitialize: FEngine.Surface := Sender.Surface;
    dxntFinalize  : FEngine.Surface := nil;
  end;
end;

procedure TCustomDXSpriteEngine.SetDXDraw(Value: TCustomDXDraw);
begin
  if FDXDraw<>nil then
    FDXDraw.UnRegisterNotifyEvent(DXDrawNotifyEvent);

  FDXDraw := Value;

  if FDXDraw<>nil then
    FDXDraw.RegisterNotifyEvent(DXDrawNotifyEvent);
end;

{ TShadowSprite }

constructor TShadowSprite.Create(AParent: TSprite);
begin
 inherited;
 collisioned:=false;
 z:=-1;

 x:=-1;
 y:=+1;
 CenterX:=Parent.CenterX;
 CenterY:=Parent.CenterY;
 Rotate:=Parent is TImageSpriteEx;
end;

procedure TShadowSprite.DoDraw;
begin
  if not(assigned(image))then raise exception.create('No Image selected for '+self.ClassName);
  if Rotate then angle:=parent.angle else angle:=0;
  Image.DrawImage(FEngine.FSurface,round(WorldX),round(WorldY),width,height,GetDrawImageIndex,Centerx,centery,angle,alpha,drawmode);
end;

procedure TShadowSprite.SetImage(const Value: TPictureCollectionItem);
begin
  FImage := Value;
  SizeShadow;
end;

procedure TShadowSprite.SetRotate(const Value: boolean);
begin
  FRotate := Value;
end;

procedure TShadowSprite.SizeShadow;
begin
 if assigned(Image)then
  Begin
   Width:=Image.width;
   Height:=Image.Height;
  End;
 if assigned(Image)and(Parent is TImageSprite)and assigned((Parent as TImageSprite).Image) then
  Begin
   Width:=round(Parent.Width/(Parent as TImageSprite).Image.Width*Image.Width);
   Height:=round(Parent.Height/(Parent as TImageSprite).Image.Height*Image.Height);
  End;
end;

end.
