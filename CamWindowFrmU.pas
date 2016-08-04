unit CamWindowFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, AprSpin, StdCtrls;

type
  TCamWindowFrm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    FullWindowBtn: TButton;
    XEdit: TAprSpinEdit;
    YEdit: TAprSpinEdit;
    WEdit: TAprSpinEdit;
    HEdit: TAprSpinEdit;
    PaintBox: TPaintBox;
    procedure FullWindowBtnClick(Sender: TObject);
    procedure WindowEditChange(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;
  end;

var
  CamWindowFrm: TCamWindowFrm;

implementation

{$R *.dfm}

uses
  CameraU, BmpUtils;

procedure TCamWindowFrm.Initialize;
begin
  XEdit.Value:=Camera.Window.X;
  YEdit.Value:=Camera.Window.Y;
  WEdit.Value:=Camera.Window.W;
  HEdit.Value:=Camera.Window.H;

  Bmp:=CreateImageBmp;

  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TCamWindowFrm.FullWindowBtnClick(Sender: TObject);
begin
  Camera.ShowFullView;
end;

procedure TCamWindowFrm.WindowEditChange(Sender: TObject);
var
  Window : TCameraWindow;
begin
  Window.X:=Round(XEdit.Value);
  Window.Y:=Round(YEdit.Value);
  Window.W:=Round(WEdit.Value);
  Window.H:=Round(HEdit.Value);

  Camera.Window:=Window;
//  Camera.SetWindow(Window);
end;

procedure TCamWindowFrm.NewCameraFrame(Sender:TObject);
begin
// clear it
  ClearBmp(Bmp,clGray);

// draw the camera bitmap
  Bmp.Canvas.Draw(Camera.Window.X,Camera.Window.Y,Camera.Bmp);

// show the window
  Camera.DrawWindow(Bmp);

  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

end.
