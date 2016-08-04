program SeSlave;

uses
  Forms,
  Main in 'Main.pas' {MainFrm},
  SeasonSetupFrmU in 'SeasonSetupFrmU.pas' {SeasonSetupFrm},
  ZmqServerU in 'ZmqServerU.pas',
  Global in 'Global.pas',
  SphereU in 'SphereU.pas',
  GLSceneU in 'GLSceneU.pas',
  SeasonU in 'SeasonU.pas',
  Protocol in 'Protocol.pas',
  Routines in 'Routines.pas',
  Settings in 'Settings.pas',
  ProjectorFrmU in 'ProjectorFrmU.pas' {ProjectorFrm},
  ProjectorU in 'ProjectorU.pas',
  ShowU in 'ShowU.pas',
  MP3PlayerU in 'MP3PlayerU.pas',
  SetupFrmU in 'SetupFrmU.pas' {SetupFrm},
  GLDraw in 'GLDraw.pas',
  FountainU in 'FountainU.pas',
  RDColorU in 'RDColorU.pas',
  PerlinU in 'PerlinU.pas',
  ShaderU in 'ShaderU.pas',
  TextureU in 'TextureU.pas',
  CameraU in 'CameraU.pas',
  TrackerU in 'TrackerU.pas',
  TrackingSetupFrmU in 'TrackingSetupFrmU.pas',
  CamSettingsFrmU in 'CamSettingsFrmU.pas',
  MaskFrmU in 'MaskFrmU.pas',
  ReactDiffuseU in 'ReactDiffuseU.pas',
  ZmqClientU in 'ZmqClientU.pas',
  BlobFinderU in 'BlobFinderU.pas',
  ShowControllerU in 'ShowControllerU.pas',
  PeerU in 'PeerU.pas',
  PeersFrmU in 'PeersFrmU.pas' {PeersFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;
end.
