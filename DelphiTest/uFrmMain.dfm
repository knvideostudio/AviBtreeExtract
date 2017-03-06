object frmMain: TfrmMain
  Left = 460
  Top = 127
  Width = 352
  Height = 637
  Caption = 'Extraction Tester'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    344
    610)
  PixelsPerInch = 96
  TextHeight = 13
  object sbStatus: TStatusBar
    Left = 0
    Top = 591
    Width = 344
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object pgCtrlPages: TPageControl
    Left = 3
    Top = 3
    Width = 338
    Height = 577
    ActivePage = tsMain
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object tsMain: TTabSheet
      Caption = 'Main'
      object gbxRecordsToPull: TGroupBox
        Left = 200
        Top = 122
        Width = 111
        Height = 209
        Caption = 'Records To Pull'
        TabOrder = 2
        object cbxPets: TCheckBox
          Left = 9
          Top = 46
          Width = 94
          Height = 17
          Caption = 'Pets'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object cbxClient: TCheckBox
          Left = 9
          Top = 18
          Width = 94
          Height = 17
          Caption = 'Clients'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object cbxInvoices: TCheckBox
          Left = 9
          Top = 73
          Width = 94
          Height = 17
          Caption = 'Invoices'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object cbxServiceCodes: TCheckBox
          Left = 9
          Top = 100
          Width = 94
          Height = 17
          Caption = 'Service Codes'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object cbxReminders: TCheckBox
          Left = 9
          Top = 128
          Width = 94
          Height = 17
          Caption = 'Reminders'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object cbxStaff: TCheckBox
          Left = 9
          Top = 156
          Width = 94
          Height = 17
          Caption = 'Staff'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object rbAll: TRadioButton
          Left = 6
          Top = 188
          Width = 37
          Height = 17
          Caption = 'All'
          Checked = True
          TabOrder = 6
          TabStop = True
          OnClick = rbAllClick
        end
        object rbNone: TRadioButton
          Left = 58
          Top = 188
          Width = 50
          Height = 17
          Caption = 'None'
          TabOrder = 7
          OnClick = rbNoneClick
        end
      end
      object cbxChipped: TCheckBox
        Left = 12
        Top = 314
        Width = 115
        Height = 17
        Caption = 'Chipped Pets Only'
        TabOrder = 3
      end
      object gbxEncryption: TGroupBox
        Left = 10
        Top = 338
        Width = 183
        Height = 129
        Caption = 'Encryption'
        TabOrder = 4
        object lblPassword: TLabel
          Left = 16
          Top = 76
          Width = 46
          Height = 13
          Caption = 'Password'
        end
        object lblEncryptionMethod: TLabel
          Left = 16
          Top = 24
          Width = 89
          Height = 13
          Caption = 'Encryption Method'
        end
        object edPassword: TEdit
          Left = 16
          Top = 92
          Width = 143
          Height = 21
          TabOrder = 0
        end
        object cbxEncryption: TComboBox
          Left = 16
          Top = 40
          Width = 145
          Height = 21
          ItemHeight = 13
          TabOrder = 1
          Text = 'None'
          Items.Strings = (
            'None'
            'PkZip20'
            'WinZipAes128 '
            'WinZipAes192 '
            'WinZipAes256 ')
        end
      end
      object gbxDataPath: TGroupBox
        Left = 10
        Top = 122
        Width = 183
        Height = 185
        Caption = 'Data Path'
        TabOrder = 1
        object dlbDataPath: TDirectoryListBox
          Left = 8
          Top = 40
          Width = 166
          Height = 137
          ItemHeight = 16
          TabOrder = 0
        end
        object dcbxDataDrive: TDriveComboBox
          Left = 8
          Top = 16
          Width = 166
          Height = 19
          DirList = dlbDataPath
          TabOrder = 1
        end
      end
      object gbxExtract: TGroupBox
        Left = 200
        Top = 338
        Width = 113
        Height = 159
        Caption = 'Extract'
        TabOrder = 6
        object btnNormal2: TButton
          Left = 20
          Top = 53
          Width = 73
          Height = 25
          Caption = 'Normal2'
          TabOrder = 0
          OnClick = btnNormal2Click
        end
        object btnCustom2: TButton
          Left = 20
          Top = 19
          Width = 73
          Height = 25
          Caption = 'Custom2'
          TabOrder = 1
          OnClick = btnCustom2Click
        end
        object btnCustom3: TButton
          Left = 20
          Top = 88
          Width = 73
          Height = 25
          Caption = 'Custom3'
          TabOrder = 2
          OnClick = btnCustom3Click
        end
        object btnNormal3: TButton
          Left = 20
          Top = 123
          Width = 73
          Height = 25
          Caption = 'Normal3'
          TabOrder = 3
          OnClick = btnNormal3Click
        end
      end
      object gbxDateRanges: TGroupBox
        Left = 10
        Top = 8
        Width = 301
        Height = 107
        Caption = 'Date Ranges'
        TabOrder = 0
        object lblStartDt: TLabel
          Left = 29
          Top = 16
          Width = 48
          Height = 13
          Caption = 'Start Date'
        end
        object lblEndDt: TLabel
          Left = 166
          Top = 16
          Width = 45
          Height = 13
          Caption = 'End Date'
        end
        object lblRemStartDt: TLabel
          Left = 29
          Top = 58
          Width = 96
          Height = 13
          Caption = 'Reminder Start Date'
        end
        object lblRemEndDt: TLabel
          Left = 166
          Top = 58
          Width = 93
          Height = 13
          Caption = 'Reminder End Date'
        end
        object dtpStartDate: TDateTimePicker
          Left = 29
          Top = 32
          Width = 105
          Height = 21
          Date = 36161.855594259260000000
          Time = 36161.855594259260000000
          TabOrder = 0
        end
        object dtpEndDate: TDateTimePicker
          Left = 166
          Top = 32
          Width = 105
          Height = 21
          Date = 39447.855710162040000000
          Time = 39447.855710162040000000
          TabOrder = 1
        end
        object dtpRemStartDate: TDateTimePicker
          Left = 29
          Top = 74
          Width = 105
          Height = 21
          Date = 36161.855594259260000000
          Time = 36161.855594259260000000
          TabOrder = 2
        end
        object dtpRemEndDate: TDateTimePicker
          Left = 166
          Top = 74
          Width = 105
          Height = 21
          Date = 39447.855710162040000000
          Time = 39447.855710162040000000
          TabOrder = 3
        end
      end
      object gbLogs: TGroupBox
        Left = 8
        Top = 472
        Width = 185
        Height = 60
        Caption = 'Logs'
        TabOrder = 5
        object cbParams: TCheckBox
          Left = 17
          Top = 22
          Width = 75
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Parameters'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object cbTimes: TCheckBox
          Left = 108
          Top = 22
          Width = 60
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Times'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
      end
    end
    object tsSvcCodes: TTabSheet
      Caption = 'Service Codes'
      ImageIndex = 1
      object Panel1: TPanel
        Left = 0
        Top = 41
        Width = 328
        Height = 476
        Align = alClient
        TabOrder = 0
        object lbSvcCodes: TListBox
          Left = 1
          Top = 1
          Width = 326
          Height = 474
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ItemHeight = 14
          ParentFont = False
          TabOrder = 0
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 330
        Height = 41
        Align = alTop
        TabOrder = 1
        object btnSvcCodes: TButton
          Left = 7
          Top = 8
          Width = 150
          Height = 25
          Caption = 'Extract Service Codes'
          TabOrder = 0
          OnClick = btnSvcCodesClick
        end
        object btnSvcCodes2: TButton
          Left = 166
          Top = 8
          Width = 150
          Height = 25
          Caption = 'Extract Service Codes 2'
          TabOrder = 1
          OnClick = btnSvcCodes2Click
        end
      end
    end
  end
end
