unit ZmqClientU;

interface

uses
  Forms, Zmq, Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs;

const
  SERVER_IP = 'tcp://10.0.6.62:4444';//localhost:5555';//127.0.0.1:5555';
  REPLY_RX_MSG = WM_USER+1;

// main thread to client thread
  StartMsg     = WM_USER+1;
  TerminateMsg = WM_USER+2;
  TxDataMsg    = WM_USER+3;

// client thread to main thread
  DataRxMsg       = WM_USER+10;
  ConnectedMsg    = WM_USER+11;
  DisconnectedMsg = WM_USER+12;

type
  TOnLog = procedure(Sender:TObject;Txt:String) of Object;

  TOnRxReply = procedure(Sender:TObject;RxStr:UTF8String) of Object;

  TZmqClient = class(TObject)
  private
    Context : Pointer;
    Socket  : Pointer;

    WinHandle : THandle;

    FOnRxReply  : TOnRxReply;
    FOnUpdate   : TNotifyEvent;
    FOnBadReply : TOnRxReply;

    FOnLog : TOnLog;
    FOnProgramAsserted : TNotifyEvent;

    procedure WndProc(var Msg:TMessage);

  public
    Tag          : Integer;
    Programs     : Integer;
    ProgramList  : TList;
    ThreadID     : DWord;
    ThreadHandle : THandle;
    CS           : TRTLCriticalSection;
    Enabled      : Boolean;
    ActiveID     : Integer;
    Connected    : Boolean;

    property OnRxReply  : TOnRxReply read FOnRxReply write FOnRxReply;
    property OnBadReply : TOnRxReply read FOnBadReply write FOnBadReply;

    property OnUpdate   : TNotifyEvent read FOnUpdate write FOnUpdate;

    property OnLog : TOnLog read FOnLog write FOnLog;
    property OnProgramAsserted : TNotifyEvent read FOnProgramAsserted
                                 write FOnProgramAsserted;

    constructor Create(iTag:Integer);
    destructor Destroy; override;

    procedure StartUp;
    procedure ShutDown;
    function  VersionStr:String;
    function  ReplyFromServer:UTF8String;
    procedure TxStream(Stream:TMemoryStream);

    procedure StartThread;
    procedure StopThread;
    procedure RunLoop;
  end;

implementation



function ThreadEntryRoutine(Info:Pointer):Integer; stdcall;
var
  Zmq : TZmqClient;
begin
// enter our tracking loop
  Zmq:=TZmqClient(Info);
  Zmq.RunLoop;
end;

{procedure SocketMonitor(Socket:Pointer;Event:Integer;Data:zmq_event_data_t);
begin
  Case Event of
    ZMQ_EVENT_LISTENING : ;
    ZMQ_EVENT_ACCEPTED : ;
  end;
end; }

constructor TZmqClient.Create(iTag:Integer);
begin
  inherited Create;

  Tag:=iTag;

  ProgramList:=TList.Create;
  InitializeCriticalSection(CS);

  FOnRxReply:=nil;
  FOnBadReply:=nil;
  FOnUpdate:=nil;

  FOnLog:=nil;
  FOnProgramAsserted:=nil;

  Enabled:=False;

  ActiveID:=0;
end;

destructor TZmqClient.Destroy;
begin
  DeAllocateHWnd(WinHandle);

  DeleteCriticalSection(CS);

  if Assigned(ProgramList) then ProgramList.Free;

 // ShutDown;
  inherited;
end;

procedure TZmqClient.StartUp;
var
  Txt     : UTF8String;
  RxStr   : AnsiString;
  Size,RC : Integer;
begin
  WinHandle:=AllocateHWnd(WndProc);

// create a context
//  Context:=ZmqServer.Context; //zmq_ctx_new;
  Context:=zmq_ctx_new;

//  RC:=zmq_ctx_set_monitor(Context,SocketMonitor);

  if not Assigned(Context) then Exit;

// create a requester
  Socket:=Zmq_Socket(Context,ZMQ_SUB);

// connect
  if Assigned(Socket) then begin
    Zmq_Connect(Socket,PAnsiChar(SERVER_IP));
    Zmq_Send(Socket,'Hello',5,0);
  end;
end;

procedure TZmqClient.ShutDown;
begin
  if Assigned(Socket) then Zmq_Close(Socket);
  if Assigned(Context) then Zmq_Term(Context);
end;

function TZmqClient.ReplyFromServer:UTF8String;
var
  Reply : Zmq_Msg_T;
  RxStr : UTF8String;
  Data  : PByte;
  Size  : Integer;
begin
  Result:='';
  Zmq_Msg_Init(Reply);

  Size:=64;
  SetLength(RxStr,Size);

  if Zmq_Recv(Socket,RxStr[1],Size,0)=0 then begin
    Size:=Zmq_Msg_Size(Reply);

// remove the "1:"
    Dec(Size,2);
    Data:=Zmq_Msg_Data(Reply);
    Inc(Data,2);

// copy it into a string
    SetLength(Result,Size);
    Move(Data^,Result[1],Size);

// clean up
    Zmq_Msg_Close(Reply);
  end;
end;

function TZmqClient.VersionStr:String;
var
  Major,Minor,Patch : Integer;
begin
  Zmq_Version(Major,Minor,Patch);

  Result:='Current 0MQ version is '+IntToStr(Major)+'.'+IntToStr(Minor)+
          '.'+IntToStr(Patch);
end;

procedure TZmqClient.StartThread;
begin
// create the thread
  ThreadHandle:=CreateThread(nil,0,@ThreadEntryRoutine,Self,0,ThreadID);
  if ThreadHandle=0 then ShowMessage('Unable to create thread!')
  else begin

// force feed it messages until we succeed
    repeat
      Application.ProcessMessages;
    until PostThreadMessage(ThreadID,StartMsg,0,0);
  end;
end;

procedure TZmqClient.StopThread;
begin
  PostThreadMessage(ThreadID,TerminateMsg,1,0);

// wait for it to die
  WaitForSingleObject(ThreadHandle,3000);
end;

procedure TZmqClient.RunLoop;
var
  Data           : PByte;
  RxStr          : UTF8String;
  Size           : Integer;
  Msg            : TMsg;
  Terminated     : Boolean;
  Char           : AnsiChar;
begin
// create the message queue
  GetMessage(Msg,0,0,0);

  StartUp;
  PostMessage(WinHandle,ConnectedMsg,0,0);

// run until we are told to quit
  Terminated:=False;
  repeat
    Zmq_Send(Socket,'Hello',5,0);
    Sleep(1000);


// get the latest server data
{    RxStr:=ReplyFromServer;

// make sure its ok and then hand it over to the main thread for processing
    if Length(RxStr)>1 then begin

// don't copy the null terminate character if it's there
      if RxStr[Length(RxStr)]=#0 then begin
        Size:=Length(RxStr)-1;
      end;
      CopyDataStruct.dwData:=REPLY_RX_MSG;
      CopyDataStruct.cbData:=Size;
      CopyDataStruct.lpData:=@RxStr[1];
      SendMessage(Handle,WM_COPYDATA,0,NativeUInt(@CopyDataStruct));
    end;}
    Terminated:=PeekMessage(Msg,0,TerminateMsg,TerminateMsg,PM_REMOVE);
  until Terminated;

  ShutDown;
end;

procedure TZmqClient.WndProc(var Msg:TMessage);
var
  CopyDataStruct : PCopyDataStruct;
  RxData         : PByte;
  RxPtr          : PByte;
  Size           : Integer;
  RxStr          : UTF8String;
begin
  if Msg.Msg=WM_COPYDATA then begin
    if Assigned(OnUpdate) then OnUpdate(Self);

// move the data into a buffer and process it
    if Enabled then begin
      CopyDataStruct:=PCopyDataStruct(Msg.LParam);
      Size:=CopyDataStruct^.cbData;
      SetLength(RxStr,Size);
      Move(CopyDataStruct^.lpData^,RxStr[1],Size);

      if Assigned(OnRxReply) then OnRxReply(Self,RxStr);
    end;
  end
  else if Msg.Msg=ConnectedMsg then Connected:=True
  else with Msg do begin
    Result:=DefWindowProc(WinHandle,Msg,wParam,lParam);
  end;
end;

procedure TZmqClient.TxStream(Stream:TMemoryStream);
var
  CopyDataStruct : TCopyDataStruct;
begin
  Stream.Position:=1;
  CopyDataStruct.lpData:=Stream.Memory;
  CopyDataStruct.cbData:=Stream.Size;
  PostThreadMessage(ThreadHandle,WM_COPYDATA,NativeUInt(@CopyDataStruct),0);
end;

end.

