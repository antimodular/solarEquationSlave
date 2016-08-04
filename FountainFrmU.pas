unit FountainFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprSpin, StdCtrls, ExtCtrls, Math;

type
  TFountainFrm = class(TForm)
    ThresholdsPanel: TPanel;
    Label4: TLabel;
    ColorDlg: TColorDialog;
    TextPanel: TPanel;
    Label11: TLabel;
    PlacementPanel: TPanel;
    Label24: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    StaticYEdit: TAprSpinEdit;
    StaticXEdit: TAprSpinEdit;
    SpacingPanel: TPanel;
    Label16: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    StaticYSpacingEdit: TAprSpinEdit;
    StaticXSpacingEdit: TAprSpinEdit;
    ShowTextBtn: TButton;
    Label2: TLabel;
    HomeThresholdEdit: TAprSpinEdit;
    Label15: TLabel;
    MoveThresholdEdit: TAprSpinEdit;
    Label17: TLabel;
    ColorPanel: TPanel;
    FadeTimePanel: TPanel;
    Label22: TLabel;
    FadeTimeEdit: TAprSpinEdit;
    Label1: TLabel;
    SizeEdit: TAprSpinEdit;
    Label3: TLabel;
    Label5: TLabel;
    WaitAlphaEdit: TAprSpinEdit;
    Label6: TLabel;
    XPaddingEdit: TAprSpinEdit;
    MoveDensityEdit: TAprSpinEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    HomeDensityEdit: TAprSpinEdit;

    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure StaticXEditChange(Sender: TObject);
    procedure StaticYEditChange(Sender: TObject);
    procedure StaticXSpacingEditChange(Sender: TObject);
    procedure StaticYSpacingEditChange(Sender: TObject);
    procedure ShowTextBtnClick(Sender: TObject);
    procedure SizeEditChange(Sender: TObject);
    procedure FadeTimeEditChange(Sender: TObject);
    procedure MoveThresholdEditChange(Sender: TObject);
    procedure HomeThresholdEditChange(Sender: TObject);
    procedure ColorPanelClick(Sender: TObject);
    procedure WaitAlphaEditChange(Sender: TObject);
    procedure XPaddingEditChange(Sender: TObject);
    procedure MoveDensityEditChange(Sender: TObject);
    procedure HomeDensityEditChange(Sender: TObject);

  private

  public
    procedure Initialize;
  end;

var
  FountainFrm: TFountainFrm;

implementation

{$R *.dfm}

uses
  FountainU, memofrmu;

procedure TFountainFrm.Initialize;
begin
  with Fountain do begin

// text panel
    StaticXEdit.Value:=Arrangement.Position.X;
    StaticYEdit.Value:=Arrangement.Position.Y;
    StaticXSpacingEdit.Value:=Arrangement.Spacing.X;
    StaticYSpacingEdit.Value:=Arrangement.Spacing.Y;
    ColorPanel.Color:=Fountain.Color;
    SizeEdit.Value:=SpriteSize;
    XPaddingEdit.Value:=Fountain.XPadding;

// thresholds
    MoveThresholdEdit.Value:=MoveThreshold;
    HomeThresholdEdit.Value:=HomeThreshold;
    MoveDensityEdit.Value:=Fountain.MoveDensity;
    HomeDensityEdit.Value:=Fountain.HomeDensity;

// fade in time
    FadeTimeEdit.Value:=FadeInTime;

// wait alpha
    WaitAlphaEdit.Value:=Fountain.WaitAlpha;
  end;
end;

procedure TFountainFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TFountainFrm.StaticXEditChange(Sender: TObject);
begin
  Fountain.Arrangement.Position.X:=StaticXEdit.Value;
  Fountain.ArrangeTextSideways;
end;

procedure TFountainFrm.StaticYEditChange(Sender: TObject);
begin
  Fountain.Arrangement.Position.Y:=StaticYEdit.Value;
  Fountain.ArrangeTextSideways;
end;

procedure TFountainFrm.StaticXSpacingEditChange(Sender: TObject);
begin
  Fountain.Arrangement.Spacing.X:=StaticXSpacingEdit.Value;
  Fountain.ArrangeTextSideways;
end;

procedure TFountainFrm.StaticYSpacingEditChange(Sender: TObject);
begin
  Fountain.Arrangement.Spacing.Y:=StaticYSpacingEdit.Value;
  Fountain.ArrangeTextSideways;
end;

procedure TFountainFrm.ShowTextBtnClick(Sender: TObject);
var
  I : Integer;
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    for I:=1 to Fountain.Lines do begin
      MemoFrm.Memo.Lines.Add(Fountain.Text[I]);
    end;
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TFountainFrm.SizeEditChange(Sender: TObject);
begin
  Fountain.SpriteSize:=Round(SizeEdit.Value);
end;

procedure TFountainFrm.FadeTimeEditChange(Sender: TObject);
begin
  Fountain.FadeInTime:=FadeTimeEdit.Value;
end;

procedure TFountainFrm.MoveDensityEditChange(Sender: TObject);
begin
  Fountain.MoveDensity:=MoveDensityEdit.Value;
end;

procedure TFountainFrm.MoveThresholdEditChange(Sender: TObject);
begin
  Fountain.MoveThreshold:=MoveThresholdEdit.Value;
end;

procedure TFountainFrm.HomeDensityEditChange(Sender: TObject);
begin
  Fountain.HomeDensity:=HomeDensityEdit.Value;
end;

procedure TFountainFrm.HomeThresholdEditChange(Sender: TObject);
begin
  Fountain.HomeThreshold:=HomeThresholdEdit.Value;
end;

procedure TFountainFrm.ColorPanelClick(Sender: TObject);
begin
  ColorDlg.Color:=Fountain.Color;
  if ColorDlg.Execute then begin
    Fountain.Color:=ColorDlg.Color;
    ColorPanel.Color:=Fountain.Color;
  end;  
end;

procedure TFountainFrm.WaitAlphaEditChange(Sender: TObject);
begin
  Fountain.WaitAlpha:=WaitAlphaEdit.Value;
end;

procedure TFountainFrm.XPaddingEditChange(Sender: TObject);
begin
  Fountain.XPadding:=XPaddingEdit.Value;
  Fountain.ArrangeTextSideways;
end;

end.
