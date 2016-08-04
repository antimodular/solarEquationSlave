unit ShadTrkr;

interface

uses
  Windows, Graphics, Global, Math, Forms, ProjectorU;

type
  TRGBColor = record
    R,G,B : Byte;
  end;

const
  MaxShadows     = 12;
  MaxChainLength = 9999;
  MaxLogEntries  = 10;

  MaxTargets    = 12;
  AreaPerTarget = 1000;

type
  TBottomLine = record
    X1,X2 : Integer;
    Y     : array[0..MaxImageW-1] of Integer;
  end;

  TShadowDirectionArray = array[0..MaxImageW-1,0..MaxImageH-1] of Byte;

  TPixelInsideArray = array[0..MaxImageW-1,0..MaxImageH-1] of Boolean;

  TChainLink = record
    X,Y   : Integer;
    Xp,Yp : Integer;
    Dir   : Integer;
    Drawn : Boolean;
  end;
  TChainLinkArray = array[1..MaxChainLength] of TChainLink;

  TChain = record
    Length : Integer;
    Link   : TChainLinkArray;
  end;
  TChainArray = array[1..MaxShadows] of TChain;

  TTrackCornerArray = array[1..4] of TPixelPoint;

  TShadowTrackerInfo = record
    LoThresh       : Integer;
    HiThresh       : Integer;
    TrackCorner    : TTrackCornerArray;
    UseReferences  : Boolean;
    LowF,HighF     : Single;
    MinArea        : Integer;
    Reserved       : array[1..252] of Byte;
  end;

  TShadow = record
    XMin,XMax    : Integer; // x limits in camera pixels
    YMin,YMax    : Integer; // y limits in camera pixels
    XAtYMin      : Integer; // where in X the top is in camera pixels
    YAtXMin      : Integer;
    YAtXMax      : Integer;
    Xc,Yc        : Integer; // center in camera pixels
    Area         : Integer; // area in camera pixels
    ProjXMin     : TPixelPoint; // chain projector pixel limits
    ProjXMax     : TPixelPoint;
    ProjYMin     : TPixelPoint;
    ProjYMax     : TPixelPoint;
    TopPt        : TMetrePt;
    CornerPt     : array[1..4] of TPixelPoint;
    LeftMetrePt  : TMetrePt;
    RightMetrePt : TMetrePt;
    TopMetrePt   : TMetrePt;
    BtmMetrePt   : TMetrePt;
    LeftClipped  : Boolean;
    TopClipped   : Boolean;
    RightClipped : Boolean;
  end;
  TShadowArray = array[1..MaxShadows] of TShadow;

  TTarget = record
    Xc,YMin : Integer;
    ShadowI : Integer;
  end;
  TTargetArray = array[1..MaxTargets] of TTarget;

  TLogEntry = record
    Shadow  : TShadowArray;
    WinI    : Integer;
    Shadows : Integer;
    Time    : Integer;
    LeftI   : Integer;
    RightI  : Integer;
    LeftD   : Integer;
    RightD  : Integer;
  end;
  TLog = array[1..MaxLogEntries] of TLogEntry;

  TShadowTracker = class(TObject)
  private
    ShadowDirection : TShadowDirectionArray;

    procedure TraceShadow(Bmp:TBitmap;X,Y:Integer);
    procedure TraceShadowWithReferences(Bmp:TBitmap;X,Y,Count:Integer;var Curled:Boolean);

    function  GetInfo:TShadowTrackerInfo;
    procedure SetInfo(NewInfo:TShadowTrackerInfo);

    function  YPixelToVolume(YMin:Integer):Integer;

    procedure FindTargetsFromShadows;

    function  DarkBmpName:String;
    function  BrightBmpName:String;
    procedure LoadDarkBmp;
    procedure LoadBrightBmp;
    procedure UpdateWithReferences(Bmp:TBitmap);

    function PixelOnLeftEdge(X,Y:Integer):Boolean;
    function PixelOnRightEdge(X,Y:Integer):Boolean;
    function PixelOnTopEdge(X,Y:Integer):Boolean;

    procedure FindClippedEdges;
    procedure FindLinePixels;

  public
    Shadow              : TShadowArray;
    ShadowCount         : Integer;
    LastShadowCount     : Integer;
    Target              : TTargetArray;
    TargetCount         : Integer;
    MinX,MaxX           : Integer;
    MinY,MaxY           : Integer;
    TrackCorner         : TTrackCornerArray;
    LoThresh            : Integer;
    HiThresh            : Integer;
    PixelInTrackingArea : TPixelInsideArray;
    EdgePixel           : TPixelInsideArray;
    DarkBmp,BrightBmp   : TBitmap;
    SubtractedBmp       : TBitmap;
    UseReferences       : Boolean;
    LowF,HighF          : Single;
    MinArea             : Integer;
    LinePixel           : TPixelInsideArray;
    BottomLine          : TBottomLine;
    Chain               : TChainArray;

    property Info:TShadowTrackerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure Update(Bmp:TBitmap);
    procedure DrawShadows(Bmp:TBitmap);
    procedure ShowShadowPixels(Bmp:TBitmap);
    procedure TraceChain(Bmp:TBitmap;S,EndI:Integer);
    procedure DrawChains(Bmp:TBitmap);

    procedure DrawChainsOnChainProjectorBmp(Bmp:TBitmap);
    procedure DrawShadowsOnChainProjectorBmp(Bmp:TBitmap);

    procedure InitForTracking;
    procedure FillPixelInTrackingAreaArray;
    procedure ShowThresholds(Bmp:TBitmap);
    procedure SaveDarkBmp;
    procedure SaveBrightBmp;
    procedure DrawReferenceBmp(Bmp:TBitmap);
    procedure ShowReferenceThresholds(Bmp:TBitmap);
    procedure DrawSubtractedBmp;

    procedure DrawDistortedBoundary(Bmp:TBitmap;DrawBottom:Boolean);

    procedure ShowPixelsInTrackingArea(Bmp:TBitmap);
    procedure DrawBottomLine(Bmp:TBitmap);
    procedure DrawEdgePixels(Bmp:TBitmap);
    procedure FindBottomLine;
    procedure InitForMouseTest;
  end;

var
  Tracker : TShadowTracker;

function DefaultShadowTrackerInfo:TShadowTrackerInfo;

implementation

uses
  SysUtils, BmpUtils, Dialogs, Classes, CameraU, Main, Routines;

function DefaultShadowTrackerInfo:TShadowTrackerInfo;
var
  I : Integer;
begin
  FillChar(Result,SizeOf(Result),0);
  with Result do begin

// thresholds
    LoThresh:=50;
    HiThresh:=75;

// track corners
    TrackCorner[1].X:=0;
    TrackCorner[1].Y:=0;
    TrackCorner[2].X:=MaxImageW;
    TrackCorner[2].Y:=0;
    TrackCorner[3].X:=MaxImageW;
    TrackCorner[3].Y:=MaxImageH;
    TrackCorner[4].X:=0;
    TrackCorner[4].Y:=MaxImageH;

    UseReferences:=True;
    UseReferences:=False;

    LowF:=0.20;
    HighF:=0.30;
    MinArea:=500;
  end;
end;

function TShadowTracker.GetInfo:TShadowTrackerInfo;
begin
  Result.LoThresh:=LoThresh;
  Result.HiThresh:=HiThresh;
  Result.TrackCorner:=TrackCorner;
  Result.UseReferences:=UseReferences;
  Result.LowF:=LowF;
  Result.HighF:=HighF;
  Result.MinArea:=MinArea;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TShadowTracker.SetInfo(NewInfo:TShadowTrackerInfo);
begin
  LoThresh:=NewInfo.LoThresh;
  HiThresh:=NewInfo.HiThresh;
  TrackCorner:=NewInfo.TrackCorner;
  UseReferences:=NewInfo.UseReferences;
  LowF:=NewInfo.LowF;
  HighF:=NewInfo.HighF;
  MinArea:=NewInfo.MinArea;

  FillPixelInTrackingAreaArray;
end;

constructor TShadowTracker.Create;
begin
  inherited;

  DarkBmp:=CreateImageBmp;
  LoadDarkBmp;

  BrightBmp:=CreateImageBmp;
  LoadBrightBmp;

  SubtractedBmp:=CreateImageBmp;
  DrawSubtractedBmp;
end;

destructor TShadowTracker.Destroy;
begin
  if Assigned(DarkBmp) then DarkBmp.Free;
  if Assigned(BrightBmp) then BrightBmp.Free;
  if Assigned(SubtractedBmp) then SubtractedBmp.Free;
  inherited;
end;

procedure TShadowTracker.InitForMouseTest;
begin
  LoThresh:=100;
  HiThresh:=200;
  TrackCorner[1].X:=0;
  TrackCorner[1].Y:=0;
  TrackCorner[2].X:=MaxImageW;
  TrackCorner[2].Y:=0;
  TrackCorner[3].X:=MaxImageW;
  TrackCorner[3].Y:=MaxImageH;
  TrackCorner[4].X:=0;
  TrackCorner[4].Y:=MaxImageH;

  UseReferences:=False;
  LowF:=0.40;
  HighF:=0.60;

  MinArea:=100;
end;

procedure TShadowTracker.DrawSubtractedBmp;
var
  X,Y  : Integer;
  Line : PByteArray;
begin
  SubtractBmpAsmAbs(BrightBmp,DarkBmp,SubtractedBmp);
  for Y:=0 to SubtractedBmp.Height-1 do begin
    Line:=SubtractedBmp.ScanLine[Y];
    for X:=0 to SubtractedBmp.Width-1 do begin
      if Line^[X*3]=0 then Line^[X*3]:=1;
    end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Follow the trail of pixels around counter clockwise until  we end up back at
// the start.
//
//  1  2  3
//   \ | /
//  8--o--4   <= Directions
//   / | \
//  7  6  5
//
////////////////////////////////////////////////////////////////////////////////
procedure TShadowTracker.TraceShadow(Bmp:TBitmap;X,Y:Integer);
const    // [last direction,preferred direction]
  PreferredDir : array[1..8,1..8] of Integer =
    ((4,3,2,1,8,7,6,5),(5,4,3,2,1,8,7,6),(6,5,4,3,2,1,8,7),(7,6,5,4,3,2,1,8),
     (8,7,6,5,4,3,2,1),(1,8,7,6,5,4,3,2),(2,1,8,7,6,5,4,3),(3,2,1,8,7,6,5,4));
var
  XMin,XMax   : Integer;
  YMin,YMax   : Integer;
  XAtYMin     : Integer;
  Area,I,Int  : Integer;
  Dir,TestDir : Integer;
  Xc,Yc,Xt,Yt : Integer; // current and test X,Y
  DeadDir     : Integer;
  Found,Done  : Boolean;
  Hopeless    : Boolean;
  Line        : PByteArray;
  NS          : Integer;
  DeadLength  : Integer;
  LocalDir    : TShadowDirectionArray;
begin
  Move(ShadowDirection,LocalDir,SizeOf(ShadowDirection));

// since we scan left to right, the 1st direction is 4
  Dir:=4;
  XMin:=X; XMax:=X;
  YMin:=Y; YMax:=Y;
  Xc:=X; Yc:=Y;
  Done:=False;
  NS:=ShadowCount+1;
  with Chain[NS] do begin
    Length:=1;
    Link[1].X:=X;
    Link[1].Y:=Y;
    Link[1].Dir:=4;
  end;
  repeat
    I:=0;
    Found:=False;
    repeat
      Inc(I);
      TestDir:=PreferredDir[Dir,I];

// find the test pixel X
      if TestDir in [3,4,5] then Xt:=Xc+1
      else if TestDir in [1,7,8] then Xt:=Xc-1
      else Xt:=Xc;

// find the test pixel Y
      if TestDir in [1,2,3] then Yt:=Yc-1
      else if TestDir in [5,6,7] then Yt:=Yc+1
      else Yt:=Yc;

// only use this pixel if it's in bounds
//  if PixelInTrackingArea[Xt,Yt]  then begin
      if (Xt>=0) and (Xt<Camera.ImageW) and (Yt>=0) and (Yt<Camera.ImageH) and

//       PixelInTrackingArea[Xt,Yt] and
        (LocalDir[Xt,Yt]<>Dir) then begin

// look for a dark pixel in the preferred direction
        Line:=Bmp.ScanLine[Yt];
        Int:=Line[Xt*3];
        Found:=(Int<HiThresh);
      end;
    until Found or (I=7);

// if we never found the next link, we may have hit a dead end - try back
// tracking in the direction opposite of which we came, trying to go in the
// last 4 preferred directions of the current projection - give up when we've
// backtracked all the way to the start
    if (not Found) and (Chain[NS].Length>1) then with Chain[NS] do begin
      repeat
        DeadDir:=Link[Length].Dir;
        Dec(Length);
        Hopeless:=(Length=0);
        if not Hopeless then begin
          I:=3;  // we'll check PrefDir[4..8]
          repeat
            Inc(I);
            TestDir:=PreferredDir[DeadDir,I];
            if TestDir in [3,4,5] then Xt:=Link[Length].X+1
            else if TestDir in [1,7,8] then Xt:=Link[Length].X-1
            else Xt:=Link[Length].X;
            if TestDir in [1,2,3] then Yt:=Link[Length].Y-1
            else if TestDir in [5,6,7] then Yt:=Link[Length].Y+1
            else Yt:=Link[Length].Y;
            if (Xt>=0) and (Xt<Camera.ImageW) and (Yt>=0) and (Yt<Camera.ImageH) and
                PixelInTrackingArea[Xt,Yt] and (LocalDir[Xt,Yt]=0) then
            begin
              Line:=Bmp.ScanLine[Yt];
              Int:=Line[Xt*3];
              Found:=(Int<HiThresh);
            end;
          until Found or (I=8);
        end;
      until Found or Hopeless;
    end;
    if Found then begin
      Dir:=TestDir; // this direction was successful
      LocalDir[Xt,Yt]:=Dir; // mark this pixel as a shadow edge

// update the current pixel
      Xc:=Xt; Yc:=Yt;

// update the chain
      with Chain[NS] do begin
        Inc(Length);
        Link[Length].X:=Xc;
        Link[Length].Y:=Yc;
        Link[Length].Dir:=Dir;
      end;

// update the shadow limits
      if Xt<XMin then XMin:=Xt
      else if Xt>XMax then XMax:=Xt;
      if Yt<YMin then begin
        YMin:=Yt;
        XAtYMin:=Xt;
      end
      else if Yt>YMax then YMax:=Yt;
      Done:=(Xt=X) and (Yt=Y);
    end;
  until Done or (Chain[NS].Length=MaxChainLength) or not Found;

  if Done then begin
    Area:=(XMax-XMin)*(YMax-YMin);
    if Area>=MinArea then begin
      Inc(ShadowCount);
      Shadow[ShadowCount].Area:=Area;
      Shadow[ShadowCount].XMin:=XMin;
      Shadow[ShadowCount].XMax:=XMax;
      Shadow[ShadowCount].YMin:=YMin;
      Shadow[ShadowCount].YMax:=YMax;
      Shadow[ShadowCount].XAtYMin:=XAtYMin;
      Shadow[ShadowCount].Xc:=(XMin+XMax) div 2;
      Shadow[ShadowCount].Yc:=(YMin+YMax) div 2;
      for I:=1 to Chain[NS].Length do with Chain[NS].Link[I] do begin
        ShadowDirection[X,Y]:=LocalDir[X,Y];
      end;
    end;
  end;
end;

procedure TShadowTracker.Update(Bmp:TBitmap);
var
  X,Y,I : Integer;
  Line  : PByteArray;
begin
  if UseReferences then begin
    UpdateWithReferences(Bmp);
    Exit;
  end;

  LastShadowCount:=ShadowCount;

// clear the shadow pixel flags
  FillChar(ShadowDirection,SizeOf(ShadowDirection),0);
  ShadowCount:=0;
  for Y:=MaxY downto MaxY do begin
    Line:=Bmp.ScanLine[Y];
//    X:=MinX;
    X:=TrackCorner[4].X;
    repeat

// if we hit a previously defined shadow pixel, zoom past it until we're out of
// the shadow
      if ShadowDirection[X,Y]>0 then begin
        repeat
          Inc(X);
          I:=Line^[X*3];
        until (I>HiThresh) or (X=MaxX);
      end
      else begin
        I:=Line^[X*3];
        if I<=LoThresh then begin
          TraceShadow(Bmp,X,Y);
          if ShadowCount=MaxShadows then Exit
        end;
        Inc(X);
      end;
    until (X>=TrackCorner[3].X);//MaxX);
  end;

// break the shadows up into targets - each shadow will be 1 or more target
  FindTargetsFromShadows;
end;

procedure TShadowTracker.ShowShadowPixels(Bmp:TBitmap);
var
  X,Y  : Integer;
  Line : PByteArray;
begin
  for Y:=MinY to MaxY do begin
    Line:=Bmp.ScanLine[Y];
    for X:=MinX to MaxX do if ShadowDirection[X,Y]>0 then begin
      Line[X*3+0]:=255;
      Line[X*3+1]:=255;
      Line[X*3+2]:=0;
    end;
  end;
end;

procedure TShadowTracker.DrawBottomLine(Bmp:TBitmap);
var
  X,Y : Integer;
begin
  if BottomLine.X1<0 then Exit;
  Bmp.Canvas.Pen.Color:=clRed;
  for X:=BottomLine.X1 to BottomLine.X2 do begin
    Y:=BottomLine.Y[X];
    if X=BottomLine.X1 then Bmp.Canvas.MoveTo(X,Y)
    else Bmp.Canvas.LineTo(X,Y);
  end;
end;

procedure TShadowTracker.DrawEdgePixels(Bmp:TBitmap);
var
  X,Y  : Integer;
  Line : PByteArray;
begin
  for Y:=0 to Camera.ImageH-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Camera.ImageW-1 do if EdgePixel[X,Y] then begin
      Line^[X*3+1]:=255;
    end;
  end;
end;

procedure TShadowTracker.FindBottomLine;
var
  Bmp        : TBitmap;
  M,Yu,Xd,Yd : Single;
  X,Xp,Yp,I  : Integer;
  Line       : PByteArray;
begin
  if TrackCorner[3].X=TrackCorner[4].X then Exit;

  Bmp:=CreateImageBmp;
  try
    ClearBmp(Bmp,clBlack);
    Bmp.Canvas.Pen.Color:=clWhite;

    M:=(TrackCorner[3].Y-TrackCorner[4].Y)/(TrackCorner[3].X-TrackCorner[4].X);
    for X:=TrackCorner[4].X to TrackCorner[3].X do begin
      Yu:=Round(TrackCorner[3].Y+M*(X-TrackCorner[3].X));
      Camera.AbleToDistortPixel(X,Yu,Xd,Yd);
      Xp:=Round(Xd);
      Yp:=Round(Yd);
      if X=TrackCorner[4].X then Bmp.Canvas.MoveTo(Xp,Yp)
      else Bmp.Canvas.LineTo(Xp,Yp);
    end;

    FillChar(BottomLine,SizeOf(BottomLine),0);
    BottomLine.X1:=-1;
    for Xp:=0 to MaxImageW-1 do begin
      Yp:=Bmp.Height;
      repeat
        Dec(Yp);
        Line:=Bmp.ScanLine[Yp];
        I:=(Line^[Xp*3]);
      until (Yp=0) or (I>0);
      if I>0 then begin
        if BottomLine.X1<0 then BottomLine.X1:=Xp;
        BottomLine.X2:=Xp;
        BottomLine.Y[Xp]:=Yp;
      end;
    end;
  finally
    if Assigned(Bmp) then Bmp.Free;
  end;
end;

procedure TShadowTracker.DrawDistortedBoundary(Bmp:TBitmap;DrawBottom:Boolean);
var
  M     : Single;
  X,Y   : Integer; // loop vars
  Xu,Yu : Single;  // undistorted
  Xd,Yd : Single;  // distorted
  Xp,Yp : Integer; // pixel
begin
// left line
  if TrackCorner[4].Y=TrackCorner[1].Y then Exit;
  M:=(TrackCorner[1].X-TrackCorner[4].X)/(TrackCorner[1].Y-TrackCorner[4].Y);
  for Y:=TrackCorner[4].Y downto TrackCorner[1].Y do begin
    Xu:=Round(TrackCorner[4].X+M*(Y-TrackCorner[4].Y));
    Camera.AbleToDistortPixel(Xu,Y,Xd,Yd);
    Xp:=Round(Xd);
    Yp:=Round(Yd);
    if Y=TrackCorner[4].Y then Bmp.Canvas.MoveTo(Xp,Yp)
    else Bmp.Canvas.LineTo(Xp,Yp);
  end;

// top line
  if TrackCorner[1].X=TrackCorner[2].X then Exit;
  M:=(TrackCorner[2].Y-TrackCorner[1].Y)/(TrackCorner[2].X-TrackCorner[1].X);
  for X:=TrackCorner[1].X to TrackCorner[2].X do begin
    Yu:=Round(TrackCorner[1].Y+M*(X-TrackCorner[1].X));
    Camera.AbleToDistortPixel(X,Yu,Xd,Yd);
    Xp:=Round(Xd);
    Yp:=Round(Yd);
    Bmp.Canvas.LineTo(Xp,Yp);
  end;

// right line
  if TrackCorner[2].Y=TrackCorner[3].Y then Exit;
  M:=(TrackCorner[3].X-TrackCorner[2].X)/(TrackCorner[3].Y-TrackCorner[2].Y);
  for Y:=TrackCorner[2].Y to TrackCorner[3].Y do begin
    Xu:=Round(TrackCorner[2].X+M*(Y-TrackCorner[2].Y));
    Camera.AbleToDistortPixel(Xu,Y,Xd,Yd);
    Xp:=Round(Xd);
    Yp:=Round(Yd);
    Bmp.Canvas.LineTo(Xp,Yp);
  end;

// bottom line
  if (not DrawBottom) or (TrackCorner[3].X=TrackCorner[4].X) then Exit;
  M:=(TrackCorner[4].Y-TrackCorner[3].Y)/(TrackCorner[4].X-TrackCorner[3].X);
  for X:=TrackCorner[3].X downto TrackCorner[4].X do begin
    Yu:=Round(TrackCorner[3].Y+M*(X-TrackCorner[3].X));
    Camera.AbleToDistortPixel(X,Yu,Xd,Yd);
    Xp:=Round(Xd);
    Yp:=Round(Yd);
    Bmp.Canvas.LineTo(Xp,Yp);
  end;
end;

function TShadowTracker.PixelOnLeftEdge(X,Y:Integer):Boolean;
const
  Border = 5;
begin
  Result:=(X<Border) or (not PixelInTrackingArea[X-Border,Y]);
end;

function TShadowTracker.PixelOnRightEdge(X,Y:Integer):Boolean;
const
  Border = 5;
begin
  Result:=((X+Border)>=Camera.ImageW) or (not PixelInTrackingArea[X+Border,Y]);
end;

function TShadowTracker.PixelOnTopEdge(X,Y:Integer):Boolean;
const
  Border = 5;
begin
  Result:=(Y<Border) or (not PixelInTrackingArea[X,Y-Border]);
end;

//  Result:=EdgePixel[X-1,Y] or EdgePixel[X,Y] or EdgePixel

//function TShadowTracker.PixelCloseToEdge(X,Y:Integer);
//begin
//  Result:=(X<1) or EdgePixel[X-1,Y]

procedure TShadowTracker.DrawShadows(Bmp:TBitmap);
const
  Size = 3;
var
  S : Integer;
begin
  with Bmp.Canvas do begin
    Brush.Style:=bsClear;
    Pen.Color:=clBlue;
    for S:=1 to ShadowCount do with Shadow[S] do begin

// left side
      if not PixelOnLeftEdge(XMin,YAtXMin) then begin
        MoveTo(XMin,YMax);
        LineTo(XMin,YMin);
      end;

// top
      if not PixelOnTopEdge(XAtYMin,YMin) then begin
        MoveTo(XMin,YMin);
        LineTo(XMax,YMin);
      end;

// right
      if not PixelOnRightEdge(XMax,YAtXMax) then begin
        MoveTo(XMax,YMin);
        LineTo(XMax,YMax);
      end;

      Pen.Color:=clRed;
      MoveTo(XMin-Size,Yc); LineTo(XMax+Size,Yc);
      MoveTo(Xc,YMin-Size); LineTo(Xc,YMax+Size);
    end;
  end;
end;

procedure TShadowTracker.TraceChain(Bmp:TBitmap;S,EndI:Integer);
var
  L,I  : Integer;
  Line : PByteArray;
begin
  for L:=1 to EndI do with Chain[S].Link[L] do begin
    Line:=Bmp.ScanLine[Y];
    I:=X*3;
    Line[I+0]:=000;
    Line[I+1]:=255;
    Line[I+2]:=000;
  end;
end;

procedure TShadowTracker.InitForTracking;
begin
  FindLinePixels;
end;

function TShadowTracker.YPixelToVolume(YMin:Integer):Integer;
begin
  Result:=Round(127*(MaxY-YMin)/(MaxY-MinY));
  if Result<0 then Result:=0
  else if Result>127 then Result:=127;
end;

procedure TShadowTracker.DrawChains(Bmp:TBitmap);
var
  S,L,I : Integer;
  Line  : PByteArray;
begin
  for S:=1 to ShadowCount do for L:=1 to Chain[S].Length do begin
    with Chain[S].Link[L] do begin
      Line:=Bmp.ScanLine[Y];
      I:=X*3;
    end;
    Line[I+0]:=000;
    Line[I+1]:=000;
    Line[I+2]:=255;
  end;
end;

procedure TShadowTracker.FindLinePixels;
var
  Bmp   : TBitmap;
  I,X,Y : Integer;
  Line  : PByteArray;
begin
  Bmp:=CreateImageBmp;
  try
    ClearBmp(Bmp,clBlack);
    Bmp.Canvas.Pen.Color:=clWhite;
    Bmp.Canvas.Pen.Width:=1;
    with TrackCorner[4] do Bmp.Canvas.MoveTo(X,Y);
    for I:=1 to 4 do with TrackCorner[I] do Bmp.Canvas.LineTo(X,Y);

    for Y:=0 to Bmp.Height-1 do begin
      Line:=Bmp.ScanLine[Y];
      for X:=0 to Bmp.Width-1 do LinePixel[X,Y]:=(Line^[X*3]>0);
    end;

  finally
    Bmp.Free;
  end;
end;

procedure TShadowTracker.DrawChainsOnChainProjectorBmp(Bmp:TBitmap);
const
  Size1 = 1;
  Size2 = 1;
var
  S,L,I,Xl,Yl   : Integer;
  Line          : PByteArray;
  R,G,B         : Byte;
  PixelPt       : TPixel;
  LimitsDefined : Boolean;
  MetrePt       : TMetrePt;
begin
 { for S:=1 to ShadowCount do begin
    LimitsDefined:=False;
    R:=255;
    G:=0;
    B:=0;
    for L:=1 to Chain[S].Length do with Chain[S].Link[L] do begin

// convert from camera pixels to chain projector pixels
      Xp:=Camera.ProjTable[X,Y].ChainProjectorX;
      Yp:=Camera.ProjTable[X,Y].ChainProjectorY;

      Drawn:=(not LinePixel[X,Y]) and (not EdgePixel[X,Y]);// and (Y<BottomLine.Y[X]);
      if Drawn then begin
//      if (not LinePixel[X,Y]) and (Y<BottomLine.Y[X]) then begin
//      if (Y<BottomLine.Y[X]) then begin
//      if True then begin

        if not LimitsDefined then begin
          LimitsDefined:=True;
          Shadow[S].ProjXMin.X:=Xp;
          Shadow[S].ProjXMin.Y:=Yp;

          Shadow[S].ProjXMax.X:=Xp;
          Shadow[S].ProjXMax.Y:=Yp;

          Shadow[S].ProjYMin.X:=Xp;
          Shadow[S].ProjYMin.Y:=Yp;

          Shadow[S].ProjYMax.X:=Xp;
          Shadow[S].ProjYMax.Y:=Yp;

// initialize all of these to the same current metre point value
          Shadow[S].LeftMetrePt:=ChainProjector.PixelXYToMetrePt(Xp,Yp);
          Shadow[S].TopMetrePt:=Shadow[S].LeftMetrePt;
          Shadow[S].RightMetrePt:=Shadow[S].LeftMetrePt;
          Shadow[S].BtmMetrePt:=Shadow[S].LeftMetrePt;
        end
        else begin
          MetrePt:=ChainProjector.PixelXYToMetrePt(Xp,Yp);
          if MetrePt.X<Shadow[S].LeftMetrePt.X then begin
            Shadow[S].LeftMetrePt:=MetrePt;
            Shadow[S].ProjXMin.X:=Xp;
            Shadow[S].ProjXMin.Y:=Yp;
          end
          else if MetrePt.X>Shadow[S].RightMetrePt.X then begin
            Shadow[S].RightMetrePt:=MetrePt;
            Shadow[S].ProjXMax.X:=Xp;
            Shadow[S].ProjXMax.Y:=Yp;
          end;

          if MetrePt.Z>Shadow[S].TopMetrePt.Z then begin
            Shadow[S].TopMetrePt:=MetrePt;
            Shadow[S].ProjYMin.X:=Xp;
            Shadow[S].ProjYMin.Y:=Yp;
          end
          else if MetrePt.Z<Shadow[S].BtmMetrePt.Z then begin
            Shadow[S].BtmMetrePt:=MetrePt;
            Shadow[S].ProjYMax.X:=Xp;
            Shadow[S].ProjYMax.Y:=Yp;
          end;
        end;

        for YL:=Yp-Size1 to Yp+Size2 do if (YL>=0) and (YL<Bmp.Height-1) then begin
          Line:=Bmp.ScanLine[YL];
          for XL:=Xp-Size1 to Xp+Size2 do if (XL>=0) and (XL<=Bmp.Width-1) then begin
            I:=XL*3;
            Line[I+0]:=B;
            Line[I+1]:=G;
            Line[I+2]:=R;
          end;
        end;
      end;
    end;
  end;}
end;

procedure TShadowTracker.FindClippedEdges;
const
  Border = -3;
var
  S,L,XT,YT  : Integer;
  LeftSlope  : Single;
  TopSlope   : Single;
  RightSlope : Single;
begin
{  for S:=1 to ShadowCount do begin
    with Shadow[S] do begin
      LeftClipped:=False;
      TopClipped:=False;
      RightClipped:=False;

// find the limits of the shadows in metres
      LeftMetrePt:=ChainProjector.PixelXYToMetrePt(ProjXMin.X,ProjXMin.Y);
      RightMetrePt:=ChainProjector.PixelXYToMetrePt(ProjXMax.X,ProjXMax.Y);
      TopMetrePt:=ChainProjector.PixelXYToMetrePt(ProjYMin.X,ProjYMin.Y);
      BtmMetrePt:=ChainProjector.PixelXYToMetrePt(ProjYMax.X,ProjYMax.Y);

// take these metre extremes and define a box in pixels

// left bottom
      CornerPt[1]:=ChainProjector.MetreXZToPixelXY(LeftMetrePt.X,BtmMetrePt.Z);

// left top
      CornerPt[2]:=ChainProjector.MetreXZToPixelXY(LeftMetrePt.X,TopMetrePt.Z);

// right top
      CornerPt[3]:=ChainProjector.MetreXZToPixelXY(RightMetrePt.X,TopMetrePt.Z);

// right bottom
      CornerPt[4]:=ChainProjector.MetreXZToPixelXY(RightMetrePt.X,BtmMetrePt.Z);

// find the slope of the lines defining the bounding box
      if CornerPt[2].Y=CornerPt[1].Y then LeftSlope:=9999
      else LeftSlope:=(CornerPt[2].X-CornerPt[1].X)/(CornerPt[2].Y-CornerPt[1].Y);

      if CornerPt[3].X=CornerPt[2].X then TopSlope:=9999
      else TopSlope:=(CornerPt[3].Y-CornerPt[2].Y)/(CornerPt[3].X-CornerPt[2].X);

      if CornerPt[4].X=CornerPt[3].X then RightSlope:=9999
      else RightSlope:=(CornerPt[4].X-CornerPt[3].X)/(CornerPt[4].Y-CornerPt[3].Y);
    end;

    for L:=1 to Chain[S].Length do with Chain[S].Link[L] do if not Drawn then begin

// left - find the x pixel that intercepts the bounding box at the height
      if not Shadow[S].LeftClipped then begin
        XT:=Shadow[S].CornerPt[1].X+Round((Yp-Shadow[S].CornerPt[1].Y)*LeftSlope);
        if Xp<=XT+Border then begin
          Shadow[S].LeftClipped:=True;
        end;
      end;

// top
      if not Shadow[S].TopClipped then begin
        YT:=Shadow[S].CornerPt[2].Y+Round((Xp-Shadow[S].CornerPt[2].X)*TopSlope);
        if Yp<YT then Shadow[S].TopClipped:=True;
      end;

// right
      if not Shadow[S].RightClipped then begin
        XT:=Shadow[S].CornerPt[3].X+Round((Yp-Shadow[S].CornerPt[3].Y)*RightSlope);
        if Xp>XT-Border then Shadow[S].RightClipped:=True;
      end;
    end;
  end;}
end;

procedure TShadowTracker.DrawShadowsOnChainProjectorBmp(Bmp:TBitmap);
const
  Size = 0;
var
  X1,X2,Y1,Y2   : Integer;
  S,Xm,Ym       : Integer;
  XMid,YMid     : Integer;
  CenterMetrePt : TMetrePt;
  LeftPixel     : TPixelPoint;
  RightPixel    : TPixelPoint;
  TopPixel      : TPixelPoint;
  BtmPixel      : TPixelPoint;
begin
 { FindClippedEdges;
  with Bmp.Canvas do begin
    Brush.Style:=bsClear;
    for S:=1 to ShadowCount do with Shadow[S] do begin
      Pen.Color:=clRed;

      if UseMetricCal then begin

// left side
        if not LeftClipped then begin
          MoveTo(CornerPt[1].X,CornerPt[1].Y);
          LineTo(CornerPt[2].X,CornerPt[2].Y);
        end;

// top
        if not TopClipped then begin
          MoveTo(CornerPt[2].X,CornerPt[2].Y);
          LineTo(CornerPt[3].X,CornerPt[3].Y);
        end;

// right
        if not RightClipped then begin
          MoveTo(CornerPt[3].X,CornerPt[3].Y);
          LineTo(CornerPt[4].X,CornerPt[4].Y);
        end;
      end
      else begin
        X1:=ProjXMin.X;
        X2:=ProjXMax.Y;
        Y1:=ProjYMin.Y;
        Y2:=ProjYMax.Y;
        MoveTo(X1,Y2);
        LineTo(X1,Y1);
        LineTo(X2,Y1);
        LineTo(X2,Y2);
      end;

// crosshairs
      Pen.Color:=clGreen;
      if UseMetricCal then begin
        Xm:=(ProjXMin.X+ProjXMax.X) div 2;
        Ym:=(ProjYMin.Y+ProjYMax.Y) div 2;
        CenterMetrePt:=ChainProjector.PixelXYToMetrePt(Xm,Ym);
        TopPt.X:=CenterMetrePt.X;
        TopPt.Z:=TopMetrePt.Z;
        with CenterMetrePt do begin
          LeftPixel:=ChainProjector.MetreXZToPixelXY(LeftMetrePt.X,Z);
          RightPixel:=ChainProjector.MetreXZToPixelXY(RightMetrePt.X,Z);
          TopPixel:=ChainProjector.MetreXZToPixelXY(X,TopMetrePt.Z);
          BtmPixel:=ChainProjector.MetreXZToPixelXY(X,BtmMetrePt.Z);
        end;
        with LeftPixel do MoveTo(X,Y);
        with RightPixel do LineTo(X,Y);
        with TopPixel do MoveTo(X,Y);
        with BtmPixel do LineTo(X,Y);
      end
      else begin
        Xm:=Camera.ProjTable[Xc,Yc].ChainProjectorX;
        Ym:=Camera.ProjTable[Xc,Yc].ChainProjectorY;
        MoveTo(X1,Ym); LineTo(X2,Ym);
        MoveTo(Xm,Y1); LineTo(Xm,Y2);
      end;
    end;
  end;}
end;

procedure TShadowTracker.ShowPixelsInTrackingArea(Bmp:TBitmap);
var
  X,Y  : Integer;
  Line : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      if PixelInTrackingArea[X,Y] then Line^[X*3]:=255;
    end;
  end;
end;

procedure TShadowTracker.FillPixelInTrackingAreaArray;
var
  Bmp   : TBitmap;
  Poly  : array[1..4] of TPoint;
  I,X,Y : Integer;
  Line  : PByteArray;
begin
  Bmp:=CreateImageBmp;
  try
    ClearBmp(Bmp,clBlack);
    Bmp.Canvas.Pen.Color:=clWhite;
    Bmp.Canvas.Brush.Color:=clWhite;

// edge pixels
    Bmp.Canvas.Pen.Width:=1;
    DrawDistortedBoundary(Bmp,False);
    for Y:=0 to Bmp.Height-1 do begin
      Line:=Bmp.ScanLine[Y];
      for X:=0 to Bmp.Width-1 do begin
        EdgePixel[X,Y]:=(Line^[X*3]>0);
      end;
    end;

    ClearBmp(Bmp,clBlack);
    Bmp.Canvas.Pen.Color:=clWhite;
    Bmp.Canvas.Brush.Color:=clWhite;
    DrawDistortedBoundary(Bmp,True);
    X:=(TrackCorner[1].X+TrackCorner[3].X) div 2;
    Y:=(TrackCorner[1].Y+TrackCorner[3].Y) div 2;
    Bmp.Canvas.FloodFill(X,Y,clWhite,fsBorder);
    for Y:=0 to Bmp.Height-1 do begin
      Line:=Bmp.ScanLine[Y];
      for X:=0 to Bmp.Width-1 do begin
        PixelInTrackingArea[X,Y]:=(Line^[X*3]>0);
      end;
    end;

  finally
    Bmp.Free;
  end;

  MinX:=MaxImageW-1;
  MaxX:=0;
  MinY:=MaxImageH-1;
  MaxY:=0;
  for X:=0 to MaxImageW-1 do for Y:=0 to MaxImageH-1 do begin
    if PixelInTrackingArea[X,Y] then begin
      if X<MinX then MinX:=X;
      if X>MaxX then MaxX:=X;
      if Y<MinY then MinY:=Y;
      if Y>MaxY then MaxY:=Y;
    end;
  end;
  FindBottomLine;
end;

procedure TShadowTracker.FindTargetsFromShadows;
var
  S : Integer;
begin
  for S:=1 to ShadowCount do begin
    Target[S].Xc:=Shadow[S].Xc;
    Target[S].YMin:=Shadow[S].YMin;
    Target[S].ShadowI:=S;
  end;
  TargetCount:=ShadowCount;
end;

procedure TShadowTracker.ShowThresholds(Bmp:TBitmap);
var
  X,Y,I,V : Integer;
  Line    : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      if Line^[I]<LoThresh then V:=50
      else if Line^[I]<HiThresh then V:=100
      else V:=255;
      Line^[I+0]:=V;
      Line^[I+1]:=V;
      Line^[I+2]:=V;
    end;
  end;
end;

function TShadowTracker.DarkBmpName:String;
begin
  Result:=Path+'Dark.bmp';
end;

function TShadowTracker.BrightBmpName:String;
begin
  Result:=Path+'Bright.bmp';
end;

procedure TShadowTracker.SaveDarkBmp;
begin
  Camera.Bmp.SaveToFile(DarkBmpName);
  DarkBmp.Assign(Camera.Bmp);
end;

procedure TShadowTracker.SaveBrightBmp;
begin
  Camera.Bmp.SaveToFile(BrightBmpName);
  BrightBmp.Assign(Camera.Bmp);
end;

procedure TShadowTracker.LoadDarkBmp;
begin
  if FileExists(DarkBmpName) then DarkBmp.LoadFromFile(DarkBmpName)
  else ClearBmp(DarkBmp,clBlack);
end;

procedure TShadowTracker.LoadBrightBmp;
begin
  if FileExists(BrightBmpName) then BrightBmp.LoadFromFile(BrightBmpName)
  else ClearBmp(BrightBmp,clWhite);
end;

procedure TShadowTracker.DrawReferenceBmp(Bmp:TBitmap);
var
  TopBmp         : TBitmap;
  X,Y,I          : Integer;
  B              : Byte;
  V              : Single;
  TopLine        : PByteArray;
  SubtractedLine : PByteArray;
  DestLine       : PByteArray;
begin
  TopBmp:=CreateImageBmp;
  try
    SubtractBmpAsmAbs(BrightBmp,Camera.Bmp,TopBmp);
    for Y:=0 to Bmp.Height-1 do begin
      TopLine:=TopBmp.ScanLine[Y];
      SubtractedLine:=SubtractedBmp.ScanLine[Y];
      DestLine:=Bmp.ScanLine[Y];
      for X:=0 to Bmp.Width-1 do begin
        I:=X*3;
        V:=255*TopLine^[I]/SubtractedLine^[I];
        if V>=255 then B:=255
        else B:=Round(V);
        DestLine^[I]:=B;
        DestLine^[I+1]:=B;
        DestLine^[I+2]:=B;
      end;
    end;
  finally
    TopBmp.Free;
  end
end;

procedure TShadowTracker.ShowReferenceThresholds(Bmp:TBitmap);
var
  TopBmp         : TBitmap;
  X,Y,I          : Integer;
  B              : Byte;
  V,F            : Single;
  TopLine        : PByteArray;
  SubtractedLine : PByteArray;
  DestLine       : PByteArray;
begin
  TopBmp:=CreateImageBmp;
  try
    SubtractBmpAsmAbs(BrightBmp,Camera.Bmp,TopBmp);
    for Y:=0 to Bmp.Height-1 do begin
      TopLine:=TopBmp.ScanLine[Y];
      SubtractedLine:=SubtractedBmp.ScanLine[Y];
      DestLine:=Bmp.ScanLine[Y];
      for X:=0 to Bmp.Width-1 do begin
        I:=X*3;
        F:=TopLine^[I]/SubtractedLine^[I];
        if F>=HighF then B:=255
        else if F>=LowF then B:=127
        else B:=0;
        DestLine^[I]:=B;
        DestLine^[I+1]:=B;
        DestLine^[I+2]:=B;
      end;
    end;
  finally
    TopBmp.Free;
  end
end;

procedure TShadowTracker.UpdateWithReferences(Bmp:TBitmap);
var
  X,Y,X3,X1,X2   : Integer;
  Count          : Integer;
  Line           : PByteArray;
  BrightLine     : PByteArray;
  SubtractedLine : PByteArray;
  F,Xd,Yd        : Single;
  Curled         : Boolean;
begin
  if BottomLine.X1<0 then Exit;

  LastShadowCount:=ShadowCount;

// clear the shadow pixel flags
  FillChar(ShadowDirection,SizeOf(ShadowDirection),0);
  ShadowCount:=0;
  X1:=TrackCorner[4].X;
  X2:=TrackCorner[3].X;

  Camera.AbleToDistortPixel(TrackCorner[4].X,TrackCorner[4].Y,Xd,Yd);
  X1:=Round(Xd);
  Y:=Round(Yd);
  Camera.AbleToDistortPixel(TrackCorner[3].X,TrackCorner[3].Y,Xd,Yd);
  X2:=Round(Xd);

    X:=BottomLine.X1;
  repeat
    Y:=BottomLine.Y[X];
    Line:=Bmp.ScanLine[Y];

// if we hit a previously defined shadow pixel, zoom past it until we're out of
// the shadow
    if ShadowDirection[X,Y]>0 then begin
      repeat
        Inc(X);
        Y:=BottomLine.Y[X];
        Line:=Bmp.ScanLine[Y];
        X3:=X*3;
        F:=(BrightLine^[X3]-Line^[X3])/SubtractedLine^[X3];
      until (F<LowF) or (X=X2);//MaxX);
    end
    else begin
      X3:=X*3;
      F:=(BrightLine^[X3]-Line^[X3])/SubtractedLine^[X3];
      if F>=HighF then begin
        Count:=0;
        repeat
          Inc(Count);
          TraceShadowWithReferences(Bmp,X,Y,Count,Curled);
        until (Count=4) or (not Curled);

        if ShadowCount=MaxShadows then Exit;

// skip past this one
        repeat
          Inc(X);
          X3:=X*3;
          F:=(BrightLine^[X3]-Line^[X3])/SubtractedLine^[X3];
        until (F<LowF) or (X=X2);//MaxX);
      end
      else Inc(X);
    end;
  until (X=X2);//MaxX);

// break the shadows up into targets - each shadow will be 1 or more target
  FindTargetsFromShadows;
end;

////////////////////////////////////////////////////////////////////////////////
// Follow the trail of pixels around counter clockwise until  we end up back at
// the start.
//
//  1  2  3
//   \ | /
//  8--o--4   <= Directions
//   / | \
//  7  6  5
//
////////////////////////////////////////////////////////////////////////////////
procedure TShadowTracker.TraceShadowWithReferences(Bmp:TBitmap;X,Y,Count:Integer;var Curled:Boolean);
const    // [last direction,preferred direction]
  PreferredDir : array[1..8,1..8] of Integer =
    ((4,3,2,1,8,7,6,5),(5,4,3,2,1,8,7,6),(6,5,4,3,2,1,8,7),(7,6,5,4,3,2,1,8),
     (8,7,6,5,4,3,2,1),(1,8,7,6,5,4,3,2),(2,1,8,7,6,5,4,3),(3,2,1,8,7,6,5,4));
  MinLength = 50;
  StartDir : array[1..4] of Integer = (1,8,7,6);
var
  XMin,XMax      : Integer;
  YMin,YMax      : Integer;
  XAtYMin        : Integer;
  YAtXMin        : Integer;
  YAtXMax        : Integer;
  Area,I,Int     : Integer;
  Dir,TestDir    : Integer;
  Xc,Yc,Xt,Yt    : Integer; // current and test X,Y
  DeadDir        : Integer;
  Found,Done     : Boolean;
  Hopeless       : Boolean;
  Line           : PByteArray;
  NS,X3          : Integer;
  DeadLength     : Integer;
  LocalDir       : TShadowDirectionArray;
  BrightLine     : PByteArray;
  SubtractedLine : PByteArray;
  F              : Single;
begin
  Move(ShadowDirection,LocalDir,SizeOf(ShadowDirection));

// since we scan left to right, the 1st direction is 4
//  Dir:=4;
  Dir:=StartDir[Count];
  Curled:=False;

  LocalDir[X,Y]:=Dir; // mark this pixel as a shadow edge

  XMin:=X; XMax:=X;
  YMin:=Y; YMax:=Y;

  YAtXMin:=Y;
  YAtXMax:=Y;
  XAtYMin:=X;

  Xc:=X; Yc:=Y;
  Done:=False;
  NS:=ShadowCount+1;
  with Chain[NS] do begin
    Length:=1;
    Link[1].X:=X;
    Link[1].Y:=Y;
    Link[1].Dir:=4;
  end;
  repeat
    I:=0;
    Found:=False;
    repeat
      Inc(I);
      TestDir:=PreferredDir[Dir,I];

// find the test pixel X
      if TestDir in [3,4,5] then Xt:=Xc+1
      else if TestDir in [1,7,8] then Xt:=Xc-1
      else Xt:=Xc;

// find the test pixel Y
      if TestDir in [1,2,3] then Yt:=Yc-1
      else if TestDir in [5,6,7] then Yt:=Yc+1
      else Yt:=Yc;

// only use this pixel if it's in bounds
      if (Xt>=0) and (Xt<MaxImageW) and (Yt>=0) and (Yt<MaxImageH) and
         PixelInTrackingArea[Xt,Yt] and (LocalDir[Xt,Yt]<>Dir) then begin

// look for a dark pixel in the preferred direction
        Line:=Bmp.ScanLine[Yt];
        BrightLine:=BrightBmp.ScanLine[Yt];
        SubtractedLine:=SubtractedBmp.ScanLine[Yt];
        X3:=Xt*3;
        F:=(BrightLine^[X3]-Line^[X3])/SubtractedLine^[X3];
        Found:=(F>=LowF);
      end;
    until Found or (I=7);

// if we never found the next link, we may have hit a dead end - try back
// tracking in the direction opposite of which we came, trying to go in the
// last 4 preferred directions of the current projection - give up when we've
// backtracked all the way to the start
    if (not Found) and (Chain[NS].Length>1) then with Chain[NS] do begin
      repeat
        DeadDir:=Link[Length].Dir;
        Dec(Length);
        Hopeless:=(Length=0);
        if not Hopeless then begin
          I:=3;  // we'll check PrefDir[4..8]
          repeat
            Inc(I);
            TestDir:=PreferredDir[DeadDir,I];
            if TestDir in [3,4,5] then Xt:=Link[Length].X+1
            else if TestDir in [1,7,8] then Xt:=Link[Length].X-1
            else Xt:=Link[Length].X;
            if TestDir in [1,2,3] then Yt:=Link[Length].Y-1
            else if TestDir in [5,6,7] then Yt:=Link[Length].Y+1
            else Yt:=Link[Length].Y;
            if (Xt>=0) and (Xt<MaxImageW) and (Yt>0) and (Yt<MaxImageH) and
                  PixelInTrackingArea[Xt,Yt] and (LocalDir[Xt,Yt]=0) then
            begin
              X3:=Xt*3;
              Line:=Bmp.ScanLine[Yt];
              BrightLine:=BrightBmp.ScanLine[Yt];
              SubtractedLine:=SubtractedBmp.ScanLine[Yt];
              F:=(BrightLine^[X3]-Line^[X3])/SubtractedLine^[X3];
              Found:=(F>=LowF);
            end;
          until Found or (I=8);
        end;
      until Found or Hopeless;
    end;
    if Found then begin
      Dir:=TestDir; // this direction was successful
      LocalDir[Xt,Yt]:=Dir; // mark this pixel as a shadow edge

// update the current pixel
      Xc:=Xt; Yc:=Yt;

// update the chain
      with Chain[NS] do begin
        Inc(Length);
        Link[Length].X:=Xc;
        Link[Length].Y:=Yc;
        Link[Length].Dir:=Dir;
      end;

// update the shadow limits
      if Xt<XMin then begin
        XMin:=Xt;
        YAtXMin:=Yt;
      end
      else if Xt>XMax then begin
        XMax:=Xt;
        YAtXMax:=Yt;
      end;
      if Yt<YMin then begin
        YMin:=Yt;
        XAtYMin:=Xt;
      end
      else if Yt>YMax then YMax:=Yt;
      Done:=(Xt=X) and (Yt=Y);
    end;
  until Done or (Chain[NS].Length=MaxChainLength) or not Found;

  if Done then begin
    if Chain[NS].Length<MinLength then Curled:=True
    else begin
      Area:=(XMax-XMin)*(YMax-YMin);
      if Area>=MinArea then begin
        Inc(ShadowCount);
        Shadow[ShadowCount].Area:=Area;
        Shadow[ShadowCount].XMin:=XMin;
        Shadow[ShadowCount].XMax:=XMax;
        Shadow[ShadowCount].YMin:=YMin;
        Shadow[ShadowCount].YMax:=YMax;
        Shadow[ShadowCount].XAtYMin:=XAtYMin;
        Shadow[ShadowCount].YAtXMin:=YAtXMin;
        Shadow[ShadowCount].YAtXMax:=YAtXMax;

        Shadow[ShadowCount].Xc:=(XMin+XMax) div 2;
        Shadow[ShadowCount].Yc:=(YMin+YMax) div 2;
        for I:=1 to Chain[NS].Length do with Chain[NS].Link[I] do begin
          ShadowDirection[X,Y]:=LocalDir[X,Y];
        end;
      end;
    end;
  end;
end;

end.


