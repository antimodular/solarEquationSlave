unit SliceU;

interface

uses
  Global;

type


  TSlice = class(TObject)
  private
    Radius : Single;
    Height : Single;
    Stacks : Integer;
    Slices : Integer;

    procedure CreateVertices;

  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor Create;
begin
  inherited;
  Rows
end;

destructor Destroy;
begin
  inherited;
end;

end.
