unit MaskU;

interface

uses
  Global, Graphics, SysUtils, CfgFile;

type
  TMaskFile = File of TMask;

procedure LoadMask(FileName:String;Mask:PMask);
procedure SaveMask(FileName:String;Mask:PMask);
procedure ApplyMaskToBmp(Mask:PMask;Bmp:TBitmap);

implementation

procedure LoadMask(FileName:String;Mask:PMask);
var
  MaskFile : TMaskFile;
begin
  if FileExists(FileName) and (SizeOfFile(FileName)=SizeOf(TMask)) then begin
    Assign(MaskFile,FileName);
    try
      Reset(MaskFile);
      Read(MaskFile,Mask^);
    finally
      Close(MaskFile);
    end;
  end
  else FillChar(Mask^,SizeOf(Mask^),True);
end;

procedure SaveMask(FileName:String;Mask:PMask);
var
  MaskFile : TMaskFile;
begin
  Assign(MaskFile,FileName);
  try
    Rewrite(MaskFile);
    Write(MaskFile,Mask^);
  finally
    Close(MaskFile);
  end;
end;

procedure ApplyMaskToBmp(Mask:PMask;Bmp:TBitmap);
var
  Bpp   : Integer;
  X,Y,I : Integer;
  Line  : PByteArray;
begin
  if Bmp.PixelFormat=pf24Bit then Bpp:=3
  else Bpp:=4;
  for Y:=0 to ImageH-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to ImageW-1 do begin
      I:=X*Bpp;
      if Mask^[X,Y] then begin
        Line^[I+0]:=Line^[I+2];
        Line^[I+1]:=Line^[I+2];
      end
      else begin
        Line^[I+0]:=0;
        Line^[I+1]:=0;
      end;
    end;
  end;
end;

end.
