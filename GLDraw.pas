unit GLDraw;

interface

uses
  Global, Graphics, OpenGL1x, OpenGLTokens;

type
  TGLColor = record
    R,G,B,A : Single;
  end;

procedure SetLitColor(Color:TColor);
procedure SetUnLitColor(Color:TColor);
function  GLColorToColor(Color:TGLColor):TColor;
function  ColorToGLColor(Color:TColor):TGLColor;
function  SafeTrunc(Value:Single):Integer;

procedure EnableAlpha;
procedure DisableAlpha;
procedure EnableTextures;
procedure DisableTextures;

procedure OutlineCube(XSize,YSize,ZSize:Single);
procedure OutlineRing(Radius,Height:Single;Sides:Integer);

procedure DrawCube(XSize,YSize,ZSize:Single;DrawTop,DrawBtm:Boolean);
procedure DrawRing(Radius,Height:Single;Sides:Integer;Textured:Boolean);

procedure RenderRectangle(X,Y,W,H:Single);

procedure RenderTexturedRectangle(X,Y,W,H,Repeats:Single);
procedure RenderTexturedRectangle2(X,Y,W,H,Repeats:Single);
procedure RenderTexturedRectangle3(X,Y,W,H,Repeats:Single);
procedure RenderTexturedRectangleMirrored(X,Y,W,H,Repeats:Single);
procedure RenderTexturedRectangleFlipped(X,Y,W,H,Repeats:Single);
procedure RenderTexturedRectangleMirroredAndFlipped(X,Y,W,H,Repeats:Single);

// rotated
procedure RenderTexturedRectangleRotated(X,Y,W,H,Repeats:Single);
procedure RenderTexturedRectangleRotatedAndFlipped(X,Y,W,H,Repeats:Single);
procedure RenderTexturedRectangleRotatedAndMirrored(X,Y,W,H,Repeats:Single);
procedure RenderTexturedRectangleRotatedMirroredAndFlipped(X,Y,W,H,Repeats:Single);

procedure RenderMultiTexturedRectangle(X,Y,W,H,R1,R2:Single);
procedure RenderTextured3DRectangle(X,Y,Z,W,H,Repeats:Single);

procedure RenderTexturedRectangleAtZ(X,Y,Z,W,H,Repeats:Single);
procedure RenderMultiTexturedRectangleAtZ(X,Y,Z,W,H,R1,R2:Single);
procedure RenderMultiTextured3DRectangle(X,Y,Z,W,H,R1,R2:Single);

procedure RenderMultiTexturedRectangleFlipped(X,Y,W,H,R1,R2:Single);

const
  glLit    : TGLColor = (R:1.0;G:1.0;B:0.5;A:1.0);
  glBlack  : TGLColor = (R:0.0;G:0.0;B:0.0;A:1.0);
  glGrey   : TGLColor = (R:0.1;G:0.1;B:0.1;A:1.0);
  glWhite  : TGLColor = (R:1.0;G:1.0;B:1.0;A:1.0);
  glRed    : TGLColor = (R:1.0;G:0.0;B:0.0;A:1.0);
  glGreen  : TGLColor = (R:0.0;G:1.0;B:0.0;A:1.0);
  glBlue   : TGLColor = (R:0.0;G:0.0;B:1.0;A:1.0);
  glGray   : TGLColor = (R:0.3;G:0.3;B:0.3;A:1.0);
  glYellow : TGLColor = (R:1.0;G:1.0;B:0.0;A:1.0);
  glPurple : TGLColor = (R:1.0;G:0.0;B:1.0;A:1.0);
  glOrange : TGLColor = (R:1.0;G:0.7;B:0.5;A:1.0);

  UpVector   : TPoint3D = (X:0;Y:0;Z:+1);
  DownVector : TPoint3D = (X:0;Y:0;Z:-1);

implementation

procedure SetLitColor(Color:TColor);
var
  GLColor : TGLColor;
begin
  GLColor:=ColorToGLColor(Color);
  glMaterialFV(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,@Color);
end;

procedure SetUnLitColor(Color:TColor);
var
  GLColor : TGLColor;
begin
  GLColor:=ColorToGLColor(Color);
  with GLColor do glColor3F(R,G,B);
end;

function GLColorToColor(Color:TGLColor):TColor;
begin
  Result:=(Round(Color.B*255) shl 16)+(Round(Color.G*255) shl 8)+
           Round(Color.R*255);
end;

function ColorToGLColor(Color:TColor):TGLColor;
begin
  Result.R:=(Color and $FF)/255;
  Result.G:=((Color and $00FF00) shr 8)/255;
  Result.B:=(Color shr 16)/255;
  Result.A:=1;
end;

function SafeTrunc(Value:Single):Integer;
begin
  Result:=Round(Value);
  if Value>=0 then begin
    if Result>Value then Dec(Result);
  end
  else begin
    if Result<Value then Inc(Result);
  end;
end;

procedure DrawCube(XSize,YSize,ZSize:Single;DrawTop,DrawBtm:Boolean);
var
  X,Y,Z : Single;
begin
  X:=XSize/2; Y:=YSize/2; Z:=ZSize/2;
  glBegin(GL_QUADS);

    if DrawTop then begin
      glNormal3F(0,0,+1);
      glVertex3F(-X,+Y,+Z);
      glVertex3F(-X,-Y,+Z);
      glVertex3F(+X,-Y,+Z);
      glVertex3F(+X,+Y,+Z);
    end;

    glNormal3F(0,-1,0);
    glVertex3F(-X,-Y,+Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(+X,-Y,+Z);

    glNormal3F(-1,0,0);
    glVertex3F(-X,+Y,+Z);
    glVertex3F(-X,+Y,-Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(-X,-Y,+Z);

    glNormal3F(0,+1,0);
    glVertex3F(+X,+Y,+Z);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(-X,+Y,-Z);
    glVertex3F(-X,+Y,+Z);

    glNormal3F(+1,0,0);
    glVertex3F(+X,-Y,+Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(+X,+Y,+Z);

    if DrawBtm then begin
      glNormal3F(0,0,-1);
      glVertex3F(+X,+Y,-Z);
      glVertex3F(+X,-Y,-Z);
      glVertex3F(-X,-Y,-Z);
      glVertex3F(-X,+Y,-Z);
    end;
  glEnd;
end;

function CrossProduct(V1,V2:TPoint3D):TPoint3D;
begin
  Result.X:=(V1.Z*V2.Y)-(V1.Y*V2.Z);
  Result.Y:=(V1.X*V2.Z)-(V1.Z*V2.X);
  Result.Z:=(V1.Y*V2.X)-(V1.X*V2.Y);
end;

procedure DrawRing(Radius,Height:Single;Sides:Integer;Textured:Boolean);
var
  X1,X2,Y1,Y2   : Single;
  Angle,Z,S1,S2 : Single;
  I             : Integer;
  V1,V2,Norm    : TPoint3D;
begin
  X1:=Radius; Y1:=0;
  Z:=Height/2;
  glDisable(GL_CULL_FACE);
  glBegin(GL_QUADS);
  V1.X:=0; V1.Y:=0; V1.Z:=1;
  V2.Z:=0;
  for I:=1 to Sides do begin
    Angle:=(I/Sides)*(2*Pi);
    X2:=Radius*Cos(Angle);
    Y2:=Radius*Sin(Angle);
    V2.X:=(X2-X1);
    V2.Y:=(Y2-Y1);
    Norm:=CrossProduct(V2,V1);
    glNormal3F(-Norm.X,-Norm.Y,-Norm.Z);
    if Textured then begin
      S1:=(I-1)/Sides;
      S2:=I/Sides;
      glTexCoord2F(S1,1);
    end;
    glVertex3F(X1,Y1,+Z);
    if Textured then glTexCoord2F(S1,0);
    glVertex3F(X1,Y1,-Z);
    if Textured then glTexCoord2F(S2,0);
    glVertex3F(X2,Y2,-Z);
    if Textured then glTexCoord2F(S2,1);
    glVertex3F(X2,Y2,+Z);
    X1:=X2; Y1:=Y2;
  end;
  glEnd;
  glEnable(GL_CULL_FACE);
end;

procedure OutlineCube(XSize,YSize,ZSize:Single);
var
  X,Y,Z : Single;
begin
  X:=XSize/2; Y:=YSize/2; Z:=ZSize/2;

  glBegin(GL_LINE_STRIP);
    glVertex3F(-X,+Y,+Z);
    glVertex3F(-X,-Y,+Z);
    glVertex3F(+X,-Y,+Z);
    glVertex3F(+X,+Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(-X,-Y,+Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(+X,-Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(-X,+Y,+Z);
    glVertex3F(-X,+Y,-Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(-X,-Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(+X,+Y,+Z);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(-X,+Y,-Z);
    glVertex3F(-X,+Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(+X,-Y,+Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(+X,+Y,+Z);
  glEnd;

  glBegin(GL_LINE_STRIP);
    glVertex3F(+X,+Y,-Z);
    glVertex3F(+X,-Y,-Z);
    glVertex3F(-X,-Y,-Z);
    glVertex3F(-X,+Y,-Z);
  glEnd;
end;

procedure OutlineRing(Radius,Height:Single;Sides:Integer);
var
  X1,X2,Y1,Y2   : Single;
  Angle,Z,S1,S2 : Single;
  I             : Integer;
  V1,V2,Norm    : TPoint3D;
begin
  X1:=Radius; Y1:=0;
  Z:=Height/2;
  V1.X:=0; V1.Y:=0; V1.Z:=1;
  V2.Z:=0;
  for I:=1 to Sides do begin
    Angle:=(I/Sides)*(2*Pi);
    X2:=Radius*Cos(Angle);
    Y2:=Radius*Sin(Angle);
    V2.X:=(X2-X1);
    V2.Y:=(Y2-Y1);
    glBegin(GL_LINE_LOOP);
      glVertex3F(X1,Y1,+Z);
      glVertex3F(X1,Y1,-Z);
      glVertex3F(X2,Y2,-Z);
      glVertex3F(X2,Y2,+Z);
    glEnd;
    X1:=X2; Y1:=Y2;
  end;
end;

procedure RenderRectangle(X,Y,W,H:Single);
var
  X1,X2 : Single;
  Y1,Y2 : Single;
begin
  X1:=X-W/2;
  X2:=X+W/2;
  Y1:=Y-H/2;
  Y2:=Y+H/2;

  glBegin(GL_QUADS);
    glVertex2F(X1,Y1);
    glVertex2F(X2,Y1);
    glVertex2F(X2,Y2);
    glVertex2F(X1,Y2);
  glEnd;
end;

procedure RenderTexturedRectangle(X,Y,W,H,Repeats:Single);
var
  X1,X2    : Single;
  Y1,Y2    : Single;
  XRepeats : Single;
  YRepeats : Single;
begin
  XRepeats:=(W/H)*Repeats;
  YRepeats:=Repeats;

  X1:=X-W/2;
  X2:=X+W/2;
  Y1:=Y-H/2;
  Y2:=Y+H/2;

  glBegin(GL_QUADS);
    glTexCoord2F(XRepeats,0);
    glVertex2F(X1,Y1);

    glTexCoord2F(0,0);
    glVertex2F(X2,Y1);

    glTexCoord2F(0,YRepeats);
    glVertex2F(X2,Y2);

    glTexCoord2F(XRepeats,YRepeats);
    glVertex2F(X1,Y2);
  glEnd;
end;

procedure RenderTexturedRectangle2(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(0,Repeats);
    glVertex2F(X,Y+H);

    glTexCoord2F(0,0);
    glVertex2F(X,Y);

    glTexCoord2F(Repeats,0);
    glVertex2F(X+W,Y);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X+W,Y+H);
  glEnd;
end;

procedure RenderTexturedRectangle3(X,Y,W,H,Repeats:Single);
var
  X1,X2 : Single;
  Y1,Y2 : Single;
begin
  X1:=X-W/2;
  X2:=X+W/2;
  Y1:=Y-H/2;
  Y2:=Y+H/2;

  glBegin(GL_QUADS);
    glTexCoord2F(Repeats,0);
    glVertex2F(X1,Y1);

    glTexCoord2F(0,0);
    glVertex2F(X2,Y1);

    glTexCoord2F(0,Repeats);
    glVertex2F(X2,Y2);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X1,Y2);
  glEnd;
end;

procedure RenderTexturedRectangleMirrored(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(0,Repeats);
    glVertex2F(X+W/2,Y+H/2);

    glTexCoord2F(0,0);
    glVertex2F(X+W/2,Y-H/2);

    glTexCoord2F(Repeats,0);
    glVertex2F(X-W/2,Y-H/2);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X-W/2,Y+H/2);
  glEnd;
end;


procedure RenderTexturedRectangleFlipped(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(0,0);
    glVertex2F(X-W/2,Y+H/2);

    glTexCoord2F(0,Repeats);
    glVertex2F(X-W/2,Y-H/2);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X+W/2,Y-H/2);

    glTexCoord2F(Repeats,0);
    glVertex2F(X+W/2,Y+H/2);
  glEnd;
end;

// rectangle is centered on X,Y and is WxH
procedure RenderTexturedRectangleMirroredAndFlipped(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(Repeats,0);
    glVertex2F(X-W/2,Y+H/2);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X-W/2,Y-H/2);

    glTexCoord2F(0,Repeats);
    glVertex2F(X+W/2,Y-H/2);

    glTexCoord2F(0,0);
    glVertex2F(X+W/2,Y+H/2);
  glEnd;
end;

// rectangle is centered on X,Y and is WxH
procedure RenderTexturedRectangleRotated(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X-W/2,Y+H/2);

    glTexCoord2F(0,Repeats);
    glVertex2F(X-W/2,Y-H/2);

    glTexCoord2F(0,0);
    glVertex2F(X+W/2,Y-H/2);

    glTexCoord2F(Repeats,0);
    glVertex2F(X+W/2,Y+H/2);
  glEnd;
end;

// rectangle is centered on X,Y and is WxH
procedure RenderTexturedRectangleRotated2(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(Repeats,0);
    glVertex2F(X-W/2,Y+H/2);

    glTexCoord2F(0,0);
    glVertex2F(X-W/2,Y-H/2);

    glTexCoord2F(0,Repeats);
    glVertex2F(X+W/2,Y-H/2);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X+W/2,Y+H/2);
  glEnd;
end;


procedure RenderTexturedRectangleRotatedAndFlipped(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(0,Repeats);
    glVertex2F(X-W/2,Y+H/2);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X-W/2,Y-H/2);

    glTexCoord2F(Repeats,0);
    glVertex2F(X+W/2,Y-H/2);

    glTexCoord2F(0,0);
    glVertex2F(X+W/2,Y+H/2);
  glEnd;
end;

procedure RenderTexturedRectangleRotatedAndMirrored(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(Repeats,0);
    glVertex2F(X-W/2,Y+H/2);

    glTexCoord2F(0,0);
    glVertex2F(X-W/2,Y-H/2);

    glTexCoord2F(0,Repeats);
    glVertex2F(X+W/2,Y-H/2);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X+W/2,Y+H/2);
  glEnd;
end;

procedure RenderTexturedRectangleRotatedMirroredAndFlipped(X,Y,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(0,0);
    glVertex2F(X-W/2,Y+H/2);

    glTexCoord2F(Repeats,0);
    glVertex2F(X-W/2,Y-H/2);

    glTexCoord2F(Repeats,Repeats);
    glVertex2F(X+W/2,Y-H/2);

    glTexCoord2F(0,Repeats);
    glVertex2F(X+W/2,Y+H/2);
  glEnd;
end;

procedure RenderTexturedRectangleAtZ(X,Y,Z,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(0,Repeats);
    glVertex3F(X-W/2,Y+H/2,Z);

    glTexCoord2F(0,0);
    glVertex3F(X-W/2,Y-H/2,Z);

    glTexCoord2F(Repeats,0);
    glVertex3F(X+W/2,Y-H/2,Z);

    glTexCoord2F(Repeats,Repeats);
    glVertex3F(X+W/2,Y+H/2,Z);
  glEnd;
end;

procedure RenderTextured3DRectangle(X,Y,Z,W,H,Repeats:Single);
begin
  glBegin(GL_QUADS);
    glTexCoord2F(0,Repeats);
    glVertex3F(X-W/2,Y,Z+H/2);

    glTexCoord2F(0,0);
    glVertex3F(X-W/2,Y,Z-H/2);

    glTexCoord2F(Repeats,0);
    glVertex3F(X+W/2,Y,Z-H/2);

    glTexCoord2F(Repeats,Repeats);
    glVertex3F(X+W/2,Y,Z+H/2);
  glEnd;
end;

procedure RenderMultiTexturedRectangle(X,Y,W,H,R1,R2:Single);
begin
  glBegin(GL_QUADS);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,0,R1);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,0,R2);
    glVertex2F(X-W/2,Y+H/2);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,0,0);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,0,0);
    glVertex2F(X-W/2,Y-H/2);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,R1,0);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,R2,0);
    glVertex2F(X+W/2,Y-H/2);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,R1,R1);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,R2,R2);
    glVertex2F(X+W/2,Y+H/2);
  glEnd;
end;

procedure RenderMultiTexturedRectangleFlipped(X,Y,W,H,R1,R2:Single);
begin
  glBegin(GL_QUADS);
    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,0,0);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,0,0);
    glVertex2F(X+W/2,Y+H/2);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,0,R1);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,0,R2);
    glVertex2F(X+W/2,Y-H/2);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,R1,R1);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,R2,R2);
    glVertex2F(X-W/2,Y-H/2);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,R1,0);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,R2,0);
    glVertex2F(X-W/2,Y+H/2);
  glEnd;
end;


procedure RenderMultiTexturedRectangleAtZ(X,Y,Z,W,H,R1,R2:Single);
begin
  glBegin(GL_QUADS);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,0,R1);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,0,R2);
    glVertex3F(X-W/2,Y+H/2,Z);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,0,0);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,0,0);
    glVertex3F(X-W/2,Y-H/2,Z);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,R1,0);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,R2,0);
    glVertex3F(X+W/2,Y-H/2,Z);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,R1,R1);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,R2,R2);
    glVertex3F(X+W/2,Y+H/2,Z);
  glEnd;
end;

procedure RenderMultiTextured3DRectangle(X,Y,Z,W,H,R1,R2:Single);
begin
  glBegin(GL_QUADS);
    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,0,R1);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,0,R2);
    glVertex3F(X-W/2,Y+H/2,Z);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,0,0);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,0,0);
    glVertex3F(X-W/2,Y-H/2,Z);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,R1,0);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,R2,0);
    glVertex3F(X+W/2,Y-H/2,Z);

    glMultiTexCoord2fArb(GL_TEXTURE0_ARB,R1,R1);
    glMultiTexCoord2fArb(GL_TEXTURE1_ARB,R2,R2);
    glVertex3F(X+W/2,Y+H/2,Z);
  glEnd;
end;

procedure EnableAlpha;
begin
  glShadeModel(GL_FLAT);
  glDepthMask(False);
  glDisable(GL_DEPTH_TEST);

  glEnable(GL_BLEND);
  glTexEnvF(GL_TEXTURE_ENV,GL_TEXTURE_ENV_COLOR,GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
end;

procedure DisableAlpha;
begin
  glDisable(GL_BLEND);
  glShadeModel(GL_SMOOTH);
  glDepthMask(True);
end;

procedure EnableTextures;
begin
  glColor4UB(255,255,255,255);
  glEnable(GL_TEXTURE_2D);

// set it to repeat in S and T
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);

// set the filters
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
end;

procedure DisableTextures;
begin
  glDisable(GL_TEXTURE_2D);
end;

end.


