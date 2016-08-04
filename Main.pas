unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Math, StdCtrls,
  Buttons, AprChkBx, Vcl.ComCtrls;

type
  TMainFrm = class(TForm)
    CameraBtn: TBitBtn;
    RunBtn: TBitBtn;
    Panel1: TPanel;
    SetupDataRxCB: TAprCheckBox;
    SeasonDataRxCB: TAprCheckBox;
    ConnectionTxt: TStaticText;
    SeasonsBtn: TBitBtn;
    PaintBox: TPaintBox;
    SetupBtn: TBitBtn;
    TrackingBtn: TBitBtn;
    DelayTimer: TTimer;
    StatusBar: TStatusBar;
    Label1: TLabel;
    Timer: TTimer;
    Panel2: TPanel;
    Label2: TLabel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    PeersBtn: TBitBtn;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SetupBtnClick(Sender: TObject);
    procedure RunBtnClick(Sender: TObject);
    procedure SeasonsBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CameraBtnClick(Sender: TObject);
    procedure TrackingBtnClick(Sender: TObject);
    procedure DelayTimerTimer(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure PeersBtnClick(Sender: TObject);

  private
    procedure ZmqServerRxData(Sender:TObject);
    procedure ShowConnectionStatus;

    procedure ZmqServerConnected(Sender:TObject);
    procedure ZmqServerRxSetupData(Sender:TObject);
    procedure ZmqServerRxSeasonData(Sender:TObject);
    procedure ZmqServerRxUpdateData(Sender:TObject);
    procedure ZmqServerRenderModeRx(Sender:TObject);

    procedure NewCameraFrame(Sender:TObject);


  public
     procedure TakeOverShow;
  end;

var
  MainFrm: TMainFrm;

implementation

{$R *.dfm}

uses
  ZmqServerU, SeasonU, SetupFrmU, Global, Routines, TextureU,
  CubeMapU, ProjectorU, MP3PlayerU,
  ProjectorFrmU, SeasonSetupFrmU, ShowU, Settings, CameraU, TrackingSetupFrmU,
  BlobFinderU, TrackerU, ShowControllerU, PeersFrmU, PeerU;

procedure TMainFrm.CameraBtnClick(Sender: TObject);
begin
  Camera.ShowSettingsFrm;
  SaveSettings;
end;

procedure TMainFrm.DelayTimerTimer(Sender: TObject);
begin
  DelayTimer.Enabled:=False;
  Camera.UseFirstDevice;
  if Camera.Found then Camera.Start
  else Camera.StartThread;

  ShowProjectorFrms;

  if RunShow then TakeOverShow;
end;

procedure TMainFrm.TakeOverShow;
var
  P : Integer;
begin
  RunMode:=rmRun;
  for P:=1 to Peers do Peer[P].Connect;
  Timer.Enabled:=True;
end;

procedure TMainFrm.FormCreate(Sender: TObject);
var
  I : Integer;
begin
  Caption:=VersionStr;
  StatusBar.SimpleText:='This computer''s IP: '+GetIPAddress;
  
  RenderMode:=rmTextured;

  for I:=1 to MaxProjectors do begin
    Projector[I]:=TProjector.Create(I);
  end;

  MP3Player:=TMP3Player.Create;

  CubeMap:=TCubeMap.Create;

  ZmqServer:=TZmqServer.Create;

  for I:=1 to MaxSeasons do begin
    Season[I]:=TSeason.Create;
    Season[I].SetToDefault;
  end;
  CurrentSeason:=TSeason.Create;

  Camera:=TCamera.Create;
  Camera.OnNewFrame:=NewCameraFrame;

  BlobFinder:=TBlobFinder.Create;
  Tracker:=TTracker.Create;

  ShowController:=TShowController.Create;
  CreatePeers;

//  SetAllToDefault;  SaveSettings;
  LoadSettings;

  CurrentSeason.CopyFromSeason(Season[1]);
  ActiveSeason:=1;

  CreateTextures;
  LoadTextures;

  ZmqServer.OnConnect:=ZmqServerConnected;
  ZmqServer.OnRxData:=ZmqServerRxData;
  ZmqServer.OnRxSetupData:=ZmqServerRxSetupData;
  ZmqServer.OnRxSeasonData:=ZmqServerRxSeasonData;
  ZmqServer.OnRxUpdateData:=ZmqServerRxUpdateData;
  ZmqServer.OnRenderModeRx:=ZmqServerRenderModeRx;

  ZmqServer.StartThread;

  DelayTimer.Enabled:=True;
end;

procedure TMainFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Camera.ShutDown;
  ZmqServer.StopThread;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
var
  I : Integer;
begin
  if SetupDataRxCB.Checked and SeasonDataRxCB.Checked then SaveSettings;

  if Assigned(Camera) then Camera.Free;
  if Assigned(BlobFinder) then BlobFinder.Free;
  if Assigned(Tracker) then Tracker.Free;

  if Assigned(ShowController) then ShowController.Free;
  FreePeers;

  if Assigned(MP3Player) then MP3Player.Free;

  if Assigned(ZmqServer) then ZmqServer.Free;
  for I:=1 to MaxSeasons do if Assigned(Season[I]) then Season[I].Free;

  FreeTextures;
  if Assigned(CubeMap) then CubeMap.Free;
end;

procedure TMainFrm.NewCameraFrame(Sender: TObject);
begin
  Case RunMode of
    rmIdle : if Visible then PaintBox.Canvas.Draw(0,0,Camera.Bmp);
    rmSetup : ;
    rmRun   : UpdateTracking;
  end;
  if Visible and (RunMode=rmIdle) then PaintBox.Canvas.Draw(0,0,Camera.Bmp);
end;

procedure TMainFrm.PeersBtnClick(Sender: TObject);
begin
  PeersFrm:=TPeersFrm.Create(Application);
  try
    PeersFrm.Initialize;
    PeersFrm.ShowModal;
  finally
    PeersFrm.Free;
  end;
end;

procedure TMainFrm.ShowConnectionStatus;
const
  ConnectedColor    : TColor = $00ADEFB0;
  DisconnectedColor : TColor = $009F9FFF;
begin
  if ZmqServer.Connected then begin
    ConnectionTxt.Color:=ConnectedColor;
    ConnectionTxt.Caption:='Connected';
  end
  else begin
    ConnectionTxt.Color:=DisconnectedColor;
    ConnectionTxt.Caption:='Disonnected';
  end;
end;

procedure TMainFrm.TimerTimer(Sender: TObject);
begin
  ShowController.UpdateShow;
//  UpdateT
//  Camera.Smooth
//
end;

procedure TMainFrm.TrackingBtnClick(Sender: TObject);
begin
  TrackingSetupFrm:=TTrackingSetupFrm.Create(Application);
  try
    TrackingSetupFrm.Initialize;
    TrackingSetupFrm.ShowModal;
  finally
    TrackingSetupFrm.Free;
  end;
  SaveSettings;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMainFrm.ZmqServerConnected(Sender:TObject);
begin
  ShowConnectionStatus;
end;

procedure TMainFrm.ZmqServerRxData(Sender:TObject);
begin
end;

procedure TMainFrm.ZmqServerRxSetupData(Sender:TObject);
begin
  SetupDataRxCB.Checked:=True;
  if SetupFrmCreated then SetupFrm.SyncSetupData;
  PositionProjectorFrms;
end;

procedure TMainFrm.ZmqServerRxSeasonData(Sender:TObject);
begin
  SeasonDataRxCB.Checked:=True;
  if SeasonSetupFrmCreated then SeasonSetupFrm.SyncSeasonData;

// reload if we are running
  if RunMode=rmRun then begin
    CurrentSeason.CopyFromSeason(Season[ActiveSeason]);
  end;
end;

procedure TMainFrm.ZmqServerRxUpdateData(Sender:TObject);
begin
  if SeasonSetupFrmCreated then SeasonSetupFrm.SyncUpdateData;
end;

procedure TMainFrm.ZmqServerRenderModeRx(Sender:TObject);
begin
  if SetupFrmCreated then SetupFrm.SyncRenderMode;
end;

procedure TMainFrm.SetupBtnClick(Sender: TObject);
begin
  ShowSetupFrm;
  SetRunMode(rmSetup);
end;

procedure TMainFrm.RunBtnClick(Sender: TObject);
begin
  SetRunMode(rmRun);
end;

procedure TMainFrm.SeasonsBtnClick(Sender: TObject);
begin
  ShowSeasonSetupFrm;
  SetRunMode(rmRun);
end;

end.
