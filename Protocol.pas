unit Protocol;

interface

uses
  Global;//, ShowControllerU;

const
  RD_PRESETS = 4;

  MaxTouches = 3;

// PodServer updating Master with user settings
  SeasonMsg = 1;

// Master giving PodServer season defaults
  SeasonDefaultsMsg = 2;

// Master to slaves
  CONNECT_MSG       = 2;
  UPDATE_DATA_MSG   = 3;
  RUN_MODE_MSG      = 4;
  RENDER_MODE_MSG   = 5;
  SETUP_DATA_MSG    = 6;
  SEASON_DATA_MSG   = 7;
  SEASON_UPDATE_MSG = 8;
  SPOT_DATA_MSG     = 9;
  COUNT_DOWN_MSG    = 10;
  HALT_CMD          = 11;
  CAL_SETTINGS_MSG  = 12;

type
  TCalibrationSettingsMsg = record
    Msg            : Byte;
    ShowProjector  : array[1..MaxProjectors] of Boolean;
    ShowRadialFade : Boolean;
    ShowXYFade     : Boolean;
  end;
  PCalibrationSettingsMsg = ^TCalibrationSettingsMsg;

  TRenderModeMsg = record
    Msg       : Byte;
    Placement : TPlacement;
    Mode      : TRenderMode;
  end;
  PRenderModeMsg = ^TRenderModeMsg;

  TRunModeMsg = record
    Msg  : Byte;
    Mode : TRunMode;
  end;
  PRunModeMsg = ^TRunModeMSg;

  TSphereSetupData = record
    Radius     : Single;   // Sphere radius
    Stack1     : Word;
    Stack2     : Word;
    Slice1     : Word;
    Slice2     : Word;
    EndAngle   : Single;
    RzOffset   : Single;
    SOffset    : Single;
    YFade      : TFade;
    RadialFade : TEdgeFade;
    XScale     : Single;
    YScale     : Single;
  end;

  TProjectorSetupData = record
    Orbit       : TSlaveOrbit;
    RzOffset    : Single;
    SOffset     : Single;
    Window      : TWindow;  // windows desktop placement and size of the projector
    Pose        : TPose;   // pose of the projector relative to the sphere center
    FOV         : Single;
    ShowCubeMap : Boolean;
    ShowImage   : Boolean;
    ShowLayer   : TLayerVisible;
    Sphere      : TSphereSetupData;
    CmSphere    : TSphereSetupData;
    PolarScale  : Single;
    PerlinScale : Single;
  end;
  TProjectorSetupDataArray = array[1..MaxProjectors] of TProjectorSetupData;

// setup data from Master to Slaves
  TSetupData = record
    Msg             : Byte;
    Projectors      : Integer;
    Projector       : TProjectorSetupDataArray;
    RunShow         : Boolean;
    UseCamera       : Boolean;
    VError          : TVError;
    RotationEnabled : Boolean;
    RotationScale   : Single;
  end;
  PSetupData = ^TSetupData;

  TSpotData = record
    Msg  : Byte;
    Spot : TLayerSpotArray;
  end;
  PSpotData = ^TSpotData;

  TSeasonSettings = record
    MP3          : TMP3Record;
    CubeMap      : TCubeMapRecordArray;
    Image        : TImageRecordArray;
    Perlin       : TPerlinRecordArray;
    ReactDiffuse : TReactDiffuseRecordArray;
    Particles    : TParticleRecordArray;
  end;

  TSeasonUpdateRecord = record
    Index    : Byte;
    Settings : TSeasonSettings;
  end;

// season data from Master to Slaves
  TSeasonData = record
    Msg    : Byte;
    Season : array[1..MaxSeasons] of TSeasonSettings;
  end;
  PSeasonData = ^TSeasonData;

// data from the pod server
  TPodServerRD = record
    TouchUpdated : array[1..MaxTouches] of Boolean;
    TouchX       : array[1..MaxTouches] of Single;
    TouchY       : array[1..MaxTouches] of Single;
    ColorDivider : Single;
    PresetI      : Byte;
    Reset        : Boolean;
    Enabled      : Boolean;
  end;

// defaults for the pod server
  TPodServerPerlin = record
    Color   : Single;
    Scale   : Single;
    Speed   : Single;
    Alpha   : Single;
    Enabled : Boolean;
  end;

  TPodServerParticle = record
    X,Y     : array[1..MaxTouches] of Single;
    Enabled : Boolean;
  end;

  TPodServerSeason = record
    ReactDiffuse : TPodServerRD;
    Perlin       : TPodServerPerlin;
    Particles    : TPodServerParticle;
  end;
  PPodServerSeason = ^TPodServerSeason;

  TPodServerSeasonArray = array[1..MaxSeasons] of TPodServerSeason;

  TMasterSeason = record
    Msg    : Byte;
    Season : TPodServerSeason;
  end;

// update data from master to slave
  TUpdateData = record
    Msg          : Byte;   // UpdateMsg
    SeasonI      : Byte;
    Rotation     : TRotationLayerArray;
    PsRD         : TPodServerRD;
    PsPerlin     : TPodServerPerlin;
    PsParticle   : TPodServerParticle;
    CamTouch     : TTouchArray;
  end;
  PUpdateData = ^TUpdateData;

  TRDPreset = record
    F,K,H : Byte;
  end;
  TRDPresetArray = array[1..RD_PRESETS] of TRDPreset;

  TCountDownData = record
    Msg   : Byte;
    Index : Byte;
  end;
  PCountDownData = ^TCountDownData;

var
  PodServerSeason   : TPodServerSeason;
  PodServerDefaults : TPodServerSeasonArray;

  SeasonReceived : Boolean = False;

  Placement : TSlavePlacement;

  LastPresetI : Byte = 0;

  CalSettings : TCalibrationSettingsMsg;

const
  RDPreset : TRDPresetArray =
    ((F:20;K:79;H:10),(F:20;K:73;H:10),(F:19;K:66;H:10),(F:24;K:78;H:10));

implementation

end.
