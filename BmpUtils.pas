unit BmpUtils;

interface

uses
  Windows, Graphics, Global, ExtCtrls;

type
  T3x3StructuredElement = array[1..3,1..3] of Boolean;
  T2x2StructuredElement = array[1..2,1..2] of Boolean;

const
  Simple3x3Element : T3x3StructuredElement =
    ((True,True,True),(True,True,True),(True,True,True));

function  CreateImageBmp:TBitmap;
procedure ClearBmp(Bmp:TBitmap;Color:TColor);
procedure DrawSobelBmp(SrcBmp,SobelBmp:TBitmap;Threshold:Integer);
procedure DrawAnalogSobelBmp(SrcBmp,SobelBmp:TBitmap;Scale:Single);
procedure DrawShadows(Bmp:TBitmap;Threshold:Integer);
procedure DrawGradientBmp(SrcBmp,DestBmp:TBitmap;Threshold:Integer);
procedure DrawSmoothBmp(SrcBmp,DestBmp:TBitmap);
procedure DrawMonoBmp(SrcBmp,DestBmp:TBitmap);
procedure ErodeBmp3x3(SrcBmp,DestBmp:TBitmap;const Element:T3x3StructuredElement);
procedure DilateBmp3x3(SrcBmp,DestBmp:TBitmap;const Element:T3x3StructuredElement);
procedure SubtractBmp(Bmp1,Bmp2,Bmp3:TBitmap);
procedure IntensifyBmp(Bmp:TBitmap;Scale:Single);
procedure ThresholdBmp(Bmp:TBitmap;Threshold:Integer);
procedure ConvertBmpToIntensityMap(Bmp:TBitmap;Threshold:Byte);
procedure DrawHistogram(SourceBmp,DestBmp:TBitmap);
procedure DrawTextOnBmp(Bmp:TBitmap;TextStr:String);
procedure ShowFrameRateOnBmp(Bmp:TBitmap;FrameRate:Single);
procedure SubtractColorBmp(Bmp1,Bmp2,Bmp3:TBitmap);
procedure MagnifyScreen(Bmp:TBitmap;Scale:Integer);
procedure MagnifyCopy(SrcBmp,IBmp,DestBmp:TBitmap;Xc,Yc,Scale:Integer);
procedure SubtractBmpAsm(Bmp1,Bmp2,TargetBmp:TBitmap);
function  BytesPerPixel(Bmp:TBitmap):Integer;
procedure SubtractBmpAsmAbs(Bmp1,Bmp2,TargetBmp:TBitmap);
procedure SubtractBmpAsmAbs32Bit(Bmp1,Bmp2,TargetBmp:TBitmap);

procedure FlipBmp(SrcBmp,DestBmp:TBitmap);
procedure MirrorBmp(SrcBmp,DestBmp:TBitmap);
procedure FlipAndMirrorBmp(SrcBmp,DestBmp:TBitmap);
procedure OrientBmp(SrcBmp,DestBmp:TBitmap;FlipImage,MirrorImage:Boolean);

function  CreateBmpForPaintBox(PaintBox:TPaintBox):TBitmap;
procedure SubtractColorBmpAsmAbs(Bmp1,Bmp2,TargetBmp:TBitmap);

procedure DrawMonoBmpAsmWithThreshold(SrcBmp,TgtBmp:TBitmap;Threshold:Byte);

procedure DrawXHairs(Bmp:TBitmap;iColor:TColor;X,Y,R:Integer);
procedure CrossBmp(Bmp:TBitmap);
procedure DrawInverseBmp(SrcBmp,DestBmp:TBitmap);
procedure DrawStatic(Bmp:TBitmap);

implementation

uses
  SysUtils, Classes;

procedure DrawInverseBmp(SrcBmp,DestBmp:TBitmap);
var
  I,X,Y    : Integer;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
begin
  for Y:=0 to SrcBmp.Height-1 do begin
    SrcLine:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    for X:=0 to SrcBmp.Width-1 do begin
      I:=X*3;
      DestLine^[I+0]:=255-SrcLine^[I+0];
      DestLine^[I+1]:=255-SrcLine^[I+1];
      DestLine^[I+2]:=255-SrcLine^[I+2];
    end;
  end;
end;

//  ImageW = 659;
//  ImageH = 493;
procedure DrawStatic(Bmp:TBitmap);
var
  Value : Integer;
  Line  : PByteArray;
  X,Y,I : Integer;
begin
  Bmp.PixelFormat:=pf24Bit;

  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      Value:=Random($FFFFFF);//Value XOR (Value shr 12);
      I:=X*3;
      Line[I+0]:=Value shr 16;
      Line[I+1]:=(Value and $FF00) shr 8;
      Line[I+2]:=(Value and $FF);
    end;
  end;
end;

function CreateImageBmp:TBitmap;
begin
  Result:=TBitmap.Create;
  Result.Width:=MaxImageW;
  Result.Height:=MaxImageH;
  Result.PixelFormat:=pf24Bit;
  Result.Canvas.Brush.Color:=clBlack;
  Result.Canvas.Font.Color:=clWhite;
  Result.Canvas.Font.Size:=14;
end;

function CreateBmpForPaintBox(PaintBox:TPaintBox):TBitmap;
begin
  Result:=TBitmap.Create;
  Result.Width:=PaintBox.Width;
  Result.Height:=PaintBox.Height;
  Result.PixelFormat:=pf24Bit;
end;

procedure ClearBmp(Bmp:TBitmap;Color:TColor);
begin
  Bmp.Canvas.Brush.Color:=Color;
  Bmp.Canvas.FillRect(Rect(0,0,Bmp.Width,Bmp.Height));
end;

procedure DrawSobelBmp(SrcBmp,SobelBmp:TBitmap;Threshold:Integer);
var
  Line1     : PByteArray;
  Line2     : PByteArray;
  Line3     : PByteArray;
  SobelLine : PByteArray;
  S1,S2,S   : Integer;
  X,Y       : Integer;
  P1,P2,P3  : Integer;
  P4,P5,P6  : Integer;
  P7,P8,P9  : Integer;
begin
  SobelBmp.Canvas.Brush.Color:=clBlack;
  SobelBmp.Canvas.FillRect(Rect(0,0,SobelBmp.Width,SobelBmp.Height));
  for Y:=1 to SrcBmp.Height-2 do begin
    Line1:=SrcBmp.ScanLine[Y-1];
    Line2:=SrcBmp.ScanLine[Y];
    Line3:=SrcBmp.ScanLine[Y+1];
    SobelLine:=SobelBmp.ScanLine[Y];
    for X:=1 to SrcBmp.Width-2 do begin
      P1:=Line1^[(X-1)*3];  P2:=Line1^[X*3]; P3:=Line1^[(X+1)*3];
      P4:=Line2^[(X-1)*3];  P5:=Line2^[X*3]; P6:=Line2^[(X+1)*3];
      P7:=Line3^[(X-1)*3];  P8:=Line3^[X*3]; P9:=Line3^[(X+1)*3];
      S1:=P3+2*P6+P9-P1-2*P4-P7;
      S2:=P1+2*P2+P3-P7-2*P8-P9;
      S:=Sqr(S1)+Sqr(S2);
      if S>Threshold then SobelLine^[X*3+0]:=255;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Same as "DrawSobelBmp" except that the actual intensity value is scaled
// instead of set to 255 or 0
////////////////////////////////////////////////////////////////////////////////
procedure DrawAnalogSobelBmp(SrcBmp,SobelBmp:TBitmap;Scale:Single);
var
  Line1     : PByteArray;
  Line2     : PByteArray;
  Line3     : PByteArray;
  SobelLine : PByteArray;
  S1,S2,S   : Integer;
  X,Y       : Integer;
  P1,P2,P3  : Integer;
  P4,P5,P6  : Integer;
  P7,P8,P9  : Integer;
begin
  SobelBmp.Canvas.Brush.Color:=clBlack;
  SobelBmp.Canvas.FillRect(Rect(0,0,SobelBmp.Width,SobelBmp.Height));
  for Y:=1 to SrcBmp.Height-2 do begin
    Line1:=SrcBmp.ScanLine[Y-1];
    Line2:=SrcBmp.ScanLine[Y];
    Line3:=SrcBmp.ScanLine[Y+1];
    SobelLine:=SobelBmp.ScanLine[Y];
    for X:=1 to SrcBmp.Width-2 do begin
      P1:=Line1^[(X-1)*3];  P2:=Line1^[X*3]; P3:=Line1^[(X+1)*3];
      P4:=Line2^[(X-1)*3];  P5:=Line2^[X*3]; P6:=Line2^[(X+1)*3];
      P7:=Line3^[(X-1)*3];  P8:=Line3^[X*3]; P9:=Line3^[(X+1)*3];
      S1:=P3+2*P6+P9-P1-2*P4-P7;
      S2:=P1+2*P2+P3-P7-2*P8-P9;
      S:=Round((Sqr(S1)+Sqr(S2))*Scale);
      if S>255 then SobelLine^[X*3+0]:=255
      else SobelLine^[X*3+0]:=S;
    end;
  end;
end;

procedure DrawShadows(Bmp:TBitmap;Threshold:Integer);
const
  EdgeColor = clRed;
  MinSize = 3;
var
  X,Y,DarkY,LightY    : Integer;
  LookingForDark,Dark : Boolean;
  Intensity           : Single;
begin
  for X:=0 to Bmp.Width-1 do begin
    LookingForDark:=True;
    Y:=0; DarkY:=0; LightY:=0;
    Bmp.Canvas.Pen.Color:=EdgeColor;
    repeat
      Inc(Y,MinSize);
      Intensity:=Bmp.Canvas.Pixels[X,Y];
      Dark:=Intensity<Threshold;
      if LookingForDark and Dark then begin
        DarkY:=Y;

// back up until we're in the light again
        repeat
          Dec(DarkY);
          Intensity:=Bmp.Canvas.Pixels[X,DarkY] and $FF;
          Dark:=Intensity<Threshold;
        until (not Dark) or (DarkY=LightY);
        Bmp.Canvas.Pixels[X,DarkY]:=EdgeColor;
        DarkY:=Y;
        LookingForDark:=False;
      end
      else if (not LookingForDark) and (not Dark) then begin
        LightY:=Y;

// back up until we're in the dark again
        repeat
          Dec(LightY);
          Intensity:=Bmp.Canvas.Pixels[X,LightY] and $FF;
          Dark:=Intensity<Threshold;
        until Dark or (LightY=DarkY);
        Bmp.Canvas.Pixels[X,LightY+1]:=EdgeColor;
        LookingForDark:=True;
        LightY:=Y;
      end;
    until (Y+MinSize>=Bmp.Height-1);
  end;
end;

procedure DrawGradientBmp(SrcBmp,DestBmp:TBitmap;Threshold:Integer);
var
  X,Y,I1,I2   : Integer;
  Gx,Gy,Gt    : Single;
  Line1,Line2 : PByteArray;
  DestLine    : PByteArray;
begin
  DestBmp.Canvas.Brush.Color:=clBlack;
  DestBmp.Canvas.FillRect(Rect(0,0,DestBmp.Width,DestBmp.Height));
  for Y:=1 to SrcBmp.Height-1 do begin
    Line1:=SrcBmp.ScanLine[Y-1];
    Line2:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    for X:=1 to SrcBmp.Width-1 do begin
      I1:=Line2[X*3];
      I2:=Line2[(X-1)*3];
      Gx:=I1-I2;
      I2:=Line1[X*3];
      Gy:=I1-I2;
      Gt:=Sqr(Gx)+Sqr(Gy);
      if Gt>Threshold then DestLine[X*3]:=255;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// 123
// 456  Pixel #5 = (P2+P4+P5+P6+P8)/5
// 789
////////////////////////////////////////////////////////////////////////////////
procedure DrawSmoothBmp(SrcBmp,DestBmp:TBitmap);
var
  Line1,Line2,Line3 : PByteArray;
  DestLine          : PByteArray;
  X,Y,V4,V6,V,I     : Integer;
begin
  for Y:=0 to SrcBmp.Height-1 do begin
    if Y=0 then Line1:=SrcBmp.ScanLine[0]
    else Line1:=SrcBmp.ScanLine[Y-1];
    Line2:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    if Y=SrcBmp.Height-1 then Line3:=Line2
    else Line3:=SrcBmp.ScanLine[Y+1];
    for X:=0 to SrcBmp.Width-1 do begin
      I:=X*3;
      if X=0 then V4:=Line2[0]
      else V4:=Line2[I-3];
      if X=SrcBmp.Width-1 then V6:=Line2[I]
      else V6:=Line2[I+3];
      V:=(Line1[I]+V4+Line2[I]+V6+Line3[I]) div 5;
      if V>255 then V:=255;
      DestLine[I+0]:=V; // blue
      DestLine[I+1]:=V; // green
      DestLine[I+2]:=V; // red
    end;
  end;
end;

procedure DrawMonoBmp(SrcBmp,DestBmp:TBitmap);
var
  I,V,X,Y          : Integer;
  SrcLine,DestLine : PByteArray;
begin
  for Y:=0 to SrcBmp.Height-1 do begin
    SrcLine:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    for X:=0 to SrcBmp.Width-1 do begin
      I:=X*3;
      V:=SrcLine[I];
      DestLine[I+0]:=V;
      DestLine[I+1]:=V;
      DestLine[I+2]:=V;
    end;
  end;
end;

procedure DilateBmp3x3(SrcBmp,DestBmp:TBitmap;const Element:T3x3StructuredElement);
var
  X,Y  : Integer;
  Mark : array[0..ImageW-1,0..ImageH-1] of Boolean;
  Line : PByteArray;
begin
// clear it
  DestBmp.Canvas.Brush.Color:=clBlack;
  DestBmp.Canvas.FillRect(Rect(0,0,ImageW,ImageH));

// clear the Mark map
  FillChar(Mark,SizeOf(Mark),False);

// find the mark map
  for Y:=0 to ImageH-1 do begin
    Line:=SrcBmp.ScanLine[Y];
    for X:=0 to ImageW-1 do begin
      if Line^[X*3]>0 then begin

// top row
        if (Element[1,1]) and (X>0) and (Y>0) then Mark[X-1,Y-1]:=True;
        if (Element[2,1]) and (Y>0) then Mark[X,Y-1]:=True;
        if (Element[3,1]) and (X<ImageW-1) and (Y>0) then Mark[X+1,Y-1]:=True;

// middle row
        if (Element[1,2]) and (X>0) then Mark[X-1,Y]:=True;
        if (Element[2,2]) then Mark[X,Y]:=True;
        if (Element[3,2]) and (X<ImageW-1) then Mark[X+1,Y]:=True;

// bottom row
        if (Element[1,3]) and (X>0) and (Y<ImageH-1) then Mark[X-1,Y+1]:=True;
        if (Element[2,3]) and (Y<ImageH-1) then Mark[X,Y+1]:=True;
        if (Element[3,3]) and (X<ImageW-1) and (Y<ImageH-1) then Mark[X+1,Y+1]:=True;
      end;
    end;
  end;

// draw the bmp
  for Y:=0 to ImageH-1 do begin
    Line:=DestBmp.ScanLine[Y];
    for X:=0 to ImageW-1 do begin
      if Mark[X,Y] then Line[X*3]:=255;
    end;
  end;
end;

procedure ErodeBmp3x3(SrcBmp,DestBmp:TBitmap;const Element:T3x3StructuredElement);
var
  X,Y       : Integer;
  Mark      : array[0..ImageW-1,0..ImageH-1] of Boolean;
  Line1     : PByteArray;
  Line2     : PByteArray;
  Line3     : PByteArray;
  LocalMask : T3x3StructuredElement;
begin
// clear it
  DestBmp.Canvas.Brush.Color:=clBlack;
  DestBmp.Canvas.FillRect(Rect(0,0,ImageW,ImageH));

// clear the Mark map
  FillChar(Mark,SizeOf(Mark),False);

// find the mark map
  for Y:=1 to ImageH-2 do begin
    Line1:=SrcBmp.ScanLine[Y-1];
    Line2:=SrcBmp.ScanLine[Y];
    Line3:=SrcBmp.ScanLine[Y+1];
    for X:=1 to ImageW-2 do begin
      LocalMask[1,1]:=Line1^[(X-1)*3]>0;
      LocalMask[2,1]:=Line1^[X*3]>0;
      LocalMask[3,1]:=Line1^[(X+1)*3]>0;
      LocalMask[1,2]:=Line2^[(X-1)*3]>0;
      LocalMask[2,2]:=Line2^[X*3]>0;
      LocalMask[3,2]:=Line2^[(X+1)*3]>0;
      LocalMask[1,3]:=Line1^[(X-1)*3]>0;
      LocalMask[2,3]:=Line1^[X*3]>0;
      LocalMask[3,3]:=Line1^[(X+1)*3]>0;
      if (LocalMask[1,1]=Element[1,1]) and
         (LocalMask[2,1]=Element[2,1]) and
         (LocalMask[3,1]=Element[3,1]) and
         (LocalMask[1,2]=Element[1,2]) and
         (LocalMask[2,2]=Element[2,2]) and
         (LocalMask[3,2]=Element[3,2]) and
         (LocalMask[1,3]=Element[1,3]) and
         (LocalMask[2,3]=Element[2,3]) and
         (LocalMask[3,3]=Element[3,3]) then
      begin
        Mark[X,Y]:=True;
      end;
    end;
  end;

// draw the bmp
  for Y:=0 to ImageH-1 do begin
    Line1:=DestBmp.ScanLine[Y];
    for X:=0 to ImageW-1 do begin
      if Mark[X,Y] then Line1[X*3]:=255;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Bmp3 = Bmp1 - Bmp2
////////////////////////////////////////////////////////////////////////////////
procedure SubtractBmp(Bmp1,Bmp2,Bmp3:TBitmap);
var
  Line1,Line2,Line3 : PByteArray;
  X,Y,I,V           : Integer;
begin
  for Y:=0 to Bmp1.Height-1 do begin
    Line1:=Bmp1.ScanLine[Y];
    Line2:=Bmp2.ScanLine[Y];
    Line3:=Bmp3.ScanLine[Y];
    for X:=0 to Bmp1.Width-1 do begin
      I:=X*3;
      V:=Line1^[I]-Line2^[I];
      if V<0 then V:=0;
      Line3^[I+0]:=V;
      Line3^[I+1]:=V;
      Line3^[I+2]:=V;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Bmp3 = Bmp1 - Bmp2
////////////////////////////////////////////////////////////////////////////////
procedure SubtractColorBmp(Bmp1,Bmp2,Bmp3:TBitmap);
var
  Line1,Line2,Line3 : PByteArray;
  X,Y,I,V           : Integer;
begin
  for Y:=0 to Bmp1.Height-1 do begin
    Line1:=Bmp1.ScanLine[Y];
    Line2:=Bmp2.ScanLine[Y];
    Line3:=Bmp3.ScanLine[Y];
    for X:=0 to Bmp1.Width-1 do begin
      V:=0;
      for I:=X*3 to X*3+2 do begin
        V:=V+Abs(Line1^[I]-Line2^[I]);
      end;
      if V>255 then V:=255;
      for I:=X*3 to X*3+2 do Line3^[I]:=V;
    end;
  end;
end;

function ClipToByte(V:Single):Byte;
begin
  if V<0 then Result:=0
  else if V>255 then Result:=255
  else Result:=Round(V);
end;

procedure IntensifyBmp(Bmp:TBitmap;Scale:Single);
var
  I,X,Y : Integer;
  Line  : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      Line^[I+0]:=ClipToByte(Line^[I+0]*Scale);
      Line^[I+1]:=ClipToByte(Line^[I+1]*Scale);
      Line^[I+2]:=ClipToByte(Line^[I+2]*Scale);
    end;
  end;
end;

procedure ThresholdBmp(Bmp:TBitmap;Threshold:Integer);
var
  I,X,Y : Integer;
  Line  : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      if Line^[I+0]<Threshold then begin
        Line^[I+0]:=0;
        Line^[I+1]:=0;
        Line^[I+2]:=0;
      end;
    end;
  end;
end;

procedure ConvertBmpToIntensityMap(Bmp:TBitmap;Threshold:Byte);
var
  X,Y,V : Integer;
  Line  : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      if Line^[X*3]>Threshold then V:=$FF
      else V:=0;
      Line^[X*3+0]:=0; // blue
      Line^[X*3+1]:=V; // green
      Line^[X*3+2]:=V; // red
    end;
  end;
end;

procedure DrawHistogram(SourceBmp,DestBmp:TBitmap);
var
  Red   : array[0..255] of Integer;
  Green : array[0..255] of Integer;
  Blue  : array[0..255] of Integer;
  Line  : PByteArray;
  X,Y,I : Integer;
  Max   : Integer;
  R,G,B : Integer;
begin
  if SourceBmp.Width=0 then Exit;

// find the values
  FillChar(Red,SizeOf(Red),0);
  FillChar(Green,SizeOf(Green),0);
  FillChar(Blue,SizeOf(Blue),0);
  for Y:=0 to SourceBmp.Height-1 do begin
    Line:=SourceBmp.ScanLine[Y];
    for X:=0 to SourceBmp.Width-1 do begin
      I:=X*3;
      R:=Line^[I+2];
      G:=Line^[I+1];
      B:=Line^[I+0];
      Inc(Red[R]);
      Inc(Green[G]);
      Inc(Blue[B]);
    end;
  end;

// find the peak value for scaling
  Max:=0;
  for I:=0 to 255 do begin
    if Red[I]>Max then Max:=Red[I];
    if Green[I]>Max then Max:=Green[I];
    if Blue[I]>Max then Max:=Blue[I];
  end;

// draw the bmp
  with DestBmp.Canvas do begin

// clear it
    Brush.Color:=$C8FAFA;
    FillRect(Rect(0,0,DestBmp.Width,DestBmp.Height));

// draw the red
    for I:=0 to 255 do begin
      X:=Round(DestBmp.Width*I/255);
      Y:=Round(DestBmp.Height*(1-Red[I]/Max));
      Pen.Color:=clRed;
      if I=0 then MoveTo(X,Y)
      else LineTo(X,Y);
    end;

// draw the green
    for I:=0 to 255 do begin
      X:=Round(DestBmp.Width*I/255);
      Y:=Round(DestBmp.Height*(1-Green[I]/Max));
      Pen.Color:=clGreen;
      if I=0 then MoveTo(X,Y)
      else LineTo(X,Y);
    end;

// draw the blue
    for I:=0 to 255 do begin
      X:=Round(DestBmp.Width*I/255);
      Y:=Round(DestBmp.Height*(1-Blue[I]/Max));
      Pen.Color:=clBlue;
      if I=0 then MoveTo(X,Y)
      else LineTo(X,Y);
    end;
  end;
end;

procedure DrawTextOnBmp(Bmp:TBitmap;TextStr:String);
var
  X,Y : Integer;
begin
  with Bmp.Canvas do begin
    Font.Color:=clYellow;
    Font.Size:=10;
    Brush.Color:=clBlack;
    FillRect(Rect(0,0,Bmp.Width,Bmp.Height));
    X:=(Bmp.Width-TextWidth(TextStr)) div 2;
    Y:=(Bmp.Height-TextHeight(TextStr)) div 2;
    TextOut(X,Y,TextStr);
  end;
end;

procedure ShowFrameRateOnBmp(Bmp:TBitmap;FrameRate:Single);
begin
  with Bmp.Canvas do begin
    Font.Color:=clYellow;
    Font.Size:=8;
    Brush.Color:=clBlack;
    TextOut(5,Bmp.Height-15,FloatToStrF(FrameRate,ffFixed,9,3));
  end;  
end;

////////////////////////////////////////////////////////////////////////////////
// Magnifies a region of the screen around the mouse cursor.
// Source rect width = scale*bmp.width
// Source rect height = scale*bmp.height
//////////////////////////////////////////////////////////////////////////////////
procedure MagnifyScreen(Bmp:TBitmap;Scale:Integer);
var
  DeskTopHandle : THandle;
  DeskTopDC     : HDC;
  MousePt       : TPoint;
  SrcW,SrcH,X,Y : Integer;
begin
  GetCursorPos(MousePt);
  DeskTopHandle:=GetDeskTopWindow;
  if DeskTopHandle>0 then with Bmp do begin
    DeskTopDC:=GetDC(DeskTopHandle);
    SrcW:=Width div Scale;
    SrcH:=Height div Scale;
    X:=MousePt.X-SrcW div 2;
    Y:=MousePt.Y-SrcH div 2;
    StretchBlt(Canvas.Handle,0,0,Width,Height,DeskTopDC,X,Y,SrcW,SrcH,SRCCOPY);
  end;
end;

procedure MagnifyCopy(SrcBmp,IBmp,DestBmp:TBitmap;Xc,Yc,Scale:Integer);
const
  ShortR = 3;
  LongR  = 8;
var
  DeskTopHandle : THandle;
  SrcW,SrcH,X,Y : Integer;
begin
  SrcW:=DestBmp.Width div Scale;
  SrcH:=DestBmp.Height div Scale;
  X:=Xc-SrcW div 2;
  Y:=Yc-SrcH div 2;

// copy the source over onto the intermediate bmp
  BitBlt(IBmp.Canvas.Handle,0,0,SrcW,SrcH,SrcBmp.Canvas.Handle,X,Y,SrcCopy);

// draw some cross hairs in the middle
  with IBmp.Canvas do begin
    Pen.Color:=clLime;
    X:=SrcW div 2;
    Y:=SrcH div 2;
    MoveTo(X-LongR,Y);  LineTo(X-ShortR+1,Y);
    MoveTo(X+ShortR,Y); LineTo(X+LongR+1,Y);
    MoveTo(X,Y-LongR);  LineTo(X,Y-ShortR+1);
    MoveTo(X,Y+ShortR); LineTo(X,Y+LongR+1);
  end;

// stretch it onto the dest bmp
  StretchBlt(DestBmp.Canvas.Handle,0,0,DestBmp.Width,DestBmp.Height,
             IBmp.Canvas.Handle,0,0,SrcW,SrcH,SrcCopy);
end;

////////////////////////////////////////////////////////////////////////////////
// TargetBmp = Bmp1 - Bmp2
// They should probably all be the same size. :)
////////////////////////////////////////////////////////////////////////////////
procedure SubtractBmpAsm(Bmp1,Bmp2,TargetBmp:TBitmap);
var
  Bmp1Ptr,Bmp2Ptr : Pointer;
  TargetPtr       : Pointer;
  MaxX,Row        : DWord;
  BytesPerRow     : DWord;
begin
// Windows bitmaps start from the bottom
  Bmp1Ptr:=Bmp1.ScanLine[0];
  Bmp2Ptr:=Bmp2.ScanLine[0];
  TargetPtr:=TargetBmp.ScanLine[0];

// find how many bytes per row there are -> width*3 + a byte or two
  BytesPerRow:=Integer(Bmp1.ScanLine[0])-Integer(Bmp1.ScanLine[1]);
  MaxX:=Bmp1.Width*3;
  Row:=DWord(Bmp1.Height-2);
  asm
    PUSHA
    MOV   ESI, Bmp1Ptr           // ESI = Bmp1
    MOV   EBX, Bmp2Ptr           // EBX = Bmp2
    MOV   EDI, TargetPtr         // EDI = TargetBmp

@YLoop :
    MOV   EDX, 0                 // EDX = column offset

@XLoop :
    MOV   AL, BYTE Ptr[ESI+EDX]  // load bmp1's blue pixel
    SUB   AL, BYTE Ptr[EBX+EDX]  // subtract bmp2's blue pixel
    JNC   @Positive
    XOR   EAX, EAX // for non-abs

@Positive:
    MOV   BYTE Ptr[EDI+EDX+0], AL  // store it in the target's blue pixel
    MOV   BYTE Ptr[EDI+EDX+1], AL  // store it in the target's green pixel
    MOV   BYTE Ptr[EDI+EDX+2], AL  // store it in the target's red pixel

    ADD   EDX, 3                   // select the next pixel index
    CMP   EDX, MaxX                // done this row?
    JL    @XLoop                   // no: continue to the next pixel in the row

    SUB   ESI, BytesPerRow         // go to the next row
    SUB   EBX, BytesPerRow
    SUB   EDI, BytesPerRow

    DEC   DWord Ptr[Row]
    JGE   @YLOOP
    POPA
  end;
  with TargetBmp.Canvas do begin
    Pen.Color:=clBlack;
    MoveTo(0,TargetBmp.Height-1);
    LineTo(TargetBmp.Width,TargetBmp.Height-1);
  end;
end;

function BytesPerPixel(Bmp:TBitmap):Integer;
begin
  Case Bmp.PixelFormat of
    pf8Bit  : Result:=1;
    pf16Bit : Result:=2;
    pf24Bit : Result:=3;
    pf32Bit : Result:=4;
    else Result:=0;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// TargetBmp = Bmp1 - Bmp2
////////////////////////////////////////////////////////////////////////////////
procedure SubtractBmpAsmAbs(Bmp1,Bmp2,TargetBmp:TBitmap);
var
  Bmp1Ptr,Bmp2Ptr : Pointer;
  TargetPtr       : Pointer;
  MaxX,Row        : DWord;
  BytesPerRow     : DWord;
  Bpp             : Integer;
begin
// Windows bitmaps start from the bottom
  Bmp1Ptr:=Bmp1.ScanLine[0];
  Bmp2Ptr:=Bmp2.ScanLine[0];
  TargetPtr:=TargetBmp.ScanLine[0];

// find how many bytes per row there are -> width*4+ a byte or two
  BytesPerRow:=Integer(Bmp1.ScanLine[0])-Integer(Bmp1.ScanLine[1]);
  Bpp:=BytesPerPixel(Bmp1);
  MaxX:=Bmp1.Width*Bpp;
  Row:=DWord(Bmp1.Height-1);
  asm
    PUSHA
    MOV   ESI, Bmp1Ptr           // ESI = Bmp1
    MOV   EBX, Bmp2Ptr           // EBX = Bmp2
    MOV   EDI, TargetPtr         // EDI = TargetBmp

@YLoop :
    MOV   EDX, 0                 // EDX = column offset

@XLoop :
    MOV   AL, BYTE Ptr[ESI+EDX]  // load bmp1's blue pixel
    SUB   AL, BYTE Ptr[EBX+EDX]  // subtract bmp2's blue pixel
    JNC   @Positive
    MOV   AL, BYTE Ptr[EBX+EDX]  // load bmp2's blue pixel
    SUB   AL, BYTE Ptr[ESI+EDX]  // subtract bmp1's blue pixel

@Positive:
    MOV   BYTE Ptr[EDI+EDX+0], AL  // store it in the target's blue pixel
    MOV   BYTE Ptr[EDI+EDX+1], AL  // store it in the target's green pixel
    MOV   BYTE Ptr[EDI+EDX+2], AL  // store it in the target's red pixel

    ADD   EDX, Bpp                 // select the next pixel index
    CMP   EDX, MaxX                // done this row?
    JL    @XLoop                   // no: continue to the next pixel in the row

    SUB   ESI, BytesPerRow         // go to the next row
    SUB   EBX, BytesPerRow
    SUB   EDI, BytesPerRow

    DEC   DWord Ptr[Row]
    JGE   @YLOOP
    POPA
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// TargetBmp = Bmp1 - Bmp2
////////////////////////////////////////////////////////////////////////////////
procedure SubtractColorBmpAsmAbs(Bmp1,Bmp2,TargetBmp:TBitmap);
var
  Bmp1Ptr,Bmp2Ptr : Pointer;
  TargetPtr       : Pointer;
  MaxX,Row        : DWord;
  BytesPerRow     : DWord;
  Bpp             : Integer;
begin
// Windows bitmaps start from the bottom
  Bmp1Ptr:=Bmp1.ScanLine[0];
  Bmp2Ptr:=Bmp2.ScanLine[0];
  TargetPtr:=TargetBmp.ScanLine[0];

// find how many bytes per row there are -> width*4+ a byte or two
  BytesPerRow:=Integer(Bmp1.ScanLine[0])-Integer(Bmp1.ScanLine[1]);
  Bpp:=BytesPerPixel(Bmp1);
  MaxX:=Bmp1.Width*Bpp;
  Row:=DWord(Bmp1.Height-2);
  asm
    PUSHA
    MOV   ESI, Bmp1Ptr           // ESI = Bmp1
    MOV   EBX, Bmp2Ptr           // EBX = Bmp2
    MOV   EDI, TargetPtr         // EDI = TargetBmp

@YLoop :
    MOV   EDX, 0                 // EDX = column offset

@XLoop :
    MOV   AL, BYTE Ptr[ESI+EDX]  // load bmp1's blue pixel
    SUB   AL, BYTE Ptr[EBX+EDX]  // subtract bmp2's blue pixel
    JNC   @BluePositive
    MOV   AL, BYTE Ptr[EBX+EDX]  // load bmp2's blue pixel
    SUB   AL, BYTE Ptr[ESI+EDX]  // subtract bmp1's blue pixel

@BluePositive:
    MOV   BYTE Ptr[EDI+EDX+0], AL  // store it in the target's blue pixel

    MOV   AL, BYTE Ptr[ESI+EDX+1]  // load bmp1's green pixel
    SUB   AL, BYTE Ptr[EBX+EDX+1]  // subtract bmp2's green pixel
    JNC   @GreenPositive
    MOV   AL, BYTE Ptr[EBX+EDX+1]  // load bmp2's green pixel
    SUB   AL, BYTE Ptr[ESI+EDX+1]  // subtract bmp1's green pixel

@GreenPositive:
    MOV   BYTE Ptr[EDI+EDX+1], AL  // store it in the target's blue pixel

    MOV   AL, BYTE Ptr[ESI+EDX+2]  // load bmp1's red pixel
    SUB   AL, BYTE Ptr[EBX+EDX+2]  // subtract bmp2's red pixel
    JNC   @RedPositive
    MOV   AL, BYTE Ptr[EBX+EDX+2]  // load bmp2's red pixel
    SUB   AL, BYTE Ptr[ESI+EDX+2]  // subtract bmp1's red pixel

@RedPositive:
    MOV   BYTE Ptr[EDI+EDX+2], AL  // store it in the target's red pixel

    ADD   EDX, Bpp                 // select the next pixel index
    CMP   EDX, MaxX                // done this row?
    JL    @XLoop                   // no: continue to the next pixel in the row

    SUB   ESI, BytesPerRow         // go to the next row
    SUB   EBX, BytesPerRow
    SUB   EDI, BytesPerRow

    DEC   DWord Ptr[Row]
    JGE   @YLOOP
    POPA
  end;
end;

procedure SubtractBmpAsmAbs32Bit(Bmp1,Bmp2,TargetBmp:TBitmap);
var
  Bmp1Ptr,Bmp2Ptr : Pointer;
  TargetPtr       : Pointer;
  MaxX,Row        : DWord;
  BytesPerRow     : DWord;
  Bpp             : Integer;
begin
// Windows bitmaps start from the bottom
  Bmp1Ptr:=Bmp1.ScanLine[0];
  Bmp2Ptr:=Bmp2.ScanLine[0];
  TargetPtr:=TargetBmp.ScanLine[0];

// find how many bytes per row there are -> width*4+ a byte or two
  BytesPerRow:=Integer(Bmp1.ScanLine[0])-Integer(Bmp1.ScanLine[1]);
  Bpp:=BytesPerPixel(Bmp1);
  MaxX:=Bmp1.Width*Bpp;
  Row:=DWord(Bmp1.Height-2);
  asm
    PUSHA
    MOV   ESI, Bmp1Ptr           // ESI = Bmp1
    MOV   EBX, Bmp2Ptr           // EBX = Bmp2
    MOV   EDI, TargetPtr         // EDI = TargetBmp

@YLoop :
    MOV   EDX, 0                 // EDX = column offset

@XLoop :
    MOV   AL, BYTE Ptr[ESI+EDX]  // load bmp1's blue pixel
    SUB   AL, BYTE Ptr[EBX+EDX]  // subtract bmp2's blue pixel
    JNC   @Positive
    MOV   AL, BYTE Ptr[EBX+EDX]  // load bmp2's blue pixel
    SUB   AL, BYTE Ptr[ESI+EDX]  // subtract bmp1's blue pixel

@Positive:
    MOV   BYTE Ptr[EDI+EDX+0], AL  // store it in the target's blue pixel
    MOV   BYTE Ptr[EDI+EDX+1], AL  // store it in the target's green pixel
    MOV   BYTE Ptr[EDI+EDX+2], AL  // store it in the target's red pixel

    ADD   EDX, Bpp                 // select the next pixel index
    CMP   EDX, MaxX                // done this row?
    JL    @XLoop                   // no: continue to the next pixel in the row

    SUB   ESI, BytesPerRow         // go to the next row
    SUB   EBX, BytesPerRow
    SUB   EDI, BytesPerRow

    DEC   DWord Ptr[Row]
    JGE   @YLOOP
    POPA
  end;
end;

procedure FlipBmp(SrcBmp,DestBmp:TBitmap);
var
  Bpr,Y    : Integer;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
begin
  Bpr:=BytesPerPixel(SrcBmp)*SrcBmp.Width;
  for Y:=0 to SrcBmp.Height-1 do begin
    SrcLine:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[SrcBmp.Height-1-Y];
    Move(SrcLine^,DestLine^,Bpr);
  end;
end;

procedure FlipAndMirrorBmp(SrcBmp,DestBmp:TBitmap);
var
  Bpp,X,Y  : Integer;
  DestX    : Integer;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
begin
  Bpp:=BytesPerPixel(SrcBmp);
  for Y:=0 to SrcBmp.Height-1 do begin
    SrcLine:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[SrcBmp.Height-1-Y];
    DestX:=SrcBmp.Width-1;
    for X:=0 to SrcBmp.Width-1 do begin
      Move(SrcLine^[X*Bpp],DestLine^[DestX*Bpp],Bpp);
      Dec(DestX);
    end;
  end;
end;

procedure MirrorBmp(SrcBmp,DestBmp:TBitmap);
var
  Bpr,X,Y  : Integer;
  DestX    : Integer;
  Bpp      : Integer;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
begin
  Bpp:=BytesPerPixel(SrcBmp);
  Bpr:=Bpp*SrcBmp.Width;
  for Y:=0 to SrcBmp.Height-1 do begin
    SrcLine:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    DestX:=SrcBmp.Width-1;
    for X:=0 to SrcBmp.Width-1 do begin
      Move(SrcLine^[X*Bpp],DestLine^[DestX*Bpp],3);
      Dec(DestX);
    end;
  end;
end;

procedure OrientBmp(SrcBmp,DestBmp:TBitmap;FlipImage,MirrorImage:Boolean);
begin
  if FlipImage then begin
    if MirrorImage then FlipAndMirrorBmp(SrcBmp,DestBmp)
    else FlipBmp(SrcBmp,DestBmp);
  end
  else if MirrorImage then MirrorBmp(SrcBmp,DestBmp)
  else DestBmp.Canvas.Draw(0,0,SrcBmp);
end;

////////////////////////////////////////////////////////////////////////////////
// TargetBmp = Bmp1 - Bmp2
// They should probably all be the same size. :)
////////////////////////////////////////////////////////////////////////////////
procedure DrawMonoBmpAsm(SrcBmp,TgtBmp:TBitmap);
var
  SrcPtr,TgtPtr : Pointer;
  MaxX,Row      : DWord;
  BytesPerRow   : DWord;
begin
// Windows bitmaps start from the bottom
  SrcPtr:=SrcBmp.ScanLine[0];
  TgtPtr:=TgtBmp.ScanLine[0];

// find how many bytes per row there are -> width*3 + a byte or two
  BytesPerRow:=Integer(TgtBmp.ScanLine[0])-Integer(TgtBmp.ScanLine[1]);
  MaxX:=TgtBmp.Width*3;
  Row:=DWord(TgtBmp.Height-2);
  asm
    PUSHA
    MOV   ESI, SrcPtr           // ESI = SrcBmp
    MOV   EDI, TgtPtr           // EDI = TgtBmp

@YLoop :
    MOV   EDX, 0                 // EDX = column offset

@XLoop :
    MOV   AL, BYTE Ptr[ESI+EDX+0]  // load bmp's blue pixel
    MOV   BYTE Ptr[EDI+EDX+0], AL  // store it in the target's blue pixel
    MOV   BYTE Ptr[EDI+EDX+1], AL  // store it in the target's green pixel
    MOV   BYTE Ptr[EDI+EDX+2], AL  // store it in the target's red pixel

    ADD   EDX, 3                   // select the next pixel index
    CMP   EDX, MaxX                // done this row?
    JL    @XLoop                   // no: continue to the next pixel in the row

    SUB   ESI, BytesPerRow         // go to the next row
    SUB   EDI, BytesPerRow         // go to the next row

    DEC   DWord Ptr[Row]
    JGE   @YLOOP
    POPA
  end;
  with TgtBmp.Canvas do begin
    Pen.Color:=clBlack;
    MoveTo(0,TgtBmp.Height-1);
    LineTo(TgtBmp.Width,TgtBmp.Height-1);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// TargetBmp = Bmp1 - Bmp2
// They should probably all be the same size. :)
////////////////////////////////////////////////////////////////////////////////
procedure DrawMonoBmpAsmWithThreshold(SrcBmp,TgtBmp:TBitmap;Threshold:Byte);
var
  SrcPtr,TgtPtr : Pointer;
  MaxX,Row      : DWord;
  BytesPerRow   : DWord;
begin
// Windows bitmaps start from the bottom
  SrcPtr:=SrcBmp.ScanLine[0];
  TgtPtr:=TgtBmp.ScanLine[0];

// find how many bytes per row there are -> width*3 + a byte or two
  BytesPerRow:=Integer(TgtBmp.ScanLine[0])-Integer(TgtBmp.ScanLine[1]);
  MaxX:=TgtBmp.Width*3;
  Row:=DWord(TgtBmp.Height-2);
  asm
    PUSHA
    MOV   ESI, SrcPtr           // ESI = SrcBmp
    MOV   EDI, TgtPtr           // EDI = TgtBmp

@YLoop :
    MOV   EDX, 0                 // EDX = column offset

@XLoop :
    MOV   AL, BYTE Ptr[ESI+EDX+0]  // load bmp's blue pixel
    CMP   AL, Threshold
    JGE   @OverThreshold
    XOR   AL, AL

@OverThreshold :
    MOV   BYTE Ptr[EDI+EDX+0], AL  // store it in the target's blue pixel
    MOV   BYTE Ptr[EDI+EDX+1], AL  // store it in the target's green pixel
    MOV   BYTE Ptr[EDI+EDX+2], AL  // store it in the target's red pixel

    ADD   EDX, 3                   // select the next pixel index
    CMP   EDX, MaxX                // done this row?
    JL    @XLoop                   // no: continue to the next pixel in the row

    SUB   ESI, BytesPerRow         // go to the next row
    SUB   EDI, BytesPerRow         // go to the next row

    DEC   DWord Ptr[Row]
    JGE   @YLOOP
    POPA
  end;
  with TgtBmp.Canvas do begin
    Pen.Color:=clBlack;
    MoveTo(0,TgtBmp.Height-1);
    LineTo(TgtBmp.Width,TgtBmp.Height-1);
  end;
end;

procedure CrossBmp(Bmp:TBitmap);
begin
  with Bmp do begin
    Canvas.MoveTo(0,0);
    Canvas.LineTo(Width,Height);
    Canvas.MoveTo(Width,0);
    Canvas.LineTo(0,Height);
  end;
end;

procedure DrawXHairs(Bmp:TBitmap;iColor:TColor;X,Y,R:Integer);
begin
  with Bmp.Canvas do begin
    Pen.Color:=iColor;
    MoveTo(X-R,Y);
    LineTo(X+R+1,Y);
    MoveTo(X,Y-R);
    LineTo(X,Y+R+1);
  end;
end;

end.



