unit CfgFile;

interface

uses
  Windows, SysUtils, Forms, Dialogs, Global, ProjectorU, ReactDiffuseU,
  DxMediaU;

type
  TFileSignature = String[10];

  TFolderName = String[100];

function  SizeOfFile(FileName:String):Integer;

implementation

uses
  Routines;

function SizeOfFile(FileName:String):Integer;
var
  Handle : Integer;
begin
  Handle:=FileOpen(FileName,fmOpenRead);
  if Handle>0 then begin
    Result:=FileSeek(Handle,0,2); // position at the end of the file
    FlushFileBuffers(Handle);
    FileClose(Handle);
  end
  else Result:=0;
end;

end.


