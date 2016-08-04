unit BmpFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TBmpFrm = class(TForm)
    Timer: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    MouseX,MouseY : Integer;

  public
    procedure Initialize;
  end;

var
  BmpFrm: TBmpFrm;

implementation

{$R *.dfm}

uses
  Routines, CloudU, CameraU, GLSceneU;

procedure TBmpFrm.Initialize;
begin
  ClientWidth:=Cloud.GridWidth;
  ClientHeight:=Cloud.GridHeight;

  Timer.Enabled:=True;
end;

procedure TBmpFrm.FormPaint(Sender: TObject);
begin
  Canvas.Draw(0,0,Cloud.DensityBmp);
end;

procedure TBmpFrm.TimerTimer(Sender: TObject);
var
  X,Y,V,I : Integer;
  B,G     : Byte;
  Line    : PByteArray;
  Bmp     : TBitmap;
  VPtr    : PSingle;
  Vx,Vy   : Single;
begin
//  if Cloud.RenderMode=rmVelocity then Bmp:=Cloud.VelocityBmp
//  else Bmp:=Cloud.DensityBmp;

  Bmp:=Cloud.VelocityBmp;

  Line:=Bmp.ScanLine[MouseY];
  I:=MouseX*3;
  B:=Line^[I];
  G:=Line^[I+1];

  VPtr:=Cloud.VelocityData;
  Inc(VPtr,2*(MouseY*Cloud.GridWidth+MouseX));
  Vx:=VPtr^;
  Inc(VPtr);
  Vy:=VPtr^;

  Caption:='B:'+IntToStr(B)+' G:'+IntToStr(G)+
          ' X:'+MetreStr(Vx)+' Y:'+MetreStr(Vy);;

  X:=Round(Camera.MouseX*Cloud.GridWidth/GLSceneU.GLScene.Width);
  Y:=Round(Camera.MouseY*Cloud.GridHeight/GLSceneU.GLScene.Height);

  with Bmp.Canvas do begin
    Pen.Color:=clWhite;
    MoveTo(0,Y);
    LineTo(Cloud.GridWidth,Y);

    MoveTo(X,0);
    LineTo(X,Cloud.GridHeight);

    Pen.Color:=clRed;
    MoveTo(0,MouseY);
    LineTo(Cloud.GridWidth,MouseY);

    MoveTo(MouseX,0);
    LineTo(MouseX,Cloud.GridHeight);
  end;

  Canvas.Draw(0,0,Bmp);
end;

procedure TBmpFrm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  MouseX:=X;
  MouseY:=Y;
end;

end.
