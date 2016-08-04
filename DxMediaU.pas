unit DxMediaU;

interface

uses
  Windows, DirectDraw, DirectShow9, Graphics, Classes, Global;

type
  TDxPlayerInfo = record
    FileName : TFileName;
    Reserved : array[1..256] of Byte;
  end;

  TDxMediaPlayer = class(TObject)
  private
    DDraw            : IDirectDraw;
    AMStream         : IAMMultiMediaStream;
    MMStream         : IMultiMediaStream;
    PrimaryVidStream : IMediaStream;
    DDStream         : IDirectDrawMediaStream;
    Sample           : IDirectDrawStreamSample;
    DDSurface        : IDirectDrawSurface;
    MediaSeeking     : IMediaSeeking;
    MediaPosition    : IMediaPosition;
    DesiredSurface   : TDDSurfaceDesc;

    procedure DrawBmpOverlay;

    function GetInfo:TDxPlayerInfo;
    procedure SetInfo(NewInfo:TDxPlayerInfo);

  public
    OnUpdate  : TNotifyEvent;
    TotalTime : Stream_Time;
    Async     : Boolean;
    HasClock  : Boolean;
    CanSeek   : Boolean;
    Bmp       : TBitmap;
    Running   : Boolean;
    FileName  : String;
    FileLoaded : Boolean;

    property Info : TDxPlayerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure ShutDown;
    function  AbleToLoadFile(iFileName:String):Boolean;
    procedure Update;

    procedure Run;
    procedure Stop;
    procedure Seek(Time:Stream_Time);
    procedure ScaleBmp(W,H:Integer);
  end;

var
  Player : TDxMediaPlayer;

function DefaultDxPlayerInfo:TDxPlayerInfo;

implementation

uses
  Dialogs, ActiveX, ComObj, Forms;

function DefaultDxPlayerInfo:TDxPlayerInfo;
begin
  Result.FileName:='';
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

constructor TDxMediaPlayer.Create;
var
  HR : HResult;
begin
  inherited;
  OnUpdate:=nil;
  Running:=False;
  FileLoaded:=False;
  Bmp:=TBitmap.Create;
  Bmp.PixelFormat:=pf24Bit;
  HR:=DirectDrawCreate(nil,DDraw,nil);
  if HR=S_OK then begin
    DDraw.SetCooperativeLevel(GetDesktopWindow(), DDSCL_NORMAL);
  end
  else ShowMessage('Error getting Direct Draw interface');
end;

destructor TDxMediaPlayer.Destroy;
begin
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TDxMediaPlayer.ShutDown;
begin
  Stop;
  AMStream:=nil;
  MMStream:=nil;
  PrimaryVidStream:=nil;
  DDStream:=nil;
  Sample:=nil;
  DDSurface:=nil;
  DDraw:=nil;
end;

function TDxMediaPlayer.GetInfo:TDxPlayerInfo;
begin
  Result.FileName:=FileName;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TDxMediaPlayer.SetInfo(NewInfo:TDxPlayerInfo);
begin
  FileName:=NewInfo.FileName;
end;

function TDxMediaPlayer.AbleToLoadFile(iFileName:String):Boolean;
var
  HR         : HResult;
  State      : Stream_State;
  StreamType : Stream_Type;
  Flags      : DWord;
begin
  FileName:=iFileName;

  try
// create the AMStream
    AMStream:=IAMMultiMediaStream(CreateComObject(CLSID_AMMultiMediaStream));

// initialize the stream for reading
    HR:=AMStream.Initialize(STREAMTYPE_READ,0,nil);

// add a video Media Stream to the filter graph
    HR:=AMStream.AddMediaStream(DDraw,@MSPID_PrimaryVideo,0,IMediaStream(nil^));

// add an Audio stream to the filter graph with default
// handling so we don't have to deal with the audio ourselves.
    try
    HR:=AMStream.AddMediaStream(nil,@MSPID_PrimaryAudio,AMMSF_ADDDEFAULTRENDERER,
                               IMediaStream(nil^));
    except
    end;

// add the file to the graph
    HR:=AMStream.OpenFile(PWideChar(WideString(FileName)),0);
    if HR<>S_OK then begin
      Result:=False;
      Exit;
    end;
    MMStream:=AMStream as IMultiMediaStream;
    MMStream.GetDuration(TotalTime);
    MMStream.GetInformation(@Flags,nil);

    Async:=(Flags and MMSSF_ASYNCHRONOUS)>0;
    HasClock:=(Flags and MMSSF_HASCLOCK)>0;
    CanSeek:=(Flags and MMSSF_SUPPORTSEEK)>0;

// Get an IMediaStream
    HR:=MMStream.GetMediaStream(MSPID_PrimaryVideo, PrimaryVidStream);

// QueryInterface on the IMediaStream for a IDirectDrawMediaStream
    DDStream:=PrimaryVidStream as IDirectDrawMediaStream;

// Set up our parameters for the GetFormat call coming up
    ZeroMemory(@DesiredSurface, SizeOf(DesiredSurface));
    DesiredSurface.dwSize:=Sizeof(DesiredSurface);

// Use IDirectDrawMediaStream.GetFormat to get a surface description of the media
    HR:=DDStream.GetFormat(TDDSurfaceDesc(nil^),IDirectDrawPalette(nil^),
                           DesiredSurface,DWord(nil^));

    Bmp.PixelFormat:=pf32bit;
    Bmp.Width:=DesiredSurface.dwWidth;
    Bmp.Height:=DesiredSurface.dwHeight;

// Set up Caps to create surface in system memory rather than video memory
    DesiredSurface.ddsCaps.dwCaps:=DesiredSurface.ddsCaps.dwCaps or
                                   DDSCAPS_OFFSCREENPLAIN or DDSCAPS_SYSTEMMEMORY;

// Set the flags to show that we are holding valid Caps and PixelFormat data
    DesiredSurface.dwFlags:=DesiredSurface.dwFlags or DDSD_CAPS or DDSD_PIXELFORMAT;

// Use our DirectDraw interface to create the surface described by Desired Surface
    HR:=DDraw.CreateSurface(DesiredSurface, DDSurface, nil);

// Get an ISample interface from the DirectDrawMediaStream for our surface
    HR:=DDStream.CreateSample(DDSurface, TRect(nil^), 0, Sample);
    Result:=True;
  except
    Result:=False;
  end;
  FileLoaded:=Result;
end;

procedure TDxMediaPlayer.DrawBmpOverlay;
var
  X,XSize : Integer;
  Y,YSize : Integer;
begin
// show the paused icon
  if not Running then with Bmp.Canvas do begin
    Brush.Color:=clPurple;
    Pen.Color:=clBlack;
    XSize:=Bmp.Width div 40;
    YSize:=XSize*5;
    X:=YSize;
    Y:=Bmp.Height-YSize*2;
    Rectangle(X, Y, X+XSize, Y+YSize);
    X:=X+XSize*2;
    Rectangle(X, Y, X+XSize, Y+YSize);
  end;
end;

procedure TDxMediaPlayer.Update;
var
  SurfaceDC : HDC;
begin
// Sample.Update renders one frame at a time to DDSurface.
  if Sample.Update(0,0,nil,0)=S_OK then begin

// get a GDI compatible device context from the surface
    DDSurface.GetDC(SurfaceDC);
    try
      Bmp.PixelFormat:=pf32bit;

// Blit memory DC to our bmp
      StretchBlt(Bmp.Canvas.Handle,0,0,Bmp.Width,Bmp.Height,SurfaceDC,0,0,
                 DesiredSurface.dwWidth,DesiredSurface.dwHeight,SRCCOPY);
      DrawBmpOverlay();
      if Assigned(OnUpdate) then OnUpdate(Self);
    finally
      DDSurface.ReleaseDC(SurfaceDC);
    end;
  end;
end;

procedure TDxMediaPlayer.Run;
begin
  if FileLoaded then begin
    MMStream.SetState(STREAMSTATE_RUN);
    Running:=True;
  end;  
end;

procedure TDxMediaPlayer.Stop;
begin
  if Assigned(MMStream) then MMStream.SetState(STREAMSTATE_STOP);
  Running:=False;
  DrawBmpOverlay;
//  if Assigned(OnUpdate) then OnUpdate(Self);
end;

procedure TDxMediaPlayer.Seek(Time:Stream_Time);
begin
  MMStream.Seek(Time);
end;

procedure TDxMediaPlayer.ScaleBmp(W,H:Integer);
var
  XScale,YScale: Single;
begin
  XScale:=W/DesiredSurface.dwWidth;
  YScale:=H/DesiredSurface.dwHeight;
  if XScale<YScale then begin
    Bmp.Width:=W;
    Bmp.Height:=Round(XScale*DesiredSurface.dwHeight);
  end
  else begin
    Bmp.Width:=Round(YScale*DesiredSurface.dwWidth);
    Bmp.Height:=H;
  end;
end;

end.


