unit SlaveU;

interface

uses
  Global, Classes, Math, SphereU, ZmqClientU;

type
  TSlave = class(TObject)
  private

  public
    Tag : Integer;

    IP     : TIpAddress;
    Pose   : TPose;
    FOV    : Single;
    Window : TWindow;

    Sphere    : TSphere;
    ZmqClient : TZmqClient;

    constructor Create(iTag:Integer);
    destructor  Destroy; override;

    procedure SetToDefault;
    procedure WriteToStream(Stream:TFileStream);
    procedure ReadFromStream(Stream:TFileStream);
    procedure Sync;
  end;

  TSlaveArray = array[1..MaxSlaves] of TSlave;

var
  Slave  : TSlaveArray;
  Slaves : Integer;

procedure CreateSlaves;
procedure FreeSlaves;

procedure SyncSlaves;

procedure SetSlavesToDefault;
procedure LoadSlaves(FileStream:TFileStream);
procedure SaveSlaves(FileStream:TFileStream);

implementation

uses
  Settings;

procedure SyncSlaves;
var
  S : Integer;
begin
  for S:=1 to MaxSlaves do Slave[S].Sync;
end;

procedure SetSlavesToDefault;
var
  S : Integer;
begin
  for S:=1 to MaxSlaves do Slave[S].SetToDefault;
end;

procedure LoadSlaves(FileStream:TFileStream);
var
  S : Integer;
begin
  for S:=1 to MaxSlaves do Slave[S].ReadFromStream(FileStream);
end;

procedure SaveSlaves(FileStream:TFileStream);
var
  S : Integer;
begin
  for S:=1 to MaxSlaves do Slave[S].WriteToStream(FileStream);
end;

procedure CreateSlaves;
var
  S : Integer;
begin
  for S:=1 to MaxSlaves do Slave[S]:=TSlave.Create(S);
end;

procedure FreeSlaves;
var
  S : Integer;
begin
  for S:=1 to MaxSlaves do if Assigned(Slave[S]) then Slave[S].Free;
end;

constructor TSlave.Create(iTag: Integer);
begin
  inherited Create;
  Tag:=iTag;
  ZmqClient:=TZmqClient.Create(Tag);
  Sphere:=TSphere.Create;
end;

destructor TSlave.Destroy;
begin
 // if Assigned(ZmqClient) then ZmqClient.Free;
//  if Assigned(Sphere) then Sphere.Free;
  inherited;
end;

procedure TSlave.SetToDefault;
begin
  IP:='?';
  FillChar(Pose,SizeOf(Pose),0);
  FOV:=DegToRad(45);
  FillChar(Window,SizeOf(Window),0);
  Sphere.SetToDefault;
end;

const
  SlaveReserveSize = 256;

procedure TSlave.WriteToStream(Stream:TFileStream);
begin
// IP
  Stream.Write(IP,SizeOf(IP));

  Stream.Write(Pose,SizeOf(Pose));
  Stream.Write(FOV,SizeOf(FOV));

// projector window
  Stream.Write(Window,SizeOf(Window));

  WriteReserveToStream(Stream,SlaveReserveSize);
end;

procedure TSlave.ReadFromStream(Stream:TFileStream);
begin
  Stream.Read(IP,SizeOf(IP));
  Stream.Read(Pose,SizeOf(Pose));
  Stream.Read(FOV,SizeOf(FOV));
  Stream.Read(Window,SizeOf(Window));

  ReadReserveFromStream(Stream,SlaveReserveSize);
end;

procedure TSlave.Sync;
var
  Stream : TMemoryStream;
begin
  Stream:=TMemoryStream.Create;
  Stream.Write(Pose,SizeOf(Pose));
  Stream.Write(FOV,SizeOf(FOV));
  Stream.Write(Window,SizeOf(Window));

  ZMQClient.TxStream(Stream);
end;

end.

