unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Sockets, ExtCtrls, StdCtrls, IdUDPClient, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPServer, IdSocketHandle,IdStack;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    RemotePort: TEdit;
    RemoteHost: TEdit;
    EnableClient: TCheckBox;
    GroupBox2: TGroupBox;
    LocalPort: TEdit;
    EnableServer: TCheckBox;
    Log: TMemo;
    procedure EnableServerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ServerStatus(ASender:TObject;AStatus:TIdStatus;AStatusText:String);
    procedure UDPRead(Sender: TObject; AData: TStream;   ABinding: TIdSocketHandle);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var UdpClient:TIdUdpClient;
var UdpServer:TIdUdpServer;

Type ActivePacket=record
  PacketType:Cardinal;
  active:boolean;
end;

var Pos:TPoint;
procedure TForm1.EnableServerClick(Sender: TObject);
begin
  if EnableServer.Checked
  then begin
    Log.Lines.Add('Enable Server');
    UdpServer.DefaultPort:=   strtoint(LocalPort.text);
    UdpServer.Active:=true;
  end
  else begin
    UdpServer.Active:=false;
  end;
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  UdpServer:=TIdUdpServer.create();
  UdpServer.OnUDPRead:=UDPRead;
end;

procedure TForm1.ServerStatus(ASender: TObject; AStatus: TIdStatus;
  AStatusText: String);
begin
//
end;

procedure TForm1.UDPRead(Sender: TObject; AData: TBytes;
  ABinding: TIdSocketHandle);
begin
  //
end;

end.
