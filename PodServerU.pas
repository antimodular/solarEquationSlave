unit PodServerU;

interface

uses
  ZmqServerU, Classes, Global;

type
  TPodServer = class(TObject)
  private
    ZmqServer : TZmqServer;

  public
    IP : TIpAddress;

    constructor Create;
    destructor  Destroy; override;

    procedure SetToDefault;
    procedure ReadFromStream(Stream:TFileStream);
    procedure WriteToStream(Stream:TFileStream);
  end;

var
  PodServer : TPodServer;

implementation

constructor TPodServer.Create;
begin
end;

destructor TPodServer.Destroy;
begin
end;

procedure TPodServer.SetToDefault;
begin
  IP:='?';
end;

procedure TPodServer.ReadFromStream(Stream: TFileStream);
begin
//  Stream.Read(IP,S
end;

procedure TPodServer.WriteToStream(Stream: TFileStream);
begin

end;

end.
