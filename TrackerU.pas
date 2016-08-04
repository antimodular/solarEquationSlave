unit TrackerU;

interface

uses
  Math, Windows, Graphics, SysUtils, Types, BlobFinderU, Global, Classes;

const
  MaxTargets     = 16;
  MaxTrackedTgts = 16;
  MaxAverages    = 64;

type
  TTrackBorder = record
    XMin,XMax : Integer;
    YMin,YMax : Integer;
  end;

  TTrackerInfo = record
    Averages          : Integer;
    MaxLostTime       : DWord;
    MaxPixelsPerFrame : Integer;
    MinTargetAge      : Integer;
    Reserved          : array[1..60] of Byte;
  end;

  TTarget = record
    XMin,XMax : Integer;
    YMin,YMax : Integer;
    Xc,Yc     : Integer;
    X,Y,Z     : Single;
    BlobI     : Integer;
    TrkTgtI   : Integer;
  end;
  TTargetArray = array[1..MaxTargets] of TTarget;

  TTrackedTarget = record
    X,Y,AvgI,TgtI    : Integer;
    AvgX,AvgY        : array[1..MaxAverages] of Integer;
    DistanceToTarget : array[1..MaxTargets] of Single;
    DrawRect         : TRect;
    BlobRect         : TRect;
    Active           : Boolean;
    LostTime         : DWord;
    Lost             : Boolean;
    Age              : DWord;
    Xm,Ym,Zm         : Single; // metric location
  end;
  TTrackedTargetArray = array[1..MaxTrackedTgts] of TTrackedTarget;

  TTracker = class(TObject)
  private
    function  GetInfo:TTrackerInfo;
    procedure SetInfo(NewInfo:TTrackerInfo);

    function  TargetFromBlob(var iBlob:TBlob):TTarget;
    procedure CreateTrackedTargetFromTarget(I:Integer);
    procedure FindTargetMetreLocations;

  public
    Target      : TTargetArray;
    Targets     : Integer;
    TrackedTgt  : TTrackedTargetArray;
    TrackedTgts : Integer;
    Averages    : Integer;

    XYInTrackArea : TMask;

    MaxLostTime       : DWord;
    MaxPixelsPerFrame : Integer;
    MinTargetAge      : Integer;

    Touch : TTouchArray;

    property Info : TTrackerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure DrawTargets(Bmp:TBitmap);
    procedure DrawTrackedTargets(Bmp:TBitmap);
    procedure OutlineTargets(Bmp:TBitmap);

    procedure FindTargets;

    procedure InitForTracking;
    procedure Update;
    procedure UpdateTracking;

    procedure DrawTrackArea(Bmp:TBitmap);

    procedure LoadTrackAreaMask;
    procedure SaveTrackAreaMask;
    procedure SetToDefault;
    procedure ReadFromStream(Stream: TFileStream);
    procedure WriteToStream(Stream: TFileStream);
  end;

var
  Tracker : TTracker;

function DefaultTrackerInfo:TTrackerInfo;

implementation

uses
  MaskU, Routines;

function TrackAreaMaskFileName:String;
begin
  Result:=Path+'TrackAreaMask.dat';
end;

function DefaultTrackerInfo:TTrackerInfo;
const
  Edge = 10;
begin
  with Result do begin
    Averages:=8;
    MaxLostTime:=4000;
    MaxPixelsPerFrame:=150;
    MinTargetAge:=10;
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

procedure TTracker.SetToDefault;
begin
  Averages:=8;
  MaxLostTime:=4000;
  MaxPixelsPerFrame:=150;
  MinTargetAge:=10;
end;

procedure TTracker.ReadFromStream(Stream:TFileStream);
begin
  Stream.Read(Averages,SizeOf(Averages));
  Stream.Read(MaxLostTime,SizeOf(MaxLostTime));
  Stream.Read(MaxPixelsPerFrame,SizeOf(MaxPixelsPerFrame));
  Stream.Read(MinTargetAge,SizeOf(MinTargetAge));
end;

procedure TTracker.WriteToStream(Stream:TFileStream);
begin
  Stream.Write(Averages,SizeOf(Averages));
  Stream.Write(MaxLostTime,SizeOf(MaxLostTime));
  Stream.Write(MaxPixelsPerFrame,SizeOf(MaxPixelsPerFrame));
  Stream.Write(MinTargetAge,SizeOf(MinTargetAge));
end;

constructor TTracker.Create;
begin
  inherited;
end;

destructor TTracker.Destroy;
begin
  inherited;
end;

function TTracker.GetInfo:TTrackerInfo;
begin
  Result.Averages:=Averages;
  Result.MaxLostTime:=MaxLostTime;
  Result.MaxPixelsPerFrame:=MaxPixelsPerFrame;
  Result.MinTargetAge:=MinTargetAge;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TTracker.SetInfo(NewInfo:TTrackerInfo);
begin
  Averages:=NewInfo.Averages;
  MaxLostTime:=NewInfo.MaxLostTime;
  MaxPixelsPerFrame:=NewInfo.MaxPixelsPerFrame;
  MinTargetAge:=NewInfo.MinTargetAge;
end;

procedure TTracker.LoadTrackAreaMask;
begin
  LoadMask(TrackAreaMaskFileName,@XYInTrackArea);
end;

procedure TTracker.SaveTrackAreaMask;
begin
  SaveMask(TrackAreaMaskFileName,@XYInTrackArea);
end;

procedure TTracker.Update;
begin
  FindTargets;
  UpdateTracking;
  FindTargetMetreLocations;
end;

procedure TTracker.FindTargetMetreLocations;
const
  TrackZ = 1.10;
var
  T       : Integer;
  MetrePt : TPoint3D;
begin
  for T:=1 to TrackedTgts do with TrackedTgt[T] do begin
//    MetrePt:=Camera.PixelTargetAtZ(X,Y,TrackZ);
    Xm:=MetrePt.X;
    Ym:=MetrePt.Y;
  end;
end;

function TTracker.TargetFromBlob(var iBlob:TBlob):TTarget;
begin
  with iBlob do begin
    Result.XMin:=XMin;
    Result.XMax:=XMax;
    Result.YMin:=YMin;
    Result.YMax:=YMax;
    Result.Xc:=Xc;
    Result.Yc:=Yc;
  end;
end;

{procedure TTracker.FindTargetXY(var Tgt:TTarget);
var
  Pt : TPoint3D;
begin
  Pt:=Camera.TargetAtZ(Tgt.Xc,Tgt.Yc,Tgt.Z);
  Tgt.X:=Pt.X;
  Tgt.Y:=Pt.Y;
end;}

procedure TTracker.FindTargets;
var
  I : Integer;
begin
  Targets:=0;
  with BlobFinder do begin
    for I:=1 to BlobCount do if (Blob[I].Area>=MinArea) and (Targets<MaxTargets)
    then begin
      Inc(Targets);
//      Target[Targets]:=TargetFromBlob(Blob[I]);
      Target[Targets].BlobI:=I;
    end;
  end;
end;

procedure TTracker.DrawTargets(Bmp:TBitmap);
var
  I : Integer;
const
  Size = 6;
begin
  Bmp.Canvas.Pen.Color:=clYellow;
  Bmp.Canvas.Brush.Color:=clBlack;
  for I:=1 to Targets do with Target[I] do begin
    Bmp.Canvas.Rectangle(Rect(Xc-Size,Yc-Size,Xc+Size+1,Yc+Size+1));
    Bmp.Canvas.MoveTo(Xc,Yc-Size);
    Bmp.Canvas.LineTo(Xc,Yc+Size+1);
    Bmp.Canvas.MoveTo(Xc-Size,Yc);
    Bmp.Canvas.LineTo(Xc+Size+1,Yc);
  end;
end;

procedure TTracker.DrawTrackedTargets(Bmp:TBitmap);
var
  I : Integer;
const
  Size = 7;
begin
  Bmp.Canvas.Brush.Color:=clBlack;
  for I:=1 to TrackedTgts do with TrackedTgt[I] do begin
    if Age>MinTargetAge then Bmp.Canvas.Pen.Color:=clLime
    else Bmp.Canvas.Pen.Color:=clGray;
    Bmp.Canvas.Rectangle(Rect(X-Size,Y-Size,X+Size+1,Y+Size+1));
    Bmp.Canvas.MoveTo(X,Y-Size);
    Bmp.Canvas.LineTo(X,Y+Size+1);
    Bmp.Canvas.MoveTo(X-Size,Y);
    Bmp.Canvas.LineTo(X+Size+1,Y);
  end;
end;

procedure TTracker.OutlineTargets(Bmp:TBitmap);
var
  I : Integer;
begin
//  for I:=1 to Targets do BlobFinder.OutlineBlob(Bmp,Target[I].BlobI);
end;

procedure TTracker.InitForTracking;
const
  Origin : TPoint3D = (X:0;Y:0;Z:0);
var
  I : Integer;
begin
  for I:=1 to MaxTrackedTgts do with TrackedTgt[I] do begin
    X:=0;
    Y:=0;
    TgtI:=0;
    FillChar(AvgX,SizeOf(AvgX),0);
    FillChar(AvgY,SizeOf(AvgY),0);
    FillChar(DistanceToTarget,SizeOf(DistanceToTarget),0);
    AvgI:=1;
    Active:=False;
  end;
  Targets:=0;
  TrackedTgts:=0;
end;

procedure TTracker.UpdateTracking;
var
  I,I2,BestI   : Integer;
  D,BestD      : Single;
  AvgPt,PredPt : TPoint3D;
  LastI        : Integer;
begin
// start fresh
  for I:=1 to MaxTargets do Target[I].TrkTgtI:=0;
  for I:=1 to MaxTrackedTgts do TrackedTgt[I].TgtI:=0;

// find the distances from each of the targets to each of the tracked targets
  for I:=1 to Targets do with Target[I] do begin
    for I2:=1 to TrackedTgts do begin
      D:=Sqrt(Sqr(Xc-TrackedTgt[I2].X)+Sqr(Yc-TrackedTgt[I2].Y));
      TrackedTgt[I2].DistanceToTarget[I]:=D;
    end;
  end;

// find the closest match to last frames tracked targets
  for I:=1 to TrackedTgts do with TrackedTgt[I] do begin
    BestI:=0;
    for I2:=1 to Targets do if Target[I2].TrkTgtI=0 then begin
      if (DistanceToTarget[I2]<Tracker.MaxPixelsPerFrame) and
         ((BestI=0) or (DistanceToTarget[I2]<BestD)) then
      begin
        BestI:=I2;
        BestD:=DistanceToTarget[I2];
      end;
    end;

// if we found the best match within MaxPixelsPerFrame, update the tracked
// target with the closest target
    if BestI>0 then begin
      TgtI:=BestI;
      Target[TgtI].TrkTgtI:=I;
      if AvgI<Averages then Inc(AvgI)
      else AvgI:=1;
      AvgX[AvgI]:=Target[TgtI].Xc;
      AvgY[AvgI]:=Target[TgtI].Yc;
      X:=0; Y:=0;
      for I2:=1 to Averages do begin
        X:=X+AvgX[I2];
        Y:=Y+AvgY[I2];
      end;
      X:=X div Averages;
      Y:=Y div Averages;
      Lost:=False;
      Inc(Age);
    end

// can't find the target - see if the cover finder thinks its there
    else begin

// if we never found a match, this one will be dropped if enough time has past
      TgtI:=0;

// if it's lost see if it should be de-activated
      if Lost then begin
        if (GetTickCount-LostTime)>MaxLostTime then Active:=False;
      end

// otherwise mark it as lost and record the lost time
      else begin
        LostTime:=GetTickCount;
        Lost:=True;
      end;
    end;
  end;

// re-shuffle the tracked target array so it's continuous
  I:=1;
  while (I<=TrackedTgts) do begin
    if not TrackedTgt[I].Active then begin
      for I2:=I to TrackedTgts-1 do begin
        TrackedTgt[I2]:=TrackedTgt[I2+1];
      end;
      Dec(TrackedTgts);
    end
    else Inc(I);
  end;

// create new tracked targets from the targets that remain unassigned
  I:=0;
  while (I<Targets) and (TrackedTgts<MaxTrackedTgts) do begin
    Inc(I);
    with Target[I] do if TrkTgtI=0 then begin
      CreateTrackedTargetFromTarget(I);
    end;
  end;

  FillChar(Touch,SizeOf(Touch),0);
  LastI:=Min(TrackedTgts,MaxTouches);
  for I:=1 to LastI do begin
    Touch[I].Active:=True;
    Touch[I].X:=TrackedTgt[I].X/TrackW;
    Touch[I].Y:=TrackedTgt[I].Y/TrackH;
  end;
end;

procedure TTracker.CreateTrackedTargetFromTarget(I:Integer);
var
  I2      : Integer;
  StartPt : TPoint3D;
begin
  Inc(TrackedTgts);
  Target[I].TrkTgtI:=TrackedTgts;
  with TrackedTgt[TrackedTgts] do begin
    TgtI:=I;
    X:=Target[TgtI].Xc;
    Y:=Target[TgtI].Yc;
    for I2:=1 to Averages do begin
      AvgX[I2]:=X;
      AvgY[I2]:=Y;
    end;
    StartPt.X:=X;
    StartPt.Y:=Y;
    StartPt.Z:=0;
    Active:=True;
    Lost:=False;
    Age:=1;
  end;
end;

procedure TTracker.DrawTrackArea(Bmp:TBitmap);
begin
  ApplyMaskToBmp(@XYInTrackArea,Bmp);
end;

end.





