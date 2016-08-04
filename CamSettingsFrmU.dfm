object CamSettingsFrm: TCamSettingsFrm
  Left = 1947
  Top = 290
  BorderStyle = bsDialog
  Caption = 'Camera settings'
  ClientHeight = 225
  ClientWidth = 330
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
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 153
    Height = 57
    Color = 14141894
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 151
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Exposure'
      Color = 13869224
      ParentColor = False
    end
    object ExposureEdit: TNBFillEdit
      Left = 10
      Top = 24
      Width = 135
      Height = 21
      ArrowColor = 16744576
      BackGndColor = 14341570
      FillColor = 13146220
      FillWidth = 50
      ArrowWidth = 14
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Max = 100
      Value = 50
      OnValueChange = ExposureEditValueChange
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 168
    Top = 8
    Width = 153
    Height = 57
    Color = 14141894
    TabOrder = 1
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 151
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Gain'
      Color = 13869224
      ParentColor = False
    end
    object GainEdit: TNBFillEdit
      Left = 8
      Top = 24
      Width = 136
      Height = 21
      ArrowColor = 16744576
      BackGndColor = 14341570
      FillColor = 13146220
      FillWidth = 70
      ArrowWidth = 14
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Max = 100
      Value = 50
      OnValueChange = GainEditValueChange
      TabOrder = 0
    end
  end
  object Panel3: TPanel
    Left = 8
    Top = 72
    Width = 153
    Height = 98
    Color = 14141894
    TabOrder = 2
    object Label5: TLabel
      Left = 1
      Top = 1
      Width = 151
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'White balance'
      Color = 13869224
      ParentColor = False
    end
    object WhiteBalanceRedEdit: TNBFillEdit
      Left = 9
      Top = 43
      Width = 135
      Height = 21
      ArrowColor = 16744576
      BackGndColor = 14341570
      FillColor = 13146220
      FillWidth = 70
      ArrowWidth = 14
      Title = 'Red'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Max = 317
      Value = 100
      OnValueChange = WhiteBalanceRedEditValueChange
      TabOrder = 0
    end
    object AutoWhiteBalanceCB: TAprCheckBox
      Left = 13
      Top = 21
      Width = 76
      Height = 17
      Caption = 'Auto   Rate:'
      TabOrder = 1
      TabStop = True
      OnClick = AutoWhiteBalanceCBClick
    end
    object WhiteBalanceBlueEdit: TNBFillEdit
      Left = 9
      Top = 69
      Width = 135
      Height = 21
      ArrowColor = 16744576
      BackGndColor = 14341570
      FillColor = 13146220
      FillWidth = 70
      ArrowWidth = 14
      Title = 'Blue'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Max = 317
      Value = 100
      OnValueChange = WhiteBalanceBlueEditValueChange
      TabOrder = 2
    end
    object WhiteBalanceRateEdit: TAprSpinEdit
      Left = 90
      Top = 19
      Width = 53
      Height = 20
      Value = 100.000000000000000000
      Max = 100.000000000000000000
      Alignment = taCenter
      Enabled = True
      Increment = 1.000000000000000000
      EditText = '100'
      OnExit = WhiteBalanceRateEditExit
      TabOrder = 3
    end
  end
  object Panel4: TPanel
    Left = 169
    Top = 71
    Width = 153
    Height = 98
    Color = 14141894
    TabOrder = 3
    object Label6: TLabel
      Left = 1
      Top = 1
      Width = 151
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Network settings'
      Color = 13869224
      ParentColor = False
    end
    object Label3: TLabel
      Left = 14
      Top = 46
      Width = 58
      Height = 13
      Caption = 'Packet size:'
    end
    object Label4: TLabel
      Left = 8
      Top = 73
      Width = 65
      Height = 13
      Caption = 'Stream MB/s:'
    end
    object PacketSizeEdit: TAprSpinEdit
      Left = 78
      Top = 42
      Width = 60
      Height = 20
      Value = 1500.000000000000000000
      Min = 100.000000000000000000
      Max = 9014.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = PacketSizeEditChange
      Increment = 1.000000000000000000
      EditText = '1500'
      TabOrder = 0
    end
    object StreamBytesPerSecondEdit: TAprSpinEdit
      Left = 78
      Top = 69
      Width = 60
      Height = 20
      Value = 32.000000000000000000
      Decimals = 1
      Min = 1.000000000000000000
      Max = 124.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = StreamBytesPerSecondEditChange
      Increment = 1.000000000000000000
      EditText = '32.0'
      TabOrder = 1
    end
    object MulticastCB: TAprCheckBox
      Left = 21
      Top = 23
      Width = 97
      Height = 17
      Caption = 'Multicast'
      TabOrder = 2
      TabStop = True
      OnClick = MulticastCBClick
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 206
    Width = 330
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object FlipImageCB: TAprCheckBox
    Left = 8
    Top = 180
    Width = 70
    Height = 17
    Caption = 'Flip image'
    TabOrder = 5
    TabStop = True
    OnClick = FlipImageCBClick
  end
  object MirrorCB: TAprCheckBox
    Left = 98
    Top = 180
    Width = 79
    Height = 17
    Caption = 'Mirror image'
    TabOrder = 6
    TabStop = True
    OnClick = MirrorCBClick
  end
  object SmoothCB: TAprCheckBox
    Left = 190
    Top = 180
    Width = 97
    Height = 17
    Caption = 'Smooth image'
    TabOrder = 7
    TabStop = True
    OnClick = SmoothCBClick
  end
  object Timer: TTimer
    Enabled = False
    Interval = 50
    OnTimer = TimerTimer
    Left = 152
    Top = 104
  end
end
