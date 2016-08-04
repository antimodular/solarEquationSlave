unit BorderTestMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

  private
    Bmp : TBitmap;

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var
  Border : array[1..100] of Integer;

const
  TextureW = 256;
  TextureH = 256;

procedure FindBorder(Bmp:TBitmap;I:Integer);
var
  X,Y   : Integer;
  Line  : PByteArray;
  Found : Boolean;
begin
  Border[I]:=Bmp.Width;
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    Found:=False;
    X:=0;
    repeat
      if Line^[X*3]>0 then Found:=True
      else Inc(X);
    until Found or (X=TextureW);
    if Found and (X<Border[I]) then begin
      Border[I]:=X;
      Form1.Caption:=IntToStr(Y);
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Bmp:=TBitmap.Create;
  Bmp.LoadFromFile('Bmps/73.bmp');
  FindBorder(Bmp,73);
end;

procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Line : PByteArray;
begin
  if (X<Bmp.Width) and (Y<Bmp.Height) then begin
    Line:=Bmp.ScanLine[Y];
    Caption:=IntToStr(Border[73])+' - '+IntToStr(X)+','+IntToStr(Y)+' = '+IntToStr(Line^[X*3]);
  end;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  Canvas.Draw(0,0,Bmp);
end;

end.
