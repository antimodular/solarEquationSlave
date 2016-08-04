unit QMatrix;

interface

uses
  OpenGL, Global;

type
// vector
  TVector = array[0..2] of Single;

// matrix
  TQMatrix = array[0..15] of GLFloat;

// quaternion
  TQuaternion = record
    X,Y,Z,W : Single;
  end;

// Quaternion/Matrix/Euler conversion routines
function QuaternionToMatrix(var Q:TQuaternion):TQMatrix;
function MatrixToQuaternion(var M:TQMatrix):TQuaternion;
function EulersToQuaternion(Rx,Ry,Rz:Single):TQuaternion;
function EulersToMatrix(Rx,Ry,Rz:Single):TQMatrix;
function QuaternionToEulers(Q:TQuaternion):TPoint3D;
function MatrixToEulers(var M:TQMatrix):TPoint3D;

// Quaternion/Matrix math routines
function  DefaultQuaternion:TQuaternion;
function  QuaternionMultiply(var Q1,Q2:TQuaternion):TQuaternion;
procedure NormalizeQuaternion(var Q:TQuaternion);
function  MatrixMultiply(var M1,M2:TQMatrix):TQMatrix;
function  MatrixMultiply34(A,B:TQMatrix):TQMatrix;
function  VectorMatrixMult(var V:TVector;var M:TQMatrix):TVector;
function  Point3DMultMatrix(Point:TPoint3D;M:TQMatrix):TPoint3D;
function  IdentityMatrix:TQMatrix;
function  XRotationMatrix(A:Single):TQMatrix;
function  YRotationMatrix(A:Single):TQMatrix;
function  ZRotationMatrix(A:Single):TQMatrix;
function  RxMatrix(Angle:GLFloat):TQMatrix;
function  RyMatrix(Angle:GLFloat):TQMatrix;
function  RzMatrix(Angle:GLFloat):TQMatrix;

implementation

uses
  Math, Main, SysUtils;

const
  RadsPerDegree = Pi/180;

function DefaultQuaternion:TQuaternion;
begin
  Result.X:=0; Result.Y:=0; Result.Z:=0; Result.W:=1;
end;

//*****************************************************************************
// Inits the quaternion from the 3 Euler angles
//*****************************************************************************
function EulersToQuaternion(Rx,Ry,Rz:Single):TQuaternion;
var
  Cr,Cp,Cy,Sr,Sp,Sy,CpCy,SpSy : Single;
begin
// find Cr,Cp,Cy
  Cr:=Cos(Rx/2); // roll
  Cp:=Cos(Ry/2); // pitch
  Cy:=Cos(Rz/2); // yaw

// find Sr,Sp,Sy
  Sr:=Sin(Rx/2);
  Sp:=Sin(Ry/2);
  Sy:=Sin(Rz/2);

// calculate these for efficiency
  CpCy:=Cp*Cy;
  SpSy:=Sp*Sy;

// init the Quaternion
  Result.W:=Cr*CpCy + Sr*SpSy;
  Result.X:=Sr*CpCy - Cr*SpSy;
  Result.Y:=Cr*Sp*Cy + Sr*Cp*Sy;
  Result.Z:=Cr*Cp*Sy - Sr*Sp*Cy;
end;

function QuaternionMultiply(var Q1,Q2:TQuaternion):TQuaternion;
var
  A,B,C,D,E,F,G,H : Single;
begin
// calculate some intermediate vars
  A:=(Q1.W+Q1.X)*(Q2.W+Q2.X);
  B:=(Q1.Z-Q1.Y)*(Q2.Y-Q2.Z);
  C:=(Q1.X-Q1.W)*(Q2.Y+Q2.Z);
  D:=(Q1.Y+Q1.Z)*(Q2.X-Q2.W);
  E:=(Q1.X+Q1.Z)*(Q2.X+Q2.Y);
  F:=(Q1.X-Q1.Z)*(Q2.X-Q2.Y);
  G:=(Q1.W+Q1.Y)*(Q2.W-Q2.Z);
  H:=(Q1.W-Q1.Y)*(Q2.W-Q2.Z);

// finish up
  Result.X:=A-(E+F+G+H)/2;
  Result.Y:=-C+(E-F+G-H)/2;
  Result.Z:=-D+(E-F-G+H)/2;
  Result.W:=B+(-E-F+G+H)/2;
end;

procedure NormalizeQuaternion(var Q:TQuaternion);
var
  Magnitude : Single;
begin
// find the magnitude
  Magnitude:=Sqrt(Sqr(Q.W)+Sqr(Q.X)+Sqr(Q.Y)+Sqr(Q.Z));

// normalize it
  if Magnitude>0 then begin
    Q.W:=Q.W/Magnitude;
    Q.X:=Q.X/Magnitude;
    Q.Y:=Q.Y/Magnitude;
    Q.Z:=Q.Z/Magnitude;
  end;
end;

function QuaternionToMatrix(var Q:TQuaternion):TQMatrix;
var
  WX2,WY2,WZ2,XX2,XY2,XZ2,YY2,YZ2,ZZ2,X2,Y2,Z2:Single;
begin
// calculate coefficients for speed
  X2:=Q.X+Q.X; Y2:=Q.Y+Q.Y; Z2:=Q.Z+Q.Z;
  XX2:=Q.X*X2; XY2:=Q.X*Y2; XZ2:=Q.X*Z2;
  YY2:=Q.Y*Y2; YZ2:=Q.Y*Z2; ZZ2:=Q.Z*Z2;
  WX2:=Q.W*X2; WY2:=Q.W*Y2; WZ2:=Q.W*Z2;

// construct a matrix
  Result[0]:=1-YY2-ZZ2; Result[1]:=XY2-WZ2;   Result[2]:=XZ2+WY2;    Result[3]:=0;
  Result[4]:=XY2+WZ2;   Result[5]:=1-XX2-ZZ2; Result[6]:=YZ2-WX2;    Result[7]:=0;
  Result[8]:=XZ2-WY2;   Result[9]:=YZ2+WX2;   Result[10]:=1-XX2-YY2; Result[11]:=0;
  Result[12]:=0;        Result[13]:=0;        Result[14]:=0;         Result[15]:=1;
end;

function MatrixToQuaternion(var M:TQMatrix):TQuaternion;
var
  Trace,S : Single;
begin
// find the "trace" of the matrix
  Trace:=M[0]+M[5]+M[10]+1;

// if the trace is >0, perform an "instant" calculation
  if Trace>0 then begin
    S:=0.5/Sqrt(Trace);
    with Result do begin
      W:=0.25/S;
      X:=(M[9]-M[6])*S;
      Y:=(M[2]-M[8])*S;
      Z:=(M[4]-M[1])*S;
    end;
  end

// otherwise, find which major diagonal is greatest and act accordingly :)
// Column #0
  else if (M[0]>M[5]) and (M[0]>M[10]) then begin
    S:=Sqrt(1+M[0]-M[5]-M[10])*2;
    with Result do begin
      X:=0.5/S;
      Y:=(M[1]+M[4])/S;
      Z:=(M[2]+M[8])/S;
      W:=(M[6]+M[9])/S;
    end;
  end

// Column #1
  else if (M[5]>M[0]) and (M[5]>M[10]) then begin
    S:=Sqrt(1+M[5]-M[0]-M[10])*2;
    with Result do begin
      X:=(M[1]+M[4])/S;
      Y:=0.5/S;
      Z:=(M[6]+M[9])/S;
      W:=(M[2]+M[8])/S;
    end;
  end

// Column #2
  else begin
    S:=Sqrt(1+M[10]-M[0]-M[5])*2;
    with Result do begin
      X:=(M[2]+M[8])/S;
      Y:=(M[6]+M[9])/S;
      Z:=0.5/S;
      W:=(M[1]+M[4])/S;
    end;
  end;
end;

function VectorMatrixMult(var V:TVector;var M:TQMatrix):TVector;
begin
  Result[0]:=(V[0]*M[0])+(V[1]*M[1])+(V[2]*M[2]);
  Result[1]:=(V[0]*M[4])+(V[1]*M[5])+(V[2]*M[6]);
  Result[2]:=(V[0]*M[8])+(V[1]*M[9])+(V[2]*M[10]);
end;

function Point3DMultMatrix(Point:TPoint3D;M:TQMatrix):TPoint3D;
begin
  Result.X:=Point.X*M[0]+Point.Y*M[4]+Point.Z*M[8]+1*M[12];
  Result.Y:=Point.X*M[1]+Point.Y*M[5]+Point.Z*M[9]+1*M[13];
  Result.Z:=Point.X*M[2]+Point.Y*M[6]+Point.Z*M[10]+1*M[14];
end;

function IdentityMatrix:TQMatrix;
begin
  Result[0]:=1;  Result[1]:=0;  Result[2]:=0;  Result[3]:=0;
  Result[4]:=0;  Result[5]:=1;  Result[6]:=0;  Result[7]:=0;
  Result[8]:=0;  Result[9]:=0;  Result[10]:=1; Result[11]:=0;
  Result[12]:=0; Result[13]:=0; Result[14]:=0; Result[15]:=1;
end;

function RxMatrix(Angle:GLFloat):TQMatrix;
var
  S,C : Single;
begin
  S:=Sin(Angle); C:=Cos(Angle);

// find the matrix
  Result[00]:=+1; Result[01]:=+0; Result[02]:=+0; Result[03]:=+0;
  Result[04]:=+0; Result[05]:=+C; Result[06]:=+S; Result[07]:=+0;
  Result[08]:=+0; Result[09]:=-S; Result[10]:=+C; Result[11]:=+0;
  Result[12]:=+0; Result[13]:=+0; Result[14]:=+0; Result[15]:=+1;
end;

function RyMatrix(Angle:GLFloat):TQMatrix;
var
  S,C : Single;
begin
  S:=Sin(Angle); C:=Cos(Angle);

// find the matrix
  Result[00]:=+C; Result[01]:=+0; Result[02]:=-S; Result[03]:=+0;
  Result[04]:=+0; Result[05]:=+1; Result[06]:=+0; Result[07]:=+0;
  Result[08]:=+S; Result[09]:=+0; Result[10]:=+C; Result[11]:=+0;
  Result[12]:=+0; Result[13]:=+0; Result[14]:=+0; Result[15]:=+1;
end;

function RzMatrix(Angle:GLFloat):TQMatrix;
var
  S,C : Single;
begin
  S:=Sin(Angle); C:=Cos(Angle);

// find the matrix
  Result[00]:=+C; Result[01]:=+S; Result[02]:=+0; Result[03]:=+0;
  Result[04]:=-S; Result[05]:=+C; Result[06]:=+0; Result[07]:=+0;
  Result[08]:=+0; Result[09]:=+0; Result[10]:=+1; Result[11]:=+0;
  Result[12]:=+0; Result[13]:=+0; Result[14]:=+0; Result[15]:=+1;
end;

function XRotationMatrix(A:Single):TQMatrix;
begin
  Result[0]:=1;  Result[1]:=0;      Result[2]:=0;       Result[3]:=0;
  Result[4]:=0;  Result[5]:=Cos(A); Result[6]:=-Sin(A); Result[7]:=0;
  Result[8]:=0;  Result[9]:=Sin(A); Result[10]:=Cos(A); Result[11]:=0;
  Result[12]:=0; Result[13]:=0;     Result[14]:=0;      Result[15]:=1;
end;

function YRotationMatrix(A:Single):TQMatrix;
begin
  Result[0]:=Cos(A); Result[1]:=0;  Result[2]:=-Sin(A); Result[3]:=0;
  Result[4]:=0;      Result[5]:=1;  Result[6]:=0;       Result[7]:=0;
  Result[8]:=Sin(A); Result[9]:=0;  Result[10]:=Cos(A); Result[11]:=0;
  Result[12]:=0;     Result[13]:=0; Result[14]:=0;      Result[15]:=1;
end;

function ZRotationMatrix(A:Single):TQMatrix;
begin
  Result[0]:=Cos(A); Result[1]:=-Sin(A); Result[2]:=0;  Result[3]:=0;
  Result[4]:=Sin(A); Result[5]:=Cos(A);  Result[6]:=0;  Result[7]:=0;
  Result[8]:=0;      Result[9]:=0;       Result[10]:=1; Result[11]:=0;
  Result[12]:=0;     Result[13]:=0;      Result[14]:=0; Result[15]:=1;
end;

function EulersToMatrix(Rx,Ry,Rz:Single):TQMatrix;
var
  A,B,C,D,E,F,AD,BD : Single;
begin
// find some intermediate vars
  Rx:=DegToRad(Rx); Ry:=DegToRad(Ry); Rz:=DegToRad(Rz);
  A:=Cos(Rx); B:=Sin(Rx);
  C:=Cos(Ry); D:=Sin(Ry);
  E:=Cos(Rz); F:=Sin(Rz);
  AD:=A*D; BD:=B*D;

// fill the result in
  Result[0]:=C*E;         Result[1]:=-C*F;        Result[2]:=-D;   Result[3]:=0;
  Result[4]:=-BD*E + A*F; Result[5]:=BD*F + A*E;  Result[6]:=-B*C; Result[7]:=0;
  Result[8]:=AD*E + B*F;  Result[9]:=-AD*F + B*E; Result[10]:=A*C; Result[11]:=0;
  Result[12]:=0;          Result[13]:=0;          Result[14]:=0;   Result[15]:=1;
end;

// this one doesn't seem to work
function QuaternionToEulers(Q:TQuaternion):TPoint3D;
var
  Angle,SinAngle : Single;
begin
  Angle:=ArcCos(Q.W)*2;
  SinAngle:=Sin(Angle);
  if Abs(SinAngle)<0.0005 then SinAngle:=1;
  Result.X:=Q.X/SinAngle;
  Result.Y:=Q.Y/SinAngle;
  Result.Z:=Q.Z/SinAngle;
end;

function MatrixToEulers(var M:TQMatrix):TPoint3D;
var
  X,Y,C : Single;
begin
  Result.Y:=-ArcSin(M[2]);
  C:=Cos(Result.Y);

// if Abs(C)>0.005 we don't have gimbal lock
  if Abs(C)>0.005 then begin
    X:=M[10]/C;
    Y:=-M[6]/C;
    Result.X:=ArcTan(Y/X);
    X:=M[0]/C;
    Y:=-M[1]/C;
    Result.Z:=ArcTan(Y/X);
  end

// the gimbal lock case
  else begin
    Result.X:=0;
    X:=M[5];
    Y:=M[4];
    Result.Z:=ArcTan(Y/X);
  end;
  Result.X:=Result.X*180/Pi;
  if Result.X<0 then Result.X:=Result.X+360;

  Result.Y:=Result.Y*180/Pi;
  if Result.Y<0 then Result.Y:=Result.Y+360;

  Result.Z:=Result.Z*180/Pi;
  if Result.Z<0 then Result.Z:=Result.Z+360;
end;

function MatrixMultiply(var M1,M2:TQMatrix):TQMatrix;
begin
  Result[0]:=M1[0]*M2[0]+M1[1]*M2[4]+M1[2]*M2[8]+M1[3]*M2[12];
  Result[1]:=M1[0]*M2[1]+M1[1]*M2[5]+M1[2]*M2[9]+M1[3]*M2[13];
  Result[2]:=M1[0]*M2[2]+M1[1]*M2[6]+M1[2]*M2[10]+M1[3]*M2[14];
  Result[3]:=M1[0]*M2[3]+M1[1]*M2[7]+M1[2]*M2[11]+M1[3]*M2[15];
  Result[4]:=M1[4]*M2[0]+M1[5]*M2[4]+M1[6]*M2[8]+M1[7]*M2[12];
  Result[5]:=M1[4]*M2[1]+M1[5]*M2[5]+M1[6]*M2[9]+M1[7]*M2[13];
  Result[6]:=M1[4]*M2[2]+M1[5]*M2[6]+M1[6]*M2[10]+M1[7]*M2[14];
  Result[7]:=M1[4]*M2[3]+M1[5]*M2[7]+M1[6]*M2[11]+M1[7]*M2[15];
  Result[8]:=M1[8]*M2[0]+M1[9]*M2[4]+M1[10]*M2[8]+M1[11]*M2[12];
  Result[9]:=M1[8]*M2[1]+M1[9]*M2[5]+M1[10]*M2[9]+M1[11]*M2[13];
  Result[10]:=M1[8]*M2[2]+M1[9]*M2[6]+M1[10]*M2[10]+M1[11]*M2[14];
  Result[11]:=M1[8]*M2[3]+M1[9]*M2[7]+M1[10]*M2[11]+M1[11]*M2[15];
  Result[12]:=M1[12]*M2[0]+M1[13]*M2[4]+M1[14]*M2[8]+M1[15]*M2[12];
  Result[13]:=M1[12]*M2[1]+M1[13]*M2[5]+M1[14]*M2[9]+M1[15]*M2[13];
  Result[14]:=M1[12]*M2[2]+M1[13]*M2[6]+M1[14]*M2[10]+M1[15]*M2[14];
  Result[15]:=M1[12]*M2[3]+M1[13]*M2[7]+M1[14]*M2[11]+M1[15]*M2[15];
end;

function MatrixMultiply34(A,B:TQMatrix):TQMatrix;
begin
  Result[00]:=A[0]*B[00]+A[4]*B[01]+A[8]*B[02];
  Result[04]:=A[0]*B[04]+A[4]*B[05]+A[8]*B[06];
  Result[08]:=A[0]*B[08]+A[4]*B[09]+A[8]*B[10];
  Result[12]:=A[0]*B[12]+A[4]*B[13]+A[8]*B[14]+A[12];

  Result[01]:=A[1]*B[00]+A[5]*B[01]+A[9]*B[02];
  Result[05]:=A[1]*B[04]+A[5]*B[05]+A[9]*B[06];
  Result[09]:=A[1]*B[08]+A[5]*B[09]+A[9]*B[10];
  Result[13]:=A[1]*B[12]+A[5]*B[13]+A[9]*B[14]+A[13];

  Result[02]:=A[2]*B[00]+A[6]*B[01]+A[10]*B[02];
  Result[06]:=A[2]*B[04]+A[6]*B[05]+A[10]*B[06];
  Result[10]:=A[2]*B[08]+A[6]*B[09]+A[10]*B[10];
  Result[14]:=A[2]*B[12]+A[6]*B[13]+A[10]*B[14]+A[14];

  Result[3]:=0;
  Result[7]:=0;
  Result[11]:=0;
  Result[15]:=1;
end;

end.
