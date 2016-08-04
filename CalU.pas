unit CalU;

interface

uses
  MatrixU, Graphics, Global, Classes, SysUtils;

const
  MaxCalPts =5;

type
  TCalibratorInfo = record
    CalPt    : TCalPtArray;
    HData    : TMatrixData3x3;
    HInvData : TMatrixData3x3;
    Reserved : array[1..256] of Byte;
  end;

  TCalibrator = class(TObject)
  private
    CamMatrix  : TMatrix;
    ProjMatrix : TMatrix;

    function  GetInfo:TCalibratorInfo;
    procedure SetInfo(NewInfo:TCalibratorInfo);

    function  NormalizedCalPts(CamMatrix,ProjMatrix:TMatrix):TCalPtArray;
    procedure DenormalizeHMatrix(H,CamMatrix,ProjMatrix:TMatrix);

  public
    HMatrix    : TMatrix;
    HInvMatrix : TMatrix;
    CalPt      : TCalPtArray;

    property Info:TCalibratorInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure CalculateMatrices(Lines:TStrings;Normalize:Boolean);
    procedure TestMatrices(Lines:TStrings);
    function  ProjectorXYFromCamXY(CamX,CamY:Single):TPixel;
    procedure FindFixedCamPoints;

    procedure FakeCalibration(Lines:TStrings;W,H:Integer);

    procedure DrawCalPts(Bmp:TBitmap);
    procedure DrawFixedCalPts(Bmp:TBitmap);

    procedure CopyCalPtsFromMetricCal(var MetricCal:TMetricCalRecord);
  end;

var
  Calibrator : TCalibrator;

function DefaultCalibratorInfo:TCalibratorInfo;

implementation

uses
  CameraU, Dialogs;

function DefaultCalibratorInfo:TCalibratorInfo;
begin
  with Result do begin
    FillChar(CalPt,SizeOf(CalPt),0);

// camera pixels
    CalPt[1].CamX:=010; CalPt[1].CamY:=010;
    CalPt[2].CamX:=310; CalPt[2].CamY:=010;
    CalPt[3].CamX:=160; CalPt[3].CamY:=120;
    CalPt[4].CamX:=010; CalPt[4].CamY:=230;
    CalPt[5].CamX:=310; CalPt[5].CamY:=230;

// projector pixels
    CalPt[1].ProjX:=0010; CalPt[1].ProjY:=0010;
    CalPt[2].ProjX:=1014; CalPt[2].ProjY:=0010;
    CalPt[3].ProjX:=0512; CalPt[3].ProjY:=0384;
    CalPt[4].ProjX:=0010; CalPt[4].ProjY:=0758;
    CalPt[5].ProjX:=1014; CalPt[5].ProjY:=0758;

// matrix data
    FillChar(HData,SizeOf(HData),0);
    FillChar(HInvData,SizeOf(HInvData),0);

// reserved
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

constructor TCalibrator.Create;
begin
  HMatrix:=TMatrix.Create(3,3);
  HInvMatrix:=TMatrix.Create(3,3);
  CamMatrix:=TMatrix.Create(3,1);
  ProjMatrix:=TMatrix.Create(3,1);
end;

destructor TCalibrator.Destroy;
begin
  if Assigned(HMatrix) then HMatrix.Free;
  if Assigned(HInvMatrix) then HInvMatrix.Free;
end;

function TCalibrator.GetInfo:TCalibratorInfo;
var
  R,C : Integer;
begin
  Result.CalPt:=CalPt;
  for R:=1 to 3 do for C:=1 to 3 do begin
    Result.HData[R,C]:=HMatrix.Cell[R,C];
    Result.HData[R,C]:=HMatrix.Cell[R,C];
    Result.HInvData[R,C]:=HInvMatrix.Cell[R,C];
    Result.HInvData[R,C]:=HInvMatrix.Cell[R,C];
  end;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TCalibrator.SetInfo(NewInfo:TCalibratorInfo);
var
  R,C : Integer;
begin
  CalPt:=NewInfo.CalPt;
  for R:=1 to 3 do for C:=1 to 3 do begin
    HMatrix.Cell[R,C]:=NewInfo.HData[R,C];
    HMatrix.Cell[R,C]:=NewInfo.HData[R,C];
    HInvMatrix.Cell[R,C]:=NewInfo.HInvData[R,C];
    HInvMatrix.Cell[R,C]:=NewInfo.HInvData[R,C];
  end;
end;

procedure TCalibrator.FindFixedCamPoints;
var
  I : Integer;
begin
  for I:=1 to MaxCalPts do with CalPt[I] do begin
    if not Camera.AbleToUndistortPixel(CamX,CamY,FixedCamX,FixedCamY) then begin
      ShowMessage('Error undistorting pixel');
    end;
  end;
end;

// Solves [A][H]=0
procedure TCalibrator.CalculateMatrices(Lines:TStrings;Normalize:Boolean);
var
  A          : TMatrix;
  CamMatrix  : TMatrix;
  ProjMatrix : TMatrix;
  I,R        : Integer;
  NormPt     : TCalPtArray;
begin
// create some matrices
  A:=TMatrix.Create(MaxCalPts*2,9);
  if Normalize then begin
    CamMatrix:=TMatrix.Create(3,3);
    ProjMatrix:=TMatrix.Create(3,3);
  end;

  try

// normalize the points
    if Normalize then NormPt:=NormalizedCalPts(CamMatrix,ProjMatrix)
    else NormPt:=CalPt;

// build the A matrix
    R:=0;
    for I:=1 to MaxCalPts do with NormPt[I] do begin
      Inc(R);
      A.Cell[R,1]:=FixedCamX;
      A.Cell[R,2]:=FixedCamY;
      A.Cell[R,3]:=1;
      A.Cell[R,4]:=0;
      A.Cell[R,5]:=0;
      A.Cell[R,6]:=0;
      A.Cell[R,7]:=-ProjX*FixedCamX;
      A.Cell[R,8]:=-ProjX*FixedCamY;
      A.Cell[R,9]:=-ProjX;
      Inc(R);
      A.Cell[R,1]:=0;
      A.Cell[R,2]:=0;
      A.Cell[R,3]:=0;
      A.Cell[R,4]:=FixedCamX;
      A.Cell[R,5]:=FixedCamY;
      A.Cell[R,6]:=1;
      A.Cell[R,7]:=-ProjY*FixedCamX;
      A.Cell[R,8]:=-ProjY*FixedCamY;
      A.Cell[R,9]:=-ProjY;
    end;
    if Assigned(Lines) then A.DisplayInLinesWithPunctuation(Lines,' A Matrix:');

// solve it
    A.SolveWithSVD;
    with HMatrix do begin
      Cell[1,1]:=A.Cell[1,1]; Cell[1,2]:=A.Cell[2,1]; Cell[1,3]:=A.Cell[3,1];
      Cell[2,1]:=A.Cell[4,1]; Cell[2,2]:=A.Cell[5,1]; Cell[2,3]:=A.Cell[6,1];
      Cell[3,1]:=A.Cell[7,1]; Cell[3,2]:=A.Cell[8,1]; Cell[3,3]:=A.Cell[9,1];
    end;

// undo the normalization
    if Normalize then begin
      DenormalizeHMatrix(HMatrix,CamMatrix,ProjMatrix);
      CamMatrix.Free;
      ProjMatrix.Free;
    end;

// find the inverse H matrix too
    HInvMatrix.Equals(HMatrix);
    HInvMatrix.PseudoInvert;

  finally
    A.Free;
  end;
end;

function TCalibrator.ProjectorXYFromCamXY(CamX,CamY:Single):TPixel;
var
  Den : Single;
begin
  CamMatrix.Cell[1,1]:=CamX;
  CamMatrix.Cell[2,1]:=CamY;
  CamMatrix.Cell[3,1]:=1;
  ProjMatrix.InitFromProduct(HMatrix,CamMatrix);
  Den:=ProjMatrix.Cell[3,1];
  if Abs(Den)>0.00001 then begin
    Result.X:=Round(ProjMatrix.Cell[1,1]/Den);
    Result.Y:=Round(ProjMatrix.Cell[2,1]/Den);
  end
  else FillChar(Result,SizeOf(Result),0);
end;

procedure TCalibrator.TestMatrices(Lines:TStrings);
var
  ProjPt : TPixel;
  I      : Integer;
begin
  for I:=1 to MaxCalPts do with CalPt[I] do begin
    ProjPt:=ProjectorXYFromCamXY(CamX,CamY);
    Lines.Add('');
    Lines.Add('Point #'+IntToStr(I));

    Lines.Add('  CamX:'+IntToStr(Round(CamX))+' CamY:'+IntToStr(Round(CamY)));
    Lines.Add('  FixedCamX:'+IntToStr(Round(FixedCamX))+' FixedCamY:'+IntToStr(Round(FixedCamY)));

    Lines.Add('  X:'+IntToStr(Round(ProjX))+' Calc:'+IntToStr(ProjPt.X));
    Lines.Add('  Y:'+IntToStr(Round(ProjY))+' Calc:'+IntToStr(ProjPt.Y));
  end;
end;

procedure TCalibrator.FakeCalibration(Lines:TStrings;W,H:Integer);
var
  HW,HH,MX,MY,I : Integer;
  XScale,YScale : Single;
begin
  HW:=Camera.Bmp.Width div 2;
  HH:=Camera.Bmp.Height div 2;
  MX:=Camera.Bmp.Width-1;
  MY:=Camera.Bmp.Height-1;

  CalPt[1].CamX:=HW; CalPt[1].CamY:=0;
  CalPt[2].CamX:=MX; CalPt[2].CamY:=HH;
  CalPt[3].CamX:=HW; CalPt[3].CamY:=MY;
  CalPt[4].CamX:=0;  CalPt[4].CamY:=HH;
  CalPt[5].CamX:=HW; CalPt[5].CamY:=HH;

  XScale:=W/Camera.Bmp.Width;
  YScale:=H/Camera.Bmp.Height;

  for I:=1 to MaxCalPts do with CalPt[I] do begin
    ProjX:=CamX*XScale;
    ProjY:=CamY*YScale;
  end;
  CalculateMatrices(Lines,False);
end;

procedure TCalibrator.DrawCalPts(Bmp:TBitmap);
const
  Size = 4;
var
  I,X,Y : Integer;
begin
  with Bmp.Canvas do begin
    Font.Color:=clYellow;
    Brush.Style:=bsClear;
    Pen.Color:=clYellow;
    for I:=1 to MaxCalPts do with CalPt[I] do begin
      X:=Round(CamX);
      Y:=Round(CamY);
      MoveTo(X-Size,Round(Y));
      LineTo(X+Size+1,Y);
      MoveTo(X,Y-Size);
      LineTo(X,Y+Size+1);
      X:=X+Size+3;
      Y:=Y-7;
      TextOut(X,Y,'#'+IntToStr(I));
    end;
  end;
end;

procedure TCalibrator.DrawFixedCalPts(Bmp:TBitmap);
const
  Size = 4;
var
  I,X,Y : Integer;
begin
  with Bmp.Canvas do begin
    Font.Color:=clYellow;
    Brush.Style:=bsClear;
    Pen.Color:=clYellow;
    for I:=1 to MaxCalPts do with CalPt[I] do begin
      X:=Round(FixedCamX);
      Y:=Round(FixedCamY);
      MoveTo(X-Size,Round(Y));
      LineTo(X+Size+1,Y);
      MoveTo(X,Y-Size);
      LineTo(X,Y+Size+1);
      X:=X+Size+3;
      Y:=Y-7;
      TextOut(X,Y,'#'+IntToStr(I));
    end;
  end;
end;

procedure TCalibrator.CopyCalPtsFromMetricCal(var MetricCal:TMetricCalRecord);
var
  I : Integer;
begin
  for I:=1 to MaxCalPts do with CalPt[I] do begin
    CamX:=MetricCal.MetrePt[I].X;
    CamY:=MetricCal.MetrePt[I].Z;
    FixedCamX:=CamX;
    FixedCamY:=CamY;
    ProjX:=MetricCal.ProjPixel[I].X;
    ProjY:=MetricCal.ProjPixel[I].Y;
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Normalizes the points and returns the normalizing matrices.
////////////////////////////////////////////////////////////////////////////////
function TCalibrator.NormalizedCalPts(CamMatrix,ProjMatrix:TMatrix):TCalPtArray;
var
  Avg       : TCalPt;
  AvgCamD   : Single;
  AvgProjD  : Single;
  CamScale  : Single;
  ProjScale : Single;
  D         : Single;
  I         : Integer;
  MR,ML     : TMatrix;
begin
// find the averages
  FillChar(Avg,SizeOf(Avg),0);
  for I:=1 to MaxCalPts do with CalPt[I] do begin
    Avg.FixedCamX:=Avg.FixedCamX+FixedCamX;
    Avg.FixedCamY:=Avg.FixedCamY+FixedCamY;
    Avg.ProjX:=Avg.ProjX+ProjX;
    Avg.ProjY:=Avg.ProjY+ProjY;
  end;
  Avg.FixedCamX:=Avg.FixedCamX/MaxCalPts;
  Avg.FixedCamY:=Avg.FixedCamY/MaxCalPts;
  Avg.ProjX:=Avg.ProjX/MaxCalPts;
  Avg.ProjY:=Avg.ProjY/MaxCalPts;

// find the average distance to the average (the translated origin)
  AvgCamD:=0;
  AvgProjD:=0;
  for I:=1 to 5 do with CalPt[I] do begin

// Camera X,Y
    D:=Sqrt(Sqr(FixedCamX-Avg.FixedCamX)+Sqr(FixedCamY-Avg.FixedCamY));
    AvgCamD:=AvgCamD+D;

// Proj X,Y
    D:=Sqrt(Sqr(ProjX-Avg.ProjX)+Sqr(ProjY-Avg.ProjY));
    AvgProjD:=AvgProjD+D;
  end;
  AvgCamD:=AvgCamD/MaxCalPts;
  AvgProjD:=AvgProjD/MaxCalPts;

// find the scales
  if AvgCamD=0 then CamScale:=1
  else CamScale:=Sqrt(2)/AvgCamD;

  if AvgProjD=0 then ProjScale:=1
  else ProjScale:=Sqrt(2)/AvgProjD;

// build the matrices
  CamMatrix.InitAsSimiliarity(0,CamScale,-Avg.FixedCamX*CamScale,-Avg.FixedCamY*CamScale);
  ProjMatrix.InitAsSimiliarity(0,ProjScale,-Avg.ProjX*ProjScale,-Avg.ProjY*ProjScale);

// translate and scale the points by the required amount
  MR:=TMatrix.Create(3,1);
  ML:=TMatrix.Create(3,1);
  FillChar(Result,SizeOf(Result),0);
  for I:=1 to MaxCalPts do with CalPt[I] do begin

// camera
    MR.Cell[1,1]:=FixedCamX;
    MR.Cell[2,1]:=FixedCamY;
    MR.Cell[3,1]:=1;
    ML.InitFromProduct(CamMatrix,MR);
    if ML.Cell[3,1]<>0 then begin
      Result[I].FixedCamX:=ML.Cell[1,1]/ML.Cell[3,1];
      Result[I].FixedCamY:=ML.Cell[2,1]/ML.Cell[3,1];
    end;

// projector
    MR.Cell[1,1]:=ProjX;
    MR.Cell[2,1]:=ProjY;
    MR.Cell[3,1]:=1;
    ML.InitFromProduct(ProjMatrix,MR);
    if ML.Cell[3,1]<>0 then begin
      Result[I].ProjX:=ML.Cell[1,1]/ML.Cell[3,1];
      Result[I].ProjY:=ML.Cell[2,1]/ML.Cell[3,1];
    end;
  end;
end;

procedure TCalibrator.DenormalizeHMatrix(H,CamMatrix,ProjMatrix:TMatrix);
var
  M : TMatrix;
begin
  M:=TMatrix.Create(3,3);
  try
    M.Equals(H);
    ProjMatrix.Invert;
    H.InitFromProduct(ProjMatrix,M);
    H.Multiply(CamMatrix);
  finally
    M.Free;
  end;
end;

end.


