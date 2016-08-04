unit Global;

interface

uses
  Windows, Graphics, Classes;

const
  VersionStr = 'Solar Equation Slave v1.18';

  MaxTouches = 3;

  MaxSlaves = 5;

  MaxStacks   = 256;//64
  MaxSlices   = 256;//64;

  ImageW = 659;
  ImageH = 493;

  MaxImageW = ImageW;
  MaxImageH = ImageH;

  TrackW = ImageW;
  TrackH = ImageH;

  MinTableX = -TrackW;
  MaxTableX = TrackW*2;
  MinTableY = -TrackH;
  MaxTableY = TrackH*2;

  MaxLayers = 2;
  Layers    = 2;
  CubeMapLayers = 2;
  ImageLayers   = 2;

  RDLayers = 2;
  PerlinLayers = 2;
  ParticleLayers = 2;

  MaxProjectors = 2;

  MaxSeasons = 11;

  TW = 1024;
  TH = 1024;

  MaxSpots = 12;

type
  TStRecord = record
    S,T : Single;
  end;

  TRotationLayer = record
    CubeMapRz   : Single; // Cubemap rotation
    ImageOffset : Single; // texture scroll for the images
    RdOffset    : Single; // texture scroll for the reaction diffusion
    PerlinRz    : Single; // perlin rotation
    ParticleRz  : Single; // particle rotation
  end;
  TRotationLayerArray = array[1..Layers] of TRotationLayer;

  TRotation = record
    Enabled : Boolean;
    Scale   : Single;
    Changed : Boolean;
    Layer   : TRotationLayerArray;
  end;

  TSpot = record
    Size : Single;
    Rx   : Single;
    Ry   : Single;
  end;
  TSpotArray = array[1..MaxSpots] of TSpot;

  TLayerSpotArray = array[1..ParticleLayers] of TSpotArray;

  TRunMode = (rmIdle,rmSetup,rmRun,rmCountDown);

  TSlaveOrbit = (soPolar,soEquatorial);

  TSlavePlacement = record
    Orbit    : TSlaveOrbit;
    RzOffset : Single;
    SOffset  : Single;
  end;

  TMP3Record = record
    Index  : Integer;
    Volume : DWord;
  end;

  TCubeMapRecord = record
    Enabled  : Boolean;
    Alpha    : Single;
    Index    : Integer;
    RotateV  : Single;
  end;
  TCubeMapRecordArray = array[1..CubeMapLayers] of TCubeMapRecord;

  TImageRecord = record
    Enabled  : Boolean;
    Alpha    : Single;
    Index    : Integer;
    TScale   : Single;
    TOffset  : Single;
    RotateV  : Single;
  end;
  TImageRecordArray = array[1..ImageLayers] of TImageRecord;

  TReactDiffuseRecord = record
    Enabled  : Boolean;
    F,K,H,Dt : Single;
    Divider  : Single;
    Scale    : Single;
    Alpha    : Single;
    Speed    : Integer;
    Repeats  : Single;
    RotateV  : Single;
  end;
  TReactDiffuseRecordArray = array[1..RDLayers] of TReactDiffuseRecord;

  TPerlinRecord = record
    Enabled   : Boolean;
    ForeColor : TColor;
    BackColor : TColor;
    BoilSpeed : Single;
    Alpha     : Single;
    Scale     : Single;
    RotateV  : Single;
  end;
  TPerlinRecordArray = array[1..PerlinLayers] of TPerlinRecord;

  TParticleRecord = record
    Enabled        : Boolean;
    Alpha          : Single;
    Count          : Integer;
    StartColor     : TColor;
    EndColor       : TColor;
    LifeSpan       : DWord;
    MinSpeed       : Single;
    MaxSpeed       : Single;
    Divider1       : Single;
    Divider2       : Single;
    MaxR           : Single;
    PointSize      : Single;
    AlphaThreshold : Single;
    MinSpotSize    : Single;
    MaxSpotSize    : Single;
    RotateV        : Single;
  end;
  TParticleRecordArray = array[1..ParticleLayers] of TParticleRecord;

  TLayerVisible = array[1..MaxLayers] of Boolean;

  TTouch = record
    Active : Boolean;
    X,Y    : Single;
  end;
  TTouchArray = array[1..MaxTouches] of TTouch;

  TIpAddress = String[40];
  TImageName = String[36];
  TMP3Name   = String[40];

  TRenderMode = (rmWireFrame,rmSolid,rmTextured);

  TPlacement = (ptUnder,ptSide);

  TRgbaSingle = record
    R,G,B,A : Single;
  end;
  PRgbaSingle = ^TRgbaSingle;

  TRgbPixel = record
    R,G,B : Byte;
  end;
  PRgbPixel = ^TRgbPixel;

  TMask = array[0..TrackW-1,0..TrackH-1] of Boolean;
  PMask = ^TMask;

  TPixel = record
    X,Y : Single;
  end;

  TPlanePoint = record
    RelativeX : Single;
    RelativeY : Single;
    X,Y,Z     : Single;
    PixelX    : Single;
    PixelY    : Single;
  end;
  TPlanePointArray = array[1..10,1..10] of TPlanePoint;

  TPixelPt = record
    X,Y : Integer;
  end;
  TPixelPtArray = array[1..4] of TPixelPt;

  TUndistortTableEntry = record
    X,Y     : Integer;
    Valid   : Boolean;
    InImage : Boolean;
  end;
  TUndistortTable = array[MinTableX..MaxTableX,MinTableY..MaxTableY] of TUndistortTableEntry;

  TKInfo = record
    K1,K2 : Single;
    Px,Py : Single;
    Skew  : Single;
    D     : array[1..4] of Single;
  end;

  TPoint2D  = record
    X,Y : Double;
  end;

  TPoint3D  = record
    X,Y,Z : Single;
  end;

 TPose = record
    X,Y,Z    : Single;
    Rx,Ry,Rz : Single;
  end;

  TRay = record
    Base   : TPoint3D;
    Vector : TPoint3D;
  end;

  TLine = record
    Origin : TPoint3D;
    Target : TPoint3D;
  end;

  TPlane = record
    Point    : array[1..4] of TPoint3D;
    Finite   : Boolean;
    Nx,Ny,Nz : Single;
    A,B,C,D  : Single; // coefficients
  end;

  TVertex = record
    Point  : TPoint3D;
    Normal : TPoint3D;
    S,T    : Single;
  end;
  TVertexArray = array[1..MaxSlices,1..MaxStacks] of TVertex;

  TWindow = record
    X,Y,W,H : Integer;
  end;

  TFileName = String[255];

  TEdgeFade = record
    Enabled : Boolean;
    StartF  : Single;
  end;

  TFade = record
    Enabled : Boolean;
    Min,Max : Single;
  end;

  TVError = record
    Rz     : Single;
    Offset : Single;
  end;

  TCurrentV = array[1..MaxLayers] of record
    CubeMapV  : Single;
    ImageV    : Single;
    RdV       : Single;
    PerlinV   : Single;
    ParticleV : Single;
  end;

var
  Placement       : TSlavePlacement;
  RunMode         : TRunMode = rmIdle;
  RenderPlacement : TPlacement = ptUnder;
  RenderMode      : TRenderMode = rmWireFrame;
//  ActiveSeason    : Integer = 1;

  Rotation        : TRotationLayerArray;
  RotationEnabled : Boolean;
  RotationScale   : Single;

  RDTouch       : TTouchArray;
  ParticleTouch : TTouchArray;

  Orbit : TSlaveOrbit = soEquatorial;

  CountDownIndex : Byte;

  RunShow : Boolean;
  EdgeFade : TEdgeFade;

  CurrentV   : TCurrentV;
  CurrentPos : TRotationLayerArray;
  VError     : TVError;

  LastRotateTime : DWord;

implementation

end.

