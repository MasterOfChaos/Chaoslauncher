unit DxPlayEx;

interface
uses DxPlay,classes,directx;
type TPointerStream=class(TCustomMemoryStream)
 end;
type TDXPlayMessageEvent2 = procedure(Sender: TObject; From: TDXPlayPlayer; Data:TStream) of object;
type TDxPlayEx=class(TDxPlay)
  private
    FOnMessage2: TDXPlayMessageEvent2;
    Stream:TPointerStream;
    FSendStream:TMemoryStream;
  protected
    procedure DoMessage(From: TDXPlayPlayer; Data: Pointer; DataSize: Integer); override;
  public
   property SendStream:TMemoryStream read FSendStream;

   constructor create(AOwner:TComponent);override;
   destructor destroy;override;

   procedure Send(ToID: TDPID;ClearData:boolean=true);
   procedure clear;
  published
   property OnMessage2:TDXPlayMessageEvent2 read FOnMessage2 write FOnMessage2;
  end;
procedure Register;

implementation

procedure Register;
Begin
 RegisterComponents('DelphiX', [TDxPlayEx]);
End;
{ TDxPlayEx }

procedure TDxPlayEx.clear;
begin
 Sendstream.Clear;
end;

constructor TDxPlayEx.create(AOwner: TComponent);
begin
 inherited;
 Stream:=TPointerStream.create;
 FSendstream:=TMemoryStream.create;
end;

destructor TDxPlayEx.destroy;
begin
 Stream.free;
 FSendstream.free;
 inherited;
end;

procedure TDxPlayEx.DoMessage(From: TDXPlayPlayer; Data: Pointer;
  DataSize: Integer);
begin
 inherited;
 Stream.SetPointer(Data,DataSize);
 Stream.Position:=0;
 if Assigned(FOnMessage2) then FOnMessage2(Self, From, Stream);
end;

procedure TDxPlayEx.Send(ToID: TDPID;ClearData:boolean);
begin
 SendMessage(ToId,Sendstream.memory,Sendstream.size);
 if cleardata then clear;
end;

end.
