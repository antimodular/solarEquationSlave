unit BlobFinderU;

interface

uses
  Global, Windows, Graphics, SysUtils, Math, Classes;

const
  MaxBlobs        = 64;
  MaxStripsPerRow = MaxImageW div 2;

type
  TBlobFinderInfo = record
    LoT,HiT           : Integer;
    JumpD             : Integer;
    MinArea           : Integer;
    KalmanTime        : Single;
    KalmanSensitivity : Integer;
    MaxLostTime       : DWord;
    MergeD            : Integer;
    Reserved          : array[1..256] of Byte;
  end;

  TStrip = record
    XMin,XMax : Integer;
    BlobI     : Integer;
  end;
  TStripArray = array[1..MaxStripsPerRow,0..MaxImageH-1] of TStrip;

  TStripCountArray = array[0..MaxImageH-1] of Integer;

  TXAtYArray = array[0..MaxImageH-1] of Integer;
  TYAtXArray = array[0..MaxImageW-1] of Integer;

  TBlob = record
    XMin,XMax : Integer;
    YMin,YMax : Integer;
    Xc,Yc     : Integer;
    Area      : Integer;
    MinXAtY   : TXAtYArray;
    MaxXAtY   : TXAtYArray;
    MinYAtX   : TYAtXArray;
    MaxYAtX   : TYAtXArray;
  end;
  TBlobArray = array[1..MaxBlobs] of TBlob;

  TBlobFinder = class(TObject)
  private
    Strip      : TStripArray;
    StripCount : TStripCountArray;

    function  StripsOverLap(Strip1,Strip2:TStrip):Boolean;

    function XYInsideBlob(X,Y:Integer;I:Integer):Boolean;
    function HLineInsideBlob(X1,X2,Y,I:Integer):Boolean;
    function VLineInsideBlob(Y1,Y2,X,I:Integer):Boolean;

    function  BlobsOverlap(I1,I2:Integer):Boolean;
    procedure FindBlobCenters;

    procedure MergeBlob(I1,I2:Integer);
    procedure MergeBlobs;

    function  GetInfo:TBlobFinderInfo;
    procedure SetInfo(NewInfo:TBlobFinderInfo);

  public
    Blob      : TBlobArray;
    BlobCount : Integer;

    LoT,HiT,JumpD,MergeD : Integer;
    MinArea,Averages     : Integer;

    SubtractedBmp : TBitmap;

    MaxLostTime : DWord;

    property Info:TBlobFinderInfo read GetInfo write SetInfo;

    constructor Create;
    destructor Destroy; override;


    procedure UpdateWithBmp(Bmp:TBitmap);

    procedure FindStrips(Bmp:TBitmap);
    procedure FindBlobs;

    procedure DrawStrips(Bmp:TBitmap);

    procedure DrawBlobs(Bmp:TBitmap;HiLit:Integer);


    procedure OutlinePixel(Bmp:TBitmap;X,Y:Integer);
    procedure OutlineBlob(Bmp:TBitmap;B:Integer);
    procedure OutlineBlobs(Bmp:TBitmap);

    procedure InitForTracking;
    procedure ShowThresholds(SrcBmp, DestBmp: TBitmap);

    function  SceneStatic:Boolean;
    function  BlobRect(B:Integer):TRect;
    procedure CopyBlobAreas(SrcBmp,DestBmp:TBitmap);
    procedure SetToDefault;
    procedure ReadFromStream(Stream: TFileStream);
    procedure WriteToStream(Stream: TFileStream);
  end;

var
  BlobFinder : TBlobFinder;

function DefaultBlobFinderInfo:TBlobFinderInfo;

implementation

uses
  BmpUtils, TrackerU;

function DefaultBlobFinderInfo:TBlobFinderInfo;
begin
  with Result do begin
    LoT:=20;
    HiT:=40;
    JumpD:=12;
    MinArea:=150;
    KalmanTime:=0.50;
    KalmanSensitivity:=20;
    MaxLostTime:=1000;  // milliseconds
    MergeD:=10;
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

procedure TBlobFinder.SetToDefault;
begin
  LoT:=20;
  HiT:=40;
  JumpD:=12;
  MinArea:=150;
  MaxLostTime:=1000;  // milliseconds
  MergeD:=10;
end;

procedure TBlobFinder.ReadFromStream(Stream:TFileStream);
begin
  Stream.Read(LoT,SizeOf(LoT));
  Stream.Read(HiT,SizeOf(HiT));
  Stream.Read(JumpD,SizeOf(JumpD));
  Stream.Read(MinArea,SizeOf(MinArea));
  Stream.Read(MaxLostTime,SizeOf(MaxLostTime));
  Stream.Read(MergeD,SizeOf(MergeD));
end;

procedure TBlobFinder.WriteToStream(Stream:TFileStream);
begin
  Stream.Write(LoT,SizeOf(LoT));
  Stream.Write(HiT,SizeOf(HiT));
  Stream.Write(JumpD,SizeOf(JumpD));
  Stream.Write(MinArea,SizeOf(MinArea));
  Stream.Write(MaxLostTime,SizeOf(MaxLostTime));
  Stream.Write(MergeD,SizeOf(MergeD));
end;

constructor TBlobFinder.Create;
begin
  inherited Create;
  SubtractedBmp:=CreateImageBmp;
  ClearBmp(SubtractedBmp,clBlack);
end;

destructor TBlobFinder.Destroy;
begin
  if Assigned(SubtractedBmp) then SubtractedBmp.Free;
  inherited;
end;

function TBlobFinder.GetInfo:TBlobFinderInfo;
begin
  Result.LoT:=LoT;
  Result.HiT:=HiT;
  Result.JumpD:=JumpD;
  Result.MinArea:=MinArea;
  Result.KalmanTime:=0;//KalmanTime;
  Result.KalmanSensitivity:=0;//KalmanSensitivity;
  Result.MaxLostTime:=MaxLostTime;
  Result.MergeD:=MergeD;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TBlobFinder.SetInfo(NewInfo:TBlobFinderInfo);
begin
  LoT:=NewInfo.LoT;
  HiT:=NewInfo.HiT;
  JumpD:=NewInfo.JumpD;
  MinArea:=NewInfo.MinArea;
//  KalmanTime:=NewInfo.KalmanTime.
//  KalmanSensitivity:=NewInfo.KalmanSensitivity;
  MaxLostTime:=NewInfo.MaxLostTime;
  MergeD:=NewInfo.MergeD;
end;

procedure TBlobFinder.FindStrips(Bmp:TBitmap);
type
  TScanMode = (smLooking,smTracing,smJumping);
var
  X,Y,I,V   : Integer;
  JumpCount : Integer;
  Line      : PByteArray;
  ScanMode  : TScanMode;
begin
// clear the strip count array
  FillChar(StripCount,SizeOf(StripCount),0);

// loop through the scanlines looking for strips
  for Y:=0 to Bmp.Height-1 do begin
    ScanMode:=smLooking;
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*3;
      V:=Line^[I+0];
      Case ScanMode of

// if we're looking and the intensity>=HiT, make a new strip
        smLooking :
          if V>=HiT then begin
            Inc(StripCount[Y]);
            Strip[StripCount[Y],Y].XMin:=X;
            Strip[StripCount[Y],Y].XMax:=X;
            ScanMode:=smTracing;
          end;

// tracing
        smTracing :
          if V<LoT then begin
            ScanMode:=smJumping;
            JumpCount:=1;
          end
          else Strip[StripCount[Y],Y].XMax:=X;

// jumping across dim pixels
        smJumping :
          if V>=LoT then begin
            ScanMode:=smTracing;
            Strip[StripCount[Y],Y].XMax:=X;
          end
          else begin
            if JumpCount<JumpD then Inc(JumpCount)
            else begin
              ScanMode:=smLooking;
            end;
          end;
      end;
    end;
  end;
end;

function TBlobFinder.StripsOverLap(Strip1,Strip2:TStrip):Boolean;
begin
  with Strip1 do begin
    Result:=not ((XMin>Strip2.XMax) or (XMax<Strip2.XMin));
  end;
end;

procedure TBlobFinder.FindBlobCenters;
var
  I : Integer;
begin
  for I:=1 to BlobCount do with Blob[I] do begin
    Xc:=(XMin+XMax) div 2;
    Yc:=(YMin+YMax) div 2;
  end;
end;

procedure TBlobFinder.FindBlobs;
var
  I,Y,Y2    : Integer;
  I2,X,MaxY : Integer;
begin
// reset the count and BlobI vars
  BlobCount:=0;
  for Y:=0 to ImageH-1 do begin
    for I:=1 to StripCount[Y] do Strip[I,Y].BlobI:=0;
  end;

// look through the strip array in Y
  for Y:=0 to ImageH-1 do for I:=1 to StripCount[Y] do begin
    with Strip[I,Y] do if BlobI=0 then begin
      Inc(BlobCount);
      BlobI:=BlobCount;

// bounding box and area
      Blob[BlobI].XMin:=XMin;
      Blob[BlobI].XMax:=XMax;
      Blob[BlobI].YMin:=Y;
      Blob[BlobI].YMax:=Y;
      Blob[BlobI].Area:=XMax-XMin+1;

// clear the limits
      for I2:=0 to ImageW-1 do begin
        Blob[BlobI].MinYAtX[I2]:=ImageH-1;
        Blob[BlobI].MaxYAtX[I2]:=0;
      end;
      for I2:=0 to ImageH-1 do begin
        Blob[BlobI].MinXAtY[I2]:=ImageW-1;
        Blob[BlobI].MaxXAtY[I2]:=0;
      end;

// init the limits
      Blob[BlobI].MinXAtY[Y]:=XMin;
      Blob[BlobI].MaxXAtY[Y]:=XMax;
      for X:=XMin to XMax do begin
        Blob[BlobI].MinYAtX[X]:=Y;
        Blob[BlobI].MaxYAtX[X]:=Y;
      end;
    end;

// check all the strips below this one for overlaps
    MaxY:=Min(ImageH-1,Y+MergeD);
    for Y2:=Y+1 to MaxY do for I2:=1 to StripCount[Y2] do begin
      if (Strip[I2,Y2].BlobI=0) and (StripsOverLap(Strip[I,Y],Strip[I2,Y2]))
      then begin
        with Strip[I2,Y2] do begin
          BlobI:=Strip[I,Y].BlobI;
          Blob[BlobI].Area:=Blob[BlobI].Area+(XMax-XMin-1);

// update the bounding box
          if XMin<Blob[BlobI].XMin then Blob[BlobI].XMin:=XMin;
          if XMax>Blob[BlobI].XMax then Blob[BlobI].XMax:=XMax;
          if Y2>Blob[BlobI].YMax then Blob[BlobI].YMax:=Y2;

// update the limits
          if XMin<Blob[BlobI].MinXAtY[Y2] then Blob[BlobI].MinXAtY[Y2]:=XMin;
          if XMax>Blob[BlobI].MaxXAtY[Y2] then Blob[BlobI].MaxXAtY[Y2]:=XMax;
          for X:=XMin to XMax do begin
            if Y2<Blob[BlobI].MinYAtX[X] then Blob[BlobI].MinYAtX[X]:=Y2;
            if Y2>Blob[BlobI].MaxYAtX[X] then Blob[BlobI].MaxYAtX[X]:=Y2;
          end;
        end;
      end;
    end;
    if BlobCount=MaxBlobs then begin
      FindBlobCenters;
      Exit;
    end;
  end;
  FindBlobCenters;
end;

function TBlobFinder.XYInsideBlob(X,Y:Integer;I:Integer):Boolean;
begin
  with Blob[I] do begin
    Result:=(X>=XMin) and (X<=XMax) and (Y>=YMin) and (Y<=YMax);
  end;
end;

function TBlobFinder.HLineInsideBlob(X1,X2,Y,I:Integer):Boolean;
begin
  with Blob[I] do begin
    Result:=(Y>=YMin) and (Y<=YMax) and
            (((X1>=XMin) and (X1<=XMax)) or
             ((X2>=XMin) and (X2<=XMax)) or
             ((X1<=XMin) and (X2>=XMax)));
  end;
end;

function TBlobFinder.VLineInsideBlob(Y1,Y2,X,I:Integer):Boolean;
begin
  with Blob[I] do begin
    Result:=(X>=XMin) and (X<=XMax) and
            (((Y1>=YMin) and (Y1<=YMax)) or
             ((Y2>=YMin) and (Y2<=YMax)) or
             ((Y1<=YMin) and (Y2>=YMax)));
  end;
end;

function TBlobFinder.BlobsOverlap(I1,I2:Integer):Boolean;
begin
  with Blob[I2] do begin
//    Result:=HLineInsideBlob(XMin,XMax,YMin,I1) or
//            HLineInsideBlob(XMin,XMax,YMax,I1) or
//            VLineInsideBlob(YMin,YMax,XMin,I1) or
//            VLineInsideBlob(YMin,YMax,XMax,I1);
    Result:=HLineInsideBlob(XMin,XMax,YMin-MergeD,I1) or
            HLineInsideBlob(XMin,XMax,YMax+MergeD,I1) or
            VLineInsideBlob(YMin,YMax,XMin-MergeD,I1) or
            VLineInsideBlob(YMin,YMax,XMax+MergeD,I1) or
            XYInsideBlob(Xc,Yc,I1);
  end;
end;

// Blob[I2] is absorbed into Blob[I1]
procedure TBlobFinder.MergeBlob(I1,I2:Integer);
var
  I,X,Y : Integer;
begin
  with Blob[I1] do begin
    if Blob[I2].XMin<XMin then XMin:=Blob[I2].XMin;
    if Blob[I2].XMax>XMax then XMax:=Blob[I2].XMax;
    if Blob[I2].YMin<YMin then YMin:=Blob[I2].YMin;
    if Blob[I2].YMax>YMax then YMax:=Blob[I2].YMax;
    for X:=Blob[I2].XMin to Blob[I2].XMax do begin
      if Blob[I2].MinYAtX[X]<MinYAtX[X] then MinYAtX[X]:=Blob[I2].MinYAtX[X];
      if Blob[I2].MaxYAtX[X]>MaxYAtX[X] then MaxYAtX[X]:=Blob[I2].MaxYAtX[X];
    end;
    for Y:=Blob[I2].YMin to Blob[I2].YMax do begin
      if Blob[I2].MinXAtY[Y]<MinXAtY[Y] then MinXAtY[Y]:=Blob[I2].MinXAtY[Y];
      if Blob[I2].MaxXAtY[Y]>MaxXAtY[Y] then MaxXAtY[Y]:=Blob[I2].MaxXAtY[Y];
    end;
    Area:=Area+Blob[I2].Area;
  end;

// sort the array so it's continuous
  for I:=I2 to BlobCount-1 do begin
    Blob[I]:=Blob[I+1];
  end;
  Dec(BlobCount);
end;

procedure TBlobFinder.MergeBlobs;
var
  I,I2       : Integer;
  BlobMerged : Boolean;
begin
  repeat
    BlobMerged:=False;
    I:=0;
    repeat
      Inc(I);
      I2:=I+1;
      while (I2<=BlobCount) do begin
        if BlobsOverlap(I,I2) or BlobsOverlap(I2,I) then begin
          MergeBlob(I,I2);
          BlobMerged:=True;
        end
        else Inc(I2);
      end;
    until (I>=(BlobCount-1));
  until not BlobMerged;
  for I:=1 to BlobCount do with Blob[I] do begin
    Xc:=(XMin+XMax) div 2;
    Yc:=(YMin+YMax) div 2;
  end;
end;

procedure TBlobFinder.DrawStrips(Bmp:TBitmap);
var
  Y,I : Integer;
begin
  Bmp.Canvas.Pen.Color:=clRed;
  for Y:=0 to ImageH-1 do for I:=1 to StripCount[Y] do with Strip[I,Y] do begin
    Bmp.Canvas.MoveTo(XMin,Y);
    Bmp.Canvas.LineTo(XMax+1,Y);
  end;
end;

procedure TBlobFinder.DrawBlobs(Bmp:TBitmap;HiLit:Integer);
var
  I : Integer;
begin
  Bmp.Canvas.Brush.Style:=bsClear;
  for I:=1 to BlobCount do with Blob[I] do begin
    if I=HiLit then Bmp.Canvas.Pen.Color:=clYellow
    else Bmp.Canvas.Pen.Color:=clBlue;
    Bmp.Canvas.Rectangle(XMin,YMin,XMax,YMax);
  end;
end;

function TBlobFinder.SceneStatic:Boolean;
begin
  Result:=(BlobCount=0);
end;

procedure TBlobFinder.OutlinePixel(Bmp:TBitmap;X,Y:Integer);
const
  Red   = 0;
  Green = 155;
  Blue  = 0;
var
  X2,Y2,I : Integer;
  Line    : PByteArray;
begin
  for Y2:=Y-1 to Y+1 do if (Y2>=0) and (Y2<Bmp.Height) then begin
    Line:=Bmp.ScanLine[Y2];
    for X2:=X-1 to X+1 do if (X2>0) and (X2<(Bmp.Width-1)) then begin
      I:=X2*3;
      Line^[I+0]:=Blue;
      Line^[I+1]:=Green;
      Line^[I+2]:=Red;
    end;
  end;
end;

procedure TBlobFinder.OutlineBlob(Bmp:TBitmap;B:Integer);
var
  X,Y : Integer;
begin
  with Blob[B] do begin
    for X:=XMin to XMax do begin
      Y:=MinYAtX[X];
      OutlinePixel(Bmp,X,Y);
      Y:=MaxYAtX[X];
      OutlinePixel(Bmp,X,Y);
    end;
    for Y:=YMin to YMax do begin
      X:=MinXAtY[Y];
      OutlinePixel(Bmp,X,Y);
      X:=MaxXAtY[Y];
      OutlinePixel(Bmp,X,Y);
    end;
  end;
end;

procedure TBlobFinder.OutlineBlobs(Bmp:TBitmap);
var
  B : Integer;
begin
  for B:=1 to BlobCount do OutlineBlob(Bmp,B);
end;

procedure TBlobFinder.UpdateWithBmp(Bmp:TBitmap);
var
  I,LastI : Integer;
begin
  FindStrips(Bmp);
  FindBlobs;
  if BlobCount>0 then MergeBlobs;

  FillChar(Tracker.Touch,SizeOf(Tracker.Touch),0);
  LastI:=Min(BlobCount,MaxTouches);
  for I:=1 to LastI do begin
    Tracker.Touch[I].Active:=True;
    Tracker.Touch[I].X:=Blob[I].Xc/TrackW;
    Tracker.Touch[I].Y:=Blob[I].Yc/TrackH;
  end;
end;

function TBlobFinder.BlobRect(B:Integer):TRect;
begin
  with Blob[B] do begin
    Result.Left:=XMin;
    Result.Right:=XMax;
    Result.Top:=YMin;
    Result.Bottom:=YMax;
  end;
end;

procedure TBlobFinder.CopyBlobAreas(SrcBmp,DestBmp:TBitmap);
var
  B     : Integer;
  BRect : TRect;
begin
  for B:=1 to BlobCount do if Blob[B].Area>=MinArea then begin
    BRect:=BlobRect(B);
    DestBmp.Canvas.CopyRect(BRect,SrcBmp.Canvas,BRect);
  end;
end;

procedure TBlobFinder.InitForTracking;
begin
//
end;

procedure TBlobFinder.ShowThresholds(SrcBmp,DestBmp:TBitmap);
var
  X,Y,I    : Integer;
  SrcLine  : PByteArray;
  DestLine : PByteArray;
begin
  ClearBmp(DestBmp,clBlack);
  for Y:=0 to TrackH-1 do begin
    SrcLine:=SrcBmp.ScanLine[Y];
    DestLine:=DestBmp.ScanLine[Y];
    for X:=0 to TrackW-1 do begin
      I:=X*3;
      if SrcLine^[I]>=HiT then begin
        DestLine^[I]:=255;
        DestLine^[I+1]:=255;
        DestLine^[I+2]:=255;
      end
      else if SrcLine^[I]>=LoT then begin
        DestLine^[I]:=127;
        DestLine^[I+1]:=127;
        DestLine^[I+2]:=127;
      end;
    end;
  end;
end;

end.
