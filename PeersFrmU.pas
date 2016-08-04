unit PeersFrmU;

interface

uses
  Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, AprSpin;

type
  TPeersFrm = class(TForm)
    Label1: TLabel;
    PeersEdit: TAprSpinEdit;
    TabControl: TTabControl;
    Label2: TLabel;
    Edit: TEdit;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure PeersEditChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure TabControlChanging(Sender: TObject; var AllowChange: Boolean);

  private
    procedure InitTabControl;

  public
    procedure Initialize;
    procedure ShowSelectedPeer;
  end;

var
  PeersFrm: TPeersFrm;

implementation

{$R *.dfm}

uses
  PeerU;

procedure TPeersFrm.Initialize;
begin
  PeersEdit.Max:=MaxPeers;
  PeersEdit.Value:=Round(Peers);
  InitTabControl;
end;

procedure TPeersFrm.PeersEditChange(Sender: TObject);
begin
  Peers:=Round(PeersEdit.Value);
  InitTabControl;
end;

procedure TPeersFrm.InitTabControl;
var
  I : Integer;
begin
  TabControl.Tabs.Clear;
  for I:=1 to Peers do TabControl.Tabs.Add(IntToStr(I));

  TabControl.TabIndex:=1;

  ShowSelectedPeer;
end;

procedure TPeersFrm.ShowSelectedPeer;
var
  P : Integer;
begin
  P:=TabControl.TabIndex+1;
  Edit.Text:=Peer[P].IP;
end;

procedure TPeersFrm.TabControlChange(Sender: TObject);
begin
  ShowSelectedPeer;
end;

procedure TPeersFrm.TabControlChanging(Sender: TObject; var AllowChange: Boolean);
begin
  EditExit(nil);
  AllowChange:=True;
end;

procedure TPeersFrm.EditExit(Sender: TObject);
var
  P : Integer;
begin
  P:=TabControl.TabIndex+1;
  Peer[P].IP:=Edit.Text;
end;

procedure TPeersFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

end.
