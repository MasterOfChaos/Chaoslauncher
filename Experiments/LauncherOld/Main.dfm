object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 215
  ClientWidth = 226
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    226
    215)
  PixelsPerInch = 96
  TextHeight = 13
  object CheckListBox1: TCheckListBox
    Left = 8
    Top = 32
    Width = 209
    Height = 145
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
  end
  object Start: TButton
    Left = 8
    Top = 183
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Start'
    Default = True
    TabOrder = 1
  end
  object Configure: TButton
    Left = 103
    Top = 183
    Width = 90
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Configure'
    TabOrder = 2
  end
end
