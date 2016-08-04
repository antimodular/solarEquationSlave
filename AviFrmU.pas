unit AviFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Math, Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TAviFrm = class(TForm)
    Panel: TPanel;
    Label10: TLabel;
    AviFileNameEdit: TEdit;
    BrowseAviBtn: TBitBtn;
    PaintBox: TPaintBox;
    OpenDialog: TOpenDialog;
    PlayBtn: TBitBtn;
    StopBtn: TBitBtn;
    Timer: TTimer;
    procedure AviFileNameEditChange(Sender: TObject);
    procedure AviFileNameEditExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure PaintBoxPaint(Sender: TObject);
    procedure BrowseAviBtnClick(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);

  private
    procedure PlayerUpdate(Sender:TObject);
    procedure SizeFrm;

  public
    procedure Initialize;

  end;

var
  AviFrm: TAviFrm;

implementation

{$R *.dfm}

uses
  DxMediaU, BmpUtils;

procedure TAviFrm.Initialize;
begin
  AviFileNameEdit.Text:=Player.FileName;
  SizeFrm;
  ClearBmp(Player.Bmp,clBlack);
end;

procedure TAviFrm.SizeFrm;
begin
  PaintBox.Width:=Player.Bmp.Width;
  PaintBox.Height:=Player.Bmp.Height;

  ClientWidth:=Max(StopBtn.Left+StopBtn.Width+10,PaintBox.Left+PaintBox.Width+10);
  ClientHeight:=PaintBox.Top+PaintBox.Height+10;
end;

procedure TAviFrm.StopBtnClick(Sender: TObject);
begin
  Player.Stop;
  Timer.Enabled:=False;
end;

procedure TAviFrm.TimerTimer(Sender: TObject);
begin
  Player.Update;
end;

procedure TAviFrm.PlayBtnClick(Sender: TObject);
begin
  Player.Run;
  Timer.Enabled:=True;
end;

procedure TAviFrm.PlayerUpdate(Sender:TObject);
begin
  PaintBox.Canvas.Draw(0,0,Player.Bmp);
end;

procedure TAviFrm.AviFileNameEditChange(Sender: TObject);
begin
  Player.FileName:=AviFileNameEdit.Text;
end;

procedure TAviFrm.AviFileNameEditExit(Sender: TObject);
begin
  AviFileNameEdit.Text:=Player.FileName;
end;

procedure TAviFrm.FormCreate(Sender: TObject);
begin
  Player.OnUpdate:=PlayerUpdate;
end;

procedure TAviFrm.FormDestroy(Sender: TObject);
begin
  Player.OnUpdate:=nil;
end;

procedure TAviFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TAviFrm.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0,0,Player.Bmp);
end;

procedure TAviFrm.BrowseAviBtnClick(Sender: TObject);
begin
 if OpenDialog.Execute then begin
   Player.AbleToLoadFile(OpenDialog.FileName);
   AviFileNameEdit.Text:=Player.FileName;
   SizeFrm;
 end;
end;

end.

b/PaintBox.Canvas.StretchDraw(PaintBox.ClientRect,Player.Bmp);
  Texture.CopyFromBmp(Player.Bmp);

  if PlayerFrmCreated then PlayerFrm.PaintBox.Canvas.Draw(0,0,Player.Bmp);


