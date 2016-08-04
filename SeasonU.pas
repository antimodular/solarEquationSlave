unit SeasonU;

interface

uses
  Windows, Classes, Graphics, SphereU, ReactDiffuseU, Global, OpenGL1x, Math,
  OpenGLTokens, PerlinU, FountainU, Protocol, ProjectorU;

const
  SeasonReserveSize = 1024;

type
  TSeason = class(TObject)
  private
    function PerlinFractionToColor(F: Single): TColor;

  public
    MP3            : TMP3Record;
    CubeMap        : TCubeMapRecordArray;
    Image          : TImageRecordArray;
    ReactDiffusion : TReactDiffuseRecordArray;
    PerlinSettings : TPerlinRecordArray;
    Particle       : TParticleRecordArray;

    procedure ReadFromStream(Stream: TFileStream);
    procedure WriteToStream(Stream: TFileStream);
    procedure SetToDefault;
//    procedure ApplyCamControl;
 //   procedure ApplyPodControl;
  //  procedure UpdateControl;

      procedure RenderFlat(iProjector:TProjector);

    procedure RenderSpherically(iProjector:TProjector);
    procedure DrawTextures(iProjector:TProjector);
    procedure PlayMP3;
    procedure CopyFromSeason(iSeason:TSeason);
    procedure UpdateControl;
    procedure ApplyUpdateData(UpdateData:TUpdateData);

    procedure RenderRDFlat(iProjector:TProjector;I: Integer);
    procedure DrawRDTextures(iProjector:TProjector;I:Integer);
  end;

  TSeasonArray = array[1..MaxSeasons] of TSeason;

var
  Season        : TSeasonArray;
  Seasons       : Integer;
  CurrentSeason : TSeason;
  ActiveSeason  : Integer = 1;

procedure CreateSeasons;
procedure FreeSeasons;

procedure SetSeasonsToDefault;
procedure LoadSeasons(Stream:TFileStream);
procedure SaveSeasons(Stream:TFileStream);

procedure ProcessSeasonData(var SeasonData:TSeasonData);

implementation

uses
  TextureU, GLDraw, Settings, RDColorU, CubeMapU, MP3PlayerU, Routines;

procedure ProcessSeasonData(var SeasonData:TSeasonData);
var
  I : Integer;
begin
  for I:=1 to MaxSeasons do begin
    Season[I].CubeMap:=SeasonData.Season[I].CubeMap;
    Season[I].Image:=SeasonData.Season[I].Image;
    Season[I].ReactDiffusion:=SeasonData.Season[I].ReactDiffuse;
    Season[I].PerlinSettings:=SeasonData.Season[I].Perlin;
    Season[I].Particle:=SeasonData.Season[I].Particles;
    Season[I].MP3:=SeasonData.Season[I].MP3;
  end;
  CurrentSeason.CopyFromSeason(Season[ActiveSeason]);
end;

procedure CreateSeasons;
var
  I : Integer;
begin
  CurrentSeason:=TSeason.Create;
  for I:=1 to MaxSeasons do Season[I]:=TSeason.Create;
end;

procedure FreeSeasons;
var
  I : Integer;
begin
  if Assigned(CurrentSeason) then CurrentSeason.Free;
  for I:=1 to MaxSeasons do if Assigned(Season[I]) then Season[I].Free;
end;

procedure SetSeasonsToDefault;
var
  I : Integer;
begin
  Seasons:=11;
  for I:=1 to MaxSeasons do Season[I].SetToDefault;
end;

procedure LoadSeasons(Stream:TFileStream);
var
  I : Integer;
begin
  for I:=1 to MaxSeasons do Season[I].ReadFromStream(Stream);
end;

procedure SaveSeasons(Stream:TFileStream);
var
  I : Integer;
begin
  for I:=1 to MaxSeasons do Season[I].WriteToStream(Stream);
end;

function DefaultPerlin:TPerlinRecord;
begin
  with Result do begin
    Enabled:=True;
    ForeColor:=clWhite;
    BackColor:=clRed;
    BoilSpeed:=5;
    Alpha:=0.50;
    Scale:=0.1;
  end;
end;

procedure ChangeSeason(S:Integer);
begin
  ActiveSeason:=S;
  CurrentSeason.CopyFromSeason(Season[S]);
end;

//procedure TSeason.SetPodServerDefaults;
//begin
  //
//end;

procedure TSeason.SetToDefault;
const
  DefaultEnabled = False;
var
  I : Integer;
begin
  MP3.Index:=1;
  MP3.Volume:=80;

  for I:=1 to CubeMapLayers do with CubeMap[I] do begin
    Enabled:=False;
    Alpha:=0.50;
    Index:=1;
    RotateV:=1.5;
  end;

  for I:=1 to ImageLayers do with Image[I] do begin
    Enabled:=(I=1);
    Alpha:=0.50;
    Index:=1;
    TScale:=1.5;
    TOffset:=0;
    RotateV:=1.5;
  end;

  FillChar(ReactDiffusion,SizeOf(ReactDiffusion),0);

  for I:=1 to RDLayers do with ReactDiffusion[I] do begin
    Enabled:=DefaultEnabled;
    F:=20;
    K:=70;
    H:=10;
    Dt:=1.0;
    Divider:=0.50;
    Scale:=3.0;
    Alpha:=0.50;
    Speed:=1;
  end;

  for I:=1 to PerlinLayers do with PerlinSettings[I] do begin
    Enabled:=DefaultEnabled;
    ForeColor:=clYellow;
    BackColor:=clRed;
    BoilSpeed:=5.0;
    Alpha:=0.50;
    Scale:=1.0;
    RotateV:=1.5;
  end;

  for I:=1 to ParticleLayers do with Particle[I] do begin
    Enabled:=DefaultEnabled;
    Alpha:=0.50;
    Count:=50000;
    StartColor:=clBlack;
    EndColor:=clYellow;
    LifeSpan:=3000;
    MinSpeed:=0.001;
    MaxSpeed:=0.010;
    Divider1:=0.55;
    Divider2:=0.40;
    MaxR:=1.0;
    PointSize:=100;
    AlphaThreshold:=0.70;
    MinSpotSize:=DegToRad(5.0);
    MaxSpotSize:=DegToRad(5.0);
    RotateV:=1.5;
  end;
end;

procedure TSeason.ReadFromStream(Stream:TFileStream);
begin
  Stream.Read(MP3,SizeOf(MP3));
  Stream.Read(CubeMap,SizeOf(CubeMap));
  Stream.Read(Image,SizeOf(Image));
  Stream.Read(ReactDiffusion,SizeOf(ReactDiffusion));
  Stream.Read(PerlinSettings,SizeOf(PerlinSettings));
  Stream.Read(Particle,SizeOf(Particle));

  ReadReserveFromStream(Stream,SeasonReserveSize);
end;

procedure TSeason.WriteToStream(Stream:TFileStream);
begin
  Stream.Write(MP3,SizeOf(MP3));
  Stream.Write(CubeMap,SizeOf(CubeMap));
  Stream.Write(Image,SizeOf(Image));
  Stream.Write(ReactDiffusion,SizeOf(ReactDiffusion));
  Stream.Write(PerlinSettings,SizeOf(PerlinSettings));
  Stream.Write(Particle,SizeOf(Particle));

  WriteReserveToStream(Stream,SeasonReserveSize);
end;

procedure TSeason.CopyFromSeason(iSeason:TSeason);
begin
  MP3:=iSeason.MP3;
  CubeMap:=iSeason.CubeMap;
  Image:=iSeason.Image;
  ReactDiffusion:=iSeason.ReactDiffusion;
  PerlinSettings:=iSeason.PerlinSettings;
  Particle:=iSeason.Particle;
end;

procedure TSeason.UpdateControl;
begin
// the Pod server controls layer #2's reaction diffusion
//  ReactDiffuse[2].ApplyPodServerRD(PodServerSeason.ReactDiffuse);

// the Pod server controls layer #2's particles
//  Fountain[2].ApplyPodServerParticle(PodServerSeason.Particles);

// the camera also controls layer #2's reaction diffusion
//  ReactDiffuse[2].CamTouch:=Tracker.Touch;
end;

procedure TSeason.DrawRDTextures(iProjector:TProjector;I:Integer);
begin
  with iProjector do with ReactDiffusion[I] do begin
    ReactDiffuse[I].F:=20;//F;
    ReactDiffuse[I].K:=79;//K;
    ReactDiffuse[I].H:=10;//H;
    ReactDiffuse[I].Dt:=1;//Dt;
    ReactDiffuse[I].Speed:=2;//Speed;
    ReactDiffuse[I].RenderToTexture;

{    RDColor[I].Divider:=Divider;
    RDColor[I].Scale:=Scale;
    RDColor[I].Alpha:=Alpha;
    RDColor[I].Repeats:=Repeats;
    RDColor[I].RenderToTexture(ReactDiffuse[I]);
    }
  end;
end;

procedure TSeason.RenderRDFlat(iProjector:TProjector;I:Integer);
const
  Scale = 5.0;
  W = Scale;
  H = Scale;
begin
  glDisable(GL_LIGHTING);

  EnableTextures;
  EnableAlpha;

  glBindTexture(GL_TEXTURE_2D,iProjector.ReactDiffuse[I].Texture[0]);
//  iProjector.RDColor[I].BindTexture;
  RenderTexturedRectangle(0,0,W,H,1);
  glBindTexture(GL_TEXTURE_2D,0);
end;

procedure TSeason.DrawTextures(iProjector:TProjector);
var
  I : Integer;
begin
  with iProjector do begin
    for I:=1 to RDLayers do if ShowLayer[I] then begin
      with ReactDiffusion[I] do if Enabled then begin
        ReactDiffuse[I].F:=F;
        ReactDiffuse[I].K:=K;
        ReactDiffuse[I].H:=H;
        ReactDiffuse[I].Dt:=Dt;
        ReactDiffuse[I].Speed:=Speed;
        ReactDiffuse[I].RenderToTexture;

        RDColor[I].Divider:=Divider;
        RDColor[I].Scale:=Scale;
        RDColor[I].Alpha:=Alpha;
        RDColor[I].Repeats:=Repeats;
        RDColor[I].RenderToTexture(ReactDiffuse[I]);
      end;
    end;

// perlin is already a texture - so we don't need to draw to a texture first
// just set the variables
    for I:=1 to PerlinLayers do if ShowLayer[I] then begin
      with PerlinSettings[I] do if Enabled then begin
        Perlin[I].ForeGndColor:=ForeColor;
        Perlin[I].BackGndColor:=BackColor;
        if iProjector.Orbit=soEquatorial then begin
          Perlin[I].Offset.X:=CurrentPos[I].PerlinRz;
        end
        else Perlin[I].Offset.X:=0;
        Perlin[I].Speed.Z:=BoilSpeed;
        Perlin[I].Alpha:=Alpha;
        Perlin[I].Scale:=Scale;
      end;
    end;

    for I:=1 to ParticleLayers do if ShowLayer[I] then begin
      with Particle[I] do if Enabled then begin
//        Fountain[I].InitFromParticleRecord(Particle[I]);
//        Fountain[I].Update;
//        Fountain[I].RenderToTexture;
      end;
    end;
  end;
end;

procedure TSeason.RenderFlat(iProjector:TProjector);
const
  Scale = 5.0;
  W = Scale;
  H = Scale;
var
  I : Integer;
begin
  glDisable(GL_LIGHTING);

  EnableTextures;
  EnableAlpha;

  for I:=1 to RdLayers do if ReactDiffusion[I].Enabled then begin
    iProjector.RDColor[1].BindTexture;
    RenderTexturedRectangle(0,0,W,H,1);
  end;
end;

procedure TSeason.RenderSpherically(iProjector:TProjector);
var
  I      : Integer;
  Rz     : Single;
  Scale  : TStRecord;
  Offset : TStRecord;
begin
  glDisable(GL_LIGHTING);
  glDisable(GL_DEPTH_TEST);

  EnableAlpha;
  EnableTextures;

  glColor4F(1,1,1,1);

  if iProjector.ShowImage then for I:=1 to ImageLayers do begin
    if iProjector.ShowLayer[I] and Image[I].Enabled then begin
      glColor4F(1,1,1,Image[I].Alpha);
      glEnable(GL_CULL_FACE);
      glCullFace(GL_BACK);
      Texture[Image[I].Index].Apply;

      Scale.S:=1.0;
      Scale.T:=Image[I].TScale;
      Offset.S:=iProjector.SOffset+CurrentPos[I].ImageOffset;
      Offset.T:=Image[I].TOffset;

      iProjector.Sphere.RenderScaledAndOffset2(Scale,Offset,iProjector.Orbit,
                                                iProjector.PolarScale);
      glBindTexture(GL_TEXTURE_2D,0);
    end;
  end;

  if iProjector.ShowCubeMap then for I:=1 to CubeMapLayers do begin
    if iProjector.ShowLayer[I] and CubeMap[I].Enabled then begin
      glEnable(GL_CULL_FACE);
      glCullFace(GL_BACK);
      glColor4F(1,1,1,CubeMap[I].Alpha);
      CubeMapU.CubeMap.Apply(CubeMap[I].Index);
      iProjector.CmSphere.Render;
      CubeMapU.CubeMap.Remove;
    end;
  end;

  for I:=1 to RDLayers do if iProjector.ShowLayer[I] then begin
    if ReactDiffusion[I].Enabled then begin
      iProjector.RDColor[I].BindTexture;
//glBindTexture(GL_TEXTURE_2D,iProjector.ReactDiffuse[I].Texture[1]);

      glColor4F(1,1,1,1); // alpha done in shader
      Scale.S:=1.0;
      Scale.T:=1.0;
      Offset.S:=CurrentPos[I].RdOffset;
      Offset.T:=0.0;

      if iProjector.Sphere.YFade.Enabled then begin
        iProjector.Sphere.RenderScaledAndOffsetWithBlend(Scale,Offset,iProjector.Orbit,
                                             iProjector.PolarScale,Image[I].Alpha);
      end
      else if EdgeFade.Enabled then begin
        iProjector.Sphere.RenderScaledAndOffsetWithBlend(Scale,Offset,iProjector.Orbit,
                                             iProjector.PolarScale,1.0);
      end
      else begin
        iProjector.Sphere.RenderScaledAndOffset(Scale,Offset,iProjector.Orbit,
                                                iProjector.PolarScale);
      end;
      glBindTexture(GL_TEXTURE_2D,0);
    end;
  end;

  for I:=1 to PerlinLayers do if iProjector.ShowLayer[I] then begin
    with PerlinSettings[I] do if Enabled then begin
      iProjector.Perlin[I].Apply;
      if iProjector.Orbit=soPolar then begin
        glPushMatrix;
        Rz:=-CurrentPos[I].PerlinRz*iProjector.PolarScale;
        glRotateF(RadToDeg(Rz),0,0,1);
      end;
      iProjector.Sphere.RenderForPerlin(CurrentPos[I].PerlinRz);
      if iProjector.Orbit=soPolar then glPopMatrix;
      iProjector.Perlin[I].Remove;
    end;
  end;

// no spots on the poles
  if iProjector.Orbit=soEquatorial then begin
    for I:=1 to ParticleLayers do if iProjector.ShowLayer[I] then begin
      with Particle[I] do if Enabled then begin
        iProjector.Fountain[I].RenderSpots(iProjector.Sphere);
      end;
    end;
  end;
end;

procedure TSeason.PlayMP3;
begin
  MP3Player.SetVolume(MP3.Volume);
  MP3Player.PlayMP3Number(MP3.Index);
end;

function TSeason.PerlinFractionToColor(F:Single):TColor;
var
  R,G,B : Byte;
begin
  if F>2.0 then begin
    R:=255;
    G:=255;
    B:=ClipToByte((F-2)*255);
  end
  else if F>1.0 then begin
    R:=255;
    G:=ClipToByte((F-1)*255);
    B:=0;
  end
  else begin
    R:=ClipToByte(255*(0.5+F*0.5));
    G:=0;
    B:=0;
  end;
  Result:=(B shl 16)+(G shl 8)+R;
end;

procedure TSeason.ApplyUpdateData(UpdateData:TUpdateData);
begin
  with UpdateData.PsRD do begin
    if (PresetI<1) or (PresetI>4) then PresetI:=1;
    ReactDiffusion[2].Enabled:=Enabled;
    ReactDiffusion[2].F:=RDPreset[PresetI].F;
    ReactDiffusion[2].K:=RDPreset[PresetI].K;
    ReactDiffusion[2].H:=RDPreset[PresetI].H;
    ReactDiffusion[2].Dt:=1.0;
    ReactDiffusion[2].Divider:=ColorDivider;
    if PresetI<>LastPresetI then begin
//      ReactDiffusion[2].MakeRandom:=True;
    end;
  end;
  with UpdateData.PsPerlin do begin
    PerlinSettings[2].ForeColor:=PerlinFractionToColor(Color);
    PerlinSettings[2].Scale:=Scale;
    PerlinSettings[2].BoilSpeed:=Speed;
    PerlinSettings[2].Alpha:=Alpha;
    PerlinSettings[2].Enabled:=Enabled;
  end;
  with UpdateData.PsParticle do begin
    Particle[2].Enabled:=Enabled;
  end;
end;

end.
