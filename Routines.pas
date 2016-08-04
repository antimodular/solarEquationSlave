unit Routines;

interface

uses
  Classes, Forms, FileCtrl, Global, WinSock;

function RadStr(Rads:Single):String;
function DegreeStr(Rads:Single):String;
function MetreStr(Metres:Single):String;
function TargetStr(Tgt:TPoint3D):String;
function Point2DStr(Pt:TPoint2D):String;

procedure ShowString(Txt:String);
function PointsSame(P1,P2:TPoint3D):Boolean;

function TwoDigitIntStr(I:Integer):String;
function ThreeDigitIntStr(I:Integer):String;
function FourDigitIntStr(I:Integer):String;

function RandomSingle(Min,Max:Single):Single;

procedure PlaceFormInWindow(Form:TForm;Window:TWindow);

function Path:String;
function ImagePath:String;
function TexturePath:String;
function MP3Path:String;
procedure SelectFileInFileLB(FileLB:TFileListBox;FileName:String);
function ClipToByte(V:Single):Byte;

function GetIPAddress:String;

implementation

uses
  SysUtils, Windows, Math, StrUtils, MemoFrmU;

function ClipToByte(V:Single):Byte;
begin
  if V<=0 then Result:=0
  else if V>=255 then Result:=255
  else Result:=Round(V);
end;

procedure SelectFileInFileLB(FileLB:TFileListBox;FileName:String);
var
  I : Integer;
begin
  for I:=0 to FileLB.Items.Count-1 do begin
    if UpperCase(FileName)=UpperCase(FileLB.Items[I]) then begin
      FileLB.ItemIndex:=I;
      Exit;
    end;
  end;
  FileLB.ItemIndex:=-1;
end;

function MP3Path:String;
begin
  Result:=Path+'MP3\';
end;

function TexturePath:String;
begin
  Result:=Path+'Textures\';
end;

function ImagePath:String;
begin
  Result:=Path+'Images\';
end;

procedure PlaceFormInWindow(Form:TForm;Window:TWindow);
begin
  Form.Left:=Window.X;
  Form.Top:=Window.Y;
  Form.Width:=Window.W;
  Form.Height:=Window.H;
end;

function RadStr(Rads:Single):String;
begin
  Result:=FloatToStrF(Rads,ffFixed,9,3);
end;

function DegreeStr(Rads:Single):String;
var
  Degs : Single;
begin
  Degs:=RadToDeg(Rads);
  Result:=FloatToStrF(Degs,ffFixed,9,2);
end;

function MetreStr(Metres:Single):String;
begin
  Result:=FloatToStrF(Metres,ffFixed,9,2);
end;

function TargetStr(Tgt:TPoint3D):String;
begin
  Result:='X: '+FloatToStrF(Tgt.X,ffFixed,9,1)+
         ' Y: '+FloatToStrF(Tgt.Y,ffFixed,9,1)+
         ' Z: '+FloatToStrF(Tgt.Z,ffFixed,9,1);
end;

function Path:String;
begin
  Result:=ExtractFilePath(Application.ExeName);
end;

function Point2DStr(Pt:TPoint2D):String;
begin
  Result:='X: '+FloatToStrF(Pt.X,ffFixed,9,2)+
         ' Y: '+FloatToStrF(Pt.Y,ffFixed,9,2);
end;

procedure ShowString(Txt:String);
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    MemoFrm.Memo.Lines.Add(Txt);
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

function PointsSame(P1,P2:TPoint3D):Boolean;
begin
  Result:=(P1.X=P2.X) and (P1.Y=P2.Y) and (P1.Z=P2.Z);
end;

function TwoDigitIntStr(I:Integer):String;
begin
  if I<10 then Result:='0'+IntToStr(I)
  else Result:=IntToStr(I);
end;

function ThreeDigitIntStr(I:Integer):String;
begin
  if I<10 then Result:='00'+IntToStr(I)
  else if I<100 then Result:='0'+IntToStr(I)
  else Result:=IntToStr(I);
end;

function FourDigitIntStr(I:Integer):String;
begin
  if I<10 then Result:='000'+IntToStr(I)
  else if I<100 then Result:='00'+IntToStr(I)
  else if I<1000 then Result:='0'+IntToStr(I)
  else Result:=IntToStr(I);
end;

function RandomSingle(Min,Max:Single):Single;
begin
  Result:=Min+Random(Round((Max-Min)*1000000))/1000000;
end;

function GetIPAddress:String;
type
  PDWord = ^DWord;
var
  WSAData : TWSAData;
  HostEnt : PHostEnt;
  InAddr  : TInAddr;
  NameBuf : array[0..255] of AnsiChar;
  Count,I : SmallInt;
  DataPtr : PPAnsiChar;
begin
  if WSAStartup($101,WSAData)<>0 then Result:='No IP Address'
  else Begin
    GetHostName(NameBuf,SizeOf(NameBuf));
    HostEnt:=GetHostByName(NameBuf);

    Count:=HostEnt^.H_Length;
    if Count>2 then Count:=2;
    Count:=1;
    DataPtr:=System.PPAnsiChar(HostEnt^.H_Addr_List);
    Result:='';
    for I:=1 to Count do begin
      InAddr.S_Addr:=Integer(PDWord(DataPtr^)^);
      if Result='' then Result:=Inet_ntoa(InAddr)
      else Result:=Result+', '+Inet_ntoa(InAddr);
      Inc(DataPtr);
    end;
  end;
  WSACleanup;
end;

end.

function RandomSingle(Min,Max:Single):Single;
begin
  Result:=Min+Random(Round((Max-Min)*100))/100;
end;

end.
