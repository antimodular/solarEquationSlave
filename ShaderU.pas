unit ShaderU;

interface

uses
  OpenGL1x, OpenGLTokens, SysUtils, Dialogs;

type
  TShaderType = (stFragment,stVertex);

  TShader = class(TObject)
  private
    function  StringFromFile(FileName:String):String;

  public
    Handle : GLHandleArb;

    constructor Create;

    procedure LoadAsType(ShaderType:TShaderType;FileName:String);
  end;

implementation

constructor TShader.Create;
begin
  Handle:=0;
end;

function TShader.StringFromFile(FileName:String):String;
var
  TxtFile : TextFile;
  Line    : String;
begin
  Result:='';
  if FileExists(FileName) then begin
    AssignFile(TxtFile,FileName);
    Reset(TxtFile);
    while not EOF(TxtFile) do begin
      ReadLn(TxtFile,Line);
      Result:=Result+Line+#10;
    end;
  end
  else ShowMessage('Can''t find '+FileName);
end;

procedure TShader.LoadAsType(ShaderType:TShaderType;FileName:String);
var
  ProgramTxt   : AnsiString;
  ProgramChars : PAnsiChar;
begin
// create the shader object
  Case ShaderType of
    stVertex   : Handle:=glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB);
    stFragment : Handle:=glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
  end;
  if Handle>0 then begin
    ProgramTxt:=StringFromFile(FileName);

// convert to a C string
    ProgramTxt:=ProgramTxt+#0;

// compile it
    if Assigned(glShaderSourceARB) then begin
   //glShaderSourceARB: procedure(shaderObj: GLhandleARB; count: GLsizei; const _string: PGLPCharArray; const length: PGLint); {$IFDEF MSWINDOWS} stdcall; {$ENDIF} {$IFDEF UNIX} cdecl; {$ENDIF}
      ProgramChars:=PAnsiChar(ProgramTxt);
      glShaderSourceARB(Handle,1,@ProgramChars,nil);

//      glShaderSourceARB(Handle,1,@ProgramTxt[1],nil);
      glCompileShaderARB(Handle);
    end;
  end
  else ShowMessage('Error loading shader');
end;

end.
