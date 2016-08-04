unit CalibrateFrmU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, AprSpin, StdCtrls, ComCtrls, ExtCtrls, ProjectorU;

type
  TCalibrateFrm = class(TForm)
    LoadCalDlg: TOpenDialog;
    CameraPanel: TPanel;
    Label7: TLabel;
    SaveKImageBtn: TBitBtn;
    KImageEdit: TAprSpinEdit;
    InternalCalBtn: TBitBtn;
    UndistortCB: TCheckBox;
    ShowKInfoBtn: TBitBtn;
    CameraSettingsBtn: TBitBtn;
    PaintBox: TPaintBox;
    FollowCB: TCheckBox;
    ShowDetailsBtn: TBitBtn;
    CalBtn: TBitBtn;
    PlacePanel: TPanel;
    MagPB: TPaintBox;
    XLbl: TLabel;
    PlacePtLbl: TLabel;
    YLbl: TLabel;
    PointEdit: TAprSpinEdit;
    XEdit: TAprSpinEdit;
    YEdit: TAprSpinEdit;
    ProjectorWindowPanel: TPanel;
    Label2: TLabel;
    LeftEdit: TAprSpinEdit;
    Label1: TLabel;
    TopEdit: TAprSpinEdit;
    HeightEdit: TAprSpinEdit;
    Label4: TLabel;
    Label3: TLabel;
    WidthEdit: TAprSpinEdit;
    Label5: TLabel;
    GridCB: TCheckBox;
    GradientCB: TCheckBox;
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure PaintBoxMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
    procedure ShowDetailsBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SaveKImageBtnClick(Sender: TObject);
    procedure InternalCalBtnClick(Sender: TObject);
    procedure CalBtnClick(Sender: TObject);
    procedure ShowKInfoBtnClick(Sender: TObject);
    procedure MagPBClick(Sender: TObject);
    procedure PointEditChange(Sender: TObject);
    procedure CalPtEditChange(Sender: TObject);
    procedure FollowCBClick(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CameraSettingsBtnClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure LeftEditChange(Sender: TObject);
    procedure TopEditChange(Sender: TObject);
    procedure WidthEditChange(Sender: TObject);
    procedure HeightEditChange(Sender: TObject);
    procedure GridCBClick(Sender: TObject);
    procedure GradientCBClick(Sender: TObject);

  private
    Bmp       : TBitmap;
    MagBmp    : TBitmap;
    MagTmpBmp : TBitmap;

    procedure NewCameraFrame(Sender: TObject);

    procedure ShowSelectedPoint;
    procedure DrawMagBmp;

  public
    procedure Initialize;

  end;

var
  CalibrateFrm: TCalibrateFrm;

implementation

uses
  Routines, Global, CameraU, BmpUtils, MemoFrmU, CalU, ProjectorCalFrmU;

{$R *.DFM}

procedure TCalibrateFrm.Initialize;
begin
  PaintBox.Width:=Camera.ImageW;
  PaintBox.Height:=Camera.ImageH;

  Bmp:=CreateImageBmp;
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);

  MagBmp:=TBitmap.Create;
  MagBmp.PixelFormat:=pf24Bit;
  MagBmp.Width:=MagPB.Width;
  MagBmp.Height:=MagPB.Height;
  MagTmpBmp:=CreateBmpForPaintBox(MagPB);

  Calibrator:=TCalibrator.Create;
  ProjectorCalFrm:=TProjectorCalFrm.Create(Application);
  ProjectorCalFrm.Show;
  ProjectorCalFrm.MouseX:=-1;
  ProjectorCalFrm.MouseY:=-1;

  LeftEdit.Value:=Projector.Window.Left;
  TopEdit.Value:=Projector.Window.Top;
  WidthEdit.Value:=Projector.Window.Width;
  HeightEdit.Value:=Projector.Window.Height;

  ShowSelectedPoint;

  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TCalibrateFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  ProjectorCalFrm.Free;
  Calibrator.Free;

  if Assigned(Bmp) then Bmp.Free;
  if Assigned(MagBmp) then MagBmp.Free;
  if Assigned(MagTmpBmp) then MagTmpBmp.Free;
end;

procedure TCalibrateFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TCalibrateFrm.GradientCBClick(Sender: TObject);
begin
  ProjectorCalFrm.ShowGradient:=GradientCB.Checked;
  ProjectorCalFrm.UpdateFrm;
end;

procedure TCalibrateFrm.GridCBClick(Sender: TObject);
begin
  ProjectorCalFrm.ShowGrid:=GridCB.Checked;
  ProjectorCalFrm.UpdateFrm;
end;

procedure TCalibrateFrm.DrawMagBmp;
var
  MousePt : TPoint;
begin
  GetCursorPos(MousePt);
  MousePt:=PaintBox.ScreenToClient(MousePt);
  if (MousePt.X>=0) and (MousePt.X<Bmp.Width) and
     (MousePt.Y>=0) and (MousePt.Y<Bmp.Height) then
  begin
    MagnifyCopy(Bmp,MagTmpBmp,MagBmp,MousePt.X,MousePt.Y,11);
  end;
end;

procedure TCalibrateFrm.NewCameraFrame(Sender:TObject);
begin
// don't do anything but undistort if we're undistorting
  if UndistortCB.Checked then Camera.DrawUndistortedBmp(Camera.Bmp,Bmp)
  else begin
    Bmp.Canvas.Draw(0,0,Camera.Bmp);
    Projector.DrawCalPts(Bmp);
    ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
    DrawMagBmp;
    MagPB.Canvas.Draw(0,0,MagBmp);
  end;
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TCalibrateFrm.PaintBoxMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
var
  ProjPx : TPixel;
begin
  if FollowCB.Checked then begin

// convert from camera to projector coordinates
    ProjPx.X:=Camera.ProjTable[X,Y].X;
    ProjPx.Y:=Camera.ProjTable[X,Y].Y;

// update the projector form
    ProjectorCalFrm.MouseX:=ProjPx.X;
    ProjectorCalFrm.MouseY:=ProjPx.Y;
    ProjectorCalFrm.UpdateFrm;
  end;
end;

procedure TCalibrateFrm.ShowDetailsBtnClick(Sender: TObject);
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    Projector.HMatrix.DisplayInLines(MemoFrm.Memo.Lines,'HMatrix:');
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TCalibrateFrm.FormActivate(Sender: TObject);
begin
//  CenterFormOnMainScreen(Self);
end;

procedure TCalibrateFrm.SaveKImageBtnClick(Sender: TObject);
var
  I : Integer;
begin
  I:=Round(KImageEdit.Value);
  Camera.Bmp.SaveToFile(Path+'KImage0'+IntToStr(I)+'.bmp');
end;

procedure TCalibrateFrm.InternalCalBtnClick(Sender: TObject);
begin
  if LoadCalDlg.Execute then Camera.InitFromCalFile(LoadCalDlg.FileName);
end;

procedure TCalibrateFrm.CalBtnClick(Sender: TObject);
begin
  MemoFrm:=TMemoFrm.Create(Application);

  Calibrator.CalPt:=Projector.CalPt;

  try
    Calibrator.FindFixedCamPoints;
    Calibrator.CalculateMatrices(MemoFrm.Memo.Lines,False);
    Calibrator.HMatrix.DisplayInLinesWithPunctuation(MemoFrm.Memo.Lines,'H Matrix:');
    Calibrator.HInvMatrix.DisplayInLinesWithPunctuation(MemoFrm.Memo.Lines,'Inverse:');
    Calibrator.TestMatrices(MemoFrm.Memo.Lines);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;

  Projector.InitFromCalibrator(Calibrator);

  Camera.BuildProjectorTable;
  Camera.SaveProjectorTable;

  Camera.BuildGridTable;
  Camera.SaveGridTable;

  FollowCB.Checked:=True;
end;

procedure TCalibrateFrm.ShowKInfoBtnClick(Sender: TObject);
begin
 MemoFrm:=TMemoFrm.Create(Application);
  try
    with Camera.KInfo do begin
      MemoFrm.Memo.Lines.Add('K1:'+FloatToStrF(K1,ffFixed,9,1));
      MemoFrm.Memo.Lines.Add('K2:'+FloatToStrF(K2,ffFixed,9,1));
      MemoFrm.Memo.Lines.Add('Px:'+FloatToStrF(Px,ffFixed,9,1));
      MemoFrm.Memo.Lines.Add('Py:'+FloatToStrF(Py,ffFixed,9,1));
    end;
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TCalibrateFrm.MagPBClick(Sender: TObject);
begin
  MagPB.Canvas.Draw(0,0,MagBmp);
end;

procedure TCalibrateFrm.ShowSelectedPoint;
var
  P : Integer;
begin
  P:=Round(PointEdit.Value);
  with Projector.CalPt[P] do begin
    XEdit.Value:=ProjX;
    YEdit.Value:=ProjY;
    ProjectorCalFrm.PlaceXHairs(Round(ProjX),Round(ProjY));
  end;
end;

procedure TCalibrateFrm.PointEditChange(Sender: TObject);
begin
  ShowSelectedPoint;
end;

procedure TCalibrateFrm.CalPtEditChange(Sender: TObject);
var
  P : Integer;
begin
  P:=Round(PointEdit.Value);
  with Projector.CalPt[P] do begin
    ProjX:=XEdit.Value;
    ProjY:=YEdit.Value;
    ProjectorCalFrm.PlaceXHairs(Round(ProjX),Round(ProjY));
  end;
end;

procedure TCalibrateFrm.FollowCBClick(Sender: TObject);
begin
  if not FollowCB.Checked then begin
    ProjectorCalFrm.MouseX:=-1;
    ProjectorCalFrm.MouseY:=-1;
    ProjectorCalFrm.UpdateFrm;
  end;
end;

procedure TCalibrateFrm.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P : Integer;
begin
  P:=Round(PointEdit.Value);
  Projector.CalPt[P].CamX:=X;
  Projector.CalPt[P].CamY:=Y;
  if P<MaxCalPts then begin
    PointEdit.Value:=P+1;
    ShowSelectedPoint;
  end;
end;

procedure TCalibrateFrm.CameraSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowSettingsFrm;
end;

procedure TCalibrateFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TCalibrateFrm.LeftEditChange(Sender: TObject);
begin
  Projector.Window.Left:=Round(LeftEdit.Value);
  ProjectorCalFrm.Position;
end;

procedure TCalibrateFrm.TopEditChange(Sender: TObject);
begin
  Projector.Window.Top:=Round(TopEdit.Value);
  ProjectorCalFrm.Position;
end;

procedure TCalibrateFrm.WidthEditChange(Sender: TObject);
begin
  Projector.Window.Width:=Round(WidthEdit.Value);
  ProjectorCalFrm.Position;
end;

procedure TCalibrateFrm.HeightEditChange(Sender: TObject);
begin
  Projector.Window.Height:=Round(HeightEdit.Value);
  ProjectorCalFrm.Position;
end;

end.


