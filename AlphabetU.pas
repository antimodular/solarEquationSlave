unit AlphabetU;

interface

uses
  SysUtils, Types, TextureU, Graphics, OpenGL1X, OpenGLTokens, Global;

const
  TextureW = 256;
  TextureH = TextureW;

  LoChar = $21;
  HiChar = $7E;

type
  TTextureArray = array[0..255] of TTexture;

  TBorderArray = array[0..255] of Integer;

  TFontName = String[64];

  TAlphabetInfo = packed record
    FontName : TFontName;
    Style    : TFontStyles;
  end;

  TAlphabet = class(TObject)
  private
    Texture        :  GLUInt;
    TexturesStored : Boolean;

    function  BmpPath:String;
    procedure CreateTextureArray;
    procedure CopyBmpIntoTextureArray(Bmp:TBitmap;Index:Integer);
    procedure CopyBmpIntoTextureArraySideways(Bmp:TBitmap;Index:Integer);
    procedure BuildTextureArray;
    procedure FindBorder(Bmp:TBitmap;I:Integer);
    procedure ReserveTextureArray;
    procedure DrawBorder(Bmp: TBitmap; I: Integer);

  public
    Border : TBorderArray;

    constructor Create;
    destructor  Destroy; override;

    procedure AssertTextureArray;
    procedure PrepareForShow;
  end;

var
  Alphabet : TAlphabet;

implementation

uses
  Routines, BmpUtils;

constructor TAlphabet.Create;
begin
  inherited;

  Texture:=0;
end;

destructor TAlphabet.Destroy;
begin
  if Texture>0 then glDeleteTextures(1,@Texture);

  inherited;
end;

function TAlphabet.BmpPath:String;
begin
  Result:=Path+'Bmps\';
end;

procedure TAlphabet.CreateTextureArray;
var
  I : Integer;
begin
// create it and bind it as a texture array
  glGenTextures(1,@Texture);
  glBindTexture(GL_TEXTURE_2D_ARRAY,Texture);

// clamp it in S and T
  glTexParameterI(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
  glTexParameterI(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);

// set the filters
  glTexParameterI(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameterI(GL_TEXTURE_2D_ARRAY,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
end;

procedure TAlphabet.CopyBmpIntoTextureArray(Bmp:TBitmap;Index:Integer);
const
  Bpp = 3;
var
  Data    : PByte;
  DataPtr : PRGBAPixel;
  I,X,Y   : Integer;
  Size    : Integer;
  Line    : PByteArray;
begin
// get memory for the bmp data
  Size:=Bmp.Width*Bmp.Height*4;
  GetMem(Data,Size);
  try

// copy the bmp into the data
    DataPtr:=PRGBAPixel(Data);
    for Y:=0 to Bmp.Height-1 do begin
      Line:=Bmp.ScanLine[Y];
      for X:=0 to Bmp.Width-1 do begin
        I:=X*Bpp;

        DataPtr^.R:=Line^[I+2];
        DataPtr^.G:=Line^[I+1];
        DataPtr^.B:=Line^[I+0];

        DataPtr^.A:=ClipToByte((DataPtr^.R+DataPtr^.G+DataPtr^.B)/3);

//        if (Line^[I+2]=0) and (Line^[I+1]=0) and (DataPtr^.B=0) then begin
//          DataPtr^.A:=0;
//        end
//        else DataPtr^.A:=255;
//        DataPtr^.A:=DataPtr^.R; //255;
        Inc(DataPtr);
      end;
    end;

// store it on the GPU
    glTexSubImage3D(GL_TEXTURE_2D_ARRAY,0,0,0,Index,Bmp.Width,Bmp.Height,1,
                    GL_RGBA,GL_UNSIGNED_BYTE,Data);
  finally
    FreeMem(Data);
  end;
end;

procedure TAlphabet.CopyBmpIntoTextureArraySideways(Bmp:TBitmap;Index:Integer);
const
  Bpp = 3;
var
  Data    : PByte;
  DataPtr : PRGBAPixel;
  I,X,Y   : Integer;
  Size    : Integer;
  Line    : PByteArray;
begin
// get memory for the bmp data
  Size:=Bmp.Width*Bmp.Height*4;
  GetMem(Data,Size);
  try

// copy the bmp into the data
    DataPtr:=PRGBAPixel(Data);
    for X:=Bmp.Width-1 downto 0 do begin
      I:=X*Bpp;
      for Y:=0 to Bmp.Height-1 do begin
        Line:=Bmp.ScanLine[Y];

        DataPtr^.R:=Line^[I+2];
        DataPtr^.G:=Line^[I+1];
        DataPtr^.B:=Line^[I+0];

        DataPtr^.A:=ClipToByte((DataPtr^.R+DataPtr^.G+DataPtr^.B)/3);

        Inc(DataPtr);
      end;
    end;

// store it on the GPU
    glTexSubImage3D(GL_TEXTURE_2D_ARRAY,0,0,0,Index,Bmp.Width,Bmp.Height,1,
                    GL_RGBA,GL_UNSIGNED_BYTE,Data);
  finally
    FreeMem(Data);
  end;
end;

procedure TAlphabet.FindBorder(Bmp:TBitmap;I:Integer);
var
  X,Y   : Integer;
  Line  : PByteArray;
  Found : Boolean;
begin
  Border[I]:=TextureW;
  for Y:=0 to TextureH-1 do begin
    Line:=Bmp.ScanLine[Y];

// look for a lit pixel in this row
    Found:=False;
    X:=0;
    repeat
      if Line^[X*4]>0 then Found:=True
      else Inc(X);
    until Found or (X=TextureW);

// if we found one and it's < the current, update it
    if Found and (X<Border[I]) then Border[I]:=X;
  end;
end;

procedure TAlphabet.DrawBorder(Bmp:TBitmap;I:Integer);
begin
  with Bmp.Canvas do begin
    Brush.Color:=clRed;
    FillRect(Rect(0,0,Border[I],Bmp.Height));
  end;
end;

// reserve GPU memory for our texture array
procedure TAlphabet.ReserveTextureArray;
var
  Count : Integer;
begin
  Count:=HiChar-LoChar+1;
  glTexImage3D(GL_TEXTURE_2D_ARRAY,0,GL_RGBA,TextureW,TextureH,Count,0,
               GL_RGB,GL_UNSIGNED_BYTE,nil);
end;

procedure TAlphabet.BuildTextureArray;
var
  Bmp   : TBitmap;
  I     : Integer;
  Txt   : String;
  X,Y   : Integer;
begin
// create a bmp
  Bmp:=TBitmap.Create;
  try
//  MakeCanvasTextSideways(Bmp.Canvas);

// initialize the bmp
    Bmp.Width:=TextureW;
    Bmp.Height:=TextureH;

    Bmp.PixelFormat:=pf32Bit;
    Bmp.Canvas.Font.Name:='Arial';
    Bmp.Canvas.Font.Size:=112;
    Bmp.Canvas.Font.Color:=clWhite;

// generate the character set
    for I:=LoChar to HiChar do begin
      ClearBmp(Bmp,clBlack);
      Txt:=Char(I);
      X:=(Bmp.Width-Bmp.Canvas.TextWidth(Txt)) div 2;
      Y:=(Bmp.Height-Bmp.Canvas.TextHeight(Txt)) div 2;
      Bmp.Canvas.TextOut(X,Y,Txt);
      FindBorder(Bmp,I);
//DrawBorder(Bmp,I);
//Bmp.SaveToFile('Bmps/'+ThreeDigitIntStr(I)+'.bmp');

// copy it into the GPU
//      CopyBmpIntoTextureArray(Bmp,I-LoChar);
      CopyBmpIntoTextureArraySideways(Bmp,I-LoChar);
    end;
  finally
    Bmp.Free;
  end;
end;

procedure TAlphabet.AssertTextureArray;
begin
  if Texture=0 then begin
    CreateTextureArray;
    ReserveTextureArray;
    BuildTextureArray;
  end;
  glBindTexture(GL_TEXTURE_2D_ARRAY,Texture);
end;

procedure TAlphabet.PrepareForShow;
begin
  CreateTextureArray;
  ReserveTextureArray;
  BuildTextureArray;
end;

end.




