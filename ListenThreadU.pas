unit ListenThreadU;

interface

uses
  Windows, Messages, Controls, WinSock;

// routine thread starts at
function  ThreadEntryRoutine(Info:Pointer):integer; stdcall;

var
  X1,X2 : integer;

const
  CallBackMsg     = WM_USER+1;
  DoneCallBackMsg = WM_User+1;

type
  TListenThread = class(TObject)
  private
    UpdatePeriod  : Integer; // ms

// priority property routines
    procedure SetPriority(NewPriority : integer);
    function  GetPriority : integer;
    procedure WMDoneCallBack(var Msg:TMessage); message DoneCallBackMsg;
    function  AbleToAcceptNewClient: Boolean;
    function  AbleToStartListening: Boolean;
    procedure StopListening;

  public
    ThreadID     : DWord;
    Stopped      : Boolean;
    ThreadHandle : Integer;
    SocketHandle : Integer;

    constructor Create;
    destructor  Destroy; override;

    property Priority : integer read GetPriority write SetPriority;

// public routines
    procedure Start;
    procedure Stop;
    procedure RunLoop;
  end;

implementation

uses
  MMSystem, Dialogs, Forms, Math, SysUtils, TcpServerU;

function ThreadEntryRoutine(Info:Pointer):integer; stdcall;
var
  Thread : TListenThread;
begin
  Thread:=TListenThread(Info);

// enter our tracking loop
  Thread.RunLoop;
end;

constructor TListenThread.Create;
begin
  inherited Create;

  UpdatePeriod:=40; // 25x per second
  ThreadHandle:=-1;
  SocketHandle:=-1;
end;

destructor TListenThread.Destroy;
begin
  if not Stopped then Stop;
end;

procedure TListenThread.SetPriority(NewPriority:integer);
begin
// THREAD_PRIORITY_TIMECRITICAL   - causes other threads to starve
// THREAD_PRIORITY_HIGHEST        - +2     4.2-4.3
// THREAD_PRIORITY_ABOVE_NORMAL   - +1     4.2-4.3
// THREAD_PRIORITY_NORMAL         -  0     4.2-4.6
// THREAD_PRIORITY_BELOW_NORMAL   - -1
// THREAD_PRIORITY_LOWEST         - -2
//  SetThreadPriority(Handle,NewPriority);
end;

function TListenThread.GetPriority : integer;
begin
  Result:=GetThreadPriority(ThreadHandle);
end;

procedure TListenThread.Start;
begin
// create the thread
  ThreadHandle:=CreateThread(nil,0,@ThreadEntryRoutine,Self,0,ThreadID);
  if ThreadHandle=0 then ShowMessage('Unable to create thread!')
  else begin
    Stopped:=False;

// normal priority is ok
    Priority:=THREAD_PRIORITY_NORMAL;
  end;

// force feed it messages until we succeed - see Win32.Hlp
  repeat
    Application.ProcessMessages;
  until PostThreadMessage(ThreadID,DoneCallBackMsg,0,0);
end;

procedure TListenThread.Stop;
begin
  StopListening;

  if ThreadHandle<>-1 then begin

    PostThreadMessage(ThreadID,TerminateMsg,0,0);

// wait for it to die
    WaitForSingleObject(ThreadHandle,3000);

// free the handle
    CloseHandle(ThreadHandle);
    ThreadHandle:=-1;
  end;
end;

procedure TListenThread.StopListening;
begin
  if SocketHandle<>-1 then begin
    WinSock.CloseSocket(SocketHandle);
    SocketHandle:=-1;
  end;
end;

function TListenThread.AbleToStartListening:Boolean;
var
  FD,Yes  : Integer;
  Error   : Integer;
  Address : SockAddr_In;
begin
  Result:=False;

  FD:=Socket(AF_INET,SOCK_STREAM,0);

  if FD=SOCKET_ERROR then Exit;

  Yes:=1;
  Error:=SetSockOpt(FD,SOL_SOCKET,SO_REUSEADDR,@Yes,SizeOf(Integer));
  if Error=SOCKET_ERROR then Exit;

// bind to an address and port
  Address.Sin_Family:=AF_INET;
  Address.Sin_Port:=HTONS(ServerPort);
  Address.Sin_Addr.S_Addr:=HTONL(INADDR_ANY);
  FillChar(Address.Sin_Zero,SizeOf(Address.Sin_Zero),0);

  Error:=Bind(FD,Address,SizeOf(Address));
  if Error=SOCKET_ERROR then Exit;

  Error:=Listen(FD,8);
  if Error=SOCKET_ERROR then Exit;

// remember the socket handle
  SocketHandle:=FD;
  Result:=True;
end;

function TListenThread.AbleToAcceptNewClient:Boolean;
var
  Addr      : TSockAddr;
  Size      : Integer;
  NewHandle : Integer;
  RemoteIP   : String;
  RemotePort : Integer;
begin
  Result:=False;
  Size:=SizeOf(Addr);
  FillChar(Addr,Size,0);

  try
    NewHandle:=WinSock.Accept(SocketHandle,@Addr,@Size);
  except
    NewHandle:=INVALID_SOCKET;
  end;

  if NewHandle<>INVALID_SOCKET then begin
    RemoteIP:=Inet_NTOA(Addr.Sin_Addr);
    RemotePort:=NTOHS(Addr.Sin_Port);

    Server.AcceptClient(NewHandle,RemoteIP,RemotePort);
    Result:=True;
  end;
end;

procedure TListenThread.RunLoop;
var
  Msg        : TMsg;
  Terminated : Boolean;
begin
  if AbleToStartListening then begin

// create the message queue
    GetMessage(Msg,0,0,0);

// we'll sit in this loop until the thread is terminated
    repeat
      Terminated:=(not AbleToAcceptNewClient) or
                   PeekMessage(Msg,0,TerminateMsg,TerminateMsg,PM_REMOVE);
    until Terminated;
  end;
  StopListening;
end;

procedure TListenThread.WMDoneCallBack(var Msg:TMessage);
begin
end;

end.





