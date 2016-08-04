unit FreeImageUtils;

interface

uses
  SysUtils, FreeImage, Graphics, Global;

procedure DrawBmpOnFreeImage(Bmp:TBitmap;Image:PFiBitmap);
procedure DrawFreeImageOnBmp(Image:PFiBitmap;DestBmp:TBitmap);

implementation

procedure DrawBmpOnFreeImage(Bmp:TBitmap;Image:PFiBitmap);
var
  DestPtr : PByte;
  SrcLine : PByteArray;
  Y,Bpr   : Integer;
begin
  Bpr:=Bmp.Width*3;
  for Y:=0 to Bmp.Height-1 do begin
    SrcLine:=Bmp.ScanLine[Y];
    DestPtr:=FreeImage_GetScanLine(Image,Y);
    Move(SrcLine^,DestPtr^,Bpr);
  end;
end;

procedure DrawFreeImageOnBmp(Image:PFiBitmap;DestBmp:TBitmap);
var
  Y        : Integer;
  DestLine : PByteArray;
  SrcPtr   : PByte;
begin
  for Y:=0 to DestBmp.Height-1 do begin
    SrcPtr:=FreeImage_GetScanLine(Image,Y);
    DestLine:=DestBmp.ScanLine[Y];
    Move(SrcPtr^,DestLine^,DestBmp.Width*3);
  end;
end;

end.
