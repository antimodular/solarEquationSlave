unit StopWatchU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  MaxChannels = 16;
  MaxSamples  = 100;

type
  TStopWatchChannel = record
    Start   : Int64;
    Stop    : Int64;
    Passes  : Integer;
    Total   : Double;
    Avg     : Double;
    Last    : Double;
    SampleI : Integer;
    Sample  : array[1..MaxSamples] of Double;
    Name    : String;
  end;
  TStopWatchChannelArray = array[1..MaxChannels] of TStopWatchChannel;

  TStopWatch = class(TObject)
  private
    Freq : Int64;

    function TimeStr(Time:Double):String;

  public
    Channel : TStopWatchChannelArray;

    constructor Create;

    procedure Reset(Ch:Integer);
    procedure Start(Ch:Integer);
    procedure Stop(Ch:Integer);
    procedure ShowHistory(Bmp:TBitmap;LastC,X,Y,W,H:Integer;MaxTime:Double);
    procedure ShowTimes(Bmp:TBitmap;LastC:Integer);
    function  ChannelStr(C:Integer):String;
  end;

var
  StopWatch : TStopWatch;

implementation

constructor TStopWatch.Create;
var
  C : Integer;
begin
  inherited;
  FillChar(Channel,SizeOf(Channel),0);
  QueryPerformanceFrequency(Freq);  // Get frequency
  for C:=1 to MaxChannels do Channel[C].Name:='Channel #'+IntToStr(C);
end;

procedure TStopWatch.Reset(Ch:Integer);
begin
  with Channel[Ch] do begin
    QueryPerformanceCounter(Start);
    Stop:=Start;
    Total:=0;
    Passes:=0;
    Avg:=0;
    SampleI:=0;
    FillChar(Sample,SizeOf(Sample),0);
  end;
end;

procedure TStopWatch.Start(Ch:Integer);
begin
  QueryPerformanceCounter(Channel[Ch].Start);
end;

procedure TStopWatch.Stop(Ch:Integer);
begin
  with Channel[Ch] do if Freq<>0 then begin
    QueryPerformanceCounter(Stop);
    Inc(Passes);
    Last:=(Stop-Start)/Freq;
    if SampleI<MaxSamples then Inc(SampleI)
    else SampleI:=1;
    Sample[SampleI]:=Last;
    Total:=Total+Last;
    Avg:=Total/Passes;
  end;
end;

procedure TStopWatch.ShowHistory(Bmp:TBitmap;LastC,X,Y,W,H:Integer;MaxTime:Double);
const
  ChannelColor : array[1..MaxChannels] of TColor =
    (clRed,clGreen,clBlue,clYellow,clWhite,clCream,clMoneyGreen,clPurple,clNavy,
     clMaroon,clFuchsia,clAqua,clTeal,clSilver,clLime,clSkyBlue);
var
  I,C,Xp,Yp        : Integer;
  XPixelsPerIndex  : Double;
  YPixelsPerSecond : Double;
begin
  with Bmp.Canvas do begin
    Brush.Color:=clBlack;
    Brush.Style:=bsSolid;
    Pen.Color:=clSilver;
    FillRect(Rect(X,Y,X+W,Y+H));
    XPixelsPerIndex:=W/MaxSamples;
    YPixelsPerSecond:=H/MaxTime;
    for C:=1 to LastC do  with Channel[C] do begin
      Pen.Color:=ChannelColor[C];
      for I:=1 to MaxSamples do begin
        Xp:=X+Round(XPixelsPerIndex*(I-1));
        Yp:=Y+(H-Round(YPixelsPerSecond*Sample[I]));
        if I=1 then MoveTo(Xp,Yp)
        else LineTo(Xp,Yp);
      end;
    end;
  end;
end;

function TStopWatch.TimeStr(Time:Double):String;
begin
  Result:=FloatToStrF(Time,ffFixed,9,3);
end;

procedure TStopWatch.ShowTimes(Bmp:TBitmap;LastC:Integer);
const
  X      = 0;
  StartY = 0;
  YSpace = 15;
var
  Y,C     : Integer;
  Txt     : String;
  AvgSum  : Double;
  LastSum : Double;
begin
  if LastC>0 then with Bmp.Canvas do begin
    Brush.Color:=clBlack;
    Font.Color:=clYellow;
    Font.Size:=8;
    Y:=StartY;
    AvgSum:=0;
    LastSum:=0;
    for C:=1 to LastC do begin
      AvgSum:=AvgSum+Channel[C].Avg;
      LastSum:=LastSum+Channel[C].Last;
      Txt:=Channel[C].Name+' Avg: '+TimeStr(Channel[C].Avg)+
                          ' Last: '+TimeStr(Channel[C].Last);
      TextOut(X,Y,Txt);
      Inc(Y,YSpace);
    end;
    Txt:='Total Avg: '+TimeStr(AvgSum)+' Last:'+TimeStr(LastSum);
    TextOut(X,Y,Txt);
  end;
end;

function TStopWatch.ChannelStr(C:Integer):String;
begin
  Result:='Last : '+FloatToStrF(Channel[C].Last,ffFixed,9,6)+
          ' Avg : '+FloatToStrF(Channel[C].Avg,ffFixed,9,6);
end;

end.
