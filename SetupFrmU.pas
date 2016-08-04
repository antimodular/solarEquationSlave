unit SetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Math, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, AprSpin, ExtCtrls, Buttons,
  AprChkBx, ComCtrls, ProjectorU, SphereU;

type
  TSetupFrm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    WireframeRB: TRadioButton;
    SolidRB: TRadioButton;
    TexturedRB: TRadioButton;
    ProjectorTC: TTabControl;
    WindowPanel: TPanel;
    Label24: TLabel;
    Label22: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    WindowXEdit: TAprSpinEdit;
    WindowYEdit: TAprSpinEdit;
    WindowWEdit: TAprSpinEdit;
    WindowHEdit: TAprSpinEdit;
    CameraPanel: TPanel;
    Label9: TLabel;
    Label12: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    CamXEdit: TAprSpinEdit;
    CamYEdit: TAprSpinEdit;
    CamZEdit: TAprSpinEdit;
    CamRxEdit: TAprSpinEdit;
    CamRyEdit: TAprSpinEdit;
    CamRzEdit: TAprSpinEdit;
    CamFovEdit: TAprSpinEdit;
    SpherePageControl: TPageControl;
    SidePage: TTabSheet;
    CapPage: TTabSheet;
    Label13: TLabel;
    Label4: TLabel;
    Slice1Edit: TAprSpinEdit;
    Slice2Edit: TAprSpinEdit;
    Label30: TLabel;
    Stack1Edit: TAprSpinEdit;
    Stack2Edit: TAprSpinEdit;
    Label32: TLabel;
    Label2: TLabel;
    RzOffsetEdit: TAprSpinEdit;
    SideRadiusEdit: TAprSpinEdit;
    Label3: TLabel;
    Label40: TLabel;
    EndAngleEdit: TAprSpinEdit;
    Label41: TLabel;
    SOffsetEdit: TAprSpinEdit;
    Label42: TLabel;
    CapRadiusEdit: TAprSpinEdit;
    Panel2: TPanel;
    Label43: TLabel;
    RenderCubeMapCB: TAprCheckBox;
    RenderImageCB: TAprCheckBox;
    RenderLayer2CB: TAprCheckBox;
    RenderLayer1CB: TAprCheckBox;
    Panel3: TPanel;
    Label14: TLabel;
    SideRB: TRadioButton;
    UnderRB: TRadioButton;
    CameraCB: TAprCheckBox;
    RunShowCB: TAprCheckBox;
    procedure Slice1EditChange(Sender: TObject);
    procedure Slice2EditChange(Sender: TObject);
    procedure Stack1EditChange(Sender: TObject);
    procedure Stack2EditChange(Sender: TObject);
    procedure WireframeRBClick(Sender: TObject);
    procedure SolidRBClick(Sender: TObject);
    procedure TexturedRBClick(Sender: TObject);
    procedure CamZEditChange(Sender: TObject);
    procedure CamYEditChange(Sender: TObject);
    procedure CamXEditChange(Sender: TObject);
    procedure CamRxEditChange(Sender: TObject);
    procedure CamRyEditChange(Sender: TObject);
    procedure CamRzEditChange(Sender: TObject);
    procedure CamFovEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RzOffsetEditChange(Sender: TObject);
    procedure SideRadiusEditChange(Sender: TObject);
    procedure CapRadiusEditChange(Sender: TObject);
    procedure WindowXEditChange(Sender: TObject);
    procedure WindowYEditChange(Sender: TObject);
    procedure WindowWEditChange(Sender: TObject);
    procedure WindowHEditChange(Sender: TObject);
    procedure RenderCubeMapCBClick(Sender: TObject);
    procedure RenderImageCBClick(Sender: TObject);
    procedure RenderLayer1CBClick(Sender: TObject);
    procedure RenderLayer2CBClick(Sender: TObject);
    procedure ProjectorTCChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SOffsetEditChange(Sender: TObject);
    procedure EndAngleEditChange(Sender: TObject);
    procedure RunShowCBClick(Sender: TObject);
    procedure CameraCBClick(Sender: TObject);

  private
    function  SelectedProjector: TProjector;
    function  SelectedSphere:TSphere;

  public
    procedure Initialize;

    procedure SyncSetupData;
    procedure SyncRenderMode;

  end;

var
  SetupFrm : TSetupFrm;
  SetupFrmCreated : Boolean = False;

procedure ShowSetupFrm;


implementation

{$R *.dfm}

uses
  Global, ProjectorFrmU,
  CameraU;

procedure ShowSetupFrm;
begin
  if not SetupFrmCreated then begin
    SetupFrm:=TSetupFrm.Create(Application);
    SetupFrm.Initialize;
  end;
  SetupFrm.Show;
end;

procedure TSetupFrm.Initialize;
begin
  SyncSetupData;
  SyncRenderMode;
end;

procedure TSetupFrm.SyncRenderMode;
begin
  Case RenderMode of
    rmWireFrame : WireFrameRB.Checked:=True;
    rmSolid     : SolidRB.Checked:=True;
    rmTextured  : TexturedRB.Checked:=True;
  end;
end;

function TSetupFrm.SelectedProjector:TProjector;
var
  I : Integer;
begin
  I:=ProjectorTC.TabIndex+1;
  Result:=Projector[I];
end;

function TSetupFrm.SelectedSphere:TSphere;
begin
  if SpherePageControl.ActivePage=SidePage then begin
    Result:=SelectedProjector.CmSphere;
  end
  else Result:=SelectedProjector.Sphere;
end;

procedure TSetupFrm.SyncSetupData;
begin
  WindowXEdit.Value:=SelectedProjector.Window.X;
  WindowYEdit.Value:=SelectedProjector.Window.Y;
  WindowWEdit.Value:=SelectedProjector.Window.W;
  WindowHEdit.Value:=SelectedProjector.Window.H;

  CamXEdit.Value:=SelectedProjector.Pose.X;
  CamYEdit.Value:=SelectedProjector.Pose.Y;
  CamZEdit.Value:=SelectedProjector.Pose.Z;
  CamRxEdit.Value:=RadToDeg(SelectedProjector.Pose.Rx);
  CamRyEdit.Value:=RadToDeg(SelectedProjector.Pose.Ry);
  CamRzEdit.Value:=RadToDeg(SelectedProjector.Pose.Rz);
  CamFOVEdit.Value:=RadToDeg(SelectedProjector.FOV);

  with SelectedProjector.Sphere do begin
    EndAngleEdit.Value:=RadToDeg(EndAngle);
    SOffsetEdit.Value:=SOffset;
    CapRadiusEdit.Value:=Radius;
  end;
  with SelectedProjector.CmSphere do begin
    Slice1Edit.Value:=Slice1;
    Slice2Edit.Value:=Slice2;
    Stack1Edit.Value:=Stack1;
    Stack2Edit.Value:=Stack2;
    RzOffsetEdit.Value:=RadToDeg(RzOffset);
    SideRadiusEdit.Value:=Radius;
  end;

  with SelectedProjector do begin
    RenderCubeMapCB.Checked:=ShowCubeMap;
    RenderImageCB.Checked:=ShowImage;
    RenderLayer1CB.Checked:=ShowLayer[1];
    RenderLayer2CB.Checked:=ShowLayer[2];
  end;

  CameraCB.Checked:=Camera.Enabled;
  RunShowCB.Checked:=RunShow;
end;

procedure TSetupFrm.Slice1EditChange(Sender: TObject);
begin
  SelectedProjector.CmSphere.Slice1:=Round(Slice1Edit.Value);
end;

procedure TSetupFrm.Slice2EditChange(Sender: TObject);
begin
  SelectedProjector.CmSphere.Slice2:=Round(Slice2Edit.Value);
end;

procedure TSetupFrm.Stack1EditChange(Sender: TObject);
begin
  SelectedProjector.CmSphere.Stack1:=Round(Stack1Edit.Value);
end;

procedure TSetupFrm.Stack2EditChange(Sender: TObject);
begin
  SelectedProjector.CmSphere.Stack2:=Round(Stack2Edit.Value);
end;

procedure TSetupFrm.WireframeRBClick(Sender: TObject);
begin
  RenderMode:=rmWireFrame;
end;

procedure TSetupFrm.SolidRBClick(Sender: TObject);
begin
  RenderMode:=rmSolid;
end;

procedure TSetupFrm.TexturedRBClick(Sender: TObject);
begin
  RenderMode:=rmTextured;
end;

procedure TSetupFrm.CamXEditChange(Sender: TObject);
begin
  SelectedProjector.Pose.X:=CamXEdit.Value;
end;

procedure TSetupFrm.CamYEditChange(Sender: TObject);
begin
  SelectedProjector.Pose.Y:=CamYEdit.Value;
end;

procedure TSetupFrm.CamZEditChange(Sender: TObject);
begin
  SelectedProjector.Pose.Z:=CamZEdit.Value;
end;

procedure TSetupFrm.CamRxEditChange(Sender: TObject);
begin
  SelectedProjector.Pose.Rx:=DegToRad(CamRxEdit.Value);
end;

procedure TSetupFrm.CamRyEditChange(Sender: TObject);
begin
  SelectedProjector.Pose.Ry:=DegToRad(CamRyEdit.Value);
end;

procedure TSetupFrm.CamRzEditChange(Sender: TObject);
begin
  SelectedProjector.Pose.Rz:=DegToRad(CamRzEdit.Value);
end;

procedure TSetupFrm.CameraCBClick(Sender: TObject);
begin
  Camera.Enabled:=CameraCB.Checked;
end;

procedure TSetupFrm.CamFovEditChange(Sender: TObject);
begin
  SelectedProjector.FOV:=DegToRad(CamFovEdit.Value);
end;

procedure TSetupFrm.FormCreate(Sender: TObject);
begin
  SetupFrmCreated:=True;
end;

procedure TSetupFrm.FormDestroy(Sender: TObject);
begin
  SetupFrmCreated:=False;
end;

procedure TSetupFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TSetupFrm.RzOffsetEditChange(Sender: TObject);
begin
  SelectedProjector.RzOffset:=DegToRad(RzOffsetEdit.Value);
end;

procedure TSetupFrm.SideRadiusEditChange(Sender: TObject);
begin
  SelectedProjector.CmSphere.Radius:=SideRadiusEdit.Value;
  SelectedProjector.CmSphere.CalculateVertices;
end;

procedure TSetupFrm.CapRadiusEditChange(Sender: TObject);
begin
  SelectedProjector.Sphere.Radius:=CapRadiusEdit.Value;
  SelectedProjector.Sphere.CalculateVertices;
end;

procedure TSetupFrm.WindowXEditChange(Sender: TObject);
begin
  SelectedProjector.Window.X:=Round(WindowXEdit.Value);
  PositionProjectorFrms;
end;

procedure TSetupFrm.WindowYEditChange(Sender: TObject);
begin
  SelectedProjector.Window.Y:=Round(WindowYEdit.Value);
  PositionProjectorFrms;
end;

procedure TSetupFrm.WindowWEditChange(Sender: TObject);
begin
  SelectedProjector.Window.W:=Round(WindowWEdit.Value);
  PositionProjectorFrms;
end;

procedure TSetupFrm.WindowHEditChange(Sender: TObject);
begin
  SelectedProjector.Window.H:=Round(WindowHEdit.Value);
  PositionProjectorFrms;
end;

procedure TSetupFrm.RenderCubeMapCBClick(Sender: TObject);
begin
  SelectedProjector.ShowCubeMap:=RenderCubeMapCB.Checked;
end;

procedure TSetupFrm.RenderImageCBClick(Sender: TObject);
begin
  SelectedProjector.ShowImage:=RenderImageCB.Checked;
end;

procedure TSetupFrm.RenderLayer1CBClick(Sender: TObject);
begin
  SelectedProjector.ShowLayer[1]:=RenderLayer1CB.Checked;
end;

procedure TSetupFrm.RenderLayer2CBClick(Sender: TObject);
begin
  SelectedProjector.ShowLayer[2]:=RenderLayer2CB.Checked;
end;

procedure TSetupFrm.RunShowCBClick(Sender: TObject);
begin
  RunShow:=RunShowCB.Checked;
end;

procedure TSetupFrm.ProjectorTCChange(Sender: TObject);
begin
  SyncSetupData;
end;

procedure TSetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TSetupFrm.SOffsetEditChange(Sender: TObject);
begin
  SelectedProjector.Sphere.SOffset:=SOffsetEdit.Value;
end;

procedure TSetupFrm.EndAngleEditChange(Sender: TObject);
begin
  SelectedProjector.Sphere.EndAngle:=DegToRad(EndAngleEdit.Value);
  SelectedProjector.Sphere.CalculateVertices;
end;

end.


