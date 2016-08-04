unit MaskFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprSpin, StdCtrls, ExtCtrls, Global, Buttons;

type
  TDrawMode = (dmNone,dmDraw,dmErase);

  TMaskFrm = class(TForm)
    PaintBox: TPaintBox;
    BrushSizeLbl: TLabel;
    BrushSizeEdit: TAprSpinEdit;
    SaveBtn: TBitBtn;
    CancelBtn: TBitBtn;
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SaveBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure LiveCBClick(Sender: TObject);

  private
    Bmp      : TBitmap;
    DrawMode : TDrawMode;

    function  ClippedX(X:Integer):Integer;
    function  ClippedY(Y:Integer):Integer;
    procedure UpdateDraw(X,Y:Integer);
    procedure NewCameraFrame(Sender:TObject);
    procedure Redraw;

  public
    procedure Initialize;
  end;

var
  MaskFrm: TMaskFrm;

implementation

{$R *.dfm}

uses
  CameraU;

procedure TMaskFrm.Initialize;
begin
  DrawMode:=dmNone;
  Bmp:=TBitmap.Create;
  Bmp.Width:=ImageW;
  Bmp.Height:=ImageH;
  Bmp.PixelFormat:=pf24Bit;//BytesPerPixelToPixelFormat(Camera.Bpp);
  Bmp.Canvas.Draw(0,0,Camera.Bmp);
//  ApplyMaskToBmp(@BlobFinder.XYInTrackArea,Bmp);
  Camera.OnNewFrame:=NewCameraFrame;
end;

procedure TMaskFrm.FormDestroy(Sender: TObject);
begin
  Camera.OnNewFrame:=nil;
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TMaskFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TMaskFrm.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then DrawMode:=dmDraw
  else DrawMode:=dmErase;
  UpdateDraw(X,Y);
end;

function TMaskFrm.ClippedX(X:Integer):Integer;
begin
  if X<0 then Result:=0
  else if X>=ImageW then Result:=ImageW-1
  else Result:=X;
end;

function TMaskFrm.ClippedY(Y:Integer):Integer;
begin
  if Y<0 then Result:=0
  else if Y>=ImageH then Result:=ImageH-1
  else Result:=Y;
end;

procedure TMaskFrm.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;X, Y: Integer);
begin
  if (X>=0) and (X<ImageW) and (Y>=0) and (Y<ImageH) then begin
    if DrawMode<>dmNone then UpdateDraw(X,Y);
//    if BlobFinder.XYInTrackArea[X,Y] then Caption:='Yes' else Caption:='No';
  end;
end;

procedure TMaskFrm.UpdateDraw(X,Y:Integer);
var
  BrushSize : Integer;
  XMin,XMax : Integer;
  YMin,YMax : Integer;
begin
  BrushSize:=Round(BrushSizeEdit.Value);
  XMin:=ClippedX(X-BrushSize);
  XMax:=ClippedX(X+BrushSize);
  YMin:=ClippedY(Y-BrushSize);
  YMax:=ClippedY(Y+BrushSize);
  for Y:=YMin to YMax do begin
    for X:=XMin to XMax do begin
//      BlobFinder.XYInTrackArea[X,Y]:=(DrawMode=dmDraw);
    end;
  end;
end;

procedure TMaskFrm.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
                                   Shift: TShiftState; X, Y: Integer);
begin
  DrawMode:=dmNone;
end;

procedure TMaskFrm.NewCameraFrame(Sender:TObject);
begin
  Redraw;
end;

procedure TMaskFrm.Redraw;
begin
  Bmp.Canvas.Draw(0,0,Camera.Bmp);
//  ApplyMaskToBmp(@BlobFinder.XYInTrackArea,Bmp);
  PaintBox.Canvas.Draw(0,0,Bmp);
end;

procedure TMaskFrm.SaveBtnClick(Sender: TObject);
begin
//  BlobFinder.SaveTrackAreaMask;
  Close;
end;

procedure TMaskFrm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMaskFrm.LiveCBClick(Sender: TObject);
begin
  Redraw;
end;

end.
