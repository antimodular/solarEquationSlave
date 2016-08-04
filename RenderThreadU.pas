unit RenderThreadU;

interface

uses
  Windows, Messages, Classes, Controls, OpenGL1x, StopWatchU;

// routine thread starts at
function  ThreadEntryRoutine(Info:Pointer):integer; stdcall;

var
  X1,X2 : integer;

const
  CallBackMsg     = WM_USER+1;
  DoneCallBackMsg = WM_USER+2;
  StopMsg         = WM_USER+3;

type
  TCallBackThread = class(TObject)
  private
    Period   : Single; //Int64; // us
    FOnStart : TNotifyEvent;
    FOnStop  : TNotifyEvent;

// priority property routines
    procedure SetPriority(NewPriority : integer);
    function  GetPriority : integer;
    procedure WMDoneCallBack(var Msg:TMessage); message DoneCallBackMsg;

  public
    ThreadID : DWord;
    Handle   : THandle;
    Freq     : Int64;

    constructor Create;
    destructor  Destroy; override;

    property Priority : integer read GetPriority write SetPriority;
    property OnStart : TNotifyEvent read FOnStart write FOnStart;
    property OnStop : TNotifyEvent read FOnStop write FOnStop;

// public routines
    procedure Start(iPeriod:Single);
    procedure Stop;
    procedure RunLoop;
  end;

var
  Thread : TCallBackThread;

implementation

uses
  MMSystem, Dialogs, Forms, Math, SysUtils, FaceTrackerU, GLSceneU, CollectorU,
  CameraU, Main;

function ThreadEntryRoutine(Info:Pointer):integer; stdcall;
begin
// enter our tracking loop
  Thread.RunLoop;
end;

constructor TCallBackThread.Create;
begin
  inherited Create;

  FOnStart:=nil;
  FOnStop:=nil;

  Handle:=0;
  QueryPerformanceFrequency(Freq);
end;

destructor TCallBackThread.Destroy;
begin
  if Handle>0 then Stop;
end;

procedure TCallBackThread.SetPriority(NewPriority:Integer);
begin
// THREAD_PRIORITY_TIMECRITICAL   - causes other threads to starve
// THREAD_PRIORITY_HIGHEST        - +2     
// THREAD_PRIORITY_ABOVE_NORMAL   - +1     
// THREAD_PRIORITY_NORMAL         -  0
// THREAD_PRIORITY_BELOW_NORMAL   - -1
// THREAD_PRIORITY_LOWEST         - -2
  SetThreadPriority(Handle,NewPriority);
end;

function TCallBackThread.GetPriority : integer;
begin
  Result:=GetThreadPriority(Handle);
end;

procedure TCallBackThread.Start(iPeriod:Single);
begin
  Period:=iPeriod;

// create the thread
  Handle:=CreateThread(nil,0,@ThreadEntryRoutine,nil,0,ThreadID);
  if Handle=0 then ShowMessage('Unable to create thread!')
  else begin

// normal priority is ok
    Priority:=THREAD_PRIORITY_NORMAL;

// force feed it messages until we succeed - see Win32.Hlp
    repeat
      Application.ProcessMessages;
    until PostThreadMessage(ThreadID,DoneCallBackMsg,0,0);
  end;
end;

procedure TCallBackThread.Stop;
begin
  PostThreadMessage(ThreadID,StopMsg,1,0);

// wait for it to die
  WaitForSingleObject(Handle,INFINITE);

// free the handle
  CloseHandle(Handle);

  Handle:=0;
end;

procedure TCallBackThread.RunLoop;
var
  Msg      : TMsg;
  Stopped  : Boolean;
  Start    : Int64;
  Stop     : Int64;
  Elapsed  : Single;
  WaitTime : DWord;
begin
  if Assigned(FOnStart) then FOnStart(Self);

  Stopped:=False;

// create the message queue
  GetMessage(Msg,0,0,0);

// we'll sit in this loop until the thread is terminated
  repeat
    StopWatch.Start(1);

    QueryPerformanceCounter(Start);

// protect the image data we share with the camera thread and the facetracker
// data we share with the main thread

// the render routine uses the ImageData for texturing and the facetracker
// data for updating the GL shading
//    EnterCriticalSection(Camera.CS);
      GLScene.Render2;
//    LeaveCriticalSection(Camera.CS);

    if PeekMessage(Msg,0,StopMsg,StopMsg,PM_REMOVE) then begin
      Stopped:=True;
    end
    else begin
      QueryPerformanceCounter(Stop);
      Elapsed:=(Stop-Start)/Freq;
      if Elapsed<Period then begin
        WaitTime:=Round((Period-Elapsed)*1000);
        if WaitTime>0 then Sleep(WaitTime);
      end;
    end;

    StopWatch.Stop(1);

  until Stopped;

  if Assigned(FOnStop) then FOnStop(Self);
end;

procedure TCallBackThread.WMDoneCallBack(var Msg:TMessage);
begin
end;

end.





