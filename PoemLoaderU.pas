unit PoemLoaderU;

interface

uses
  Windows;

const
  HistoryLength = 3;
  TitleSize     = 200;

type
  TLoaderMode = (lmTitleFadeIn,lmTitlePause,lmTitleFadeOut,lmPoemFadeIn,
                 lmPause,lmStart,lmStop,lmFadeOut);

  TModeTime = array[TLoaderMode] of DWord;

  TPoemHistory = array[1..HistoryLength] of Integer;

  TPoemLoader = class(TObject)
  private
    History  : TPoemHistory;
    HistoryI : Integer;

    StartTime : DWord;

    Fraction : Single;

    procedure StartOver;
    procedure SetMode(NewMode: TLoaderMode);

  public
    PoemI  : Integer;
    Mode   : TLoaderMode;
    Paused : Boolean;

    constructor Create;

    procedure PrepareForShow;
    procedure Update;
    function  StatusStr:String;
    procedure NextStep;
    procedure AssertPoem(P: Integer);
  end;

var
  PoemLoader : TPoemLoader;

const
  ModeTime : TModeTime = (
    3000,   // lmTitleFadeIn
    6000,   // lmTitlePause
    3000,   // lmTitleFadeOut
    5000,   // lmPoemFadeIn
    5000,   // lmPause
    0,      // lmStart (set by the poem)
    2000,   // lmStop
    3000);  // lmFadeOut

implementation

uses
  PoemU, CloudU, FountainU, Routines;

constructor TPoemLoader.Create;
begin
  PoemI:=1;
  Mode:=lmTitleFadeIn;
  inherited;
end;

procedure TPoemLoader.PrepareForShow;
begin
  Paused:=False;
  PoemI:=1;
  FillChar(History,SizeOf(History),0);
  HistoryI:=0;
  StartOver;
end;

procedure TPoemLoader.Update;
var
  Elapsed  : DWord;
  Duration : DWord;
begin
  if Paused then Exit;

  Elapsed:=GetTickCount-StartTime;
  if Mode=lmStart then Duration:=Poem[PoemI].Duration
  else Duration:=ModeTime[Mode];

// see how far along we are in this mode
  Fraction:=Elapsed/Duration;

// if we are done
  if Fraction>=1 then begin
    if Mode=lmFadeOut then StartOver
    else SetMode(Succ(Mode));
    Fraction:=0;
  end;

  Case Mode of
    lmTitleFadeIn    : Fountain.Alpha:=Fraction;
//    lmTitleBlackHole : ;
    lmTitleFadeOut   : Fountain.Alpha:=1.0-Fraction;
    lmPoemFadeIn     : Fountain.Alpha:=Fraction;
    lmStart          : ;
    lmStop           : ;
    lmFadeOut        : Fountain.Alpha:=1.0-Fraction;
  end;
end;

procedure TPoemLoader.SetMode(NewMode:TLoaderMode);
begin
  StartTime:=GetTickCount;
  Mode:=NewMode;

  Cloud.Active:=(Mode in [lmStart]);

// initialize according to the mode
  Case Mode of

    lmTitleFadeIn :
      begin
        Fountain.Reset:=True;
        Fountain.SpriteSize:=TitleSize;
        Fountain.Mode:=fmRigid;
        Fountain.Arrangement:=Poem[PoemI].TitleArrangement;
        Fountain.XPadding:=Poem[PoemI].TitleXPadding;
        Fountain.ShowTitle(Poem[PoemI].Title);
      end;

    lmTitlePause : ;

    lmTitleFadeOut : ;

    lmPoemFadeIn :
      begin
        Fountain.Arrangement:=Poem[PoemI].Arrangement;
        Fountain.XPadding:=Poem[PoemI].XPadding;
        Poem[PoemI].Assert;
        Fountain.SpriteSize:=Poem[PoemI].Size;
        Fountain.Mode:=fmRigid;
        Fountain.Reset:=True;
      end;

    lmStart :
      begin
        Fountain.Mode:=fmNormal;
        Poem[PoemI].PlayWave;
      end;

    lmStop :
      begin
      end;

    lmFadeOut : ;
  end;
end;

procedure TPoemLoader.StartOver;
var
  Count : Integer;
  P,I   : Integer;
  Used  : Boolean;
begin
// select a poem a random that hasn't been shown for a while
 Count:=0;
  repeat
    Inc(Count);

// pick one at random
    P:=1+Random(Poems);

// see if its in the history
    Used:=False;
    for I:=1 to HistoryLength do begin
      if History[I]=P then begin
        Used:=True;
        Break;
      end;
    end;
  until (not Used) or (Count=Poems);

// use it
  PoemI:=P;

// put it in the history
  if HistoryI<HistoryLength then Inc(HistoryI)
  else HistoryI:=1;

  History[HistoryI]:=P;

// start fading in
  SetMode(lmTitleFadeIn);
end;

procedure TPoemLoader.AssertPoem(P:Integer);
var
  Count : Integer;
  I   : Integer;
  Used  : Boolean;
begin
// use it
  PoemI:=P;

// put it in the history
  if HistoryI<HistoryLength then Inc(HistoryI)
  else HistoryI:=1;

  History[HistoryI]:=P;

// start fading in
  SetMode(lmTitleFadeIn);
end;

function TPoemLoader.StatusStr:String;
begin
  Case Mode of
    lmTitleFadeIn    : Result:='Title fade in '+MetreStr(Fraction);
    lmTitlePause     : Result:='Title pause '+MetreStr(Fraction);
    lmTitleFadeOut   : Result:='Title fade out '+MetreStr(Fraction);
    lmPoemFadeIn     : Result:='Poem fade in '+MetreStr(Fraction);
    lmPause          : Result:='Pause '+MetreStr(Fraction);
    lmStart          : Result:='Interactive '+MetreStr(Fraction);
    lmStop           : Result:='Finished '+MetreStr(Fraction);
    lmFadeOut        : Result:='Fade out '+MetreStr(Fraction);
  end;
end;

procedure TPoemLoader.NextStep;
begin
  StartTime:=0;
end;

end.
