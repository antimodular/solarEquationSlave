unit SectionU;

interface

uses
  Math, OpenGL, Global;

type
  TSection = class(TObject)
  private
    Radius : Single;
    Height : Single;
    Stacks : Integer;
    Slices : Integer;

    Vertex : TVertexArray;

  public
    constructor Create;
    destructor Destroy; override;

    procedure CreateVertices;

    procedure RenderPoints;
    procedure RenderWireFrame;
    procedure Render;
    procedure RenderTextured;
  end;


implementation

uses
  BowlU;

constructor TSection.Create;
begin
  inherited;
  Radius:=10;
  Stacks:=10;
  Slices:=10;
  CreateVertices;
end;

destructor TSection.Destroy;
begin
  inherited;
end;

procedure TSection.CreateVertices;
var
  StartSliceAngle : Single;
  EndSliceAngle   : Single;
  SliceAngle      : Single;
  SliceAngleInc   : Single;
  StackAngle      : Single;
  StackAngleInc   : Single;
  Z,R,X,Y         : Single;
  EndStackAngle   : Single;
  Stack,Slice     : Integer;
begin
  StartSliceAngle:=DegToRad(225);
  EndSliceAngle:=DegToRad(315);
  SliceAngleInc:=(EndSliceAngle-StartSliceAngle)/Slices;


  EndStackAngle:=DegToRad(75);
  StackAngleInc:=EndStackAngle/Stacks;

  StackAngle:=0;
  for Stack:=1 to Stacks do begin
    Z:=Radius*Sin(StackAngle);
    R:=Radius*Sin(StackAngle);

    SliceAngle:=0;
    for Slice:=1 to Slices do begin
      X:=R*Cos(SliceAngle);
      Y:=R*Sin(SliceAngle);
      Vertex[Slice,Stack].Point.X:=X;
      Vertex[Slice,Stack].Point.Y:=Y;
      Vertex[Slice,Stack].Point.Z:=Z;
      SliceAngle:=SliceAngle+SliceAngleInc;
    end;
    StackAngle:=StackAngle+StackAngleInc;
  end;
end;

procedure TSection.RenderPoints;
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

procedure TSection.RenderWireFrame;
var
  Stack : Integer;
  Slice : Integer;
begin
  for Stack:=2 to Stacks do begin
    glBegin(GL_LINE_STRIP);
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

procedure TSection.Render;
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

procedure TSection.RenderTextured;
begin
end;

end.
