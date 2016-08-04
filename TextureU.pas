unit TextureU;

interface

uses
  Windows, SysUtils, Dialogs, Bitmap, Graphics, Classes,
  OpenGL1X, OpenGLTokens;

const
  MaxImages = 11;
  StampW    = 168;
  StampH    = 56;

type
  TTexture = class(TObject)
  private

  public
    W,H      : Integer;
    Data     : PBmpData;
    Bmp      : TBitmap;
    HasAlpha : Boolean;
    Name     : GLUInt;

    constructor Create;
    destructor Destroy; override;

    procedure Load(FileName:String);
    procedure FreeData;
    procedure Apply;
    procedure Resize(iW,iH:Integer);
    procedure SetSize(iW,iH:Integer);
    procedure StretchCopyFromBmp(iBmp:TBitmap);
    procedure CopyFromBmp(iBmp:TBitmap);

    procedure Bind;
  end;

var
  AviTexture       : TTexture;
  LiveTexture      : TTexture;
  Texture          : array[1..MaxImages] of TTexture;
  TexturesLoaded   : Boolean;
  CountDownTexture : array[1..10] of TTexture;

procedure CreateTextures;
procedure LoadTextures;
procedure FreeTextures;

implementation

uses
  Routines, Jpeg, BmpUtils;

procedure CreateTextures;
var
  I : Integer;
begin
  for I:=1 to MaxImages do Texture[I]:=TTexture.Create;
  for I:=1 to 10 do CountDownTexture[I]:=TTexture.Create;
end;

procedure LoadTextures;
var
  I        : Integer;
  FileName : String;
  Bmp      : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    for I:=1 to MaxImages do begin
      FileName:=Path+'Images/'+'Sun'+IntToStr(I)+'.bmp';
      if FileExists(FileName) then begin
        Bmp.LoadFromFile(FileName);
        Bmp.PixelFormat:=pf24Bit;
      end
      else begin
        ClearBmp(Bmp,clBlack);
        Bmp.Canvas.Pen.Color:=clGray;
        CrossBmp(Bmp);
      end;
      Texture[I].CopyFromBmp(Bmp);
    end;
    for I:=1 to 10 do begin
      FileName:=Path+'Images/'+IntToStr(I)+'.bmp';
      if FileExists(FileName) then begin
        Bmp.LoadFromFile(FileName);
        Bmp.PixelFormat:=pf24Bit;
      end
      else begin
        ClearBmp(Bmp,clBlack);
        Bmp.Canvas.Pen.Color:=clGray;
        CrossBmp(Bmp);
      end;
      CountDownTexture[I].CopyFromBmp(Bmp);
    end;
  finally
    Bmp.Free;
  end;
  TexturesLoaded:=True;
end;

procedure LoadTextures2;
var
  I        : Integer;
  FileName : String;
  Bmp      : TBitmap;
  Jpg      : TJpegImage;
begin
  Bmp:=TBitmap.Create;
  Jpg:=TJpegImage.Create;
  try
    for I:=1 to MaxImages do begin
      FileName:=Path+'Images/'+'Sun'+IntToStr(I)+'.jpg';
      if FileExists(FileName) then begin
        Jpg.LoadFromFile(FileName);
        Bmp.Assign(Jpg);
        Bmp.PixelFormat:=pf24Bit;

//        FileName:=Path+'Images/'+'Sun'+IntToStr(I)+'.bmp';
//        Bmp.SaveToFile(FileName);
      end
      else begin
        ClearBmp(Bmp,clBlack);
        Bmp.Canvas.Pen.Color:=clGray;
        CrossBmp(Bmp);
      end;
      Texture[I].CopyFromBmp(Bmp);
    end;
  finally
    Bmp.Free;
    Jpg.Free;
  end;
  TexturesLoaded:=True;
end;

procedure FreeTextures;
var
  I : Integer;
begin
  for I:=1 to MaxImages do if Assigned(Texture[I]) then begin
    Texture[I].Free;
  end;
  for I:=1 to 10 do if Assigned(CountDownTexture[I]) then begin
    CountDownTexture[I].Free;
  end;
end;

constructor TTexture.Create;
begin
  inherited;
  Data:=nil;
  HasAlpha:=True;
  Bmp:=TBitmap.Create;
  Name:=0;
end;

destructor TTexture.Destroy;
begin
  FreeData;
  if Assigned(Bmp) then Bmp.Free;
  inherited;
end;

procedure TTexture.Resize(iW,iH:Integer);
begin
  W:=iW; H:=iH;
  Bmp.Width:=W;
  Bmp.Height:=H;
  FreeData;
  if HasAlpha then begin
    Bmp.PixelFormat:=pf32Bit;
    GetMem(Data,W*H*4);
  end
  else begin
    Bmp.PixelFormat:=pf24Bit;
    GetMem(Data,W*H*3);
  end;
end;

procedure TTexture.SetSize(iW,iH:Integer);
begin
  W:=iW; H:=iH;
  Bmp.Width:=W;
  Bmp.Height:=H;
  Bmp.PixelFormat:=pf24Bit;
  FreeData;
  GetMem(Data,W*H*3);
  glGenTextures(1,@Name);
  glBindTexture(GL_TEXTURE_2D,Name);
  Apply;
end;

procedure TTexture.FreeData;
begin
  if Name>0 then begin
    glDeleteTextures(1,@Name);
    Name:=0;
  end;
  if Assigned(Data) then begin
    FreeMem(Data);
    Data:=nil;
  end;
end;

procedure TTexture.Apply;
const
  GL_TEXTURE_RECTANGLE_EXT = $84F5;
begin
// set it to repeat in S and T
  glTexParameterI(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameterI(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

// set the filters
  glTexParameterI(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  glTexParameterI(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

 // glTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT,0,0,0,W,H,GL_RGB,GL_UNSIGNED_BYTE,Data);
//  glTexImage2D(GL_TEXTURE_2D,0,3,W,H,0,GL_RGB,GL_UNSIGNED_BYTE,Data);
  if HasAlpha then begin
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,W,H,0,GL_RGBA,GL_UNSIGNED_BYTE,Data);
  end
  else glTexImage2D(GL_TEXTURE_2D,0,3,W,H,0,GL_BGR,GL_UNSIGNED_BYTE,Data);
end;

procedure TTexture.Bind;
begin
  if Name=0 then begin
    glGenTextures(1,@Name);
    glBindTexture(GL_TEXTURE_2D,Name);
    Apply;
  end
  else glBindTexture(GL_TEXTURE_2D,Name);
end;

procedure TTexture.StretchCopyFromBmp(iBmp:TBitmap);
var
  DataPtr  : PByte;
  LineSize : Integer;
  Line     : PByteArray;
  X,Y,I    : Integer;
begin
  Bmp.Canvas.StretchDraw(Rect(0,0,Bmp.Width,Bmp.Height),iBmp);
  LineSize:=Bmp.Width*3;
  DataPtr:=PByte(Data);
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      DataPtr^:=Line^[I+2];
      Inc(DataPtr);
      DataPtr^:=Line^[I+1];
      Inc(DataPtr);
      DataPtr^:=Line^[I+0];
      Inc(DataPtr);
    end;
  end;
end;

procedure TTexture.CopyFromBmp(iBmp:TBitmap);
var
  DataPtr  : PByte;
  Line     : PByteArray;
  BPR      : Integer;
  SrcBpp,Y : Integer;
begin
  iBmp.PixelFormat:=pf24Bit;
  W:=iBmp.Width;
  H:=iBmp.Height;

  if Assigned(Data) then FreeMem(Data);
  HasAlpha:=False;
  BPR:=W*3;
  GetMem(Data,H*BPR);

  DataPtr:=PByte(Data);
  for Y:=0 to H-1 do begin
    Line:=iBmp.ScanLine[iBmp.Height-1-Y];
    Move(Line^,DataPtr^,BPR);
    Inc(DataPtr,BPR);
  end;

  Bmp.Width:=StampW;
  Bmp.Height:=StampH;
  Bmp.PixelFormat:=pf24Bit;
  Bmp.Canvas.StretchDraw(Rect(0,0,StampW,StampH),iBmp);
end;

procedure TTexture.Load(FileName:String);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.LoadFromFile(FileName);
    Bmp.PixelFormat:=pf24Bit;
    CopyFromBmp(Bmp);
  finally
    Bmp.Free;
  end;
end;

end.

procedure TTexture.CopyFromBmp(iBmp:TBitmap);
var
  DataPtr  : PByte;
  LineSize : Integer;
  Line     : PByteArray;
  X,Y,I    : Integer;
  Bpp      : Integer;
  SrcBpp   : Integer;
begin
  W:=iBmp.Width;
  H:=iBmp.Height;

  HasAlpha:=False;

  if Assigned(Data) then FreeMem(Data);
  if HasAlpha then Bpp:=4
  else Bpp:=3;
  GetMem(Data,W*H*Bpp);

  LineSize:=W*Bpp;

  if iBmp.PixelFormat=pf32Bit then SrcBpp:=4
  else SrcBpp:=3;

  DataPtr:=PByte(Data);
  for Y:=0 to H-1 do begin
    Line:=iBmp.ScanLine[iBmp.Height-1-Y];
    for X:=0 to W-1 do begin
      I:=X*SrcBpp;
      DataPtr^:=Line^[I+2];
      Inc(DataPtr);
      DataPtr^:=Line^[I+1];
      Inc(DataPtr);
      DataPtr^:=Line^[I+0];
      Inc(DataPtr);
      if HasAlpha then begin
        DataPtr^:=255;
        Inc(DataPtr);
      end;
    end;
  end;

  Bmp.Width:=StampW;
  Bmp.Height:=StampH;
  Bmp.PixelFormat:=pf24Bit;
  Bmp.Canvas.StretchDraw(Rect(0,0,StampW,StampH),iBmp);
end;



