unit PgrKsMedia;

interface

{$MINENUMSIZE 4}

uses
  Windows, Ks;
// KsProxy, KsMedia;

// GUID identifying the custom properties that are exported by the driver.
const
  PROPSETID_CUSTOM : TGUID =
    (D1:$DAE50FA6;D2:$1DAC;D3:$4913;D4:($98,$41,$8E,$D3,$AB,$3F,$EB,$04));
    
type
  TKsPropertyCustom = (KSPROPERTY_CUSTOM_REGISTER,KSPROPERTY_CUSTOM_FORMAT7);

// Record used for getting and setting of registers on the camera.
  TKsPropertyCustomRegisterS = record
    Prop        : TKsProperty;
    StreamIndex : DWord;
    RegAddress  : DWord;
    Value       : DWord;
  end;
  PKsPropertyCustomRegisterS = ^TKsPropertyCustomRegisterS;

// Pixel type. Used for format 7 custom image mode.
  TFormat7PixelFormat = (
    FORMAT7_MONO8    = $0001,      // 8 bit mono
    FORMAT7_411YUV8  = $0002,      // YUV 4:1:1.
    FORMAT7_422YUV8  = $0004,      // YUV 4:2:2.
    FORMAT7_444YUV8  = $0008,      // YUV 4:4:4.
    FORMAT7_RGB8     = $0010,      // R = G = B = 8 bits.
    FORMAT7_MONO16   = $0020,      // 16 bits of mono information.
    FORMAT7_RGB16    = $0040,      // R = G = B = 16 bits.
    FORMAT7_S_MONO16 = $0080,      // 16 bits of signed mono information.
    FORMAT7_S_RGB16  = $0100,      // R = G = B = 16 bits signed.
    FORMAT7_RAW8     = $0200,      // 8 bit raw data output of sensor.
    FORMAT7_RAW16    = $0400,      // 16 bit raw data output of sensor.
    FORMAT7_QUADLET  = $7FFFFFFF); // Unsed member to force this enum to compile to 32 bits.

// Structure used for getting information on availability of format 7 and
// it's parameters, and setting of the format 7 parameters.
  TKsPropertyCustomFormat7S = record
     Prop             : TKsProperty;
     StreamIndex      : DWord;
     ImageLeft        : DWord;
     ImageTop         : DWord;
     ImageWidth       : DWord;
     ImageHeight      : DWord;
     Mode             : DWord;
     Speed            : DWord;
     PacketSize       : DWord;
     Format           : TFormat7PixelFormat;
     Available        : Boolean;
     UnitSizeX        : DWord;
     UnitSizeY	      : DWord;
   	 MaxImageSizeX    : DWord;
   	 MaxImageSizeY    : DWord;
   	 AvailableFormats : DWord;
   end;
   PKsPropertyCustomFormat7S = ^TKsPropertyCustomFormat7S;

implementation

end.
