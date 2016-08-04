unit WaveWrap;

interface

uses SysUtils, Windows, MMSystem;

const
     NUM_WAVE_FORMATS = 12;
     NUM_WAVE_FUNCTIONS = 7;

type

  eWave_error = class(Exception)
    Wave_result : integer;
    constructor Create(const Err : integer;const Msg : string);
  end;

  tWave_device = class
    Handle : HWaveOut;
    Caps   : TWaveOutCaps;

    constructor Create;

    function GetOutCaps(const DeviceID: integer) : MMRESULT;
    function Open(var Format : TWaveFormatEx;const Flags  : DWORD) : MMRESULT;
    function Close : MMRESULT;
    function Prepare_header(var Header : TWaveHdr) : MMRESULT;
    function Unprepare_header(var Header : TWaveHdr) : MMRESULT;
    function Write(var Header : TWaveHdr): MMRESULT;

  end;

function WaveFormatString(const FormatConstant: UINT): string;
function WaveFunctionString(const FunctionConstant: UINT): string;

implementation

constructor eWave_error.Create(
  const Err : integer;
  const Msg : string
  );
    begin
        inherited Create(Msg);
        Wave_result := Err;
        end;

constructor tWave_device.Create;
    begin

        inherited Create;
        Handle := 0;
        end;

function tWave_device.GetOutCaps(
  const DeviceID: integer
  ) : MMRESULT;
    begin
    result := waveOutGetDevCaps(
                DeviceID,
                @Caps,
                SizeOf(Caps)
                );
    if result <> MMSYSERR_NOERROR then
        raise eWave_error.Create(result,
          'Unable to get device capabilities'
          );
    end;

function tWave_device.Open(
  var   Format : TWaveFormatEx;
  const Flags  : DWORD
  ) : MMRESULT;
    begin
        result := waveOutOpen(
                    @Handle,
                    WAVE_MAPPER,  { Let Windows choose device. }
                    @Format,
                    DWORD(nil),   { No callback. }
                    0,            { No instance. }
                    Flags
                    );
        if result <> 0 then
            raise eWave_error.Create(result,
              'Error opening output wave device'
              );
        end;

function tWave_device.Close : MMRESULT;
    begin
        result := waveOutClose(Handle);
        if result <> 0 then
            raise eWave_error.Create(result,
              'Error closing output wave device'
              );
        end;

function tWave_device.Prepare_header(
  var   Header : TWaveHdr
  ) : MMRESULT;
    begin
        result := waveOutPrepareHeader(Handle,
                    @Header,
                    sizeof(Header)
                    );
        if result <> 0 then
            raise eWave_error.Create(result,
              'Error preparing header for output wave device'
              );
        end;

function tWave_device.Unprepare_header(
  var   Header : TWaveHdr
  ) : MMRESULT;
    begin
        result := waveOutUnprepareHeader(Handle,
                    @Header,
                    sizeof(Header)
                    );
        if result <> 0 then
            raise eWave_error.Create(result,
              'Error unpreparing header for output wave device'
              );
        end;

function tWave_device.Write(
  var   Header : TWaveHdr
  ): MMRESULT;
    begin
        result := waveOutWrite(Handle,
                    @Header,
                    sizeof(Header)
                    );
        if result <> 0 then
            raise eWave_error.Create(result,
              'Error writing to output wave device'
              );
        end;

function WaveFormatString(const FormatConstant: UINT): string;
begin
  case FormatConstant of
    WAVE_FORMAT_1M08: result := '11.025 kHz. Mono. 8-bit';
    WAVE_FORMAT_1S08: result := '11.025 kHz. Stereo 8bit';
    WAVE_FORMAT_1M16: result := '11.025 kHz. Mono. 16-bit';
    WAVE_FORMAT_1S16: result := '11.025 kHz. Stereo 16-bit';
    WAVE_FORMAT_2M08: result := '22.05 kHz. Mono. 8-bit';
    WAVE_FORMAT_2S08: result := '22.05 kHz. Stereo 8-bit';
    WAVE_FORMAT_2M16: result := '22.05 kHz. Mono. 16-bit';
    WAVE_FORMAT_2S16: result := '22.05 kHz. Stereo 16-bit';
    WAVE_FORMAT_4M08: result := '44.1 kHz. Mono. 8-bit';
    WAVE_FORMAT_4S08: result := '44.1 kHz. Stereo 8-bit';
    WAVE_FORMAT_4M16: result := '44.1 kHz. Mono. 16-bit';
    WAVE_FORMAT_4S16: result := '44.1 kHz. Stereo 16-bit';
    else result := 'Unknown Format';
  end;
end;

function WaveFunctionString(
  const FunctionConstant: UINT
  ): string;

  begin
    case FunctionConstant of
      WAVECAPS_PITCH:
        result := 'Pitch Control';
      WAVECAPS_PLAYBACKRATE:
        result := 'Playback Rate Control';
      WAVECAPS_VOLUME:
        result := 'Volume Control';
      WAVECAPS_LRVOLUME:
        result := 'Separate L/R Volume Control';
      WAVECAPS_SYNC:
        result := 'Syncronization';
      WAVECAPS_SAMPLEACCURATE:
        result := 'Sample Accurate';
      WAVECAPS_DIRECTSOUND:
        result := 'DirectSound!!!!';

      else
        result := 'Invalid Function';

      end;
  end;

{initialization}
end.

