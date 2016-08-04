unit SphereU;

interface

uses
  Classes, OpenGLTokens, OpenGL1X, Global, Math, Math3D, Protocol;

type
  TSphereSection = record
    Stack1,Stack2 : Integer;
    Slice1,Slice2 : Integer;
  end;

  TVertex = record
    X,Y,Z  : Single;
    S,T    : Single;
    Sf,Tf  : Single;
    Normal : TPoint3D;
    A      : Single;
  end;
  PVertex = ^TVertex;

  TVertexArray = array[1..MaxSlices,1..MaxStacks] of TVertex;

  TSphere = class(TObject)
  private
    DLIndex : GLUInt;

    procedure CreateDisplayList;
    procedure FreeDisplayList;


    procedure FindVertexNormal(Vtx1,Vtx2,Vtx3:PVertex);
    procedure RenderWireSlices(S1,S2:Integer);
    procedure RenderSliceNormals(S1, S2: Integer);
    procedure RenderSlices(Stack, S1, S2: Integer);
    procedure RenderSlicesForPerlin(Stack, S1, S2: Integer);

    procedure CalculateSideVertices;
    procedure CalculateCapVertices;
    procedure FindAlphaOfVertices;
    function RadialFadeStack: Integer;
    function RadialFadeRange: Integer;
  public
    Vertices : Integer;
    Vertex : TVertexArray;

    CamPose : TPose;
    CamFOV  : Single;

    SOffset  : Single;
    TOffset  : Single;
    Radius   : Single;
    RzOffset : Single;

    Slice1,Slice2 : Integer;
    Stack1,Stack2 : Integer;

    Flat : Boolean;

    Orientation : TPoint3D;

    Placement : TPlacement;
    EndAngle  : Single;

    SpotSliceAngle : Single;
    SpotStackAngle : Single;

    RadialFade : TEdgeFade;

    XFade : TFade;
    YFade : TFade;

    XScale : Single;
    YScale : Single;

    constructor Create;

    procedure RenderTextured2;
    procedure RenderScaledAndOffset2(Scale, Offset: TStRecord;
      Orbit: TSlaveOrbit; PolarScale: Single);

    procedure RenderScaledAndOffsetWithFade(Scale,Offset:TStRecord;
                                            Orbit:TSlaveOrbit;
                                            PolarScale,Alpha:Single);
    procedure RenderTexturedWithFade(Orbit: TSlaveOrbit);

    procedure RenderWireFrame;
    procedure RenderTextured(Orbit:TSlaveOrbit);
    procedure RenderTexturedForDisplayList(Orbit:TSlaveOrbit);
    procedure Render;
    procedure RenderForPerlin(Rz:Single);
    procedure RenderAsDisk;
    procedure RenderSpot(Size:Single);
    procedure RenderSpot2(Size:Single);
    procedure RenderPolarSpot(Size, Rz: Single);

    procedure PlaceCamera;
    procedure CalculateVertices;

    procedure FindNormals;
    procedure RenderNormals;
    procedure ApplyRotation;

    procedure SetToDefault;
    procedure SetToCubeMapDefault;
    procedure WriteToStream(Stream:TFileStream);
    procedure ReadFromStream(Stream:TFileStream);
    procedure InitFromSetupData(Data:TSphereSetupData);
    procedure RenderScaledAndOffset(Scale,Offset:TStRecord;Orbit:TSlaveOrbit;PolarScale:Single);
    procedure RenderScaledAndOffsetWithBlend(Scale,Offset:TStRecord;Orbit:TSlaveOrbit;PolarScale,Alpha:Single);
    procedure ShowRadialFade;
    procedure ShowYFade;
  end;

implementation



constructor TSphere.Create;
begin
  inherited;

  Radius:=5;
  SpotSliceAngle:=Pi;
  SpotStackAngle:=0;

  XScale:=1;
  YScale:=1;

  FillChar(Orientation,SizeOf(Orientation),0);
end;

procedure TSphere.SetToCubeMapDefault;
begin
  FillChar(CamPose,SizeOf(CamPose),0);
  CamFOV:=DegToRad(45);
  Placement:=ptSide;

  EndAngle:=DegToRad(45);

  Slice1:=1;
  Slice2:=MaxSlices;
  Stack1:=1;
  Stack2:=MaxStacks;

  CalculateVertices;
end;

procedure TSphere.SetToDefault;
begin
  FillChar(CamPose,SizeOf(CamPose),0);
  CamFOV:=DegToRad(45);
  Placement:=ptUnder;

  EndAngle:=DegToRad(45);

  Slice1:=1;
  Slice2:=MaxSlices;
  Stack1:=1;
  Stack2:=MaxStacks;

  CalculateVertices;
end;

procedure TSphere.WriteToStream(Stream:TFileStream);
begin
// pose
  Stream.Write(CamPose,SizeOf(CamPose));
  Stream.Write(CamFOV,SizeOf(CamFOV));
  Stream.Write(Radius,SizeOf(Radius));
  Stream.Write(Stack1,SizeOf(Stack1));
  Stream.Write(Stack2,SizeOf(Stack2));
  Stream.Write(Slice1,SizeOf(Slice1));
  Stream.Write(Slice2,SizeOf(Slice2));
  Stream.Write(Placement,SizeOf(Placement));
  Stream.Write(EndAngle,SizeOf(EndAngle));
  Stream.Write(SOffset,SizeOf(SOffset));
  Stream.Write(RzOffset,SizeOf(RzOffset));
  Stream.Write(XFade,SizeOf(XFade));
  Stream.Write(YFade,SizeOf(YFade));
  Stream.Write(RadialFade,SizeOf(RadialFade));
  Stream.Write(XScale,SizeOf(XScale));
  Stream.Write(YScale,SizeOf(YScale));
end;

procedure TSphere.ReadFromStream(Stream:TFileStream);
begin
// pose
  Stream.Read(CamPose,SizeOf(CamPose));
  Stream.Read(CamFOV,SizeOf(CamFOV));
  Stream.Read(Radius,SizeOf(Radius));
  Stream.Read(Stack1,SizeOf(Stack1));
  Stream.Read(Stack2,SizeOf(Stack2));
  Stream.Read(Slice1,SizeOf(Slice1));
  Stream.Read(Slice2,SizeOf(Slice2));
  Stream.Read(Placement,SizeOf(Placement));
  Stream.Read(EndAngle,SizeOf(EndAngle));
  Stream.Read(SOffset,SizeOf(SOffset));
  Stream.Read(RzOffset,SizeOf(RzOffset));
  Stream.Read(XFade,SizeOf(XFade));
  Stream.Read(YFade,SizeOf(YFade));
  XFade.Enabled:=False;
  Stream.Read(RadialFade,SizeOf(RadialFade));

  Stream.Read(XScale,SizeOf(XScale));
  Stream.Read(YScale,SizeOf(YScale));

  Case Placement of
    ptUnder : CalculateCapVertices;
    ptSide  : CalculateVertices;
  end;
end;

procedure TSphere.PlaceCamera;
begin
end;

procedure TSphere.RenderWireSlices(S1,S2:Integer);
var
  Slice,Stack : Integer;
begin
  for Slice:=S1 to S2 do begin
    glBegin(GL_LINE_STRIP);
      for Stack:=Stack1 to Stack2 do begin
        with Vertex[Slice,Stack] do glVertex3f(X,Y,Z);
      end;
    glEnd();
  end;
end;

procedure TSphere.RenderWireFrame;
var
  Stack : Integer;
  Slice : Integer;
begin
  glDisable(GL_LIGHTING);
  glDisable(GL_TEXTURE_2D);
  glDisable(GL_TEXTURE_CUBE_MAP_EXT);
  glColor3f(1,1,1);
  glLineWidth(1);

  glScaleF(XScale,YScale,1.0);

// do the horizontal loops
  for Stack:=Stack1 to Stack2 do begin

// last one is green
    if Stack=Stack2 then glColor3F(0,1,0)

// 2nd from last is blue
    else if Stack=Stack2-1 then glColor3F(0,0,1)

// 3rd from last is red
    else if Stack=Stack2-2 then glColor3F(1,0,1)

// the rest are white
    else glColor3F(1,1,1);

    if (Slice1=1) and (Slice2=MaxSlices) then glBegin(GL_LINE_LOOP)
    else glBegin(GL_LINE_STRIP);
      if Slice2>Slice1 then begin
        for Slice:=Slice1 to Slice2 do begin
          with Vertex[Slice,Stack] do glVertex3f(X,Y,Z);
        end;
      end
      else begin
        for Slice:=Slice1 to MaxSlices do begin
          with Vertex[Slice,Stack] do glVertex3f(X,Y,Z);
        end;
        for Slice:=1 to Slice2 do begin
          with Vertex[Slice,Stack] do glVertex3f(X,Y,Z);
        end;
      end;
    glEnd;
  end;
  glLineWidth(1);
  glColor3f(1.0, 1.0, 1.0);

// do the radial beams
  if Slice2>Slice1 then RenderWireSlices(Slice1,Slice2)
  else begin
    RenderWireSlices(Slice1,MaxSlices);
    RenderWireSlices(1,Slice2);
  end;
end;

procedure TSphere.RenderSliceNormals(S1,S2:Integer);
var
  Slice,Stack   : Integer;
  StartPt,EndPt : TPoint3D;
  R             : Single;
begin
  R:=Radius/10;
  for Slice:=S1 to S2 do begin
    glBegin(GL_LINE_STRIP);
      for Stack:=Stack1 to Stack2 do begin
        with Vertex[Slice,Stack] do begin
          StartPt.X:=X-R*Normal.X;
          StartPt.Y:=Y-R*Normal.Y;
          StartPt.Z:=Z-R*Normal.Z;

          EndPt.X:=X+R*Normal.X;
          EndPt.Y:=Y+R*Normal.Y;
          EndPt.Z:=Z+R*Normal.Z;

          glVertex3F(StartPt.X,StartPt.Y,StartPt.Z);
          glVertex3F(EndPt.X,EndPt.Y,EndPt.Z);
        end;
      end;
    glEnd();
  end;
end;

procedure TSphere.RenderNormals;
begin
  glColor3f(1,1,1);
  glLineWidth(1);

  glBegin(GL_LINES);
    if Slice2>Slice1 then RenderSliceNormals(Slice1,Slice2)
    else begin
      RenderSliceNormals(Slice1,MaxSlices);
      RenderSliceNormals(1,Slice2);
    end;
  glEnd();
end;

procedure TSphere.RenderSlices(Stack,S1,S2:Integer);
var
  Slice : Integer;
  Vtx1  : TVertex;
  Vtx2  : TVertex;
begin
  for Slice:=S1 to S2 do begin
    Vtx1:=Vertex[Slice,Stack];
    Vtx2:=Vertex[Slice,Stack+1];

    with Vtx1 do begin
      glNormal3F(Normal.X,Normal.Y,Normal.Z);
      glVertex3F(X,Y,Z);
    end;

    with Vtx2 do begin
      glNormal3F(Normal.X,Normal.Y,Normal.Z);
      glVertex3F(X,Y,Z);
    end;
  end;
end;

procedure TSphere.Render;
var
  Slice : Integer;
  Stack : Integer;
  Vtx   : TVertex;
begin
  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);
      if Slice2>Slice1 then RenderSlices(Stack,Slice1,Slice2)
      else begin
        RenderSlices(Stack,Slice1,MaxSlices);
        RenderSlices(Stack,1,Slice2);
      end;

// close it off
      if Slice2=MaxSlices then Slice:=1
      else Slice:=Slice2+1;

      Vtx:=Vertex[Slice,Stack];
      with Vtx do begin
        glNormal3F(Normal.X,Normal.Y,Normal.Z);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice,Stack+1];
      with Vtx do begin
        glNormal3F(Normal.X,Normal.Y,Normal.Z);
        glVertex3F(X,Y,Z);
      end;
    glEnd;
  end;
end;

procedure TSphere.RenderSlicesForPerlin(Stack,S1,S2:Integer);
var
  Slice : Integer;
  Vtx1  : TVertex;
  Vtx2  : TVertex;
begin
  for Slice:=S1 to S2 do begin
    Vtx1:=Vertex[Slice,Stack];
    Vtx2:=Vertex[Slice,Stack+1];

    with Vtx1 do begin
      glVertex3F(X,Y,Z);
    end;

    with Vtx2 do begin
      glVertex3F(X,Y,Z);
    end;
  end;
end;

procedure TSphere.RenderForPerlin(Rz:Single);
var
  Slice : Integer;
  Stack : Integer;
begin
  glColor3f(1,1,1);

  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);
      if Slice2>Slice1 then RenderSlicesForPerlin(Stack,Slice1,Slice2)
      else begin
        RenderSlicesForPerlin(Stack,Slice1,MaxSlices);
        RenderSlicesForPerlin(Stack,1,Slice2);
      end;

// close it off
      if Slice2=MaxSlices then Slice:=1
      else Slice:=Slice2+1;

      with Vertex[Slice,Stack] do glVertex3F(X,Y,Z);
      with Vertex[Slice,Stack+1] do glVertex3F(X,Y,Z);

    glEnd;
  end;
end;

procedure TSphere.RenderAsDisk;
var
  Slice : Integer;
  Stack : Integer;
  Vtx   : TVertex;
begin
  glColor3f(1,1,1);

  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);
      if Slice2>Slice1 then RenderSlices(Stack,Slice1,Slice2)
      else begin
        RenderSlices(Stack,Slice1,MaxSlices);
        RenderSlices(Stack,1,Slice2);
      end;

// close it off
      if Slice2=MaxSlices then Slice:=1
      else Slice:=Slice2+1;

      Vtx:=Vertex[Slice,Stack];
      with Vtx do begin
        glNormal3F(0,0,1);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice,Stack+1];
      with Vtx do begin
        glNormal3F(0,0,1);
        glVertex3F(X,Y,Z);
      end;
    glEnd;
  end;
end;

procedure TSphere.FindAlphaOfVertices;
var
  Stack  : Integer;
  Slice  : Integer;
  Vtx    : PVertex;
  F      : Single;
  RStack : Integer;
  RRange : Integer;
begin
  RStack:=RadialFadeStack;
  RRange:=RadialFadeRange;
  for Stack:=Stack1 to Stack2-1 do for Slice:=Slice1 to Slice2 do begin
    with Vertex[Slice,Stack] do begin
      A:=1.0;

// factor in the XFade if X is within the band
      if XFade.Enabled then begin

// left side
        if (X<0) and (XFade.Min<0) then begin
          F:=(X-XFade.Min)/(XFade.Max-XFade.Min);
          if F<0 then A:=0
          else if F<1 then A:=A*F;
        end

// right side
        else if (X>0) and (XFade.Min>0) then begin
          F:=(XFade.Max-X)/(XFade.Max-XFade.Min);
          if F<0 then A:=0
          else if F<1 then A:=A*F;
        end;
      end;

// factor in the YFade if Y is within the band
      if YFade.Enabled then begin

// top
        if (Y>0) and (YFade.Min>0) then begin
          F:=(YFade.Max-Y)/(YFade.Max-YFade.Min);
          if F<0 then A:=0
          else if F<1 then A:=A*F;
        end
        else if (Y<0) and (YFade.Min<0) then begin
          F:=(Y-YFade.Min)/(YFade.Max-YFade.Min);
          if F<0 then A:=0
          else if F<1 then A:=A*F;
        end;
      end;

// factor in the radial fade
      if RadialFade.Enabled then begin
        if (Stack+1)>=RStack then begin
          F:=(Stack2-Stack)/RRange;
          if F<0 then A:=0
          else if F<1 then A:=A*F;
        end;
      end;
    end;
  end;
end;

procedure TSphere.RenderScaledAndOffsetWithFade(Scale,Offset:TStRecord;
                                                Orbit:TSlaveOrbit;
                                                PolarScale,Alpha:Single);
var
  Stack      : Integer;
  Slice      : Integer;
  Vtx        : TVertex;
  A,S,T      : Single;
begin
  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);
      for Slice:=Slice1 to Slice2 do begin
        Vtx:=Vertex[Slice,Stack];
        with Vtx do begin
          glColor4F(1,1,1,Alpha*A);
          S:=(Sf+Offset.S)*Scale.S;
          T:=(Tf+Offset.T)*Scale.T;
          glTexCoord2f(S,T);
          glVertex3f(X,Y,Z);
        end;

        Vtx:=Vertex[Slice,Stack+1];
        with Vtx do begin
          glColor4F(1,1,1,Alpha*A);
          S:=(Sf+Offset.S)*Scale.S;
          T:=(Tf+Offset.T)*Scale.T;
          glTexCoord2f(S,T);
          glVertex3f(X,Y,Z);
        end;
      end;

// close it off
      Vtx:=Vertex[Slice1,Stack];
      with Vtx do begin
        glColor4F(1,1,1,Alpha*A);
        S:=(Sf+Offset.S)*Scale.S;
        T:=(Tf+Offset.T)*Scale.T;
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice1,Stack+1];
      with Vtx do begin
        glColor4F(1,1,1,Alpha*A);
        S:=(Sf+Offset.S)*Scale.S;
        T:=(Tf+Offset.T)*Scale.T;
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

    glEnd();
  end;
end;

procedure TSphere.RenderScaledAndOffsetWithBlend(Scale,Offset:TStRecord;
                                                 Orbit:TSlaveOrbit;
                                                 PolarScale,Alpha:Single);
var
  Stack      : Integer;
  Slice      : Integer;
  Vtx        : TVertex;
  A          : Single;
  BlendStack : Integer;
  BlendRange : Integer;
begin
  BlendRange:=Round((1-EdgeFade.StartF)*Stack2);
  BlendStack:=Stack2-BlendRange;

  if Orbit=soPolar then begin
    glPushMatrix();
    glRotatef(-PolarScale*SOffset*360, 0, 0, 1);
    Offset.S:=0;
    Offset.T:=0;
  end;

  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);

      if (Stack+1)>=BlendStack then begin
        A:=Alpha*(Stack2-Stack)/BlendRange;
        glColor4F(1,1,1,A);
      end;

      for Slice:=Slice1 to Slice2 do begin
        Vtx:=Vertex[Slice,Stack];
        with Vtx do begin
          S:=(Sf+Offset.S)*Scale.S;
          T:=(Tf+Offset.T)*Scale.T;
          glTexCoord2f(S,T);
          glVertex3f(X,Y,Z);
        end;


        Vtx:=Vertex[Slice,Stack+1];
        with Vtx do begin
          S:=(Sf+Offset.S)*Scale.S;
          T:=(Tf+Offset.T)*Scale.T;
          glTexCoord2f(S,T);
          glVertex3f(X,Y,Z);
        end;
      end;

// close it off
      Vtx:=Vertex[Slice1,Stack];
      with Vtx do begin
        S:=(Sf+Offset.S)*Scale.S;
        T:=(Tf+Offset.T)*Scale.T;
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice1,Stack+1];
      with Vtx do begin
        S:=(Sf+Offset.S)*Scale.S;
        T:=(Tf+Offset.T)*Scale.T;
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

    glEnd();
  end;

  if Placement=ptUnder then glPopMatrix();
end;

// for rendering a texture (image or reaction diffusion)
procedure TSphere.RenderScaledAndOffset(Scale,Offset:TStRecord;Orbit:TSlaveOrbit;
                                        PolarScale:Single);
var
  Stack : Integer;
  Slice : Integer;
  Vtx   : TVertex;
  S,T   : Single;
begin
  if Orbit=soPolar then begin
    glPushMatrix();
    glRotatef(-PolarScale*Offset.S*360, 0, 0, 1);
    Offset.S:=0;
    Offset.T:=0;
  end;

  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);

      for Slice:=Slice1 to Slice2 do begin
        Vtx:=Vertex[Slice,Stack];
        with Vtx do begin
          S:=(Sf+Offset.S)*Scale.S;
          T:=(Tf+Offset.T)*Scale.T;
          glTexCoord2f(S,T);
          glVertex3f(X,Y,Z);
        end;

        Vtx:=Vertex[Slice,Stack+1];
        with Vtx do begin
          S:=(Sf+Offset.S)*Scale.S;
          T:=(Tf+Offset.T)*Scale.T;
          glTexCoord2f(S,T);
          glVertex3f(X,Y,Z);
        end;
      end;

// close it off
      Vtx:=Vertex[Slice1,Stack];
      with Vtx do begin
        S:=(Sf+Offset.S)*Scale.S;
        T:=(Tf+Offset.T)*Scale.T;
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice1,Stack+1];
      with Vtx do begin
        S:=(Sf+Offset.S)*Scale.S;
        T:=(Tf+Offset.T)*Scale.T;
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

    glEnd();
  end;

  if Placement=ptUnder then glPopMatrix();
end;

// for rendering a texture (image or reaction diffusion)
procedure TSphere.RenderScaledAndOffset2(Scale,Offset:TStRecord;Orbit:TSlaveOrbit;
                                         PolarScale:Single);
var
  Stack : Integer;
  Slice : Integer;
  Vtx   : TVertex;
  S,T   : Single;
begin
  glScaleF(XScale,YScale,1.0);

  if Orbit=soPolar then begin
    glPushMatrix();
    glRotatef(-PolarScale*Offset.S*360, 0, 0, 1);
    Offset.S:=0;
    Offset.T:=0;
  end;

  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);

      for Slice:=Slice1 to Slice2 do begin
        Vtx:=Vertex[Slice,Stack];
        with Vtx do begin
          glColor4F(1,1,1,A);
          S:=(Sf+Offset.S)*Scale.S;
          T:=(Tf+Offset.T)*Scale.T;
          glTexCoord2f(S,T);
          glVertex3f(X,Y,Z);
        end;

        Vtx:=Vertex[Slice,Stack+1];
        with Vtx do begin
          glColor4F(1,1,1,A);
          S:=(Sf+Offset.S)*Scale.S;
          T:=(Tf+Offset.T)*Scale.T;
          glTexCoord2f(S,T);
          glVertex3f(X,Y,Z);
        end;
      end;

// close it off
      Vtx:=Vertex[Slice1,Stack];
      with Vtx do begin
        glColor4F(1,1,1,A);
        S:=(Sf+Offset.S)*Scale.S;
        T:=(Tf+Offset.T)*Scale.T;
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice1,Stack+1];
      with Vtx do begin
        glColor4F(1,1,1,A);
        S:=(Sf+Offset.S)*Scale.S;
        T:=(Tf+Offset.T)*Scale.T;
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

    glEnd();
  end;

  if Orbit=soPolar then glPopMatrix();
end;

procedure TSphere.RenderTexturedWithFade(Orbit:TSlaveOrbit);
var
  Stack  : Integer;
  Slice  : Integer;
  Vtx    : TVertex;
  Offset : Single;
begin
  Offset:=0;
  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);

      for Slice:=Slice1 to Slice2 do begin
        Vtx:=Vertex[Slice,Stack];
        with Vtx do begin
          glColor4F(1,1,1,A);
          glTexCoord2f(Sf+Offset,Tf);
          glVertex3f(X,Y,Z);
        end;

        Vtx:=Vertex[Slice,Stack+1];
        with Vtx do begin
          glColor4F(1,1,1,A);
          glTexCoord2f(Sf+Offset,Tf);
          glVertex3f(X,Y,Z);
        end;
      end;

// close it off
      Vtx:=Vertex[Slice1,Stack];
      with Vtx do begin
        glColor4F(1,1,1,A);
        glTexCoord2f(Sf+Offset,Tf);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice1,Stack+1];
      with Vtx do begin
        glColor4F(1,1,1,A);
        glTexCoord2f(Sf+Offset,Tf);
        glVertex3F(X,Y,Z);
      end;

    glEnd();
  end;
end;

procedure TSphere.RenderTextured2;
//(Orbit:TSlaveOrbit;iProjector:TProjector);
var
  Stack : Integer;
  Slice : Integer;
  Vtx   : TVertex;
begin
  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);

      for Slice:=Slice1 to Slice2 do begin
        Vtx:=Vertex[Slice,Stack];
        with Vtx do begin
          glColor4F(1,1,1,A);
          glTexCoord2f(Sf+SOffset,Tf+TOffset);
          glVertex3f(X,Y,Z);
        end;

        Vtx:=Vertex[Slice,Stack+1];
        with Vtx do begin
          glColor4F(1,1,1,A);
          glTexCoord2f(Sf+SOffset,Tf+TOffset);
          glVertex3f(X,Y,Z);
        end;
      end;

// close it off
      Vtx:=Vertex[Slice1,Stack];
      with Vtx do begin
        glColor4F(1,1,1,A);
        glTexCoord2f(Sf+SOffset,Tf+TOffset);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice1,Stack+1];
      with Vtx do begin
        glColor4F(1,1,1,A);
        glTexCoord2f(Sf+SOffset,Tf+TOffset);
        glVertex3F(X,Y,Z);
      end;

    glEnd();
  end;
end;

procedure TSphere.RenderTextured(Orbit:TSlaveOrbit);
begin
  RenderTexturedForDisplayList(Orbit);
end;

procedure TSphere.RenderTexturedForDisplayList(Orbit:TSlaveOrbit);
var
  Stack  : Integer;
  Slice  : Integer;
  Vtx    : TVertex;
  Offset : Single;
begin
{  if Orbit=soPolar then begin
    glPushMatrix();
//    glRotatef(-RotateScale*Rotation.Scroll*360, 0, 0, 1);
    Offset:=SOffset;
  end
  else Offset:=SOffset+Rotation.Scroll;
 }
  Offset:=0;
  for Stack:=Stack1 to Stack2-1 do begin
    glBegin(GL_TRIANGLE_STRIP);

      for Slice:=Slice1 to Slice2 do begin
        Vtx:=Vertex[Slice,Stack];
        with Vtx do begin
          glTexCoord2f(Sf+Offset,Tf);
          glVertex3f(X,Y,Z);
        end;

        Vtx:=Vertex[Slice,Stack+1];
        with Vtx do begin
          glTexCoord2f(Sf+Offset,Tf);
          glVertex3f(X,Y,Z);
        end;
      end;

// close it off
      Vtx:=Vertex[Slice1,Stack];
      with Vtx do begin
        glTexCoord2f(Sf+Offset,Tf);
        glVertex3F(X,Y,Z);
      end;

      Vtx:=Vertex[Slice1,Stack+1];
      with Vtx do begin
        glTexCoord2f(Sf+Offset,Tf);
        glVertex3F(X,Y,Z);
      end;

    glEnd();
  end;

 //if Orbit=soPolar then glPopMatrix();
end;

procedure TSphere.FindVertexNormal(Vtx1,Vtx2,Vtx3:PVertex);
var
  Pt1,Pt2,Pt3 : TPoint3D;
begin
  Pt1.X:=Vtx1^.X;
  Pt1.Y:=Vtx1^.Y;
  Pt1.Z:=Vtx1^.Z;

  Pt2.X:=Vtx2^.X;
  Pt2.Y:=Vtx2^.Y;
  Pt2.Z:=Vtx2^.Z;

  Pt3.X:=Vtx3^.X;
  Pt3.Y:=Vtx3^.Y;
  Pt3.Z:=Vtx3^.Z;

  Vtx1^.Normal:=FindNormal(Pt1,Pt2,Pt3);
end;

procedure TSphere.FindNormals;
var
  Stack : Integer;
  Slice : Integer;
begin
  for Stack:=Stack1 to Stack2 do for Slice:=Slice1 to Slice2 do begin
    with Vertex[Slice,Stack] do begin
      Normal.X:=X;
      Normal.Y:=Y;
      Normal.Z:=Z;
      Normalize(Normal);
      if Placement=ptSide then Negate(Normal);
    end;
  end;
  ApplyRotation;
end;

procedure TSphere.ApplyRotation;
var
  Slice,Stack : Integer;
begin
  for Stack:=Stack1 to Stack2 do for Slice:=Slice1 to Slice2 do begin
    Rotate3DPointRx(Vertex[Slice,Stack].Normal,Orientation.X);
    Rotate3DPointRy(Vertex[Slice,Stack].Normal,Orientation.Y);
    Rotate3DPoint(Vertex[Slice,Stack].Normal,Orientation.Z);
  end;
end;

procedure TSphere.CalculateVertices;
begin
  Case Placement of
    ptUnder : CalculateCapVertices;
    ptSide  : CalculateSideVertices;
  end;
end;

procedure TSphere.CalculateSideVertices;
var
  SliceA        : Single;
  SliceAngleInc : Single;
  StackAngle    : Single;
  StackAngleInc : Single;
  Zm,R,Xm,Ym    : Single;
  Stack,Slice   : Integer;
begin
  SliceAngleInc:=(2*PI)/(MaxSlices-1);
  StackAngleInc:=Pi/(MaxStacks-1);

  StackAngle:=0;

  for Stack:=1 to MaxStacks do begin
    Zm:=-Radius*(1-Cos(StackAngle));
    R:=Radius*Sin(StackAngle);

    SliceA:=0;

    for Slice:=1 to MaxSlices do begin

// set the X,Y,Z location
      Xm:=R*Cos(SliceA);
      Ym:=R*Sin(SliceA);

      Vertex[Slice,Stack].X:=Xm;
      Vertex[Slice,Stack].Y:=Ym;
      Vertex[Slice,Stack].Z:=Zm+Radius;

      SliceA:=SliceA+SliceAngleInc;
    end;
    StackAngle:=StackAngle+StackAngleInc;
  end;
  FindNormals;
  FindAlphaOfVertices;
end;

procedure TSphere.CreateDisplayList;
begin
  DLIndex:=glGenLists(1);
  if DLIndex>0 then begin
    glNewList(DLIndex, GL_COMPILE);
      Render;
    glEndList();
  end;
end;

procedure TSphere.FreeDisplayList;
begin
  if DLIndex>0 then begin
    glDeleteLists(DLIndex,1);
  end;
end;

procedure TSphere.CalculateCapVertices;
const
  SScale = 1.0;
  TScale = 1.0;
var
  SliceA        : Single;
  SliceAngleInc : Single;
  StackAngle    : Single;
  StackAngleInc : Single;
  Zm,R,Xm,Ym    : Single;
  Stack,Slice   : Integer;
begin
  SliceAngleInc:=(2*PI)/(MaxSlices-1);
  StackAngleInc:=EndAngle/(MaxStacks-1);

  StackAngle:=0;

  for Stack:=1 to MaxStacks do begin
    Zm:=Radius*Cos(StackAngle);

    R:=Radius*Sin(StackAngle);

    SliceA:=0;

    for Slice:=1 to MaxSlices do begin

// set the X,Y,Z location
      Xm:=R*Cos(SliceA);
      Ym:=R*Sin(SliceA);

      Vertex[Slice,Stack].X:=Xm;
      Vertex[Slice,Stack].Y:=Ym;
      Vertex[Slice,Stack].Z:=Zm;

// set the texture S,T
      Vertex[Slice,Stack].Sf:=0.5*(1+Xm/Radius)*SScale;
      Vertex[Slice,Stack].Tf:=0.5*(1+Ym/Radius)*TScale;

// mirrored
//      (*vtx).sfm = 0.5 * (1 - xm/sphereR) * tScale;
//      (*vtx).tfm = 0.5 * (1 + ym/sphereR) * tScale;

      SliceA:=SliceA+SliceAngleInc;
    end;
    StackAngle:=StackAngle+StackAngleInc;
  end;
  FindNormals;
  FindAlphaOfVertices;
end;

procedure TSphere.InitFromSetupData(Data:TSphereSetupData);
begin
  Radius:=Data.Radius;
  Stack1:=Data.Stack1;
  Stack2:=Data.Stack2;
  Slice1:=Data.Slice1;
  Slice2:=Data.Slice2;

  if Stack1>MaxStacks then Stack1:=MaxStacks;
  if Stack2>MaxStacks then Stack2:=MaxStacks;
  if Slice1>MaxSlices then Slice1:=MaxSlices;
  if Slice2>MaxSlices then Slice2:=MaxSlices;

  EndAngle:=Data.EndAngle;
  SOffset:=Data.SOffset;
  RzOffset:=Data.RzOffset;

  YFade:=Data.YFade;
  RadialFade:=Data.RadialFade;

  XScale:=Data.XScale;
  YScale:=Data.YScale;

  CalculateVertices;
end;

// could just do this once at start up and rotate it
procedure TSphere.RenderSpot2(Size:Single);
const
  StackRes = 16;//MaxStacks;
  SliceRes = 16;//MaxSlices;
var
  SInc,TInc,Sc,Tc : Single;
  Xm,Ym,Zm,R,Zc   : Single;
  Origin          : TPoint2D;
  Stack,Slice     : Integer;
  Vtx             : TVertexArray;
  StartSliceAngle : Single;
  EndSliceAngle   : Single;
  StartStackAngle : Single;
  EndStackAngle   : Single;
  SliceAngle      : Single;
  StackAngle      : Single;
  SliceAngleInc   : Single;
  StackAngleInc   : Single;
begin
// calculate how much the angles vary with each step
  SliceAngleInc:=Size/(SliceRes-1);
  StackAngleInc:=Size/(StackRes-1);

// texture coordinates range from 0 -1
  SInc:=1/(SliceRes-1);
  TInc:=1/(StackRes-1);

//  Origin:=XYToPanTilt(X,Y);
  Origin.X:=SpotSliceAngle;
  Origin.Y:=SpotStackAngle;
  //Pi/2;

  StartSliceAngle:=Origin.X-Size/2;
  EndSliceAngle:=Origin.X+Size/2;

  StartStackAngle:=Origin.Y-Size/2;
  EndStackAngle:=Origin.Y+Size/2;

  Tc:=0;
  StackAngle:=StartStackAngle;
  for Stack:=1 to StackRes do begin
    Zc:=Radius*Cos(StackAngle);
    R:=Radius*Sin(StackAngle);

    Sc:=0;
    SliceAngle:=StartSliceAngle;
    for Slice:=1 to SliceRes do begin

// set the X,Y,Z location
      Vtx[Slice,Stack].X:=Zc*Sin(SliceAngle);
      Vtx[Slice,Stack].Y:=R;
      Vtx[Slice,Stack].Z:=Zc;//+Radius;

// set the texture coordinate
      Vtx[Slice,Stack].S:=Sc;
      Vtx[Slice,Stack].T:=Tc;

      SliceAngle:=SliceAngle+SliceAngleInc;
      Sc:=Sc+SInc;
    end;
    StackAngle:=StackAngle+StackAngleInc;
    Tc:=Tc+TInc;
  end;

// draw it
  for Stack:=1 to StackRes-1 do begin

    glBegin(GL_TRIANGLE_STRIP);

    glBegin(GL_LINE_STRIP);

    for Slice:=1 to SliceRes do begin

      with Vtx[Slice,Stack] do begin
        glTexCoord2F(S,T);
        glVertex3F(X,Y,Z);
      end;

      with Vtx[Slice,Stack+1] do begin
        glTexCoord2F(S,T);
        glVertex3F(X,Y,Z);
      end;
    end;

// close it off
    if SliceRes=MaxSlices then begin
      with Vtx[1,1] do begin
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

      with Vtx[1,2] do begin
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;
    end;

    glEnd;
  end;
end;

// could just do this once at start up and rotate it
procedure TSphere.RenderSpot(Size:Single);
const
  StackRes = 16;//MaxStacks;
  SliceRes = 16;//MaxSlices;
var
  SInc,TInc,Sc,Tc : Single;
  R,Zc            : Single;
  Origin          : TPoint2D;
  Stack,Slice     : Integer;
  Vtx             : TVertexArray;
  StartSliceAngle : Single;
  StartStackAngle : Single;
  SliceAngle,Rs   : Single;
  StackAngle      : Single;
  SliceAngleInc   : Single;
  StackAngleInc   : Single;
begin
// calculate how much the angles vary with each step
  SliceAngleInc:=Size/(SliceRes-1);
  StackAngleInc:=Size/(StackRes-1);

// texture coordinates range from 0 -1
  SInc:=1/(SliceRes-1);
  TInc:=1/(StackRes-1);

//  Origin:=XYToPanTilt(X,Y);
  Origin.X:=SpotSliceAngle;
  Origin.Y:=SpotStackAngle;
  //Pi/2;

  StartSliceAngle:=Origin.X-Size/2;
  StartStackAngle:=Origin.Y-Size/2;

  Tc:=0;
  StackAngle:=StartStackAngle;
  Rs:=Radius;//*0.95;
  for Stack:=1 to StackRes do begin
    Zc:=Rs*Cos(StackAngle);
    R:=Rs*Sin(StackAngle);

    Sc:=0;
    SliceAngle:=StartSliceAngle;
    for Slice:=1 to SliceRes do begin

// set the X,Y,Z location
      Vtx[Slice,Stack].X:=Zc*Sin(SliceAngle);
      Vtx[Slice,Stack].Y:=R;
      Vtx[Slice,Stack].Z:=Zc;//+Radius;

// set the texture coordinate
      Vtx[Slice,Stack].S:=Sc;
      Vtx[Slice,Stack].T:=Tc;

      SliceAngle:=SliceAngle+SliceAngleInc;
      Sc:=Sc+SInc;
    end;
    StackAngle:=StackAngle+StackAngleInc;
    Tc:=Tc+TInc;
  end;

// draw it
  for Stack:=1 to StackRes-1 do begin

    glBegin(GL_TRIANGLE_STRIP);
    for Slice:=1 to SliceRes do begin

      with Vtx[Slice,Stack] do begin
        glTexCoord2F(S,T);
        glVertex3F(X,Y,Z);
      end;

      with Vtx[Slice,Stack+1] do begin
        glTexCoord2F(S,T);
        glVertex3F(X,Y,Z);
      end;
    end;

// close it off
    if SliceRes=MaxSlices then begin
      with Vtx[1,1] do begin
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

      with Vtx[1,2] do begin
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;
    end;
    glEnd;
  end;
end;

// could just do this once at start up and rotate it
procedure TSphere.RenderPolarSpot(Size:Single;Rz:Single);
const
  StackRes = 16;//MaxStacks;
  SliceRes = 16;//MaxSlices;
var
  SInc,TInc,Sc,Tc : Single;
  R,Zc            : Single;
  Origin          : TPoint2D;
  Stack,Slice     : Integer;
  Vtx             : TVertexArray;
  StartSliceAngle : Single;
  StartStackAngle : Single;
  SliceAngle,Rs   : Single;
  StackAngle      : Single;
  SliceAngleInc   : Single;
  StackAngleInc   : Single;
begin
// calculate how much the angles vary with each step
  SliceAngleInc:=Size/(SliceRes-1);
  StackAngleInc:=Size/(StackRes-1);

// texture coordinates range from 0 -1
  SInc:=1/(SliceRes-1);
  TInc:=1/(StackRes-1);

//  Origin:=XYToPanTilt(X,Y);
  Origin.X:=SpotSliceAngle;
  Origin.Y:=SpotStackAngle;
  //Pi/2;

  StartSliceAngle:=Origin.X-Size/2;
  StartStackAngle:=Origin.Y-Size/2;

  Tc:=0;
  StackAngle:=StartStackAngle;
  Rs:=Radius;//*0.95;
  for Stack:=1 to StackRes do begin
    Zc:=Rs*Cos(StackAngle);
    R:=Rs*Sin(StackAngle);

    Sc:=0;
    SliceAngle:=StartSliceAngle;
    for Slice:=1 to SliceRes do begin

// set the X,Y,Z location
      Vtx[Slice,Stack].X:=Zc*Sin(SliceAngle);
      Vtx[Slice,Stack].Y:=R;

      RotateXYPoint(Vtx[Slice,Stack].X,Vtx[Slice,Stack].Y,Rz);
      Vtx[Slice,Stack].Z:=Zc;//+Radius;

// set the texture coordinate
      Vtx[Slice,Stack].S:=Sc;
      Vtx[Slice,Stack].T:=Tc;

      SliceAngle:=SliceAngle+SliceAngleInc;
      Sc:=Sc+SInc;
    end;
    StackAngle:=StackAngle+StackAngleInc;
    Tc:=Tc+TInc;
  end;

// draw it
  for Stack:=1 to StackRes-1 do begin

    glBegin(GL_TRIANGLE_STRIP);
    for Slice:=1 to SliceRes do begin

      with Vtx[Slice,Stack] do begin
        glTexCoord2F(S,T);
        glVertex3F(X,Y,Z);
      end;

      with Vtx[Slice,Stack+1] do begin
        glTexCoord2F(S,T);
        glVertex3F(X,Y,Z);
      end;
    end;

// close it off
    if SliceRes=MaxSlices then begin
      with Vtx[1,1] do begin
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;

      with Vtx[1,2] do begin
        glTexCoord2f(S,T);
        glVertex3F(X,Y,Z);
      end;
    end;
    glEnd;
  end;
end;

function TSphere.RadialFadeRange:Integer;
begin
  Result:=Round((1-RadialFade.StartF)*Stack2);
end;

function TSphere.RadialFadeStack:Integer;
begin
  Result:=Stack2-RadialFadeRange;
  if Result<1 then Result:=1
  else if Result>MaxStacks then Result:=MaxStacks;
end;

procedure TSphere.ShowRadialFade;
var
  Slice : Integer;
  Stack : Integer;
begin
  Stack:=RadialFadeStack;

  glColor3F(1,1,1);
  glBegin(GL_LINE_LOOP);
    for Slice:=Slice1 to Slice2 do begin
      with Vertex[Slice,Stack] do glVertex3F(X,Y,Z);
   end;
  glEnd;
end;

procedure TSphere.ShowYFade;
begin
  glBegin(GL_LINES);
    glColor3F(0,0,1);
    glVertex2F(-Radius,YFade.Min);
    glVertex2F(+Radius,YFade.Min);

    glColor3F(0,1,0);
    glVertex2F(-Radius,YFade.Max);
    glVertex2F(+Radius,YFade.Max);
  glEnd;
end;

end.
