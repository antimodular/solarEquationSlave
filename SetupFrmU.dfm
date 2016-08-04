object SetupFrm: TSetupFrm
  Left = 437
  Top = 262
  ClientHeight = 274
  ClientWidth = 570
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 470
    Top = 93
    Width = 86
    Height = 96
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 84
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Render'
      Color = 14798523
      ParentColor = False
      Transparent = False
      ExplicitWidth = 35
    end
    object WireframeRB: TRadioButton
      Left = 9
      Top = 22
      Width = 72
      Height = 17
      Caption = 'Wireframe'
      TabOrder = 0
      OnClick = WireframeRBClick
    end
    object SolidRB: TRadioButton
      Left = 9
      Top = 46
      Width = 59
      Height = 17
      Caption = 'Solid'
      TabOrder = 1
      OnClick = SolidRBClick
    end
    object TexturedRB: TRadioButton
      Left = 9
      Top = 69
      Width = 67
      Height = 17
      Caption = 'Textured'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnClick = TexturedRBClick
    end
  end
  object ProjectorTC: TTabControl
    Left = 8
    Top = 6
    Width = 450
    Height = 254
    TabOrder = 1
    Tabs.Strings = (
      '1'
      '2')
    TabIndex = 0
    OnChange = ProjectorTCChange
    object WindowPanel: TPanel
      Left = 12
      Top = 33
      Width = 182
      Height = 76
      TabOrder = 0
      object Label24: TLabel
        Left = 1
        Top = 1
        Width = 180
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'Desktop window'
        Color = 15123895
        ParentColor = False
        Transparent = False
        ExplicitWidth = 78
      end
      object Label22: TLabel
        Left = 12
        Top = 23
        Width = 10
        Height = 13
        Caption = 'X:'
      end
      object Label25: TLabel
        Left = 94
        Top = 23
        Width = 10
        Height = 13
        Caption = 'Y:'
      end
      object Label26: TLabel
        Left = 10
        Top = 50
        Width = 14
        Height = 13
        Caption = 'W:'
      end
      object Label27: TLabel
        Left = 94
        Top = 50
        Width = 11
        Height = 13
        Caption = 'H:'
      end
      object WindowXEdit: TAprSpinEdit
        Left = 26
        Top = 20
        Width = 58
        Height = 20
        Value = -9999.000000000000000000
        Min = -9999.000000000000000000
        Max = 9999.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = WindowXEditChange
        Increment = 1.000000000000000000
        EditText = '-9999'
        TabOrder = 0
      end
      object WindowYEdit: TAprSpinEdit
        Left = 108
        Top = 20
        Width = 58
        Height = 20
        Value = -9999.000000000000000000
        Min = -9999.000000000000000000
        Max = 9999.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = WindowYEditChange
        Increment = 1.000000000000000000
        EditText = '-9999'
        TabOrder = 1
      end
      object WindowWEdit: TAprSpinEdit
        Left = 27
        Top = 46
        Width = 58
        Height = 20
        Value = -9999.000000000000000000
        Min = 1.000000000000000000
        Max = 9999.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = WindowWEditChange
        Increment = 1.000000000000000000
        EditText = '-9999'
        TabOrder = 2
      end
      object WindowHEdit: TAprSpinEdit
        Left = 109
        Top = 46
        Width = 58
        Height = 20
        Value = -9999.000000000000000000
        Min = 1.000000000000000000
        Max = 9999.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = WindowHEditChange
        Increment = 1.000000000000000000
        EditText = '-9999'
        TabOrder = 3
      end
    end
    object CameraPanel: TPanel
      Left = 12
      Top = 115
      Width = 182
      Height = 128
      TabOrder = 1
      object Label9: TLabel
        Left = 9
        Top = 24
        Width = 10
        Height = 13
        Caption = 'X:'
      end
      object Label12: TLabel
        Left = 1
        Top = 1
        Width = 180
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'Physical location'
        Color = 15123895
        ParentColor = False
        Transparent = False
        ExplicitWidth = 78
      end
      object Label5: TLabel
        Left = 9
        Top = 49
        Width = 10
        Height = 13
        Caption = 'Y:'
      end
      object Label6: TLabel
        Left = 9
        Top = 74
        Width = 10
        Height = 13
        Caption = 'Z:'
      end
      object Label7: TLabel
        Left = 89
        Top = 24
        Width = 17
        Height = 13
        Caption = 'Rx:'
      end
      object Label8: TLabel
        Left = 89
        Top = 49
        Width = 17
        Height = 13
        Caption = 'Ry:'
      end
      object Label10: TLabel
        Left = 89
        Top = 74
        Width = 16
        Height = 13
        Caption = 'Rz:'
      end
      object Label11: TLabel
        Left = 40
        Top = 102
        Width = 24
        Height = 13
        Caption = 'FOV:'
      end
      object CamXEdit: TAprSpinEdit
        Left = 24
        Top = 20
        Width = 60
        Height = 20
        Value = -99.900001525878910000
        Decimals = 2
        Min = -99.900001525878910000
        Max = 99.900001525878910000
        Alignment = taCenter
        Enabled = True
        OnChange = CamXEditChange
        Increment = 1.000000000000000000
        EditText = '-99.90'
        TabOrder = 0
      end
      object CamYEdit: TAprSpinEdit
        Left = 24
        Top = 46
        Width = 60
        Height = 20
        Value = -99.900001525878910000
        Decimals = 2
        Min = -99.900001525878910000
        Max = 99.900001525878910000
        Alignment = taCenter
        Enabled = True
        OnChange = CamYEditChange
        Increment = 1.000000000000000000
        EditText = '-99.90'
        TabOrder = 1
      end
      object CamZEdit: TAprSpinEdit
        Left = 24
        Top = 70
        Width = 60
        Height = 20
        Value = -99.900001525878910000
        Decimals = 2
        Min = -99.900001525878910000
        Max = 99.900001525878910000
        Alignment = taCenter
        Enabled = True
        OnChange = CamZEditChange
        Increment = 1.000000000000000000
        EditText = '-99.90'
        TabOrder = 2
      end
      object CamRxEdit: TAprSpinEdit
        Left = 108
        Top = 20
        Width = 65
        Height = 20
        Value = -360.000000000000000000
        Decimals = 2
        Min = -360.000000000000000000
        Max = 360.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = CamRxEditChange
        Increment = 1.000000000000000000
        EditText = '-360.00'
        TabOrder = 3
      end
      object CamRyEdit: TAprSpinEdit
        Left = 108
        Top = 46
        Width = 65
        Height = 20
        Value = -360.000000000000000000
        Decimals = 2
        Min = -360.000000000000000000
        Max = 360.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = CamRyEditChange
        Increment = 1.000000000000000000
        EditText = '-360.00'
        TabOrder = 4
      end
      object CamRzEdit: TAprSpinEdit
        Left = 108
        Top = 69
        Width = 65
        Height = 20
        Value = -360.000000000000000000
        Decimals = 2
        Min = -360.000000000000000000
        Max = 360.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = CamRzEditChange
        Increment = 1.000000000000000000
        EditText = '-360.00'
        TabOrder = 5
      end
      object CamFovEdit: TAprSpinEdit
        Left = 68
        Top = 98
        Width = 66
        Height = 20
        Value = 999.000000000000000000
        Decimals = 2
        Max = 999.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = CamFovEditChange
        Increment = 1.000000000000000000
        EditText = '999.00'
        TabOrder = 6
      end
    end
    object SpherePageControl: TPageControl
      Left = 206
      Top = 41
      Width = 129
      Height = 193
      ActivePage = SidePage
      TabOrder = 2
      object CapPage: TTabSheet
        Caption = 'Cap'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Label40: TLabel
          Left = 35
          Top = 12
          Width = 51
          Height = 13
          Caption = 'End angle:'
        end
        object Label41: TLabel
          Left = 34
          Top = 62
          Width = 44
          Height = 13
          Caption = 'S Offset:'
        end
        object Label42: TLabel
          Left = 34
          Top = 109
          Width = 36
          Height = 13
          Caption = 'Radius:'
        end
        object EndAngleEdit: TAprSpinEdit
          Left = 34
          Top = 31
          Width = 49
          Height = 20
          Value = 1.000000000000000000
          Max = 180.000000000000000000
          Alignment = taCenter
          Enabled = True
          OnChange = EndAngleEditChange
          Increment = 1.000000000000000000
          EditText = '1'
          TabOrder = 0
        end
        object SOffsetEdit: TAprSpinEdit
          Left = 33
          Top = 79
          Width = 49
          Height = 20
          Decimals = 2
          Min = -1.000000000000000000
          Max = 1.000000000000000000
          Alignment = taCenter
          Enabled = True
          OnChange = SOffsetEditChange
          Increment = 0.009999999776482582
          EditText = '0.00'
          TabOrder = 1
        end
        object CapRadiusEdit: TAprSpinEdit
          Left = 33
          Top = 126
          Width = 57
          Height = 20
          Value = 99.989997863769530000
          Decimals = 2
          Max = 99.989997863769530000
          Alignment = taCenter
          Enabled = True
          OnChange = CapRadiusEditChange
          Increment = 1.000000000000000000
          EditText = '99.99'
          TabOrder = 2
        end
      end
      object SidePage: TTabSheet
        Caption = 'Side'
        object Label13: TLabel
          Left = 21
          Top = 11
          Width = 34
          Height = 13
          Caption = 'Slice 1:'
        end
        object Label4: TLabel
          Left = 22
          Top = 37
          Width = 34
          Height = 13
          Caption = 'Slice 2:'
        end
        object Label30: TLabel
          Left = 17
          Top = 63
          Width = 39
          Height = 13
          Caption = 'Stack 1:'
        end
        object Label32: TLabel
          Left = 17
          Top = 90
          Width = 39
          Height = 13
          Caption = 'Stack 2:'
        end
        object Label2: TLabel
          Left = 6
          Top = 114
          Width = 50
          Height = 13
          Caption = 'Rz Offset:'
        end
        object Label3: TLabel
          Left = 20
          Top = 141
          Width = 36
          Height = 13
          Caption = 'Radius:'
        end
        object Slice1Edit: TAprSpinEdit
          Left = 58
          Top = 8
          Width = 57
          Height = 20
          Value = 1.000000000000000000
          Min = 1.000000000000000000
          Max = 64.000000000000000000
          Alignment = taCenter
          Enabled = True
          OnChange = Slice1EditChange
          Increment = 1.000000000000000000
          EditText = '1'
          TabOrder = 0
        end
        object Slice2Edit: TAprSpinEdit
          Left = 58
          Top = 34
          Width = 57
          Height = 20
          Value = 1.000000000000000000
          Min = 1.000000000000000000
          Max = 64.000000000000000000
          Alignment = taCenter
          Enabled = True
          OnChange = Slice2EditChange
          Increment = 1.000000000000000000
          EditText = '1'
          TabOrder = 1
        end
        object Stack1Edit: TAprSpinEdit
          Left = 58
          Top = 60
          Width = 57
          Height = 20
          Value = 1.000000000000000000
          Min = 1.000000000000000000
          Max = 64.000000000000000000
          Alignment = taCenter
          Enabled = True
          OnChange = Stack1EditChange
          Increment = 1.000000000000000000
          EditText = '1'
          TabOrder = 2
        end
        object Stack2Edit: TAprSpinEdit
          Left = 58
          Top = 86
          Width = 57
          Height = 20
          Value = 1.000000000000000000
          Min = 1.000000000000000000
          Max = 64.000000000000000000
          Alignment = taCenter
          Enabled = True
          OnChange = Stack2EditChange
          Increment = 1.000000000000000000
          EditText = '1'
          TabOrder = 3
        end
        object RzOffsetEdit: TAprSpinEdit
          Left = 58
          Top = 112
          Width = 57
          Height = 20
          Value = 1.000000000000000000
          Min = -360.000000000000000000
          Max = 360.000000000000000000
          Alignment = taCenter
          Enabled = True
          OnChange = RzOffsetEditChange
          Increment = 1.000000000000000000
          EditText = '1'
          TabOrder = 4
        end
        object SideRadiusEdit: TAprSpinEdit
          Left = 58
          Top = 138
          Width = 57
          Height = 20
          Value = 99.989997863769530000
          Decimals = 2
          Max = 99.989997863769530000
          Alignment = taCenter
          Enabled = True
          OnChange = SideRadiusEditChange
          Increment = 1.000000000000000000
          EditText = '99.99'
          TabOrder = 5
        end
      end
    end
    object Panel2: TPanel
      Left = 345
      Top = 106
      Width = 94
      Height = 128
      TabOrder = 3
      object Label43: TLabel
        Left = 1
        Top = 1
        Width = 92
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'Render'
        Color = 15123895
        ParentColor = False
        Transparent = False
        ExplicitWidth = 35
      end
      object RenderCubeMapCB: TAprCheckBox
        Left = 13
        Top = 20
        Width = 72
        Height = 17
        BiDiMode = bdLeftToRight
        Caption = 'Cube map'
        ParentBiDiMode = False
        TabOrder = 0
        TabStop = True
        OnClick = RenderCubeMapCBClick
      end
      object RenderImageCB: TAprCheckBox
        Left = 14
        Top = 44
        Width = 72
        Height = 17
        BiDiMode = bdLeftToRight
        Caption = 'Image'
        ParentBiDiMode = False
        TabOrder = 1
        TabStop = True
        OnClick = RenderImageCBClick
      end
      object RenderLayer2CB: TAprCheckBox
        Left = 13
        Top = 95
        Width = 72
        Height = 17
        BiDiMode = bdLeftToRight
        Caption = 'Layer #2'
        ParentBiDiMode = False
        TabOrder = 2
        TabStop = True
        OnClick = RenderLayer2CBClick
      end
      object RenderLayer1CB: TAprCheckBox
        Left = 13
        Top = 70
        Width = 72
        Height = 17
        BiDiMode = bdLeftToRight
        Caption = 'Layer #1'
        ParentBiDiMode = False
        TabOrder = 3
        TabStop = True
        OnClick = RenderLayer1CBClick
      end
    end
    object Panel3: TPanel
      Left = 345
      Top = 33
      Width = 94
      Height = 61
      TabOrder = 4
      object Label14: TLabel
        Left = 1
        Top = 1
        Width = 92
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'Placement'
        Color = 15123895
        ParentColor = False
        Transparent = False
        ExplicitWidth = 49
      end
      object SideRB: TRadioButton
        Left = 9
        Top = 19
        Width = 77
        Height = 17
        Caption = 'On the side'
        TabOrder = 0
      end
      object UnderRB: TRadioButton
        Left = 9
        Top = 37
        Width = 80
        Height = 17
        Caption = 'Underneath'
        TabOrder = 1
      end
    end
  end
  object CameraCB: TAprCheckBox
    Left = 471
    Top = 31
    Width = 80
    Height = 17
    Caption = 'Use camera'
    TabOrder = 2
    TabStop = True
    OnClick = CameraCBClick
  end
  object RunShowCB: TAprCheckBox
    Left = 471
    Top = 54
    Width = 80
    Height = 17
    Caption = 'Run show'
    TabOrder = 3
    TabStop = True
    OnClick = RunShowCBClick
  end
end
