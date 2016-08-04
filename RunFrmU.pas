unit RunFrmU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AprSpin, Vcl.StdCtrls, Vcl.ExtCtrls,
  CPanel, GLSceneU;

type
  TRunFrm = class(TForm)
    GLPanel: TCanvasPanel;
    Panel: TPanel;
    GroupBox1: TGroupBox;
    FullSphereRB: TRadioButton;
    SlaveRB: TRadioButton;
    SlaveEdit: TAprSpinEdit;
    RenderRG: TRadioGroup;

  private
    GLScene : TGLScene;

    procedure GLSceneRender(Sender:TObject);

  public
    procedure Initialize;

  end;

var
  RunFrm: TRunFrm;

implementation

{$R *.dfm}

uses
  SphereU, SlaveU;

procedure TRunFrm.Initialize;
begin
  GLScene:=TGLScene.Create(GLPanel);
  GLScene.OnRender:=GLSceneRender;
end;

procedure TRunFrm.GLSceneRender(Sender:TObject);
var
  S      : Integer;
  Sphere : TSphere;
begin
  if FullSphereRB.Checked then begin
    FillChar(GLScene.CamLocation,SizeOf(GLScene.CamLocation),0);
    Sphere:=FullSphere;
  end
  else begin
    S:=Round(SlaveEdit.Value);
    Sphere:=Slave[S].Sphere;
  end;
  GLScene.CamLocation:=Sphere.CamPose;

  GLScene.Init3DDraw;

  Case RenderRG.ItemIndex of
    0 : Sphere.RenderWireFrame;
    1 : Sphere.RenderSolid;
    2 : Sphere.RenderTextured;
  end;
end;

end.
