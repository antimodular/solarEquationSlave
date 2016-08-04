unit PeerU;

interface

uses
  Global, ZmqClientU;

const
  MaxPeers = 4;

type
  TPeerInfo = record
    IP : TIpAddress;
  end;

  TPeer = class(TObject)
  private
    Client : TZmqClient;

    function GetInfo:TPeerInfo;
    procedure SetInfo(NewInfo:TPeerInfo);

  public
    IP : TIpAddress;

    constructor Create;
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure Update;

    procedure SetRunMode(Mode: TRunMode);
  end;
  TPeerArray = array[1..MaxPeers] of TPeer;

var
  Peer  : TPeerArray;
  Peers : Integer = 3;

procedure CreatePeers;
procedure FreePeers;

procedure ConnectToPeers;
procedure UpdatePeers;

implementation

procedure CreatePeers;
var
  I : Integer;
begin
  for I:=1 to MaxPeers do begin
    Peer[I]:=TPeer.Create;
  end;
end;

procedure FreePeers;
var
  I : Integer;
begin
  for I:=1 to MaxPeers do begin
    if Assigned(Peer[I]) then Peer[I].Free;
  end;
end;

procedure ConnectToPeers;
var
  I : Integer;
begin
  for I:=1 to Peers do begin
    if Assigned(Peer[I]) then Peer[I].Connect;
  end;
end;

procedure DisconnectFromPeers;
var
  I : Integer;
begin
  for I:=1 to Peers do begin
    if Assigned(Peer[I]) then Peer[I].Disconnect;
  end;
end;

procedure UpdatePeers;
var
  I : Integer;
begin
  for I:=1 to Peers do begin
    if Assigned(Peer[I]) then Peer[I].Update;
  end;
end;

procedure PutPeersInRunMode;
var
  I : Integer;
begin
  for I:=1 to Peers do begin
    if Assigned(Peer[I]) then Peer[I].SetRunMode(rmRun);
  end;
end;

constructor TPeer.Create;
begin
  inherited;

  Client:=TZmqClient.Create(1);
end;

destructor TPeer.Destroy;
begin
  if Assigned(Client) then Client.Free;
end;

function TPeer.GetInfo:TPeerInfo;
begin
  Result.IP:=IP;
end;

procedure TPeer.SetInfo(NewInfo:TPeerInfo);
begin
  IP:=NewInfo.IP;
end;

procedure TPeer.Connect;
begin
  Client.StartUp;
end;

procedure TPeer.Disconnect;
begin

end;

procedure TPeer.Update;
begin

end;

procedure TPeer.SetRunMode(Mode:TRunMode);
begin

end;

end.
