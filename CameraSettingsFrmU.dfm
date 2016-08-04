object CameraSettingsFrm: TCameraSettingsFrm
  Left = 629
  Top = 1211
  VertScrollBar.Visible = False
  BorderStyle = bsDialog
  Caption = 'Lighting and Camera'
  ClientHeight = 511
  ClientWidth = 963
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object CamPB: TPaintBox
    Left = 2
    Top = 5
    Width = 640
    Height = 480
    OnPaint = CamPBPaint
  end
  object ExposureEdit: TNBFillEdit
    Tag = 2
    Left = 656
    Top = 286
    Width = 298
    Height = 21
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 16227430
    FillWidth = 220
    ArrowWidth = 15
    Title = 'Exposure'
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
    TabOrder = 1
  end
  object GainEdit: TNBFillEdit
    Tag = 2
    Left = 655
    Top = 318
    Width = 298
    Height = 21
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 16227430
    FillWidth = 220
    ArrowWidth = 15
    Title = 'Gain'
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
    TabOrder = 2
  end
  object Memo: TMemo
    Left = 649
    Top = 23
    Width = 309
    Height = 232
    Color = clInfoBk
    Lines.Strings = (
      'Use exposure and gain to get a good bright video picture from '
      'the camera.'
      ''
      
        'First increase the lighting in the room so that the person stand' +
        'ing '
      'in front of the shadow box is well illuminated.'
      ''
      'If the room does not have nice even illumination throughout you '
      'may want to add a fluorescent or dim floodlight, - on the same '
      'wall as the piece - , that illuminates the viewer. Try to avoid '
      'illuminating the piece itself directly; instead concentrate on '
      'illuminating the viewer'#8217's face and body.'
      ''
      'Once the final lighting is in place then increase exposure (as '
      
        'long as the value on the bottom left of the live video display s' +
        'till '
      
        'reads 14.9) and if the video is still not bright enough then sta' +
        'rt '
      
        'increasing gain (i.e. try to keep gain as low as possible while ' +
        'still '
      'getting a bright camera image).')
    ReadOnly = True
    TabOrder = 0
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 492
    Width = 963
    Height = 19
    Panels = <
      item
        Text = 'Camera not found'
        Width = 240
      end
      item
        Text = '9999 verbs loaded'
        Width = 50
      end>
    SimplePanel = True
  end
  object DoneBtn: TButton
    Left = 876
    Top = 451
    Width = 75
    Height = 31
    Caption = 'Done'
    TabOrder = 4
    OnClick = DoneBtnClick
  end
end
