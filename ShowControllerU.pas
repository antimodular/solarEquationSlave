unit ShowControllerU;

interface

uses
  Windows, Classes, IniFiles, ZmqServerU, TextureU, Global;

type
  TSeasonChange = record
    Enabled : Boolean;
    MinTime : DWord;
    MaxTime : DWord;
  end;

  TShowController = class(TObject)
  private
    FSoundEnabled : Boolean;

    procedure StartPublishing;
    procedure SetSoundEnabled(V:Boolean);

  public
// ZMQ server as a publisher
    ZmqServer : TZmqServer;

    SeasonChange : TSeasonChange;

    Rotation     : TRotation;
    ActiveSeason : Integer;

    LastSeasonTime : DWord;

    property SoundEnabled:Boolean read FSoundEnabled write SetSoundEnabled;


    constructor Create;
    destructor  Destroy; override;

    procedure SetToDefault;

    procedure ReadFromStream(Stream:TFileStream);
    procedure WriteToStream(Stream:TFileStream);

    procedure LoadFromIniFile(IniFile:TIniFile);
    procedure SaveToIniFile(IniFile:TIniFile);

    procedure StartShow;
    procedure UpdateShow;
    procedure StopShow;

    procedure SetActiveSeason(I:Integer);
  end;

var
  ShowController : TShowController;

implementation

uses
  FountainU, SeasonU, MP3PlayerU,
  Protocol;

constructor TShowController.Create;
begin
  inherited;
  ZmqServer:=TZmqServer.Create;
  Rotation.Enabled:=True;
  Rotation.Scale:=1.0;
  ActiveSeason:=1;
  FSoundEnabled:=False;
end;

destructor TShowController.Destroy;
begin
  if Assigned(ZmqServer) then ZmqServer.Free;
end;

procedure TShowController.SetToDefault;
begin
  with SeasonChange do begin
    Enabled:=True;
    MinTime:=30000;
    MaxTime:=60000;
  end;
end;

procedure TShowController.LoadFromIniFile(IniFile:TIniFile);
begin
  with SeasonChange do begin
    Enabled:=IniFile.ReadBool('SeasonChange','Enabled',True);
    MinTime:=IniFile.ReadInteger('SeasonChange','MinTime',30000);
    MaxTime:=IniFile.ReadInteger('SeasonChange','MaxTime',60000);
  end;
end;

procedure TShowController.SaveToIniFile(IniFile:TIniFile);
begin
  with SeasonChange do begin
    IniFile.WriteBool('SeasonChange','Enabled',Enabled);
    IniFile.WriteInteger('SeasonChange','MinTime',MinTime);
    IniFile.WriteInteger('SeasonChange','MaxTime',MaxTime);
  end;
end;

procedure TShowController.WriteToStream(Stream:TFileStream);
begin
  Stream.Write(SeasonChange,SizeOf(SeasonChange));
end;

procedure TShowController.ReadFromStream(Stream:TFileStream);
begin
  Stream.Read(SeasonChange,SizeOf(SeasonChange));
end;

procedure TShowController.StartPublishing;
begin
end;

procedure TShowController.StartShow;
begin
  RunMode:=rmRun;
  if not TexturesLoaded then LoadTextures;
 // PutSlavesInRunMode(rmRun);
  SetActiveSeason(1);
end;

procedure TShowController.UpdateShow;
var
  L,S,I : Integer;
begin
// update the rotation
  if Rotation.Enabled then begin
    for L:=1 to Layers do with Rotation.Layer[L] do begin
      CubeMapRz:=CubeMapRz+Season[ActiveSeason].CubeMap[L].RotateV*Rotation.Scale/100;
      ImageOffset:=ImageOffset+Season[ActiveSeason].Image[L].RotateV*Rotation.Scale/10000;
      RdOffset:=RdOffset+Season[ActiveSeason].ReactDiffusion[L].RotateV*Rotation.Scale/10000;
//      PerlinRz:=PerlinRz+Season[ActiveSeason].Perlin[L].RotateV*Rotation.Scale/10000;
      ParticleRz:=ParticleRz+Season[ActiveSeason].Particle[L].RotateV*Rotation.Scale/10000;
      if ParticleRz>Pi then ParticleRz:=ParticleRz-(2*Pi)
      else if ParticleRz<-Pi then ParticleRz:=ParticleRz+(2*Pi);
    end;
  end;

// sync the slaves
//  for S:=1 to Slaves do Slave[S].SyncUpdateData;

// reset the touch flags
  for I:=1 to MaxTouches do begin
   // PodServerSeason.ReactDiffuse.TouchUpdated[I]:=False;
  end;

  if SeasonChange.Enabled then begin
    if (GetTickCount-LastSeasonTime)>SeasonChange.MaxTime then begin
      I:=1+Random(MaxSeasons);
      if I=ActiveSeason then begin
        if I<MaxSeasons then Inc(I)
        else I:=1;
      end;
      SetActiveSeason(I);
    end;
  end;
end;

procedure TShowController.StopShow;
begin
  RunMode:=rmIdle;
//  PutSlavesInRunMode(rmIdle);
  MP3Player.SetVolume(0);
  MP3Player.Stop;
end;


procedure TShowController.SetActiveSeason(I:Integer);
var
  L : Integer;
begin
  ActiveSeason:=I;
  CurrentSeason.CopyFromSeason(Season[I]);

  for L:=1 to RDLayers do begin
//    if Assigned(ReactDiffuse[L]) then ReactDiffuse[L].MakeRandom:=True;
  end;

// initialize the spots
  for L:=1 to ParticleLayers do begin
  //  if Assigned(Fountain[L]) then Fountain[L].PlaceSpots;
  end;

//  SyncSpotsWithSlaves;

//  CurrentSeason.InitPodServerSeason(PodServerSeason);

  if FSoundEnabled then CurrentSeason.PlayMP3;

  LastSeasonTime:=GetTickCount;
end;

procedure TShowController.SetSoundEnabled(V:Boolean);
begin
  FSoundEnabled:=V;
  if FSoundEnabled then Season[ActiveSeason].PlayMP3
  else MP3Player.Stop;
end;

end.
