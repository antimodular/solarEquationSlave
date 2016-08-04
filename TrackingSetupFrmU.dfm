object TrackingSetupFrm: TTrackingSetupFrm
  Left = 424
  Top = 381
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Tracking setup'
  ClientHeight = 559
  ClientWidth = 827
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Tag = 1
    Left = 8
    Top = 7
    Width = 659
    Height = 493
    OnMouseMove = PaintBoxMouseMove
    OnPaint = PaintBoxPaint
  end
  object XLcd: TLCD
    Left = 9
    Top = 506
    Width = 44
    Height = 27
    OffColor = 43
    SegWidth = 7
    SegHeight = 8
    LineWidth = 1
    Gap = 1
    Digits = 3
    ShowLead0 = False
    ShowSign = False
  end
  object YLcd: TLCD
    Left = 57
    Top = 506
    Width = 44
    Height = 27
    OffColor = 43
    SegWidth = 7
    SegHeight = 8
    LineWidth = 1
    Gap = 1
    Digits = 3
    ShowLead0 = False
    ShowSign = False
  end
  object FollowMouseCB: TAprCheckBox
    Left = 133
    Top = 514
    Width = 85
    Height = 17
    Caption = 'Follow mouse'
    TabOrder = 0
    TabStop = True
  end
  object Panel1: TPanel
    Left = 675
    Top = 8
    Width = 146
    Height = 78
    TabOrder = 1
    object Label7: TLabel
      Left = 1
      Top = 1
      Width = 144
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Camera'
      Color = 16756912
      ParentColor = False
      Transparent = False
      ExplicitWidth = 149
    end
    object FlipCB: TAprCheckBox
      Left = 65
      Top = 23
      Width = 41
      Height = 17
      Caption = 'Flip'
      TabOrder = 0
      TabStop = True
      OnClick = FlipCBClick
    end
    object MirrorCB: TAprCheckBox
      Left = 9
      Top = 23
      Width = 49
      Height = 17
      Caption = 'Mirror'
      TabOrder = 1
      TabStop = True
      OnClick = MirrorCBClick
    end
    object CamSettingsBtn: TButton
      Left = 8
      Top = 46
      Width = 61
      Height = 22
      Caption = 'Settings'
      TabOrder = 2
      OnClick = CamSettingsBtnClick
    end
    object InfoBtn: TButton
      Left = 79
      Top = 46
      Width = 56
      Height = 22
      Caption = 'Info'
      TabOrder = 3
      OnClick = InfoBtnClick
    end
  end
  object Panel2: TPanel
    Left = 673
    Top = 92
    Width = 149
    Height = 173
    TabOrder = 2
    object Label8: TLabel
      Left = 1
      Top = 1
      Width = 147
      Height = 13
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Tracking'
      Color = 16756912
      ParentColor = False
      Transparent = False
      ExplicitWidth = 148
    end
    object Label3: TLabel
      Left = 16
      Top = 26
      Width = 69
      Height = 13
      Caption = 'Low threshold:'
    end
    object Label4: TLabel
      Left = 15
      Top = 48
      Width = 71
      Height = 13
      Caption = 'High threshold:'
    end
    object Label5: TLabel
      Left = 13
      Top = 74
      Width = 71
      Height = 13
      Caption = 'Jump distance:'
    end
    object Label6: TLabel
      Left = 9
      Top = 99
      Width = 76
      Height = 13
      Caption = 'Merge distance:'
    end
    object MinAreaLbl: TLabel
      Left = 18
      Top = 126
      Width = 66
      Height = 13
      Caption = 'Mininum area:'
    end
    object LowThresholdEdit: TAprSpinEdit
      Left = 90
      Top = 22
      Width = 50
      Height = 20
      Value = 30.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = LowThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '30'
      TabOrder = 0
    end
    object HighThresholdEdit: TAprSpinEdit
      Left = 90
      Top = 46
      Width = 50
      Height = 20
      Value = 40.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = HighThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '40'
      TabOrder = 1
    end
    object JumpDEdit: TAprSpinEdit
      Left = 89
      Top = 70
      Width = 50
      Height = 20
      Value = 25.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = JumpDEditChange
      Increment = 1.000000000000000000
      EditText = '25'
      TabOrder = 2
    end
    object MergeDEdit: TAprSpinEdit
      Left = 90
      Top = 95
      Width = 50
      Height = 20
      Value = 25.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MergeDEditChange
      Increment = 1.000000000000000000
      EditText = '25'
      TabOrder = 3
    end
    object MinAreaEdit: TAprSpinEdit
      Left = 90
      Top = 120
      Width = 50
      Height = 20
      Value = 500.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MinAreaEditChange
      Increment = 1.000000000000000000
      EditText = '500'
      TabOrder = 4
    end
    object SmoothCB: TAprCheckBox
      Left = 20
      Top = 148
      Width = 61
      Height = 17
      Caption = 'Smooth'
      TabOrder = 5
      TabStop = True
      OnClick = SmoothCBClick
    end
  end
  object Panel3: TPanel
    Left = 686
    Top = 271
    Width = 124
    Height = 263
    TabOrder = 3
    object Label9: TLabel
      Left = 1
      Top = 1
      Width = 122
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Draw'
      Color = 11511183
      ParentColor = False
      Transparent = False
      ExplicitWidth = 148
    end
    object BackGndDrawPanel: TPanel
      Left = 9
      Top = 21
      Width = 104
      Height = 60
      Color = 13685705
      TabOrder = 0
      object Label11: TLabel
        Left = 1
        Top = 1
        Width = 102
        Height = 14
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'Background'
        Color = 11511183
        ParentColor = False
        Transparent = False
        ExplicitWidth = 115
      end
      object NormalRB: TRadioButton
        Left = 10
        Top = 20
        Width = 57
        Height = 17
        Caption = 'Normal'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object SubtractedRB: TRadioButton
        Left = 10
        Top = 38
        Width = 75
        Height = 17
        Caption = 'Subtracted'
        TabOrder = 1
      end
    end
    object ForeGndDrawPanel: TPanel
      Left = 10
      Top = 89
      Width = 104
      Height = 164
      Color = 13685705
      TabOrder = 1
      object Label14: TLabel
        Left = 1
        Top = 1
        Width = 102
        Height = 14
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'Foreground'
        Color = 11511183
        ParentColor = False
        Transparent = False
        ExplicitWidth = 118
      end
      object ThresholdsRB: TRadioButton
        Left = 7
        Top = 21
        Width = 80
        Height = 17
        Caption = 'Thresholds'
        TabOrder = 0
        TabStop = True
      end
      object TrackingViewRB: TRadioButton
        Left = 7
        Top = 43
        Width = 83
        Height = 17
        Caption = 'Tracking info'
        Checked = True
        TabOrder = 1
        TabStop = True
      end
      object StripsCB: TAprCheckBox
        Left = 21
        Top = 63
        Width = 47
        Height = 17
        Caption = 'Strips'
        TabOrder = 2
        TabStop = True
      end
      object TargetsCB: TAprCheckBox
        Left = 21
        Top = 120
        Width = 61
        Height = 17
        Caption = 'Targets'
        TabOrder = 4
        TabStop = True
      end
      object BlobsCB: TAprCheckBox
        Left = 21
        Top = 101
        Width = 57
        Height = 17
        Caption = 'Blobs'
        TabOrder = 5
        TabStop = True
      end
      object MaskCB: TAprCheckBox
        Left = 21
        Top = 139
        Width = 78
        Height = 17
        Caption = 'Track mask'
        TabOrder = 6
        TabStop = True
      end
      object AllStripsCB: TAprCheckBox
        Left = 37
        Top = 79
        Width = 47
        Height = 17
        Caption = 'All'
        TabOrder = 3
        TabStop = True
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 540
    Width = 827
    Height = 19
    Panels = <>
  end
  object TrackMaskBtn: TButton
    Left = 320
    Top = 507
    Width = 75
    Height = 25
    Caption = 'Track mask'
    TabOrder = 5
    OnClick = TrackMaskBtnClick
  end
end
