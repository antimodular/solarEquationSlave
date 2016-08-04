unit CalMath;

interface

uses
  Classes, Dialogs, Global, MatrixU;

const
  MaxCalPoints = 5;

function AbleToFindHMatrix(HMatrix:TMatrix;var CalPoint:TCalPointArray):Boolean;
procedure FindPoseFromKInfoAndHMatrix(var Pose:TPose;KInfo:TKInfo;HMatrix:TMatrix);
function InvalidSingle(S:Single):Boolean;
procedure FindHMatrixFromCalPoints(var HMatrix:TMatrix;var CalPt:TCalPointArray;
                                   Lines:TStrings);
implementation

uses
  Math3D, MathUnit;

function CalMeasurementsAreOk(CalMeasurements:TCalMeasurements;
                              ShowErrors:Boolean=True):Boolean;
begin
// first see if they've all been entered
  with CalMeasurements do begin
    Result:=(D12>0) and (D23>0) and (D34>0) and (D14>0) and (D2C>0) and (D4C>0);
    if not Result then begin
      if ShowErrors then begin
        ShowMessage(
          'One or more of your calibration measurements have not been entered.'+
          CRLF+'Please check your measurements and try again.');
      end;
      Exit;
    end;

// now check the validity of them
    if (D2C+D4C)>=(D14+D12) then begin
      if ShowErrors then ShowMessage(
        'The distance along the path from Point #4 to Point #1 to Point #2 '+
        'must be greater than the distance from Point #4 to Point #2.'+CRLF+
        'Please check your measurements and try again.');
      Result:=False;
      Exit;
    end
    else if (D2C+D4C)>=(D34+D23) then begin
      if ShowErrors then ShowMessage(
        'The distance along the path from Point #4 to Point #3 to Point #2 '+
        'must be greater than the distance from Point #4 to Point #2.'+CRLF+
        'Please check your measurements and try again.');
      Result:=False;
      Exit;
    end
    else if (D12+D2C+D4C<=D14) then begin
      if ShowErrors then ShowMessage(
        'The distance along the path from Point #1 to Point #2 to Point #C '+
        'to Point #4 must be greater than the distance from Point #1 to '+
        'Point #4.'+CRLF+'Please check your measurements and try again.');
      Result:=False;
      Exit;
    end
    else if (D23+D2C+D4C<=D34) then begin
      if ShowErrors then ShowMessage(
        'The distance along the path from Point #3 to Point #2 to Point #C '+
        'to Point #4 must be greater than the distance from Point #3 to '+
        'Point #4.'+CRLF+'Please check your measurements and try again.');
      Result:=False;
    end;
  end;
end;

// returns true if S is Infinity, NAN or indeterminate
// 4byte IEEE: bit[31] = sign, bits[23-30] exponent, bits[0..22] mantissa
// if exponent is all 1s the single = Infinity, NAN or Indeterminate
function InvalidSingle(S:Single):Boolean;
var
  Overlay : LongInt absolute S;
const
  Exponent = 255 shl 23;
begin
  Result:=((Overlay and Exponent)=Exponent);
end;

//          /|\          :Lb=D-La  Sqr(Lb)=Sqr(D)-2DLa+Sqr(La)
//    Ra   / | \   Rb    :h=Sqr(Rb)-Sqr(Lb)=Sqr(Ra)-Sqr(La)
//        /  |h \        :Sqr(La)=Sqr(Ra)-Sqr(Rb)+Sqr(Lb)
//       /___|_ _\       :0=Sqr(Ra)-Sqr(Rb)+Sqr(D)-2DLa
//        La   Lb        :2DLa=Sqr(Ra)-Sqr(Rb)+Sqr(D)
//      <--- D --->      :La=Sqr(Ra)+Sqr(D)-Sqr(Rb)/2D
function Project2RadiiToSolveForLa(Ra,Rb,D:Double): Double;
begin
  Result:=(Sqr(Ra)+Sqr(D)-Sqr(Rb))/(2*D);
end;

function AbleToFindHMatrix(HMatrix:TMatrix;var CalPoint:TCalPointArray):Boolean;
var
  A     : TMatrix;
  Row,P : Integer;
begin
  A:=TMatrix.Create(10,9);
  try

// build the A matrix
    Row:=0;
    for P:=1 to 5 do with CalPoint[P] do begin
      Inc(Row);
      A.Cell[Row,1]:=X;
      A.Cell[Row,2]:=Y;
      A.Cell[Row,3]:=1;
      A.Cell[Row,4]:=0;
      A.Cell[Row,5]:=0;
      A.Cell[Row,6]:=0;
      A.Cell[Row,7]:=-PanTicks*X;
      A.Cell[Row,8]:=-PanTicks*Y;
      A.Cell[Row,9]:=-PanTicks;
      Inc(Row);
      A.Cell[Row,1]:=0;
      A.Cell[Row,2]:=0;
      A.Cell[Row,3]:=0;
      A.Cell[Row,4]:=X;
      A.Cell[Row,5]:=Y;
      A.Cell[Row,6]:=1;
      A.Cell[Row,7]:=-TiltTicks*X;
      A.Cell[Row,8]:=-TiltTicks*Y;
      A.Cell[Row,9]:=-TiltTicks;
    end;

// solve it
    A.SolveWithSVD;
    with HMatrix do begin
      Cell[1,1]:=A.Cell[1,1]; Cell[1,2]:=A.Cell[2,1]; Cell[1,3]:=A.Cell[3,1];
      Cell[2,1]:=A.Cell[4,1]; Cell[2,2]:=A.Cell[5,1]; Cell[2,3]:=A.Cell[6,1];
      Cell[3,1]:=A.Cell[7,1]; Cell[3,2]:=A.Cell[8,1]; Cell[3,3]:=A.Cell[9,1];
      Normalize;
    end;
  finally
    A.Free;
  end;
end;

procedure FindPoseFromKInfoAndHMatrix(var Pose:TPose;KInfo:TKInfo;HMatrix:TMatrix);
var
  K,Ki,R1R2T : TMatrix;
  Rot,C,T    : TMatrix;
  Scale      : Single;
  R1,R2,R3   : TPoint3D;
  R          : Integer;
begin
  K:=TMatrix.Create(3,3);
  Ki:=TMatrix.Create(3,3);
  R1R2T:=TMatrix.Create(3,3);
  Rot:=TMatrix.Create(3,3);
  T:=TMatrix.Create(3,1);
  C:=TMatrix.Create(3,1);
  try
    K.InitFromKInfo3x3(KInfo);
    Ki.Equals(K);
    Ki.Invert;
    R1R2T.InitFromProduct(Ki,HMatrix); // [K]^-1 [H]
    Scale:=1/R1R2T.Norm;
    R1R2T.MultiplyByScalar(Scale);    // [K]^-1 [H] / || [K]^-1 [H] ||

    R1.X:=R1R2T.Cell[1,1];
    R1.Y:=R1R2T.Cell[2,1];
    R1.Z:=R1R2T.Cell[3,1];
    R2.X:=-R1R2T.Cell[1,2];
    R2.Y:=-R1R2T.Cell[2,2];
    R2.Z:=-R1R2T.Cell[3,2];
    R3:=CrossProduct(R2,R1);
    Rot.Cell[1,1]:=R1.X; Rot.Cell[1,2]:=R2.X; Rot.Cell[1,3]:=R3.X;
    Rot.Cell[2,1]:=R1.Y; Rot.Cell[2,2]:=R2.Y; Rot.Cell[2,3]:=R3.Y;
    Rot.Cell[3,1]:=R1.Z; Rot.Cell[3,2]:=R2.Z; Rot.Cell[3,3]:=R3.Z;
    Rot.FixRotationMatrix;

    with Pose do Rot.FindRxRyRz(Rx,Ry,Rz);

    for R:=1 to 3 do T.Cell[R,1]:=R1R2T.Cell[R,3];

    Rot.Invert;
    Rot.MultiplyByScalar(-1);
    C.InitFromProduct(Rot,T);
    Scale:=Rot.Cell[1,1]/R1.X;
    C.MultiplyByScalar(Scale);
    Pose.X:=C.Cell[1,1];
    Pose.Y:=C.Cell[2,1];
    Pose.Z:=C.Cell[3,1];

// we don't want to be below the stage - pick the other solution (- Scale)
    if Pose.Z<0 then begin
      R1R2T.InitFromProduct(Ki,HMatrix); // [K]^-1 [H]
      Scale:=-1/R1R2T.Norm;
      R1R2T.MultiplyByScalar(Scale);    // [K]^-1 [H] / || [K]^-1 [H] ||

      R1.X:=R1R2T.Cell[1,1];
      R1.Y:=R1R2T.Cell[2,1];
      R1.Z:=R1R2T.Cell[3,1];
      R2.X:=-R1R2T.Cell[1,2];
      R2.Y:=-R1R2T.Cell[2,2];
      R2.Z:=-R1R2T.Cell[3,2];
      R3:=CrossProduct(R2,R1);
      Rot.Cell[1,1]:=R1.X; Rot.Cell[1,2]:=R2.X; Rot.Cell[1,3]:=R3.X;
      Rot.Cell[2,1]:=R1.Y; Rot.Cell[2,2]:=R2.Y; Rot.Cell[2,3]:=R3.Y;
      Rot.Cell[3,1]:=R1.Z; Rot.Cell[3,2]:=R2.Z; Rot.Cell[3,3]:=R3.Z;
      Rot.FixRotationMatrix;

      with Pose do Rot.FindRxRyRz(Rx,Ry,Rz);

      for R:=1 to 3 do T.Cell[R,1]:=R1R2T.Cell[R,3];

      Rot.Invert;
      Rot.MultiplyByScalar(-1);
      C.InitFromProduct(Rot,T);
      Scale:=Rot.Cell[1,1]/R1.X;
      C.MultiplyByScalar(Scale);
      Pose.X:=C.Cell[1,1];
      Pose.Y:=C.Cell[2,1];
      Pose.Z:=C.Cell[3,1];
    end;
  finally
    K.Free;
    Ki.Free;
    R1R2T.Free;
    Rot.Free;
    T.Free;
    C.Free;
  end;
end;

procedure FindHMatrixFromCalPoints(var HMatrix:TMatrix;var CalPt:TCalPointArray;Lines:TStrings);
var
  A,Tr,Tp  : TMatrix;
  I,R      : Integer;
  NormalPt : TCalPointArray;
begin
  A:=TMatrix.Create(10,9);
  Tp:=TMatrix.Create(3,3);
  Tr:=TMatrix.Create(3,3);
  try

// build the A matrix
    R:=0;
    for I:=1 to 5 do with CalPt[I] do begin
      Inc(R);
      A.Cell[R,1]:=X;
      A.Cell[R,2]:=Y;
      A.Cell[R,3]:=1;
      A.Cell[R,4]:=0;
      A.Cell[R,5]:=0;
      A.Cell[R,6]:=0;
      A.Cell[R,7]:=-PanTicks*X;
      A.Cell[R,8]:=-PanTicks*Y;
      A.Cell[R,9]:=-PanTicks;
      Inc(R);
      A.Cell[R,1]:=0;
      A.Cell[R,2]:=0;
      A.Cell[R,3]:=0;
      A.Cell[R,4]:=X;
      A.Cell[R,5]:=Y;
      A.Cell[R,6]:=1;
      A.Cell[R,7]:=-TiltTicks*X;
      A.Cell[R,8]:=-TiltTicks*Y;
      A.Cell[R,9]:=-TiltTicks;
    end;

    if Assigned(Lines) then begin
      A.DisplayInLinesWithPunctuation(Lines,'A matrix:');
    end;

// solve it
    A.SolveWithSVD;
    with HMatrix do begin
      Cell[1,1]:=A.Cell[1,1]; Cell[1,2]:=A.Cell[2,1]; Cell[1,3]:=A.Cell[3,1];
      Cell[2,1]:=A.Cell[4,1]; Cell[2,2]:=A.Cell[5,1]; Cell[2,3]:=A.Cell[6,1];
      Cell[3,1]:=A.Cell[7,1]; Cell[3,2]:=A.Cell[8,1]; Cell[3,3]:=A.Cell[9,1];
    end;

    if Assigned(Lines) then begin
      HMatrix.DisplayInLinesWithPunctuation(Lines,'H matrix:');
    end;
  finally
    A.Free;
    Tr.Free;
    Tp.Free;
  end;
end;

end.
