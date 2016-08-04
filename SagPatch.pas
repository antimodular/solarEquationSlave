unit SagPatch;

{$WEAKPACKAGEUNIT ON}

interface

procedure PatchINT3;

implementation

uses
  SysUtils, Windows;

procedure PatchINT3;
var
  NOP: Byte;
  BytesWritten: DWORD;
  NtDll: THandle;
  P: Pointer;
begin
  if Win32Platform <> VER_PLATFORM_WIN32_NT then Exit;
  NtDll := GetModuleHandle('NTDLL.DLL');
  if NtDll = 0 then Exit;
  P := GetProcAddress(NtDll, 'DbgBreakPoint');
  if P = nil then Exit;
  try
    If Byte(P^) <> $CC then Exit;
    NOP := $90;
    if WriteProcessMemory(GetCurrentProcess, P, @NOP, 1, BytesWritten) and
       (BytesWritten = 1) then
    begin
      FlushInstructionCache(GetCurrentProcess, P, 1);
    end;
  except
    On EAccessViolation Do ;
  else
    raise ;
  end;
end;

initialization

end.


