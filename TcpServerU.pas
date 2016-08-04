unit TcpServerU;

interface

uses
  Windows, SysUtils, Sockets, Forms, IdBaseComponent, Classes, Graphics,
  Messages, Global, Dialogs, WinSock, IdGlobal, ListenThreadU, ClientThreadU,
  ClientU, UdpU;

const
  ServerPort  = 7000;

// main thread to server thread
  TerminateMsg = WM_USER+1;

// main thread to client thread
  TxDataMsg = WM_USER+5;

// client thread to main thread
  ConnectedMsg    = WM_USER+10;
  DisconnectedMsg = WM_USER+11;
  DataRxMsg       = WM_USER+12;

// client to server
  QueryStatusCmd = 4;
  StartPieceCmd  = 55;
  StopPieceCmd   = 18;

// server to client
  StatusMsg = 77;

  Sig1 = 47;
  Sig2 = 32;
  Sig3 = 16;
  Sig4 = 93;

type
  TOnRxString = procedure(Sender:TObject;RxString:String) of Object;

  TOnRxData = procedure(Sender:TObject;C:Integer) of Object;

  TOnClientConnect = procedure(Sender:TObject;C:Integer) of Object;

  TTcpServer = class(TObject)
  private
    procedure WndProc(var Msg:TMessage);

    function  ClientAtIp(IpAddress:String):Integer;
    function  FirstAvailableClient:Integer;
    function  SocketHasBeenDisconnected(Handle: Integer): Boolean;
    function  SocketStillConnected(Handle: Integer): Boolean;
    function  NextClient:Integer;
    procedure ProcessRxBuffer(C: Integer);

  public
    WinHandle    : THandle;
    ListenThread : TListenThread;
    Clients      : Integer;
    Client       : TClientArray;

    OnClientConnect    : TOnClientConnect;
    OnClientDisconnect : TOnClientConnect;
    OnRxString         : TOnRxString;
    OnRxData           : TOnRxData;
    ShuttingDown       : Boolean;

    Active : Boolean;

    constructor Create;
    destructor  Destroy; override;

    function  AbleToTxStringToIP(TxStr,IpAddress:String):Boolean;

    procedure ShutDown;
    procedure DisconnectClients;

    procedure PrepareBytes(var Bytes:TBytes;Size:Integer);
    procedure ClientConnected(C:Integer);
    procedure StringRxFromClient(RxString:String;ClientI:Integer);

//    procedure ListenOnPort(Port:Integer);

    procedure TxDataToClient(Data:PByte;Size,I:Integer);
    procedure TxDataToClients(Data:PByte;Size:Integer);

    procedure TxBytesToClient(Data:TBytes;I:Integer);
    procedure TxBytesToClients(Data:TBytes);

    procedure TxStringToClient(TxStr:String;I:Integer);
    procedure TxStringToClients(TxStr:String);

    procedure TxStatusToClient(C: Integer; Running: Boolean);
    procedure TxStatusToClients(Running: Boolean);

    procedure AcceptClient(NewHandle: Integer; RemoteIP:String;RemotePort: Integer);

    procedure ListenForClients;
    procedure StopListening;
  end;

var
  Server : TTcpServer;

implementation

uses
  Routines, TilerU, JpgTransceiverU;

constructor TTcpServer.Create;
var
  I : Integer;
begin
  inherited Create;

  ShuttingDown:=False;
  for I:=1 to MaxClients do Client[I]:=TClient.Create(I);

  OnRxString:=nil;
  OnClientConnect:=nil;
  OnClientDisconnect:=nil;

  WinHandle:=AllocateHWnd(WndProc);
end;

procedure TTcpServer.ShutDown;
begin
  if Active then begin
 //   DisconnectClients;
    Active:=False;
  end;
end;

destructor TTcpServer.Destroy;
var
  I : Integer;
begin
  ShutDown;
  DeAllocateHWnd(WinHandle);

  for I:=1 to MaxClients do if Assigned(Client[I]) then Client[I].Free;

  inherited;
end;

procedure TTcpServer.DisconnectClients;
var
  C : Integer;
begin
  for C:=1 to MaxClients do Client[C].Disconnect;
end;

function TTcpServer.ClientAtIp(IpAddress:String):Integer;
var
  Found : Boolean;
begin
  Result:=0;
  repeat
    Inc(Result);
    Found:=Client[Result].Connected and (Client[Result].IP=IpAddress);
  until Found or (Result=MaxClients);

  if not Found then Result:=0;
end;

procedure TTcpServer.TxBytesToClient(Data:TBytes;I:Integer);
begin
  TxDataToClient(@Data[0],Length(Data),I);
end;

procedure TTcpServer.TxBytesToClients(Data:TBytes);
var
  I : Integer;
begin
  for I:=1 to MaxClients do TxBytesToClient(Data,I);
end;

procedure TTcpServer.TxDataToClient(Data:PByte;Size,I:Integer);
begin
  Client[I].TxData(Data,Size);
end;

procedure TTcpServer.TxDataToClients(Data:PByte;Size:Integer);
var
  I : Integer;
begin
  for I:=1 to MaxClients do TxDataToClient(Data,Size,I);
end;

procedure TTcpServer.TxStringToClients(TxStr:String);
var
  I : Integer;
begin
  for I:=1 to MaxClients do TxStringToClient(TxStr,I);
end;

procedure TTcpServer.TxStringToClient(TxStr:String;I:Integer);
begin
  TxDataToClient(@TxStr[1],Length(TxStr),I);
end;

function TTcpServer.FirstAvailableClient:Integer;
var
  C : Integer;
begin
  C:=0;
  repeat
    Inc(C);
  until (C=MaxClients) or (not Client[C].Connected);

  if Client[C].Connected then Result:=0
  else Result:=C;
end;

function TTcpServer.SocketHasBeenDisconnected(Handle:Integer):Boolean;
var
  V : Byte;
begin
  Result:=(Recv(Handle,V,0,MSG_PEEK)=0);
end;

function TTcpServer.SocketStillConnected(Handle:Integer):Boolean;
var
  C : Char;
begin
  Result:=(Recv(Handle,C,SizeOf(C),MSG_PEEK)<>0);
end;

procedure TTcpServer.ClientConnected(C:Integer);
begin
  Client[C].Connected:=True;
  if Assigned(OnClientConnect) then OnClientConnect(Self,C);
end;

procedure TTcpServer.StringRxFromClient(RxString:String;ClientI:Integer);
begin
end;

procedure TTcpServer.WndProc(var Msg:TMessage);
var
  ClientI : Integer;
begin
  ClientI:=Msg.wParam;

  Case Msg.Msg of

// move the data into a buffer and process it
    DataRxMsg :
      begin
        if (ClientI>0)  and (ClientI<=MaxClients) then begin
          EnterCriticalSection(Client[ClientI].CS);
            ProcessRxBuffer(ClientI);
            if Assigned(OnRxData) then OnRxData(Self,ClientI);     
          LeaveCriticalSection(Client[ClientI].CS);
        end;
      end;

    ConnectedMsg :
      if (ClientI>0)  and (ClientI<=MaxClients) then begin
        ClientConnected(ClientI);
      end;

// free the handle
    DisconnectedMsg :
      if (ClientI>0)  and (ClientI<=MaxClients) then begin
        Client[ClientI].Connected:=False;
        if Assigned(OnClientDisconnect) then begin
          OnClientDisconnect(Self,ClientI);
        end;
      end;

    else with Msg do begin
      Result:=DefWindowProc(WinHandle,Msg,wParam,lParam);
    end;
  end;
end;

procedure TTcpServer.PrepareBytes(var Bytes:TBytes;Size:Integer);
begin
  SetLength(Bytes,Size+SizeOf(Integer));
  Move(Size,Bytes[0],SizeOf(Integer));
end;

{procedure TTcpServer.ListenOnPort(Port:Integer);
begin
  Server.LocalPort:=IntToStr(Port);
  Server.Active:=True;
end;}

procedure TTcpServer.TxStatusToClient(C:Integer;Running:Boolean);
var
  TxStr : String;
begin
  SetLength(TxStr,2);
  TxStr[1]:=Char(StatusMsg);
  if Running then TxStr[2]:=Char(255)
  else TxStr[2]:=Char(0);

  TxStringToClient(TxStr,C);
end;

procedure TTcpServer.TxStatusToClients(Running: Boolean);
var
  TxStr : String;
begin
  SetLength(TxStr,2);
  TxStr[1]:=Char(StatusMsg);
  if Running then TxStr[2]:=Char(255)
  else TxStr[2]:=Char(0);
  TxStringToClients(TxStr);
end;

function TTcpServer.NextClient:Integer;
var
  C : Integer;
begin
  C:=0;
  repeat
    Inc(C);
  until (C=MaxClients) or (not Client[C].Connected);
  if Client[C].Connected then Result:=0
  else Result:=C;
end;

procedure TTcpServer.AcceptClient(NewHandle:Integer;RemoteIP:String;RemotePort:Integer);
var
  C : Integer;
begin
  C:=NextClient;
  if C>0 then begin
    Client[C].Connected:=True;
    Client[C].IP:=RemoteIP;
    Client[C].Port:=RemotePort;
    Client[C].Thread:=TClientThread.Create(C,NewHandle);

// inform the main thread
    PostMessage(WinHandle,ConnectedMsg,C,0);
  end;
end;

function TTcpServer.AbleToTxStringToIP(TxStr, IpAddress: String): Boolean;
begin
end;

procedure TTcpServer.ListenForClients;
begin
  ListenThread:=TListenThread.Create;
  ListenThread.Start;
  Active:=True;
end;

procedure TTcpServer.StopListening;
begin
  if Active then begin
    ListenThread.Stop;
    Active:=False;
  end;
end;

// the master doesn't get any info back from the clients
procedure TTcpServer.ProcessRxBuffer(C:Integer);
begin
end;

end.

