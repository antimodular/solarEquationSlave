unit FileU;

interface

uses
  Windows, CameraU, Dialogs, SysUtils, Global;

function AbleToLoadUndistortTable(var Table:TUndistortTable;FileName:String):Boolean;
procedure SaveUndistortTable(var Table:TUndistortTable;FileName:String);

implementation

uses
  CfgFile;

type
  TUndistortTableFile = File of TUndistortTable;

function AbleToLoadUndistortTable(var Table:TUndistortTable;FileName:String):Boolean;
var
  Handle : Integer;
  Size   : Integer;
begin
  Result:=False;
  if FileExists(FileName) and (SizeOfFile(FileName)=SizeOf(Table)) then begin
    Handle:=FileOpen(FileName,fmOpenRead);
    if Handle>0 then begin
      FileSeek(Handle,0,0);
      Size:=FileRead(Handle,Table,SizeOf(Table));
      FlushFileBuffers(Handle);
      FileClose(Handle);
      Result:=(Size=SizeOf(Table));
    end;
  end;
end;

procedure SaveUndistortTable(var Table:TUndistortTable;FileName:String);
var
  Handle : Integer;
begin
  if FileExists(FileName) then Handle:=FileOpen(FileName,fmOpenWrite)
  else Handle:=FileCreate(FileName);
  if Handle>0 then begin
    FileSeek(Handle,0,0);
    FileWrite(Handle,Table,SizeOf(Table));
    FlushFileBuffers(Handle);
    FileClose(Handle);
  end;
end;

end.


