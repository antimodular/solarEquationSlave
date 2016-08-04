unit Math3D;

interface

uses
  Global;

var
  BadTargets : integer;

procedure FindPanAndTiltToTarget(var Pose:TPose;Target:TPoint3D;var Pan,Tilt:Single);

procedure Rotate2DPoint(var Point:TPoint2D;Rz:Single);

function PointIsOnPlane(Pt:TPoint3D;Plane:TPlane):Boolean;

function DistanceBetween3DPoints(const Pt1,Pt2:TPoint3D):Single;

function LineBetweenPointsIntersectsPlane(P1,P2:TPoint3D;Plane:TPlane;
             var IPoint:TPoint3D):Boolean;

function Vector2D(P1,P2:TPoint2D):TPoint2D;
function Magnitude2D(V:TPoint2D):Single;
function DotProduct2D(V1,V2:TPoint2D):Single;
function AngleBetween2DPoints(P1,P2,P3:TPoint2D):Single;
function AngleBetween3DPoints(P1,P2,P3:TPoint3D):Single;

function Vector(P1,P2:TPoint3D):TPoint3D;
function Magnitude(V:TPoint3D):Single;
function DotProduct(V1,V2:TPoint3D):Single;
function FindNormal(P1,P2,P3:TPoint3D):TPoint3D;
procedure FindPlaneCoefficients(var Plane:TPlane);
procedure RotateXYPoint(var X,Y:Single;Rz:Single);
function  Rotated3DPoint(Point:TPoint3D;Rz:Single): TPoint3D;

function  ExtendTarget(Base,Target:TPoint3D):TPoint3D;
procedure Normalize(var V:TPoint3D);
procedure Negate(var V:TPoint3D);

procedure Rotate3DPoint(var Point:TPoint3D;Rz:Single);
procedure Rotate3DPointRx(var Point:TPoint3D;Rx:Single);
procedure Rotate3DPointRy(var Point:TPoint3D;Ry:Single);

implementation

uses
  Dialogs, QMatrix, Math;

procedure Rotate3DPoint(var Point:TPoint3D;Rz:Single);
var
  Temp : Single;
begin
  Rz:=-Rz;
  with Point do begin
    Temp:=Y*Cos(Rz)-X*Sin(Rz);
    X:=X*Cos(Rz)+Y*Sin(Rz);
    Y:=Temp;
  end;
end;

procedure Rotate3DPointRx(var Point:TPoint3D;Rx:Single);
var
  Temp : Single;
begin
  Rx:=-Rx;
  with Point do begin
    Temp:=Z*Cos(Rx)-Y*Sin(Rx);
    Y:=Y*Cos(Rx)+Z*Sin(Rx);
    Z:=Temp;
  end;
end;

procedure Rotate3DPointRy(var Point:TPoint3D;Ry:Single);
var
  Temp : Single;
begin
  Ry:=-Ry;
  with Point do begin
    Temp:=Z*Cos(Ry)-X*Sin(Ry);
    X:=X*Cos(Ry)+Z*Sin(Ry);
    Z:=Temp;
  end;
end;

procedure Negate(var V:TPoint3D);
begin
  V.X:=-V.X;
  V.Y:=-V.Y;
  V.Z:=-V.Z;
end;

procedure Normalize(var V:TPoint3D);
var
  D : Single;
begin
  D:=Sqrt(Sqr(V.X)+Sqr(V.Y)+Sqr(V.Z));
  if D<>0 then begin
    V.X:=V.X/D;
    V.Y:=V.Y/D;
    V.Z:=V.Z/D;
  end;
end;

function ExtendTarget(Base,Target:TPoint3D):TPoint3D;
var
  V : TPoint3D;
begin
  V.X:=Target.X-Base.X;
  V.Y:=Target.Y-Base.Y;
  V.Z:=Target.Z-Base.Z;
  Result.X:=Base.X+V.X*100;
  Result.Y:=Base.Y+V.Y*100;
  Result.Z:=Base.Z+V.Z*100;
end;


procedure Rotate2DPoint(var Point:TPoint2D;Rz:Single);
var
  Temp : Single;
begin
  Rz:=-Rz;
  with Point do begin
    Temp:=Y*Cos(Rz)-X*Sin(Rz);
    X:=X*Cos(Rz)+Y*Sin(Rz);
    Y:=Temp;
  end;
end;

function PointIsOnPlane(Pt:TPoint3D;Plane:TPlane):Boolean;
var
  A1,A2,A3,A4 : Single;
begin
  with Plane do begin
    A1:=AngleBetween3DPoints(Point[1],Pt,Point[2]);
    A2:=AngleBetween3DPoints(Point[2],Pt,Point[3]);
    A3:=AngleBetween3DPoints(Point[3],Pt,Point[4]);
    A4:=AngleBetween3DPoints(Point[4],Pt,Point[1]);
  end;
  Result:=Abs(A1+A2+A3+A4-(2*Pi))<0.01;
end;

function DistanceBetween3DPoints(const Pt1,Pt2:TPoint3D):Single;
begin
  Result:=Sqrt(Sqr(Pt1.X-Pt2.X)+Sqr(Pt1.Y-Pt2.Y)+Sqr(Pt1.Z-Pt2.Z));
end;

function LineBetweenPointsIntersectsPlane(P1,P2:TPoint3D;Plane:TPlane;
             var IPoint:TPoint3D):Boolean;
var
  E,F,G,T : Single;
  Denom   : Single;
  Length  : Single;
begin
  with Plane do begin

// The line (L) is defined by the 2 points as follows :
// L:  X=P1.X+(P2.X-P1.X)*T,Y=P1.Y+(P2.Y-P1.Y)*T,Z=P1.Z+(P2.Z-P1.Z)*T
// or  X=P1.X+E*T,Y=P1.Y+F*T,Z=P1.Z+G*T

// find the E,F,G multipliers for the "T" parameter
    try
      E:=P2.X-P1.X; F:=P2.Y-P1.Y; G:=P2.Z-P1.Z;

// solve for T...
      Denom:=A*E+B*F+C*G;
      if Denom=0 then begin
        Result:=False;
        Exit;
      end;
      T:=-(D+A*P1.X+B*P1.Y+C*P1.Z)/Denom;

// plug T into the line equation to find the X,Y,Z intersection point
      IPoint.X:=P1.X+E*T;
      IPoint.Y:=P1.Y+F*T;
      IPoint.Z:=P1.Z+G*T;

// make sure the intersection point lies on our finite line
      Length:=DistanceBetween3DPoints(P1,P2);
      Result:=(DistanceBetween3DPoints(P1,IPoint)<=Length) and
              (DistanceBetween3DPoints(P2,IPoint)<=Length);

// also make sure the intersection point is on our FINITE Plane
      if Result and Plane.Finite then Result:=PointIsOnPlane(IPoint,Plane);
    except
      Result:=False;
    end;
  end;
end;

//*****************************************************************************
// Converts P1,P2 into a vector
//      P1o----->P2
//*****************************************************************************
function Vector2D(P1,P2:TPoint2D):TPoint2D;
begin
  Result.X:=P2.X-P1.X;
  Result.Y:=P2.Y-P1.Y;
end;

//*****************************************************************************
// Returns the magnitude of V. ( |V| )
//*****************************************************************************
function Magnitude2D(V:TPoint2D):Single;
begin
  Result:=Sqrt(Sqr(V.X)+Sqr(V.Y));
end;

//*****************************************************************************
// Returns the dot product of two vectors
//*****************************************************************************
function DotProduct2D(V1,V2:TPoint2D):Single;
begin
  Result:=V1.X*V2.X+V1.Y*V2.Y;
end;

//*****************************************************************************
// Returns the angle between P1,P2,P3          P1
//                                            /
//                                           /
//                                         P2 ----P3
//*****************************************************************************
function AngleBetween2DPoints(P1,P2,P3:TPoint2D):Single;
begin
// find the vectors
  P1:=Vector2D(P2,P1);
  P3:=Vector2D(P2,P3);
  Result:=DotProduct2D(P1,P3)/(Magnitude2D(P1)*Magnitude2D(P3));

// clip the ArcCos to the valid range - sometimes it goes beyond +1/-1 due to
// round off error
  if Result>1 then Result:=0
  else if Result<-1 then Result:=Pi
  else Result:=ArcCos(Result);
end;

//*****************************************************************************
// Returns the angle between P1,P2,P3          P1
//                                            /
//                                           /
//                                         P2 ----P3
//*****************************************************************************
function AngleBetween3DPoints(P1,P2,P3:TPoint3D):Single;
begin
// find the vectors
  P1:=Vector(P2,P1);
  P3:=Vector(P2,P3);
  Result:=DotProduct(P1,P3)/(Magnitude(P1)*Magnitude(P3));

// clip the ArcCos to the valid range - sometimes it goes beyond +1/-1 due to
// round off error
  if Result>1 then Result:=0
  else if Result<-1 then Result:=Pi
  else Result:=ArcCos(Result);
end;

//*****************************************************************************
// Converts P1,P2 into a vector
//      P1o----->P2
//*****************************************************************************
function Vector(P1,P2:TPoint3D):TPoint3D;
begin
  Result.X:=P2.X-P1.X;
  Result.Y:=P2.Y-P1.Y;
  Result.Z:=P2.Z-P1.Z;
end;

//*****************************************************************************
// Returns the magnitude of V. ( |V| )
//*****************************************************************************
function Magnitude(V:TPoint3D):Single;
begin
  Result:=Sqrt(Sqr(V.X)+Sqr(V.Y)+Sqr(V.Z));
end;

//*****************************************************************************
// Returns the dot product of two vectors
//*****************************************************************************
function DotProduct(V1,V2:TPoint3D):Single;
begin
  Result:=V1.X*V2.X+V1.Y*V2.Y+V1.Z*V2.Z;
end;

function FindNormal(P1,P2,P3:TPoint3D):TPoint3D;
var
  V1,V2  : TPoint3D;
  Length : Single;
begin
  V1:=Vector(P1,P2);
  V2:=Vector(P1,P3);

// find the normal perpendicular to both - (cross product of the 2)
//  Result.X:=-((V1.Y*V2.Z)-(V1.Z*V2.Y));
//  Result.Y:=+((V1.X*V2.Z)-(V1.Z*V2.X));
//  Result.Z:=-((V1.X*V2.Y)-(V1.Y*V2.X));

  Result.X:=-((V1.Y*V2.Z)-(V1.Z*V2.Y));
  Result.Z:=-((V1.X*V2.Z)-(V1.Z*V2.X));
  Result.Y:=-((V1.X*V2.Y)-(V1.Y*V2.X));


// scale the vector to be of unit length
  Length:=Sqrt(Sqr(Result.X)+Sqr(Result.Y)+Sqr(Result.Z));

// don't divide by zero...
  if Length>0 then begin
    Result.X:=Result.X/Length;
    Result.Y:=Result.Y/Length;
    Result.Z:=Result.Z/Length;
  end;
end;

procedure FindPlaneCoefficients(var Plane:TPlane);
begin
// find the plane equation vars
// A = y1 ( z2 - z3 ) + y2 ( z3 - z1 ) + y3 ( z1 - z2 )
// B = z1 ( x2 - x3 ) + z2 ( x3 - x1 ) + z3 ( x1 - x2 )
// C = x1 ( y2 - y3 ) + x2 ( y3 - y1 ) + x3 ( y1 - y2 )
// D = - x1 ( y2z3 - y3z2 ) - x2 ( y3z1 - y1z3 ) - x3 ( y1z2 - y2z1 )
  with Plane do begin
    A:=Point[1].Y*(Point[2].Z-Point[3].Z)+Point[2].Y*(Point[3].Z-Point[1].Z)+
       Point[3].Y*(Point[1].Z-Point[2].Z);
    B:=Point[1].Z*(Point[2].X-Point[3].X)+Point[2].Z*(Point[3].X-Point[1].X)+
       Point[3].Z*(Point[1].X-Point[2].X);
    C:=Point[1].X*(Point[2].Y-Point[3].Y)+Point[2].X*(Point[3].Y-Point[1].Y)+
       Point[3].X*(Point[1].Y-Point[2].Y);
    D:=-Point[1].X*(Point[2].Y*Point[3].Z-Point[3].Y*Point[2].Z)-
       Point[2].X*(Point[3].Y*Point[1].Z-Point[1].Y*Point[3].Z)-
       Point[3].X*(Point[1].Y*Point[2].Z-Point[2].Y*Point[1].Z);
  end;
end;

//      X1,X2         a = angle from X1,X2 to X Axis
//     /              Rz = angle of rotation (clockwise)
//  R / a \           R = distance from origin to X1,X2
//   / /   \          X1=RCos(a) Y1=RSin(a)
//  + ----- Rz--- X   X2=RCos(a-Rz) Y2=RSin(a-Rz)
//   \     /          Cos(a-Rz)=Cos(a)Cos(Rz)+Sin(a)Sin(Rz)
//  R \   /           Sin(a-Rz)=Sin(a)Cos(Rz)-Cos(a)Sin(Rz)
//     \              X2=R[Cos(a)Cos(Rz)+Sin(a)Sin(Rz)=X1Cos(Rz)+Y1Sin(Rz)
//     X2,Y2          Y2=R[Sin(a)Cos(Rz)-Cos(a)Sin(Rz)]=Y1Cos(Rz)-X1Sin(Rz)

procedure RotateXYPoint(var X,Y:Single;Rz:Single);
var
  Temp : Single;
begin
  Rz:=-Rz;
  Temp:=Y*Cos(Rz)-X*Sin(Rz);
  X:=X*Cos(Rz)+Y*Sin(Rz);
  Y:=Temp;
end;

//******************************************************************************
// Returns Point rotated Rz about the Z axis
//******************************************************************************
function Rotated3DPoint(Point:TPoint3D;Rz:Single) : TPoint3D;
begin
  with Result do begin
    X:=Point.X*Cos(Rz)+Point.Y*Sin(Rz);
    Y:=Point.Y*Cos(Rz)-Point.X*Sin(Rz);
    Z:=Point.Z;
  end;
end;

procedure FindPanAndTiltToTarget(var Pose:TPose;Target:TPoint3D;var Pan,Tilt:Single);
var
  RxMatrix : TQMatrix;
  RyMatrix : TQMatrix;
  RzMatrix : TQMatrix;
  L        : Single;
begin
// find the target relative to the source location
  Target.X:=Target.X-Pose.X;
  Target.Y:=Target.Y-Pose.Y;
  Target.Z:=Target.Z-Pose.Z;

// apply the fixture p,t,r
  RxMatrix:=XRotationMatrix(-Pose.Rx);
  RyMatrix:=YRotationMatrix(-Pose.Ry);
  RzMatrix:=ZRotationMatrix(+Pose.Rz);
  Target:=Point3DMultMatrix(Target,RzMatrix);
  Target:=Point3DMultMatrix(Target,RxMatrix);
  Target:=Point3DMultMatrix(Target,RyMatrix);

// pan
  if Target.Z<0 then Pan:=ArcTan(Target.X/Target.Z)
  else if Target.Z>0 then begin
    if Target.X>0 then Pan:=ArcTan(Target.X/Target.Z)-Pi
    else Pan:=ArcTan(Target.X/Target.Z)+Pi;
  end
  else if Target.X>0 then Pan:=-Pi/2
  else Pan:=+Pi/2;

// tilt
  L:=Sqrt(Sqr(Target.X)+Sqr(Target.Z));
  if L>0 then Tilt:=-ArcTan(Target.Y/L)
  else Tilt:=0;
end;

end.

procedure FindPanAndTiltToTarget(var Pose:TPose;Target:TPoint3D;var Pan,Tilt:Single);
var
  RxMatrix : TQMatrix;
  RyMatrix : TQMatrix;
  RzMatrix : TQMatrix;
  L        : Single;
  Under    : Boolean;
begin
  Under:=(Target.Z<Pose.Z);
// find the target relative to the source location
  Target.X:=Target.X-Pose.X;
  Target.Y:=Target.Y-Pose.Y;
  Target.Z:=Target.Z-Pose.Z;

// apply the fixture p,t,r
  RxMatrix:=XRotationMatrix(-Pose.Rx);
  RyMatrix:=YRotationMatrix(-Pose.Ry);
  RzMatrix:=ZRotationMatrix(+Pose.Rz);
  Target:=Point3DMultMatrix(Target,RzMatrix);
  Target:=Point3DMultMatrix(Target,RxMatrix);
  Target:=Point3DMultMatrix(Target,RyMatrix);

// pan
  if Target.Z<0 then Pan:=ArcTan(Target.X/Target.Z)
  else if Target.Z>0 then begin
    if Target.X>0 then Pan:=ArcTan(Target.X/Target.Z)-Pi
    else Pan:=ArcTan(Target.X/Target.Z)+Pi;
  end
  else if Target.X>0 then Pan:=-Pi/2
  else Pan:=+Pi/2;

// tilt
  L:=Sqrt(Sqr(Target.X)+Sqr(Target.Z));
  if L>0 then Tilt:=-ArcTan(Target.Y/L)
  else Tilt:=0;

  if Target.Z<Pose.Z then begin
    Tilt:=Tilt+Pi;
  end;
end;

end.

