unit SeasonSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Math, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, AprSpin, ExtCtrls, Buttons, ColorBtn,
  AprChkBx, ComCtrls, ProjectorU, SeasonU, NBFill;

type
  TSeasonSetupFrm = class(TForm)
    SeasonTC: TTabControl;
    LayerTC: TTabControl;
    FxPageControl: TPageControl;
    CubeMapPage: TTabSheet;
    Label14: TLabel;
    Label15: TLabel;
    CubeMapPB: TPaintBox;
    CubeMapEnabledCB: TAprCheckBox;
    CubeMapAlphaEdit: TAprSpinEdit;
    CubeMapIndexEdit: TAprSpinEdit;
    ImagePage: TTabSheet;
    Label16: TLabel;
    ImagePB: TPaintBox;
    Label17: TLabel;
    ImageAlphaEdit: TAprSpinEdit;
    ImageEnabledCB: TAprCheckBox;
    ImageIndexEdit: TAprSpinEdit;
    ReactDiffuse1Page: TTabSheet;
    Label18: TLabel;
    RepeatsLbl: TLabel;
    Panel3: TPanel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    FEdit: TAprSpinEdit;
    KEdit: TAprSpinEdit;
    HEdit: TAprSpinEdit;
    RandomizeBtn: TBitBtn;
    Panel4: TPanel;
    Label28: TLabel;
    Label29: TLabel;
    Label31: TLabel;
    DividerEdit: TAprSpinEdit;
    ScaleEdit: TAprSpinEdit;
    RdAlphaEdit: TAprSpinEdit;
    ReactDiffuseCB: TAprCheckBox;
    SpeedEdit: TAprSpinEdit;
    RepeatsEdit: TAprSpinEdit;
    PerlinPage: TTabSheet;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    PerlinCB: TAprCheckBox;
    PerlinAlphaEdit: TAprSpinEdit;
    PerlinForeGndColorBtn: TColorBtn;
    PerlinBackGndColorBtn: TColorBtn;
    PerlinBoilSpeedEdit: TAprSpinEdit;
    PerlinScaleEdit: TAprSpinEdit;
    TabSheet2: TTabSheet;
    Label39: TLabel;
    ParticlesEnabledCB: TAprCheckBox;
    ParticlesAlphaEdit: TAprSpinEdit;
    Label1: TLabel;
    SeasonEdit: TAprSpinEdit;
    Label2: TLabel;
    ParticlesDivider1Edit: TAprSpinEdit;
    Label3: TLabel;
    ParticlesDivider2Edit: TAprSpinEdit;
    ColorDlg: TColorDialog;
    RotateCB: TAprCheckBox;
    RotateTimer: TTimer;
    MP3Page: TTabSheet;
    Label27: TLabel;
    MP3IndexEdit: TAprSpinEdit;
    MP3VolumeEdit: TNBFillEdit;
    PlayBtn: TBitBtn;
    StopBtn: TBitBtn;
    Label22: TLabel;
    ParticlesPointSizeEdit: TAprSpinEdit;
    Label4: TLabel;
    ParticlesMinSpeedEdit: TAprSpinEdit;
    Label5: TLabel;
    ParticlesMaxSpeedEdit: TAprSpinEdit;
    Label48: TLabel;
    ParticlesRotateVEdit: TAprSpinEdit;
    Label6: TLabel;
    ParticlesMaxREdit: TAprSpinEdit;
    Label7: TLabel;
    ParticlesAlphaThresholdEdit: TAprSpinEdit;
    ParticlesMaxSpotSizeEdit: TAprSpinEdit;
    Label8: TLabel;
    Label46: TLabel;
    CubeMapRotateVEdit: TAprSpinEdit;
    Label9: TLabel;
    ImageTScaleEdit: TAprSpinEdit;
    Label42: TLabel;
    ImageTOffsetEdit: TAprSpinEdit;
    Label43: TLabel;
    ImageRotateVEdit: TAprSpinEdit;
    Label44: TLabel;
    RDRotateVEdit: TAprSpinEdit;
    Label10: TLabel;
    PerlinRotateVEdit: TAprSpinEdit;
    RotateSpeedEdit: TAprSpinEdit;

    procedure CubeMapPBPaint(Sender: TObject);
    procedure ImagePBPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SeasonEditChange(Sender: TObject);
    procedure CubeMapEnabledCBClick(Sender: TObject);
    procedure CubeMapIndexEditChange(Sender: TObject);
    procedure CubeMapAlphaEditChange(Sender: TObject);
    procedure ImageEnabledCBClick(Sender: TObject);
    procedure ImageIndexEditChange(Sender: TObject);
    procedure ImageAlphaEditChange(Sender: TObject);
    procedure ReactDiffuseCBClick(Sender: TObject);
    procedure DividerEditChange(Sender: TObject);
    procedure ScaleEditChange(Sender: TObject);
    procedure RdAlphaEditChange(Sender: TObject);
    procedure FEditChange(Sender: TObject);
    procedure KEditChange(Sender: TObject);
    procedure HEditChange(Sender: TObject);
    procedure SpeedEditChange(Sender: TObject);
    procedure RepeatsEditChange(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure RandomizeBtnClick(Sender: TObject);
    procedure SquaresBtnClick(Sender: TObject);
    procedure PerlinCBClick(Sender: TObject);
    procedure PerlinAlphaEditChange(Sender: TObject);
    procedure PerlinBoilSpeedEditChange(Sender: TObject);
    procedure PerlinScaleEditChange(Sender: TObject);
    procedure PerlinForeGndColorBtnClick(Sender: TObject);
    procedure PerlinBackGndColorBtnClick(Sender: TObject);
    procedure ParticlesEnabledCBClick(Sender: TObject);
    procedure ParticlesAlphaEditChange(Sender: TObject);
    procedure ParticlesDivider1EditChange(Sender: TObject);
    procedure ParticlesDivider2EditChange(Sender: TObject);
    procedure RotateTimerTimer(Sender: TObject);
    procedure RotateCBClick(Sender: TObject);
    procedure SeasonTCChange(Sender: TObject);
    procedure LayerTCChange(Sender: TObject);
    procedure MP3IndexEditChange(Sender: TObject);
    procedure MP3VolumeEditValueChange(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure CubeMapRotateVEditChange(Sender: TObject);
    procedure ImageTScaleEditChange(Sender: TObject);
    procedure ImageTOffsetEditChange(Sender: TObject);
    procedure ImageRotateVEditChange(Sender: TObject);
    procedure RDRotateVEditChange(Sender: TObject);
    procedure PerlinRotateVEditChange(Sender: TObject);
    procedure ParticlesPointSizeEditChange(Sender: TObject);
    procedure ParticlesMinSpeedEditChange(Sender: TObject);
    procedure ParticlesMaxSpeedEditChange(Sender: TObject);
    procedure ParticlesRotateVEditChange(Sender: TObject);
    procedure ParticlesMaxREditChange(Sender: TObject);
    procedure ParticlesAlphaThresholdEditChange(Sender: TObject);
    procedure ParticlesMaxSpotSizeEditChange(Sender: TObject);

  private
    procedure ShowSeason;

    function  SelectedLayer: Integer;
    function  SelectedSeason:TSeason;

  public
    procedure Initialize;

    procedure SyncSeasonData;
    procedure SyncUpdateData;
  end;

var
  SeasonSetupFrm : TSeasonSetupFrm;
  SeasonSetupFrmCreated : Boolean = False;

procedure ShowSeasonSetupFrm;

implementation

{$R *.dfm}

uses
  Global, CubeMapU, TextureU, ReactDiffuseU,
  MP3PlayerU;

procedure ShowSeasonSetupFrm;
begin
  if not SeasonSetupFrmCreated then begin
    SeasonSetupFrm:=TSeasonSetupFrm.Create(Application);
    SeasonSetupFrm.Initialize;
  end;
  SeasonSetupFrm.Show;
end;

procedure TSeasonSetupFrm.ParticlesEnabledCBClick(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].Enabled:=ParticlesEnabledCB.Checked;
end;

procedure TSeasonSetupFrm.ParticlesAlphaEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].Alpha:=ParticlesAlphaEdit.Value;
end;

procedure TSeasonSetupFrm.ParticlesDivider1EditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].Divider1:=ParticlesDivider1Edit.Value;
end;

procedure TSeasonSetupFrm.ParticlesDivider2EditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].Divider2:=ParticlesDivider2Edit.Value;
end;

procedure TSeasonSetupFrm.Initialize;
begin
  CubeMapPage.TabVisible:=False;
  ShowSeason;
end;

procedure TSeasonSetupFrm.SyncSeasonData;
begin
  ShowSeason;
end;

procedure TSeasonSetupFrm.SyncUpdateData;
begin
  ShowSeason;
end;

function TSeasonSetupFrm.SelectedLayer:Integer;
begin
  Result:=LayerTC.TabIndex+1;
end;

function TSeasonSetupFrm.SelectedSeason:TSeason;
begin
  if SeasonTC.TabIndex=0 then Result:=CurrentSeason
  else Result:=Season[SeasonTC.TabIndex];
end;

procedure TSeasonSetupFrm.ShowSeason;
var
  I : Integer;
begin
  I:=SelectedLayer;
  with SelectedSeason do begin

// MP3
    MP3IndexEdit.Value:=MP3.Index;
    MP3VolumeEdit.Value:=MP3.Volume;

// CubeMap
    CubeMapEnabledCB.Checked:=CubeMap[I].Enabled;
    CubeMapIndexEdit.Value:=CubeMap[I].Index;
    CubeMapAlphaEdit.Value:=CubeMap[I].Alpha;
    CubeMapRotateVEdit.Value:=CubeMap[I].RotateV;
    CubeMapU.CubeMap.LoadTextureIfNecessary(CubeMap[I].Index);

// image
    ImageEnabledCB.Checked:=Image[I].Enabled;
    ImageAlphaEdit.Value:=Image[I].Alpha;
    ImageIndexEdit.Value:=Image[I].Index;
    ImageTScaleEdit.Value:=Image[I].TScale;
    ImageTOffsetEdit.Value:=Image[I].TOffset;
    ImageRotateVEdit.Value:=Image[I].RotateV;

// react diffuse #1
    ReactDiffuseCB.Checked:=ReactDiffusion[I].Enabled;
    DividerEdit.Value:=ReactDiffusion[I].Divider;
    ScaleEdit.Value:=ReactDiffusion[I].Scale;
    RdAlphaEdit.Value:=ReactDiffusion[I].Alpha;
    FEdit.Value:=ReactDiffusion[I].F;
    KEdit.Value:=ReactDiffusion[I].K;
    HEdit.Value:=ReactDiffusion[I].H;
    SpeedEdit.Value:=ReactDiffusion[I].Speed;
    RepeatsEdit.Value:=ReactDiffusion[I].Repeats;
    RdRotateVEdit.Value:=ReactDiffusion[I].RotateV;

// perlin
    PerlinCB.Checked:=PerlinSettings[I].Enabled;
    PerlinAlphaEdit.Value:=PerlinSettings[I].Alpha;
    PerlinForeGndColorBtn.Color:=PerlinSettings[I].ForeColor;
    PerlinBackGndColorBtn.Color:=PerlinSettings[I].BackColor;
    PerlinBoilSpeedEdit.Value:=PerlinSettings[I].BoilSpeed;
    PerlinScaleEdit.Value:=PerlinSettings[I].Scale;
    PerlinRotateVEdit.Value:=PerlinSettings[I].RotateV;

// particles
    ParticlesEnabledCB.Checked:=Particle[I].Enabled;
    ParticlesAlphaEdit.Value:=Particle[I].Alpha;
    ParticlesMinSpeedEdit.Value:=Particle[I].MinSpeed;
    ParticlesMaxSpeedEdit.Value:=Particle[I].MaxSpeed;
    ParticlesDivider1Edit.Value:=Particle[I].Divider1;
    ParticlesDivider2Edit.Value:=Particle[I].Divider2;
    ParticlesMaxREdit.Value:=Particle[I].MaxR;
    ParticlesPointSizeEdit.Value:=Particle[I].PointSize;
    ParticlesAlphaThresholdEdit.Value:=Particle[I].AlphaThreshold;
    ParticlesMaxSpotSizeEdit.Value:=RadToDeg(Particle[I].MaxSpotSize);
    ParticlesRotateVEdit.Value:=Particle[I].RotateV;
  end;
  CubeMapPBPaint(nil);
  ImagePBPaint(nil);
end;

procedure TSeasonSetupFrm.CubeMapPBPaint(Sender: TObject);
var
  I,L : Integer;
begin
  L:=SelectedLayer;
  I:=SelectedSeason.CubeMap[L].Index;
  CubeMapPB.Canvas.Draw(0,0,CubeMap.Face[I,3].Bmp);
end;

procedure TSeasonSetupFrm.ImagePBPaint(Sender: TObject);
var
  I,L : Integer;
begin
  L:=SelectedLayer;
  I:=SelectedSeason.Image[L].Index;
  ImagePB.Canvas.Draw(0,0,Texture[I].Bmp);
end;

procedure TSeasonSetupFrm.FormCreate(Sender: TObject);
begin
  SeasonSetupFrmCreated:=True;
end;

procedure TSeasonSetupFrm.FormDestroy(Sender: TObject);
begin
  SeasonSetupFrmCreated:=False;
end;

procedure TSeasonSetupFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TSeasonSetupFrm.SeasonEditChange(Sender: TObject);
var
  S : Integer;
begin
  S:=Round(SeasonEdit.Value);
  if S<>ActiveSeason then begin
    ActiveSeason:=S;
    CurrentSeason.CopyFromSeason(Season[S]);
    if SeasonTC.TabIndex=0 then ShowSeason;
  end;
end;

procedure TSeasonSetupFrm.CubeMapEnabledCBClick(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  CurrentSeason.CubeMap[L].Enabled:=CubeMapEnabledCB.Checked;
end;

procedure TSeasonSetupFrm.CubeMapIndexEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  CurrentSeason.CubeMap[L].Index:=Round(CubeMapIndexEdit.Value);
end;

procedure TSeasonSetupFrm.CubeMapAlphaEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  CurrentSeason.CubeMap[L].Alpha:=CubeMapAlphaEdit.Value;
end;

procedure TSeasonSetupFrm.ImageEnabledCBClick(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  CurrentSeason.Image[L].Enabled:=ImageEnabledCB.Checked;
end;

procedure TSeasonSetupFrm.ImageIndexEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  CurrentSeason.Image[L].Index:=Round(ImageIndexEdit.Value);
end;

procedure TSeasonSetupFrm.ImageAlphaEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  CurrentSeason.Image[L].Alpha:=ImageAlphaEdit.Value;
end;

procedure TSeasonSetupFrm.ReactDiffuseCBClick(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].Enabled:=ReactDiffuseCB.Checked;
end;

procedure TSeasonSetupFrm.DividerEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].Divider:=DividerEdit.Value;
end;

procedure TSeasonSetupFrm.ScaleEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].Scale:=ScaleEdit.Value;
end;

procedure TSeasonSetupFrm.RdAlphaEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].Alpha:=RdAlphaEdit.Value;
end;

procedure TSeasonSetupFrm.FEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].F:=FEdit.Value;
end;

procedure TSeasonSetupFrm.KEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].K:=KEdit.Value;
end;

procedure TSeasonSetupFrm.HEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].H:=HEdit.Value;
end;

procedure TSeasonSetupFrm.SpeedEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].Speed:=Round(SpeedEdit.Value);
end;

procedure TSeasonSetupFrm.RepeatsEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].Repeats:=RepeatsEdit.Value;
end;

procedure TSeasonSetupFrm.ResetBtnClick(Sender: TObject);
var
  L,I : Integer;
begin
  L:=SelectedLayer;
  for I:=1 to Projectors do Projector[I].ReactDiffuse[L].MakeReset:=True;
end;

procedure TSeasonSetupFrm.RandomizeBtnClick(Sender: TObject);
var
  L,I : Integer;
begin
  L:=SelectedLayer;
  for I:=1 to Projectors do Projector[I].ReactDiffuse[L].MakeRandom:=True;
end;

procedure TSeasonSetupFrm.SquaresBtnClick(Sender: TObject);
var
  L,I : Integer;
begin
  L:=SelectedLayer;
  for I:=1 to Projectors do Projector[I].ReactDiffuse[L].MakeSquares:=True;
end;

procedure TSeasonSetupFrm.PerlinCBClick(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.PerlinSettings[L].Enabled:=PerlinCB.Checked;
end;

procedure TSeasonSetupFrm.PerlinAlphaEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.PerlinSettings[L].Alpha:=PerlinAlphaEdit.Value;
end;

procedure TSeasonSetupFrm.PerlinBoilSpeedEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.PerlinSettings[L].BoilSpeed:=PerlinBoilSpeedEdit.Value;
end;

procedure TSeasonSetupFrm.PerlinScaleEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.PerlinSettings[L].Scale:=PerlinScaleEdit.Value;
end;

procedure TSeasonSetupFrm.PerlinForeGndColorBtnClick(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  ColorDlg.Color:=SelectedSeason.PerlinSettings[L].ForeColor;
  if ColorDlg.Execute then begin
    SelectedSeason.PerlinSettings[L].ForeColor:=ColorDlg.Color;
    PerlinForeGndColorBtn.Color:=SelectedSeason.PerlinSettings[L].ForeColor;
  end;
end;

procedure TSeasonSetupFrm.PerlinBackGndColorBtnClick(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  ColorDlg.Color:=SelectedSeason.PerlinSettings[L].BackColor;
  if ColorDlg.Execute then begin
    SelectedSeason.PerlinSettings[L].BackColor:=ColorDlg.Color;
    PerlinBackGndColorBtn.Color:=SelectedSeason.PerlinSettings[L].BackColor;
  end;
end;

procedure TSeasonSetupFrm.RotateTimerTimer(Sender: TObject);
//var
 // V : Single;
begin
//  V:=RotateSpeedEdit.Value;
//  Rotation.Scroll:=Rotation.Scroll+V;
end;

procedure TSeasonSetupFrm.RotateCBClick(Sender: TObject);
begin
  RotateTimer.Enabled:=RotateCB.Checked;
end;

procedure TSeasonSetupFrm.SeasonTCChange(Sender: TObject);
begin
  ShowSeason;
end;

procedure TSeasonSetupFrm.LayerTCChange(Sender: TObject);
begin
  MP3Page.TabVisible:=(SelectedLayer=1);
  ShowSeason;
end;

procedure TSeasonSetupFrm.MP3IndexEditChange(Sender: TObject);
begin
  SelectedSeason.MP3.Index:=Round(MP3IndexEdit.Value);
  MP3Player.PlayMP3Number(SelectedSeason.MP3.Index);
end;

procedure TSeasonSetupFrm.MP3VolumeEditValueChange(Sender: TObject);
begin
  SelectedSeason.MP3.Volume:=MP3VolumeEdit.Value;
  MP3Player.SetVolume(MP3VolumeEdit.Value);
end;

procedure TSeasonSetupFrm.PlayBtnClick(Sender: TObject);
begin
  SelectedSeason.PlayMP3;
end;

procedure TSeasonSetupFrm.StopBtnClick(Sender: TObject);
begin
  MP3Player.Stop;
end;

procedure TSeasonSetupFrm.CubeMapRotateVEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.CubeMap[L].RotateV:=CubeMapRotateVEdit.Value;
end;

procedure TSeasonSetupFrm.ImageTScaleEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Image[L].TScale:=ImageTScaleEdit.Value;
end;

procedure TSeasonSetupFrm.ImageTOffsetEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Image[L].TOffset:=ImageTOffsetEdit.Value;
end;

procedure TSeasonSetupFrm.ImageRotateVEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Image[L].RotateV:=ImageRotateVEdit.Value;
end;

procedure TSeasonSetupFrm.RDRotateVEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.ReactDiffusion[L].RotateV:=RDRotateVEdit.Value;
end;

procedure TSeasonSetupFrm.PerlinRotateVEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.PerlinSettings[L].RotateV:=PerlinRotateVEdit.Value;
end;

procedure TSeasonSetupFrm.ParticlesPointSizeEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].PointSize:=ParticlesPointSizeEdit.Value;
end;

procedure TSeasonSetupFrm.ParticlesMinSpeedEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].MinSpeed:=ParticlesMinSpeedEdit.Value;
end;

procedure TSeasonSetupFrm.ParticlesMaxSpeedEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].MaxSpeed:=ParticlesMaxSpeedEdit.Value;
end;

procedure TSeasonSetupFrm.ParticlesRotateVEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].RotateV:=ParticlesRotateVEdit.Value;
end;

procedure TSeasonSetupFrm.ParticlesMaxREditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].MaxR:=ParticlesMaxREdit.Value;
end;

procedure TSeasonSetupFrm.ParticlesAlphaThresholdEditChange(
  Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].AlphaThreshold:=ParticlesAlphaThresholdEdit.Value;
end;

procedure TSeasonSetupFrm.ParticlesMaxSpotSizeEditChange(Sender: TObject);
var
  L : Integer;
begin
  L:=SelectedLayer;
  SelectedSeason.Particle[L].MinSpotSize:=DegToRad(ParticlesMaxSpotSizeEdit.Value);
  SelectedSeason.Particle[L].MaxSpotSize:=DegToRad(ParticlesMaxSpotSizeEdit.Value);
end;

end.



