unit MemoFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TMemoFrm = class(TForm)
    Memo: TMemo;
    ClearBtn: TButton;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private

  public
   
  end;

var
  MemoFrm: TMemoFrm;

implementation

{$R *.dfm}

procedure TMemoFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#27 then Close;
end;

end.
