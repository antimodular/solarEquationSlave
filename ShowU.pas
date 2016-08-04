unit ShowU;

interface

uses
  Global, Main;

procedure SetRunMode(NewMode:TRunMode);
procedure UpdateTracking;

implementation

uses
  CameraU, BlobFinderU;

procedure UpdateTracking;
begin
  if Camera.Smooth then Camera.SmoothBmp;
  Camera.DrawSubtractedBmp;
  BlobFinder.UpdateWithBmp(Camera.SubtractedBmp);
end;

procedure SetRunMode(NewMode:TRunMode);
var
  OpenFrms  : Boolean;
  CloseFrms : Boolean;
begin
  if RunMode=NewMode then begin
 //   if RunMode in [rmSetup,rmRun,rmCountDown] then ShowProjectorFrms;
    Exit;
  end;

  CloseFrms:=(RunMode in [rmSetup,rmRun,rmCountDown]) and (NewMode=rmIdle);
  OpenFrms:=(RunMode=rmIdle) and (NewMode in [rmSetup,rmRun,rmCountDown]);

  RunMode:=NewMode;


  if RunMode=rmIdle then MainFrm.Show
  else MainFrm.Hide;


//  if OpenFrms then ShowProjectorFrms
//  else if CloseFrms then CloseProjectorFrms;
end;

end.
