unit FountainU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs,  OpenGL1x, StdCtrls,
  ComCtrls, ExtCtrls,
  OpenGLTokens, Routines, Global, TextureU, GLDraw, Math, ProgramU,
  SphereU;

const
  MaxParticles   = 9000;
  MaxTextures    = 5;
  ParticleLayers = 2;
  MaxSpots       = 12;
  SpotTW         = 256;//TW;
  SpotTH         = SpotTW;

type
  TParticleMode = (pmIdle,pmRising,pmRisen,pmFalling);

  TParticle = record
    Position : TPoint3D;
    Velocity : TPoint3D;
  end;
  PParticle = ^TParticle;

  TParticleArray = array[1..MaxParticles] of TParticle;
  TFountain = class(TObject)
  private
    Particle  : TParticleArray;

    StartTime : DWord;
    LastTime  : DWord;

    ParticleProgram : TProgram;

// buffer objects
    FeedBackBuffer : array[0..1] of GLUInt;
    HomePosBuffer  : array[0..1] of GLUInt;
    PositionBuffer : array[0..1] of GLUInt;
    VelocityBuffer : array[0..1] of GLUInt;

    InitialVelocity : GLUInt;

// vertex array
    Vertex : array[0..1] of GLUInt;

    Texture : GLUInt;
    FBO     : GLUInt;

    UpdateSub : GLUInt;
    RenderSub : GLUInt;

    ParticleTexture : TTexture;

    Initialized : Boolean;

    procedure LoadProgram;
    procedure CreateBuffers;

    procedure CreateTexture;
    procedure FreeTexture;

    procedure CreateFBO;
    procedure FreeFBO;

    procedure Initialize;

    procedure SetUniformVars;
    procedure ApplySpeed;

  public
    Tag       : Integer;
    Alpha     : Single;
    Particles : Integer;
    DrawIndex : Integer;
    PointSize : Single;

    Divider1 : Single;
    Divider2 : Single;

    MaxR : Single;

    Spot : TSpotArray;

    MinSpeed : Single;
    MaxSpeed : Single;

    ResetFlag : Boolean;
    SpeedFlag : Boolean;

    AlphaThreshold : Single;

    MinSpotSize : Single;
    MaxSpotSize : Single;

    Touch : TTouchArray;

    constructor Create(iTag:Integer);
    destructor Destroy; override;

    procedure Update;
    procedure Render;
    procedure RenderToTexture;
    procedure BindTexture;
    procedure SetToDefault;
    procedure PlaceParticles(Reset:Boolean);
    procedure SetMinSpeed(NewSpeed:Single);
    procedure SetMaxSpeed(NewSpeed:Single);
    procedure ApplyReset;
    procedure RenderSpots(Sphere:TSphere);
    procedure RenderPolarSpots(Sphere:TSphere;PolarScale:Single);
    procedure InitFromParticleRecord(Particle:TParticleRecord);
    procedure PlaceSpots;
    procedure PlacePolarSpots;
  end;
  TFountainArray = array[1..ParticleLayers] of TFountain;

var
//  Fountain     : TFountainArray;
  FountainSpot : TLayerSpotArray;

implementation

uses
  Protocol;

procedure TFountain.SetToDefault;
begin
  Divider1:=0.18;
  Divider2:=0.16;
  MaxR:=0.24;
  PointSize:=16;
  Particles:=MaxParticles;
  AlphaThreshold:=0.70;
end;

constructor TFountain.Create(iTag:Integer);
begin
  inherited Create;

  Tag:=iTag;

  Initialized:=False;

  MinSpeed:=0.001;
  MaxSpeed:=0.010;

  SetToDefault;

  ParticleProgram:=TProgram.Create;

// the texture of the particle itself
  ParticleTexture:=TTexture.Create;

// the texture we render to when we don't render directly to the screen
  Texture:=0;

  PlaceSpots;

  Randomize;
end;

destructor TFountain.Destroy;
begin
  if Assigned(ParticleProgram) then ParticleProgram.Free;
  if Assigned(ParticleTexture) then ParticleTexture.Free;

  if Initialized then begin
    glDeleteBuffers(2,@HomePosBuffer[0]);
    glDeleteBuffers(2,@PositionBuffer[0]);
    glDeleteBuffers(2,@VelocityBuffer[0]);

    FreeFBO;
    FreeTexture;
  end;

  inherited;
end;

procedure TFountain.CreateTexture;
begin
  glGenTextures(1,@Texture);

 	glBindTexture(GL_TEXTURE_2D, Texture);

// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,SpotTW,SpotTH,0,GL_RGBA,GL_UNSIGNED_BYTE,nil);

  glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure TFountain.FreeTexture;
begin
  glDeleteTextures(1,@Texture);
end;

procedure TFountain.BindTexture;
begin
  if Texture=0 then CreateTexture;
 	glBindTexture(GL_TEXTURE_2D,Texture);
end;

procedure TFountain.CreateFBO;
var
  Status : GLEnum;
begin
// create the frame buffer objects
  glGenFrameBuffersEXT(1,@FBO);

  glBindTexture(GL_TEXTURE_2D,Texture);

  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,FBO);

// add the texture as a color attachment to the FBO
  glFrameBufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                            GL_TEXTURE_2D,Texture,0);

// unbind the texture
  glBindTexture(GL_TEXTURE_2D,0);

  Status:=glCheckFrameBufferStatusEXT(GL_FRAMEBUFFER_EXT);
  if Status<>GL_FRAMEBUFFER_COMPLETE_EXT then begin
    ShowMessage('Error creating frame buffer object');
  end;

  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
end;

procedure TFountain.FreeFBO;
begin
  glDeleteFramebuffersEXT(1,@FBO);
end;

procedure TFountain.LoadProgram;
const
  Names = 3;
  OutputName : array[1..Names] of PGLChar = ('HomePos','Position','Velocity');
begin
// load the particle program - don't link it yet
  ParticleProgram.LoadVertexAndFragmentFiles('Particle.vert','Particle.frag',False);

// set up the varying feedback output names
  glTransformFeedbackVaryings(ParticleProgram.Handle,Names,@OutputName[1],
                              GL_SEPARATE_ATTRIBS);
// link the program
  ParticleProgram.Link;
end;

procedure TFountain.ApplyReset;
begin
  PlaceParticles(True);
end;

procedure TFountain.PlaceParticles(Reset:Boolean);
const
  Noise = 0.001;
var
  I,P,Size : Integer;
  Data     : array of GLFloat;
begin
// Allocate space for all buffers
  Size:=MaxParticles*3*SizeOf(Single);
  SetLength(Data,MaxParticles*3); // X,Y,Z

// fill the home position buffer with random positions
  I:=0;
  for P:=1 to MaxParticles do begin
    Data[I]:=RandomSingle(-Noise,+Noise);
    Inc(I);
    Data[I]:=RandomSingle(-Noise,+Noise);
    Inc(I);
    Data[I]:=0;
    Inc(I);
  end;
  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,HomePosBuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);

// give it to the start position buffer as well
    if Reset then begin
      glBindBuffer(GL_ARRAY_BUFFER,PositionBuffer[I]);
      glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);
    end;
  end;
end;

procedure TFountain.SetMinSpeed(NewSpeed: Single);
begin
  if MinSpeed<>NewSpeed then begin
    MinSpeed:=NewSpeed;
    SpeedFlag:=True;
  end;
end;

procedure TFountain.SetMaxSpeed(NewSpeed: Single);
begin
  if MaxSpeed<>NewSpeed then begin
    MaxSpeed:=NewSpeed;
    SpeedFlag:=True;
  end;
end;

procedure TFountain.ApplySpeed;
const
  Scale = 10;
var
  Data : array of Single;
  I,P  : Integer;
  Size : Integer;
  MinV : Single;
  MaxV : Single;
  X,Y,Z : Integer;
begin
  SetLength(Data,MaxParticles*3); // X,Y,Z

  MinV:=MinSpeed/Scale;
  MaxV:=MaxSpeed/Scale;

  X:=0;
  Y:=1;
  Z:=2;
  for P:=1 to MaxParticles do begin

// X
    Data[X]:=RandomSingle(-MaxV,+MaxV);

// Y
    Data[Y]:=RandomSingle(-MaxV,+MaxV);
    if (Abs(Data[X])<MinV) and (Abs(Data[Y])<MinV) then begin
      Case Random(4) of
        0: Data[X]:=-MinV;
        1: Data[X]:=+MinV;
        2: Data[Y]:=-MinV;
        3: Data[Y]:=+MinV;
      end;
    end;
    Data[Z]:=0;
    Inc(X,3);
    Inc(Y,3);
    Inc(Z,3);
  end;

  Size:=MaxParticles*3*SizeOf(Single);
  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,VelocityBuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);
  end;
end;

procedure TFountain.CreateBuffers;
const
  Noise = 0.001;
var
  I,P,Size   : Integer;
  Time       : Single;
  Data       : array of GLFloat;
  Normalized : ByteBool;
  Vx,Vy      : Single;
  Ax,Ay      : Single;
begin
// Generate the buffers
  glGenBuffers(2,@HomePosBuffer[0]);
  glGenBuffers(2,@PositionBuffer[0]);
  glGenBuffers(2,@VelocityBuffer[0]);

// Allocate space for all buffers
  Size:=MaxParticles*3*SizeOf(Single);
  SetLength(Data,MaxParticles*3); // X,Y,Z

  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,HomePosBuffer[I]);
    glBufferData(GL_ARRAY_BUFFER,Size,nil,GL_DYNAMIC_COPY);

    glBindBuffer(GL_ARRAY_BUFFER,PositionBuffer[I]);
    glBufferData(GL_ARRAY_BUFFER,Size,nil,GL_DYNAMIC_COPY);

    glBindBuffer(GL_ARRAY_BUFFER,VelocityBuffer[I]);
    glBufferData(GL_ARRAY_BUFFER,Size,nil,GL_DYNAMIC_COPY);
  end;

  PlaceParticles(True);

  ApplySpeed;

// create vertex arrays for each set of buffers
  glGenVertexArrays(2,@Vertex[0]);
  Normalized:=False;

  for I:=0 to 1 do begin
    glBindVertexArray(Vertex[I]);

    glBindBuffer(GL_ARRAY_BUFFER,HomePosBuffer[I]);
    glVertexAttribPointer(0,3,GL_FLOAT,Normalized,0,nil);
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER,PositionBuffer[I]);
    glVertexAttribPointer(1,3,GL_FLOAT,Normalized,0,nil);
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER,VelocityBuffer[I]);
    glVertexAttribPointer(2,3,GL_FLOAT,Normalized,0,nil);
    glEnableVertexAttribArray(2);
  end;

  glBindVertexArray(0);
  glBindBuffer(GL_ARRAY_BUFFER,0);

// generate the feedback buffer objects
  glGenTransformFeedbacks(2,@FeedBackBuffer[0]);

// initialize them
  for I:=0 to 1 do begin
    glBindTransformFeedback(GL_TRANSFORM_FEEDBACK,FeedBackBuffer[I]);
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER,0,HomePosBuffer[I]);
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER,1,PositionBuffer[I]);
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER,2,VelocityBuffer[I]);
  end;

  glBindTransformFeedback(GL_TRANSFORM_FEEDBACK,0);

  StartTime:=GetTickCount;
  LastTime:=StartTime;

  DrawIndex:=0;
end;

procedure TFountain.Update;
var
  Time      : DWord;
  FrameTime : Single;
begin
  if not Initialized then Initialize;

  Spot:=FountainSpot[Tag];

  ParticleProgram.Active:=True;

  if ResetFlag then begin
    ApplyReset;
    ResetFlag:=False;
  end;

  if SpeedFlag then begin
    ApplySpeed;
    SpeedFlag:=False;
  end;

  glUniformSubRoutinesUIV(GL_VERTEX_SHADER,1,@UpdateSub);

// Set the uniforms: H and Time
  Time:=GetTickCount;
  FrameTime:=(Time-LastTime)/1000;
  LastTime:=Time;

  ParticleProgram.SetUniformF('H',FrameTime);

// Disable rendering
  glEnable(GL_RASTERIZER_DISCARD);

// Bind the feedback object for the buffers
  glBindTransformFeedback(GL_TRANSFORM_FEEDBACK,FeedBackBuffer[DrawIndex]);
  glBeginTransformFeedBack(GL_POINTS);

// draw points from input buffer with transform
  glBeginTransformFeedBack(GL_POINTS);
    glBindVertexArray(Vertex[1-DrawIndex]);
    glDrawArrays(GL_POINTS,0,Particles);
  glEndTransformFeedBack();

// enable rendering again
  glDisable(GL_RASTERIZER_DISCARD);

  glBindTransformFeedback(GL_TRANSFORM_FEEDBACK,0);
end;

procedure TFountain.Render;
begin
  glClearColor(0.0,0.0,0.0,0.0);

// clear the color buffer
  glClear(GL_COLOR_BUFFER_BIT);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE);// GL_ONE_MINUS_SRC_ALPHA);

  glEnable(GL_POINT_SPRITE);
  glEnable(GL_TEXTURE_2D);
  glActiveTexture(GL_TEXTURE0);

  ParticleTexture.Bind;

  SetUniformVars;

  glUniformSubroutinesUIV(GL_VERTEX_SHADER,1,@RenderSub);

// draw the sprites from the feedback buffer
  glColor3F(1,1,1);
  glPointSize(PointSize);
  glBindVertexArray(Vertex[DrawIndex]);
  glDrawArrays(GL_POINTS,0,Particles);

// swap the buffers
  DrawIndex:=(1-DrawIndex);

  ParticleProgram.Active:=False;
  glBindTexture(GL_TEXTURE_2D,0);
end;

procedure TFountain.PlaceSpots;
const
  Spacing = (2*Pi)/MaxSpots;
var
  I : Integer;
begin
  for I:=1 to MaxSpots do begin
    Spot[I].Rx:=Math.DegToRad(-5+Random(10));
    Spot[I].Ry:=(I-1)*Spacing+Math.DegToRad(-5+Random(10));
  end;
end;

procedure TFountain.PlacePolarSpots;
const
  Spacing = (2*Pi)/MaxSpots;
var
  I : Integer;
begin
  for I:=1 to MaxSpots do begin
    Spot[I].Rx:=Math.DegToRad(-15+Random(30));
    Spot[I].Ry:=(I-1)*Spacing+Math.DegToRad(-15+Random(30));
  end;
end;

procedure TFountain.Initialize;
begin
  LoadProgram;

// get the subroutine indexes inside the shader
  RenderSub:=glGetSubroutineIndex(ParticleProgram.Handle,GL_VERTEX_SHADER,'render');
  UpdateSub:=glGetSubroutineIndex(ParticleProgram.Handle,GL_VERTEX_SHADER,'update');

  CreateBuffers;

//  ParticleTexture.LoadWithAlpha(TexturePath+'Par124Bit.bmp');
  ParticleTexture.Load(TexturePath+'Par124Bit.bmp');

//  ParticleTexture.SaveAsBmp(TexturePath+'ParticleWithAlpha.bmp');

// for rendering to texture
  CreateTexture;
  CreateFBO;

  Initialized:=True;
end;

procedure TFountain.SetUniformVars;
begin
  ParticleProgram.SetUniformI('ParticleTex',0);
  ParticleProgram.SetUniformF('SpriteSize',PointSize);
  ParticleProgram.SetUniformF('divider1',Divider1);
  ParticleProgram.SetUniformF('divider2',Divider2);
  ParticleProgram.SetUniformF('MaxR',MaxR);
  ParticleProgram.SetUniformF('alphaThreshold',AlphaThreshold);
end;

procedure TFountain.RenderToTexture;
begin
  Particles:=MaxParticles;

  glClearColor(0,0,0,0);

// clear the color buffer
  glClear(GL_COLOR_BUFFER_BIT);

// set the viewport to the size of the texture
  glViewport(0, 0, SpotTW, SpotTH);

// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

// establish a 1/1 relationship between pixels and OpenGL units
  glOrtho(0, SpotTW, 0, SpotTH, -1, 1000);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

// clear the color buffer
  glClear(GL_COLOR_BUFFER_BIT);

  EnableAlpha;
  EnableTextures;

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

  glEnable(GL_POINT_SPRITE);
  glEnable(GL_TEXTURE_2D);

  ParticleTexture.Bind;
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,FBO); // draw on the texture

  SetUniformVars;

  glUniformSubroutinesUIV(GL_VERTEX_SHADER,1,@RenderSub);

// draw the sprites from the feedback buffer
  glColor4F(1,1,1,1);
  glPointSize(PointSize);
  glBindVertexArray(Vertex[DrawIndex]);
  glDrawArrays(GL_POINTS,0,Particles);

  glBindTexture(GL_TEXTURE_2D,0);

// swap the buffers
  DrawIndex:=(1-DrawIndex);

  ParticleProgram.Active:=False;
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);
end;

procedure TFountain.RenderSpots(Sphere:TSphere);
var
  S,I      : Integer;
  Rx,Ry,Rz : Single;
  Mag,F    : Single;
  Min,Max  : Single;
begin
  BindTexture;

  Min:=Math.DegToRad(25);
  Max:=Math.DegToRad(45);

  for S:=1 to MaxSpots do begin
    Rx:=Spot[S].Rx;
    Ry:=Spot[S].Ry-CurrentPos[Tag].ParticleRz;
    if Tag=2 then begin
      I:=((S-1) mod MaxTouches)+1;
//      Rx:=Rx-Pi/4+PodServerSeason.Particles.Y[S]*Pi/2;
//      Ry:=Ry-Pi/4+PodServerSeason.Particles.X[S]*Pi/2;
//      Rx:=Rx+Pi/4-PodServerSeason.Particles.Y[S]*Pi/2;
//      Ry:=Ry-Pi/4+PodServerSeason.Particles.X[S]*Pi/2;
      Rx:=Rx+Pi/4-Touch[I].Y*Pi/2;
      Ry:=Ry-Pi/4+Touch[I].X*Pi/2;
    end;
    if Ry>Pi then Ry:=Ry-(2*Pi)
    else if Ry<-Pi then Ry:=Ry+(2*Pi);

// fade at the edges
    Mag:=Abs(Ry);
    if Mag>=Max then Continue
    else if Mag<=Min then F:=1
    else begin
      F:=(Max-Mag)/(Max-Min);
    end;
    glColor4F(1,1,1,F*Alpha);

    glPushMatrix;
      glRotateF(Math.RadToDeg(Rx),1,0,0);
      glRotateF(Math.RadToDeg(Ry),0,1,0);
      Sphere.RenderSpot(MaxSpotSize);
    glPopMatrix;
  end;

  glBindTexture(GL_TEXTURE_2D,0);
end;

procedure TFountain.RenderPolarSpots(Sphere:TSphere;PolarScale:Single);
var
  S        : Integer;
  Rx,Ry,Rz : Single;
  Mag,F    : Single;
  Min,Max  : Single;
begin
  BindTexture;

  glColor4F(1,1,1,Alpha);
  Rz:=CurrentPos[Tag].ParticleRz*PolarScale;

  for S:=1 to MaxSpots do begin
    Rx:=Spot[S].Rx;
    Ry:=Spot[S].Ry;
    if Tag=2 then begin
      Rx:=Rx-Pi/4+PodServerSeason.Particles.Y[S]*Pi/2;
      Ry:=Ry-Pi/4+PodServerSeason.Particles.X[S]*Pi/2;
    end;

    glPushMatrix;
      glRotateF(Math.RadToDeg(Rx),1,0,0);
      glRotateF(Math.RadToDeg(Ry),0,1,0);
//      glRotateF(Math.RadToDeg(Rz),0,0,1);
      Sphere.RenderPolarSpot(MaxSpotSize,Rz);
    glPopMatrix;
  end;

  glBindTexture(GL_TEXTURE_2D,0);
end;

{procedure TFountain.RenderSpots(Sphere:TSphere);
var
  S : Integer;
  Rx : Single;
  Ry : Single;
  Rz : Single;
begin
  BindTexture;

  glColor4F(1,1,1,Alpha);

  for S:=1 to MaxSpots do begin
    Rx:=Spot[S].Rx;
    Ry:=Spot[S].Ry-Rotation[Tag].ParticleRz;

    if Tag=2 then begin
      Rx:=Rx-Pi/4+PodServerSeason.Particles.Y[S]*Pi/2;
      Ry:=Ry-Pi/4+PodServerSeason.Particles.X[S]*Pi/2;
    end;

    glPushMatrix;
      glRotateF(Math.RadToDeg(Rx),1,0,0);
      glRotateF(Math.RadToDeg(Ry),0,1,0);
      Sphere.RenderSpot(MaxSpotSize);
    glPopMatrix;
  end;

  glBindTexture(GL_TEXTURE_2D,0);
end;}

procedure TFountain.InitFromParticleRecord(Particle:TParticleRecord);
begin
  Alpha:=Particle.Alpha;
  Particles:=Particle.Count;
  MaxR:=Particle.MaxR;
  Divider1:=Particle.Divider1*MaxR;
  Divider2:=Particle.Divider2*MaxR;
  PointSize:=Particle.PointSize;
  SetMinSpeed(Particle.MinSpeed);
  SetMaxSpeed(Particle.MaxSpeed);
  AlphaThreshold:=Particle.AlphaThreshold;
  MinSpotSize:=Particle.MinSpotSize;
  MaxSpotSize:=Particle.MaxSpotSize;
end;


initialization

end.
procedure TFountain.ApplyPodServerParticle(PodServerParticle:TPodServerParticle);
begin
end;

//   glRotateF(Math.RadToDeg(Spot[1].Ry),0,1,0);
//   glRotateF(Math.RadToDeg(Spot[1].Rz),0,0,1);

{   glRotateF(-90,0,1,0);
   glRotateF(0,0,0,1);

   Sphere.RenderSpot;

  glBindTexture(GL_TEXTURE_2D,0);

 Exit;}









