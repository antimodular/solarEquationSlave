unit ImageProcessorSetupFrmU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  AprSpin, Vcl.ComCtrls, AprChkBx;

type
  TImageProcessorSetupFrm = class(TForm)
    TabControl: TTabControl;
    FilterTypeRG: TRadioGroup;
    Label2: TLabel;
    ThresholdEdit: TAprSpinEdit;
    DeleteBtn: TBitBtn;
    PaintBox: TPaintBox;
    AprCheckBox1: TAprCheckBox;
    AddBtn: TBitBtn;
    procedure DeleteBtnClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure FilterTypeRGClick(Sender: TObject);
    procedure ThresholdEditChange(Sender: TObject);

  private
    function SelectedFilter: Integer;
    procedure ShowSelectedFilter;

  public
    procedure Initialize;
  end;

var
  ImageProcessorSetupFrm: TImageProcessorSetupFrm;

implementation

{$R *.dfm}

uses
  ImageProcessorU, CameraU;

procedure TImageProcessorSetupFrm.Initialize;
var
  F : Integer;
begin
  PaintBox.Width:=Camera.ImageW;
  PaintBox.Height:=Camera.ImageH;

  for F:=2 to ImageProcessor.Filters do begin
    TabControl.Tabs.Add(IntToStr(F));
  end;
end;

function TImageProcessorSetupFrm.SelectedFilter:Integer;
begin
  Result:=TabControl.TabIndex+1;
end;

procedure TImageProcessorSetupFrm.ThresholdEditChange(Sender: TObject);
var
  F : Integer;
begin
  F:=SelectedFilter;
  ImageProcessor.Filter[F].Threshold:=ThresholdEdit.Value;
end;

procedure TImageProcessorSetupFrm.AddBtnClick(Sender: TObject);
begin
  if ImageProcessor.Filters<MaxFilters then begin
    ImageProcessor.AddFilter;
    TabControl.Tabs.Add(IntToStr(ImageProcessor.Filters));
    ShowSelectedFilter;
  end;
end;

procedure TImageProcessorSetupFrm.DeleteBtnClick(Sender: TObject);
var
  F : Integer;
begin
  if ImageProcessor.Filters>1 then begin
    F:=SelectedFilter;
    ImageProcessor.DeleteFilter(F);
  end;
end;

procedure TImageProcessorSetupFrm.FilterTypeRGClick(Sender: TObject);
var
  F,I     : Integer;
  NewType : TFilterType;
begin
  F:=SelectedFilter;

  NewType:=Low(TFilterType);
  for I:=1 to FilterTypeRG.ItemIndex do NewType:=Succ(NewType);

  ImageProcessor.Filter[F].FilterType:=NewType;
end;

procedure TImageProcessorSetupFrm.ShowSelectedFilter;
var
  F : Integer;
begin
  F:=SelectedFilter;
  with ImageProcessor.Filter[F] do begin
    FilterTypeRG.ItemIndex:=Ord(FilterType);
    ThresholdEdit.Value:=Threshold;
  end;
end;

end.
