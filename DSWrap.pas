unit DSWrap;

interface
uses
  SysUtils, Windows, DSound, Dialogs;

type
  EDSoundErr = class(Exception)
    DSoundResult : HResult;
    constructor Create(const Err : HResult; const Msg : string);
    end;

  TDSound = class(TObject)
    protected
      FDSObj: IDirectSound;
      FCaps: DSCAPS;

    public
      constructor Create;
      destructor Destroy; override;

      property Caps: DSCAPS read FCaps;
      property IDS: IDirectSound read FDSObj;

      function Init(hwnd: hWnd; dwLevel: DWORD): HResult;
      function GetCaps: HResult;
      function IsCapable(Flag: DWORD): Boolean;

    end;

  TDSBuffer = class(TObject)
    protected
      FDSBufObj: IDirectSoundBuffer;
      FCaps: DSBCAPS;
      FDesc: DSBUFFERDESC;
      FLoop: Boolean;

    public
      constructor Create;

      property Caps: DSBCAPS read FCaps;
      property Desc: DSBUFFERDESC read FDesc write FDesc;
      property IDSB: IDirectSoundBuffer read FDSBufObj;
      property Loop: Boolean read FLoop write FLoop default True;
      
      function InitFile(DS: IDirectSound;Flags: DWORD;fn: string): HResult;
// bare init function. FDesc must be set before calling this
      function Initialize(DS:IDirectSound) : HResult;

    end;

function GetDSErrorString(error:integer) : string;

implementation

uses
  WavePlay;

function GetDSErrorString(error:integer) : string;
begin
  Result:='DS Error';
//  case Error of
{    DSERR_ALLOCATED : Result:='Resources in use elsewhere.';
    DSERR_CONTROLUNAVAIL : Result:='Control Unavailable.';
    DSERR_INVALIDPARAM : Result:='Invalid Parameter passed.';
    DSERR_INVALIDCALL : Result:='Invalid call while in current state.';
    DSERR_GENERIC : Result:='Generic error';
    DSERR_PRIOLEVELNEEDED : Result:='Need higher priority level.';
    DSERR_OUTOFMEMORY : Result:='Out of memory.';
    DSERR_BADFORMAT : Result:='Invalid format used.';
    DSERR_UNSUPPORTED : Result:='Unsupported function.';
    DSERR_NODRIVER : Result:='No sound driver.';
    DSERR_ALREADYINITIALIZED : Result:='Already initialized';
    DSERR_NOAGGREGATION : Result:='Object doesn''t support aggregation.';
    DSERR_BUFFERLOST : Result:='Buffer lost.';
    DSERR_OTHERAPPHASPRIO : Result:='External application has higher priority.';
    else Result:='Unknown error.';}
//  end;
end;

constructor EDSoundErr.Create(const Err : HResult; const Msg : string);
begin
  inherited Create(Msg);
  DSoundResult := Err;
end;

constructor TDSound.Create;
begin
  inherited Create;
end;

destructor TDSound.Destroy;
begin
  if Assigned(FDSObj) then FDSObj.Release;
  inherited Destroy;
end;

constructor TDSBuffer.Create;
begin
  inherited Create;
end;

function TDSound.Init(hwnd: hWnd; dwLevel: DWORD): HResult;
// Creates a directsound interface object and sets the cooperative level
begin
  Result:=DirectSoundCreate(nil,FDSObj,nil);
  if Result=DS_OK then FDSObj.SetCooperativeLevel(hwnd, dwLevel)
  else ShowMessage('Unable to initialize the DirectSound interface');
end;

function TDSBuffer.InitFile(DS:IDirectSound;Flags:DWORD;fn:string): HResult;
var
  WaveForm: tAudio_waveform;
  pAudioBuffer1,
  pAudioBuffer2: pointer;
  nAudioBuffer1Bytes,
  nAudioBuffer2Bytes: DWORD;
begin
// Read the waveform from a file
  WaveForm := TAudio_waveform.Create;
  try
// read the file
    WaveForm.Read(fn);

// Setup the DSBufferDesc structure
    FDesc.dwSize := SizeOf(FDesc);
    FDesc.dwFlags := flags;
    FDesc.dwBufferBytes := WaveForm.Header.dwBufferLength;
    FDesc.lpwfxFormat := @WaveForm.Format;

    Result:=DS.CreateSoundBuffer(FDesc,FDSBufObj,nil);

    if Result = DS_OK then begin
      FDSBufObj.Lock(0,FDesc.dwBufferBytes,pAudioBuffer1,nAudioBuffer1Bytes,
        pAudioBuffer2,nAudioBuffer2Bytes,0);
      Move(WaveForm.Data^, PByte(pAudioBuffer1)^, nAudioBuffer1Bytes);
      FDSBufObj.UnLock(pAudioBuffer1,nAudioBuffer1Bytes,pAudioBuffer2,
                       nAudioBuffer2Bytes);

    end
    else
      raise EDSoundErr.Create(result,'Unable to create sound buffer : '+
         GetDSErrorString(result));
    finally
      WaveForm.Free;
    end;
end;

function TDSBuffer.Initialize(DS:IDirectSound): HResult;
begin
  Result := DS.CreateSoundBuffer(FDesc,FDSBufObj,nil);
end;

function TDSound.GetCaps: HResult;
{Retrieves the Capabilities of the DirectSound object}
begin

  FCaps.dwSize := SizeOf(FCaps);
  FCaps.dwFlags := 0;
  result := FDSObj.GetCaps(FCaps);
  if result <> DS_OK then
    raise EDSoundErr.Create(
      result,
      'Unable to initialize the DirectSound interface'
      );

end; {TDSound.GetCaps}

function TDSound.IsCapable(Flag: DWORD): Boolean;
begin
  result := False;
  if Flag and FCaps.dwFlags = Flag then
    result := True;

end;

end.
