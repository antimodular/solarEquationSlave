unit ReactDiffuseU;

interface

uses
  Windows, SysUtils, Graphics, Dialogs, ProgramU, OpenGL1X, Global,
  OpenGLTokens, GLDraw, Protocol;

const
  DataSize = TW*TH*4*SizeOf(Single);  // RGBA

type
  TRGBAFloat = record
    R,G,B,A : Single;
  end;

  TDataArray = array[0..TW-1,0..TH-1] of TRGBAFloat;

  TDataFile = file of TDataArray;

  T2DSingleArray = array of array of Single;

  T2DArray = array[0..999,0..999] of Single;

  TReactDiffuseInfo = record
    F,K,H,Dt      : Single;
    StepsPerFrame : Integer;
    ColorDivider  : Single;
    Reserved      : array[1..60] of Byte;
  end;

  TReactDiffuse = class(TObject)
  private
    ReactDiffuseProgram : TProgram;
    Initialized         : Boolean;

    FBO     : array[0..1] of GLUInt;
    PBO     : array[0..1] of GLUInt;

    Data : TDataArray;

    RandomData : TDataArray;

    function  GetInfo:TReactDiffuseInfo;
    procedure SetInfo(NewInfo:TReactDiffuseInfo);

    procedure CreatePBOs;
    procedure FreePBOs;

    procedure CreateTextures;
    procedure FreeTextures;

    procedure CreateFBOs;
    procedure FreeFBOs;

    procedure InitLazy;
    procedure LoadProgram;
    procedure ReadDataFromTexture(I: Integer);
    procedure CopyDataToTextures;
    procedure CopyDataFromPBO(I: Integer);

    procedure AssertTexture(I: Integer);
    function  RandomFileName: String;
    procedure LoadRandomData;
    procedure SaveRandomData;
    function  AnyTouchesActive: Boolean;
    procedure UpdateControl;
    procedure CopyDataToTexture(I: Integer);
    procedure AssertControlData;
    procedure AddCircularDisturbance(X, Y, R: Integer);
    procedure AddMirroredCircularDisturbance(X, Y, R: Integer);
    function  TouchXYToTextureXY(Tx, Ty: Single): TPoint;

  public
    Tag : Integer;

    F,K,H,Dt : Single;

    Speed : Integer;

    Width  : Integer;
    Height : Integer;

    StepsPerFrame : Integer;
    ColorDivider  : Single;
    OddFrame      : Boolean;

    MakeRandom  : Boolean;
    MakeReset   : Boolean;
    MakeSquares : Boolean;

    SetRandomData : Boolean;

  //  Touch    : TTouchArray;
 //   CamTouch : TTouchArray;

    LastTouch : TTouchArray;

  //  LastCamTouch : TTouchArray;

    Texture : array[0..1] of GLUInt;    property Info:TReactDiffuseInfo read GetInfo write SetInfo;

    constructor Create(iTag:Integer);
    destructor  Destroy; override;

    procedure Reset;
    procedure Render;
    procedure DrawOnBmp(Bmp:TBitmap);
    procedure DrawOnTextureData(Data:PByte);
    procedure Update;
    procedure SetSize(iW,iH:Integer);
    procedure Disturb(X,Y:Integer);

    procedure PrepareForShow;
    procedure RenderToTexture;
    procedure BindInputTexture;
    procedure RenderToScreen2D;
    procedure RenderToScreen3D;
    procedure SyncVars;
    procedure MakeSolidColor(R,G,B:Single);
    procedure TextureQuad2D;
    procedure SelectSpots;
    procedure SelectWaves;
    procedure SelectPulsating;
    procedure SelectLabyrinth;
    procedure ApplyPodServerRD(PodServerRD: TPodServerRD);
    procedure SaveBmp;
  end;

  TReactDiffuseArray = array[1..RDLayers] of TReactDiffuse;

//var
//  ReactDiffuse : TReactDiffuseArray;

function DefaultReactDiffuseInfo:TReactDiffuseInfo;

implementation

uses
  Routines, TrackerU;

function DefaultReactDiffuseInfo:TReactDiffuseInfo;
begin
  with Result do begin
    F:=0.019;
    K:=0.070;
    H:=0.010;
    Dt:=1.00;
    StepsPerFrame:=10;
    ColorDivider:=0.50;
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

// periodic boundary conditions
function pBC(X,Max:Integer):Integer;
begin
  Result:=X;
  while (Result<0) do Inc(Result,Max);
  while (Result>=Max) do Dec(Result,Max);
end;

constructor TReactDiffuse.Create(iTag:Integer);
begin
  inherited Create;

  Tag:=iTag;
  Initialized:=False;
  Speed:=1;
  ReactDiffuseProgram:=TProgram.Create;
  F:=20;
  K:=70;
  H:=10;
  Dt:=1.00;

  FillChar(LastTouch,SizeOf(LastTouch),0);
 // FillChar(LastCamTouch,SizeOf(LastCamTouch),0);

  LoadRandomData;
  Move(RandomData,Data,SizeOf(Data));
end;

destructor TReactDiffuse.Destroy;
begin
  if Initialized then begin
    FreeTextures;
    FreeFBOs;
  end;
  if Assigned(ReactDiffuseProgram) then ReactDiffuseProgram.Free;
  inherited;
end;

procedure TReactDiffuse.SetSize(iW,iH:Integer);
begin
  Width:=iW;
  Height:=iH;

  Reset;
end;

function TReactDiffuse.GetInfo:TReactDiffuseInfo;
begin
  Result.F:=F;
  Result.K:=K;
  Result.H:=H;
  Result.StepsPerFrame:=StepsPerFrame;
  Result.ColorDivider:=ColorDivider;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TReactDiffuse.SetInfo(NewInfo:TReactDiffuseInfo);
begin
  F:=NewInfo.F;
  K:=NewInfo.K;
  H:=NewInfo.H;
  StepsPerFrame:=NewInfo.StepsPerFrame;
  ColorDivider:=NewInfo.ColorDivider;
end;

function AlphaFromRG(R,G:Integer):Integer;
var
  V : Integer;
begin
  V:=Round(Sqrt(Sqr(R)+Sqr(G)));
  if V>255 then Result:=255
  else Result:=V;
end;

procedure TReactDiffuse.Reset;
begin
  FillChar(Data,SizeOf(Data),0);
  CopyDataToTextures;
end;

procedure TReactDiffuse.PrepareForShow;
begin
//  LoadProgram;
end;

procedure TReactDiffuse.LoadProgram;
begin
  ReactDiffuseProgram.LoadVertexAndFragmentFiles('ReactDiffuse.vert',
                                                 'ReactDiffuse.frag',True);
end;

procedure TReactDiffuse.Update;
begin

end;

procedure TReactDiffuse.CreateTextures;
var
  I : Integer;
begin
  glGenTextures(2,@Texture[0]);

  for I:=0 to 1 do begin
    glBindTexture(GL_TEXTURE_2D,Texture[I]);

// set it to repeat in S and T
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA32F_ARB,TW,TH,0,GL_RGBA,GL_FLOAT,nil);//@Data[0]);

    glBindTexture(GL_TEXTURE_2D,0);
  end;
end;

procedure TReactDiffuse.FreeTextures;
begin
  glDeleteTextures(2,@Texture[0]);
end;

procedure TReactDiffuse.CreateFBOs;
var
  I : Integer;
  Status : GLEnum;
begin
// create the frame buffer objects
  glGenFrameBuffersEXT(2,@FBO[0]);

  for I:=0 to 1 do begin
    glBindTexture(GL_TEXTURE_2D,Texture[I]);

    glBindFrameBufferEXT(GL_FRAMEBUFFER_EXT,FBO[I]);

// add the texture as a color attachment to the FBO
    glFrameBufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                              GL_TEXTURE_2D,Texture[I],0);

// unbind the texture
    glBindTexture(GL_TEXTURE_2D,0);

    Status:=glCheckFrameBufferStatusEXT(GL_FRAMEBUFFER_EXT);

    if Status<>GL_FRAMEBUFFER_COMPLETE_EXT then begin
      ShowMessage('Error creating FBOs');
    end;
    glBindFrameBufferEXT(GL_FRAMEBUFFER_EXT,0);
  end;
end;

procedure TReactDiffuse.FreeFBOs;
begin
  glDeleteFrameBuffersEXT(2,@FBO[0]);
end;

procedure TReactDiffuse.CreatePBOs;
begin
// create the pixel buffer objects
  glGenBuffersARB(2,@PBO[0]);

  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB,PBO[0]);
  glBufferDataARB(GL_PIXEL_PACK_BUFFER_ARB,DataSize,nil,GL_STREAM_READ_ARB);

  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB,PBO[1]);
  glBufferDataARB(GL_PIXEL_PACK_BUFFER_ARB,DataSize,nil,GL_STREAM_READ_ARB);

  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB,0);

  glPixelStoreI(GL_UNPACK_ALIGNMENT,4);      // 4-byte pixel alignment
end;

procedure TReactDiffuse.CopyDataFromPBO(I:Integer);
var
  Src : PSingle;
begin
  glReadBuffer(GL_FRONT);

  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB,PBO[I]);

  glReadPixels(0,0,TW,TH,GL_RGBA,GL_FLOAT,nil);

// map the PBO
  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB,PBO[I]);
  Src:=PSingle(glMapBufferARB(GL_PIXEL_PACK_BUFFER_ARB, GL_READ_ONLY_ARB));

  if Assigned(Src)then begin
    Move(Src^,Data,DataSize);
  end;

  glUnmapBufferARB(GL_PIXEL_PACK_BUFFER_ARB);     // release pointer to the mapped buffer
  glBindBufferARB(GL_PIXEL_PACK_BUFFER_ARB, 0);
end;

procedure TReactDiffuse.FreePBOs;
begin
  glDeleteBuffers(2,@PBO[0]);
end;

procedure TReactDiffuse.InitLazy;
begin
  LoadProgram;

  CreateTextures;
  CreateFBOs;
  CreatePBOs;

  MakeRandom:=True;

  Initialized:=True;
end;

procedure TReactDiffuse.MakeSolidColor(R,G,B:Single);
var
  PixelPtr : PRgbaSingle;
  X,Y      : Integer;
begin
  PixelPtr:=PRgbaSingle(@Data[0]);
  for Y:=0 to TH-1 do begin
    for X:=0 to TW-1 do begin
      PixelPtr^.R:=R;
      PixelPtr^.G:=G;
      PixelPtr^.B:=B;
      PixelPtr^.A:=1.0;
      Inc(PixelPtr);
    end;
  end;
  CopyDataToTextures;
end;

procedure TReactDiffuse.CopyDataToTexture(I:Integer);
begin
  glBindTexture(GL_TEXTURE_2D,Texture[I]);
  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA32F_ARB,TW,TH,0,GL_RGBA,GL_FLOAT,@Data);
  glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure TReactDiffuse.CopyDataToTextures;
var
  I : Integer;
begin
  for I:=0 to 1 do begin
    glBindTexture(GL_TEXTURE_2D,Texture[I]);
    glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA32F_ARB,TW,TH,0,GL_RGBA,GL_FLOAT,@Data);
  end;
  glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure TReactDiffuse.AssertTexture(I:Integer);
begin
  glEnable(GL_TEXTURE_2D);

  glBindTexture(GL_TEXTURE_2D,Texture[I]);

// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA32F_ARB,TW,TH,0,GL_RGBA,GL_FLOAT,@RandomData);
end;

procedure TReactDiffuse.AssertControlData;
var
  I : Integer;
begin
  glEnable(GL_TEXTURE_2D);

  for I:=0 to 1 do begin
    glBindTexture(GL_TEXTURE_2D,Texture[I]);

// set it to repeat in S and T
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  end;
end;

function TReactDiffuse.RandomFileName:String;
begin
  Result:=Path+'Random.dat';
end;

procedure TReactDiffuse.LoadRandomData;
var
  RandomFile : File;
  FileName   : String;
begin
  FileName:=RandomFileName;
  if FileExists(FileName) then begin
    Assign(RandomFile,FileName);
    try
      System.Reset(RandomFile,1);
      BlockRead(RandomFile,RandomData,SizeOf(RandomData));
    finally
      Close(RandomFile);
    end;
  end
  else begin
    ShowMessage(FileName+' not found');
    FillChar(RandomData,SizeOf(RandomData),0);
  end;
end;

procedure TReactDiffuse.SaveRandomData;
var
  RandomFile : File;
  FileName   : String;
  Size       : Integer;
begin
  FileName:=RandomFileName;
  Assign(RandomFile,RandomFileName);
  try
    Rewrite(RandomFile,1);
    Size:=SizeOf(RandomData);
    BlockWrite(RandomFile,RandomData,Size);
  finally
    Close(RandomFile);
  end;
end;

procedure TReactDiffuse.TextureQuad2D;
const
  Repeats = 1;
begin
  glBegin(GL_QUADS);

// bottom left
    glTexCoord2F(0,0);
    glVertex2F(0,0);

// top left
    glTexCoord2F(Repeats,0);
    glVertex2F(TW,0);

// top right
    glTexCoord2F(Repeats,Repeats);
    glVertex2f(TW,TH);

// bottom right
    glTexCoord2F(0,Repeats);
    glVertex2F(0,TH);
  glEnd();
end;

{function TReactDiffuse.AnyTouchesActive:Boolean;
var
  I : Integer;
begin
  Result:=False;
  I:=0;
  while (I<MaxTouches) and (not Result) do begin
    Inc(I);
    with Touch[I] do if Active then begin
      Result:=(X<>LastTouch[I].X) or (Y<>LastTouch[I].Y);
    end;
    if not Result then with CamTouch[I] do if Active then begin
      Result:=(X<>LastCamTouch[I].X) or (Y<>LastCamTouch[I].Y);
    end;
  end;
end;}

function TReactDiffuse.AnyTouchesActive:Boolean;
var
  I : Integer;
begin
  Result:=False;
  I:=0;
  while (I<MaxTouches) and (not Result) do begin
    Inc(I);
    with Tracker.Touch[I] do if Active then begin
      Result:=(X<>LastTouch[I].X) or (Y<>LastTouch[I].Y);
    end;
  end;
end;

function TReactDiffuse.TouchXYToTextureXY(Tx,Ty:Single):TPoint;
begin
  Result.X:=Round(TW/2*(1+Tx));
  Result.Y:=Round(TH/2*(1+Ty));
end;

procedure TReactDiffuse.UpdateControl;
var
  I  : Integer;
  Pt : TPoint;
begin
  for I:=1 to MaxTouches do begin
    with Tracker.Touch[I] do if Active then begin
      Pt:=TouchXYToTextureXY(X,Y);
      AddCircularDisturbance(Pt.Y,Pt.X,10);
      AddMirroredCircularDisturbance(Pt.Y,Pt.X,10);
      Active:=False;
    end;
  end;

  if OddFrame then CopyDataToTexture(1)
  else CopyDataToTexture(0);
end;

procedure TReactDiffuse.RenderToTexture;
var
  I : Integer;
begin
  if not Initialized then InitLazy;

// enable the shaders
  ReactDiffuseProgram.Use;

  SyncVars;

// set the viewport to the size of the texture
  glViewport(0,0,TW,TH);

  glClearColor(0.0, 0.0, 1.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);

// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

// establish a 1/1 relationship between pixels and OpenGL units
  glOrtho(0,TW,0,TH,-1,1000);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  for I:=1 to Speed do begin
    OddFrame:=not OddFrame;

    if OddFrame then begin
      glBindTexture(GL_TEXTURE_2D,Texture[0]);         // texture[0] is input
      if MakeRandom then begin
        AssertTexture(0);
        MakeRandom:=False;
      end;
      glBindFrameBufferEXT(GL_FRAMEBUFFER_EXT,FBO[1]); // draw on texture[1]
    end
    else begin
      glBindTexture(GL_TEXTURE_2D,Texture[1]);         // texture[1] is input
      if MakeRandom then begin
        AssertTexture(1);
        MakeRandom:=False;
      end;
      glBindFrameBufferEXT(GL_FRAMEBUFFER_EXT,FBO[0]); // draw on texture[0]
    end;
    TextureQuad2D;
  end;

//MakeSolidColor(Random(10)/10,0,0);


//      CopyDataFromPBO(0);
//      AddCircularDisturbance(Random(100),Random(100),50);

  if Tag=2 then begin
    if AnyTouchesActive then begin
      CopyDataFromPBO(0);
      UpdateControl;
    end;
    Move(Tracker.Touch,LastTouch,SizeOf(LastTouch));
 //   Move(CamTouch,LastCamTouch,SizeOf(CamTouch));}
  end;

  if SetRandomData then begin
    glReadPixels(0,0,TW,TH,GL_RGBA,GL_FLOAT,@RandomData[0]);
    SetRandomData:=False;
    SaveRandomData;
  end;

  glBindTexture(GL_TEXTURE_2D, 0);

  ReactDiffuseProgram.Remove;

// set the screen as the drawing target again
  glBindFrameBufferEXT(GL_FRAMEBUFFER_EXT,0);
end;

procedure TReactDiffuse.BindInputTexture;
begin
  if OddFrame then glBindTexture(GL_TEXTURE_2D,Texture[1])
  else glBindTexture(GL_TEXTURE_2D,Texture[0]);
end;

procedure TReactDiffuse.Render;
begin
  RenderToTexture;
  RenderToScreen2D;
end;

procedure TReactDiffuse.RenderToScreen2D;
begin
  BindInputTexture;
  RenderTexturedRectangle3(0,0,TW,TH,1.0);
  glBindTexture(GL_TEXTURE_2D,0);
end;

procedure TReactDiffuse.RenderToScreen3D;
const
  Size = 10;
begin
  BindInputTexture;
  RenderTexturedRectangle3(0,0,Size,Size,1.0);

  glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure TReactDiffuse.Disturb(X, Y: Integer);
begin

end;

procedure TReactDiffuse.DrawOnBmp(Bmp: TBitmap);
begin

end;

procedure TReactDiffuse.DrawOnTextureData(Data: PByte);
begin

end;

procedure TReactDiffuse.ReadDataFromTexture(I:Integer);
begin
  glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_FLOAT,@Data[0]);
end;

procedure TReactDiffuse.SyncVars;
const
  DU = 2E-5;
  DV = 1E-5;
var
  DuDivH2 : Single;
  DvDivH2 : Single;
  HS      : Single;
begin
  ReactDiffuseProgram.SetUniformI('inTexture',0);
  ReactDiffuseProgram.SetUniform4F('pixelDimension',1/TW,-1/TW,1/TH,-1/TH);

  ReactDiffuseProgram.SetUniformF('f',F/1000);
  ReactDiffuseProgram.SetUniformF('k',K/1000);

// H is stored in 2 vars to simplify things for the shader
  HS:=Sqr(H/1000);
  DuDivH2:=DU/HS;
  DvDivH2:=DV/HS;
  ReactDiffuseProgram.SetUniformF('duDivH2',DuDivH2);
  ReactDiffuseProgram.SetUniformF('dvDivH2',DvDivH2);

  ReactDiffuseProgram.SetUniformF('dt',Dt);
end;

procedure TReactDiffuse.SelectSpots;
begin
  F:=20;
  K:=79;
  H:=10;
end;

procedure TReactDiffuse.SelectWaves;
begin
  F:=20;
  K:=73;
  H:=10;
end;

procedure TReactDiffuse.SelectPulsating;
begin
  F:=19;
  K:=66;
  H:=10;
end;

procedure TReactDiffuse.SelectLabyrinth;
begin
  F:=24;
  K:=78;
  H:=10;
end;

procedure TReactDiffuse.SaveBmp;
var
  DataPtr : PSingle;
  X,Y,I   : Integer;
  Bmp     : TBitmap;
  Line    : PByteArray;
begin
  Bmp:=TBitmap.Create;
  try
    Bmp.PixelFormat:=pf24Bit;
    for Y:=0 to TH-1 do begin
      Line:=Bmp.ScanLine[Y];
      for X:=0 to TW-1 do begin
        I:=X*3;
        Line^[I+0]:=ClipToByte(Data[X,Y].R*255);
        Line^[I+1]:=ClipToByte(Data[X,Y].G*255);
        Line^[I+2]:=ClipToByte(Data[X,Y].B*255);
      end;
    end;
    Bmp.SaveToFile(Path+'RD.bmp');
  finally
    Bmp.Free;
  end;
end;

procedure TReactDiffuse.ApplyPodServerRD(PodServerRD:TPodServerRD);
var
  I :Integer;
begin
 { I:=PodServerRD.PresetI;
  F:=RDPreset[I].F;
  K:=RDPreset[I].K;
  H:=RDPreset[I].H;

  for I:=1 to MaxTouches do begin
    Touch[I].Active:=PodServerRD.TouchUpdated[I];
    Touch[I].X:=PodServerRD.TouchX[I];
    Touch[I].Y:=PodServerRD.TouchY[I];
  end;

  ColorDivider:=PodServerRD.ColorDivider;
  MakeRandom:=False;//PodServerRD.Reset;       }
end;

procedure TReactDiffuse.AddMirroredCircularDisturbance(X,Y,R:Integer);
var
  HW : Integer;
begin
  HW:=TW div 2;

  if Y>HW then Y:=Y-HW
  else Y:=Y+HW;

  if Y<0 then Y:=0
  else if Y>(TW-1) then Y:=TW-1;

  AddCircularDisturbance(X,Y,R);
end;

procedure TReactDiffuse.AddCircularDisturbance(X,Y,R:Integer);
var
  MinX    : Integer;
  MaxX    : Integer;
  MinY    : Integer;
  MaxY    : Integer;
  DataPtr : PSingle;
  XL,YL   : Integer;
  D       : Single;
begin
// find the limits of the square
  MinX:=X-R;
  if MinX<0 then MinX:=0;

  MaxX:=X+R;
  if MaxX>(TW-1) then MaxX:=TW-1;

  MinY:=Y-R;
  if MinY<0 then MinY:=0;

  MaxY:=Y+R;
  if MaxY>(TH-1) then MaxY:=TH-1;

  for YL:=MinY to MaxY do begin
    for XL:=MinX to MaxX do begin
      D:=Sqrt((YL-Y)*(YL-Y)+(XL-X)*(XL-X));
      if D<=R then begin
        Data[XL,YL].R:=0.50; // red
        Data[XL,YL].G:=0.25; // green
        Data[XL,YL].B:=0.00; // blue
        Data[XL,YL].A:=1.00; // alpha
      end;
    end;
  end;
end;

end.

