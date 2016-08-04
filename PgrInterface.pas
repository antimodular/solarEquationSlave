unit PgrInterface;

interface

uses
  PgrKsMedia, Windows;

type
  IPgrInterface = interface(IUnknown)
    function GetRegister(Address:DWord;out Value:DWord):HResult; stdcall;
	  function SetRegister(Address,Value:DWord):HResult; stdcall;
  	function GetFormat7(out Format7:TKsPropertyCustomFormat7S):HResult; stdcall;
    function SetFormat7(Mode,Left,Top,Width,Height,Percentage:DWord;
                        Format7:TKsPropertyCustomFormat7S):HResult; stdcall;
  end;


implementation

end.


