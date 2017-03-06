{$WARN UNIT_PLATFORM OFF}

////{$define LOG_IT}

unit uFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, FileCtrl, IniFiles, uRecStruct, uDefs;

type
  TfrmMain = class(TForm)
    sbStatus: TStatusBar;
    pgCtrlPages: TPageControl;
    tsMain: TTabSheet;
    gbxRecordsToPull: TGroupBox;
    cbxPets: TCheckBox;
    cbxClient: TCheckBox;
    cbxInvoices: TCheckBox;
    cbxServiceCodes: TCheckBox;
    cbxReminders: TCheckBox;
    cbxStaff: TCheckBox;
    rbAll: TRadioButton;
    rbNone: TRadioButton;
    cbxChipped: TCheckBox;
    gbxEncryption: TGroupBox;
    lblPassword: TLabel;
    lblEncryptionMethod: TLabel;
    edPassword: TEdit;
    cbxEncryption: TComboBox;
    gbxDataPath: TGroupBox;
    dlbDataPath: TDirectoryListBox;
    dcbxDataDrive: TDriveComboBox;
    gbxExtract: TGroupBox;
    btnNormal2: TButton;
    btnCustom2: TButton;
    tsSvcCodes: TTabSheet;
    gbxDateRanges: TGroupBox;
    lblStartDt: TLabel;
    lblEndDt: TLabel;
    lblRemStartDt: TLabel;
    lblRemEndDt: TLabel;
    dtpStartDate: TDateTimePicker;
    dtpEndDate: TDateTimePicker;
    dtpRemStartDate: TDateTimePicker;
    dtpRemEndDate: TDateTimePicker;
    Panel1: TPanel;
    lbSvcCodes: TListBox;
    Panel2: TPanel;
    btnSvcCodes: TButton;
    btnSvcCodes2: TButton;
    btnCustom3: TButton;
    btnNormal3: TButton;
    gbLogs: TGroupBox;
    cbParams: TCheckBox;
    cbTimes: TCheckBox;

    procedure btnNormal2Click(Sender: TObject);
    procedure btnCustom2Click(Sender: TObject);
    procedure btnSvcCodesClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure rbAllClick(Sender: TObject);
    procedure rbNoneClick(Sender: TObject);
    procedure ToggleChecks(Sender: TObject);

    procedure LoadSettings;
    procedure SaveSettings;
    procedure btnSvcCodes2Click(Sender: TObject);
    procedure btnCustom3Click(Sender: TObject);
    procedure btnNormal3Click(Sender: TObject);
  private
    { Private declarations }
    FExePath : String;
    procedure ShowStatus(const s : String);
    procedure Normal;
    procedure Custom;
    procedure ServiceCodes;
    procedure ServiceCodes2;
    procedure GetParams(var DataPath, AppPath, StartDate, EndDate, RemStDt, RemEndDt, Options : string);
    procedure GetRecParams(var rec : TExtractRec);
    function CopyDBFiles(const sDataPath : String) : Boolean;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  iServRecCount : Integer;

implementation

//uses
  //ServiceCodes;

{$R *.dfm}

{$ifdef LOG_IT}
procedure LogStr(const s : String);
Var
  sFile : String;
  F : TextFile;
Begin
  sFile := (IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'TestLog.Txt');
  AssignFile(F, sFile);
  if FileExists(sFile) then
    Append(F)
  else
    Rewrite(F);
  Try
    WriteLn(F, s);
  Finally
    CloseFile(F);
  End;
End;
{$endif}

function NormalPull(sAVIPath : AnsiString;
                    sAppPath : AnsiString;
                 sPracticeID : AnsiString;
                 dtStartDate : AnsiString;
                   dtEndDate : AnsiString;
         dtReminderStartDate : AnsiString;
           dtReminderEndDate : AnsiString;
                   lPassword : longint;
                   sOptions  : AnsiString): AnsiString; stdcall;
                    external 'VetMetAviHA.dll';

function CustomPull(sAVIPath : AnsiString;
                    sAppPath : AnsiString;
                 sPracticeID : AnsiString;
                 dtStartDate : AnsiString;
                   dtEndDate : AnsiString;
         dtReminderStartDate : AnsiString;
           dtReminderEndDate : AnsiString;
                     sTables : AnsiString;
                   lPassword : longint;
                    sOptions : AnsiString): AnsiString; stdcall;
                    external 'VetMetAviHA.dll';

Function NormalPull2(AVIPath : PChar;
                     AppPath : PChar;
                  PracticeID : PChar;
                   StartDate : PChar;
                     EndDate : PChar;
           ReminderStartDate : PChar;
             ReminderEndDate : PChar;
                    Password : longint;
                     Options : PChar) : WordBool; stdcall;
                    external 'VetMetAviHA.dll';

Function CustomPull2(AVIPath : PChar;
                     AppPath : PChar;
                  PracticeID : PChar;
                   StartDate : PChar;
                     EndDate : PChar;
           ReminderStartDate : PChar;
             ReminderEndDate : PChar;
                      Tables : PChar;
                    Password : Longint;
                     Options : PChar) : WordBool; stdcall;
                    external 'VetMetAviHA.dll';

Function NormalPull3(rec : TExtractRec) : WordBool ; stdcall;
                    external 'VetMetAviHA.dll';

Function CustomPull3(rec : TExtractRec) : WordBool ; stdcall;
                    external 'VetMetAviHA.dll';

function GetLastErrorMessage(buf : PChar; buflen : longint) : longint; stdcall;
                    external 'VetMetAviHA.dll';

Function EnumServiceCodes(EnumFunc : ServiceCodeEnumFunc;
                           AVIPath : PChar;
                          Password : longint;
                          UserData : longint) : WordBool; stdcall;
                          external 'VetMetAviHA.dll';

Function EnumServiceCodes2(EnumFunc : ServiceCodeEnumFunc2;
                           rec : TServiceCodeRec) : WordBool; stdcall;
                           external 'VetMetAviHA.dll';

Const
  //AVI_PATH = 'C:\Code\VetMet\Data\Post';
  AVI_PATH = 'C:\VetMet\Avimark_v176';
//  AVI_PATH = 'C:\VetMet\Avimark_v165';

  PRACTICE_ID    = '999';
  START_DATE     = '1/1/1999';
  END_DATE       = '12/31/2007';
  REM_START_DATE = '1/1/1999';
  REM_END_DATE   = '12/31/2007';
  DEFAUL_PASSWORD = 1111;


function PadL(sInStr, sPadStr : string; iWidth : integer) : string;
var x, iPadWidth : Integer;
begin
  iPadWidth := Abs(iWidth - Length(sInStr));
  if Length(sInStr) < iWidth then
    for x := 1 to iPadWidth do
      sInStr := sPadStr + sInStr;

  result := sInStr;
end;

function EnumFunc( lpStructServiceRec : PServiceCode;
                   dwCurrent     : longint;
                   dwRecordCount : integer;
                   dwUserData    : longint): wordbool; stdcall;
var pnlStatus : TStatusPanel;
    sServRecCount : string;
begin
  pnlStatus := TStatusPanel(dwUserData);

  Inc(iServRecCount);
  sServRecCount := PadL(IntToStr(iServRecCount), ' ', 4);
  frmMain.lbSvcCodes.Items.Add(sServRecCount + ' - ' +
      PadL(IntToStr(dwCurrent), ' ', 4) + ' : ' +
      lpStructServiceRec.SERVICECODE_DESCRIPTION + ' - ' +
      Chr(lpStructServiceRec.SERVICECODE_RECD));

  {$ifdef LOG_IT}
  LogStr(sServRecCount + ' - ' +
        PadL(IntToStr(dwCurrent), ' ', 4) + ' : ' +
        lpStructServiceRec.SERVICECODE_DESCRIPTION + ' - ' +
        Chr(lpStructServiceRec.SERVICECODE_RECD));
  {$endif}

  pnlStatus.Text := 'Total: ' + IntToStr(iServRecCount) + ' service records found.';
  result := true;
end;

function EnumFunc2( lpStructServiceRec : PServiceCode2;
                   dwCurrent     : longint;
                   dwRecordCount : integer;
                   dwUserData    : longint): wordbool; stdcall;
var
  pnlStatus : TStatusPanel;
  sServRecCount : string;
begin
  pnlStatus := TStatusPanel(dwUserData);

  Inc(iServRecCount);
  sServRecCount := PadL(IntToStr(iServRecCount), ' ', 4);
  frmMain.lbSvcCodes.Items.Add(sServRecCount + ' - ' +
                              PadL(IntToStr(dwCurrent), ' ', 4) + ' : ' +
                              lpStructServiceRec.SERVICECODE_DATA);

  {$ifdef LOG_IT}
  LogStr(sServRecCount + ' - ' +
          PadL(IntToStr(dwCurrent), ' ', 4) + ' : ' +
          lpStructServiceRec.SERVICECODE_DATA);
  {$endif}

  pnlStatus.Text := 'Total: ' + IntToStr(iServRecCount) + ' service records found.';
  result := true;
end;


procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FExePath := ExtractFileDir(ParamStr(0));

  LoadSettings;

  pgCtrlPages.ActivePage := tsMain;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings;
end;

procedure TfrmMain.ShowStatus(const s : String);
Begin
  sbStatus.Panels[0].Text := s;
  Application.ProcessMessages;
End;

procedure TfrmMain.LoadSettings;
var Settings : TiniFile;
    sPath : string;
begin
  Settings := TIniFile.Create('ExtractTest.ini');

  sPath := Settings.ReadString('SETTINGS', 'PATH', AVI_PATH);
  dcbxDataDrive.Drive   := Copy(sPath, 1, 1)[1];
  dlbDataPath.Directory := sPath;

  dtpStartDate.Date    := Settings.ReadDateTime('SETTINGS','START', StrToDate(START_DATE));
  dtpEndDate.Date      := Settings.ReadDateTime('SETTINGS','END', StrToDate(END_DATE));
  dtpRemStartDate.Date := Settings.ReadDateTime('SETTINGS','REMSTART', StrToDate(REM_START_DATE));
  dtpRemEndDate.Date   := Settings.ReadDateTime('SETTINGS','REMEND', StrToDate(REM_END_DATE));

  cbxClient.Checked       := Settings.ReadBool('SETTINGS','IncludeClient',True);
  cbxInvoices.Checked     := Settings.ReadBool('SETTINGS','IncludeInvoices',True);
  cbxPets.Checked         := Settings.ReadBool('SETTINGS','IncludePets',True);
  cbxReminders.Checked    := Settings.ReadBool('SETTINGS','IncludeReminders',True);
  cbxServiceCodes.Checked := Settings.ReadBool('SETTINGS','IncludeSvcCodes',True);
  cbxStaff.Checked        := Settings.ReadBool('SETTINGS','IncludeStaff',True);

  Settings.Free;
end;

procedure TfrmMain.SaveSettings;
var Settings : TiniFile;
begin
  Settings := TIniFile.Create('ExtractTest.ini');

  Settings.WriteString('SETTINGS', 'PATH', dlbDataPath.Directory);

  Settings.WriteDateTime('SETTINGS','START', dtpStartDate.Date);
  Settings.WriteDateTime('SETTINGS','END', dtpEndDate.Date);
  Settings.WriteDateTime('SETTINGS','REMSTART', dtpRemStartDate.Date);
  Settings.WriteDateTime('SETTINGS','REMEND', dtpRemEndDate.Date);

  Settings.WriteBool('SETTINGS','IncludeClient',cbxClient.Checked);
  Settings.WriteBool('SETTINGS','IncludeInvoices',cbxInvoices.Checked);
  Settings.WriteBool('SETTINGS','IncludePets',cbxPets.Checked);
  Settings.WriteBool('SETTINGS','IncludeReminders',cbxReminders.Checked);
  Settings.WriteBool('SETTINGS','IncludeSvcCodes',cbxServiceCodes.Checked);
  Settings.WriteBool('SETTINGS','IncludeStaff',cbxStaff.Checked);

  Settings.Free;
end;

procedure TfrmMain.btnNormal2Click(Sender: TObject);
begin
  Normal;
end;

procedure TfrmMain.btnCustom2Click(Sender: TObject);
begin
  Custom;
end;

procedure TfrmMain.btnSvcCodesClick(Sender: TObject);
begin
   ServiceCodes;
end;

procedure TfrmMain.btnSvcCodes2Click(Sender: TObject);
begin
  ServiceCodes2;
end;

procedure TfrmMain.Normal;
var //temp,
    DataPath,
    AppPath,
    StartDate,
    EndDate,
    RemStDt,
    RemEndDt,
    Options : string;
    bResult : WordBool;
    tStart : TTime;
begin
  ShowStatus('Normal Pull Started');

  GetParams(DataPath, AppPath, StartDate, EndDate, RemStDt, RemEndDt, Options);

  ShowStatus('Normal Pull Running...');

  tStart := Now;

  bResult := CopyDBFiles(DataPath) and
              NormalPull2( PChar(DataPath),
                          PChar(AppPath),
                          PChar(PRACTICE_ID),
                          PChar(StartDate),
                          PChar(EndDate),
                          PChar(RemStDt),
                          PChar(RemEndDt),
                          DEFAUL_PASSWORD,
                          PChar(options));

  if bResult then
    ShowStatus('Normal Pull Complete - ' +
      FormatDateTime('"Time Elapsed: " hh:mm:ss:zzz', Now - tStart))
  else
    ShowStatus('Normal Pull Ended - Possible Error');
end;

procedure TfrmMain.Custom;
var //temp,
    DataPath,
    AppPath,
    StartDate,
    EndDate,
    RemStDt,
    RemEndDt,
    Tables,
    Options : string;
    bResult : WordBool;
    tStart : TTime;

  procedure AddTable(cbx : TCheckbox; name : string);
  begin
    if cbx.Checked then
    begin
      if tables <> '' then
        tables := tables + ',';
      tables := tables + name;
    end;
  end;

begin
  ShowStatus('Custom Pull Started');

  Tables := '';

  AddTable(cbxPets, 'Pets');
  AddTable(cbxClient, 'Client');
  AddTable(cbxInvoices, 'Invoices');
  AddTable(cbxReminders, 'Reminders');
  AddTable(cbxServiceCodes, 'ServiceCodes');
  AddTable(cbxStaff, 'Staff');

  if Tables = '' then
  begin
     MessageDlg('You must select at least one type'+#13+#10+
                'of record to pull for this test.', mtError, [mbOK], 0);
     Exit;
  end;

  GetParams(DataPath, AppPath, StartDate, EndDate, RemStDt, RemEndDt, Options);

  ShowStatus('Custom Pull Running...');
  Application.ProcessMessages;

  tStart := Now;

  bResult := CopyDBFiles(DataPath) and
            CustomPull2( PChar(DataPath),
                          PChar(AppPath),
                          PChar(PRACTICE_ID),
                          PChar(StartDate),
                          PChar(EndDate),
                          PChar(RemStDt),
                          PChar(RemEndDt),
                          PChar(Tables),
                          DEFAUL_PASSWORD,
                          PChar(options));

  if bResult then
    ShowStatus('Custom Pull Complete - ' +
      FormatDateTime('"Time Elapsed: " hh:mm:ss:zzz', Now - tStart))
  else
    ShowStatus('Custom Pull Ended - Possible Error');
end;

procedure TfrmMain.btnCustom3Click(Sender: TObject);
var
  bResult : WordBool;
  rec : TExtractRec;
  tStart : TTime;
  sTables : String;

  procedure AddTable(cbx : TCheckbox; name : string);
  begin
    if cbx.Checked then
    begin
      if sTables <> '' then
        sTables := sTables + ',';
      sTables := sTables + name;
    end;
  end;
begin
  ShowStatus('Custom Pull Started');

  GetRecParams(rec);

  sTables := '';

  AddTable(cbxPets, 'Pets');
  AddTable(cbxClient, 'Client');
  AddTable(cbxInvoices, 'Invoices');
  AddTable(cbxReminders, 'Reminders');
  AddTable(cbxServiceCodes, 'ServiceCodes');
  AddTable(cbxStaff, 'Staff');

  if sTables = '' then
  begin
     MessageDlg('You must select at least one type'+#13+#10+
                'of record to pull for this test.', mtError, [mbOK], 0);
     Exit;
  end;
  StrPCopy(rec.Tables, sTables);

  tStart := Now;

  bResult := CopyDBFiles(rec.AviPath) and
              CustomPull3(rec);

  if bResult then
    ShowStatus('Custom Pull Complete - ' +
      FormatDateTime('"Time Elapsed: " hh:mm:ss:zzz', Now - tStart))
  else
    ShowStatus('Custom Pull Ended - Possible Error');
end;

procedure TfrmMain.btnNormal3Click(Sender: TObject);
var
  bResult : WordBool;
  rec : TExtractRec;
  tStart : TTime;
begin
  ShowStatus('Normal Pull Started');
  
  GetRecParams(rec);
  StrPCopy(rec.Tables, '');  // Not used in normal pull

  tStart := Now;

  bResult := CopyDBFiles(rec.AviPath) and
              NormalPull3(rec);

  if bResult then
    ShowStatus('Normal Pull Complete - ' +
      FormatDateTime('"Time Elapsed: " hh:mm:ss:zzz', Now - tStart))
  else
    ShowStatus('Normal Pull Ended - Possible Error');
end;

Procedure TfrmMain.ServiceCodes;
var
  panel : TStatusPanel;
  sPath : String;
begin
  sPath := dlbDataPath.Directory;
  lbSvcCodes.Items.Clear;

  panel := sbStatus.Panels[0];

  {$ifdef LOG_IT}
  LogStr('************************************************************');
  LogStr('Call to ServiceCodes');
  LogStr('');
  {$endif}

  EnumServiceCodes(EnumFunc, PAnsiChar(sPath), DEFAUL_PASSWORD, longint(panel));
end;

Procedure TfrmMain.ServiceCodes2;
var
  panel : TStatusPanel;
  sPath : String;
  rec : TServiceCodeRec;
begin
  sPath := dlbDataPath.Directory;
  lbSvcCodes.Items.Clear;

  panel := sbStatus.Panels[0];
  {$ifdef LOG_IT}
  LogStr('************************************************************');
  LogStr('Call to ServiceCodes2');
  LogStr('');
  {$endif}

  StrPCopy(rec.AviPath, dlbDataPath.Directory);
  rec.Password := DEFAUL_PASSWORD;
  rec.UserData := longint(panel);

  EnumServiceCodes2(EnumFunc2, rec);
end;

procedure TfrmMain.GetParams(var DataPath, AppPath, StartDate, EndDate, RemStDt, RemEndDt, Options : string);
var ZipPwd : string;
begin
  DataPath := dlbDataPath.Directory;
  AppPath  := FExePath; /// ExtractFilePath(Application.ExeName);

  StartDate := FormatDateTime('mm/dd/yyyy', dtpStartDate.Date);
  EndDate   := FormatDateTime('mm/dd/yyyy', dtpEndDate.Date);
  RemStDt   := FormatDateTime('mm/dd/yyyy', dtpRemStartDate.Date);
  RemEndDt  := FormatDateTime('mm/dd/yyyy', dtpRemEndDate.Date);

  Options := 'encryption=' + Trim(cbxEncryption.Items[cbxEncryption.ItemIndex]);

  ZipPwd  := Trim(edPassword.Text);
  if (ZipPwd <> '') then
    Options := Options + ';password=' + ZipPwd;

  if cbxChipped.Checked then
    Options := Options + ';chipped=1';
end;

procedure TfrmMain.GetRecParams(var rec : TExtractRec);
var
  sOptions : String;
  sZipPwd : String;
Begin
  StrPCopy(rec.AVIPath, dlbDataPath.Directory);
  StrPCopy(rec.AppPath, FExePath);
  StrPCopy(rec.PracticeID, PRACTICE_ID);
  StrPCopy(rec.StartDate, FormatDateTime('mm/dd/yyyy', dtpStartDate.Date));
  StrPCopy(rec.EndDate, FormatDateTime('mm/dd/yyyy', dtpEndDate.Date));
  StrPCopy(rec.ReminderStartDate, FormatDateTime('mm/dd/yyyy', dtpRemStartDate.Date));
  StrPCopy(rec.ReminderEndDate, FormatDateTime('mm/dd/yyyy', dtpRemEndDate.Date));
  rec.Password := DEFAUL_PASSWORD;
  sOptions := 'encryption=' + Trim(cbxEncryption.Items[cbxEncryption.ItemIndex]);

  sZipPwd := Trim(edPassword.Text);
  if (sZipPwd <> '') then
    sOptions := sOptions + ';password=' + sZipPwd;

  if cbxChipped.Checked then
    sOptions := sOptions + ';chipped=1';
  if cbParams.Checked then
    sOptions := sOptions + ';params';
  if cbTimes.Checked then
    sOptions := sOptions + ';times';
    
  StrPCopy(rec.Options, sOptions);
End;

procedure TfrmMain.rbAllClick(Sender: TObject);
begin
  ToggleChecks(rbAll);
end;

procedure TfrmMain.rbNoneClick(Sender: TObject);
begin
  ToggleChecks(rbNone);
end;

procedure TfrmMain.ToggleChecks(Sender: TObject);
begin
  if Sender is TRadioButton then
    if TRadiobutton(Sender).Name = 'rbAll' then
    begin
      cbxClient.Checked       := True;
      cbxInvoices.Checked     := True;
      cbxPets.Checked         := True;
      cbxReminders.Checked    := True;
      cbxServiceCodes.Checked := True;
      cbxStaff.Checked        := True;
    end
    else
    begin
      cbxClient.Checked       := False;
      cbxInvoices.Checked     := False;
      cbxPets.Checked         := False;
      cbxReminders.Checked    := False;
      cbxServiceCodes.Checked := False;
      cbxStaff.Checked        := False;
    end;
end;

function TfrmMain.CopyDBFiles(const sDataPath : String) : Boolean;
var
  sPath : String;

  function CopyDBFile(const sSrcPath, sTarPath, sFile : String) : Boolean;
  Begin
    Result := CopyFile(PAnsiChar(IncludeTrailingPathDelimiter(sSrcPath) + sFile),
                      PAnsiChar(IncludeTrailingPathDelimiter(sTarPath) + sFile), False);
  End;
Begin
  sPath := (IncludeTrailingPathDelimiter(FExePath) + 'Data');
  ForceDirectories(sPath);

  Result := CopyDBFile(sDataPath, sPath, 'CATEGORY.VM$') and
            CopyDBFile(sDataPath, sPath, 'GROUP.VM$') and
            CopyDBFile(sDataPath, sPath, 'HEADER.VM$') and
            CopyDBFile(sDataPath, sPath, 'PHRASE.VM$');
End;

end.
