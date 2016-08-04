unit DxSound;

interface

uses
  DSound, DSWrap, MMSystem, SysUtils, Windows, Global, PoemU;

const
  MaxWaves = MaxPoems;
  ShadowCountIncreaseWaveI = 1;
  ShadowCountDecreaseWaveI = 2;

procedure UpdateWaves;
  
procedure InitDxSound(Handle:THandle);
procedure ShutDownDxSound;

procedure LoadDxWave(WaveNum:Integer;FileName:String);
procedure PlayDxWave(WaveNum:Integer);

procedure LoadDxWaves;

type
  TWaveFileNameArray = array[1..MaxWaves] of TNameStr;

var
// our direct sound object
  DirectSound   : TDSound;
  PrimaryBuffer : TDSBuffer;
  PrimaryFormat : TWaveFormatEx;
  DsBuffer      : array[1..MaxWaves] of TDSBuffer;
  WaveFileName  : TWaveFileNameArray;

implementation

uses
  Dialogs, Forms, Controls, Buttons, Routines, ShadTrkr;

procedure SetPrimaryFormat; forward;
procedure StopWave(WaveNum:Integer); forward;
procedure SetVolume(WaveNum,NewVolume:Integer); forward;
procedure SetFrequency(WaveNum,NewFreq:Integer); forward;
procedure SetBalance(WaveNum,NewBalance:Integer); forward;

procedure InitDxSound(Handle:THandle);
var
  Error : HResult;
  NewDesc : DSBUFFERDESC;
begin
// create the direct sound object
  DirectSound:=TDSound.Create;

// init the directSound with the specified co-op level
// Options: DSSCL_NORMAL, DSSCL_PRIORITY, DSSCL_EXCLUSIVE, DSSCL_WRITEPRIMARY
  if DirectSound.Init(Handle, DSSCL_Exclusive)<>DS_OK then Exit;

// create a primary buffer so we can control the Playback format
  PrimaryBuffer:=TDSBuffer.Create;

// set up Desc...
  NewDesc:=PrimaryBuffer.Desc;
  NewDesc.dwSize:=sizeOf(DSBufferDesc);
  NewDesc.dwFlags:=DSBCAPS_PRIMARYBUFFER;
  NewDesc.dwBufferBytes:=0;
  NewDesc.lpwfxFormat:=nil;

  PrimaryBuffer.Desc:=NewDesc;

// Create the IDirectSound buffer part
  Error:=PrimaryBuffer.Initialize(DirectSound.IDS);

// Raise an exception if there was a problem
  if Error<>DS_OK then begin
    ShowMessage('Unable to create primary buffer: '+GetDSErrorString(Error));
    Exit;
  end;

// init the primary format
  with PrimaryFormat do begin

// this *must* be 1, since it's the only format direct sound supports
    wFormatTag:=1;
    nChannels:=2; // must be stereo if we want to pan
    nSamplesPerSec := 44100;
    nAvgBytesPerSec:=nSamplesPerSec*2*nChannels;
    wBitsPerSample:=16;

// block align - how many bytes need for 1 sample of all channels
    nBlockAlign:=nChannels*(wBitsPerSample div 8);

// and finally, the mysterious cbSize which is always zero...
    cbSize:=0;
  end;

  SetPrimaryFormat;
end;

procedure ShutDownDxSound;
var
  WaveNum : Integer;
begin
// free the secondary buffers

  for WaveNum:=1 to MaxWaves do if Assigned(dsBuffer[WaveNum]) then begin
    dsBuffer[WaveNum].idsb.stop;
    dsBuffer[WaveNum].Free;
  end;

// free the primary buffer
  PrimaryBuffer.Free;

// free the sound card
  DirectSound.Free;
end;

procedure SetPrimaryFormat;
var
  Error : Integer;
begin
// Set the primary buffer format
  Error:=PrimaryBuffer.IDSB.SetFormat(PrimaryFormat);
  if Error<>DS_OK then begin
    ShowMessage('Unable to Set format : '+GetDSErrorString(Error));
  end;
end;

procedure LoadDxWave(WaveNum:Integer;FileName:String);
var
  FullName : String;
  WavePath : String;
begin
  WavePath:=Path+'/Poems';
  FullName:=WavePath+FileName;
  if not FileExists(FullName) then begin
    ShowMessage('Unable to find wave file: '+FullName);
    Exit;
  end;
  WaveFileName[WaveNum]:=FileName;

// if we've already created this object, dispose of it and we'll start over
  if Assigned(dsBuffer[WaveNum]) then begin
    with dsBuffer[WaveNum] do begin
      if Assigned(IDSB) then IDSB.Stop;
      Free;
    end;
    dsBuffer[WaveNum]:=nil;
  end;
  dsBuffer[WaveNum]:=TDSBuffer.create;

// Load the Wave into our Wave buffer
  with dsBuffer[WaveNum] do begin

//      Desc.
// DSBCAPS_CTRLDEFAULT : pan, Freq, and volume control
// DSBCAPS_STATIC      : Load entire Wave file into memory
// DSBCAPS_GLOBALFOCUS : continue to Play buffers even when switched
//                       to another directSound application.
    InitFile(directSound.ids,DSBCAPS_CTRLDEFAULT or DSBCAPS_STATIC or
             dsbCaps_globalFocus,FullName);
  end;

// set the sound buffer to it's default Status
  SetVolume(WaveNum,255);
  SetFrequency(WaveNum,0);
  SetBalance(WaveNum,127);
end;

procedure PlayDxWave(WaveNum:Integer);
var
  Status : DWord;
begin
  if Assigned(dsBuffer[WaveNum]) then with dsBuffer[WaveNum] do begin
    if IDSB<>nil then begin
      IDSB.GetStatus(Status);
      if (Status and DSBSTATUS_BUFFERLOST)>0 then begin
        IDSB.Restore;
        InitFile(directSound.ids,DSBCAPS_CTRLDEFAULT or DSBCAPS_STATIC or
                 dsbCaps_globalFocus,WaveFileName[WaveNum]);
      end;
      IDSB.Play(0,0,0);
    end;
  end;
end;

procedure StopWave(WaveNum:Integer);
begin
  if dsBuffer[WaveNum] <> nil then begin
    dsBuffer[WaveNum].idsb.Stop;
  end;
end;

procedure SetVolume(WaveNum,NewVolume:Integer);
var
  NewSetting : longint;
begin
// we could convert between 255 (loudest) and 0 (quietest) to
// 0 (loudest) and -10000 (quietest - -100dB)
// since -33dB is next to silent, we'll only use the 0 to -33dB range
// which will give us more resolution in the useful part of the volume
// scale
  NewSetting:=round((255-NewVolume)*(-3333/255));
  if Assigned(dsBuffer[WaveNum]) then begin
    with dsBuffer[WaveNum] do if IDSB<>nil then IDSB.SetVolume(NewSetting);
  end;
end;

procedure SetFrequency(WaveNum,NewFreq:Integer);
var
  NewSetting: longint;
begin
// we must convert between 1 (slowest) and 255(fastest) to
// 100 (slowest) and 100000 (fastest)
// if NewFreq=0, send a 0 which will Set the F to the WaveFile default
  NewSetting:=NewFreq*392; { range of 0 to 99960 }
  if dsBuffer[WaveNum]<>nil then begin
    with dsBuffer[WaveNum] do if IDSB<>nil then IDSB.SetFrequency(NewSetting);
  end;
end;

procedure SetBalance(WaveNum,NewBalance:Integer);
var
  NewSetting: longint;
begin
// we must convert between 0 (left) and 255(right) with 127 as center to
// -6000 (left) and +6000 (right) with 0 as center
  NewSetting:=round((NewBalance-127)*(6000/128));
  if dsBuffer[WaveNum]<>nil then begin
    with dsBuffer[WaveNum] do if IDSB<>nil then IDSB.SetPan(NewSetting);
  end;
end;

procedure LoadDxWaves;
var
  I : Integer;
begin
  for I:=1 to MaxWaves do begin
    if WaveFileName[I]<>'' then LoadDxWave(I,WaveFileName[I]);
  end;
end;

procedure UpdateWaves;
begin
  if Tracker.ShadowCount>Tracker.LastShadowCount then begin
    PlayDxWave(ShadowCountIncreaseWaveI);
  end
  else if Tracker.ShadowCount<Tracker.LastShadowCount then begin
    PlayDxWave(ShadowCountDecreaseWaveI);
  end;
end;

end.
