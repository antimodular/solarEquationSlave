unit IplUtils;

interface

uses
  Global, Ipl, Graphics, SysUtils, OpenCV;

function CreateColorIplImage(W,H:Integer):PIplImage;
function CreateMonoIplImage(W,H:Integer):PIplImage;

procedure DrawQuarterSizeBmpFromImage(Bmp:TBitmap;Image:PIplImage);

function  CopySubImage(Image:PIplImage;X,Y,W,H:Integer):PIplImage;

function IplImageFromBmp(Bmp:TBitmap):PIplImage;
procedure DrawBmpOnQuarterSizedIplMonoImage(Bmp:TBitmap;Image:PIplImage);

procedure DrawMonoIplImageOnBmp(Image:PIplImage;Bmp:TBitmap);
procedure DrawMonoIplImageOnBmpAtXY(Image:PIplImage;Bmp:TBitmap;X,Y:Integer);

procedure DrawPartOfMonoIplImageOnBmp(Image:PIplImage;Bmp:TBitmap;Rect:CvRect);

procedure SaveSubImage(Image:PIplImage;Rect:CvRect);

implementation

function CreateColorIplImage(W,H:Integer):PIplImage;
begin
// create an IPL image from this header
  Result:=iplCreateImageHeader(
    3,                    // number of channels
    0,                    // no alpha channel
    IPL_DEPTH_8U,         // data of byte type
    'RGB',                // color model
    'BGR',                // color order
    IPL_DATA_ORDER_PIXEL, // channel arrangement
    IPL_ORIGIN_TL,        // top left orientation
    IPL_ALIGN_DWORD,      // 8 bytes align
    W,                    // image width
    H,                    // image height
    nil,                  // no ROI
    nil,                  // no mask ROI
    nil,                  // no image ID
    nil);                 // not tiled

// allocate storage for the data
  iplAllocateImage(Result,0,0);
end;

function CreateMonoIplImage(W,H:Integer):PIplImage;
begin
// create an IPL image from this header
  Result:=iplCreateImageHeader(
    1,                    // number of channels
    0,                    // no alpha channel
    IPL_DEPTH_8U,         // data of byte type
    'RGB',                // color model
    'BGR',                // color order
    IPL_DATA_ORDER_PIXEL, // channel arrangement
    IPL_ORIGIN_TL,        // top left orientation
    IPL_ALIGN_DWORD,      // 8 bytes align
    W,                    // image width
    H,                    // image height
    nil,                  // no ROI
    nil,                  // no mask ROI
    nil,                  // no image ID
    nil);                 // not tiled

// allocate storage for the data
  IplAllocateImage(Result,0,0);
end;

procedure DrawQuarterSizeBmpFromImage(Bmp:TBitmap;Image:PIplImage);
var
  X,Y,I,SrcI : Integer;
  Line       : PByteArray;
  SrcLine    : PByteArray;
  SrcPtr     : PByte;
begin
  if Bmp.Width<>(Image^.Width shr 2) then begin
    Bmp.Width:=Image^.Width shr 2;
    Bmp.Height:=Image^.Height shr 2;
  end;

  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    SrcPtr:=Image^.ImageData;
    Inc(SrcPtr,Y*4*Image^.WidthStep);
    SrcLine:=PByteArray(SrcPtr);
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      SrcI:=I*4;
      Line^[I]:=SrcLine^[SrcI];
      Line^[I+1]:=SrcLine^[SrcI+1];
      Line^[I+2]:=SrcLine^[SrcI+2];
    end;
  end;
end;

function CopySubImage(Image:PIplImage;X,Y,W,H:Integer):PIplImage;
var
  SubImage       : PIplImage;
  SrcPtr,DestPtr : PByte;
  SrcBpp,DestBpp : Integer;
  SrcBpr,DestBpr : Integer;
  XL,YL          : Integer;
begin
// make a color sub image
  SubImage:=CreateColorIplImage(W,H);
  DestPtr:=SubImage^.ImageData;
  DestBpr:=SubImage^.WidthStep;
  DestBpp:=SubImage^.NChannels+SubImage^.AlphaChannel;

// copy the data over
  SrcBpr:=Image^.WidthStep;
  SrcBpp:=Image^.NChannels+Image^.AlphaChannel;
  for YL:=Y to Y+H-1 do begin
    SrcPtr:=Image^.ImageData;
    Inc(SrcPtr,Y*SrcBpr+X*SrcBpp);
    for XL:=X to X+W-1 do begin
      Move(SrcPtr^,DestPtr^,DestBpr);
      Inc(SrcPtr,SrcBpp);
      Inc(DestPtr,SrcBpp);
    end;
  end;
  Result:=SubImage;
end;

procedure DrawBmpOnMonoIplImage(Bmp:TBitmap;IplImage:PIplImage);
var
  I,X,Y   : Integer;
  DestPtr : PByte;
  Line    : PByteArray;
begin
  DestPtr:=IplImage^.ImageData;
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      DestPtr^:=Round((Line^[I+0]+Line^[I+1]+Line^[I+2])/3);
      Inc(DestPtr);
    end;
  end;
end;

procedure DrawBmpOnIplImage(Bmp:TBitmap;IplImage:PIplImage);
type
  TPixelData = array[1..High(Integer)] of Byte;
  PPixelData = ^TPixelData;
var
  Size    : Integer;
  I,X,Y   : Integer;
  DestPtr : PPixelData;
  Line    : PByteArray;
begin
// copy the data over
  Size:=IplImage^.ImageSize;
  DestPtr:=PPixelData(IplImage^.ImageData);

  I:=1; X:=0; Y:=0;
  Line:=Bmp.ScanLine[Y];
  repeat
    Inc(I);
    DestPtr^[I]:=(Line^[X*3+0]+Line^[X*3+1]+Line^[X*3+2]) div 3;
    if X<(Bmp.Width-1) then Inc(X)
    else begin
      X:=0;
      Inc(Y);
      if Y<Bmp.Height then Line:=Bmp.ScanLine[Y];
    end;
  until (I=Size);
end;

function IplImageFromBmp(Bmp:TBitmap):PIplImage;
begin
  Result:=CreateMonoIplImage(Bmp.Width,Bmp.Height);
  DrawBmpOnMonoIplImage(Bmp,Result);
end;

//procedure MakeScale

procedure DrawBmpOnQuarterSizedIplMonoImage(Bmp:TBitmap;Image:PIplImage);
var
  X,Ys,Yd,I : Integer;
  SrcLine   : PByteArray;
  DestPtr   : PByte;
begin
  Ys:=0;
  DestPtr:=Image^.ImageData;
  for Yd:=0 to Image^.Height-1 do begin
    SrcLine:=Bmp.ScanLine[Ys];
    I:=0;
    for X:=0 to Image^.Width-1 do begin
      DestPtr^:=Round((SrcLine^[I]+SrcLine^[I+1]+SrcLine^[I+3])/3);
      Inc(DestPtr);
      Inc(I,6);
    end;
    Inc(Ys,2);
  end;
end;

procedure DrawMonoIplImageOnBmp(Image:PIplImage;Bmp:TBitmap);
var
  SrcPtr   : PByte;
  SrcBpr   : Integer;
  DestLine : PByteArray;
  X,Y,I    : Integer;
begin
  SrcBpr:=Image^.WidthStep;
  for Y:=0 to Image^.Height-1 do begin
    SrcPtr:=Image^.ImageData;
    Inc(SrcPtr,Y*SrcBpr);
    DestLine:=Bmp.ScanLine[Y];
    I:=0;
    for X:=0 to Image^.Width-1 do begin
      DestLine^[I+0]:=SrcPtr^;
      DestLine^[I+1]:=SrcPtr^;
      DestLine^[I+2]:=SrcPtr^;
      Inc(I,3);
      Inc(SrcPtr);
    end;
  end;
end;

procedure DrawMonoIplImageOnBmpAtXY(Image:PIplImage;Bmp:TBitmap;X,Y:Integer);
var
  SrcPtr   : PByte;
  SrcBpr   : Integer;
  DestLine : PByteArray;
  C,R,I    : Integer;
begin
  SrcBpr:=Image^.WidthStep;
  for R:=0 to Image^.Height-1 do begin
    SrcPtr:=Image^.ImageData;
    Inc(SrcPtr,R*SrcBpr);
    DestLine:=Bmp.ScanLine[Y+R];
    I:=X*3;
    for C:=0 to Image^.Width-1 do begin
      DestLine^[I+0]:=SrcPtr^;
      DestLine^[I+1]:=SrcPtr^;
      DestLine^[I+2]:=SrcPtr^;
      Inc(I,3);
      Inc(SrcPtr);
    end;
  end;
end;

procedure DrawPartOfMonoIplImageOnBmp(Image:PIplImage;Bmp:TBitmap;Rect:CvRect);
var
  SrcPtr   : PByte;
  DestLine : PByteArray;
  X,Y,I    : Integer;
  SrcX     : Integer;
  SrcY     : Integer;
begin
  SrcX:=Rect.X-(Rect.Width shr 1);
  SrcY:=Rect.Y-(Rect.Height shr 1);

  for Y:=0 to Rect.Height-1 do begin
    SrcPtr:=Image^.ImageData;
    Inc(SrcPtr,(SrcY+Y)*Image.Width+SrcX);
    DestLine:=Bmp.ScanLine[Y];
    I:=0;
    for X:=0 to Rect.Width-1 do begin
      DestLine^[I+0]:=SrcPtr^;
      DestLine^[I+1]:=SrcPtr^;
      DestLine^[I+2]:=SrcPtr^;
      Inc(I,3);
      Inc(SrcPtr);
    end;
  end;
end;

procedure SaveSubImage(Image:PIplImage;Rect:CvRect);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.Width:=Rect.Width;
    Bmp.Height:=Rect.Height;
    Bmp.PixelFormat:=pf24Bit;
    DrawPartOfMonoIplImageOnBmp(Image,Bmp,Rect);
    Bmp.SaveToFile('c:\Test.bmp');
  finally
    Bmp.Free;
  end;
end;


end.
