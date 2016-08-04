unit MP3PlayerU;

interface

uses
  Windows, Forms, Dialogs, Classes, SysUtils;

type
  TMP3Player = class(TObject)
  private
    Channel : DWord;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Play(FileName:AnsiString);
    procedure PlayMP3Number(I:Integer);

    procedure Stop;
    procedure SetVolume(Volume:DWord);
  end;

var
  MP3Player : TMP3Player;

implementation

uses
  Bass, Routines;

constructor TMP3Player.Create;
begin
  inherited;

  BASS_Init(-1, 44100, 0, Application.Handle, nil);
  BASS_SetVolume(80);

  Channel:=0;
end;

destructor TMP3Player.Destroy;
begin
  Bass_Free;

  inherited;
end;

procedure TMP3Player.PlayMP3Number(I:Integer);
var
  FileName : AnsiString;
begin
  FileName:=MP3Path+IntToStr(I)+'.mp3';
  if FileExists(FileName) then begin
    Play(FileName);
  end;
end;

procedure TMP3Player.Play(FileName:AnsiString);
begin
  if Channel<>0 then begin
    BASS_StreamFree(Channel);
    Channel:=0;
  end;

  if FileExists(FileName) then begin
    Channel:=BASS_StreamCreateFile(False,PAnsiChar(FileName), 0, 0, 0);
    if Channel=0  then ShowMessage('Error loading '+FileName)
    else begin
      BASS_ChannelPlay(Channel,False);
    end;
  end;
end;

procedure TMP3Player.Stop;
begin
  BASS_ChannelStop(Channel);
end;

procedure TMP3Player.SetVolume(Volume:DWord);
begin
  BASS_SetVolume(Volume);
end;

end.
