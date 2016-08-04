unit ZmqServerU;

//https://github.com/bvarga/delphizmq x

interface

uses
  Zmq, Windows, Messages, Forms, SysUtils, Classes, Graphics, Controls, Dialogs,
  Protocol, CameraU, Global;

const
  StartMsg        = WM_USER+1;
  TerminateMsg    = WM_USER+2;
  DataRxMsg       = WM_USER+3;
  ConnectedMsg    = WM_USER+4;
  DisconnectedMsg = WM_USER+5;

type
  TOnRxStr = procedure(Sender:TObject;RxStr:AnsiString) of Object;

  TZmqServer = class(TObject)
  private
    Socket    : Pointer;
    Responder : Pointer;

    WinHandle : THandle;

    ThreadID     : DWord;
    ThreadHandle : THandle;
    CS           : TRTLCriticalSection;

    FOnRxStr      : TOnRxStr;
    FOnRxData     : TNotifyEvent;
    FOnConnect    : TNotifyEvent;
    FOnDisconnect : TNotifyEvent;

    FOnRxSetupData  : TNotifyEvent;
    FOnRxSeasonData : TNotifyEvent;
    FOnRxUpdateData : TNotifyEvent;
    FOnRenderModeRx : TNotifyEvent;

    FOnCalSettingsChanged : TNotifyEvent;

    procedure RunLoop;
    procedure StartUp;
    procedure ShutDown;
    procedure WndProc(var Msg:TMessage);
    procedure ProcessRxData;
    procedure ProcessSetupData(var SetupData:TSetupData);
    procedure ProcessUpdateData(var UpdateData: TUpdateData);
    procedure ProcessSpotData(var SpotData:TSpotData);
    procedure ProcessCountDownData(var CountDownData: TCountDownData);
    procedure ResetRotation(const UpdateData: TUpdateData);
    procedure TweakRotation(var NewRot: TRotationLayerArray);
    procedure ResetCurrentV;

  public
    Context : Pointer;
    RxData  : array of Byte;

    Connected : Boolean;

    property OnRxStr : TOnRxStr read FOnRxStr write FOnRxStr;
    property OnRxData : TNotifyEvent read FOnRxData write FOnRxData;

    property OnRxSetupData  : TNotifyEvent read FOnRxSetupData write FOnRxSetupData;
    property OnRxSeasonData : TNotifyEvent read FOnRxSeasonData write FOnRxSeasonData;
    property OnRxUpdateData : TNotifyEvent read FOnRxUpdateData write FOnRxUpdateData;
    property OnRenderModeRx : TNotifyEvent read FOnRxUpdateData write FOnRxUpdateData;

    property OnConnect : TNotifyEvent read FOnConnect write FOnConnect;
    property OnDisconnect : TNotifyEvent read FOnDisconnect write FOnDisconnect;

    constructor Create;
    destructor  Destroy; override;

    procedure PrepareForShow;
    procedure SyncClients;

    procedure StartThread;
    procedure StopThread;

    function VersionStr:String;
  end;

var
  ZmqServer : TZmqServer;

implementation

uses
  ProjectorU, ShowU, SeasonU, MP3PlayerU, ReactDiffuseU, Main,
  FountainU;

function ThreadEntryRoutine(Info:Pointer):Integer; stdcall;
var
  Zmq : TZmqServer;
begin
// enter our tracking loop
  Zmq:=TZmqServer(Info);
  Zmq.RunLoop;

  Result:=0;
end;

constructor TZmqServer.Create;
begin
  inherited;

  FOnRxStr:=nil;
  FOnRxData:=nil;
  FOnConnect:=nil;
  FOnDisconnect:=nil;

  FOnRxSetupData:=nil;
  FOnRxSeasonData:=nil;
  FOnRxUpdateData:=nil;

  FOnRenderModeRx:=nil;

  Connected:=False;

  FillChar(CalSettings.ShowProjector,SizeOf(CalSettings.ShowProjector),True);
  CalSettings.ShowRadialFade:=False;
  CalSettings.ShowXYFade:=False;

  InitializeCriticalSection(CS);

  WinHandle:=AllocateHWnd(WndProc);
end;

destructor TZmqServer.Destroy;
begin
  DeleteCriticalSection(CS);
  DeAllocateHWnd(WinHandle);

  inherited;
end;

function TZmqServer.VersionStr:String;
var
  Major : Integer;
  Minor : Integer;
  Patch : Integer;
begin
  Zmq_Version(Major,Minor,Patch);
  Result:=IntToStr(Major)+'.'+IntToStr(Minor)+'.'+IntToStr(Patch);
end;

procedure TZmqServer.PrepareForShow;
begin
  StartThread;
end;

procedure TZmqServer.StartUp;
var
  RC  : Integer;
  Txt : AnsiString;
begin
// create a context
//  Context:=zmq_ctx_new;
  Context:=zmq_init(1);

// create a responder to respond to the clients
  Responder:=zmq_socket(Context,ZMQ_REP); // rep

//RC:=Zmq_Bind(Responder,'tcp://*:4444');
  RC:=zmq_bind(Responder,'tcp://*:5000');

  Assert(RC=0,'');
end;

procedure TZmqServer.ShutDown;
begin
  StopThread;
end;

procedure TZmqServer.SyncClients;
var
//  Msg : TZmqMsgT;
  Size : Integer;
  RxStr : AnsiString;
const
  WelcomeMsg : String[8] = 'Welcome'+#0;
begin
//  Zmq_Msg_Init(Msg);

  Size:=32;
  SetLength(RxStr,Size);
  if Zmq_Recv(Responder,RxStr[1],Size,0)>0 then begin
    if Assigned(FOnRxStr) then FOnRxStr(Self,RxStr);
    Size:=Length(WelcomeMsg);
    Zmq_Send(Responder,WelcomeMsg[1],Size,0);
  end;
end;

procedure TZmqServer.StartThread;
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

procedure TZmqServer.StopThread;
begin
  PostThreadMessage(ThreadID,TerminateMsg,1,0);

// wait for it to die
//  WaitForSingleObject(ThreadHandle,3000);
end;

procedure TZmqServer.ProcessRxData;
begin

end;

procedure TZmqServer.ProcessSetupData(var SetupData:TSetupData);
var
  I : Integer;
begin
  Projectors:=SetupData.Projectors;
  for I:=1 to MaxProjectors do begin
    Projector[I].InitFromSetupData(SetupData.Projector[I]);
  end;
  Camera.Enabled:=SetupData.UseCamera;

  if (not RunShow) and (SetupData.RunShow) then MainFrm.TakeOverShow;
  RunShow:=SetupData.RunShow;

  VError:=SetupData.VError;
  RotationEnabled:=SetupData.RotationEnabled;
  RotationScale:=SetupData.RotationScale;
end;

procedure TZmqServer.ProcessSpotData(var SpotData:TSpotData);
var
  I : Integer;
begin
  for I:=1 to ParticleLayers do begin
    FountainSpot:=SpotData.Spot;
  end;
end;

procedure TZmqServer.ResetRotation(const UpdateData:TUpdateData);
var
  L : Integer;
begin
// reset the positions
  CurrentPos:=UpdateData.Rotation;
  ResetCurrentV;
  LastRotateTime:=GetTickCount;
end;

procedure TZmqServer.ResetCurrentV;
var
  L : Integer;
begin
  for L:=1 to MaxLayers do begin
    with CurrentV[L] do begin
      CubeMapV:=CurrentSeason.CubeMap[L].RotateV;//*RotationScale;
      ImageV:=CurrentSeason.Image[L].RotateV;//*RotationScale;
      RdV:=CurrentSeason.ReactDiffusion[L].RotateV;//*RotationScale;
      PerlinV:=CurrentSeason.PerlinSettings[L].RotateV;//*RotationScale;
      ParticleV:=CurrentSeason.Particle[L].RotateV;//*RotationScale;
    end;
  end;
end;

procedure TZmqServer.TweakRotation(var NewRot:TRotationLayerArray);
var
  L     : Integer;
  Error : Single;
begin
  for L:=1 to MaxLayers do with CurrentV[L] do begin

// cube map
    Error:=NewRot[L].CubeMapRz-CurrentPos[L].CubeMapRz;
    CubeMapV:=CubeMapV+Error*VError.Rz;

// image
    Error:=NewRot[L].ImageOffset-CurrentPos[L].ImageOffset;
    ImageV:=ImageV+Error*VError.Offset;

// reaction diffusion
    Error:=NewRot[L].RdOffset-Rotation[L].RdOffset;
    RdV:=RdV+Error*VError.Offset;

// perlin
    Error:=NewRot[L].PerlinRz-Rotation[L].PerlinRz;
    PerlinV:=PerlinV+Error*VError.Rz;

// particles
    Error:=NewRot[L].ParticleRz-Rotation[L].ParticleRz;
    ParticleV:=ParticleV+Error*VError.Rz;
  end;
end;

procedure TZmqServer.ProcessUpdateData(var UpdateData:TUpdateData);
var
  I,T,P : Integer;
begin
// see if the season needs to be changed
  if UpdateData.SeasonI<>ActiveSeason then begin
    ActiveSeason:=UpdateData.SeasonI;
    CurrentSeason.CopyFromSeason(Season[ActiveSeason]);
    ResetRotation(UpdateData);
    for P:=1 to Projectors do for I:=1 to RDLayers do begin
      Projector[P].ReactDiffuse[I].MakeRandom:=True;
    end;

    for P:=1 to Projectors do for I:=1 to ParticleLayers do begin
      Case Projector[P].Orbit of
        soEquatorial : Projector[P].Fountain[I].PlaceSpots;
        soPolar      : Projector[P].Fountain[I].PlacePolarSpots;
      end;
    end;

    MP3Player.SetVolume(CurrentSeason.MP3.Volume);
    MP3Player.PlayMP3Number(CurrentSeason.MP3.Index);
  end;

// rotation
  TweakRotation(UpdateData.Rotation);

// season settings
  CurrentSeason.ApplyUpdateData(UpdateData);

// touches
 { for I:=1 to Projectors do if Projector[I].ShowLayer[2] then begin
    Projector[I].ReactDiffuse[2].CamTouch:=UpdateData.CamTouch;
    for T:=1 to MaxTouches do begin
      Projector[I].ReactDiffuse[2].Touch[T].Active:=UpdateData.PsRD.TouchUpdated[T];
      Projector[I].ReactDiffuse[2].Touch[T].X:=UpdateData.PsRD.TouchX[T];
      Projector[I].ReactDiffuse[2].Touch[T].Y:=UpdateData.PsRD.TouchY[T];

      Projector[I].Fountain[2].Touch[T].Active:=True;
      Projector[I].Fountain[2].Touch[T].X:=UpdateData.PsParticle.X[T];
      Projector[I].Fountain[2].Touch[T].Y:=UpdateData.PsParticle.Y[T];
    end;
  end;   }
end;

procedure TZmqServer.ProcessCountDownData(var CountDownData:TCountDownData);
begin
  CountDownIndex:=CountDownData.Index;
  if CountDownIndex=0 then SetRunMode(rmRun)
  else SetRunMode(rmCountDown);
end;

procedure TZmqServer.WndProc(var Msg:TMessage);
var
  DataPtr       : PByte;
  Size          : Integer;
  SetupData     : PSetupData;
  SeasonData    : PSeasonData;
  RunModeMsg    : PRunModeMsg;
  RenderModeMsg : PRenderModeMsg;
  UpdateData    : PUpdateData;
  SpotData      : PSpotData;
  CountDownData : PCountDownData;
  SetupSize     : Integer;
begin
  if Msg.Msg=DataRxMsg then begin
//Size:=SizeOf(TSetupData);

    DataPtr:=PByte(Msg.WParam);
    Size:=Msg.LParam;

    Case DataPtr^ of
      CONNECT_MSG :
        if Size=1 then begin
          Connected:=True;
          if Assigned(FOnConnect) then FOnConnect(Self);
        end;

// master is sending us our setup data
      SETUP_DATA_MSG :
        begin
          SetupSize:=SizeOf(TSetupData);
          if Size=SetupSize then begin
            SetupData:=PSetupData(Msg.WParam);
            ProcessSetupData(SetupData^);
            if Assigned(FOnRxSetupData) then FOnRxSetupData(Self);
          end;
        end;

// master is sending us our season data
      SEASON_DATA_MSG :
        if Size=SizeOf(TSeasonData) then begin
          SeasonData:=PSeasonData(DataPtr);
          ProcessSeasonData(SeasonData^);
          ResetCurrentV;
          if Assigned(FOnRxSeasonData) then FOnRxSeasonData(Self);
        end;

// master is setting the run mode
      RUN_MODE_MSG :
        if Size=SizeOf(TRunModeMsg) then begin
          RunModeMsg:=PRunModeMsg(DataPtr);
          SetRunMode(RunModeMsg^.Mode);
        end;

// master is setting the run mode
      RENDER_MODE_MSG :
        if Size=SizeOf(TRenderModeMsg) then begin
          RenderModeMsg:=PRenderModeMsg(DataPtr);
          RenderPlacement:=RenderModeMsg^.Placement;
          RenderMode:=RenderModeMsg^.Mode;
          if Assigned(FOnRenderModeRx) then FOnRenderModeRx(Self);
        end;

// master is sending update data
      UPDATE_DATA_MSG :
        if Size=SizeOf(TUpdateData) then begin
          UpdateData:=PUpdateData(DataPtr);
          ProcessUpdateData(UpdateData^);
        end;

// sun spot data
      SPOT_DATA_MSG :
        if Size=SizeOf(TSpotData) then begin
          SpotData:=PSpotData(DataPtr);
          ProcessSpotData(SpotData^);
        end;

      COUNT_DOWN_MSG :
        if Size=SizeOf(TCountDownData) then begin
          CountDownData:=PCountDownData(DataPtr);
          ProcessCountDownData(CountDownData^);
        end;

      HALT_CMD : Application.Terminate;

      CAL_SETTINGS_MSG :
        if Size=SizeOf(CalSettings) then begin
          Move(DataPtr^,CalSettings,SizeOf(CalSettings));
          if Assigned(FOnCalSettingsChanged) then FOnCalSettingsChanged(Self);
        end;
    end;

    if (not Connected) and (DataPtr^ in [UPDATE_DATA_MSG..SEASON_DATA_MSG]) then
    begin
      Connected:=True;
      if Assigned(FOnConnect) then FOnConnect(Self);
    end;

// free the memory which was allocated in the thread's RunLoop
    FreeMem(DataPtr);

    if Assigned(FOnRxData) then FOnRxData(Self);
    Msg.Result:=0;
  end
  else with Msg do begin
    Result:=DefWindowProc(WinHandle,Msg,wParam,lParam);
  end;
end;

procedure TZmqServer.RunLoop;
var
  Data           : PByte;
  RxData         : array of Byte;
  Size,RC        : Integer;
  Msg            : TMsg;
  Terminated     : Boolean;
  ZmqMsg         : ZMQ_MSG_T;
  MaxSize        : Integer;
begin
  Size:=SizeOf(TSeasonData);

  StartUp;

// create the message queue
  GetMessage(Msg,0,0,0);

  MaxSize:=SizeOf(TSetupData)*2+SizeOf(TSeasonData);
  SetLength(RxData,MaxSize);

// run until we are told to quit
  repeat

// read from the client
    Size:=zmq_recv(Responder,RxData[0],MaxSize,0);

// tell it ok
    zmq_send(Responder,'OK',2,0);

// send the received data to our main thread
    GetMem(Data,Size);
    Move(RxData[0],Data^,Size);
    SendMessage(WinHandle,DataRxMsg,NativeUInt(Data),Size);

    Terminated:=PeekMessage(Msg,0,TerminateMsg,TerminateMsg,PM_REMOVE);
  until Terminated;

  ShutDown;
end;

end.

   while (1) {
        char buffer [10];
        zmq_recv (responder, buffer, 10, 0);
        printf ("Received Hello\n");
        zmq_send (responder, "World", 5, 0);
        sleep (1);          //  Do some 'work'
    }
    return 0;
}


