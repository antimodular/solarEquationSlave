unit ProjTst;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Global;

type
  TProjectorTestFrm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);

  private
    Bmp : TBitmap;

    procedure DrawBmp;

  public
    MouseX  : Integer;
    MouseY  : Integer;
    StaticX : Integer;
    StaticY : Integer;

    procedure UpdateFrm;
    procedure DrawXHairs(X,Y:Integer);
  end;

var
  ProjectorTestFrm: TProjectorTestFrm;

implementation

{$R *.dfm}

uses
  ProjectorU;

procedure TProjectorTestFrm.FormCreate(Sender:TObject);
begin
  BorderStyle:=bsNone;
  Color:=clBlack;
  Bmp:=TBitmap.Create;
  Bmp.PixelFormat:=pf24Bit;
end;

procedure TProjectorTestFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TProjectorTestFrm.DrawXHairs(X,Y:Integer);
begin
  with Bmp.Canvas do begin
    MoveTo(0,Y);
    LineTo(Width,Y);
    MoveTo(X,0);
    LineTo(X,Height);
  end;
end;

procedure TProjectorTestFrm.DrawBmp;
begin
  Bmp.Width:=ClientWidth;
  Bmp.Height:=ClientHeight;
  with Bmp.Canvas do begin
    Brush.Color:=clBlack;
    FillRect(ClientRect);
    Pen.Color:=clYellow;
    DrawXHairs(MouseX,MouseY);
    Pen.Color:=clWhite;
    DrawXHairs(StaticX,StaticY);
  end;
end;

procedure TProjectorTestFrm.FormPaint(Sender: TObject);
begin
  Canvas.Draw(0,0,Bmp);
end;

procedure TProjectorTestFrm.UpdateFrm;
begin
  DrawBmp;
  Canvas.Draw(0,0,Bmp);
end;

end.
