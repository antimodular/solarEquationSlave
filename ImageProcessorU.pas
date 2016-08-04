unit ImageProcessorU;

interface

uses
  Graphics;

const
  MaxFilters = 10;

type
  TFilterType = (ftNone,ftSobel,ftBlur,ftDilate,ftTop);

  TFilter = record
    FilterType : TFilterType;
    Threshold  : Single;
    Bmp        : TBitmap;
  end;
  PFilter = ^TFilter;
  TFilterArray = array[1..MaxFilters] of TFilter;

  TImageProcessorInfo = record
    Filter   : TFilterArray;
    Filters  : Integer;
    Reserved : array[1..64] of Byte;
  end;

  TImageProcessor = class(TObject)
  private
    function  GetInfo:TImageProcessorInfo;
    procedure SetInfo(NewInfo:TImageProcessorInfo);

  public
    Filter  : TFilterArray;
    Filters : Integer;

    constructor Create;
    destructor  Destroy;

    property Info : TImageProcessorInfo read GetInfo write SetInfo;

    procedure PrepareForShow;

    procedure AddFilter;
    procedure DeleteFilter(I: Integer);
    procedure Update(InBmp, OutBmp: TBitmap);
  end;

var
  ImageProcessor : TImageProcessor;

function DefaultImageProcessorInfo:TImageProcessorInfo;

implementation

uses
  CloudU, BmpUtils;

function DefaultImageProcessorInfo:TImageProcessorInfo;
begin
  FillChar(Result,SizeOf(Result),0);
end;

constructor TImageProcessor.Create;
var
  I : Integer;
begin
  for I:=1 to MaxFilters do begin
    Filter[I].Bmp:=TBitmap.Create;
    Filter[I].Bmp.PixelFormat:=pf24Bit;
  end;
end;

destructor TImageProcessor.Destroy;
var
  I : Integer;
begin
  for I:=1 to MaxFilters do begin
    if Assigned(Filter[I].Bmp) then Filter[I].Bmp.Free;
  end;
end;

function TImageProcessor.GetInfo:TImageProcessorInfo;
begin
  Result.Filter:=Filter;
  Result.Filters:=Filters;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TImageProcessor.SetInfo(NewInfo:TImageProcessorInfo);
begin
  Filter:=NewInfo.Filter;
  Filters:=NewInfo.Filters;
  if Filters=0 then Filters:=1;
end;

procedure TImageProcessor.PrepareForShow;
var
  I : Integer;
begin
  for I:=1 to MaxFilters do begin
    Filter[I].Bmp.Width:=Cloud.GridWidth;
    Filter[I].Bmp.Height:=Cloud.GridHeight;
  end;
end;

procedure TImageProcessor.AddFilter;
begin
  if Filters<MaxFilters then Inc(Filters);
end;

procedure TImageProcessor.DeleteFilter(I:Integer);
var
  Temp : TFilter;
  F    : Integer;
begin
  if I<Filters then begin
    Temp:=Filter[I];
    for F:=I to Filters-1 do Filter[I]:=Filter[I+1];
    Filter[Filters]:=Temp;
  end;
  Dec(Filters);
end;

procedure TImageProcessor.Update(InBmp,OutBmp:TBitmap);
var
  F       : Integer;
  SrcBmp  : TBitmap;
  DestBmp : TBitmap;
begin
  for F:=1 to Filters do begin
    if F=1 then SrcBmp:=InBmp
    else SrcBmp:=Filter[F-1].Bmp;

    if F=Filters then DestBmp:=OutBmp
    else DestBmp:=Filter[F].Bmp;

    Case Filter[F].FilterType of
      ftNone   : OutBmp.Canvas.Draw(0,0,InBmp);
      ftSobel  : DrawSobelBmp(SrcBmp,DestBmp,Round(Filter[F].Threshold));
      ftBlur   : DrawSmoothBmp(SrcBmp,DestBmp);
      ftDilate : DilateBmp3x3(SrcBmp,DestBmp,Simple3x3Element);
    end;
  end;
end;

end.
