unit MediaU;

interface

type
  TMediaPlayer = class(TObject);
  private
    AMStream         : IAMMultiMediaStream;
    MMStream         : IMultiMediaStream;
    PrimaryVidStream : IMediaStream;
    DDStream         : IDirectDrawMediaStream;
    Sample           : IDirectDrawStreamSample;
    DDSurface        : IDirectDrawSurface;
    SurfaceDC        : HDC;
    Time,TotalTime   : TStream_Time;
    State            : TStream_State;
    StreamType       : TStream_Type;
    Flags            : DWord;

  public
    TotalTime : Integer;
    Async     : Boolean;
    HasClock  : Boolean;
    CanSeek   : Boolean;
    Bmp       : TBitmap;
    Running   : Boolean;

    constructor Create;
    destructor  Destroy; override;

    procedure ShutDown;
    procedure LoadFile(FileName:String);
    procedure Update;

    procedure Start;
    procedure Stop;
  end;

implementation

constructor TMediaPlayer.Create;
begin
  inherited;
  Running:=False;
  Bmp:=TBitmap.Create;
  Bmp.PixelFormat:=pf24Bit;
end;

destructor TMediaPlayer.Destroy;
begin
  if Assigned(Bmp) then Bmp.Free;
end;

procedure TMediaPlayer.ShutDown;
begin
  AMStream:=nil;
  MMStream:=nil;
  PrimaryVidStream:=nil;
  DDStream:=nil;
  Sample:=nil;
  DDSurface:=nil;
end;

procedure TMediaPlayer.LoadFile(FileName:String);
var
  DesiredSurface : TDDSurfaceDesc;
begin
  try
// create the AMStream
    AMStream:=IAMMultiMediaStream(CreateComObject(CLSID_AMMultiMediaStream));

// initialize the stream for reading
    OleCheck(AMStream.Initialize(STREAMTYPE_READ,0,nil));

// add a video Media Stream to the filter graph
    OleCheck(AMStream.AddMediaStream(DDraw,@MSPID_PrimaryVideo,0,IMediaStream(nil^)));

// add an Audio stream to the filter graph with default
// handling so we don't have to deal with the audio ourselves.
    OleCheck(AMStream.AddMediaStream(nil, @MSPID_PrimaryAudio,
             AMMSF_ADDDEFAULTRENDERER,IMediaStream(nil^)));

// add the file to the graph
    OleCheck(AMStream.OpenFile(PWideChar(FileName),0));

    MMStream:=AMStream as IMultiMediaStream;
    MMStream.GetDuration(TotalTime);
    MMStream.GetInformation(@Flags,nil);

    Async:=(Flags and MMSSF_ASYNCHRONOUS)>0;
    HasClock:=(Flags and MMSSF_HASCLOCK)>0;
    CanSeek:=(Flags and MMSSF_SUPPORTSEEK)>0;

// Get an IMediaStream
    OleCheck(MMStream.GetMediaStream(MSPID_PrimaryVideo, PrimaryVidStream));

// QueryInterface on the IMediaStream for a IDirectDrawMediaStream
    DDStream:=PrimaryVidStream as IDirectDrawMediaStream;

// Set up our parameters for the GetFormat call coming up
    ZeroMemory(@DesiredSurface, SizeOf(DesiredSurface));
    DesiredSurface.dwSize:=Sizeof(DesiredSurface);

// Use IDirectDrawMediaStream.GetFormat to get a surface description of the media
    OleCheck(DDStream.GetFormat(TDDSurfaceDesc(nil^),IDirectDrawPalette(nil^),
             DesiredSurface,DWord(nil^)));

// Set up Caps to create surface in system memory rather than video memory
    DesiredSurface.ddsCaps.dwCaps:=DesiredSurface.ddsCaps.dwCaps or
                                   DDSCAPS_OFFSCREENPLAIN or DDSCAPS_SYSTEMMEMORY;

//Set the flags to show that we are holding valid Caps and PixelFormat data
    DesiredSurface.dwFlags:=DesiredSurface.dwFlags or DDSD_CAPS or DDSD_PIXELFORMAT;

//Use our DirectDraw interface to create the surface described by Desired Surface
    OleCheck(DDraw.CreateSurface(DesiredSurface, DDSurface, nil));

//Get an ISample interface from the DirectDrawMediaStream for our surface
    OleCheck(DDStream.CreateSample(DDSurface, TRect(nil^), 0, Sample));

//Set the stream state to Run
    OleCheck(MMStream.SetState(STREAMSTATE_RUN));
    Running:=True;
  except
    ShowMessage('Error opening file');
  end;
end;

procedure TMediaPlayer.Update;
begin
// Sample.Update renders one frame at a time to DDSurface.
  if Sample.Update(0,0,nil,0)=S_OK then begin

// get a GDI compatible device context from the surface
    DDSurface.GetDC(SurfaceDC);
    try

// Blit memory DC to our forms client area DC
      StretchBlt(Bmp.Canvas.Handle,0,0,ClientWidth,ClientHeight,SurfaceDC,0,0,
                 DesiredSurface.dwWidth,DesiredSurface.dwHeight,SRCCOPY);
    finally
      DDSurface.ReleaseDC(SurfaceDC);
    end;
  end;
end;

procedure TMediaPlayer.Start;
begin
  MMStream.SetState(STREAMSTATE_START);
end;

procedure TMediaPlayer.Stop;
begin
  MMStream.SetState(STREAMSTATE_STOP);
end;

procedure TMediaPlayer.Seek;
begin


    Caption:='Done!';

  finally
    VideoRunning:=False;


      Application.ProcessMessages;
      if ScrollBarMoved then begin
//        MMStream.SetState(STREAMSTATE_STOP);
//        repeat
//          MMStream.GetState(State);
//        until (State=STREAMSTATE_STOP);
        if MMStream.Seek(Round(TotalTime*ScrollBar.Position/ScrollBar.Max))<>S_OK then begin
          Caption:='Can''t seek!!!';
        end;
//        if MMStream.SetState(STREAMSTATE_RUN)<>S_OK then Caption:='Stuck';
        ScrollBarMoved:=False;
      end;
    until Quit;


procedure Update;
begin
end;

end.

//---------- Create a multimedia stream and open it ----------//
  try

//Create IAMMultiMediaStream Com Object
//This interface indirectly sets up a DirectShow filter graph
//that allows multimedia streaming
    AMStream := IAMMultiMediaStream(CreateComObject(CLSID_AMMultiMediaStream));

//Initialize the Stream for reading
    OleCheck(AMStream.Initialize(STREAMTYPE_READ, 0, nil));

//Add a Video Media Stream to the filter graph
    OleCheck(AMStream.AddMediaStream(DDraw,@MSPID_PrimaryVideo,0,IMediaStream(nil^)));

// Add an Audio stream to the filter graph with default
// handling so we don't have to deal with the audio ourselves.
    try
      OleCheck(AMStream.AddMediaStream(nil, @MSPID_PrimaryAudio,
               AMMSF_ADDDEFAULTRENDERER,IMediaStream(nil^)));
    except
// Do nothing if audio not supported;
    end;

//Open a file into the graph
    OleCheck(AMStream.OpenFile(PWideChar(FileName),0));

//-------------- Get setup to Render Stream to surface-------------//

// Typecast our IAMMultiMediaStream Stream to a IMultiMediaStream
// Although the SHOWSTREAM.CPP example typecasts this directly, I chose to
// convert by a call to QueryInterface (handled by the 'as' operator)
    MMStream:=AMStream as IMultiMediaStream;
    MMStream.GetDuration(TotalTime);
    MMStream.GetInformation(@Flags,nil);

    if (Flags and MMSSF_ASYNCHRONOUS)>0 then begin
      Caption:='The stream supports asynchronous sample updates.';
    end
    else Caption:='';
    if (Flags and MMSSF_HASCLOCK)>0 then begin
      Caption:=Caption+'The stream has a clock.';
    end;
    if (Flags and MMSSF_SUPPORTSEEK)>0 then begin
      Caption:=Caption+'Can seek';
    end;

//Get an IMediaStream
    OleCheck(MMStream.GetMediaStream(MSPID_PrimaryVideo, PrimaryVidStream));

//QueryInterface on the IMediaStream for a IDirectDrawMediaStream
    DDStream:=PrimaryVidStream as IDirectDrawMediaStream;

//Set up our parameters for the GetFormat call coming up
    ZeroMemory(@DesiredSurface, SizeOf(DesiredSurface));
    DesiredSurface.dwSize:=Sizeof(DesiredSurface);

//Use IDirectDrawMediaStream.GetFormat to get a
//surface description of the media
    OleCheck(DDStream.GetFormat(TDDSurfaceDesc(nil^),IDirectDrawPalette(nil^),
             DesiredSurface,DWord(nil^)));


// Set up Caps to create surface in system memory rather than
// video memory
    DesiredSurface.ddsCaps.dwCaps:=DesiredSurface.ddsCaps.dwCaps or
                               DDSCAPS_OFFSCREENPLAIN or DDSCAPS_SYSTEMMEMORY;

//Note:  Removed DDS_OWNSDC flag - incompatible with NT

//Set the flags to show that we are holding valid Caps and PixelFormat data
    DesiredSurface.dwFlags:=DesiredSurface.dwFlags or DDSD_CAPS or DDSD_PIXELFORMAT;

//Use our DirectDraw interface to create the surface described by Desired Surface
    OleCheck(DDraw.CreateSurface(DesiredSurface, DDSurface, nil));

//-------------- Get an ISample and set stream to run-------------//
//Notes:
// For the next call to be successfull, the surface must be of the same
// height and width as the video frames, and surface must be compatible
// with one of the rendered data formats of the video stream.  If the
// surface were a primary surface in video memory, the current display
// mode would need to be the same pixel format as the rendered stream
// (I have seen some media that likes RGB24 bit and some that likes
// RGBA32 bit).

//Get an ISample interface from the DirectDrawMediaStream for our surface
    OleCheck(DDStream.CreateSample(DDSurface, TRect(nil^), 0, Sample));

//Set the stream state to Run
    OleCheck(MMStream.SetState(STREAMSTATE_RUN));

//Go into our loop to update the frames
    Quit:=False;
    ScrollBarMoved:=False;
    Bmp:=TBitmap.Create;
    Bmp.Width:=ClientWidth;
    Bmp.Height:=ClientHeight;
    Bmp.PixelFormat:=pf24Bit;
    repeat

//Sample.Update renders one frame at a time to DDSurface.
      if Sample.Update(0,0,nil,0)<>S_OK then begin
        MMStream.GetTime(Time);
        ScrollBar.Position:=Round(ScrollBar.Max*Time/TotalTime);
        Caption:=IntToStr(GetTickCount)+' !!!';// Break;
      end;

//Get a GDI compatible device context from the surface
      DDSurface.GetDC(SurfaceDC);
      try

// Blit memory DC to our forms client area DC
        StretchBlt(Bmp.Canvas.Handle,0,0,ClientWidth,ClientHeight,SurfaceDC,0,0,
                   DesiredSurface.dwWidth,DesiredSurface.dwHeight,SRCCOPY);
        Bmp.Canvas.TextOut(10,10,IntToStr(GetTickCount));
        Canvas.Draw(0,0,Bmp);
      finally
        DDSurface.ReleaseDC(SurfaceDC);
      end;
      Application.ProcessMessages;
      if ScrollBarMoved then begin
//        MMStream.SetState(STREAMSTATE_STOP);
//        repeat
//          MMStream.GetState(State);
//        until (State=STREAMSTATE_STOP);
        if MMStream.Seek(Round(TotalTime*ScrollBar.Position/ScrollBar.Max))<>S_OK then begin
          Caption:='Can''t seek!!!';
        end;
//        if MMStream.SetState(STREAMSTATE_RUN)<>S_OK then Caption:='Stuck';
        ScrollBarMoved:=False;
      end;
    until Quit;
    Bmp.Free;

//Set the stream state to stop
    MMStream.SetState(STREAMSTATE_STOP);
    Caption:='Done!';

  finally
    VideoRunning:=False;



