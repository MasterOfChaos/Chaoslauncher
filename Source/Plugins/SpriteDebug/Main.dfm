object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 216
  ClientWidth = 426
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LblSel: TLabel
    Left = 24
    Top = 32
    Width = 27
    Height = 13
    Caption = 'LblSel'
  end
  object LblSprite: TLabel
    Left = 24
    Top = 56
    Width = 41
    Height = 13
    Caption = 'LblSprite'
  end
  object LblMem: TLabel
    Left = 88
    Top = 88
    Width = 35
    Height = 13
    Caption = 'LblMem'
  end
  object LblPos: TLabel
    Left = 180
    Top = 56
    Width = 30
    Height = 13
    Caption = 'LblPos'
  end
  object LblOffset: TLabel
    Left = 32
    Top = 88
    Width = 44
    Height = 13
    Caption = 'LblOffset'
  end
  object LblMemD: TLabel
    Left = 168
    Top = 88
    Width = 42
    Height = 13
    Caption = 'LblMemD'
  end
  object Button1: TButton
    Left = 336
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 216
    Top = 12
    Width = 185
    Height = 133
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 80
    Top = 48
  end
end
