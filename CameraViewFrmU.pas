unit CameraViewFrmU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TCameraViewFrm = class(TForm)
    PaintBox: TPaintBox;
    CameraSettingsBtn: TBitBtn;
    procedure CameraSettingsBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    procedure NewCameraFrame(Sender:TObject);

  public
    procedure Initialize;
  end;

var
  CameraViewFrm: TCameraViewFrm;

implementation

{$R *.dfm}

uses
  CameraU, BmpUtils;

procedure TCameraViewFrm.CameraSettingsBtnClick(Sender: TObject);
begin
  Camera.ShowSettingsFrm;
end;

procedure TCameraViewFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
end;

procedure TCameraViewFrm.Initialize;
begin
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TCameraViewFrm.NewCameraFrame(Sender:TObject);
begin
  ShowFrameRateOnBmp(Camera.Bmp,Camera.MeasuredFPS);
  PaintBox.Canvas.Draw(0,0,Camera.Bmp);
end;

end.
