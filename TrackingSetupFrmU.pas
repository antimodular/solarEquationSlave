unit TrackingSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, FileCtrl, Menus,
  Buttons, AprSpin, AprChkBx, LCD;

type
  TTrackingSetupFrm = class(TForm)
    FollowMouseCB: TAprCheckBox;
    Panel1: TPanel;
    Label7: TLabel;
    FlipCB: TAprCheckBox;
    MirrorCB: TAprCheckBox;
    CamSettingsBtn: TButton;
    Panel2: TPanel;
    Label8: TLabel;
    Label3: TLabel;
    LowThresholdEdit: TAprSpinEdit;
    Label4: TLabel;
    HighThresholdEdit: TAprSpinEdit;
    Label5: TLabel;
    JumpDEdit: TAprSpinEdit;
    Label6: TLabel;
    MergeDEdit: TAprSpinEdit;
    MinAreaLbl: TLabel;
    MinAreaEdit: TAprSpinEdit;
    PaintBox: TPaintBox;
    Panel3: TPanel;
    BackGndDrawPanel: TPanel;
    Label11: TLabel;
    NormalRB: TRadioButton;
    ForeGndDrawPanel: TPanel;
    Label14: TLabel;
    ThresholdsRB: TRadioButton;
    TrackingViewRB: TRadioButton;
    StripsCB: TAprCheckBox;
    TargetsCB: TAprCheckBox;
    BlobsCB: TAprCheckBox;
    MaskCB: TAprCheckBox;
    Label9: TLabel;
    StatusBar1: TStatusBar;
    TrackMaskBtn: TButton;
    XLcd: TLCD;
    YLcd: TLCD;
    InfoBtn: TButton;
    AllStripsCB: TAprCheckBox;
    SubtractedRB: TRadioButton;
    SmoothCB: TAprCheckBox;
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure LowThresholdEditChange(Sender: TObject);
    procedure HighThresholdEditChange(Sender: TObject);
    procedure JumpDEditChange(Sender: TObject);
    procedure MinAreaEditChange(Sender: TObject);
    procedure FlipCBClick(Sender: TObject);
    procedure MirrorCBClick(Sender: TObject);
    procedure CamSettingsBtnClick(Sender: TObject);
    procedure MergeDEditChange(Sender: TObject);
    procedure TrackAreaBtnClick(Sender: TObject);
    procedure TrackMaskBtnClick(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure InfoBtnClick(Sender: TObject);
    procedure SmoothCBClick(Sender: TObject);

  private
    FrameCount : Integer;
    Save       : Boolean;
    Bmp        : TBitmap;

    procedure DrawBmp;
    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;
  end;

var
  TrackingSetupFrm: TTrackingSetupFrm;

implementation

{$R *.dfm}

uses
  CameraU, BlobFinderU, Math, BmpUtils, MemoFrmU,
  MaskFrmU;

procedure TTrackingSetupFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TTrackingSetupFrm.Initialize;
begin
  Save:=False;

  LowThresholdEdit.Value:=BlobFinder.LoT;
  HighThresholdEdit.Value:=BlobFinder.HiT;

  JumpDEdit.Value:=BlobFinder.JumpD;
  MergeDEdit.Value:=BlobFinder.MergeD;
  MinAreaEdit.Value:=BlobFinder.MinArea;

  FrameCount:=0;

// bmps
  Bmp:=CreateImageBmp;

// camera
  FlipCB.Checked:=Camera.FlipImage;
  MirrorCB.Checked:=Camera.MirrorImage;
  SmoothCB.Checked:=Camera.Smooth;

  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackingSetupFrm.DrawBmp;
begin
  if ThresholdsRB.Checked then begin
    BlobFinder.ShowThresholds(Camera.SubtractedBmp,Bmp);
  end

  else begin

// background
    if NormalRB.Checked then begin
      if Camera.Smooth then begin
        if Odd(Camera.FrameCount) then Bmp.Canvas.Draw(0,0,Camera.SmoothOddBmp)
        else Bmp.Canvas.Draw(0,0,Camera.SmoothEvenBmp);
      end;
      Bmp.Canvas.Draw(0,0,Camera.Bmp);
    end
    else Bmp.Canvas.Draw(0,0,Camera.SubtractedBmp);

    if StripsCB.Checked then BlobFinder.DrawStrips(Bmp);

    if BlobsCB.Checked then BlobFinder.DrawBlobs(Bmp,0);
  end;

  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
end;

procedure TTrackingSetupFrm.PaintBoxPaint(Sender:TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TTrackingSetupFrm.SmoothCBClick(Sender: TObject);
begin
  Camera.Smooth:=SmoothCB.Checked;
end;

procedure TTrackingSetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TTrackingSetupFrm.LowThresholdEditChange(Sender: TObject);
begin
  BlobFinder.LoT:=Round(LowThresholdEdit.Value);
  Save:=True;
end;

procedure TTrackingSetupFrm.HighThresholdEditChange(Sender: TObject);
begin
  BlobFinder.HiT:=Round(HighThresholdEdit.Value);
  Save:=True;
end;

procedure TTrackingSetupFrm.JumpDEditChange(Sender: TObject);
begin
  BlobFinder.JumpD:=Round(JumpDEdit.Value);
  Save:=True;
end;

procedure TTrackingSetupFrm.MinAreaEditChange(Sender: TObject);
begin
  BlobFinder.MinArea:=Round(MinAreaEdit.Value);
  Save:=True;
end;

procedure TTrackingSetupFrm.NewCameraFrame(Sender:TObject);
begin
  if Camera.Smooth then Camera.SmoothBmp;
  Camera.DrawSubtractedBmp;
  BlobFinder.UpdateWithBmp(Camera.SubtractedBmp);
  DrawBmp;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TTrackingSetupFrm.FlipCBClick(Sender: TObject);
begin
  Camera.FlipImage:=FlipCB.Checked;
end;

procedure TTrackingSetupFrm.MirrorCBClick(Sender: TObject);
begin
  Camera.MirrorImage:=MirrorCB.Checked;
end;

procedure TTrackingSetupFrm.CamSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowCameraSettingsFrm(False);
end;

procedure TTrackingSetupFrm.MergeDEditChange(Sender: TObject);
begin
  BlobFinder.MergeD:=Round(MergeDEdit.Value);
end;

procedure TTrackingSetupFrm.TrackAreaBtnClick(Sender: TObject);
begin
  MaskFrm:=TMaskFrm.Create(Application);
  try
    MaskFrm.Initialize;
    MaskFrm.ShowModal;
  finally
    MaskFrm.Free;
  end;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackingSetupFrm.TrackMaskBtnClick(Sender: TObject);
begin
  MaskFrm:=TMaskFrm.Create(Application);
  try
    MaskFrm.Initialize;
    MaskFrm.ShowModal;
  finally
    MaskFrm.Free;
  end;
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TTrackingSetupFrm.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  XLcd.Value:=X;
  YLcd.Value:=Y;
  if FollowMouseCB.Checked then begin
    Camera.MouseX:=X;
  end;
end;

procedure TTrackingSetupFrm.InfoBtnClick(Sender: TObject);
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    Camera.ShowInfoInLines(MemoFrm.Memo.Lines);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

end.

