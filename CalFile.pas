unit CalFile;

interface

uses
  Windows, Global, CfgFile;

const
  MaxExtCorners = 100;

type
  TMatrixData3x3 = array[1..3,1..3] of Single;
  TMatrixData3x4 = array[1..3,1..4] of Single;

  TExtCornerArray = array[1..MaxExtCorners] of TPoint2D;

  TCalFileRecord = packed record
    Signature      : TFileSignature;
    KInfo          : TKInfo;
    Pose           : TPose;
    HMatrixData    : TMatrixData3x3;
    ProjMatrixData : TMatrixData3x4;
    ExtCorner      : TExtCornerArray; // 100*2*4=800
    ExtColumns     : Integer;  // 4
    ExtRows        : Integer;  // 4
    ExtColSpacing  : Single;   // 4
    ExtRowSpacing  : Single;   // 4
    CalMetrePt     : array[1..5] of TPoint2D; // cal point metre location
    Reserved       : array[1..216] of Byte;
  end;
  TCalFile = File of TCalFileRecord;

function AbleToLoadCalFile(FileName:String;var CalFileRecord:TCalFileRecord):Boolean;

implementation

uses
  Dialogs, FileCtrl, SysUtils;

const
  CalFileSignature = 'CalFile001';

function AbleToLoadCalFile(FileName:String;var CalFileRecord:TCalFileRecord):Boolean;
var
  CalFile : TCalFile;
  Handle  : Integer;
  Size    : Integer;
begin
  Result:=False;
  if not FileExists(FileName) then ShowMessage('Can''t find '+FileName)
  else if SizeOfFile(FileName)<>SizeOf(TCalFileRecord) then begin
    ShowMessage(FileName+' is the wrong size');
  end
  else begin
    Handle:=FileOpen(FileName,fmOpenRead);
    if Handle>0 then begin
      FileSeek(Handle,0,0);
      Size:=FileRead(Handle,CalFileRecord,SizeOf(CalFileRecord));
      FlushFileBuffers(Handle);
      FileClose(Handle);
      Result:=(Size=SizeOf(CalFileRecord));
    end;
  end;
end;

end.
