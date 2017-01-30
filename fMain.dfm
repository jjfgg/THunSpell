object FormMain: TFormMain
  Left = 0
  Top = 0
  ActiveControl = eWord
  Caption = 'HunSpell Test'
  ClientHeight = 311
  ClientWidth = 503
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Shell Dlg 2'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 69
    Width = 497
    Height = 13
    Align = alTop
    Caption = 'Suggestions:'
    ExplicitWidth = 62
  end
  object Bevel1: TBevel
    Left = 0
    Top = 0
    Width = 503
    Height = 66
    Align = alTop
  end
  object Label2: TLabel
    Left = 8
    Top = 11
    Width = 95
    Height = 13
    Caption = 'Selected dictionary:'
  end
  object Label3: TLabel
    Left = 30
    Top = 38
    Width = 73
    Height = 13
    Caption = 'Word to check:'
  end
  object eWord: TEdit
    Left = 122
    Top = 35
    Width = 105
    Height = 21
    TabOrder = 0
  end
  object bCheck: TButton
    Left = 233
    Top = 33
    Width = 96
    Height = 25
    Caption = 'check && suggest'
    Default = True
    TabOrder = 1
    OnClick = bCheckClick
  end
  object mSuggestions: TMemo
    Left = 0
    Top = 85
    Width = 318
    Height = 207
    Align = alClient
    TabOrder = 2
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 292
    Width = 503
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object bCheckAuto: TButton
    Tag = 1
    Left = 335
    Top = 33
    Width = 122
    Height = 25
    Caption = 'check && suggest auto'
    TabOrder = 4
    OnClick = bCheckClick
  end
  object mTest: TMemo
    Left = 318
    Top = 85
    Width = 185
    Height = 207
    Align = alRight
    TabOrder = 5
  end
  object cbDiccionarios: TComboBox
    Left = 122
    Top = 8
    Width = 105
    Height = 21
    Style = csDropDownList
    TabOrder = 6
    OnChange = cbDiccionariosChange
  end
end
