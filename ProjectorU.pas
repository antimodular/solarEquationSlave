unit ProjectorU;

interface

uses
  Math, Global, SphereU, Classes, Protocol, ReactDiffuseU, RdColorU, PerlinU,
  FountainU;

type
  TProjector = class(TObject)
  private

  public
    Tag      : Integer;
    Pose     : TPose;
    FOV      : Single;
    Window   : TWindow;
    Sphere   : TSphere;
    CmSphere : TSphere;

    Orbit       : TSlaveOrbit;
    PolarScale  : Single;
    PerlinScale : Single;
    SOffset     : Single;  // for the image and effects
    RzOffset    : Single;  // for the cube map

    ShowCubeMap : Boolean;
    ShowImage   : Boolean;
    ShowLayer   : TLayerVisible;

// each projector needs its own set of shaders
    ReactDiffuse : TReactDiffuseArray;
    RDColor      : TRdColorArray;
    Perlin       : TPerlinArray;
    Fountain     : TFountainArray;

    constructor Create(iTag:Integer);
    destructor Destroy; override;

    procedure SetToDefault;
    procedure WriteToStream(Stream:TFileStream);
    procedure ReadFromStream(Stream:TFileStream);
    procedure InitFromSetupData(Data:TProjectorSetupData);
    procedure CreateEffects;
    procedure FreeEffects;
  end;
  TProjectorArray = array[1..MaxProjectors] of TProjector;

var
  Projectors : Integer = 2;
  Projector  : TProjectorArray;

procedure LoadProjectors(Stream:TFileStream);
procedure SaveProjectors(Stream:TFileStream);

implementation

procedure LoadProjectors(Stream:TFileStream);
var
  P : Integer;
begin
  for P:=1 to MaxProjectors do Projector[P].ReadFromStream(Stream);
end;

procedure SaveProjectors(Stream:TFileStream);
var
  P : Integer;
begin
  for P:=1 to MaxProjectors do Projector[P].WriteToStream(Stream);
end;

constructor TProjector.Create(iTag:Integer);
var
  I : Integer;
begin
  Tag:=iTag;

  Sphere:=TSphere.Create;
  Sphere.Placement:=ptUnder;

  CmSphere:=TSphere.Create;
  CmSphere.Placement:=ptSide;

  for I:=1 to RDLayers do begin
    ReactDiffuse[I]:=TReactDiffuse.Create(I);
    RDColor[I]:=TRDColor.Create(I);
  end;

  for I:=1 to PerlinLayers do begin
    Perlin[I]:=TPerlin.Create;
  end;

  for I:=1 to ParticleLayers do begin
    Fountain[I]:=TFountain.Create(I);
  end;
end;

destructor TProjector.Destroy;
var
  I : Integer;
begin
  if Assigned(Sphere) then Sphere.Free;
  if Assigned(CmSphere) then CmSphere.Free;

  for I:=1 to RDLayers do begin
    if Assigned(ReactDiffuse[I]) then ReactDiffuse[I].Free;
    if Assigned(RDColor[I]) then RDColor[I].Free;
  end;

  for I:=1 to PerlinLayers do begin
    if Assigned(Perlin[I]) then Perlin[I].Free;
  end;

  for I:=1 to ParticleLayers do begin
    if Assigned(Fountain[I]) then Fountain[I].Free;
  end;
end;

procedure TProjector.SetToDefault;
begin
  FillChar(Pose,SizeOf(Pose),0);
  Pose.Z:=10;

  FOV:=DegToRad(45);

  Window.X:=(Tag-1)*500;
  Window.Y:=0;
  Window.W:=400;
  Window.H:=300;

  ShowCubeMap:=True;
  ShowImage:=True;
  FillChar(ShowLayer,SizeOf(ShowLayer),True);

  Sphere.SetToDefault;
  CmSphere.SetToCubeMapDefault;

  Orbit:=soEquatorial;
  RzOffset:=0;
  SOffset:=0;
  PolarScale:=-0.25;
  PerlinScale:=-2.5;
end;

procedure TProjector.ReadFromStream(Stream: TFileStream);
begin
  Stream.Read(Pose,SizeOf(Pose));
  Stream.Read(FOV,SizeOf(FOV));
  Stream.Read(Window,SizeOf(Window));
  Sphere.ReadFromStream(Stream);
  CmSphere.ReadFromStream(Stream);
  Stream.Read(ShowCubeMap,SizeOf(ShowCubeMap));
  Stream.Read(ShowImage,SizeOf(ShowImage));
  Stream.Read(ShowLayer,SizeOf(ShowLayer));
  Stream.Read(Orbit,SizeOf(Orbit));
  Stream.Read(PolarScale,SizeOf(PolarScale));
  Stream.Read(PerlinScale,SizeOf(PerlinScale));
  Stream.Read(SOffset,SizeOf(SOffset));
  Stream.Read(RzOffset,SizeOf(RzOffset));
end;

procedure TProjector.WriteToStream(Stream: TFileStream);
begin
  Stream.Write(Pose,SizeOf(Pose));
  Stream.Write(FOV,SizeOf(FOV));

// projector window
  Stream.Write(Window,SizeOf(Window));

// Spheres
  Sphere.WriteToStream(Stream);
  CmSphere.WriteToStream(Stream);

  Stream.Write(ShowCubeMap,SizeOf(ShowCubeMap));
  Stream.Write(ShowImage,SizeOf(ShowImage));
  Stream.Write(ShowLayer,SizeOf(ShowLayer));

  Stream.Write(Orbit,SizeOf(Orbit));
  Stream.Write(PolarScale,SizeOf(PolarScale));
  Stream.Write(PerlinScale,SizeOf(PerlinScale));
  Stream.Write(SOffset,SizeOf(SOffset));
  Stream.Write(RzOffset,SizeOf(RzOffset));
end;

procedure TProjector.InitFromSetupData(Data:TProjectorSetupData);
var
  I : Integer;
begin
  Window:=Data.Window;
  Pose:=Data.Pose;
  FOV:=Data.FOV;
  ShowCubeMap:=Data.ShowCubeMap;
  ShowImage:=Data.ShowImage;
  ShowLayer:=Data.ShowLayer;
  Sphere.InitFromSetupData(Data.Sphere);
  CmSphere.InitFromSetupData(Data.CmSphere);
  Orbit:=Data.Orbit;
  RzOffset:=Data.RzOffset;
  SOffset:=Data.SOffset;
  PolarScale:=Data.PolarScale;
  PerlinScale:=Data.PerlinScale;
  for I:=1 to ParticleLayers do begin
    Case Orbit of
      soEquatorial : Fountain[I].PlaceSpots;
      soPolar      : Fountain[I].PlacePolarSpots;
    end;
  end;
end;

procedure TProjector.CreateEffects;
var
  I : Integer;
begin
{  for I:=1 to RDLayers do begin
    ReactDiffuse[I]:=TReactDiffuse.Create(I);
    RDColor[I]:=TRDColor.Create(I);
  end;

  for I:=1 to PerlinLayers do begin
    Perlin[I]:=TPerlin.Create;
  end;

  for I:=1 to ParticleLayers do begin
    Fountain[I]:=TFountain.Create(I);
  end;}
end;

procedure TProjector.FreeEffects;
var
  I : Integer;
begin
{  for I:=1 to RDLayers do begin
    if Assigned(ReactDiffuse[I]) then ReactDiffuse[I].Free;
    if Assigned(RDColor[I]) then RDColor[I].Free;
  end;

  for I:=1 to PerlinLayers do begin
    if Assigned(Perlin[I]) then Perlin[I].Free;
  end;

  for I:=1 to ParticleLayers do begin
    if Assigned(Fountain[I]) then Fountain[I].Free;
  end;}
end;

end.


