unit PerlinU;

interface

uses
  GLDraw, OpenGL1x, OpenGLTokens, ProgramU, Global, SysUtils, Classes, Routines,
  Graphics, Dialogs;

const
  TextureSize  = 128;
  DataSize     = TextureSize*TextureSize*TextureSize*SizeOf(Single);
  PerlinLayers = 2;

type
  TPerlin = class(TObject)
  private
    PerlinProgram : TProgram;
    Initialized   : Boolean;
    NoiseTexture  : GLUInt;
    Color         : Single;
    Data          : array[0..DataSize-1] of Single;
    Quadric       : PGluQuadric;

    procedure LoadProgram;
    procedure SyncUniformVars;
    procedure InitLazy;
    procedure Update;
    procedure InitNoiseTexture;
    procedure LoadNoiseTexture;

    procedure FakeData;
    procedure StoreNoiseTexture;

  public
    Alpha    : Single;
    Speed    : TPoint3D;
    LightPos : TPoint3D;
    Scale    : Single;
    Offset   : TPoint3D;

    ForeGndColor : TColor;
    BackGndColor : TColor;

    constructor Create;
    destructor Destroy; override;

    procedure PrepareForShow;

    procedure Apply;
    procedure Remove;

    procedure SetToDefault;
    procedure ReadFromStream(Stream:TFileStream);
    procedure WriteToStream(Stream:TFileStream);
  end;
  TPerlinArray = array[1..PerlinLayers] of TPerlin;

implementation

uses
  Settings;

constructor TPerlin.Create;
begin
  PerlinProgram:=TProgram.Create;
  Initialized:=False;
  Speed.X:=0;
  Speed.Y:=0;
  Speed.Z:=0;
  LightPos.X:=0;
  LightPos.Y:=0;
  LightPos.Z:=0;
end;

destructor TPerlin.Destroy;
begin
  if Initialized then begin
    glDeleteTextures(1,@NoiseTexture);
  end;
  if Assigned(PerlinProgram) then PerlinProgram.Free;
end;

procedure TPerlin.SetToDefault;
begin

end;

procedure TPerlin.ReadFromStream(Stream:TFileStream);
begin
end;

procedure TPerlin.WriteToStream(Stream:TFileStream);
begin
end;

procedure TPerlin.PrepareForShow;
begin
  Offset.X:=0;
  Offset.Y:=0;
  Offset.Z:=0;
end;

procedure TPerlin.LoadProgram;
begin
  PerlinProgram.LoadVertexAndFragmentFiles('Perlin.vert','Perlin.frag',True);
end;

procedure TPerlin.SyncUniformVars;
begin
  PerlinProgram.SetUniform3F('LightPos',0.0,0.0,4.0);
  PerlinProgram.SetUniform4F('BackColor',0.8,0.0,0.0,0.0);
  PerlinProgram.SetUniform4F('FrontColor',0.8,0.8,0.0,1.0);
  PerlinProgram.SetUniformF('Scale',1.0);
  PerlinProgram.SetUniformI('Noise',0);
  PerlinProgram.SetUniformF('Alpha',1.0);
  PerlinProgram.SetUniform3F('Offset',0.0,0.0,0.0);
end;

procedure TPerlin.InitLazy;
begin
  ReadExtensions;
  Alpha:=0.50;

// 3D noise texture
  glGenTextures(1,@NoiseTexture);

// fill it
//  FillNoiseTexture;
  LoadNoiseTexture;
  StoreNoiseTexture;


// load the shader programs
  LoadProgram;

  Initialized:=True;
end;

procedure TPerlin.Update;
var
  R,G,B      : Single;
  FixedScale : Single;
  Color      : TGLColor;
begin
// update the boiling
  Offset.X:=Offset.X+Speed.X/100;
  Offset.Y:=Offset.Y+Speed.Y/100;
  Offset.Z:=Offset.Z+Speed.Z/100;

  PerlinProgram.SetUniform3F('Offset',Offset.X,Offset.Y,Offset.Z);

  PerlinProgram.SetUniformF('Alpha',Alpha);

  Color:=ColorToGLColor(ForeGndColor);
  with Color do PerlinProgram.SetUniform4F('FrontColor',R,G,B,Alpha);

  Color:=ColorToGLColor(BackGndColor);
  with Color do PerlinProgram.SetUniform4F('BackColor',R,G,B,0);//Alpha);

  PerlinProgram.SetUniformF('Scale',Scale/10);
  with LightPos do PerlinProgram.SetUniform3F('LightPos',X,Y,Z);
  PerlinProgram.SetUniformI('Noise',0);
end;

procedure TPerlin.Apply;
begin
  if not Initialized then InitLazy;

  PerlinProgram.Use;

  Update;

  glBindTexture(GL_TEXTURE_3D,NoiseTexture);
//  StoreNoiseTexture;
end;

procedure TPerlin.Remove;
begin
  PerlinProgram.Remove;
  glBindTexture(GL_TEXTURE_3D,0);
end;

function NoiseFileName:String;
begin
  Result:=Path+'Noise3D.dat';
end;

procedure TPerlin.FakeData;
var
  I,Count : Integer;
begin
  Count:=TextureSize*TextureSize*TextureSize;
  for I:=0 to Count-1 do begin
    Data[I]:=1.0;
  end;
end;

procedure TPerlin.LoadNoiseTexture;
var
  Stream : TFileStream;
  Size   : Integer;
begin
// make sure the file exists
  if FileExists(NoiseFileName) then begin

// make sure its big enough
    Size:=SizeOfFile(NoiseFileName);
    if Size>=DataSize then begin

// read it
      Stream:=TFileStream.Create(NoiseFileName,fmOpenRead);
      try
        Stream.Read(Data[0],DataSize);
      finally
        Stream.Free;
      end;
    end;
  end
  else ShowMessage(NoiseFileName+' is missing');
// FakeData;
end;

procedure TPerlin.StoreNoiseTexture;
begin
  glBindTexture(GL_TEXTURE_3D,NoiseTexture);

  glTexParameterf(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexImage3D(GL_TEXTURE_3D, 0, GL_RGBA8,TextureSize,TextureSize,TextureSize,0,
               GL_RGBA,GL_UNSIGNED_BYTE,@Data[0]);
end;

procedure TPerlin.InitNoiseTexture;
begin
  LoadNoiseTexture;
  glGenTextures(1,@NoiseTexture);
  StoreNoiseTexture;
  glBindTexture(GL_TEXTURE_3D,0);
end;

end.
