unit CubeMapU;

interface

uses
  Windows, Graphics, TextureU, Classes, SysUtils, OpenGL1X, OpenGLTokens, Jpeg,
  FileUtils;

const
  MaxCubeMapTextures = 11;

type
  TCubeMap = class(TObject)
  private
    Initialized : Boolean;

    procedure Initialize(TextureI:Integer);
    procedure StoreTexture(TextureI: Integer);

  public
    Face     : array[1..MaxCubeMapTextures,1..6] of TTexture;
    FaceName : array[1..MaxCubeMapTextures,1..7] of GLUInt;

    procedure Load(TextureI:Integer);
    procedure LoadTextureIfNecessary(TextureI: Integer);

    procedure Apply(TextureI:Integer);
    procedure Remove;

    constructor Create;
    destructor Destroy; override;

  end;

var
  CubeMap : TCubeMap;

implementation

uses
  Routines, BmpUtils;

constructor TCubeMap.Create;
var
  T,I : Integer;
begin
  inherited;
  for T:=1 to MaxCubeMapTextures do for I:=1 to 6 do begin
    Face[T,I]:=TTexture.Create;
  end;
  Initialized:=False;
end;

destructor TCubeMap.Destroy;
var
  T,I : Integer;
begin
  for T:=1 to MaxCubeMapTextures do for I:=1 to 6 do begin
    if Assigned(Face[T,I]) then Face[T,I].Free;
  end;
  inherited;
end;

// Faces:
//   1
//  2345
//   6
procedure TCubeMap.Load(TextureI:Integer);
var
  FullBmp     : TBitmap;
  FaceBmp     : TBitmap;
  FaceRect    : TRect;
  W           : Integer;
  W2,W3,W4    : Integer;
  UseJpg      : Boolean;
  Jpg         : TJpegImage;
  Ext         : String;
  TextureName : String;
begin
  TextureName:=TexturePath+'CubeMap'+IntToStr(TextureI)+'.bmp';
  Ext:=ExtractFileExt(TextureName);
  UseJpg:=(Ext='.jpg');
  if UseJpg then Jpg:=TJpegImage.Create;
  FullBmp:=TBitmap.Create;
  FaceBmp:=TBitmap.Create;
  try
    if FileExists(TextureName) then begin
      if UseJpg then begin
        Jpg.LoadFromFile(TextureName);
        FullBmp.Assign(Jpg);
      end
      else FullBmp.LoadFromFile(TextureName);
    end
    else begin
      FullBmp.Width:=1024;
      FullBmp.Height:=1024;
      ClearBmp(FullBmp,clBlack);
      FullBmp.Canvas.Pen.Color:=clGray;
      CrossBmp(FullBmp);
    end;

    FullBmp.PixelFormat:=pf24Bit;
    W:=FullBmp.Width div 4;
    FaceBmp.Width:=W;
    FaceBmp.Height:=W;
    FaceBmp.PixelFormat:=pf24Bit;

    W2:=W*2;
    W3:=W*3;
    W4:=W*4;
    FaceRect:=Rect(0,0,W,W);

// #1
    FaceBmp.Canvas.CopyRect(FaceRect,FullBmp.Canvas,Rect(W,0,W2,W));
//    FaceBmp.SaveToFile(TexturePath+'Face1.bmp');
    Face[TextureI,1].CopyFromBmp(FaceBmp);

// #2
    FaceBmp.Canvas.CopyRect(FaceRect,FullBmp.Canvas,Rect(0,W,W,W2));
//    FaceBmp.SaveToFile(TexturePath+'Face2.bmp');
    Face[TextureI,2].CopyFromBmp(FaceBmp);

// #3
    FaceBmp.Canvas.CopyRect(FaceRect,FullBmp.Canvas,Rect(W,W,W2,W2));
//    FaceBmp.SaveToFile(TexturePath+'Face3.bmp');
    Face[TextureI,3].CopyFromBmp(FaceBmp);

// #4
    FaceBmp.Canvas.CopyRect(FaceRect,FullBmp.Canvas,Rect(W2,W,W3,W2));
//    FaceBmp.SaveToFile(TexturePath+'Face4.bmp');
    Face[TextureI,4].CopyFromBmp(FaceBmp);

// #5
    FaceBmp.Canvas.CopyRect(FaceRect,FullBmp.Canvas,Rect(W3,W,W4,W2));
//    FaceBmp.SaveToFile(TexturePath+'Face5.bmp');
    Face[TextureI,5].CopyFromBmp(FaceBmp);

// #6
    FaceBmp.Canvas.CopyRect(FaceRect,FullBmp.Canvas,Rect(W,W2,W2,W3));
//    FaceBmp.SaveToFile(TexturePath+'Face6.bmp');
    Face[TextureI,6].CopyFromBmp(FaceBmp);

  finally
    FullBmp.Free;
    FaceBmp.Free;
    if UseJpg then Jpg.Free;
  end;
end;

procedure TCubeMap.LoadTextureIfNecessary(TextureI:Integer);
begin
  if (TextureI=0) or (TextureI>MaxCubeMapTextures) then TextureI:=1;

  if not Assigned(Face[TextureI,1].Data) then Load(TextureI);
end;

// Faces:
//   1
//  2345
//   6
procedure TCubeMap.StoreTexture(TextureI:Integer);
var
  I,FI : Integer;
  Tgt  : TGLEnum;
begin
  glEnable(GL_TEXTURE_2D);
  glEnable(GL_TEXTURE_CUBE_MAP);

  //environment mapping
	glBindTexture(GL_TEXTURE_CUBE_MAP, FaceName[TextureI,7]);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);


  for I:=1 to 6 do begin
    FI:=I;
    glBindTexture(GL_TEXTURE_2D,FaceName[TextureI,FI]);

    Case I of
      1 : Tgt:=GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_EXT;
      2 : Tgt:=GL_TEXTURE_CUBE_MAP_NEGATIVE_X_EXT;
      3 : Tgt:=GL_TEXTURE_CUBE_MAP_POSITIVE_Z_EXT;
      4 : Tgt:=GL_TEXTURE_CUBE_MAP_POSITIVE_X_EXT;
      5 : Tgt:=GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_EXT;
      6 : Tgt:=GL_TEXTURE_CUBE_MAP_POSITIVE_Y_EXT;
    end;

    glTexImage2D(Tgt,0,GL_RGB8,Face[TextureI,FI].W,Face[TextureI,FI].H,0,GL_BGR,GL_UNSIGNED_BYTE,
                 Face[TextureI,FI].Data);
  end;

	glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
  glBindTexture(GL_TEXTURE_2D,0);
end;

procedure TCubeMap.Initialize(TextureI:Integer);
begin
  LoadTextureIfNecessary(TextureI);

  glGenTextures(7,@FaceName[TextureI,1]);

  StoreTexture(TextureI);
end;

procedure TCubeMap.Apply(TextureI:Integer);
var
  Param : Integer;
  I     : Integer;
  Tgt   : GLEnum;
begin
  if FaceName[TextureI,1]=0 then begin
    Initialize(TextureI);
  end;

  glDisable(GL_LIGHTING);
  glEnable(GL_TEXTURE_2D);

  glBindTexture(GL_TEXTURE_CUBE_MAP,FaceName[TextureI,7]);
  glEnable(GL_TEXTURE_CUBE_MAP);

  Param:=GL_REFLECTION_MAP;
//  Param:=GL_OBJECT_LINEAR;
//  Param:=GL_EYE_LINEAR;
//  Param:=GL_SPHERE_MAP;

  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, Param);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, Param);
	glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, Param);

  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_NORMAL_MAP_EXT);
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_NORMAL_MAP_EXT);
  glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, GL_NORMAL_MAP_EXT);

	glEnable(GL_TEXTURE_GEN_S);
	glEnable(GL_TEXTURE_GEN_T);
	glEnable(GL_TEXTURE_GEN_R);

  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
end;

procedure TCubeMap.Remove;
var
  Param : Integer;
begin
  glBindTexture(GL_TEXTURE_2D,0);
  glBindTexture(GL_TEXTURE_CUBE_MAP,0);

  glDisable(GL_TEXTURE_2D);
  glDisable(GL_TEXTURE_CUBE_MAP);

	glDisable(GL_TEXTURE_GEN_S);
	glDisable(GL_TEXTURE_GEN_T);
	glDisable(GL_TEXTURE_GEN_R);

  Param:=GL_OBJECT_LINEAR;
  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, Param);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, Param);
	glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, Param);
end;

end.
