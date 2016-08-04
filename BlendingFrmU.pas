unit BlendingFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AprSpin, StdCtrls;

type
  TBlendingFrm = class(TForm)
    Label3: TLabel;
    AviAlphaEdit: TAprSpinEdit;
    Label4: TLabel;
    LiveAlphaEdit: TAprSpinEdit;
    procedure AviAlphaEditChange(Sender: TObject);
    procedure LiveAlphaEditChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private

  public
    procedure Initialize;

  end;

var
  BlendingFrm: TBlendingFrm;

implementation

{$R *.dfm}

uses
  Global;

procedure TBlendingFrm.Initialize;
begin
  AviAlphaEdit.Value:=AviAlpha*100;
  LiveAlphaEdit.Value:=LiveAlpha*100;
end;

procedure TBlendingFrm.AviAlphaEditChange(Sender: TObject);
begin
  AviAlpha:=AviAlphaEdit.Value/100;
end;

procedure TBlendingFrm.LiveAlphaEditChange(Sender: TObject);
begin
  LiveAlpha:=LiveAlphaEdit.Value/100;
end;

procedure TBlendingFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

end.
