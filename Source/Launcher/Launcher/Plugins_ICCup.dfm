object ICCupConfigForm: TICCupConfigForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'ICCup Settings'
  ClientHeight = 103
  ClientWidth = 202
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LanLatency: TCheckBox
    Left = 8
    Top = 8
    Width = 97
    Height = 17
    Caption = 'LAN Latency'
    TabOrder = 0
  end
  object OK: TButton
    Left = 8
    Top = 63
    Width = 89
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = OKClick
  end
  object Cancel: TButton
    Left = 104
    Top = 63
    Width = 90
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    TabOrder = 2
    OnClick = CancelClick
  end
  object GatewayRegister: TButton
    Left = 8
    Top = 32
    Width = 186
    Height = 25
    Caption = 'GatewayRegister'
    TabOrder = 3
    OnClick = GatewayRegisterClick
  end
end
