unit ProjectorFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, CPanel, GLSceneU, ProjectorU, OpenGL1x, OpenGLTokens,
  Menus, Global, SphereU;

type
  TProjectorFrm = class(TForm)
    GLPanel: TCanvasPanel;
    Timer: TTimer;
    PopupMenu1: TPopupMenu;
    ProjectorSetupItem: TMenuItem;
    BlendingSetupItem: TMenuItem;
    N1: TMenuItem;
    ExitItem: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GLPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure ExitItemClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    GLScene : TGLScene;

    procedure GLSceneRender(Sender:TObject);
    procedure GLSceneShutDown(Sender:TObject);
    procedure DrawTexturedSquare;
    function RenderSphere: TSphere;

    procedure TestRD;
    procedure UpdateRotation;

  public
    procedure Initialize(iTag:Integer);
  end;

var
  ProjectorFrm        : array[1..MaxProjectors] of TProjectorFrm;
  ProjectorFrmCreated : array[1..MaxProjectors] of Boolean = (False,False);

procedure ShowProjectorFrms;
procedure CloseProjectorFrms;
procedure PositionProjectorFrms;

procedure ShowProjectorFrm(I:Integer);
procedure PositionProjectorFrm(I:Integer);

implementation

uses
  Main, TextureU, GLDraw, SeasonU, Protocol;

{$R *.dfm}

procedure CloseProjectorFrms;
var
  I : Integer;
begin
  for I:=1 to Projectors do begin
    if Assigned(ProjectorFrm[I]) then ProjectorFrm[I].Close;
  end;
end;

procedure ShowProjectorFrms;
var
  I : Integer;
begin
  if not TexturesLoaded then LoadTextures;

  for I:=1 to Projectors do ShowProjectorFrm(I);
end;

procedure ShowProjectorFrm(I:Integer);
begin
  if not ProjectorFrmCreated[I] then begin
    ProjectorFrm[I]:=TProjectorFrm.Create(Application);
    ProjectorFrm[I].Initialize(I);
  end;
  ProjectorFrm[I].Show;
end;

procedure PositionProjectorFrm(I:Integer);
begin
  if ProjectorFrmCreated[I] then with Projector[I].Window do begin
    ProjectorFrm[I].Left:=X;
    ProjectorFrm[I].Top:=Y;
    ProjectorFrm[I].Width:=W;
    ProjectorFrm[I].Height:=H;
    ProjectorFrm[I].GLScene.Resize;
  end;
end;

procedure PositionProjectorFrms;
var
  I : Integer;
begin
  for I:=1 to Projectors do if ProjectorFrmCreated[I] then begin
    PositionProjectorFrm(I);
  end;
end;

procedure TProjectorFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TProjectorFrm.FormCreate(Sender: TObject);
begin
  BorderStyle:=bsNone;

  GLScene:=TGLScene.Create(GLPanel);

  GLScene.BackColor:=clBlack;
  GLScene.MouseMode:=mmNone;
  GLScene.DrawStage:=False;
  GLScene.DrawGrid:=False;
  GLScene.GridSize:=1.0;
  GLScene.CameraFOV:=45;
  GLScene.OnRender:=GLSceneRender;
  GLScene.OriginColor:=clYellow;
  GLScene.GridColor:=clWhite;
  GLScene.Resize;
end;

procedure TProjectorFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(GLScene) then GLScene.Free;
  ProjectorFrmCreated[Tag]:=False;
end;

procedure TProjectorFrm.Initialize(iTag:Integer);
begin
  Tag:=iTag;
  ProjectorFrmCreated[Tag]:=True;
  Projector[Tag].CreateEffects;

  with GLScene do begin
    CamLocation:=Projector[Tag].Pose;
    SceneRx:=0;
    SceneRz:=0;
    EnableTextures;
  end;
  GLScene.OnShutDown:=GLSceneShutDown;

  Timer.Enabled:=True;

  PositionProjectorFrm(Tag);
end;

procedure TProjectorFrm.GLSceneShutDown(Sender: TObject);
begin
  Projector[Tag].FreeEffects;
end;

function TProjectorFrm.RenderSphere:TSphere;
begin
  Case RenderPlacement of
    ptUnder : Result:=Projector[Tag].Sphere;
    ptSide  : Result:=Projector[Tag].CmSphere;
  end;
end;

procedure TProjectorFrm.TestRD;
begin
  Season[1].DrawRDTextures(Projector[Tag],1);
  GLScene.Init3DDraw;
  Season[1].RenderRDFlat(Projector[Tag],1);
end;

procedure TProjectorFrm.GLSceneRender(Sender:TObject);
var
  Scale,Offset : TStRecord;
begin
//TestRD;
//Exit;
  glDisable(GL_LIGHTING);
  glDisable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  glCullFace(GL_BACK);

  GLScene.CamLocation:=Projector[Tag].Pose;
  GLScene.CameraFOV:=Projector[Tag].FOV;

// setup mode
  if RunMode=rmSetup then begin
    if CalSettings.ShowProjector[Tag] then begin
      GLScene.Init3DDraw;
      Case RenderMode of
        rmWireFrame : RenderSphere.RenderWireFrame;
        rmSolid     :
          begin
            DisableTextures;
            GLScene.InitLighting;
            SetLitColor(clWhite);
            RenderSphere.Render;
          end;
        rmTextured :
          begin
            EnableTextures;
            EnableAlpha;
            glColor3F(1,1,1);
            Texture[1].Apply;
            if Projector[Tag].Orbit=soEquatorial then begin
              Scale.S:=1;
              Scale.T:=1;
              Offset.S:=0;// !!!Projector[Tag].SOffset;
              Offset.T:=0;
              RenderSphere.RenderScaledAndOffset2(Scale,Offset,soEquatorial,1.0);
            end
            else RenderSphere.RenderTextured(Projector[Tag].Orbit);
            glBindTexture(GL_TEXTURE_2D,0);

            DisableAlpha;
            DisableTextures;

            if CalSettings.ShowXYFade then begin
              RenderSphere.ShowYFade;
            end;
            if CalSettings.ShowRadialFade then begin
              RenderSphere.ShowRadialFade;
            end;
          end;
      end;
    end
    else begin
      glClearColor(0,0,0,1);
      glClear(GL_COLOR_BUFFER_BIT);
    end;
  end
  else if RunMode=rmCountDown then begin
    if CountDownIndex in [254,255] then begin
      Case CountDownIndex of
        254 : glClearColor(0,0,0,1);
        255 : glClearColor(1,1,1,1);
      end;
      glClear(GL_COLOR_BUFFER_BIT);
    end
    else begin
      if Tag=1 then begin
        CountDownTexture[CountDownIndex].Apply;
        GLScene.Init2DDraw;
        RenderTexturedRectangle2(0,0,GLScene.Width,GLScene.Height,1);
      end
      else begin
        glClearColor(0,0,0,1);
        glClear(GL_COLOR_BUFFER_BIT);
      end;
    end;
  end

// normal run mode
  else begin

// update the rotation
    if (RunMode=rmRun) and RotationEnabled then begin
      UpdateRotation;
    end;

// draw the textures
    CurrentSeason.DrawTextures(Projector[Tag]);

// place the camera
    GLScene.Init3DDraw;

    CurrentSeason.RenderSpherically(Projector[Tag]);
  end;
end;

procedure TProjectorFrm.Button1Click(Sender: TObject);
begin
  Projector[Tag].ReactDiffuse[1].MakeRandom:=True;
  Projector[Tag].ReactDiffuse[2].MakeRandom:=True;
end;

procedure TProjectorFrm.DrawTexturedSquare;
const
  X1 = -1;
  X2 = +1;
  Y1 = -1;
  Y2 = +1;
begin
  glBegin(GL_QUADS);
    glTexCoord2F(1,0);
    glVertex2F(X1,Y1);

    glTexCoord2F(0,0);
    glVertex2F(X2,Y1);

    glTexCoord2F(0,1);
    glVertex2F(X2,Y2);

    glTexCoord2F(1,1);
    glVertex2F(X1,Y2);
  glEnd;
end;

procedure TProjectorFrm.GLPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbRight then MainFrm.Show
  else MainFrm.Hide;
end;

procedure TProjectorFrm.FormActivate(Sender: TObject);
begin
  with Projector[Tag].Window do begin
    Left:=X;
    Top:=Y;
    Width:=W;
    Height:=H;
  end;
  GLScene.Resize;
end;

procedure TProjectorFrm.TimerTimer(Sender: TObject);
begin
 // Rotation[Tag].RdOffset:=Rotation[Tag].RdOffset+0.001;
  GLScene.Render2;
end;

procedure TProjectorFrm.ExitItemClick(Sender: TObject);
begin
  Exit;
end;

procedure TProjectorFrm.UpdateRotation;
var
  L  : Integer;
  Dt : Single;
  Time : DWord;
begin
  Time:=GetTickCount;
  Dt:=(Time-LastRotateTime)/1000;
  LastRotateTime:=Time;

  for L:=1 to Layers do with CurrentPos[L] do begin
    CubeMapRz:=CubeMapRz+CurrentV[L].CubeMapV*RotationScale*Dt;
//CurrentV[L].ImageV:=0.01;
    ImageOffset:=ImageOffset+CurrentV[L].ImageV*RotationScale*Dt;
    RdOffset:=RdOffset+CurrentV[L].RdV*RotationScale*Dt;
    PerlinRz:=PerlinRz+CurrentV[L].PerlinV*RotationScale*Dt;
    ParticleRz:=ParticleRz+CurrentV[L].ParticleV*RotationScale*Dt;
  end;
end;

end.
