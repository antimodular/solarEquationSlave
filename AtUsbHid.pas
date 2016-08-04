unit AtUsbHid;

interface

uses
  Windows;

const
  ERROR_USB_DEVICE_NOT_FOUND       = $E0000001;
  ERROR_USB_DEVICE_NO_CAPABILITIES = $E0000002;

  AtmelID  = $03EB;
  UsbKeyID = $2013;

type
  TUsbBuffer = array[1..16] of Byte;
  TOnDeviceChange = function(nEventType,dwData:DWord):Boolean of Object;

function findHidDevice(const VendorID,ProductID:DWord):Boolean; stdcall;

procedure closeDevice; stdcall;

function writeData(Buffer:PByte):Boolean; stdcall;
function readData(Buffer:PByte):Boolean; stdcall;

function writeContinuous(Buffer:PByte):Boolean; stdcall;

function hidRegisterDeviceNotification(HWnd:Integer):Integer; stdcall;
procedure hidUnregisterDeviceNotification(HWnd:Integer); stdcall;
function isMyDeviceNotification(Data:DWord):Integer; stdcall;

function StartBootLoader:Boolean; stdcall;

function setFeature(FType,Direction:Byte;Length:DWord):Boolean; stdcall;

procedure setReportContinuous; stdcall;

procedure openDevice; stdcall;

implementation

const
  DllName = 'AtUsbHid.dll';

function findHidDevice(const VendorID,ProductID:DWord):Boolean; external DllName;
procedure closeDevice; external DllName;

function writeData(Buffer:PByte):Boolean; external DllName;
function readData(Buffer:PByte):Boolean; external DllName;

function writeContinuous(Buffer:PByte):Boolean; external DllName;

function hidRegisterDeviceNotification(HWnd:Integer):Integer; external DllName;
procedure hidUnregisterDeviceNotification(HWnd:Integer); external DllName;
function isMyDeviceNotification(Data:DWord):Integer; external DllName;

function startBootLoader:Boolean; external DllName;

function setFeature(FType,Direction:Byte;Length:DWord):Boolean; external DllName;

procedure setReportContinuous; external DllName;

procedure openDevice; external DllName;

end.



