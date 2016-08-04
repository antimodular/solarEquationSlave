unit CamSetupFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AprChkBx, NBFill, DirectShow9, ExtCtrls, AprSpin;

const
  PropCount = 10;
  CtrlCount = 7;

type
  TCamSettingsFrm = class(TForm)
    PropertyPanel: TPanel;
    AutoPropertyLbl: TLabel;
    PropertyLbl: TLabel;
    BrightnessEdit: TNBFillEdit;
    ContrastEdit: TNBFillEdit;
    SaturationEdit: TNBFillEdit;
    BacklightCompensationEdit: TNBFillEdit;
    SharpnessEdit: TNBFillEdit;
    GammaEdit: TNBFillEdit;
    WhiteBalanceEdit: TNBFillEdit;
    BrightnessCB: TAprCheckBox;
    ContrastCB: TAprCheckBox;
    SaturationCB: TAprCheckBox;
    SharpnessCB: TAprCheckBox;
    GammaCB: TAprCheckBox;
    WhiteBalanceCB: TAprCheckBox;
    BacklightCompensationCB: TAprCheckBox;
    GainEdit: TNBFillEdit;
    GainCB: TAprCheckBox;
    HueEdit: TNBFillEdit;
    HueCB: TAprCheckBox;
    ColorEnableEdit: TNBFillEdit;
    ColorEnableCB: TAprCheckBox;
    BrightnessOnOffCB: TAprCheckBox;
    ContrastOnOffCB: TAprCheckBox;
    SaturationOnOffCB: TAprCheckBox;
    SharpnessOnOffCB: TAprCheckBox;
    GammaOnOffCB: TAprCheckBox;
    WhiteBalanceOnOffCB: TAprCheckBox;
    BackLightCompensationOnOffCB: TAprCheckBox;
    PropertyOnOffLbl: TLabel;
    ControlPanel: TPanel;
    ControlLbl: TLabel;
    AutoControlLbl: TLabel;
    TiltEdit: TNBFillEdit;
    TiltCB: TAprCheckBox;
    PanEdit: TNBFillEdit;
    PanCB: TAprCheckBox;
    ZoomEdit: TNBFillEdit;
    ZoomCB: TAprCheckBox;
    RollEdit: TNBFillEdit;
    RollCB: TAprCheckBox;
    IrisEdit: TNBFillEdit;
    IrisCB: TAprCheckBox;
    ExposureEdit: TNBFillEdit;
    ExposureCB: TAprCheckBox;
    FocusEdit: TNBFillEdit;
    FocusCB: TAprCheckBox;
    ColorEnableOnOffCB: TAprCheckBox;
    HueOnOffCB: TAprCheckBox;
    GainOnOffCB: TAprCheckBox;

    function  TagToProperty(iTag:Integer):TVideoProcAmpProperty;
    procedure SetProperty(I:Integer);
    procedure PropertyEditValueChange(Sender: TObject);
    procedure PropertyCBClick(Sender: TObject);

    function  TagToControl(iTag:Integer):TCameraControlProperty;
    procedure SetControl(I:Integer);
    procedure ControlEditValueChange(Sender: TObject);
    procedure ControlCBClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private
    PropertyEdit    : array[1..PropCount] of TNBFillEdit;
    PropertyCB      : array[1..PropCount] of TAprCheckBox;
    PropertyOnOffCB : array[1..PropCount] of TAprCheckBox;

    ControlEdit : array[1..CtrlCount] of TNBFillEdit;
    ControlCB   : array[1..CtrlCount] of TAprCheckBox;


  public
    procedure Initialize;

  end;

var
  CamSettingsFrm: TCamSettingsFrm;

implementation

{$R *.dfm}

uses
  CameraU;

procedure TCamSettingsFrm.Initialize;
var
  I,Min,Max  : Integer;
  Value      : Integer;
  Prop       : TVideoProcAmpProperty;
  Ctrl       : TCameraControlProperty;
  Auto       : Boolean;
  CanDisable : Boolean;
begin
  PropertyEdit[1]:=BrightnessEdit;            
  PropertyEdit[2]:=ContrastEdit;              
  PropertyEdit[3]:=SaturationEdit;            
  PropertyEdit[4]:=SharpnessEdit;             
  PropertyEdit[5]:=GammaEdit;                 
  PropertyEdit[6]:=WhiteBalanceEdit;          
  PropertyEdit[7]:=BacklightCompensationEdit; 
  PropertyEdit[8]:=GainEdit;                  
  PropertyEdit[9]:=HueEdit;                   
  PropertyEdit[10]:=ColorEnableEdit;

  PropertyCB[1]:=BrightnessCB;
  PropertyCB[2]:=ContrastCB;
  PropertyCB[3]:=SaturationCB;
  PropertyCB[4]:=SharpnessCB;
  PropertyCB[5]:=GammaCB;
  PropertyCB[6]:=WhiteBalanceCB;
  PropertyCB[7]:=BacklightCompensationCB;
  PropertyCB[8]:=GainCB;
  PropertyCB[9]:=HueCB;
  PropertyCB[10]:=ColorEnableCB;

  PropertyOnOffCB[1]:=BrightnessOnOffCB;
  PropertyOnOffCB[2]:=ContrastOnOffCB;
  PropertyOnOffCB[3]:=SaturationOnOffCB;
  PropertyOnOffCB[4]:=SharpnessOnOffCB;
  PropertyOnOffCB[5]:=GammaOnOffCB;
  PropertyOnOffCB[6]:=WhiteBalanceOnOffCB;
  PropertyOnOffCB[7]:=BacklightCompensationOnOffCB;
  PropertyOnOffCB[8]:=GainOnOffCB;
  PropertyOnOffCB[9]:=HueOnOffCB;
  PropertyOnOffCB[10]:=ColorEnableOnOffCB;

  for I:=1 to PropCount do begin
    PropertyEdit[I].Tag:=I;
    PropertyCB[I].Tag:=I;
    PropertyOnOffCB[I].Tag:=I;
    Prop:=TagToProperty(I);

// find the range
    if Camera.AbleToGetPropertyDetails(Prop,Min,Max,Auto,CanDisable) then begin

// set the range
      PropertyEdit[I].Min:=Min;
      PropertyEdit[I].Max:=Max;
      PropertyCB[I].Enabled:=Auto;
      PropertyOnOffCB[I].Enabled:=CanDisable;

// find the current setting
      Camera.AbleToGetProperty(Prop,Value,Auto);

// show it
      PropertyEdit[I].Value:=Value;
      PropertyCB[I].Checked:=Auto;

// events
      PropertyEdit[I].OnValueChange:=PropertyEditValueChange;
      PropertyCB[I].OnClick:=PropertyCBClick;
      PropertyCB[I].OnClick:=PropertyCBClick;
    end
    else begin
      PropertyEdit[I].Enabled:=False;
      PropertyCB[I].Enabled:=False;
      PropertyOnOffCB[I].Enabled:=False;
    end;
  end;

// controls
  ControlEdit[1]:=PanEdit;      ControlCB[1]:=PanCB;
  ControlEdit[2]:=TiltEdit;     ControlCB[2]:=TiltCB;
  ControlEdit[3]:=RollEdit;     ControlCB[3]:=RollCB;
  ControlEdit[4]:=ZoomEdit;     ControlCB[4]:=ZoomCB;
  ControlEdit[5]:=ExposureEdit; ControlCB[5]:=ExposureCB;
  ControlEdit[6]:=IrisEdit;     ControlCB[6]:=IrisCB;
  ControlEdit[7]:=FocusEdit;    ControlCB[7]:=FocusCB;

  for I:=1 to CtrlCount do begin
    ControlEdit[I].Tag:=I;
    ControlCB[I].Tag:=I;
    Ctrl:=TagToControl(I);

// find the range
    if Camera.AbleToGetControlDetails(Ctrl,Min,Max,Auto) then begin

// set the range
      ControlEdit[I].Min:=Min;
      ControlEdit[I].Max:=Max;
      ControlCB[I].Enabled:=Auto;

// find the current setting
      Camera.AbleToGetControl(Ctrl,Value,Auto);

// show it
      ControlEdit[I].Value:=Value;
      ControlCB[I].Checked:=Auto;

// events
      ControlEdit[I].OnValueChange:=ControlEditValueChange;
      ControlCB[I].OnClick:=ControlCBClick;
    end
    else begin
      ControlEdit[I].Enabled:=False;
      ControlCB[I].Enabled:=False;
    end;
  end;
end;

function TCamSettingsFrm.TagToProperty(iTag:Integer):TVideoProcAmpProperty;
begin
  Case iTag of
    1: Result:=VideoProcAmp_Brightness;
    2: Result:=VideoProcAmp_Contrast;
    3: Result:=VideoProcAmp_Saturation;
    4: Result:=VideoProcAmp_Sharpness;
    5: Result:=VideoProcAmp_Gamma;
    6: Result:=VideoProcAmp_WhiteBalance;
    7: Result:=VideoProcAmp_BacklightCompensation;
    8: Result:=VideoProcAmp_Gain;
    9: Result:=VideoProcAmp_Hue;
    10:Result:=VideoProcAmp_ColorEnable;
  end;
end;

function TCamSettingsFrm.TagToControl(iTag:Integer):TCameraControlProperty;
begin
  Case iTag of
    1: Result:=CameraControl_Pan;
    2: Result:=CameraControl_Tilt;
    3: Result:=CameraControl_Roll;
    4: Result:=CameraControl_Zoom;
    5: Result:=CameraControl_Exposure;
    6: Result:=CameraControl_Iris;
    7: Result:=CameraControl_Focus;
  end;
end;

procedure TCamSettingsFrm.SetProperty(I:Integer);
var
  Prop      : TVideoProcAmpProperty;
  Value     : Integer;
  CtrlType  : TCameraControlType;
begin
  Value:=PropertyEdit[I].Value;
  Prop:=TagToProperty(I);
  if PropertyOnOffCB[I].Enabled then begin
    if PropertyOnOffCB[I].Checked then CtrlType:=ccOn
    else CtrlType:=ccOff;
  end
  else if PropertyCB[I].Checked then CtrlType:=ccAuto
  else CtrlType:=ccManual;
  Camera.AbleToSetProperty(Prop,Value,CtrlType);
end;

procedure TCamSettingsFrm.PropertyEditValueChange(Sender: TObject);
begin
  SetProperty((Sender as TNBFillEdit).Tag);
end;

procedure TCamSettingsFrm.PropertyCBClick(Sender: TObject);
begin
  SetProperty((Sender as TAprCheckBox).Tag);
end;

procedure TCamSettingsFrm.SetControl(I:Integer);
var
  Ctrl  : TCameraControlProperty;
  Value : Integer;
  Auto  : Boolean;
begin
  Ctrl:=TagToControl(I);
  Value:=ControlEdit[I].Value;
  Auto:=ControlCB[I].Checked;
  Camera.AbleToSetControl(Ctrl,Value,Auto);
end;

procedure TCamSettingsFrm.ControlEditValueChange(Sender: TObject);
begin
  SetControl((Sender as TNBFillEdit).Tag);
end;

procedure TCamSettingsFrm.ControlCBClick(Sender: TObject);
begin
  SetControl((Sender as TAprCheckBox).Tag);
end;

procedure TCamSettingsFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

end.


