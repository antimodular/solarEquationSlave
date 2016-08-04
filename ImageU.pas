unit ImageU;

interface

uses
  Ipl, OpenCV_CV, Windows, Graphics, Global, OpenCV;

type
  TPixelData = array[1..High(Integer)] of Byte;
  PPixelData = ^TPixelData;

  TImageIPL = class(TObject)
  private
    function  GetPixel(X,Y:Integer):Byte;
    procedure SetPixel(X,Y:Integer;Value:Byte);

  public
    IplImage : PIplImage;

    property Pixel[X,Y:Integer]:Byte read GetPixel write SetPixel;

    constructor Create;
    destructor  Destroy; override;

    procedure FreeIplImage;

// load routines
    procedure LoadJpg(FileName:String);
    procedure LoadBmp(FileName:String);
    procedure Load(FileName:String);

// save routines
    procedure SaveBmp(FileName:String);

// read routines
    procedure CopyFromBmp(Bmp:TBitmap);
    procedure CopyFromImage(SrcImage:TImageIpl);

// write routines
    procedure DrawOnBmp(Bmp:TBitmap);

    procedure ShowFileNotFoundMsg(FileName:String);
    procedure CreateIplImage(W,H:Integer);
    function  CreateIplImageFromDefaultHeader(W,H:Integer):PIplImage;
    function  PixelXYToDataIndex(X,Y:Integer):Integer;
  end;

implementation

uses
  Jpeg, SysUtils, Dialogs, BmpUtils;//, CameraU;

constructor TImageIPL.Create;
begin
  inherited;
//  CreateIplImage(MaxImageW,MaxImageH);
end;

destructor TImageIPL.Destroy;
begin
  FreeIplImage;
  inherited;
end;

procedure TImageIPL.CreateIplImage(W,H:Integer);
begin
  iplImage:=CreateIplImageFromDefaultHeader(W,H);
end;

procedure TImageIPL.FreeIplImage;
begin
  if Assigned(IplImage) then begin
    iplDeallocate(IplImage,IPL_IMAGE_HEADER or IPL_IMAGE_DATA);
  end;
end;

function TImageIPL.CreateIplImageFromDefaultHeader(W,H:Integer):PIplImage;
begin
// create an IPL image from this header
  Result:=iplCreateImageHeader(
    1,                    // number of channels
    0,                    // no alpha channel
    IPL_DEPTH_8U,         // data of byte type
    'RGB',                // color model
    'BGR',                // color order
    IPL_DATA_ORDER_PIXEL, // channel arrangement
    IPL_ORIGIN_TL,        // top left orientation
    IPL_ALIGN_DWORD,      // 8 bytes align
    W,                    // image width
    H,                    // image height
    nil,                  // no ROI
    nil,                  // no mask ROI
    nil,                  // no image ID
    nil);                 // not tiled

// allocate storage for the data
  iplAllocateImage(Result,0,0);
end;

procedure TImageIPL.CopyFromBmp(Bmp:TBitmap);
var
  Size    : Integer;
  I,X,Y   : Integer;
  DestPtr : PPixelData;
  Line    : PByteArray;
begin
// start fresh
  FreeIplImage;

// create the iplImage
  iplImage:=CreateIplImageFromDefaultHeader(Bmp.Width,Bmp.Height);

// copy the data over
  Size:=IplImage^.ImageSize;
  DestPtr:=PPixelData(IplImage^.ImageData);
  I:=0; X:=0; Y:=0;
  Line:=Bmp.ScanLine[Y];
  repeat
    Inc(I);
    DestPtr^[I]:=(Line^[X*3+0]+Line^[X*3+1]+Line^[X*3+2]) div 3;
    if X<(Bmp.Width-1) then Inc(X)
    else begin
      X:=0;
      Inc(Y);
      if Y<Bmp.Height then Line:=Bmp.ScanLine[Y];
    end;
  until (I=Size);
end;

procedure TImageIPL.LoadJpg(FileName:String);
var
  Jpg : TJpegImage;
  Bmp : TBitmap;
begin
  if FileExists(FileName) then begin
    Jpg:=TJpegImage.Create;
    Bmp:=TBitmap.Create;
    try
      Jpg.LoadFromFile(FileName);
      Bmp.Assign(Jpg);
      CopyFromBmp(Bmp);
    finally
      Jpg.Free;
      Bmp.Free;
    end;
  end
  else ShowFileNotFoundMsg(FileName);
end;

procedure TImageIPL.LoadBmp(FileName:String);
var
  Bmp : TBitmap;
begin
  if FileExists(FileName) then begin
    Bmp:=TBitmap.Create;
    try
      Bmp.LoadFromFile(FileName);
      CopyFromBmp(Bmp);
    finally
      Bmp.Free;
    end;
  end
  else ShowFileNotFoundMsg(FileName);
end;

procedure TImageIPL.Load(FileName:String);
var
  Ext : String;
begin
  Ext:=UpperCase(ExtractFileExt(FileName));
  if Ext='.JPG' then LoadJpg(FileName)
  else if Ext='.BMP' then LoadBmp(FileName)
  else begin
    ShowMessage('Invalid file name "'+FileName+
                '" : File extension must be "JPG" or "BMP"');
  end;
end;

procedure TImageIPL.DrawOnBmp(Bmp:TBitmap);
var
  Size,X,Y : Integer;
  Index,I  : Integer;
  SrcPtr   : PPixelData;
  Line     : PByteArray;
begin
  Bmp.Width:=IplImage^.Width;
  Bmp.Height:=IplImage^.Height;
  Bmp.PixelFormat:=pf24Bit;
  Size:=IplImage^.ImageSize;
  X:=0; Y:=0; //Bmp.Height-1;
  Index:=1;
  Line:=Bmp.ScanLine[Y];
  SrcPtr:=PPixelData(IplImage^.ImageData);
  repeat
    I:=X*3;
    Line^[I+0]:=SrcPtr^[Index];
    Line^[I+1]:=SrcPtr^[Index];
    Line^[I+2]:=SrcPtr^[Index];
    if X<Bmp.Width-1 then Inc(X)
    else begin
      X:=0;
      if Y<Bmp.Height-1 then begin
        Inc(Y);
        Line:=Bmp.ScanLine[Y];
      end;  
    end;
    Inc(Index);
  until (Index=Size);
end;

procedure TImageIPL.ShowFileNotFoundMsg(FileName:String);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.Width:=320;
    Bmp.Height:=240;
    Bmp.PixelFormat:=pf24Bit;
    ClearBmp(Bmp,clTeal);
    Bmp.Canvas.Brush.Color:=clTeal;
    DrawTextOnBmp(Bmp,FileName+' not found');
    CopyFromBmp(Bmp);
  finally
    Bmp.Free;
  end;
end;

procedure TImageIpl.CopyFromImage(SrcImage:TImageIpl);
var
  Size    : Integer;
  SrcPtr  : PPixelData;
  DestPtr : PPixelData;
begin
  IplImage:=CreateIplImageFromDefaultHeader(SrcImage.IplImage.Width,SrcImage.IplImage.Height);
  Size:=IplImage^.ImageSize;

// copy the data over
  SrcPtr:=PPixelData(SrcImage.IplImage^.ImageData);
  DestPtr:=PPixelData(IplImage^.ImageData);
  Move(SrcPtr^,DestPtr^,Size);
end;

procedure TImageIpl.SaveBmp(FileName:String);
var
  Bmp : TBitmap;
begin
  Bmp:=TBitmap.Create;
  try
    DrawOnBmp(Bmp);
    Bmp.SaveToFile(FileName);
  finally
    Bmp.Free;
  end;
end;

function TImageIpl.GetPixel(X,Y:Integer):Byte;
var
  I : Integer;
begin
  if Assigned(IplImage) and (X<IplImage^.Width) and (Y<IplImage^.Height) then
  begin
    I:=PixelXYToDataIndex(X,Y);
    Result:=PPixelData(IplImage^.ImageData)[I];
  end
  else Result:=0;
end;

procedure TImageIpl.SetPixel(X,Y:Integer;Value:Byte);
var
  I : Integer;
begin
  if Assigned(IplImage) and (X<IplImage^.Width) and (Y<IplImage^.Height) then
  begin
    I:=PixelXYToDataIndex(X,Y);
    PPixelData(IplImage^.ImageData)[I]:=Value;
  end;
end;

function TImageIpl.PixelXYToDataIndex(X,Y:Integer):Integer;
begin
  Result:=1+Y*IplImage^.Width+X;
end;

end.




