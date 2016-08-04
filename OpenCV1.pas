unit OpenCV1;

interface

type
  TCvMat1 = packed record
    mType    : Integer;
    Step     : Integer;
    RefCount : Integer; // PCvIntArray;
{    Case Integer of
      0: (Ptr : ^Byte);
      1: (S   : ^ShortInt);
      2: (I   : ^Integer);
      3: (Fl  : ^Single);
      4: (Db  : ^Double);  }
    Data     : ^Single;//Pointer;//Cv64FArray;
    Rows     : Integer;
    Cols     : Integer;
  end;
  PCvMat1 = ^TCvMat1;

const
  CV_32F_1   = 4;
  CV_32FC1_1 = CV_32F_1 + 0*8;

procedure cvRodrigues(RotMatr:PCvMat1;RotVect:PCvMat1;Jacobian:PCvMat1;
            ConvType:Integer); cdecl;

function  cvCreateMat(Rows:Integer;Cols:Integer;dType:Integer):PCvMat1; cdecl;
procedure cvReleaseMat(var Mat:PCvMat1); cdecl;


implementation

const
  OpenCvDLL = 'cv.dll';

procedure cvRodrigues; external OpenCvDLL;
function  cvCreateMat; external OpenCvDLL;
procedure cvReleaseMat; external OpenCvDLL;

end.
