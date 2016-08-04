unit PoemU;

interface

uses
  MMSystem, SysUtils, FileUtils, Global, Graphics, FountainU, Forms;

const
  MaxPoems   = 25;
  MaxColumns = 4;

type
  TFileName = String[64];

  TFontName = String[16];

  TFontRecord = record      // 22
    Name     : TFontName;
    Style    : TFontStyles;
    Size     : Integer;
    Reserved : array[1..12] of Byte;
  end;

  TColumnX = array[1..MaxColumns] of Single;

  TBlockText = String[24];

  TBlockRecord = record
    Text     : TBlockText;   // 25
    Font     : TFontRecord;  // 22
    Color    : TColor;       // 4
    X,Y      : Integer;
    Reserved : array[1..4] of Byte;
  end;

  TPoemInfo = record
    Size             : Single;
    Columns          : Integer;
    ColumnX          : TColumnX;
    Blockage         : TBlockRecord;
    Arrangement      : TArrangement;
    XPadding         : Single;
    TitleArrangement : TArrangement;
    TitleXPadding    : Single;
    Title            : TPoemTitle;
    Duration         : DWord;
    Reserved         : array[1..9] of Byte;
  end;
  TPoemInfoArray = array[1..MaxPoems] of TPoemInfo;

  TPoem = class(TObject)
  private
    function  GetInfo:TPoemInfo;
    procedure SetInfo(NewInfo:TPoemInfo);
    function  AbleToLoadText:Boolean;

  public
    Tag : Integer;

    Size     : Single;
    Columns  : Integer;
    ColumnX  : TColumnX;
    Blockage : TBlockRecord;

    Lines   : Integer;
    Text    : TTextLines;
    TextPos : TTextPosition;

    Title    : TPoemTitle;
    Duration : DWord;

    Arrangement      : TArrangement;
    XPadding         : Single;
    TitleArrangement : TArrangement;
    TitleXPadding    : Single;

    property Info:TPoemInfo read GetInfo write SetInfo;

    constructor Create(iTag:Integer);

    procedure ShowText;
    procedure PlayWave;
    procedure Assert;
  end;
  TPoemArray = array[1..MaxPoems] of TPoem;

var
  Poems : Integer;
  Poem  : TPoemArray;

procedure CreatePoems;
procedure LoadPoems;
procedure FreePoems;

function  DefaultPoemInfoArray:TPoemInfoArray;
procedure ApplyPoemInfo(var PoemInfo:TPoemInfoArray);
function  GetInfoFromPoems:TPoemInfoArray;

implementation

uses
  Routines, AlphabetU, MemoFrmU;

procedure InitPoems;
var
  Info : TPoemInfoArray;
  P    : Integer;
begin
  Info:=DefaultPoemInfoArray;
  for P:=1 to MaxPoems do begin
    Poem[P].Arrangement:=Info[P].Arrangement;
    Poem[P].XPadding:=Info[P].XPadding;
    Poem[P].TitleArrangement:=Info[P].TitleArrangement;
    Poem[P].TitleXPadding:=Info[P].TitleXPadding;
  end;
end;

procedure ApplyPoemInfo(var PoemInfo:TPoemInfoArray);
var
  P : Integer;
begin
  for P:=1 to MaxPoems do begin
    Poem[P].Info:=PoemInfo[P];
  end;
 // InitPoems;
end;

function GetInfoFromPoems:TPoemInfoArray;
var
  P : Integer;
begin
  for P:=1 to MaxPoems do begin
    Result[P]:=Poem[P].Info;
  end;
end;

function DefaultPoemInfoArray:TPoemInfoArray;
var
  P,C : Integer;
begin
  for P:=1 to MaxPoems do with Result[P] do begin
    Size:=8;
    Columns:=1;
    for C:=1 to MaxColumns do ColumnX[C]:=-0.8+0.4*C;
    Blockage.Text:='Name';
    Blockage.Font.Name:='Arial';
    Blockage.Font.Style:=[];
    Blockage.Font.Size:=36;
    FillChar(Blockage.Font.Reserved,SizeOf(Blockage.Font.Reserved),0);
    Title[1]:='Title1';
    Title[2]:='Title2';
    Title[3]:='Title3';

    Duration:=30000;

    Arrangement.Position.X:=-0.61;
    Arrangement.Position.Y:=-0.39;
    Arrangement.Spacing.X:=+0.026;
    Arrangement.Spacing.Y:=-0.046;
    XPadding:=0.027;

    TitleArrangement.Position.X:=-0.61;
    TitleArrangement.Position.Y:=-0.35;
    TitleArrangement.Spacing.X:=+0.090;
    TitleArrangement.Spacing.Y:=-0.125;
    TitleXPadding:=0.090;

    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

procedure CreatePoems;
var
  P : Integer;
begin
  for P:=1 to MaxPoems do Poem[P]:=TPoem.Create(P);
end;

procedure FreePoems;
var
  P : Integer;
begin
  for P:=1 to MaxPoems do begin
    if Assigned(Poem[P]) then Poem[P].Free;
  end;
end;

function PoemFileName(P:Integer):String;
begin
  Result:=Path+'Poems\Text-'+TwoDigitIntStr(P)+'.txt';
end;

function WaveFileName(P:Integer):String;
begin
  Result:=Path+'Poems\Wave-'+TwoDigitIntStr(P)+'.wav';
end;

procedure LoadPoems;
var
  Done : Boolean;
begin
  Poems:=0;
  Done:=False;
  repeat
    if Poem[Poems+1].AbleToLoadText then Inc(Poems)
    else Done:=True;
  until (Poems=MaxPoems) or Done;
end;

constructor TPoem.Create(iTag: Integer);
begin
  Tag:=iTag;
  inherited Create;
end;

function TPoem.GetInfo: TPoemInfo;
begin
  Result.Size:=Size;
  Result.Columns:=Columns;
  Result.ColumnX:=ColumnX;
  Result.Blockage:=Blockage;
  Result.Title:=Title;
  Result.Duration:=Duration;

  Result.Arrangement:=Arrangement;
  Result.XPadding:=XPadding;

  Result.TitleArrangement:=TitleArrangement;
  Result.TitleXPadding:=TitleXPadding;

  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TPoem.SetInfo(NewInfo: TPoemInfo);
begin
  Size:=NewInfo.Size;
  Columns:=NewInfo.Columns;
  ColumnX:=NewInfo.ColumnX;
  Blockage:=NewInfo.Blockage;
  Title:=NewInfo.Title;
  Duration:=NewInfo.Duration;

  Arrangement:=NewInfo.Arrangement;
  XPadding:=NewInfo.XPadding;

  TitleArrangement:=NewInfo.TitleArrangement;
  TitleXPadding:=NewInfo.TitleXPadding;
end;

procedure TPoem.ShowText;
var
  I : Integer;
begin
  MemoFrm:=TMemoFrm.Create(Application);
  try
    for I:=1 to Lines do begin
      MemoFrm.Memo.Lines.Add(Text[I]);
    end;
    MemoFrm.ShowModal;
  finally
    MemoFrm.Free;
  end;
end;

procedure TPoem.PlayWave;
var
  FileName : String;
begin
  FileName:=WaveFileName(Tag);
  if FileExists(FileName) then begin
    SndPlaySound(PWideChar(FileName),SND_ASYNC);
  end;
end;

function TPoem.AbleToLoadText:Boolean;
var
  FileName : String;
  Line     : AnsiString;
  TxtFile  : TextFile;
  I        : Integer;
begin
  Result:=False;
  Lines:=0;
  FileName:=PoemFileName(Tag);
  if not FileExists(FileName) then Exit;

  AssignFile(TxtFile,FileName);
  try
    System.Reset(TxtFile);
    while not EOF(TxtFile) do begin
      Inc(Lines);
      ReadLn(TxtFile,Text[Lines]);
    end;
  finally
    CloseFile(TxtFile);
  end;
  Result:=True;
end;

procedure TPoem.Assert;
begin
  Fountain.Lines:=Lines;
  Fountain.Text:=Text;
  Fountain.ArrangeTextSideways;
end;

end.

var
  I,P      : Integer;
  Found    : Boolean;
  FileName : String;

