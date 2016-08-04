object SeasonSetupFrm: TSeasonSetupFrm
  Left = 551
  Top = 219
  ClientHeight = 328
  ClientWidth = 471
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 11
    Top = 10
    Width = 57
    Height = 13
    Caption = 'Set season:'
  end
  object SeasonTC: TTabControl
    Left = 8
    Top = 34
    Width = 457
    Height = 287
    TabOrder = 0
    Tabs.Strings = (
      'Live'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11')
    TabIndex = 0
    TabWidth = 37
    OnChange = SeasonTCChange
    object LayerTC: TTabControl
      Left = 24
      Top = 37
      Width = 401
      Height = 239
      TabOrder = 0
      Tabs.Strings = (
        'Free running'
        'Controlled')
      TabIndex = 0
      OnChange = LayerTCChange
      object FxPageControl: TPageControl
        Left = 13
        Top = 32
        Width = 372
        Height = 192
        ActivePage = ReactDiffuse1Page
        TabOrder = 0
        object MP3Page: TTabSheet
          Caption = 'MP3'
          ImageIndex = 5
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label27: TLabel
            Left = 50
            Top = 38
            Width = 32
            Height = 13
            Caption = 'Index:'
          end
          object MP3IndexEdit: TAprSpinEdit
            Left = 88
            Top = 34
            Width = 48
            Height = 20
            Value = 1.000000000000000000
            Min = 1.000000000000000000
            Max = 8.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = MP3IndexEditChange
            Increment = 1.000000000000000000
            EditText = '1'
            TabOrder = 0
          end
          object MP3VolumeEdit: TNBFillEdit
            Left = 34
            Top = 80
            Width = 167
            Height = 22
            BackGndColor = 13062247
            FillColor = 13480380
            FillWidth = 100
            ArrowWidth = 17
            Title = 'Volume'
            EditFont.Charset = DEFAULT_CHARSET
            EditFont.Color = clBlack
            EditFont.Height = -11
            EditFont.Name = 'Tahoma'
            EditFont.Style = []
            EditColor = clWindow
            Alignment = taCenter
            SpeedUpDelay = 200
            SpeedUpPeriod = 50
            Max = 100
            Value = 50
            OnValueChange = MP3VolumeEditValueChange
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            TabOrder = 1
          end
          object PlayBtn: TBitBtn
            Left = 242
            Top = 25
            Width = 75
            Height = 25
            Caption = 'Play'
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000130B0000130B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
              33333333333333333333EEEEEEEEEEEEEEE333FFFFFFFFFFFFF3E00000000000
              00E337777777777777F3E0F77777777770E337F33333333337F3E0F333333333
              70E337F3333F333337F3E0F33303333370E337F3337FF33337F3E0F333003333
              70E337F33377FF3337F3E0F33300033370E337F333777FF337F3E0F333000033
              70E337F33377773337F3E0F33300033370E337F33377733337F3E0F333003333
              70E337F33377333337F3E0F33303333370E337F33373333337F3E0F333333333
              70E337F33333333337F3E0FFFFFFFFFFF0E337FFFFFFFFFFF7F3E00000000000
              00E33777777777777733EEEEEEEEEEEEEEE33333333333333333}
            NumGlyphs = 2
            TabOrder = 2
            OnClick = PlayBtnClick
          end
          object StopBtn: TBitBtn
            Left = 242
            Top = 61
            Width = 75
            Height = 25
            Caption = 'Stop'
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000130B0000130B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
              33333333333333333333EEEEEEEEEEEEEEE333FFFFFFFFFFFFF3E00000000000
              00E337777777777777F3E0F77777777770E337F33333333337F3E0F333333333
              70E337F33333333337F3E0F33333333370E337F333FFFFF337F3E0F330000033
              70E337F3377777F337F3E0F33000003370E337F3377777F337F3E0F330000033
              70E337F3377777F337F3E0F33000003370E337F3377777F337F3E0F330000033
              70E337F33777773337F3E0F33333333370E337F33333333337F3E0F333333333
              70E337F33333333337F3E0FFFFFFFFFFF0E337FFFFFFFFFFF7F3E00000000000
              00E33777777777777733EEEEEEEEEEEEEEE33333333333333333}
            NumGlyphs = 2
            TabOrder = 3
            OnClick = StopBtnClick
          end
        end
        object CubeMapPage: TTabSheet
          Caption = 'CubeMap'
          ImageIndex = 5
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label14: TLabel
            Left = 54
            Top = 63
            Width = 31
            Height = 13
            Caption = 'Alpha:'
          end
          object Label15: TLabel
            Left = 54
            Top = 37
            Width = 32
            Height = 13
            Caption = 'Index:'
          end
          object CubeMapPB: TPaintBox
            Left = 167
            Top = 37
            Width = 168
            Height = 56
            OnPaint = CubeMapPBPaint
          end
          object Label46: TLabel
            Left = 30
            Top = 90
            Width = 54
            Height = 13
            Caption = 'Rotation V:'
          end
          object CubeMapEnabledCB: TAprCheckBox
            Left = 25
            Top = 15
            Width = 81
            Height = 13
            Caption = 'Use'
            TabOrder = 0
            TabStop = True
            OnClick = CubeMapEnabledCBClick
          end
          object CubeMapAlphaEdit: TAprSpinEdit
            Left = 88
            Top = 60
            Width = 59
            Height = 20
            Decimals = 2
            Max = 1.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = CubeMapAlphaEditChange
            Increment = 0.009999999776482582
            EditText = '0.00'
            TabOrder = 1
          end
          object CubeMapIndexEdit: TAprSpinEdit
            Left = 88
            Top = 34
            Width = 59
            Height = 20
            Value = 1.000000000000000000
            Min = 1.000000000000000000
            Max = 8.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = CubeMapIndexEditChange
            Increment = 1.000000000000000000
            EditText = '1'
            TabOrder = 2
          end
          object CubeMapRotateVEdit: TAprSpinEdit
            Left = 88
            Top = 86
            Width = 59
            Height = 20
            Decimals = 1
            Min = -360.000000000000000000
            Max = 360.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = CubeMapRotateVEditChange
            Increment = 1.000000000000000000
            EditText = '0.0'
            TabOrder = 3
          end
        end
        object ImagePage: TTabSheet
          Caption = 'Image'
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label16: TLabel
            Left = 54
            Top = 63
            Width = 31
            Height = 13
            Caption = 'Alpha:'
          end
          object ImagePB: TPaintBox
            Left = 167
            Top = 61
            Width = 168
            Height = 56
            OnPaint = ImagePBPaint
          end
          object Label17: TLabel
            Left = 54
            Top = 37
            Width = 32
            Height = 13
            Caption = 'Index:'
          end
          object Label9: TLabel
            Left = 46
            Top = 89
            Width = 38
            Height = 13
            Caption = 'T Scale:'
          end
          object Label42: TLabel
            Left = 40
            Top = 113
            Width = 44
            Height = 13
            Caption = 'T Offset:'
          end
          object Label43: TLabel
            Left = 31
            Top = 141
            Width = 54
            Height = 13
            Caption = 'Rotation V:'
          end
          object ImageAlphaEdit: TAprSpinEdit
            Left = 88
            Top = 60
            Width = 61
            Height = 20
            Decimals = 2
            Max = 1.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = ImageAlphaEditChange
            Increment = 0.009999999776482582
            EditText = '0.00'
            TabOrder = 0
          end
          object ImageEnabledCB: TAprCheckBox
            Left = 25
            Top = 15
            Width = 81
            Height = 13
            Caption = 'Use'
            TabOrder = 1
            TabStop = True
            OnClick = ImageEnabledCBClick
          end
          object ImageIndexEdit: TAprSpinEdit
            Left = 88
            Top = 34
            Width = 61
            Height = 20
            Value = 1.000000000000000000
            Min = 1.000000000000000000
            Max = 8.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = ImageIndexEditChange
            Increment = 1.000000000000000000
            EditText = '1'
            TabOrder = 2
          end
          object ImageTScaleEdit: TAprSpinEdit
            Left = 87
            Top = 86
            Width = 61
            Height = 20
            Decimals = 2
            Max = 9.989999771118164000
            Alignment = taCenter
            Enabled = True
            OnChange = ImageTScaleEditChange
            Increment = 0.009999999776482582
            EditText = '0.00'
            TabOrder = 3
          end
          object ImageTOffsetEdit: TAprSpinEdit
            Left = 87
            Top = 111
            Width = 61
            Height = 20
            Decimals = 2
            Min = -0.990000009536743200
            Max = 9.989999771118164000
            Alignment = taCenter
            Enabled = True
            OnChange = ImageTOffsetEditChange
            Increment = 0.009999999776482582
            EditText = '0.00'
            TabOrder = 4
          end
          object ImageRotateVEdit: TAprSpinEdit
            Left = 87
            Top = 137
            Width = 61
            Height = 20
            Decimals = 1
            Min = -99.989997863769530000
            Max = 99.989997863769530000
            Alignment = taCenter
            Enabled = True
            OnChange = ImageRotateVEditChange
            Increment = 1.000000000000000000
            EditText = '0.0'
            TabOrder = 5
          end
        end
        object ReactDiffuse1Page: TTabSheet
          Caption = 'React / Diffuse'
          ImageIndex = 1
          object Label18: TLabel
            Left = 11
            Top = 87
            Width = 34
            Height = 13
            Caption = 'Speed:'
          end
          object RepeatsLbl: TLabel
            Left = 69
            Top = 88
            Width = 44
            Height = 13
            Caption = 'Repeats:'
          end
          object Label44: TLabel
            Left = 144
            Top = 103
            Width = 54
            Height = 13
            Caption = 'Rotation V:'
          end
          object Panel3: TPanel
            Left = 72
            Top = 47
            Width = 232
            Height = 35
            TabOrder = 0
            object Label19: TLabel
              Left = 11
              Top = 12
              Width = 10
              Height = 13
              Caption = 'F:'
            end
            object Label20: TLabel
              Left = 83
              Top = 13
              Width = 10
              Height = 13
              Caption = 'K:'
            end
            object Label21: TLabel
              Left = 155
              Top = 13
              Width = 11
              Height = 13
              Caption = 'H:'
            end
            object FEdit: TAprSpinEdit
              Tag = 1
              Left = 27
              Top = 8
              Width = 48
              Height = 20
              Max = 999.000000000000000000
              Alignment = taCenter
              Enabled = True
              OnChange = FEditChange
              Increment = 1.000000000000000000
              EditText = '0'
              TabOrder = 0
            end
            object KEdit: TAprSpinEdit
              Tag = 1
              Left = 97
              Top = 8
              Width = 48
              Height = 20
              Max = 999.000000000000000000
              Alignment = taCenter
              Enabled = True
              OnChange = KEditChange
              Increment = 1.000000000000000000
              EditText = '0'
              TabOrder = 1
            end
            object HEdit: TAprSpinEdit
              Tag = 1
              Left = 169
              Top = 8
              Width = 48
              Height = 20
              Max = 999.000000000000000000
              Alignment = taCenter
              Enabled = True
              OnChange = HEditChange
              Increment = 1.000000000000000000
              EditText = '0'
              TabOrder = 2
            end
          end
          object RandomizeBtn: TBitBtn
            Tag = 1
            Left = 272
            Top = 97
            Width = 80
            Height = 25
            Caption = 'Randomize'
            TabOrder = 1
            OnClick = RandomizeBtnClick
          end
          object Panel4: TPanel
            Left = 71
            Top = 2
            Width = 284
            Height = 37
            TabOrder = 2
            object Label28: TLabel
              Left = 7
              Top = 14
              Width = 37
              Height = 13
              Caption = 'Divider:'
            end
            object Label29: TLabel
              Left = 107
              Top = 14
              Width = 29
              Height = 13
              Caption = 'Scale:'
            end
            object Label31: TLabel
              Left = 194
              Top = 14
              Width = 31
              Height = 13
              Caption = 'Alpha:'
            end
            object DividerEdit: TAprSpinEdit
              Tag = 1
              Left = 47
              Top = 10
              Width = 48
              Height = 20
              Value = 0.500000000000000000
              Decimals = 2
              Max = 999.000000000000000000
              Alignment = taCenter
              Enabled = True
              OnChange = DividerEditChange
              Increment = 0.100000001490116100
              EditText = '0.50'
              TabOrder = 0
            end
            object ScaleEdit: TAprSpinEdit
              Tag = 1
              Left = 137
              Top = 10
              Width = 48
              Height = 20
              Value = 1.000000000000000000
              Decimals = 2
              Max = 999.000000000000000000
              Alignment = taCenter
              Enabled = True
              OnChange = ScaleEditChange
              Increment = 1.000000000000000000
              EditText = '1.00'
              TabOrder = 1
            end
            object RdAlphaEdit: TAprSpinEdit
              Tag = 1
              Left = 229
              Top = 10
              Width = 48
              Height = 20
              Decimals = 2
              Max = 1.000000000000000000
              Alignment = taCenter
              Enabled = True
              OnChange = RdAlphaEditChange
              Increment = 0.009999999776482582
              EditText = '0.00'
              TabOrder = 2
            end
          end
          object ReactDiffuseCB: TAprCheckBox
            Tag = 1
            Left = 25
            Top = 15
            Width = 41
            Height = 13
            Caption = 'Use'
            TabOrder = 3
            TabStop = True
            OnClick = ReactDiffuseCBClick
          end
          object SpeedEdit: TAprSpinEdit
            Left = 10
            Top = 101
            Width = 48
            Height = 20
            Value = 1.000000000000000000
            Min = 1.000000000000000000
            Max = 99.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = SpeedEditChange
            Increment = 1.000000000000000000
            EditText = '1'
            TabOrder = 4
          end
          object RepeatsEdit: TAprSpinEdit
            Left = 68
            Top = 101
            Width = 53
            Height = 20
            Value = 1.000000000000000000
            Decimals = 1
            Min = 0.100000001490116100
            Max = 9.899999618530273000
            Alignment = taCenter
            Enabled = True
            OnChange = RepeatsEditChange
            Increment = 0.100000001490116100
            EditText = '1.0'
            TabOrder = 5
          end
          object RDRotateVEdit: TAprSpinEdit
            Left = 202
            Top = 99
            Width = 60
            Height = 20
            Decimals = 1
            Min = -99.989997863769530000
            Max = 99.989997863769530000
            Alignment = taCenter
            Enabled = True
            OnChange = RDRotateVEditChange
            Increment = 1.000000000000000000
            EditText = '0.0'
            TabOrder = 6
          end
        end
        object PerlinPage: TTabSheet
          Caption = 'Perlin noise'
          ImageIndex = 2
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label33: TLabel
            Left = 65
            Top = 39
            Width = 31
            Height = 13
            Caption = 'Alpha:'
          end
          object Label34: TLabel
            Left = 216
            Top = 40
            Width = 86
            Height = 13
            Caption = 'Foreground color:'
          end
          object Label35: TLabel
            Left = 216
            Top = 71
            Width = 86
            Height = 13
            Caption = 'Background color:'
          end
          object Label36: TLabel
            Left = 44
            Top = 65
            Width = 52
            Height = 13
            Caption = 'Boil speed:'
          end
          object Label37: TLabel
            Left = 67
            Top = 92
            Width = 29
            Height = 13
            Caption = 'Scale:'
          end
          object Label10: TLabel
            Left = 42
            Top = 116
            Width = 54
            Height = 13
            Caption = 'Rotation V:'
          end
          object PerlinCB: TAprCheckBox
            Tag = 1
            Left = 25
            Top = 15
            Width = 41
            Height = 13
            Caption = 'Use'
            TabOrder = 0
            TabStop = True
            OnClick = PerlinCBClick
          end
          object PerlinAlphaEdit: TAprSpinEdit
            Left = 102
            Top = 35
            Width = 61
            Height = 20
            Decimals = 2
            Max = 1.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = PerlinAlphaEditChange
            Increment = 0.009999999776482582
            EditText = '0.00'
            TabOrder = 1
          end
          object PerlinForeGndColorBtn: TColorBtn
            Left = 308
            Top = 34
            Width = 29
            Height = 25
            Caption = ''
            OnClick = PerlinForeGndColorBtnClick
            TabOrder = 2
          end
          object PerlinBackGndColorBtn: TColorBtn
            Left = 308
            Top = 65
            Width = 29
            Height = 25
            Caption = ''
            OnClick = PerlinBackGndColorBtnClick
            TabOrder = 3
          end
          object PerlinBoilSpeedEdit: TAprSpinEdit
            Left = 100
            Top = 61
            Width = 61
            Height = 20
            Decimals = 2
            Max = 1.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = PerlinBoilSpeedEditChange
            Increment = 0.100000001490116100
            EditText = '0.00'
            TabOrder = 4
          end
          object PerlinScaleEdit: TAprSpinEdit
            Left = 100
            Top = 87
            Width = 61
            Height = 20
            Value = 0.100000001490116100
            Decimals = 1
            Min = 0.100000001490116100
            Max = 999.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = PerlinScaleEditChange
            Increment = 0.100000001490116100
            EditText = '0.1'
            TabOrder = 5
          end
          object PerlinRotateVEdit: TAprSpinEdit
            Left = 100
            Top = 112
            Width = 60
            Height = 20
            Decimals = 1
            Min = -99.989997863769530000
            Max = 99.989997863769530000
            Alignment = taCenter
            Enabled = True
            OnChange = PerlinRotateVEditChange
            Increment = 1.000000000000000000
            EditText = '0.0'
            TabOrder = 6
          end
        end
        object TabSheet2: TTabSheet
          Caption = 'Particles'
          ImageIndex = 4
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label39: TLabel
            Left = 86
            Top = 39
            Width = 31
            Height = 13
            Caption = 'Alpha:'
          end
          object Label2: TLabel
            Left = 209
            Top = 39
            Width = 54
            Height = 13
            Caption = 'Divider #1:'
          end
          object Label3: TLabel
            Left = 209
            Top = 66
            Width = 54
            Height = 13
            Caption = 'Divider #2:'
          end
          object Label22: TLabel
            Left = 70
            Top = 64
            Width = 49
            Height = 13
            Caption = 'Point size:'
          end
          object Label4: TLabel
            Left = 67
            Top = 91
            Width = 52
            Height = 13
            Caption = 'Min speed:'
          end
          object Label5: TLabel
            Left = 63
            Top = 116
            Width = 56
            Height = 13
            Caption = 'Max speed:'
          end
          object Label48: TLabel
            Left = 62
            Top = 140
            Width = 54
            Height = 13
            Caption = 'Rotation V:'
          end
          object Label6: TLabel
            Left = 232
            Top = 91
            Width = 34
            Height = 13
            Caption = 'Max R:'
          end
          object Label7: TLabel
            Left = 187
            Top = 114
            Width = 79
            Height = 13
            Caption = 'Alpha threshold:'
          end
          object Label8: TLabel
            Left = 217
            Top = 139
            Width = 47
            Height = 13
            Caption = 'Spot size:'
          end
          object ParticlesEnabledCB: TAprCheckBox
            Tag = 1
            Left = 25
            Top = 15
            Width = 41
            Height = 13
            Caption = 'Use'
            TabOrder = 0
            TabStop = True
            OnClick = ParticlesEnabledCBClick
          end
          object ParticlesAlphaEdit: TAprSpinEdit
            Left = 120
            Top = 36
            Width = 62
            Height = 20
            Decimals = 2
            Max = 1.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesAlphaEditChange
            Increment = 0.009999999776482582
            EditText = '0.00'
            TabOrder = 1
          end
          object ParticlesDivider1Edit: TAprSpinEdit
            Left = 268
            Top = 36
            Width = 61
            Height = 20
            Value = 999.989990234375000000
            Decimals = 2
            Max = 999.989990234375000000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesDivider1EditChange
            Increment = 0.100000001490116100
            EditText = '999.99'
            TabOrder = 2
          end
          object ParticlesDivider2Edit: TAprSpinEdit
            Left = 268
            Top = 62
            Width = 61
            Height = 20
            Value = 999.989990234375000000
            Decimals = 2
            Max = 999.989990234375000000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesDivider2EditChange
            Increment = 0.100000001490116100
            EditText = '999.99'
            TabOrder = 3
          end
          object ParticlesPointSizeEdit: TAprSpinEdit
            Left = 120
            Top = 61
            Width = 62
            Height = 20
            Value = 1.000000000000000000
            Decimals = 1
            Min = 1.000000000000000000
            Max = 999.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesPointSizeEditChange
            Increment = 1.000000000000000000
            EditText = '1.0'
            TabOrder = 4
          end
          object ParticlesMinSpeedEdit: TAprSpinEdit
            Left = 120
            Top = 87
            Width = 62
            Height = 20
            Value = 1.000000000000000000
            Decimals = 3
            Max = 9.989999771118164000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesMinSpeedEditChange
            Increment = 0.001000000047497451
            EditText = '1.000'
            TabOrder = 5
          end
          object ParticlesMaxSpeedEdit: TAprSpinEdit
            Left = 120
            Top = 112
            Width = 62
            Height = 20
            Value = 1.000000000000000000
            Decimals = 3
            Max = 9.989999771118164000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesMaxSpeedEditChange
            Increment = 0.001000000047497451
            EditText = '1.000'
            TabOrder = 6
          end
          object ParticlesRotateVEdit: TAprSpinEdit
            Left = 120
            Top = 136
            Width = 62
            Height = 20
            Decimals = 1
            Min = -360.000000000000000000
            Max = 360.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesRotateVEditChange
            Increment = 1.000000000000000000
            EditText = '0.0'
            TabOrder = 7
          end
          object ParticlesMaxREdit: TAprSpinEdit
            Left = 268
            Top = 87
            Width = 58
            Height = 20
            Value = 1.000000000000000000
            Decimals = 3
            Max = 999.999023437500000000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesMaxREditChange
            Increment = 0.001000000047497451
            EditText = '1.000'
            TabOrder = 8
          end
          object ParticlesAlphaThresholdEdit: TAprSpinEdit
            Left = 268
            Top = 111
            Width = 58
            Height = 20
            Decimals = 2
            Max = 1.000000000000000000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesAlphaThresholdEditChange
            Increment = 0.009999999776482582
            EditText = '0.00'
            TabOrder = 9
          end
          object ParticlesMaxSpotSizeEdit: TAprSpinEdit
            Left = 268
            Top = 135
            Width = 58
            Height = 20
            Decimals = 1
            Max = 99.900001525878910000
            Alignment = taCenter
            Enabled = True
            OnChange = ParticlesMaxSpotSizeEditChange
            Increment = 0.100000001490116100
            EditText = '0.0'
            TabOrder = 10
          end
        end
      end
    end
  end
  object SeasonEdit: TAprSpinEdit
    Left = 69
    Top = 7
    Width = 48
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 11.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = SeasonEditChange
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 1
  end
  object RotateCB: TAprCheckBox
    Left = 137
    Top = 10
    Width = 72
    Height = 13
    Caption = 'Rotate at'
    TabOrder = 2
    TabStop = True
    OnClick = RotateCBClick
  end
  object RotateSpeedEdit: TAprSpinEdit
    Left = 208
    Top = 7
    Width = 57
    Height = 20
    Value = 0.050000000745058060
    Decimals = 2
    Min = -9.989999771118164000
    Max = 9.989999771118164000
    Alignment = taCenter
    Enabled = True
    Increment = 0.009999999776482582
    EditText = '0.05'
    TabOrder = 3
  end
  object ColorDlg: TColorDialog
    Left = 160
    Top = 8
  end
  object RotateTimer: TTimer
    Enabled = False
    Interval = 20
    OnTimer = RotateTimerTimer
    Left = 424
    Top = 2
  end
end
