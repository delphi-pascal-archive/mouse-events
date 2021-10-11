object FrmTest: TFrmTest
  Left = 255
  Top = 130
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Mouse Events'
  ClientHeight = 546
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 272
    Top = 16
    Width = 211
    Height = 16
    Caption = 'Double-click on form to open dialog'
  end
  object BtnExecOpenDialog: TButton
    Left = 8
    Top = 8
    Width = 201
    Height = 25
    Caption = 'Execute OpenDialog'
    TabOrder = 0
    OnClick = BtnExecOpenDialogClick
  end
  object ListBox1: TListBox
    Left = 8
    Top = 40
    Width = 473
    Height = 498
    ItemHeight = 16
    TabOrder = 1
  end
  object OpenDialog1: TOpenDialog
    Left = 24
    Top = 48
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 56
    Top = 48
  end
end
