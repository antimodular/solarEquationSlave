unit FountainU;

interface

uses
  VectorGeometry, Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, GLScene, GLObjects,  GLTexture, OpenGL1x, StdCtrls,
  Jpeg, ComCtrls, ExtCtrls, VectorTypes, GLRenderContextInfo, BaseClasses,
  OpenGLTokens, Routines, Global, TextureU, GLDraw, GLSceneU, Math, ProgramU;

const
  MaxParticles = 100000;
  MaxTextures  = 5;

  TW = 1024;
  TH = 1024;

type
  TParticleMode = (pmIdle,pmRising,pmRisen,pmFalling);

  TParticle = record
    Position     : TPoint3D;
    Velocity     : TPoint3D;
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
//    procedure SetHomePositions;

    procedure CreateTexture;
    procedure FreeTexture;

    procedure CreateFBO;
    procedure FreeFBO;

    procedure Initialize;
    procedure SetUniformVars;

  public
    Particles : Integer;
    DrawIndex : Integer;
    PointSize : Integer;

    Divider1 : Single;
    Divider2 : Single;

    constructor Create;
    destructor Destroy; override;

    procedure PrepareForShow;

    procedure Update;
    procedure Render;
    procedure RenderToTexture;
    procedure BindTexture;
  end;

var
  Fountain : TFountain;

implementation

uses
  Main;

constructor TFountain.Create;
var
  I : Integer;
begin
  inherited;

  PointSize:=8;

  Particles:=10000;

  Divider1:=0.55;
  Divider2:=0.40;

  ParticleProgram:=TProgram.Create;

  ParticleTexture:=TTexture.Create;

  Randomize;
end;

destructor TFountain.Destroy;
var
  I : Integer;
begin
  if Assigned(ParticleProgram) then ParticleProgram.Free;
  if Assigned(ParticleTexture) then ParticleTexture.Free;

  glDeleteBuffers(2,@HomePosBuffer[0]);
  glDeleteBuffers(2,@PositionBuffer[0]);
  glDeleteBuffers(2,@VelocityBuffer[0]);

  if Initialized then begin
    FreeFBO;
    FreeTexture;
  end;

  inherited;
end;

procedure TFountain.CreateTexture;
begin
  glGenTextures(1,@Texture);

 	glBindTexture(GL_TEXTURE_2D,Texture);

// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

  glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,TW,TH,0,GL_RGBA,GL_UNSIGNED_BYTE,nil);

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

procedure TFountain.PrepareForShow;
begin
  LoadProgram;

// get the subroutine indexes inside the shader
  RenderSub:=glGetSubroutineIndex(ParticleProgram.Handle,GL_VERTEX_SHADER,'render');
  UpdateSub:=glGetSubroutineIndex(ParticleProgram.Handle,GL_VERTEX_SHADER,'update');

  CreateBuffers;

  ParticleTexture.Load(TexturePath+'Par1.bmp');
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

procedure TFountain.CreateBuffers;
const
  MaxSpeed = 0.3;
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

// fill the home position buffer with random positions
  I:=0;
  for P:=1 to MaxParticles do begin
    Data[I]:=RandomSingle(-0.1,+0.1);
    Inc(I);
    Data[I]:=RandomSingle(-0.1,+0.1);
    Inc(I);
    Data[I]:=0;
    Inc(I);
  end;
  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,HomePosBuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);

// give it to the start position buffer as well
    glBindBuffer(GL_ARRAY_BUFFER,PositionBuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);
  end;

// fill the first velocity buffer with random velocities
  I:=0;
  for P:=1 to MaxParticles do begin
    Data[I]:=RandomSingle(-MaxSpeed,+MaxSpeed);
    Inc(I);
    Data[I]:=RandomSingle(-MaxSpeed,+MaxSpeed);
    Inc(I);
    Data[I]:=0;
    Inc(I);
  end;

  for I:=0 to 1 do begin
    glBindBuffer(GL_ARRAY_BUFFER,VelocityBuffer[I]);
    glBufferSubData(GL_ARRAY_BUFFER,0,Size,@Data[0]);
  end;

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
  ParticleProgram.Active:=True;

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
end;

procedure TFountain.Initialize;
begin
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
end;

procedure TFountain.RenderToTexture;
begin
  if not Initialized then Initialize;

// set the viewport to the size of the texture
  glViewport(0, 0, TW, TH);

  glClearColor(0,0,0,1);

// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

// establish a 1/1 relationship between pixels and OpenGL units
  glOrtho(0, TW, 0, TH, -1, 1000);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

// clear the color buffer
  glClear(GL_COLOR_BUFFER_BIT);

  EnableAlpha;
  EnableTextures;

  glEnable(GL_BLEND);
//  glBlendFunc(GL_SRC_ALPHA,GL_ONE);// GL_ONE_MINUS_SRC_ALPHA);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

  glEnable(GL_POINT_SPRITE);
  glEnable(GL_TEXTURE_2D);
  glActiveTexture(GL_TEXTURE0);

  ParticleTexture.Bind;
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,FBO); // draw on the texture

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
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);
end;

initialization

end.







