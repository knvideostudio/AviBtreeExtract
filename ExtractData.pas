// Modified on: Feb 09, 2009
// Author: Krassimir

unit ExtractData;

interface

uses  SysUtils,
      Classes,
      ServiceCodes,
      recClient,
      recUser,
      recEntry,
      recReminder,
      recTreatment,
      recInventory,
      recInvoice,
      recPet,
      recScriptCode,
      recMedHistory,
      recWP,
      recResult,
      AVITyp,
      uRecStruct,
      uDefs;

// Uncomment the following to enable experimental buffered input support
{$define AVI_BUFFER_INPUT}

//  Get Medical History
procedure GetCurrentMedHistory(var Context     : TExtractContext;
                     const enumFunc        : MedHistoryCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean;
                     dtStartDate     : AnsiString);

// Pets
procedure GetCurrentPets(var Context : TExtractContext;
                     enumFunc        : PetCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

// Reminders
procedure GetCurrentReminders(var Context     : TExtractContext;
                     enumFunc        : ReminderCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current       : LongInt;
                     userData          : LongInt;
                     var userAborted  : Boolean;
                     dtRemStartDate   : AnsiString;
                     dtRemEndDate     : AnsiString);

//  Invoices
procedure GetCurrentInvoices(var Context     : TExtractContext;
                     const enumFunc        : InvoiceCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean;
                     dtStartDate     : AnsiString;
                     dtEndDate       : AnsiString);

// Service Codes
Function EnumServiceCodes(EnumFunc : ServiceCodeEnumFunc;
                          AVIPath  : PChar;
                          Password : LongInt;
                          UserData : LongInt) : WordBool ; stdcall; export;

Function EnumServiceCodes2(EnumFunc : ServiceCodeEnumFunc2;
                          rec : TServiceCodeRec) : WordBool ; stdcall; export;

Function GetLastErrorMessage(buf : PChar; buflen : longint) : longint; stdcall; export;

// Stream Related Utilities
Procedure WriteExcept(errMsg : string; fName : string; pullTyp :string);
Function CreateInputStream(Filename : string) : TStream;
Procedure StreamRead(Stream : TStream; var buf; bufsize : Integer);
Function StreamReadString(const myStream : TStream; iPosition : LongInt) : String;
Function GetRecordCount(fname : string; recordSize : integer) : LongInt;
Procedure ResetCounts(var context : TExtractContext);

// added on Feb 23, 2009 - 10:29 AM
Function EnumResultData(enumFunc : ResultCodeEnumFunc;
      sPracticeID : PChar;
      AVIPath   : PChar;
      Password  : LongInt;
      UserData  : LongInt) : WordBool ; stdcall; export;

// Added on Jan 14, 2009
Function EnumWpCodeData(enumFunc : WpCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt) : WordBool ; stdcall; export;

// Added on Jan 06, 2009
Function EnumScriptCodeData(enumFunc : ScriptEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt) : WordBool ; stdcall; export;

Function EnumClientData(enumFunc : ClientCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;

Function EnumUserData(enumFunc : UserCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;

Function EnumBreedData(enumFunc : BreedCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;

Function EnumColorData(enumFunc : ColorCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;

Function EnumSpeciesData(enumFunc : SpeciesCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;

Function EnumPetData(enumFunc : PetCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;

// Reminder
Function EnumReminderData(enumFunc : ReminderCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint;
          sReminderStartDate: PChar;
          sReminderEndDate: PChar) : WordBool ; stdcall; export;

// Invoice
Function EnumInvoiceData(enumFunc : InvoiceCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt;
          sStartDate: PChar;
          sEndDate: PChar) : WordBool ; stdcall; export;  // stdCall

// Medical Records
Function EnumHistoryMedicalData(enumFunc : MedHistoryCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt;
          sStartDate: PChar) : WordBool ; stdcall; export;

// TreatMents
Function EnumTreatData(enumFunc : TreatCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath     : PChar;
          Password    : longint;
          UserData    : longint) : WordBool ; stdcall; export;

// Inventory
Function EnumInventoryData(enumFunc : InvenCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt) : WordBool ; stdcall; export;

// Database Version
Function EnumGetDataVersion(enumFunc : DataVersionEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt) : WordBool ; stdcall; export;

function GetDataVersionExec(pContext    : pointer;
                            enumFunc    : DataVersionEnumFunc;
                            sPracticeID : PChar;
                            UserData    : Integer) : Boolean;

procedure GetCurrentDatabaseVersion(var Context  : TExtractContext;
                  enumFunc        : DataVersionEnumFunc;
                  sPracticeID     : PChar;
                  totalRecs       : LongInt;
                  var current     : LongInt;
                  userData        : LongInt;
                  var userAborted : Boolean);

procedure LogStr(const s : String);

implementation

uses  DateUtils,
      Filer,
      BTIsBase,
      NumKey32,
      Utils,
      IniFiles,
      IntList,
      DIUtils
      {$ifdef AVI_BUFFER_INPUT}
      , BufFStrm
      {$endif}
      , StrUtils;

const
{$ifdef AVI_BUFFER_INPUT}
  AVI_INPUT_BUFFER_SIZE = 32768;
{$endif}
  MAX_STRING_LEN  = 512;
  ___w = 1111;
  ___m : string = 'Invalid permission. Access denied.';

  // Default Locking values
  DEFAULT_LOCK_RETRIES = 200;
  DEFAULT_LOCK_SLEEP   = 50;

  // leave the following blank, and the system will search for a file
  // with the same name as the executable calling the dll, but with an
  // .ini extension
  DEFAULT_INI_FILENAME = '';
  // otherwise, change it to a specific filename to look for
  // DEFAULT_INI_FILENAME = 'VMExtract.Ini';
  // in either case, the file is looked for in the current directory
  // (relative to the executable), the Windows directory, then the
  // Windows System directory

CONST
  // Maximum Number of locked records to bookmark and attempt later
  MAX_SKIPLIST_SIZE = 32;
  CR_LF = #13+#10;

threadvar
  {VARIABLE CREATED}
  sCurrentPath     : String;
  LastErrorMessage : String;

  // Number of retries in case of locking
  LOCK_RETRIES     : Word;

  // Time (in milliseconds) to sleep before retries
  LOCK_SLEEP       : Word;

  // Database Variable
  iDataVersion : Integer;

var
  FTimes : TStringList;

// Permission Check. Anything can go here - just return true for authorized, false otherwise.
// Named as such to defeat very simple snoop attempts
function __(__p : longint) : boolean;
begin
  result := (___w = __p);
end;


procedure __c__(__p : longint);
begin
  if (not __(__p)) then
    Raise Exception.Create(___m);
end;

function ChkJunk(const fieldStr : String) : String;
var
  //iAscii : Integer;
  i : Integer;
Begin
  Result := '';
  for i := 1 to Length(fieldStr) do
  Begin
    //iAscii := Ord(fieldStr[i]);
    if (Ord(fieldStr[i]) IN [32, 33, 35..123, 125, 126]) then
      Result := (Result + fieldStr[i]);
  End;
End;


procedure ValidateDirExists(const directoryName : string);
begin
  if not DirectoryExists(directoryName) then
    Raise Exception.Create('Directory "' + directoryName + '" does not exist.');
end;

function GetParamLogFileName : String;
Begin
  Result := (IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'Params.Log');
End;

// Added by Krassimir
// Aug 27, 2008 9:11 AM
Function GetWorkingFolder : String;
begin
     Result := (IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))));
end;

procedure DeleteParamsLog;
Begin
  DeleteFile(GetParamLogFileName);
End;

// Logs to file if LOG_IT defined at top of file
procedure LogStr(const s : String);
var
  sFile : String;
  F : TextFile;
Begin
  sFile := GetParamLogFileName;
  AssignFile(F, sFile);
  if FileExists(sFile) then
    Append(F)
  else
    ReWrite(F);
  Try
    WriteLn(F, s);
  Finally
    CloseFile(F);
  End;
End;

// Writes exceptions to log file
procedure WriteExcept(errMsg : string; fName : string; pullTyp :string);
var
  logFile    : TextFile;
  sFilePath  : String;
  errorMsg   : String;
begin
  try
    LastErrorMessage := fName + ' extraction error : ' + errMsg;
    errorMsg  := DateToStr(Date) + FLD_DELIM + TimeToStr(Time) + FLD_DELIM + pullTyp +
      ' Error occured during ' +  fName + ' extraction. Error Description : ' + errMsg;
    sFilepath := sCurrentPath + '\Log.txt';

    Assignfile(logFile, sFilePath);

    if not FileExists(sFilePath) then
      Rewrite(logFile)
    else
      Append(logFile);

    try
      Writeln(logFile,errorMsg);
    finally
      close(logFile);
    end
  except
  end;
end;

// Modified May 08, 2008
// Using old AVI Type set of types
/// BTree Filer Specific
const
  AVI_index_names : array[TAVImark_indexes] of string =
  ( 'Client',
    'Animal',
    'Service',
    'Treatment',
    'Inventory',
    'Lists',
    'Account',
    'Security',
    'Reminder',
    'Table',
    'Diagnosis',
    'Estimate',
    'Appoint',
    'Follow',
    'Split',
    'Board',
    'More',
    'QA',
    'ProbHist',
    'Problem',
    'Timeclock',
    'FormTemplate',
    'OptionValue',
    'Attachment',
    'Glossary',
    'EntryHistory',
    'DiscountRate', // Should be remove for Previous Version
    'DentalCharts',
    {$IFDEF EquineVersion}
    'EquineRegistry',
    {$ENDIF}
    'Reminder2'
    );

procedure InitBTreeFiler;
begin
  BTInitIsam(MsNet, 200);
  if (IsamError <> 0) then
    raise Exception.Create('Cannot initialize Btree Filer');
end;

procedure DisposeBTreeFiler;
begin
  BTExitIsam;
end;

function IsBTLockError: Boolean;
begin
  Result := BTIsamErrorClass = 2;
end;

procedure OpenIndexFile(const Context : TExtractContext;idxType : TAVImark_indexes);
  var FullPath : String;
begin
  FullPath := Context.FilePath + '\' + AVI_index_definitions[idxType].Name;

  // Attempt to open the appropriate index file in read-only mode
  BTOpenFileBlock(AVI_index_definitions[idxType].FileBlockPtr,
                  FullPath, False, False, True, True);

  if (IsamError <> 0) then
  begin
    LogStr('Cannot open ' + AVI_index_names[idxType] + ' Index.');
    LogStr('IsamError ' + IntToStr(IsamError));
    raise Exception.Create('Cannot open ' + AVI_index_names[idxType] + ' Index.');
  end;
end;

procedure CloseIndexFile(idxType : TAVImark_indexes);
begin
  BTCloseFileBlock(AVI_index_definitions[idxType].FileBlockPtr);
  AVI_index_definitions[idxType].FileBlockPtr := nil;
end;

function SearchForKey(idxType : TAVImark_indexes; indexNr : integer;
         var Key : IsamKeyStr;  var DatRef : LongInt) : Boolean;
var
  retries : word;
  i       : LongInt;

begin

Try

  Retries := 0;

  Repeat
    BTSearchKey(AVI_index_definitions[idxType].FileBlockPtr, indexNr, DatRef, Key);

    i := IsamError;

    // LogStr('IsamError: ' + IntToStr(i));

    if (IsBTLockError) then
    begin
      Inc(Retries);
      Sleep(10);
    end;
  until not IsBTLockError or (Retries > LOCK_RETRIES);
  if (Retries > LOCK_RETRIES) then
  begin
    raise Exception.Create( 'Locking Error During Index Search Operation (SearchKey) : ' +
        AVI_index_names[idxType]);
  end;

except on E:Exception do
      writeExcept(E.Message + ' ' + IntToStr(IsamError), 'GetRemindersInvoices', 'SearchForKey');
end;

  Result := IsamOK;

End;

function GetFirstKey(idxType : TAVImark_indexes; indexNr : Word;
         var Key : IsamKeyStr;  var DatRef : LongInt) : Boolean;
var retries : word;
    FB: IsamFileBlockPtr;
begin
  Retries := 0;
  FB  :=  AVI_index_definitions[idxType].FileBlockPtr;
  Key := '';
  BTClearKey(FB, indexNR);
  repeat
    BTSearchKey(FB, indexNr, DatRef, Key);
    if (IsBTLockError) then
    begin
      Inc(Retries);
      Sleep(10);
    end;
  until not IsBTLockError or (Retries > LOCK_RETRIES);
  if (Retries > LOCK_RETRIES) then
  begin
    raise Exception.Create( 'Locking Error During Index Search Operation (GetFirstKey) ' +
        AVI_index_names[idxType]);
  end;
  Result := IsamOK;
End;

function GetNextKey(idxType : TAVImark_indexes; indexNr : Word;
         var Key : IsamKeyStr;  var DatRef : LongInt) : Boolean;
var retries : word;
    FB: IsamFileBlockPtr;
begin
  Retries := 0;
  FB :=  AVI_index_definitions[idxType].FileBlockPtr;

  Repeat
    BTNextKey(FB, indexNr, DatRef, Key);

    if (IsBTLockError) then
    begin
      Inc(Retries);
      Sleep(10);
    end;
  until not IsBTLockError or (Retries > LOCK_RETRIES);
  // end the REPEAT LOOP

  if (Retries > LOCK_RETRIES) then
  begin
    raise Exception.Create( 'Locking Error During Index Search Operation (NextKey) ' +
        AVI_index_names[idxType]);
  end;

  Result := IsamOK;
End;

// My Data Version
// -----------------------------------------------------------------------------
function GetDataVersion(DataPath : String) : Integer;
var rec    : Hospital_record;
    size   : LongInt;
    stream : TFileStream;
    fname  : String;
begin
  fname := SlashedDir(DataPath) + 'Hospital.vm$';
  size  := Longint(Addr(rec.Hospital_Version)) - Longint(Addr(rec)) + 4; //fudge
  stream := TFileStream.Create(fname, fmOpenRead or fmShareDenyNone);
  try
    stream.Read(rec, size);
  finally
    stream.Free;
  end;
  result := rec.Hospital_Version;
end;

Procedure ClearContext(var Context : TExtractContext);
begin
  if (Context.RecordCounts <> nil) then
    Context.RecordCounts.Free;
end;

Function CreateIntCache : TIntegerList;
var
  cache : TIntegerList;

begin
  cache := TIntegerList.Create();
  cache.Sorted := true;
  cache.Duplicates := dupIgnore;
  result := cache;
end;

Procedure InitChippedPetCache(var context : TExtractContext);
begin
  if (context.ClientCache = nil) then
    context.ClientCache := CreateIntCache()
  else
    TIntegerList(context.ClientCache).Clear;

  if (context.PetCache = nil) then
    context.PetCache := CreateIntCache()
  else
      TIntegerList(context.PetCache).Clear;
end;

Procedure DestroyChippedPetCache(var context : TExtractContext);
begin
  if (context.ClientCache <> nil) then
     TIntegerList(context.ClientCache).Free;
   if (context.PetCache <> nil) then
      TIntegerList(context.PetCache).Free;
end;

Function PetIsChipped(var context : TExtractContext; PetId : longint) : boolean;
var cache : TIntegerList;
begin
  result := false;
  if (context.ChippedPets) then
  begin
    if (context.PetCache <> nil) then
    begin
      cache := TIntegerList(context.PetCache);
      result := (cache.IndexOf(petId) >= 0);
    end;
  end;
end;


Procedure CacheAnimalInfo(var context : TExtractContext; var animal : Animal_record; datRef : integer);
var animalCache, clientCache : TIntegerList;
begin
  animalCache := TIntegerList( Context.PetCache );
  clientCache := TIntegerList( Context.ClientCache );

  animalCache.Add(datRef);
  clientCache.Add(animal.Animal_client);
end;

// This is used only in custom pull when Client, Reminders
//  or Service is selected and Pets is not
Procedure GetChippedPetIds(var Context : TExtractContext);
var animal  : Animal_record;
    fname   : string;
    skey    : IsamKeyStr;
    found   : Boolean;
    datRef  : LongInt;
    fstream : TStream;
begin
  fname    := Context.FilePath + '\ANIMAL.VM$';
  fstream  := CreateInputStream(FName);
  try
    InitChippedPetCache(context);
    // Attempt to open the appropriate index file in read-only mode
    OpenIndexFile(Context, aviidxAnimal);

    try
      sKey := '';
      found := GetFirstKey(aviidxAnimal, Registration_index.Offset, sKey, DatRef);
      while (found) do
      begin
        // the ref received is the record number. We
        // need to do some math to get the byte offset
        // According to Gene, the record number is 1 based
        // so we need to subtract
        FStream.Position := (DatRef - 1) * Sizeof(Animal_record);
        StreamRead(FStream, animal, SizeOf(Animal_record));

        if (animal.Animal_recd = 'D') or (animal.Animal_recd = 'A')  then
          CacheAnimalInfo(context, animal, datRef);

        found := GetNextKey(aviidxAnimal, Registration_index.Offset, sKey, DatRef);
      end; // while

    finally
      CloseIndexFile(aviidxAnimal);
    end;

  finally
    fstream.Free;
  end;

end;

procedure ResetCounts(var context : TExtractContext);
begin
  context.NCount  := 0;
  context.WrCount := 0;
end;


procedure LoadIniSettings();
var IniFile : TIniFile;
    iniFilePath : string;
    //---------------------------------------
    procedure SetDefaults;
    begin
       LOCK_SLEEP    := DEFAULT_LOCK_SLEEP;
       LOCK_RETRIES  := DEFAULT_LOCK_RETRIES;
    end;
    //---------------------------------------
begin
  iniFilePath := '';
  SetDefaults;
  if findINI('', iniFilePath) then
  begin
    IniFile := TIniFile.Create(IniFilePath);
    try
      try
       LOCK_RETRIES  := IniFile.ReadInteger('Locking', 'LockRetries', DEFAULT_LOCK_RETRIES);
       LOCK_SLEEP    := IniFile.ReadInteger('Locking', 'LockSleep',   DEFAULT_LOCK_SLEEP);
      except
        on e: Exception do
            SetDefaults;
      end;
    finally
        IniFile.Free;
    end;
  end;
end;

procedure WriteRecordCounts(Context : TExtractContext);
var i : integer;
    str, tag, sHeader : string;
    //--------------------------------------------
    procedure WriteToTextFile(list : TStringList);
    var stream : TFileStream;
        fname, str, tag, sHeader  : string;
        i : integer;
    begin
      // Drop into output dir

      fname := Context.OutputPath + '\RecordsCount.txt';

      stream := TFileStream.Create(fname, fmCreate );
      try
        sHeader := 'PracticeID' + FLD_DELIM +
                   'Date'       + FLD_DELIM +
                   'TableName'  + FLD_DELIM +
                   'RecCount'   + FLD_DELIM +
                   'RecPulled'  + FLD_DELIM +
                   'PullVar'    + CRLF;
        stream.Write(PChar(sHeader)^, Length(sHeader));

        for i := 0 to list.Count-1 do
        begin
          tag := list[i];
          if (tag = '') then continue;
          str := Context.PracticeId + FLD_DELIM;
          str := str + FormatDateTime('m/d/yyyy', Now) + FLD_DELIM;
          str := str + tag + FLD_DELIM;
          str := str + IntToStr(Integer(list.Objects[i])) + FLD_DELIM;
          str := str + IntToStr(Integer(list.Objects[i])) + FLD_DELIM + '0' + CRLF;
          stream.Write(PChar(str)^, Length(str));
        end;
      finally
        stream.Free;
      end;
    end;
    //--------------------------------------------
begin

   // RecordCnts.txt
    sHeader := 'PracticeID' + FLD_DELIM +
               'Date'       + FLD_DELIM +
               'TableName'  + FLD_DELIM +
               'RecCount'   + FLD_DELIM +
               'RecPulled'  + FLD_DELIM +
               'PullVar';

    if (Context.RecordCounts <> nil) then
    begin
      for i := 0 to Context.RecordCounts.Count-1 do
      begin
        tag := Context.RecordCounts[i];
        if (tag = '') then continue;
        str := Context.PracticeId + FLD_DELIM;
        str := str + FormatDateTime('m/d/yyyy', Now) + FLD_DELIM;
        str := str + tag + FLD_DELIM;
        str := str + IntToStr(Integer(Context.RecordCounts.Objects[i])) + FLD_DELIM;
        str := str + IntToStr(Integer(Context.RecordCounts.Objects[i])) + FLD_DELIM + '0';

      end;
      WriteToTextFile(Context.RecordCounts);
    end;
end;

function CreateInputStream(Filename : string) : TStream;
begin
{$ifdef AVI_BUFFER_INPUT}
  result := TBufferedFileStream.Create(Filename, fmOpenRead or fmShareDenyNone);
{$else}
  Result := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
{$endif}
end;

// Handle locking issues by retrying the read operation
function AttemptStreamRead(Stream : TStream; var buf; bufsize : integer; lockRetries, lockSleep : integer) : boolean;
var tries : Integer;
    code  : Integer;
begin
  result := False;
  tries := 0;
  code := -1; // Init

  if (bufsize = 0) then
    exit;

  while (true) do
  begin
    try
      inc(tries);
      stream.Read(buf, bufsize);
      break;

   except
        on e: Exception do
        begin

          if (tries = lockRetries) then
            exit;

          if (e is EOSError) then
              code := (e as EOSError).ErrorCode
          else if (e is EInOutError) then
              code := (e as EInOutError).ErrorCode
          else
          begin
            // for other types of errors, retry but be less tolerant
            tries := trunc(tries * 2.5);
            Sleep(10);
            continue;
          end;

          // we care only about locking issues at this point
          if  (code = 33{ERROR_LOCK_VIOLATION}) or
              (code = 32 {ERROR_SHARING_VIOLATION}) then
            Sleep(lockSleep);
        end;  // o e:Exception
    end;  // except
  end;  // while;
  result := true;
end;


// Handle locking issues by retrying the read operation
procedure StreamRead(Stream : TStream; var buf; bufsize : integer);
var tries : integer;
    code  : integer;
{$ifndef AVI_BUFFER_INPUT}
    count : LongInt;
{$endif}
begin
  tries := 0;
  code := -1; // Init

  if (bufsize = 0) then
    exit;

  while (true) do
  begin
    try
      inc(tries);
{$ifndef AVI_BUFFER_INPUT}
      count := stream.Read(buf, bufsize);
      // no exception is raised necessarily, so we need to check return value of
      // read operation
      if (0 = count) then
          RaiseLastOSError;
{$else}
      stream.Read(buf, bufsize);
{$endif}
      break;
    except
        on e: Exception do
        begin
          if (tries = LOCK_RETRIES) then
            raise;

          if (e is EOSError) then
            code := (e as EOSError).ErrorCode
          else if (e is EInOutError) then
              code := (e as EInOutError).ErrorCode
          else
          begin
            // for other types of errors, retry but be less tolerant
            tries := trunc(tries * 2.5);
            Sleep(50);
            continue;
          end;

          // we care only about locking issues at this point
          if (code = 33{ERROR_LOCK_VIOLATION}) or
             (code = 32 {ERROR_SHARING_VIOLATION}) then
            Sleep(LOCK_SLEEP);
        end;  // o e:Exception
    end;  // except
  end;  // while;
end;


function StreamReadString(const myStream : TStream; iPosition : LongInt) : String;
var
  StrSize : Byte;
begin
  myStream.Position := iPosition;
  StreamRead(myStream, StrSize, sizeof(Byte));
  SetLength(Result, StrSize);
  StreamRead(myStream, PChar(Result)^, StrSize);
end;


function GetRecordCount(fname : string; recordSize : integer) : longint;
var
  f : file;
begin
  AssignFile(f, fname);
  Reset(f, recordSize);
  try
    result := Filesize(f);
  finally
    CloseFile(f);
  end;
end;

function GetPCharDate(pdate : PChar; deflt : string) : string;
begin
  result := PCharToString(pdate);
  if (length(result) = 0) then
    result := deflt;
end;

Function EnumSpeciesData(enumFunc : SpeciesCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
begin
  Result := False;

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumUserData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
    {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Species Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;    

    try
      LoadIniSettings;
      InitBTreeFiler;

      result := recEntry.ExportSpeciesEntity(@context, enumFunc, sPracticeID, UserData);
    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;
end;

// -----------------------------------------------------------------------------
// - Begin DataVersion
// - Required data version
// - Aug 20, 2008 2:59
// -----------------------------------------------------------------------------

Function EnumGetDataVersion(enumFunc : DataVersionEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : String;
begin
  Result := False;

  Try
    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumGetDataVersion Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
    {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'EnumGetDataVersion Data';
    Context.FilePath := bFilePath;

    try
      LoadIniSettings;
      InitBTreeFiler;

     result := GetDataVersionExec(@context, enumFunc, sPracticeID, UserData);

    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message, 'NormalFunction', 'StartingFunction');
  end;
end;

// Decalare in the TOP1
function GetDataVersionExec(pContext    : pointer;
                            enumFunc    : DataVersionEnumFunc;
                            sPracticeID : PChar;
                            UserData    : Integer) : Boolean;

var
    Context     : PExtractContext;
    userAborted : Boolean;
    totalRecs   : LongInt;
    current     : LongInt;

begin
  context := PExtractContext(pContext);

  Try
    userAborted := false;
    current     := 0;

    totalRecs   := GetRecordCount(SlashedDir(context.FilePath) + 'Hospital.vm$', sizeof(Hospital_record));
    GetCurrentDatabaseVersion(context^, enumFunc, sPracticeID, totalRecs, current, userData, userAborted);

    Result := not userAborted;

  Except
    on E:Exception do
    begin
         writeExcept(E.Message, 'GetDataVersionExec', Context.PullType);
         Result := false;
    end;
  end
end;

procedure GetCurrentDatabaseVersion(var Context  : TExtractContext;
                  enumFunc        : DataVersionEnumFunc;
                  sPracticeID     : PChar;
                  totalRecs       : LongInt;
                  var current     : LongInt;
                  userData        : LongInt;
                  var userAborted : Boolean);

var
    rec       : Hospital_record;
    size      : LongInt;
    stream    : TFileStream;
    fname     : String;
    DataPath  : String;
    exportRec : TDataVersion;
    
begin

  DataPath := Context.FilePath;
  
  fname := SlashedDir(DataPath) + 'Hospital.vm$';
  LogStr(fname);


  size  := Longint(Addr(rec.Hospital_Version)) - Longint(Addr(rec)) + 4; //fudge
  stream := TFileStream.Create(fname, fmOpenRead or fmShareDenyNone);

  Try
    stream.Read(rec, size);

    FillChar(exportRec, sizeof(exportRec), 0);
    exportRec.TDATAVER_PRACTICEID  := StrToInt(sPracticeID);
    exportRec.TDATAVER_IVERSION    := rec.Hospital_Version;

    if (false = enumFunc(@exportRec, current, totalRecs, userData)) then begin
        userAborted := true;
       // break;
    end;

  Finally
    stream.Free;
  end;
end;

// Begin User function
Function EnumColorData(enumFunc : ColorCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : String;
begin
  Result := False;

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumUserData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
    {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Color Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;
    
    try
      LoadIniSettings;
      InitBTreeFiler;

      result := recEntry.ExportColorEntity(@context, enumFunc, sPracticeID, UserData);
    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;

// ---------------------------------------
// - Jan 09, 2009 1:00 PM                -
// - Medical Records                     -
// ---------------------------------------
Function EnumHistoryMedicalData(enumFunc : MedHistoryCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath     : PChar;
          Password    : LongInt;
          UserData    : LongInt;
          sStartDate  : PChar) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : String;
  sAnsiSDate  : AnsiString;

begin
  Result := False;

  // Assign Dates value
  sAnsiSDate := sStartDate;

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumHistoryMedicalData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF +
           'StartDate = ' + sAnsiSDate + CR_LF);
    {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'History Medical Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;
    
    Try
      LoadIniSettings;
      InitBTreeFiler;

      result := recMedHistory.ExptMedHistory(@context, sPracticeID, enumFunc, UserData, sAnsiSDate); //, sAnsiEDate);
   Finally
      DisposeBTreeFiler;
   end;

  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;
// end Invoices

// Invoice function
Function EnumInvoiceData(enumFunc : InvoiceCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint;
          sStartDate: PChar;
          sEndDate: PChar) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
  sAnsiSDate : AnsiString;
  sAnsiEDate : AnsiString;
begin
  Result := False;

  // Assign Dates value
  sAnsiSDate := sStartDate; // GetPCharDate(sReminderStartDate, '01/01/1980');
  sAnsiEDate := sEndDate; // GetPCharDate(sReminderEndDate,   '01/01/2500');

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumInvoiceData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF +
           'StartDate = ' + sAnsiSDate + CR_LF +
           'EndDate = ' + sAnsiEDate + CR_LF);
    {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Invoice Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;
    
    try
      LoadIniSettings;
      InitBTreeFiler;
      result := recInvoice.ExpInvoice(@context, sPracticeID, enumFunc, UserData, sAnsiSDate, sAnsiEDate);

   Finally
      DisposeBTreeFiler;
   end;

  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;
// end Invoices

// Pet Function
Function EnumPetData(enumFunc : PetCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : String;
begin
  Result := False;

  Try
   DeleteParamsLog;

  {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumPetData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
 {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Pet Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    try
      LoadIniSettings;
      InitBTreeFiler;

      if (Context.ChippedPets) then
        InitChippedPetCache(context);
        
      result := recPet.ExpPet(@Context, sPracticeID, enumFunc, UserData);

   Finally
      DisposeBTreeFiler;

      if (context.ChippedPets) then
        Begin
          Try
            DestroyChippedPetCache(context);
          except
          end;
        End;
   end;

  except
    on E:Exception do
      writeExcept(E.Message, 'NormalFunction', 'StartingFunction');
  end;
end;

// Reminder Function
Function EnumReminderData(enumFunc : ReminderCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint;
          sReminderStartDate: PChar;
          sReminderEndDate: PChar) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
  sAnsiRemSDate : AnsiString;
  sAnsiRemEDate : AnsiString;
begin
  Result := False;

  // Assign Dates value
  sAnsiRemSDate := sReminderStartDate; // GetPCharDate(sReminderStartDate, '01/01/1980');
  sAnsiRemEDate := sReminderEndDate; // GetPCharDate(sReminderEndDate,   '01/01/2500');

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumReminderData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF +
           'ReminderStartDate = ' + sAnsiRemSDate + CR_LF +
           'ReminderEndDate = ' + sAnsiRemEDate + CR_LF);
    {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Reminder Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    try
      LoadIniSettings;
      InitBTreeFiler;
      result := recReminder.ExpReminders(@context,
                                        sPracticeID,
                                        enumFunc,
                                        UserData,
                                        sAnsiRemSDate,
                                        sAnsiRemEDate);

   Finally
      DisposeBTreeFiler;
   end;

  except
    on E:Exception do
      writeExcept(E.Message, 'NormalFunction', 'StartingFunction');
  end;

end;

// getting Duplicate Records
// March 26, 2008
// Pets  - Changed for Forney DATA
// Aug 19, 2008  - cannot get the right data
procedure GetCurrentPets(var Context : TExtractContext;
                     enumFunc        : PetCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);
var
  EStream       : TStream;
  exportPetRec  : TPetCode;
  iPhoto        : Integer;
  sPhotoPath    : String;

  //-----------------------------------------------------------------------
  function ProcessAnimal(const FrdAnimal : Animal_record; rCount : integer; sPracticeID : PChar) : boolean;
  var
      sAnimalDate  : String;
      sAnimalSuspendDate : String;
  begin
    result := false;

   if  (FrdAnimal.Animal_recd = 'D') or
       (FrdAnimal.Animal_recd = 'A')  then
   begin

      Inc(Context.nCount);
      FillChar(exportPetRec, sizeof(exportPetRec), 0);

      iPhoto := 0;
      sPhotoPath := '';

      exportPetRec.PETCODE_PRACTICEID := StrToInt(sPracticeID);
      exportPetRec.PETCODE_RECORDNUM := rCount;
      exportPetRec.PETCODE_RECD := FrdAnimal.Animal_recd;
      exportPetRec.PETCODE_CLIENT := IntToStr(FrdAnimal.Animal_client);
      exportPetRec.PETCODE_NAME := FrdAnimal.Animal_name;
      exportPetRec.PETCODE_SPECIES := FrdAnimal.Animal_species;
      exportPetRec.PETCODE_BREED :=  FrdAnimal.Animal_breed;
      exportPetRec.PETCODE_SEX :=  FrdAnimal.Animal_sex;
      exportPetRec.PETCODE_CODES :=  FrdAnimal.Animal_codes;
      exportPetRec.PETCODE_WEIGHT := FloatToStr(FrdAnimal.Animal_weight);

      exportPetRec.PETCODE_ADDEDDATE := DateToStr(AVIDateToDateTime(FrdAnimal.Animal_added));
      exportPetRec.PETCODE_BIRTHDATE := DateToStr(AVIDateToDateTime(FrdAnimal.Animal_birthday));

      // AVIDateToDateTime
      if FrdAnimal.Animal_death <> 0 then
        sAnimalDate := DateToStr(AVIDateToDateTime(FrdAnimal.Animal_death))
      else
        sAnimalDate := TimeToStr(FrdAnimal.Animal_death);

      exportPetRec.PETCODE_DEATHDATE := sAnimalDate;

      // begin Photo
      iPhoto := FrdAnimal.Animal_photo;
      if iPhoto > 0 then
        sPhotoPath := StreamReadString(EStream, iPhoto - 1)
      else
        sPhotoPath := IntToStr(iPhoto);

      exportPetRec.PETCODE_PHOTO := sPhotoPath;
      // end Photo

       exportPetRec.PETCODE_MICROCHIP := FrdAnimal.Animal_registration;
       exportPetRec.PETCODE_RABTAG := FrdAnimal.Animal_rabies;
       exportPetRec.PETCODE_COLOR :=  FrdAnimal.Animal_color;

       // Animal Suspend Date
       sAnimalSuspendDate := '';
       if FrdAnimal.Animal_suspend <> 0 then
        sAnimalSuspendDate := DateToStr(AVIDateToDateTime(FrdAnimal.Animal_suspend))
      else
        sAnimalSuspendDate := TimeToStr(FrdAnimal.Animal_suspend);

        exportPetRec.PETCODE_SUSPENDREM := sAnimalSuspendDate;
        // End Animal Suspend Date

      Inc(Context.wrCount);

      result := true;
    end;
  end;

//------------- End Process Animal   -------------------------------------
Procedure ProcessChipped(enumFunc  : PetCodeEnumFunc);
  var
      rCount    : LongInt;
      FrdAnimal : Animal_record;
      FName     : String;
      fstream   : TStream;
      skey      : IsamKeyStr;
      found     : Boolean;
      datRef    : LongInt;
  begin

    FName    := Context.FilePath +'\ANIMAL.VM$';
   // LogStr('ProcessChipped: ' +  FName);
    fstream  := CreateInputStream(FName);

    Try
      // Attempt to open the appropriate index file in read-only mode
      // Initialize the Chache
     // InitChippedPetCache(Context);
      OpenIndexFile(Context, aviidxAnimal);

       Try
        sKey := '';

        found := GetFirstKey(aviidxAnimal, Registration_index.Offset, sKey, DatRef);

     //   LogStr('Chipped' + BoolToStr(found));
        While (found) Do Begin

          // the ref received is the record number. We
          // need to do some math to get the byte offset
          // According to Gene, the record number is 1 based
          // so we need to subtract
          FStream.Position := (DatRef - 1) * Sizeof(Animal_record);
          StreamRead(FStream, FrdAnimal, SizeOf(Animal_record));

          rCount := datRef;
          if  (FrdAnimal.Animal_recd = 'D') or
              (FrdAnimal.Animal_recd = 'A')  then
          begin
          //  if (writeOutput) then
              ProcessAnimal(FrdAnimal, rCount, sPracticeID);

              // Getting Duplicates
              // May 15, 2008
              // Begin Enum Function
              if (false = enumFunc(@exportPetRec, current, totalRecs, userData)) then
              begin
                userAborted := true;
                break;
              end; // end enum function
          end; // end D and A

        found := GetNextKey(aviidxAnimal, Registration_index.Offset, sKey, DatRef);

        end; // end while

      finally
        CloseIndexFile(aviidxAnimal);
      end;

    finally
      fstream.Free;
    end;
 end;
 //-----------------------------------------------------------------------
  Procedure ProcessUnChipped(enumFunc : PetCodeEnumFunc);
  var
      FrdAnimal  : Animal_record;
      rCount  : LongInt;
      fname   : String;
      FStream : TStream;
  begin

    fname   := Context.FilePath +'\ANIMAL.VM$';
    FStream := CreateInputStream(FName);

    // added right now
     fname   := Context.DataFldr +'data\PHRASE.VM$';
     EStream := CreateInputStream(fname);

    Try
      rCount := 0;

      while (FStream.Position < FStream.Size) Do
      begin

        Inc(rCount);
        StreamRead(FStream, FrdAnimal, SizeOf(Animal_record));

        // Added on May 15, 2008
       if  (FrdAnimal.Animal_recd = 'D') or
           (FrdAnimal.Animal_recd = 'A')  then
       begin

          ProcessAnimal(FrdAnimal, rCount, sPracticeID);

         if (false = enumFunc(@exportPetRec, current, totalRecs, userData)) then
          begin
             userAborted := true;
             break;
           end; // end if false
        end; // end if D or A
       end; // while
     finally
      FStream.Free;
      EStream.Free;
    end;
  end;
//--------- End Process UnChipped ---------------------------------
begin
  if (userAborted) then exit;
  // dStart    := Now;
    Try
        ResetCounts(context);

        if (Context.ChippedPets) then
          ProcessChipped(enumFunc)
        else
          ProcessUnChipped(enumFunc);

 Except
    on E:Exception do
      writeExcept(E.Message, 'GetCurrentPets' ,Context.PullType);
 end;

end;
// end Pet Records


// Last Updated: Jan 20, 2009
// ***************************************************************
// * Get Medical History
// ***************************************************************
procedure GetCurrentMedHistory(var Context     : TExtractContext;
                     const enumFunc        : MedHistoryCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean;
                     dtStartDate     : AnsiString);
var
  FStream      : TStream;
  FrService    : Service_record;
  FSearchStream : TFileStream;
  WpRecord : WP_record;
  strNote       : String;
  strInstruction : String;
  dAmount       : Double;
  iPosted       : Integer;
  expServiceRec : TMedHistoryCode;
  fName        : String;
  SrvStartDate : TDateTime;
  dStart       : TDateTime;
  ServiceDate : TDateTime;
// ---------------------------------------------------------------------------
function ProcessRecord(const FrService : Service_record) : Boolean;
begin
      result := false;

        Inc(context.nCount);
        FillChar(expServiceRec, sizeof(expServiceRec), 0);

        expServiceRec.MEDCODE_PRACTICE  := StrToInt(sPracticeID);
        expServiceRec.MEDCODE_RECORDNUM := context.nCount;
        expServiceRec.MEDCODE_RECD      := FrService.Service_recd;
        expServiceRec.MEDCODE_TYPE      := FrService.Service_type;

        // Boolean version
        if FrService.Service_posted = true then
           iPosted := 1
        else
           iPosted := 0;
        expServiceRec.MEDCODE_POSTED    := IntToStr(iPosted);
        // end Boolean version

        expServiceRec.MEDCODE_DATE      := DateToStr(AVIDateToDateTime(FrService.Service_date));
        expServiceRec.MEDCODE_VACCINE   := IntToStr(FrService.Service_vaccine);
        expServiceRec.MEDCODE_DOCTOR    := FrService.Service_doctor;
        expServiceRec.MEDCODE_DESCRIPTION := FrService.Service_description;
        expServiceRec.MEDCODE_CODE      := FrService.Service_code;

        dAmount := FrService.Service_amount / 100;
        expServiceRec.MEDCODE_AMOUNT    := FormatFloat('0.00', dAmount);

        expServiceRec.MEDCODE_QUANTITY  := FloatToStr(FrService.Service_quantity / 100);
        expServiceRec.MEDCODE_SOLDBY    := FrService.Service_sold_by;
        expServiceRec.MEDCODE_RXFEES    := IntToStr(FrService.Service_fees);
        expServiceRec.MEDCODE_INVOICE   := IntToStr(FrService.Service_invoice);
        expServiceRec.MEDCODE_ACCOUNT   := IntToStr(FrService.Service_account);
        expServiceRec.MEDCODE_PETID     := IntToStr(FrService.Service_animal);
        expServiceRec.MEDCODE_ENTEREDBY := FrService.Service_entered;
        expServiceRec.MEDCODE_COMPANY   := IntToStr(FrService.Service_company);
        expServiceRec.MEDCODE_REFILLS   := IntToStr(FrService.Service_refills);

       // Instruction
        strInstruction := '';
        if FrService.Service_doctor_instructions > 0 then
        begin
            FillChar(WpRecord, sizeof(WpRecord), 0);
            FSearchStream.Position := FrService.Service_doctor_instructions - 1;
            FSearchStream.Read(WpRecord, SizeOf(WP_record));

            if (WpRecord.WP_text <> '') then
            begin
                strInstruction := ChkJunk(WpRecord.WP_text);
            end;
        end;

        // StrPCopy(expServiceRec.MEDCODE_DOCTOR_INSTR, strInstruction);
         StringToBuf(strInstruction, expServiceRec.MEDCODE_DOCTOR_INSTR, sizeof(expServiceRec.MEDCODE_DOCTOR_INSTR)-1);
        // end Instruction


        // Begin Note
        strNote := '';
        if FrService.Service_note > 0 then
        begin
            FillChar(WpRecord, sizeof(WpRecord), 0);
            FSearchStream.Position := FrService.Service_note - 1;
            FSearchStream.Read(WpRecord, SizeOf(WP_record));

            if (WpRecord.WP_text <> '') then
            begin
                strNote := ChkJunk(WpRecord.WP_text);
            end;
        end;
       // StrPCopy(expServiceRec.MEDCODE_NOTE, strNote);
        StringToBuf(strNote, expServiceRec.MEDCODE_NOTE, sizeof(expServiceRec.MEDCODE_NOTE)-1);
        // end NOTE

        Inc(Context.wrCount);
        result := true;
   // end;
end;
  //-----------------------------------------------------------------------
  begin
  if (userAborted) then exit;
  dStart := Now;

  Try
    ResetCounts(Context);

    fName   := Context.FilePath +'\SERVICE.VM$';
    FStream := CreateInputStream(fName);
    FSearchStream := TFileStream.Create(Context.FilePath + '\WP.VM$', fmOpenRead or fmShareDenyNone);

    // ading the result data Results.vm$
   // fileResult := Context.FilePath + '\RESULTS.VM$';
   // FSrcmResult := TFileStream.Create(Context.FilePath + '\RESULTS.VM$', fmOpenRead or fmShareDenyNone);

    // sKey  := '';
    SrvStartDate  := StrToDate(dtStartDate);

    Try
          // OpenIndexFile(Context, aviidxService);
          // found := GetFirstKey(aviidxService, Service_index.Offset, sKey, DatRef);

          // Begin LOOP
          //while (found) Do Begin
          while (FStream.Position < FStream.Size) do Begin

           // FStream.Position := (DatRef - 1) * Sizeof(Service_record);
            StreamRead(FStream, FrService, SizeOf(Service_record));

            // FrService.Service_type
            // ------------------------------------------------------
            // - adding a new Filter                                -
            // - only records with type - I                         -
            // if  (FrService.Service_type in ['I']) and
            //    (ServiceDate >= SrvStartDate) and
            //    (ServiceDate <= SrvEndDate) then
            // ------------------------------------------------------
            // if  (FrService.Service_type in ['E', 'L', 'T', 'S']) and
            //    (ServiceDate >= SrvStartDate) then
            // I - Invoice
            // S - Service
            // add criteria by Date

            ServiceDate := AVIDateToDateTime(FrService.Service_date);

            if  (ServiceDate >= SrvStartDate) then
            begin
                // retrieve records
                ProcessRecord(FrService); // , DatRef);

                if (false = enumFunc(@expServiceRec, current, totalRecs, userData)) then
                  begin
                    userAborted := true;
                    break;
                  end;
                end; // Date Criteria

             //   found := GetNextKey(aviidxService, Service_index.Offset, sKey, DatRef);
         end; // end while

     Finally
      // CloseIndexFile(aviidxService);
       FStream.Free;
       FSearchStream.Free;
     //  FSrcmResult.Free;

       if Context.LogTimes then
          FTimes.Add('Extract Medical History: ' + FormatDateTime('hh:mm:ss:zzz', Now - dStart));
     end;
 Except
    on E:Exception do
      writeExcept(E.Message, 'Get Current Med History' ,Context.PullType);
  end;
end;
// End Medical History

// -------------------------------------------------------------------------
// ---  Get Invoices                                                     ---
// ---  Modified at May 02, 2008                                         ---
// -------------------------------------------------------------------------
procedure GetCurrentInvoices(var Context     : TExtractContext;
                     const enumFunc        : InvoiceCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : longint;
                     var current     : longint;
                     userData        : longint;
                     var userAborted : boolean;
                     dtStartDate     : AnsiString;
                     dtEndDate       : AnsiString);
var
  FStream      : TStream;
  FrAccount    : Account_record;
  fName        : String;
  DatRef         : Longint;
  found          : Boolean;
  wDateStart     : Word;
  wDateEnd       : Word;
  sKey           : IsamKeyStr;
  sIndexLow      : IsamKeyStr;
  sIndexHigh     : IsamKeyStr;
  exportInvoiceRec : TInvoiceCode;
  InvoiceStartDate    : TDateTime;
  InvoiceEndDate      : TDateTime;
  dMidValue    : Double;
  arrSkipped   : array[1..MAX_SKIPLIST_SIZE] of LongInt;
  skipCount    : Integer;
  dStart       : TDateTime;

 // -----------------------------------------------------------------------
 // before it was var FrAccount : Account_record
  function ProcessRecord(const FrInvoice : Account_record; recNo : LongInt) : Boolean;
  var
      accountDate : TDateTime;
      sClient     : String;
  begin
    result := false;

    AccountDate := AVIDateToDateTime(FrInvoice.Account_date);

    // 'P' as Payments
    // Types:
    // I - invoice ...
    // S - non-tax ...
    // T - taxable ...
    if (FrInvoice.Account_type in ['I', 'S', 'T']) and
       (AccountDate >= InvoiceStartDate) and
       (AccountDate <= InvoiceEndDate) and
       // If we need only chipped pets, filter for it here
       ((not context.ChippedPets) or PetIsChipped(Context, FrInvoice.Account_animal))
       then
    begin

        Inc(Context.nCount);
        FillChar(exportInvoiceRec, sizeof(exportInvoiceRec), 0);

        sClient   := IntToStr(FrInvoice.Account_client);
        exportInvoiceRec.INVOICECODE_PRACTICEID := StrToInt(sPracticeID);
        exportInvoiceRec.INVOICECODE_RECORDNUM := recNo;
        exportInvoiceRec.INVOICECODE_RECD := FrInvoice.Account_recd;

        exportInvoiceRec.INVOICECODE_IANIMAL :=  IntToStr(FrInvoice.Account_animal);
        exportInvoiceRec.INVOICECODE_CODE :=  FrInvoice.Account_code;
        exportInvoiceRec.INVOICECODE_TYPE := FrAccount.Account_type;


        StringToBuf(DateToStr(AVIDateToDateTime(FrInvoice.Account_Date)),
            exportInvoiceRec.INVOICECODE_DATE,
            sizeof(exportInvoiceRec.INVOICECODE_DATE)-1);

        StringToBuf(FrInvoice.Account_doctor,
            exportInvoiceRec.INVOICECODE_DOCTOR,
            sizeof(exportInvoiceRec.INVOICECODE_DOCTOR)-1);

        StringToBuf(FloatToStr(FrInvoice.Account_qty / 100),
            exportInvoiceRec.INVOICECODE_QTY,
           sizeof(exportInvoiceRec.INVOICECODE_QTY)-1);

        dMidValue := FrInvoice.Account_amount / 100;

       StringToBuf(FormatFloat('0.00', dMidValue),
          exportInvoiceRec.INVOICECODE_AMOUNT,
          sizeof(exportInvoiceRec.INVOICECODE_AMOUNT)-1);

        StringToBuf(sClient,
            exportInvoiceRec.INVOICECODE_CLIENT,
            sizeof(exportInvoiceRec.INVOICECODE_CLIENT)-1);

        StringToBuf(IntToStr(FrInvoice.Account_data.Account_invno),
        exportInvoiceRec.INVOICECODE_NUMBER, sizeof(exportInvoiceRec.INVOICECODE_NUMBER)-1);

        // adding the new field
        // Dec 09, 2008
        StringToBuf(FrInvoice.Account_description,
          exportInvoiceRec.INVOICECODE_DESC,
          sizeof(exportInvoiceRec.INVOICECODE_DESC)-1);

        Inc(Context.wrCount);
        result := true;

    end; // end IF
  end;
  //-----------------------------------------------------------------------
  procedure ProcessSkipped();
  var
      skipIndex : Integer;
      DatRef    : LongInt;
  begin
      // Process any records we may have skipped due to locks.
      // This time we do reads and retries according to ini settings
      for skipIndex := 1 to skipCount do
      begin

          if (FrAccount.Account_type in ['I', 'S', 'T']) then
          Begin
            DatRef := arrSkipped[skipIndex];
            FStream.Position := (DatRef - 1) * Sizeof(Account_record);
            StreamRead(FStream, FrAccount, SizeOf(Account_record));
            ProcessRecord(FrAccount, DatRef);
          end;
      end;
      skipCount := 0;
  end;
  //-----------------------------------------------------------------------
  // Add record number to list of records to process later
  // If the list is full, then process it immediately
  procedure SkipRecord(DatRef : LongInt);
  begin
      if (skipCount >= MAX_SKIPLIST_SIZE) then
          ProcessSkipped();

    inc(skipCount);
    arrSkipped[skipCount] := DatRef;
  end;
begin
  if (userAborted) then exit;
  dStart := Now;

  Try
    ResetCounts(Context);
    fName   := Context.FilePath +'\ACCOUNT.VM$';
    FStream := CreateInputStream(fName);

    // Calculate index range
    // index expression is WordToKey(Reminder_due) + Int32ToKey(Reminder_recno)
    // Index expression is DescendingKey(WordToKey(Account_date) + Int32ToKey(Account_recno), 6)
    InvoiceStartDate := StrToDate(dtStartDate);
    InvoiceEndDate := StrToDate(dtEndDate);

    // Here's the invoice bug
    wDateStart := DateTimeToAVIDate(InvoiceStartDate);
    wDateEnd   := DateTimeToAVIDate(InvoiceEndDate);

    // index prefixes for the given range
    sIndexLow   := DescendingKey(WordToKey(wDateStart), 6);
    sIndexHigh  := DescendingKey(WordToKey(wDateEnd), 6);

    // ensure we search in ascending key order
    if (sIndexLow > sIndexHigh) then
      begin
         sKey := sIndexLow;
         sIndexLow := sIndexHigh;
         sIndexHigh := sKey;
    end;

    // Attempt to open the appropriate index file in read-only mode
    OpenIndexFile(Context, aviidxAccount);
    Try
          sKey := sIndexLow;
          skipCount := 0;
          found := SearchForKey(aviidxAccount, AccountDate_index.Offset, sKey, DatRef);

          while (found) and ((sKey >= sIndexLow) and (sKey <= sIndexHigh)) do
          begin

            //sKey := DatRef;
            // we're in the proper date range, so lets check the record
            // the ref received is the record number. We
            // need to do some math to get the byte offset
            // According to Gene, the record number is 1 based
            // so we need to subtract
            FStream.Position := (DatRef - 1) * Sizeof(Account_record);

      		  // Attempt a quick read of the account file. If we encounter a lock,
            // just bookmark the location and attempt later

            if AttemptStreamRead(FStream, FrAccount, sizeof(Account_record), 10, 25) then
              ProcessRecord(FrAccount, DatRef)
           else
              SkipRecord(DatRef);

            if (FrAccount.Account_type in ['I', 'S', 'T']) then
            Begin
               if (false = enumFunc(@exportInvoiceRec, current, totalRecs, userData)) then
                  begin
                     userAborted := true;
                      break;
               end; // end if false
            end;

            found := GetNextKey(aviidxAccount, AccountDate_index.Offset, sKey, DatRef);
          end; // end while

     Finally
       CloseIndexFile(aviidxAccount);
       FStream.Free;

       if Context.LogTimes then
        FTimes.Add('Extract Invoices Time : ' + FormatDateTime('hh:mm:ss:zzz', Now - dStart));
     end;

     // Commented on May 02, 2008
      ProcessSkipped();


 Except
    on E:Exception do
      writeExcept(E.Message, 'GetCurrentInvoices' ,Context.PullType);
  end;
end;

// --------------------------------------------
// - Lastest Update: May 18, 2008 10:31 AM
// - Last Update: Aug 8, 2008               -
// - get Reminders                            -
// --------------------------------------------
procedure GetCurrentReminders(var Context     : TExtractContext;
                     enumFunc        : ReminderCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean;
                     dtRemStartDate: AnsiString;
                     dtRemEndDate: AnsiString);
var
  FStream        : TStream;
  rmRecord       : Reminder_record;
  fName          : String;
  rCount         : LongInt;
  wDateStart     : Word;
  wDateEnd       : Word;
  sKey           : IsamKeyStr;
  sIndexLow      : IsamKeyStr;
  sIndexHigh     : IsamKeyStr;
  DatRef         : LongInt;
  found          : Boolean;

  dStart                    : TDateTime;
  exportReminderRec         : TReminderCode;
  ContextReminderStartDate  : TDateTime;
  ContextReminderEndDate    : TDateTime;
  ReturnedDataDate          : TDateTime;
// get Records
// ***************************************************
procedure ProcessReminder(var reminder: Reminder_record; rCount : LongInt);
 // var
 //   ReminderDue : TDateTime;
  begin

 //  ReminderDue := AVIDateToDateTime(rmRecord.Reminder_due);

  // If Reminder Due Current dates
  //  if (rmRecord.Reminder_recd = 'A') and
  //    (ReminderDue >= ContextReminderStartDate) and
  //    (ReminderDue <= ContextReminderEndDate) then
  // begin
      Inc(context.nCount);
      FillChar(exportReminderRec, sizeof(exportReminderRec), 0);

      rCount    := DatRef;

      exportReminderRec.REMINDERCODE_PRACTICEID := StrToInt(sPracticeID);
      exportReminderRec.REMINDERCODE_RECORDNUM := rCount;
      exportReminderRec.REMINDERCODE_RECD := rmRecord.Reminder_recd;
      exportReminderRec.REMINDERCODE_PARENT := IntToStr(rmRecord.Reminder_parent);
      exportReminderRec.REMINDERCODE_CODE := rmRecord.Reminder_code;
      exportReminderRec.REMINDERCODE_DESCRIPTION := rmRecord.Reminder_description;
      exportReminderRec.REMINDERCODE_DUEDATE := DateToStr(AVIDateToDateTime(rmRecord.Reminder_due));
      exportReminderRec.REMINDERCODE_APPROPRIATE := IntToStr(Ord(rmRecord.Reminder_appropriate));
      exportReminderRec.REMINDERCODE_SUSPEND := BoolToStr(rmRecord.Reminder_suspend);

      Inc(Context.wrCount);
   // end;
  end;
////////////////////////////// end procedure   //////////////////////////////////////////
  function IsChippedPetReminder(var myReminder: Reminder_record): boolean;
  begin
    // todo : need to figure out and validate
    result := PetIsChipped(context, myReminder.Reminder_parent);
  end;  
// ********************************************************
begin
  if (userAborted) then exit;
  try
    dStart    := Now;
    ResetCounts(Context);

    // Begin Stream
    fName    := Context.FilePath + '\PROC.VM$';
    FStream  := CreateInputStream(fName);

    // LogStr('Open File: ' + fName);

    // get dates from str to datetime
    ContextReminderStartDate  := StrToDate(dtRemStartDate);
    ContextReminderEndDate    := StrToDate(dtRemEndDate);

    // Dates
    wDateStart := DateTimeToAVIDate(ContextReminderStartDate);
    wDateEnd   := DateTimeToAVIDate(ContextReminderEndDate);

   // LogStr('wStart Date; ' + DateTostr(wDateStart));
   // LogStr('wEnd Date; ' + DateTostr(wDateEnd));

   // ***********************************************
   // index prefixes for the given range
    sIndexLow  := WordToKey(wDateStart);
    sIndexHigh  := WordToKey(wDateEnd);

    OpenIndexFile(Context, aviidxReminder);

    // iIndexLow   := KeyToInt32(sIndexLow);
    // iIndexHigh  := KeyToInt32(sIndexHigh);

    Try
      sKey := sIndexLow;

      found := SearchForKey(aviidxReminder, RemindDate_index.Offset, sKey, DatRef);

      // Begin the LOOP
      while (found) and ((sKey >= sIndexLow) and (sKey <= sIndexHigh)) do
      begin

        FStream.Position := (DatRef - 1) * SizeOf(Reminder_record);
        StreamRead(FStream, rmRecord, SizeOf(Reminder_record));

        // counts
        rCount := DatRef;

        // added new logic here
        ReturnedDataDate := AVIDateToDateTime(rmRecord.Reminder_due);

        if (rmRecord.Reminder_recd = 'A') and
            (ReturnedDataDate >= ContextReminderStartDate) and
            (ReturnedDataDate <= ContextReminderEndDate) then
        begin

          // if ChipPets
          if (not context.ChippedPets) or (IsChippedPetReminder(rmRecord)) then
            ProcessReminder(rmRecord, rCount);

          if (false = enumFunc(@exportReminderRec, current, totalRecs, userData)) then
           begin
              userAborted := true;
              break;
           end; // end if false
        end; // Reminder_recd

        found := GetNextKey(aviidxReminder, RemindDate_index.Offset, sKey, DatRef);
        Inc(context.wrCount);
       end; // while LOOP

    finally
      CloseIndexFile(aviidxReminder);
      FStream.Free;

       if Context.LogTimes then
        FTimes.Add('Extract Reminder Time : ' + FormatDateTime('hh:mm:ss:zzz', Now - dStart));
    end;

except
    on E:Exception do
        writeExcept(E.Message, 'GetCurrentReminders', Context.PullType);
    end;
end;
// End Reminder
// **********************************************

// Begin User function
Function EnumBreedData(enumFunc : BreedCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
begin
  Result := False;

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumUserData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
    {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Breed Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    try
      LoadIniSettings;
      InitBTreeFiler;

      result := recEntry.ExportBreedEntity(@context, enumFunc, sPracticeID, UserData);

    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;

// Begin Inventory function
Function EnumInventoryData(enumFunc : InvenCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : String;
begin
  Result := False;

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumInventoryData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
    {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Inventory Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    try
      LoadIniSettings;
      InitBTreeFiler;

      result := recInventory.ExpMyItem(@context, enumFunc, sPracticeID, UserData);
      
    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;

// Begin Treatment Function
Function EnumTreatData(enumFunc : TreatCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
begin
  Result := False;

  Try
    DeleteParamsLog;

  {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumTreatData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
  {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Treat Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;    

    try
      LoadIniSettings;
      InitBTreeFiler;

      result := recTreatment.ExpTreat(@context, enumFunc, sPracticeID, UserData);
    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;


// Begin User function
Function EnumUserData(enumFunc : UserCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : longint;
          UserData  : longint) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
begin
  Result := False;

  Try
    DeleteParamsLog;

  {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumUserData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
   {$endif}

    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'User Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;
    // Get Data Version
    // iDataVersion := GetDataVersion(Context.FilePath);

    try
      LoadIniSettings;
      InitBTreeFiler;

      result := recUser.ExpUsers(@context, enumFunc, sPracticeID, UserData);

    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;

// Jan 14, 2009
Function EnumWpCodeData(enumFunc : WpCodeEnumFunc;
          sPracticeID : PChar;
          AVIPath   : PChar;
          Password  : LongInt;
          UserData  : LongInt) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : String;
begin
  Result := False;

  Try
    DeleteParamsLog;

  {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumWpCodeData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
   {$endif}

    // Verifies that the password is 1111?
    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    FillChar(Context, sizeof(Context), 0);
    Context.PullType := 'EnumWpCodeData';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    try
      LoadIniSettings;
      InitBTreeFiler;
      result := recWp.ExptWpCodes(@context, enumFunc, sPracticeID, UserData);
    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;


// Jan 06, 2009
// ---------------------------------------------------
Function EnumScriptCodeData(enumFunc : ScriptEnumFunc;
      sPracticeID : PChar;
      AVIPath   : PChar;
      Password  : LongInt;
      UserData  : LongInt) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : String;
begin
  Result := False;

  Try
    DeleteParamsLog;

  {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumScriptData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
   {$endif}

    // Verifies that the password is 1111?
    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    FillChar(Context, sizeof(Context), 0);
    Context.PullType := 'Script Code Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    try
      LoadIniSettings;
      InitBTreeFiler;

      // result := recClient.ExpClients(@context, enumFunc, sPracticeID, UserData);
      result := recScriptCode.ExptScriptCodes(@context, enumFunc, sPracticeID, UserData);

    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;

// Feb 23, 2009 - 10:26 AM
// Calls recClient.ExpClients which uses
// a callback function to process records
Function EnumResultData(enumFunc : ResultCodeEnumFunc;
      sPracticeID : PChar;
      AVIPath   : PChar;
      Password  : LongInt;
      UserData  : LongInt) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
begin
  Result := False;

  Try
    DeleteParamsLog;

  {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumResultData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
   {$endif}

    // Verifies that the password is 1111?
    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Result Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    try
      LoadIniSettings;
      InitBTreeFiler;

      result := recResult.ExpResults(@context, enumFunc, sPracticeID, UserData);

    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message, 'NormalFunction', 'StartingFunction');
  end;

end;

// March 11, 2008
// // Calls recClient.ExpClients which uses a callback function to process records
Function EnumClientData(enumFunc : ClientCodeEnumFunc;
      sPracticeID : PChar;
      AVIPath   : PChar;
      Password  : LongInt;
      UserData  : LongInt) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : String;
begin
  Result := False;

  Try
    DeleteParamsLog;

  {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumClientData Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
   {$endif}

    // Verifies that the password is 1111?
    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Client Data';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    try
      LoadIniSettings;
      InitBTreeFiler;

      result := recClient.ExpClients(@context, enumFunc, sPracticeID, UserData);

    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;

//
// function ExportServiceCodes( pContext   : pointer;
//                              enumFunc : ServiceEnumFunc;
//                              UserData   : Integer) : boolean;
//
// Calls ServiceCodes.ExportServiceCodes which uses a callback function to process records
//////////////////////////////////////////////////////////////////////////////////////////
Function EnumServiceCodes(EnumFunc : ServiceCodeEnumFunc;
                           AVIPath   : PChar;
                           Password  : longint;
                           UserData  : longint) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
begin
  Result := False;

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    // record input parameters
    LogStr('EnumServiceCodes Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + AVIPath + CR_LF +
           'Password = ' + IntToStr(Password) + CR_LF +
           'UserData = ' + IntToStr(UserData) + CR_LF);
    {$endif}

    // Verifies that the password is 1111?
    __c__(Password);
    lastErrorMessage := '';
    bfilePath := StrPas(AVIPath);
    ValidateDirExists(bFilePath);

    //Reading Values from Intermediate file
    //ReadValues(sCurrentPath + 'AviPull.txt');
    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Service Codes';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;
    
    try
      LoadIniSettings;
      InitBTreeFiler;

      result := ServiceCodes.ExportServiceCodes( @context, enumFunc, UserData);
    Finally
      DisposeBTreeFiler;
    end;
  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;

// Calls ServiceCodes.ExportServiceCodes2 which uses a callback function to process records
Function EnumServiceCodes2(EnumFunc : ServiceCodeEnumFunc2;
                           rec : TServiceCodeRec) : WordBool ; stdcall; export;
var
  Context     : TExtractContext;
  bFilePath   : string;
begin
  Result := False;

  Try
    DeleteParamsLog;

    {$ifdef LOG_IT}
    LogStr('EnumServiceCodes Parameters:' + CR_LF +
           'EnumFunc' + CR_LF +
           'AVIPath = ' + rec.AVIPath + CR_LF +
           'Password = ' + IntToStr(rec.Password) + CR_LF +
           'UserData = ' + IntToStr(rec.UserData) + CR_LF);
    {$endif}

    __c__(rec.Password);
    lastErrorMessage := '';
    bfilePath := StrPas(rec.AVIPath);
    ValidateDirExists(bFilePath);

    //Reading Values from Intermediate file
    //ReadValues(sCurrentPath + 'AviPull.txt');
    Fillchar(Context, sizeof(Context), 0);
    Context.PullType := 'Service Codes';
    Context.FilePath := bFilePath;
    Context.DataFldr := GetWorkingFolder;

    LoadIniSettings;

    result := ExportServiceCodes2( @context, enumFunc, rec.UserData);

  except
    on E:Exception do
      writeExcept(E.Message,'NormalFunction','StartingFunction');
  end;

end;

function GetLastErrorMessage(buf : PChar; buflen : longint) : longint; stdcall;export;
begin
  try
    StringToBuf(LastErrorMessage, buf, buflen);
    result := Length(LastErrorMessage);
  except
    result := 0;
  end;
end;

// Actual End of file
end.


