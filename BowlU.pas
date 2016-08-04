unit BowlU;

interface

uses
  Global, Math, OpenGL;

type
  TBowl = class(TObject)
  private
    Vertex : TVertexArray;

  public
    EndStackAngle : Single;
    Radius : Single;
    Height : Single;
    Stacks : Integer;
    Slices : Integer;

    constructor Create;
    destructor Destroy; override;

    procedure RenderPoints;
    procedure RenderWireFrame;
    procedure Render;
    procedure RenderTextured;
    procedure CreateVertices;
  end;

implementation

uses
  ProjectorU;

constructor TBowl.Create;
begin
  inherited;
  Radius:=10;
  Height:=5;
  Slices:=10;
  Stacks:=10;
end;

destructor TBowl.Destroy;
begin
  inherited;
end;

procedure TBowl.CreateVertices;
var
  SliceAngle    : Single;
  SliceAngleInc : Single;
  StackAngle    : Single;
  StackAngleInc : Single;
  Z,R,X,Y       : Single;
  Stack,Slice   : Integer;
begin
  SliceAngleInc:=(2*Pi)/Slices;

  StackAngleInc:=EndStackAngle/Stacks;

  StackAngle:=0;
  for Stack:=1 to Stacks do begin
    Z:=-Radius*(1-Cos(StackAngle));
    R:=Radius*Sin(StackAngle);

    SliceAngle:=0;
    for Slice:=1 to Slices do begin

// set the X,Y,Z location
      X:=R*Cos(SliceAngle);
      Y:=R*Sin(SliceAngle);
      Vertex[Slice,Stack].Point.X:=X;
      Vertex[Slice,Stack].Point.Y:=Y;
      Vertex[Slice,Stack].Point.Z:=Z;

// set the texture S,T
      Vertex[Slice,Stack].S:=(0.5+X/Radius)*0.5+0.25;
      Vertex[Slice,Stack].T:=(0.5+Y/Radius)*0.5+0.25;

      SliceAngle:=SliceAngle+SliceAngleInc;
    end;
    StackAngle:=StackAngle+StackAngleInc;
  end;
end;

procedure TBowl.RenderPoints;
var
  Stack : Integer;
  Slice : Integer;
begin
  glPointSize(3);
  glBegin(GL_POINTS);
    for Stack:=1 to Stacks-1 do for Slice:=1 to Slices do begin
      with Vertex[Slice,Stack].Point do glVertex3F(X,Y,Z);
    end;
  glEnd;
end;


procedure TBowl.RenderWireFrame;
var
  Stack : Integer;
  Slice : Integer;
begin
  for Stack:=2 to Stacks do begin
    glBegin(GL_LINE_LOOP);
      for Slice:=1 to Slices do begin
        with Vertex[Slice,Stack].Point do glVertex3F(X,Y,Z);
      end;
    glEnd;
  end;

  for Slice:=1 to Slices do begin
    glBegin(GL_LINE_STRIP);
      for Stack:=1 to Stacks do begin
        with Vertex[Slice,Stack].Point do glVertex3F(X,Y,Z);
      end;
    glEnd;
  end;
end;

procedure TBowl.Render;
var
  Stack : Integer;
  Slice : Integer;
begin
  glBegin(GL_QUAD_STRIP);
    for Stack:=1 to Stacks-1 do begin
      for Slice:=1 to Slices do begin
        with Vertex[Slice,Stack+0].Point do glVertex3F(X,Y,Z);
        with Vertex[Slice,Stack+1].Point do glVertex3F(X,Y,Z);
      end;
    end;
    with Vertex[1,Stacks-1].Point do glVertex3F(X,Y,Z);
    with Vertex[1,Stack].Point do glVertex3F(X,Y,Z);
  glEnd;
end;

procedure TBowl.RenderTextured;
var
  Stack : Integer;
  Slice : Integer;
begin
  glBegin(GL_QUAD_STRIP);
    for Stack:=1 to Stacks-1 do begin
      for Slice:=1 to Slices do begin
        with Vertex[Slice,Stack+0] do begin
          glTexCoord2F(S,T);
          glVertex3F(Point.X,Point.Y,Point.Z);
        end;
        with Vertex[Slice,Stack+1] do begin
          glTexCoord2F(S,T);
          glVertex3F(Point.X,Point.Y,Point.Z);
        end;
      end;
    end;
    with Vertex[1,Stacks-1] do begin
      glTexCoord2F(S,T);
      glVertex3F(Point.X,Point.Y,Point.Z);
    end;
    with Vertex[1,Stack] do begin
      glTexCoord2F(S,T);
      glVertex3F(Point.X,Point.Y,Point.Z);
    end;
  glEnd;
end;

end.
