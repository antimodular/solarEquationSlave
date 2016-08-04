object ProjectorFrm: TProjectorFrm
  Left = 755
  Top = 945
  Caption = 'ProjectorFrm'
  ClientHeight = 305
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GLPanel: TCanvasPanel
    Left = 0
    Top = 0
    Width = 472
    Height = 305
    Align = alClient
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 0
    OnMouseDown = GLPanelMouseDown
  end
  object Timer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = TimerTimer
    Left = 15
    Top = 16
  end
  object PopupMenu1: TPopupMenu
    Left = 232
    Top = 152
    object ProjectorSetupItem: TMenuItem
      Caption = '&Projector setup'
    end
    object BlendingSetupItem: TMenuItem
      Caption = '&Blending setup'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExitItem: TMenuItem
      Caption = 'E&xit'
      OnClick = ExitItemClick
    end
  end
end
