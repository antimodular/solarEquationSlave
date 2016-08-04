unit DShowUtils;

interface

uses
  DirectShow9, Windows, Classes, Types, SysUtils;

procedure ShowVideoStreamCfgCaps(var Caps:TVideoStreamConfigCaps;Lines:TStrings);

implementation

function SizeStr(Size:TSize):String;
begin
  with Size do Result:='X: '+IntToStr(Cx)+' Y:'+IntToStr(Cy);
end;

procedure ShowVideoStreamCfgCaps(var Caps:TVideoStreamConfigCaps;Lines:TStrings);
begin
  with Caps do with Lines do begin
    Add('MinCroppingSize = '+SizeStr(MinCroppingSize));
    Add('MaxCroppingSize = '+SizeStr(MaxCroppingSize));
    Add('CropGranularityX = '+IntToStr(CropGranularityX));
    Add('CropGranularityY = '+IntToStr(CropGranularityY));
    Add('CropAlignX = '+IntToStr(CropAlignX));
    Add('CropAlignY = '+IntToStr(CropAlignY));
    Add('MinOutputSize = '+SizeStr(MinOutputSize));
    Add('MaxOutputSize = '+SizeStr(MaxOutputSize));
    Add('OutputGranularityX = '+IntToStr(OutputGranularityX));
    Add('OutputGranularityY = '+IntToStr(OutputGranularityY));
    Add('StretchTapsX = '+IntToStr(StretchTapsX));
    Add('StretchTapsY = '+IntToStr(StretchTapsY));
    Add('ShrinkTapsX = '+IntToStr(ShrinkTapsX));
    Add('ShrinkTapsY = '+IntToStr(ShrinkTapsY));
  end;
end;

end.
