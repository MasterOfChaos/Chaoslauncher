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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 193
    Height = 81
    Caption = 'Client'
    TabOrder = 0
    object RemotePort: TEdit
      Left = 143
      Top = 21
      Width = 42
      Height = 21
      TabOrder = 0
      Text = '8762'
    end
    object RemoteHost: TEdit
      Left = 16
      Top = 21
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'RemoteHost'
    end
    object EnableClient: TCheckBox
      Left = 16
      Top = 48
      Width = 97
      Height = 17
      Caption = 'EnableClient'
      TabOrder = 2
    end
  end
  object GroupBox2: TGroupBox
    Left = 207
    Top = 8
    Width = 193
    Height = 81
    Caption = 'Server'
    TabOrder = 1
    object LocalPort: TEdit
      Left = 144
      Top = 21
      Width = 41
      Height = 21
      TabOrder = 0
      Text = '8762'
    end
    object EnableServer: TCheckBox
      Left = 16
      Top = 48
      Width = 97
      Height = 17
      Caption = 'Enable Server'
      TabOrder = 1
      OnClick = EnableServerClick
    end
  end
  object Log: TMemo
    Left = 8
    Top = 95
    Width = 392
    Height = 106
    Lines.Strings = (
      'Log')
    ReadOnly = True
    TabOrder = 2
  end
end
