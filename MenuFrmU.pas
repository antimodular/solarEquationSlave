unit MenuFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ThreadU, StopWatchU, ComCtrls, ExtCtrls,
  AprSpin, AprChkBx;

type
  TMenuFrm = class(TForm)
    SetupBtn: TBitBtn;
    ExitBtn: TBitBtn;
    CameraBtn: TBitBtn;
    ViewTrackingBtn: TBitBtn;
    CalibrateBtn: TBitBtn;
    MouseTestBtn: TBitBtn;
    StatusBar: TStatusBar;
    FountainBtn: TBitBtn;
    ShowRG: TRadioGroup;
    ResetBtn: TBitBtn;
    DrawObstaclesCB: TAprCheckBox;
    DrawSourcesCB: TAprCheckBox;
    PoemsBtn: TBitBtn;
    NextStepBtn: TButton;
    AprSpinEdit1: TAprSpinEdit;
    AprSpinEdit2: TAprSpinEdit;
    ObstaclesBtn: TBitBtn;
    procedure SetupBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure CameraBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ViewTrackingBtnClick(Sender: TObject);
    procedure CalibrateBtnClick(Sender: TObject);
    procedure MouseTestBtnClick(Sender: TObject);
    procedure ProjectorMaskBtnClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FountainBtnClick(Sender: TObject);
    procedure WatchBmpBtnClick(Sender: TObject);
    procedure SaveBmpBtnClick(Sender: TObject);
    procedure ShowRGClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure NextStepBtnClick(Sender: TObject);
    procedure DrawObstaclesCBClick(Sender: TObject);
    procedure DrawSourcesCBClick(Sender: TObject);
    procedure PoemsBtnClick(Sender: TObject);
    procedure AprSpinEdit1Change(Sender: TObject);
    procedure AprSpinEdit2Change(Sender: TObject);
    procedure ObstaclesBtnClick(Sender: TObject);

  private

  public
    procedure Initialize;

  end;

var
  MenuFrm: TMenuFrm;

implementation

uses
  SetupFrmU, CameraU, Main, Global, TrackingSetupFrmU, CalibrateFrmU, CfgFile,
  MouseTestFrmU, CloudSetupFrmU, ProjectorMaskFrmU, TrackViewFrmU, AlphabetU,
  FountainFrmU, CloudU, BmpFrmU, FountainU, MouseTest2FrmU, PoemSetupFrmU,
  PoemU, PoemLoaderU, ObstaclesFrmU;

{$R *.dfm}

procedure TMenuFrm.FormCreate(Sender: TObject);
var
  L : Integer;
begin
  L:=Length(VersionStr);
  Caption:=Copy(VersionStr,L-4,5);
end;

procedure TMenuFrm.Initialize;
begin
  DrawSourcesCB.Checked:=(roSources in Cloud.RenderOptions);
  DrawObstaclesCB.Checked:=(roObstacles in Cloud.RenderOptions);
end;

procedure TMenuFrm.SetupBtnClick(Sender: TObject);
begin
  CloudSetupFrm:=TCloudSetupFrm.Create(Application);
  try
    CloudSetupFrm.Initialize;
    CloudSetupFrm.ShowModal;
  finally
    CloudSetupFrm.Free;
  end;
  SaveCfgFile;
end;

procedure TMenuFrm.ExitBtnClick(Sender: TObject);
begin
  SaveCfgFile;
  MainFrm.Close;
end;

procedure TMenuFrm.CameraBtnClick(Sender: TObject);
begin
  Camera.ShowSettingsFrm;
  SaveCfgFile;
end;

procedure TMenuFrm.DrawObstaclesCBClick(Sender: TObject);
begin
  if DrawObstaclesCB.Checked then begin
    Cloud.RenderOptions:=Cloud.RenderOptions+[roObstacles];
  end
  else Cloud.RenderOptions:=Cloud.RenderOptions-[roObstacles];
end;

procedure TMenuFrm.DrawSourcesCBClick(Sender: TObject);
begin
  if DrawSourcesCB.Checked then begin
    Cloud.RenderOptions:=Cloud.RenderOptions+[roSources];
  end
  else Cloud.RenderOptions:=Cloud.RenderOptions-[roSources];
end;

procedure TMenuFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  MainFrm.GLPanel.Cursor:=crNone;
//  TrackViewFrm.Cursor:=crNone;
  SaveCfgFile;
end;

procedure TMenuFrm.ViewTrackingBtnClick(Sender: TObject);
begin
  TrackingSetupFrm:=TTrackingSetupFrm.Create(Application);
  try
    TrackingSetupFrm.Initialize;
    TrackingSetupFrm.ShowModal;
  finally
    TrackingSetupFrm.Free;
  end;
  SaveCfgFile;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
end;

procedure TMenuFrm.CalibrateBtnClick(Sender: TObject);
begin
  CalibrateFrm:=TCalibrateFrm.Create(Application);
  try
    CalibrateFrm.Initialize;
    CalibrateFrm.ShowModal;
  finally
    CalibrateFrm.Free;
  end;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
  SaveCfgFile;
end;

procedure TMenuFrm.MouseTestBtnClick(Sender: TObject);
begin
  MouseTest2Frm:=TMouseTest2Frm.Create(Application);
  try
    MouseTest2Frm.Initialize;
    MouseTest2Frm.ShowModal;
  finally
    MouseTest2Frm.Free;
  end;
  Camera.OnNewFrame:=MainFrm.NewCameraFrame;
end;

procedure TMenuFrm.PoemsBtnClick(Sender: TObject);
begin
  if Poems=0 then begin
    ShowMessage('No poems were found');
    Exit;
  end;

  PoemSetupFrm:=TPoemSetupFrm.Create(Application);
  try
    PoemSetupFrm.Initialize;
    PoemSetupFrm.ShowModal;
  finally
    PoemSetupFrm.Free;
  end;
  SaveCfgFile;
end;

procedure TMenuFrm.ProjectorMaskBtnClick(Sender: TObject);
begin
  ProjectorMaskFrm:=TProjectorMaskFrm.Create(Application);
  try
    ProjectorMaskFrm.Initialize;
    ProjectorMaskFrm.ShowModal;
  finally
    ProjectorMaskFrm.Free;
  end;
  SaveCfgFile;
end;

procedure TMenuFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then Close;
end;

procedure TMenuFrm.FountainBtnClick(Sender: TObject);
begin
  FountainFrm:=TFountainFrm.Create(Application);
  try
    FountainFrm.Initialize;
    FountainFrm.ShowModal;
  finally
    FountainFrm.Free;
  end;
end;

procedure TMenuFrm.WatchBmpBtnClick(Sender: TObject);
begin
  if not Assigned(BmpFrm) then BmpFrm:=TBmpFrm.Create(Application);
  BmpFrm.Initialize;
  BmpFrm.Show;
end;

procedure TMenuFrm.SaveBmpBtnClick(Sender: TObject);
begin
  Cloud.Save:=True;
end;

procedure TMenuFrm.ShowRGClick(Sender: TObject);
begin
  Case ShowRG.ItemIndex of
    0 : Cloud.RenderMode:=rmVelocity;
    1 : Cloud.RenderMode:=rmTemperature;
    2 : Cloud.RenderMode:=rmPressure;
    3 : Cloud.RenderMode:=rmDensity;
  end;
end;

procedure TMenuFrm.ResetBtnClick(Sender: TObject);
begin
  Fountain.Reset:=True;
end;

procedure TMenuFrm.AprSpinEdit1Change(Sender: TObject);
begin
  ObstacleTextX:=Round(AprSpinEdit1.Value);
end;

procedure TMenuFrm.AprSpinEdit2Change(Sender: TObject);
begin
  ObstacleTextY:=Round(AprSpinEdit2.Value);
end;

procedure TMenuFrm.NextStepBtnClick(Sender: TObject);
begin
  PoemLoader.NextStep;
end;

procedure TMenuFrm.ObstaclesBtnClick(Sender: TObject);
begin
  ObstaclesFrm:=TObstaclesFrm.Create(Application);
  try
    ObstaclesFrm.Initialize;
    ObstaclesFrm.ShowModal;
  finally
    ObstaclesFrm.Free;
  end;
  SaveCfgFile;
end;

end.

procedure TMenuFrm.FadeTestCBClick(Sender: TObject);
begin
  Collector.Fade.Test:=FadeTestCB.Checked;
end;

procedure TMenuFrm.FadeSBChange(Sender: TObject);
begin
  Collector.Fade.Fraction:=FadeSB.Position/100;
end;

procedure TMenuFrm.Button1Click(Sender: TObject);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.Width:=800;
    Bmp.Height:=600;
    Bmp.PixelFormat:=pf24Bit;
    StopWatch.ShowHistory(Bmp,2,0,0,Bmp.Width,Bmp.Height,0.066);
    Bmp.SaveToFile('c:\Times.bmp');
  finally
    Bmp.Free;
  end;
end;

end.

KSPROPERTY_LP1_VERSION_S
Bmp.Height div 2
