unit ProgramU;

interface

uses
  OpenGL1x, OpenGLTokens, ShaderU, Dialogs;

type
  TProgram = class(TObject)
  private
    procedure SetActive(NewSetting:Boolean);

  public
    Handle : GLHandleArb;

    constructor Create;
    destructor  Destroy; override;

    property Active:Boolean write SetActive;

    function  ShaderPath:String;
    procedure LoadVertexAndFragmentFiles(VertexFile,FragmentFile:String;LinkAfter:Boolean=True);
    procedure Link;

    procedure Use;
    procedure Remove;
    function  Loaded:Boolean;

    procedure SetUniformF(Name:AnsiString;V:Single);
    procedure SetUniformI(Name:AnsiString;V:Integer);
    procedure SetUniform3F(Name:AnsiString;X,Y,Z:Single);
    procedure SetUniform4F(Name:AnsiString;R,G,B,A:Single);
  end;

implementation

uses
  Routines, Main;

constructor TProgram.Create;
begin
  Handle:=0;
  inherited;
end;

destructor TProgram.Destroy;
begin
//  Handle:=0;
  inherited;
end;

procedure TProgram.SetUniformI(Name:AnsiString;V:Integer);
var
  VarLoc : Integer;
begin
  VarLoc:=glGetUniformLocation(Handle,PAnsiChar(Name));
  glUniform1I(VarLoc,V);
end;

procedure TProgram.SetUniformF(Name:AnsiString;V:Single);
var
  VarLoc : Integer;
begin
  VarLoc:=glGetUniformLocation(Handle,PAnsiChar(Name));
  glUniform1F(VarLoc,V);
end;

procedure TProgram.SetUniform3F(Name:AnsiString;X,Y,Z:Single);
var
  VarLoc : Integer;
begin
  VarLoc:=glGetUniformLocation(Handle,PAnsiChar(Name));
  glUniform3f(VarLoc,X,Y,Z);
end;

procedure TProgram.SetUniform4F(Name:AnsiString;R,G,B,A:Single);
var
  VarLoc : Integer;
begin
  VarLoc:=glGetUniformLocation(Handle,PAnsiChar(Name));
  glUniform4f(VarLoc,R,G,B,A);
end;

function TProgram.ShaderPath:String;
begin
  Result:=Path+'Shaders\';
end;

procedure TProgram.LoadVertexAndFragmentFiles(VertexFile,FragmentFile:String;LinkAfter:Boolean=True);
var
  VertexShader   : TShader;
  FragmentShader : TShader;
begin
  if not Assigned(glCreateProgramObjectARB) then ReadExtensions;

// create a new program object
  Handle:=glCreateProgramObjectARB();

// attach the vertex shader
  VertexShader:=TShader.Create;
  try
    VertexShader.LoadAsType(stVertex,ShaderPath+VertexFile);

// attach the vertex shader
    glAttachObjectARB(Handle,VertexShader.Handle);
    glDeleteObjectARB(VertexShader.Handle);
  finally
    VertexShader.Free;
  end;

  if FragmentFile<>'' then begin
    FragmentShader:=TShader.Create;
    try
      FragmentShader.LoadAsType(stFragment,ShaderPath+FragmentFile);

// attach the frament shader
      glAttachObjectARB(Handle,FragmentShader.Handle);
      glDeleteObjectARB(FragmentShader.Handle);
    finally
      FragmentShader.Free;
    end;  
  end;

  if LinkAfter then Link;
end;

procedure TProgram.Link;
var
  Linked   : GLInt;
  LogTxt   : array[1..4096] of AnsiChar;
  Length   : GLSizeI;
  TruncTxt : AnsiString;
begin
  glLinkProgramARB(Handle);
  glGetObjectParameterivARB(Handle,GL_OBJECT_LINK_STATUS_ARB,@Linked);

  glGetInfoLogARB(Handle,4096,@Length,@LogTxt[1]);
  if Length>0 then begin
    SetLength(TruncTxt,Length);
    Move(LogTxt[1],TruncTxt[1],Length);
  end
  else TruncTxt:='Ok';

  if Linked=0 then begin
//    glGetInfoLogARB(Handle,4096,@Length,@LogTxt[1]);
    ShowMessage('Error linking GLSL program:'+TruncTxt);
    glDeleteObjectARB(Handle);
    Handle:=0;
  end;
end;

procedure TProgram.Use;
begin
  glUseProgramObjectARB(Handle);
end;

procedure TProgram.Remove;
begin
  glUseProgramObjectARB(0);
end;

procedure TProgram.SetActive(NewSetting:Boolean);
begin
  if NewSetting then Use
  else Remove;
end;

function TProgram.Loaded:Boolean;
begin
  Result:=(Handle>0);
end;

end.

- (void) loadFromVertexFile : (NSString *) vertexFile andFragmentFile : (NSString *) fragmentFile
{
  Shader *vertexShader = [[Shader alloc] init];
  [vertexShader loadAsVertexShader : vertexFile];

  if ([vertexShader ready]) {
    Shader *fragmentShader = [[Shader alloc] init];
    [fragmentShader loadAsFragmentShader : fragmentFile];
    if ([fragmentShader ready]) {
      [self initFromVertexShader : vertexShader.handle andFragmentShader : fragmentShader.handle];
    }
    else NSLog(@"Error loading fragment shader");
    [fragmentShader release];
  }
  else NSLog(@"Error loading vertex shader");
  [vertexShader release];
}

- (BOOL) ready
{ 
  return (handle > 0);
}


end.

//- (void) initFromVertexShader : (GLhandleARB) vertexShader andFragmentShader : (GLhandleARB) fragmentShader
{
  GLint linked;

// create a new program object
  handle = glCreateProgramObjectARB();

// attach the vertex shader
 	glAttachObjectARB(handle, vertexShader);
  glDeleteObjectARB(vertexShader);   /* Release */

// attach the frament shader
	glAttachObjectARB(handle, fragmentShader);
  glDeleteObjectARB(fragmentShader);   /* Release */

// link it
  glLinkProgramARB(handle);
  glGetObjectParameterivARB(handle, GL_OBJECT_LINK_STATUS_ARB, &linked);

  if (!linked) {
   	glDeleteObjectARB(handle);
	  handle = NULL;
  }
}


