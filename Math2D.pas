unit Math2D;

interface

uses
  Global, MatrixU, Math;

const
  MaxPixelPts = 10;

type
  TPixelPt = record
    X,Y : Integer;
  end;
  TPixelPtArray = array[1..MaxPixelPts] of TPixelPt;

function XYInPoly(X,Y:Integer;var Poly:TPixelPtArray):Boolean;
function OffsetLine(L:TVector;R:Single):TVector;
function PerpendicularDistanceToLine(L:TVector;X,Y:Single):Single;
function LineIntersection(Line1,Line2:MatrixU.TVector):TPoint2D;
function PointInsideEllipse(Pt:TPoint2D;X1,Y1,X2,Y2:Single):Boolean;

function VectorLineFromTwoPoints(Pt1,Pt2:TPoint2D):TVector;

implementation

function PointInsideEllipse(Pt:TPoint2D;X1,Y1,X2,Y2:Single):Boolean;
var
  X,Y,A,B : Single;
begin
  X:=(X1+X2)/2;
  Y:=(Y1+Y2)/2;
  A:=(X2-X1)/2;
  B:=(Y2-Y1)/2;
  Result:=Sqr((Pt.X-X)/A)+Sqr((Pt.Y-Y)/B)<=1;
end;

function XYInPoly(X,Y:Integer;var Poly:TPixelPtArray):Boolean;
var
  I,J : Integer;
  Den : Single;
begin
  Result:=False;
  I:=1; J:=4;
  repeat
    Den:=Poly[J].Y-Poly[I].Y;

// Y must be between these 2 adjacent point Y's to cross a line
    if (Abs(Den)>1E-6) and ((((Y>=Poly[I].Y) and (Y<=Poly[J].Y)) or
         ((Y>=Poly[J].Y) and (Y<=Poly[I].Y)))) and

// see which side of the line X is on
        (X<(Poly[J].X-Poly[I].X)*(Y-Poly[I].Y)/Den+Poly[I].X)
    then begin
      Result:=not Result;
    end;
    Inc(I);
    J:=I-1;
  until (I>4);
end;

function VectorLineFromTwoPoints(Pt1,Pt2:TPoint2D):TVector;
var
  Dx,M,B : Single;
begin
// vertical lines - Line[2] = 0, X intercept = -C/A = Pt1.X = Pt2.X
  Dx:=Pt2.X-Pt1.X;
  if Abs(Dx)<1E-6 then begin
    Result[1]:=1;
    Result[2]:=0;
    Result[3]:=-Pt1.X;
  end
  else begin   // M = -A/B
    M:=(Pt2.Y-Pt1.Y)/Dx;
    B:=Pt1.Y-(M*Pt1.X);
    Result[1]:=-M;
    Result[2]:=1;
    Result[3]:=-B;
  end;
end;

function Normalized2DVector(V:TPoint2D):TPoint2D;
var
  M : Single;
begin
  M:=Sqrt(Sqr(V.X)+Sqr(V.Y));
  if Abs(M)<1E-6 then begin
    Result.X:=1;
    Result.Y:=0;
  end
  else begin
    Result.X:=V.X/M;
    Result.Y:=V.Y/M;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
// Returns a line parallel to L offset by R pixels
////////////////////////////////////////////////////////////////////////////////
// Vector line: Ax + By + C = 0
// MB line : y = Mx + B (M = slope, B = y intercept
// By = -Ax - C
// y = (-A/B)x + (-C/B)
// M = -A/B, B = -C/B
////////////////////////////////////////////////////////////////////////////////
function OffsetLine(L:TVector;R:Single):TVector;
var
  V       : TPoint2D;
  Pt1,Pt2 : TPoint2D;
  Pt3,Pt4 : TPoint2D;
begin
// find a vector perpendicular to this line

// line is vertical - perpendicular line will be horizontal
  if Abs(L[2])<1E-6 then begin
    V.X:=1;
    V.Y:=0;
  end

// line is horizontal - perpendicular line will be vertical
  else if Abs(L[1])<1E-6 then begin
    V.X:=0;
    V.Y:=1;
  end

// line is skew - vector of the perpendicular line will be -1/M (-B/A)
  else begin
    V.X:=L[1]/L[2];
    V.Y:=1;
    V:=Normalized2DVector(V);
  end;

// pick two points on the line
// Y intercept : X = 0 => A(0) + B(y) + C = 0 => Y = -C/B
//  - if B = 0, there is no Y intercept (line is vertical)
// X intercept : Y = 0 => A(x) + B(0) + C = 0 => X = -C/A
//  - if A = 0, there is no X intercept (line is horizontal)

// horizontal line
  if Abs(L[1])<1E-6 then begin
    Pt1.X:=-0.5;
    Pt1.Y:=-L[3]/L[2];
    Pt2.X:=+0.5;
    Pt2.Y:=Pt1.Y;
  end

// vertical line
  else if Abs(L[2])<1E-6 then begin
    Pt1.X:=-L[3]/L[1];
    Pt1.Y:=-0.5;
    Pt2.X:=Pt1.X;
    Pt2.Y:=+0.5;
  end

// skew line going through the origin (Ax + By = 0) y = (-A/B) x
  else if Abs(L[3])<1E-6 then begin
    Pt1.X:=1;
    Pt1.Y:=-L[1]/L[2];
    Pt2.X:=-1;
    Pt2.Y:=L[1]/L[2];
  end

// skew line with at least non-zero X,Y intercept
  else begin
    Pt1.X:=0;
    Pt1.Y:=-L[3]/L[2];
    Pt2.X:=-L[3]/L[1];
    Pt2.Y:=0;
  end;

// find new points in the orthagonal directions
  Pt3.X:=Pt1.X+R*(V.X);
  Pt3.Y:=Pt1.Y+R*(V.Y);
  Pt4.X:=Pt2.X+R*(V.X);
  Pt4.Y:=Pt2.Y+R*(V.Y);

// convert back to vector line format
  Result:=VectorLineFromTwoPoints(Pt3,Pt4);
end;

function PerpendicularDistanceToLine(L:TVector;X,Y:Single):Single;
begin
  Result:=Abs(L[1]*X+L[2]*Y+L[3])/Sqrt(Sqr(L[1])+Sqr(L[2]));
end;

function CrossProduct(V1,V2:TPoint3D):TPoint3D;
begin
  Result.X:=(V1.Z*V2.Y)-(V1.Y*V2.Z);
  Result.Y:=(V1.X*V2.Z)-(V1.Z*V2.X);
  Result.Z:=(V1.Y*V2.X)-(V1.X*V2.Y);
end;

function VectorCrossProduct(V1,V2:MatrixU.TVector):TPoint3D;
var
  Va,Vb : TPoint3D;
begin
  Va.X:=V1[1]; Va.Y:=V1[2]; Va.Z:=V1[3];
  Vb.X:=V2[1]; Vb.Y:=V2[2]; Vb.Z:=V2[3];
  Result:=CrossProduct(Va,Vb);
end;

function LineIntersection(Line1,Line2:MatrixU.TVector):TPoint2D;
var
  IPt : TPoint3D;
begin
  IPt:=VectorCrossProduct(Line1,Line2);
  if Abs(IPt.Z)<1E-6 then begin
    Result.X:=0;
    Result.Y:=0;
  end
  else begin
    Result.X:=IPt.X/IPt.Z;
    Result.Y:=IPt.Y/IPt.Z;
  end;
end;

function Project2RadiiToSolveForLa(Ra,Rb,D:Double): Double;
begin
//          /|\          :Lb=D-La  Sqr(Lb)=Sqr(D)-2DLa+Sqr(La)
//    Ra   / | \   Rb    :h=Sqr(Rb)-Sqr(Lb)=Sqr(Ra)-Sqr(La)
//        /  |h \        :Sqr(La)=Sqr(Ra)-Sqr(Rb)+Sqr(Lb)
//       /___|_ _\       :0=Sqr(Ra)-Sqr(Rb)+Sqr(D)-2DLa
//        La   Lb        :2DLa=Sqr(Ra)-Sqr(Rb)+Sqr(D)
//      <--- D --->      :La=Sqr(Ra)+Sqr(D)-Sqr(Rb)/2D
//
  Result:=(Sqr(Ra)+Sqr(D)-Sqr(Rb))/(2*D);
end;

end.
