unit Normal;

////////////////////////////////////////////////////////////////////////////////
// Before performing the DLT (Direct Linear Transformation) algorithm, we need
// to normalize the data.
// The idea is to translate and scale both sets of points so the the average
// of the centroid is at the origin and the average point is Sqrt(2) from
// the origin.
// To do this we find 2 normalizing transformation matrices, Tr and Tp that
// will perform the appropriate scaling. After the planar homography H' is
// calculated, set H = [Tr^-1] [H'] [Tp] to move back to our coordinate space.
//
// ie [x] = [H] [X]
//    [x] [T'] = [H'] [X] [T] = [H] [X] [T']
//    [H] [X] [T'] = [H'] [X] [T]
//    [H] = [T']^-1 [H'] [T]
//
////////////////////////////////////////////////////////////////////////////////

interface

uses
  MatrixU, Global;

type
  TAvgPointRecord = record
    Px,Py,Pd : Single;
    Rx,Ry,Rd : Single;
  end;

function  AveragePointVars(var Pt:TPlanePointArray;Cols,Rows:Integer):TAvgPointRecord;
function  NormalizedPoints(Pt:TPlanePointArray;Tp,Tr:TMatrix;Cols,Rows:Integer):TPlanePointArray;
procedure DenormalizeHMatrix(H,Tp,Tr:TMatrix);

implementation

function AveragePointVars(var Pt:TPlanePointArray;Cols,Rows:Integer):TAvgPointRecord;
var
  R,C    : Integer;
  D      : Single;
  Points : Integer;
begin
  FillChar(Result,SizeOf(Result),0);
  Points:=Cols*Rows;
  for C:=1 to Cols do for R:=1 to Rows do with Pt[C,R] do
  begin

// pixel points
    Result.Px:=Result.Px+PixelX;
    Result.Py:=Result.Py+PixelY;
    D:=Sqrt(Sqr(PixelX)+Sqr(PixelY));
    Result.Pd:=Result.Pd+D;

// relative points
    Result.Rx:=Result.Rx+RelativeX;
    Result.Ry:=Result.Ry+RelativeY;
    D:=Sqrt(Sqr(RelativeX)+Sqr(RelativeY));
    Result.Rd:=Result.Rd+D;
  end;
  with Result do begin
    Px:=Px/Points;
    Py:=Py/Points;
    Pd:=Pd/Points;
    Rx:=Rx/Points;
    Ry:=Ry/Points;
    Rd:=Rd/Points;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Normalizes the points and returns the normalizing matrices.
////////////////////////////////////////////////////////////////////////////////
function NormalizedPoints(Pt:TPlanePointArray;Tp,Tr:TMatrix;Cols,Rows:Integer):TPlanePointArray;
var
  AvgPt  : TAvgPointRecord;
  PScale : Single;
  RScale : Single;
  D      : Single;
  C,R    : Integer;
  MR,ML  : TMatrix;
  Points : Integer;
begin
  Points:=Cols*Rows;
  AvgPt:=AveragePointVars(Pt,Cols,Rows);

// find the average distance to the translated origin
  AvgPt.Pd:=0;
  AvgPt.Rd:=0;
  for C:=1 to Cols do for R:=1 to Rows do with Pt[C,R] do
  begin

// Pixel X,Y
    D:=Sqrt(Sqr(PixelX-AvgPt.Px)+Sqr(PixelY-AvgPt.Py));
    AvgPt.Pd:=AvgPt.Pd+D;

// Relative X,Y
    D:=Sqrt(Sqr(RelativeX-AvgPt.Rx)+Sqr(RelativeY-AvgPt.Ry));
    AvgPt.Rd:=AvgPt.Rd+D;
  end;
  with AvgPt do begin
    Pd:=Pd/Points;
    Rd:=Rd/Points;
    if Pd=0 then PScale:=1
    else PScale:=Sqrt(2)/Pd;
    if Rd=0 then RScale:=1
    else RScale:=Sqrt(2)/Rd;

// build the matrices
    Tp.InitAsSimiliarity(0,PScale,-Px*PScale,-Py*PScale);
    Tr.InitAsSimiliarity(0,RScale,-Rx*RScale,-Ry*RScale);
  end;

// translate and scale the points by the required amount
  MR:=TMatrix.Create(3,1);
  ML:=TMatrix.Create(3,1);
  for C:=1 to Cols do for R:=1 to Rows do with Pt[C,R] do
  begin

// pixels
    MR.Cell[1,1]:=PixelX;
    MR.Cell[2,1]:=PixelY;
    MR.Cell[3,1]:=1;
    ML.InitFromProduct(Tp,MR);
    if ML.Cell[3,1]<>0 then begin
      Result[C,R].PixelX:=ML.Cell[1,1]/ML.Cell[3,1];
      Result[C,R].PixelY:=ML.Cell[2,1]/ML.Cell[3,1];
    end;

// relative points
    MR.Cell[1,1]:=RelativeX;
    MR.Cell[2,1]:=RelativeY;
    MR.Cell[3,1]:=1;
    ML.InitFromProduct(Tr,MR);
    if ML.Cell[3,1]<>0 then begin
      Result[C,R].RelativeX:=ML.Cell[1,1]/ML.Cell[3,1];
      Result[C,R].RelativeY:=ML.Cell[2,1]/ML.Cell[3,1];
    end;
  end;
end;

procedure DenormalizeHMatrix(H,Tp,Tr:TMatrix);
var
  M : TMatrix;
begin
  M:=TMatrix.Create(3,3);
  try
    M.Equals(H);
    Tp.Invert;
    H.InitFromProduct(Tp,M);
    H.Multiply(Tr);
  finally
    M.Free;
  end;
end;

end.
