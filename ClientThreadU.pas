unit ClientThreadU;

// a client thread is created by the server anytime a new client connects

interface

uses
  Windows, Messages, Controls, IdGlobal, WinSock;

var
  X1,X2 : Integer;

const
  MaxRxSize = 9000;

  Port = 7000;

  CallBackMsg     = WM_USER+1;
  DoneCallBackMsg = WM_User+1;

type
  TClientThread = class(TObject)
  private
    SocketHandle : THandle;
    UpdatePeriod : Integer; // ms

// priority property routines
    procedure SetPriority(NewPriority : integer);
    function  GetPriority : integer;
    function  AbleToPollRx: Boolean;

  public
    Tag          : Integer;
    ThreadID     : DWord;
    ThreadHandle : Integer;
    Stopped      : Boolean;
    CS           : TRTLCriticalSection;

    constructor Create(iTag,iHandle:Integer);
    destructor  Destroy; override;

    property Priority : integer read GetPriority write SetPriority;

// public routines
    procedure Start;
    procedure Stop;
    procedure RunLoop;
    procedure TxBytes(Data:TBytes);
    procedure TxData(Data:PByte;Size:Integer);
  end;

var
  Thread : TClientThread;

implementation

uses
  MMSystem, Dialogs, Forms, Math, SysUtils, TcpServerU, JpgTransceiverU;

function ThreadEntryRoutine(Info:Pointer):Integer; stdcall;
var
  Thd : TClientThread;
begin
// enter our tracking loop
  Thd:=TClientThread(Info);
  Thd.RunLoop;
end;

constructor TClientThread.Create(iTag,iHandle:Integer);
begin
  inherited Create;
  Tag:=iTag;
  SocketHandle:=iHandle;

  Stopped:=True;
  InitializeCriticalSection(CS);
  UpdatePeriod:=40; // 25x per second
  Start;
end;

destructor TClientThread.Destroy;
var
  Msg : TMsg;
begin
  if not Stopped then Stop;

// clear any pending messages
//  PeekMessage(Msg,Handle,CallBackMsg,CallBackMsg,PM_REMOVE);

  DeleteCriticalSection(CS);
end;

procedure TClientThread.SetPriority(NewPriority:Integer);
begin
// THREAD_PRIORITY_TIMECRITICAL   - causes other threads to starve
// THREAD_PRIORITY_HIGHEST        - +2     4.2-4.3
// THREAD_PRIORITY_ABOVE_NORMAL   - +1     4.2-4.3
// THREAD_PRIORITY_NORMAL         -  0     4.2-4.6
// THREAD_PRIORITY_BELOW_NORMAL   - -1
// THREAD_PRIORITY_LOWEST         - -2
//  SetThreadPriority(Handle,NewPriority);
end;

function TClientThread.GetPriority : integer;
begin
  Result:=GetThreadPriority(ThreadHandle);
end;

procedure TClientThread.Start;
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

procedure TClientThread.Stop;
begin
  if ThreadHandle<>-1 then begin
    PostThreadMessage(ThreadID,TerminateMsg,1,0);

// wait for it to die
    WaitForSingleObject(ThreadHandle,3000);

// free the handle
    CloseHandle(ThreadHandle);
  end;
end;

function TClientThread.AbleToPollRx:Boolean;
var
  ReadFDS : TFDSET;
  Error   : Integer;
  Cmd     : Byte;
  Size    : Word;
  TimeOut : TimeVal;
begin
  Result:=False;

  FillChar(TimeOut,SizeOf(TimeOut),0);

  FD_ZERO(ReadFDS);
  FD_SET(SocketHandle,ReadFDS);

  Error:=Select(SocketHandle+1,@ReadFDS,nil,nil,@TimeOut);
  if Error=SOCKET_ERROR then begin
    Exit;
  end;

  Result:=True;

// see if anybody is there
  if FD_ISSET(SocketHandle,ReadFDS) then begin

// read the data
    EnterCriticalSection(CS);
      with Server.Client[Tag] do begin
        RxSize:=WinSock.Recv(SocketHandle,RxData[1],MaxRxSize,0);

        if RxSize>0 then begin

// see if this is a texture
          Cmd:=RxData[1]; // 1:Cmd 2:ID 3:PacketI 4,5:Size
          if Cmd in [TextureMsg,TextureEndMsg] then begin

// determine the size of the sent data
            Move(RxData[4],Size,SizeOf(Size));

// if we never got it all wait for the rest
            if RxSize<Size then begin
              Size:=WinSock.Recv(SocketHandle,RxData[1+RxSize],MaxRxSize,0);
              RxSize:=RxSize+Size;
            end;
          end;
          Server.Client[Tag].ProcessRxData;
        end

// zero bytes means they've disconnected
        else Result:=False;
      end;
    LeaveCriticalSection(CS);

// tell the server we have new data
    if Result then begin
      PostMessage(Server.WinHandle,DataRxMsg,Tag,0);
    end;
  end;
end;

procedure TClientThread.RunLoop;
var
  Msg          : TMsg;
  Time,Elapsed : DWord;
  PollOk       : Boolean;
  TxData       : PByte;
  TxSize       : Integer;
  Terminated   : Boolean;
begin
// create the message queue
  GetMessage(Msg,0,0,0);
  PollOk:=True;
  Terminated:=False;

// we'll sit in this loop until the thread is terminated
  repeat
//    Time:=GetTickCount;

// see if we need to send anything
    if PeekMessage(Msg,0,TxDataMsg,TxDataMsg,PM_REMOVE) then begin
      TxData:=PByte(Msg.WParam);
      TxSize:=Msg.LParam;
      WinSock.Send(SocketHandle,TxData^,TxSize,0);
      FreeMem(TxData);
    end;

// see if the client has sent anything
    if AbleToPollRx then begin

// sleep if we're running too fast
//      Elapsed:=GetTickCount-Time;
//      if Elapsed<UpdatePeriod then Sleep(UpdatePeriod-Elapsed);
      if PeekMessage(Msg,0,TerminateMsg,TerminateMsg,PM_REMOVE) then begin
        Terminated:=True;
      end;
    end
    else begin
      Terminated:=True;
    end;

    if not Terminated then Sleep(20);

// wait until the main thread signals to us that it's ready
  until Terminated;

// clean up any remaining data packets
  while PeekMessage(Msg,0,TxDataMsg,TxDataMsg,PM_REMOVE) do begin
    TxData:=PByte(Msg.WParam);
    FreeMem(TxData);
  end;

  PostMessage(Server.WinHandle,DisconnectedMsg,Tag,0);
  Stopped:=True;
end;

procedure TClientThread.TxData(Data:PByte;Size:Integer);
var
  DataCopy : PByte;
begin
// make a copy of the data
  GetMem(DataCopy,Size);
  Move(Data^,DataCopy^,Size);

// give it to the thread - could use events instead - probably faster
  PostThreadMessage(ThreadID,TxDataMsg,Integer(DataCopy),Size);
end;

procedure TClientThread.TxBytes(Data:TBytes);
var
  Size : Integer;
begin
  Size:=Length(Data);
  TxData(@Data[0],Size);
end;

end.






