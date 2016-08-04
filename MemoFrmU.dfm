object MemoFrm: TMemoFrm
  Left = 196
  Top = 103
  Width = 334
  Height = 245
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 23
    Width = 326
    Height = 195
    Align = alBottom
    Lines.Strings = (
      '')
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object ClearBtn: TButton
    Left = 8
    Top = 3
    Width = 65
    Height = 17
    Caption = 'Clear'
    TabOrder = 1
  end
end
