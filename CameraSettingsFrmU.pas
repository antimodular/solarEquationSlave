unit CameraSettingsFrmU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, NBFill, Buttons, AprSpin, StdCtrls, AprChkBx, ComCtrls,
  CameraU, Math, CfgFile, LCD;

type
  TCameraSettingsFrm = class(TForm)
    CamPB: TPaintBox;
    ExposureEdit: TNBFillEdit;
    GainEdit: TNBFillEdit;
    Memo: TMemo;
    StatusBar: TStatusBar;
    DoneBtn: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure CamPBPaint(Sender: TObject);
    procedure ExposureEditValueChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GainEditValueChange(Sender: TObject);
    procedure DoneBtnClick(Sender: TObject);

  private
    Bmp      : TBitmap;
    Settings : TAvtDriverSettings;

    procedure DrawBmp;

  public
    procedure Initialize;
    procedure UpdateTracking;

  end;

var
  CameraSettingsFrm: TCameraSettingsFrm;
  CameraSettingsFrmCreated : Boolean =False;

implementation

{$R *.dfm}

uses
  Global, BmpUtils, Main, TilerU, StopWatchU;

procedure TCameraSettingsFrm.FormCreate(Sender: TObject);
begin
  CameraSettingsFrmCreated:=True;
end;

procedure TCameraSettingsFrm.Initialize;
begin
  Caption:=VersionStr;
  Bmp:=CreateImageBmp;

  Settings:=Camera.GetAvtDriverSettings;

// exposure
  with Settings.Exposure do begin
    if Max=Min then ExposureEdit.Enabled:=False
    else begin
      ExposureEdit.Min:=Min;
      ExposureEdit.Max:=Max;
      ExposureEdit.Value:=Value;
    end
  end;

// gain
  with Settings.Gain do begin
    GainEdit.Min:=Min;
    GainEdit.Max:=Max;
    GainEdit.Value:=Value;
  end;

  if Camera.Found then begin
    StatusBar.SimpleText:=Camera.CameraName+' - '+Camera.DriverName;
  end
  else StatusBar.SimpleText:='Camera not found';

  MainFrm.Cursor:=crDefault;
end;

procedure TCameraSettingsFrm.FormDestroy(Sender: TObject);
begin
  if Assigned(Bmp) then Bmp.Free;
  CameraSettingsFrmCreated:=False;
  MainFrm.Cursor:=crNone;
end;

procedure TCameraSettingsFrm.CamPBPaint(Sender: TObject);
begin
  CamPB.Canvas.Draw(0,0,Bmp);
end;

procedure TCameraSettingsFrm.DrawBmp;
begin
  Bmp.Canvas.Draw(0,0,Camera.Bmp);
  ShowFrameRateOnBmp(Bmp,Camera.MeasuredFPS);
end;

procedure TCameraSettingsFrm.UpdateTracking;
begin
  DrawBmp;
  CamPB.Canvas.Draw(0,0,Bmp);
end;

procedure TCameraSettingsFrm.ExposureEditValueChange(Sender: TObject);
begin
  Settings:=Camera.GetAvtDriverSettings;
  Settings.Exposure.Value:=ExposureEdit.Value;
  Camera.SetAvtDriverSettings(Settings);
end;

procedure TCameraSettingsFrm.FormClose(Sender: TObject;var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TCameraSettingsFrm.GainEditValueChange(Sender: TObject);
begin
  Settings:=Camera.GetAvtDriverSettings;
  Settings.Gain.Value:=GainEdit.Value;
  Camera.SetAvtDriverSettings(Settings);
end;

procedure TCameraSettingsFrm.DoneBtnClick(Sender: TObject);
begin
  Close;
end;

end.




