unit BackGndFind;

interface

uses
  Global, Routines, SysUtils, Windows, Graphics;

type
  TSubtractMethod = (smBrighter,smDarker,smAbsolute);

  TBackGndFinderInfo = record
    Threshold          : Integer;
    MaxCount           : Integer;
    Enabled            : Boolean;
    MinTime            : DWord;
    UpdateFullImage    : Boolean;
    MaxStaticTime      : DWord;
    FullImageThreshold : Integer;
    SubtractMethod     : TSubtractMethod;
    Reserved           : array[1..9] of Byte;
  end;

// background means the pixel is < threshold and is considered part of the backgnd
// trigger means the pixel was > threshold last frame and is being monitored to
// see if it remains > threshold for a long enough period of time
// if it does it will be considered changed
// the pixel will go back to being part of the background if it remains within
// it's changed value for long enough
  TPixelState = (psBackGnd,psTriggered,psChanged);

  TBgfPixel = record
    State       : TPixelState;
    TriggerTime : DWord;
    ChangeTime  : DWord;
    ChangeValue : Integer;
  end;

  TBgfPixelArray = array[0..MaxImageW-1,0..MaxImageH-1] of TBgfPixel;

  TBackGndFinder = class(TObject)
  private
    function  GetInfo : TBackGndFinderInfo;
    procedure SetInfo(NewInfo:TBackGndFinderInfo);
    function  BackGndFileName: String;

  public
    Tag : Integer;

    BackGndBmp    : TBitmap;
    SubtractedBmp : TBitmap;

    BackGndChanged : Boolean;

    Enabled     : Boolean;
    Threshold   : Integer;
    MaxCount    : Integer;
    MinTime     : DWord;

    Pixel : TBgfPixelArray;

    LastStaticTime : DWord;

    UpdateFullImage     : Boolean;
    MaxStaticTime       : DWord;
    FullImageThreshold  : Integer;
    FullImageBackGndAvg : Single;

    SubtractMethod : TSubtractMethod;

    property Info : TBackGndFinderInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure SetBackGndBmp(Bmp:TBitmap);

    procedure InitPixels;
    procedure InitForTracking;

    procedure DrawSubtractedBmp(Bmp:TBitmap);

    procedure ShowAutoBackGndChangingPixels(Bmp:TBitmap);
    procedure ShowPixelsAboveAutoBackGndThreshold(Bmp:TBitmap);

    procedure ShowPixelStates(Bmp:TBitmap);

    procedure LoadBackGndBmp;
    procedure SaveBackGndBmp;
    procedure UpdateAutoBackGnd(Bmp:TBitmap);
    procedure UpdateFullImageBackGndCheck;
    procedure UpdateWithBmp(Bmp:TBitmap);

    procedure Update(Bmp:TBitmap);
    procedure TakeReferenceImage;
  end;

var
  BackGndFinder : TBackGndFinder;

function DefaultBackGndFinderInfo:TBackGndFinderInfo;

implementation

uses
  BmpUtils, CameraU, Math2D, BlobFindU;

function DefaultBackGndFinderInfo:TBackGndFinderInfo;
begin
  with Result do begin
    Enabled:=False;
    Threshold:=50;
    MaxCount:=30;  // not used
    MinTime:=120000;
    UpdateFullImage:=True;
    MaxStaticTime:=90000;
    FullImageThreshold:=5;
    SubtractMethod:=smAbsolute;
    FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
  end;
end;

constructor TBackGndFinder.Create;
begin
  inherited Create;
  BackGndBmp:=CreateImageBmp;
  LoadBackGndBmp;
  SubtractedBmp:=CreateImageBmp;
  ClearBmp(SubtractedBmp,clBlack);
  BackGndChanged:=False;
end;

destructor TBackGndFinder.Destroy;
begin
  SaveBackGndBmp;
  if Assigned(BackGndBmp) then BackGndBmp.Free;
  if Assigned(SubtractedBmp) then SubtractedBmp.Free;
  inherited;
end;

function TBackGndFinder.GetInfo:TBackGndFinderInfo;
begin
  Result.Enabled:=Enabled;
  Result.Threshold:=Threshold;
  Result.MaxCount:=MaxCount;
  Result.MinTime:=MinTime;
  Result.UpdateFullImage:=UpdateFullImage;
  Result.MaxStaticTime:=MaxStaticTime;
  Result.FullImageThreshold:=FullImageThreshold;
  Result.SubtractMethod:=SubtractMethod;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TBackGndFinder.SetInfo(NewInfo:TBackGndFinderInfo);
begin
  Enabled:=NewInfo.Enabled;
  Threshold:=NewInfo.Threshold;
  MaxCount:=NewInfo.MaxCount;
  MinTime:=NewInfo.MinTime;
  if MinTime=0 then MinTime:=1;
  UpdateFullImage:=NewInfo.UpdateFullImage;
  MaxStaticTime:=NewInfo.MaxStaticTime;
  FullImageThreshold:=NewInfo.FullImageThreshold;
  SubtractMethod:=NewInfo.SubtractMethod;
end;

function TBackGndFinder.BackGndFileName:String;
begin
  Result:=Path+'Camera.bmp';
end;

procedure TBackGndFinder.LoadBackGndBmp;
var
  FileName : String;
begin
  FileName:=BackGndFileName;
  if FileExists(FileName) then BackGndBmp.LoadFromFile(Path+'Camera.bmp')
  else ClearBmp(BackGndBmp,clBlack);

  BackGndBmp.Width:=MaxImageW;
  BackGndBmp.Height:=MaxImageH;
  BackGndBmp.PixelFormat:=pf24Bit;
end;

procedure TBackGndFinder.SaveBackGndBmp;
begin
  BackGndBmp.SaveToFile(BackGndFileName);
end;

procedure TBackGndFinder.InitPixels;
var
  X,Y  : Integer;
begin
  for X:=0 to MaxImageW-1 do for Y:=0 to MaxImageH-1 do begin
    Pixel[X,Y].State:=psBackGnd;
  end;
end;

procedure TBackGndFinder.InitForTracking;
begin
  InitPixels;
  LastStaticTime:=GetTickCount;
end;

procedure TBackGndFinder.SetBackGndBmp(Bmp:TBitmap);
begin
  BackGndBmp.Canvas.Draw(0,0,Bmp);
  InitPixels;
  BackGndChanged:=True;
end;

procedure TBackGndFinder.DrawSubtractedBmp(Bmp:TBitmap);
begin
  Case SubtractMethod of
    smBrighter : SubtractBmpAsm(Bmp,BackGndBmp,SubtractedBmp);
    smDarker   : SubtractBmpAsm(BackGndBmp,Bmp,SubtractedBmp);
    smAbsolute : SubtractBmpAsmAbs(Bmp,BackGndBmp,SubtractedBmp);
  end;
end;

procedure TBackGndFinder.ShowPixelsAboveAutoBackGndThreshold(Bmp:TBitmap);
var
  X,Y,I,Bpp : Integer;
  TestLine  : PByteArray;
  DrawLine  : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  ClearBmp(Bmp,clBlack);
  for Y:=0 to Bmp.Height-1 do begin
    TestLine:=SubtractedBmp.ScanLine[Y];
    DrawLine:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*Bpp;
      if TestLine^[I]>Threshold then DrawLine^[I+2]:=255;
    end;
  end;
end;

procedure TBackGndFinder.ShowAutoBackGndChangingPixels(Bmp:TBitmap);
var
  X,Y,I,Bpp     : Integer;
  Line,DrawLine : PByteArray;
begin
  Bpp:=BytesPerPixel(Bmp);
  for Y:=0 to Bmp.Height-1 do begin
    Line:=SubtractedBmp.ScanLine[Y];
    DrawLine:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      I:=X*Bpp;
      if Line^[I]>Threshold then begin
        DrawLine^[I+0]:=255;
        DrawLine^[I+1]:=0;
        DrawLine^[I+2]:=0;
      end;
    end;
  end;
end;

procedure TBackGndFinder.UpdateWithBmp(Bmp:TBitmap);
var
  X,Y  : Integer;
  Line : PByteArray;
begin
  for Y:=0 to Bmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do begin
      if Line^[X*3]>0 then Pixel[X,Y].State:=psTriggered
      else Pixel[X,Y].State:=psBackGnd;
    end;
  end;
end;

procedure TBackGndFinder.ShowPixelStates(Bmp:TBitmap);
var
  X,Y,I,D          : Integer;
  Time,ElapsedTime : DWord;
  Line,BackGndLine : PByteArray;
begin
  Time:=GetTickCount;
  for Y:=0 to SubtractedBmp.Height-1 do begin
    Line:=Bmp.ScanLine[Y];
    BackGndLine:=BackGndBmp.ScanLine[Y];
    for X:=0 to SubtractedBmp.Width-1 do with Pixel[X,Y] do begin
      I:=X*3;
      Case State of
        psBackGnd : ;//Move(BackGndLine^[I],Line^[I],3);

// red means triggered
        psTriggered :
          begin
            ElapsedTime:=Time-TriggerTime;
            D:=Round(255*ElapsedTime/MinTime);
            if D>255 then D:=255;
            Line^[I+0]:=0;
            Line^[I+1]:=0;
            Line^[I+2]:=D;
          end;

// green means changed
        psChanged :
          begin
            ElapsedTime:=Time-ChangeTime;
            D:=Round(255*ElapsedTime/MinTime);
            if D>255 then D:=255;
            Line^[I+0]:=D;
            Line^[I+1]:=0;
            Line^[I+2]:=0;
          end;
      end;
    end;
  end;
end;

procedure TBackGndFinder.Update(Bmp:TBitmap);
begin
  DrawSubtractedBmp(Bmp);
//  UpdateAutoBackGnd(Bmp);
end;

procedure TBackGndFinder.UpdateAutoBackGnd(Bmp:TBitmap);
var
  Time           : DWord;
  X,Y,I          : Integer;
  CurrentLine    : PByteArray;
  SubtractedLine : PByteArray;
  BackGndLine    : PByteArray;
begin
  Time:=GetTickCount;
  for Y:=0 to Bmp.Height-1 do begin
    CurrentLine:=Bmp.ScanLine[Y];
    SubtractedLine:=SubtractedBmp.ScanLine[Y];
    BackGndLine:=BackGndBmp.ScanLine[Y];
    for X:=0 to Bmp.Width-1 do with Pixel[X,Y] do begin
      I:=X*3;
      Case State of

// if this pixel is considered part of the background, see if it's now above
// the threshold
        psBackGnd :
          if SubtractedLine^[I]>=Threshold then begin
            State:=psTriggered;
            TriggerTime:=Time;
          end;

// if this pixel is triggered, mark it as background if it's fallen below the
// threshold - if it's still above see if enough time has passed
        psTriggered :
          if SubtractedLine^[I]<Threshold then State:=psBackGnd
          else if (Time-TriggerTime)>=MinTime then begin
            State:=psChanged;
            ChangeValue:=CurrentLine^[I];
            ChangeTime:=Time;
          end;

// if this pixel is changed, see if it's still changing
        psChanged :
          if (CurrentLine^[I]-ChangeValue)>Threshold then begin
            ChangeValue:=CurrentLine^[I];
            ChangeTime:=Time;
          end

// if needs to be stable for at least min time before we update the reference
          else if (Time-ChangeTime)>=MinTime then begin
            State:=psBackGnd;
            BackGndLine^[I+0]:=CurrentLine^[I+0];
            BackGndLine^[I+1]:=CurrentLine^[I+1];
            BackGndLine^[I+2]:=CurrentLine^[I+2];
          end;
      end;
    end;
  end;
end;

procedure TBackGndFinder.UpdateFullImageBackGndCheck;
var
  Time : DWord;
begin
  Time:=GetTickCount;

// if there's too much action, reset the clock
  if FullImageBackGndAvg>=FullImageThreshold then LastStaticTime:=Time

// if enough time has past, take the backgnd
  else if (Time-LastStaticTime)>MaxStaticTime then begin
    SetBackGndBmp(Camera.Bmp);
    LastStaticTime:=Time;
  end;
end;

procedure TBackGndFinder.TakeReferenceImage;
begin
  BackGndBmp.Canvas.Draw(0,0,Camera.Bmp);
  BackGndBmp.SaveToFile(BackGndFileName);
end;

end.

