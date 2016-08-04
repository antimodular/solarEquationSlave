unit CloudSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, CPanel, OpenGL1x, OpenGLTokens, ProgramU, AprChkBx,
  StdCtrls, ComCtrls, Buttons, ColorBtn, AprSpin, UnitLCD;

type
  TCloudSetupFrm = class(TForm)
    ColorDlg: TColorDialog;
    SmokePanel: TPanel;
    Label26: TLabel;
    Label1: TLabel;
    AmbientTemperatureEdit: TAprSpinEdit;
    Label2: TLabel;
    ImpulseTemperatureEdit: TAprSpinEdit;
    Label3: TLabel;
    ImpulseDensityEdit: TAprSpinEdit;
    Label4: TLabel;
    JacobiIterationsEdit: TAprSpinEdit;
    Label5: TLabel;
    TimeStepEdit: TAprSpinEdit;
    Label6: TLabel;
    SmokeBuoyancyEdit: TAprSpinEdit;
    Label7: TLabel;
    SmokeWeightEdit: TAprSpinEdit;
    Label8: TLabel;
    TemperatureDissipationEdit: TAprSpinEdit;
    Label9: TLabel;
    VelocityDissipationEdit: TAprSpinEdit;
    Label10: TLabel;
    DensityDissipationEdit: TAprSpinEdit;
    Label11: TLabel;
    CellSizeEdit: TAprSpinEdit;
    Label12: TLabel;
    GradientScaleEdit: TAprSpinEdit;
    SmokeColorBtn: TColorBtn;
    BackGndColorBtn: TColorBtn;
    Label13: TLabel;
    MaxSizeEdit: TAprSpinEdit;
    procedure SmokeColorBtnClick(Sender: TObject);
    procedure AmbientTemperatureEditChange(Sender: TObject);
    procedure ImpulseTemperatureEditChange(Sender: TObject);
    procedure ImpulseDensityEditChange(Sender: TObject);
    procedure JacobiIterationsEditChange(Sender: TObject);
    procedure TimeStepEditChange(Sender: TObject);
    procedure SmokeBuoyancyEditChange(Sender: TObject);
    procedure SmokeWeightEditChange(Sender: TObject);
    procedure TemperatureDissipationEditChange(Sender: TObject);
    procedure VelocityDissipationEditChange(Sender: TObject);
    procedure DensityDissipationEditChange(Sender: TObject);
    procedure CellSizeEditChange(Sender: TObject);
    procedure GradientScaleEditChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure BackGndColorBtnClick(Sender: TObject);
    procedure MaxSizeEditChange(Sender: TObject);

  private

  public
    procedure Initialize;

  end;

var
  CloudSetupFrm: TCloudSetupFrm;

implementation

{$R *.dfm}

uses
  Routines, GLSceneU, GLDraw, TextureU, CloudU, CfgFile, Global, Math, Main,
  CameraU, BlobFindU;

procedure TCloudSetupFrm.Initialize;
begin
  Caption:=VersionStr;

  EnterCriticalSection(Camera.CS);

  AmbientTemperatureEdit.Value:=Cloud.AmbientTemperature;
  ImpulseTemperatureEdit.Value:=Cloud.ImpulseTemperature;
  ImpulseDensityEdit.Value:=Cloud.ImpulseDensity;
  JacobiIterationsEdit.Value:=Cloud.JacobiIterations;
  TimeStepEdit.Value:=Cloud.TimeStep;
  SmokeBuoyancyEdit.Value:=Cloud.SmokeBuoyancy;
  SmokeWeightEdit.Value:=Cloud.SmokeWeight;
  TemperatureDissipationEdit.Value:=Cloud.TemperatureDissipation;
  VelocityDissipationEdit.Value:=Cloud.VelocityDissipation;
  DensityDissipationEdit.Value:=Cloud.DensityDissipation;
  CellSizeEdit.Value:=Cloud.CellSize;
  GradientScaleEdit.Value:=Cloud.GradientScale;

  SmokeColorBtn.Color:=Cloud.SmokeColor;
  SmokeColorBtn.Font.Color:=(not Cloud.SmokeColor) and $00FFFFFF;

  BackGndColorBtn.Color:=Cloud.BackGndColor;
  BackGndColorBtn.Font.Color:=(not Cloud.BackGndColor) and $00FFFFFF;

  MaxSizeEdit.Value:=Cloud.MaxSize;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.SmokeColorBtnClick(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  ColorDlg.Color:=Cloud.SmokeColor;
  if ColorDlg.Execute then begin
    Cloud.SmokeColor:=ColorDlg.Color;
    SmokeColorBtn.Color:=Cloud.SmokeColor;
    SmokeColorBtn.Font.Color:=(not Cloud.SmokeColor) and $00FFFFFF;
  end;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.AmbientTemperatureEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.AmbientTemperature:=AmbientTemperatureEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.ImpulseTemperatureEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.ImpulseTemperature:=ImpulseTemperatureEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.ImpulseDensityEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.ImpulseDensity:=ImpulseDensityEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.JacobiIterationsEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.JacobiIterations:=Round(JacobiIterationsEdit.Value);

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.TimeStepEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.TimeStep:=TimeStepEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.SmokeBuoyancyEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.SmokeBuoyancy:=SmokeBuoyancyEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.SmokeWeightEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.SmokeWeight:=SmokeWeightEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.TemperatureDissipationEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.TemperatureDissipation:=TemperatureDissipationEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.VelocityDissipationEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.VelocityDissipation:=VelocityDissipationEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.DensityDissipationEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.DensityDissipation:=DensityDissipationEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.CellSizeEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.CellSize:=CellSizeEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.GradientScaleEditChange(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  Cloud.GradientScale:=GradientScaleEdit.Value;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TCloudSetupFrm.BackGndColorBtnClick(Sender: TObject);
begin
  EnterCriticalSection(Camera.CS);

  ColorDlg.Color:=Cloud.BackGndColor;
  if ColorDlg.Execute then begin
    Cloud.BackGndColor:=ColorDlg.Color;
    BackGndColorBtn.Color:=Cloud.BackGndColor;
    BackGndColorBtn.Font.Color:=(not Cloud.BackGndColor) and $00FFFFFF;
  end;

  LeaveCriticalSection(Camera.CS);
end;

procedure TCloudSetupFrm.MaxSizeEditChange(Sender: TObject);
begin
  Cloud.MaxSize:=Round(MaxSizeEdit.Value);
end;

end.

procedure TCloudSetupFrm.YOffsetFractionEditChange(Sender: TObject);
begin
end;

end.









