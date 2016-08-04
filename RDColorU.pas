unit RDColorU;

interface

uses
  ProgramU, OpenGL1x, OpenGLTokens, Dialogs, Global, ReactDiffuseU;

type
  TRdColorInfo = record
  end;

  TColorTableEntry  = record
    R,G,B : Single;
  end;

  TRdColor = class(TObject)
  private
    ColorProgram : TProgram;
    MakeReset    : Boolean;
    Initialized  : Boolean;
    ScrollV      : Single;
    ApplyAlpha   : Boolean;
    SOffset      : Single;
    AlphaScale   : Single;

    SyncColorTable : Boolean;
    SyncVars       : Boolean;

    FBO : GLUInt;
    PBO : GLUInt;
    Texture : GLUInt;

    procedure CreateTexture;
    procedure FreeTexture;

    procedure CreateFBO;
    procedure FreeFBO;

    procedure LoadProgram;
    procedure InitLazy;

    procedure InitUniformVars;
    procedure TextureQuad2D;

  public
    Tag     : Integer;
    Divider : Single;
    Scale   : Single;
    Alpha   : Single;
    Repeats : Single;

    constructor Create(iTag:Integer);
    destructor Destroy; override;

    procedure Reset;
    procedure PrepareForShow;
    procedure RenderToTexture(iReactDiffuse:TReactDiffuse);
    procedure RenderToScreen2D;
    procedure RenderToScreen3D;
    procedure BindTexture;
  end;
  TRDColorArray = array[1..RDLayers] of TRDColor;

implementation

uses
  GLDraw;

function DefaultRdColorInfo:TRdColorInfo;
begin
  with Result do begin
{    ScrollV = 0;
    Divider = 0.561;
    Scale = 2.199;
    ApplyAlpha = YES;}
  end;
end;

constructor TRdColor.Create(iTag:Integer);
begin
  inherited Create;

  Tag:=iTag;

  ColorProgram:=TProgram.Create;

  Divider:=0.561;
  Scale:=2.199;
end;

destructor TRdColor.Destroy;
begin
  if Initialized then begin
    FreeFBO;
    FreeTexture;
  end;

  if Assigned(ColorProgram) then ColorProgram.Free;

  inherited;
end;

procedure TRdColor.Reset;
begin
  MakeReset:=True;
end;

procedure TRdColor.PrepareForShow;
begin
end;

procedure TRdColor.LoadProgram;
begin
  ColorProgram.LoadVertexAndFragmentFiles('Color.vert','Color.frag',True);
end;

procedure TRdColor.InitLazy;
begin
  CreateTexture;
  CreateFBO;

  LoadProgram;

  Initialized:=True;
end;

procedure TRdColor.InitUniformVars;
begin
  ColorProgram.SetUniformI('inTexture',0);
  ColorProgram.SetUniformF('divider',Divider);
  ColorProgram.SetUniformF('scale',Scale);
  ColorProgram.SetUniformF('alphaScale',Alpha);
end;

procedure TRdColor.TextureQuad2D;
begin
//  Repeats:=1;
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

procedure TRdColor.RenderToTexture(iReactDiffuse:TReactDiffuse);
begin
  if  not Initialized then InitLazy;

// enable the shaders
  ColorProgram.Use;
  InitUniformVars;

// set the viewport to the size of the texture
  glViewport(0, 0, TW, TH);

// set up the projection matrix
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();

// establish a 1/1 relationship between pixels and OpenGL units
  glOrtho(0, TW, 0, TH, -1, 1000);

// model view matrix
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

// activate the latest RD texture
  iReactDiffuse.BindInputTexture;

  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,FBO); // draw on the texture

  //ReactDiffuse[Tag].
  TextureQuad2D;

  glBindTexture(GL_TEXTURE_2D, 0);

  ColorProgram.Remove;

// set the screen as the drawing target again
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,0);
end;

procedure TRdColor.BindTexture;
begin
  glBindTexture(GL_TEXTURE_2D,Texture);
end;

procedure TRdColor.RenderToScreen2D;
const
  Size = 1.0;
begin
  glBindTexture(GL_TEXTURE_2D,Texture);

  RenderTexturedRectangle(0,0,Size,Size,1.0);
  glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure TRdColor.RenderToScreen3D;
const
  Size = 15;
begin
  glBindTexture(GL_TEXTURE_2D,Texture);
  RenderTexturedRectangle(0,0,Size,Size,1.0);
  glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure TRdColor.CreateTexture;
begin
  glGenTextures(1,@Texture);

 	glBindTexture(GL_TEXTURE_2D, texture);

// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
 	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

 	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, TW, TH, 0, GL_RGBA, GL_FLOAT, nil);// data

  glBindTexture(GL_TEXTURE_2D, 0);
end;

procedure TRdColor.FreeTexture;
begin
  glDeleteTextures(1,@Texture);
end;

procedure TRdColor.CreateFBO;
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

procedure TRdColor.FreeFBO;
begin
  glDeleteFramebuffersEXT(1,@FBO);
end;


end.

