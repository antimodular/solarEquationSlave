object PeersFrm: TPeersFrm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Peers'
  ClientHeight = 115
  ClientWidth = 143
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 19
    Top = 13
    Width = 31
    Height = 13
    Caption = 'Peers:'
  end
  object PeersEdit: TAprSpinEdit
    Left = 54
    Top = 10
    Width = 48
    Height = 20
    Min = 1.000000000000000000
    Max = 4.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = PeersEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 0
  end
  object TabControl: TTabControl
    Left = 9
    Top = 43
    Width = 125
    Height = 62
    TabOrder = 1
    Tabs.Strings = (
      '1')
    TabIndex = 0
    OnChange = TabControlChange
    OnChanging = TabControlChanging
    object Label2: TLabel
      Left = 11
      Top = 34
      Width = 14
      Height = 13
      Caption = 'IP:'
    end
    object Edit: TEdit
      Left = 31
      Top = 30
      Width = 82
      Height = 21
      TabOrder = 0
      OnExit = EditExit
    end
  end
end
