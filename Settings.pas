unit Settings;

interface

uses
  Classes, Graphics, ProjectorU;

type
  TFileSignature = String[10];

procedure LoadSettings;
procedure SaveSettings;

procedure SetAllToDefault;

function SizeOfFile(FileName:String):Integer;
function FileSignature(FileName:string) : TFileSignature;

procedure WriteReserveToStream(Stream:TFileStream;Size:Integer);
procedure ReadReserveFromStream(Stream:TFileStream;Size:Integer);

implementation

uses
  Windows, SysUtils, Forms, Dialogs, Routines, SeasonU,
  Global, CameraU, BlobFinderU, TrackerU;

const
  SettingsSignature : TFileSignature = 'SolarEq1.0';

procedure WriteReserveToStream(Stream:TFileStream;Size:Integer);
var
  Reserved : array of Byte;
begin
  SetLength(Reserved,Size);
  FillChar(Reserved[0],Size,0);
  Stream.Write(Reserved[0],Size);
end;

procedure ReadReserveFromStream(Stream:TFileStream;Size:Integer);
begin
  Stream.Seek(Size,soFromCurrent);
end;

function SizeOfFile(FileName:String):Integer;
var
  Handle : Integer;
begin
  Handle:=FileOpen(FileName,fmOpenRead);
  if Handle>0 then begin
    Result:=FileSeek(Handle,0,2); // position at the end of the file
    FlushFileBuffers(Handle);
    FileClose(Handle);
  end
  else Result:=0;
end;

function FileSignature(FileName:string) : TFileSignature;
var
  Handle : Integer;
  Size   : Integer;
begin
  Handle:=FileOpen(FileName,fmOpenRead);
  if Handle>0 then begin
    FileSeek(Handle,0,0);
    Size:=FileRead(Handle,Result,SizeOf(Result));
    if Size<>SizeOf(Result) then Result:='';
    FlushFileBuffers(Handle);
    FileClose(Handle);
  end
  else Result:='';
end;

function SettingsFileName:String;
begin
  Result:=Path+'Settings.dat';
end;

procedure SetAllToDefault;
var
  I : Integer;
begin
// placement
  Placement.Orbit:=soEquatorial;
  Placement.RzOffset:=0;
  Placement.SOffset:=0;

// projectors
  Projectors:=MaxProjectors;
  for I:=1 to MaxProjectors do Projector[I].SetToDefault;

// seasons
  Seasons:=MaxSeasons;
  for I:=1 to MaxSeasons do Season[I].SetToDefault;

  Camera.SetToDefault;
  BlobFinder.SetToDefault;
  Tracker.SetToDefault;

  RunShow:=False;

  VError.Rz:=0.1;
  VError.Offset:=0.1;

  RotationEnabled:=True;
  RotationScale:=10.0;
end;

procedure SaveDefaults;
begin
  SetAllToDefault;
  SaveSettings;
end;

function MinSettingsFileSize:Integer;
begin
  Result:=Length(SettingsSignature);// SizeOf(TFileSignature);//+SizeOf(TAxisInfo);
end;

procedure LoadSettings;
var
  Stream    : TFileStream;
  Signature : AnsiString;
  Size      : Integer;
  MinSize   : Integer;
begin
  Size:=SizeOfFile(SettingsFileName);
  MinSize:=MinSettingsFileSize;
  if FileExists(SettingsFileName) and (Size>=MinSize) then begin
    Stream:=TFileStream.Create(SettingsFileName,fmOpenRead);
    try

// check the signature
      Size:=Length(SettingsSignature);
      SetLength(Signature,Size);
      Stream.Read(Signature[1],Size);
      if Signature<>SettingsSignature then begin
        Stream.Free;
        SaveDefaults;
        Exit;
      end;

// placement
      Stream.Read(Placement,SizeOf(Placement));

// projectors
      Stream.Read(Projectors,SizeOf(Projectors));
      LoadProjectors(Stream);

// seasons
      Stream.Read(Seasons,SizeOf(Seasons));
      LoadSeasons(Stream);

// tracking
      Camera.ReadFromStream(Stream);
      BlobFinder.ReadFromStream(Stream);
      Tracker.ReadFromStream(Stream);

      Stream.Read(RunShow,SizeOf(RunShow));

      Stream.Read(VError,SizeOf(VError));
      Stream.Read(RotationEnabled,SizeOf(RotationEnabled));
      Stream.Read(RotationScale,SizeOf(RotationScale));

// clean up
    finally
      Stream.Free;
    end;
  end

// go with defaults if there was a problem
  else begin
    SetAllToDefault;
    SaveSettings;
  end;
end;

procedure SaveSettings;
var
  Stream : TFileStream;
  Size   : Integer;
begin
  Stream:=TFileStream.Create(SettingsFileName,fmCreate);
  try

// write the signature
    Size:=Length(SettingsSignature);
    Stream.Write(SettingsSignature[1],Size);

// placement
    Stream.Write(Placement,SizeOf(Placement));

// projectors
    Stream.Write(Projectors,SizeOf(Projectors));
    SaveProjectors(Stream);

// seasons
    Stream.Write(Seasons,SizeOf(Seasons));
    SaveSeasons(Stream);

// tracking stuff
    Camera.WriteToStream(Stream);
    BlobFinder.WriteToStream(Stream);
    Tracker.WriteToStream(Stream);

    Stream.Write(RunShow,SizeOf(RunShow));

    Stream.Write(VError,SizeOf(VError));

// clean up
  finally
    Stream.Free;
  end;
end;

end.
