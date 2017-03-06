// Last Modified: Jan 09, 2009
// by Krassimir Nikov
// Last Modified: March 11, 2008
// by Krassimir Nikov
// added new Types for Client

unit uDefs;

interface

uses  SysUtils,
      Classes;

// Uncomment the following to enable experimental buffered input support
{$define AVI_BUFFER_INPUT}

const
  // the following are derived from AviTypx.pas
  CATEGORY_NAME_MAX_LENGTH      = 31;
  STRING_LENGTH_1 = 1;
  STRING_LENGTH_2 = 2;
  STRING_LENGTH_3 = 3;
  STRING_LENGTH_4 = 4;
  STRING_LENGTH_5 = 5;
  STRING_LENGTH_6 = 6;
  STRING_LENGTH_7 = 7;
  STRING_LENGTH_8 = 8;
  STRING_LENGTH_10 = 10;
  STRING_LENGTH_12 = 12;
  STRING_LENGTH_15 = 15;
  STRING_LENGTH_20 = 20;
  STRING_LENGTH_30 = 30;
  STRING_LENGTH_31 = 31;
  STRING_LENGTH_40 = 40;
  STRING_LENGTH_45 = 45;
  STRING_LENGTH_25 = 25;
  STRING_LENGTH_85 = 85;
  STRING_LENGTH_150 = 150;
  MAX_MEMO_SIZE    = 932;
  RESULT_DATA_SIZE = 2047;

type
  // added right now
  CharSet        = set of Char;
  MemoField      = Array[0..MAX_MEMO_SIZE] of Char;
  ResDataField   = Array[0..RESULT_DATA_SIZE] of Char;

  PExtractContext = ^TExtractContext;
  TExtractContext = Packed Record
    StartDate        : TDateTime;
    EndDate          : TDateTime;
    ReminderStart    : TDateTime;
    ReminderEnd      : TDateTime;
    AppPath          : String;
    FilePath         : String;
    PracticeId       : String;
    PullType         : String;
    nCount           : LongInt;
    wrCount          : LongInt;
    OutputPath       : String;
    ChippedPets      : Boolean;
    PetCache         : pointer;
    ClientCache      : pointer;
    DataFldr         : String;
    Crc32            : Cardinal;
    CurrentFile      : String;
    TempContent      : TStringList;
    RecordCounts     : TStringList;
    NewZipEntry      : String;
    Password         : String;
    _Passwd          : String;
    LogParams        : Boolean;
    LogTimes         : Boolean;
  end;

  // Aug 20, 2008 - fields for version number
  PDataVersion = ^TDataVersion;
  TDataVersion = Record
      TDATAVER_PRACTICEID   : Integer;
      TDATAVER_IVERSION     : Integer;
  end;

  // Added on Feb 23, 2009
  // 10:11 AM
  PResultData = ^TResultData;
  TResultData = Record
      RESULT_PRACTICEID : Integer;
      RESULT_RECNUM      : Integer;
      RESULT_PARENT      : Integer;
      // RESULT_PARENTIS  : TResults_parentis;
      RESULT_RECD        : Char;
      RESULT_NEXT        : Integer;
      RESULT_PREV        : Integer;
      RESULT_SITE        : Byte;
      RESULT_GENERATION  : String[STRING_LENGTH_10];
      RESULT_LENGTH      : Integer;
      RESULT_DATA        : ResDataField;
  end;

  {
                Results_prefix = record
    Results_parent: Integer;
    Results_parentis: TResults_parentis;
    Results_next: Integer;
    Results_prev: Integer;
    Results_site: Byte;
    Results_recd: Char;
    Results_generation: Word;
    Results_length: Integer;
  end;

  Results_record = record
    Results_header: Results_prefix;
    Results_data: array[0..2047] of Char;
  end;  Results_record
     }

  // Aug 08, 2008
  // Price field size has been changed to 15
  // Inventory data
  PInventoryCode = ^TInventoryCode;
  TInventoryCode = Record
      TINVECODE_PRACTICEID    : Integer;
      TINVECODE_RECORDNUM     : Integer;
      TINVECODE_RECD          : Char;
      TINVECODE_CODE          : String[STRING_LENGTH_8];
      TINVECODE_CATEGORY      : String[STRING_LENGTH_8];
      TINVECODE_DESCRIPTION   : String[STRING_LENGTH_40];
      TINVECODE_CATEGORYNAME  : String[STRING_LENGTH_31];
      TINVECODE_PRICE         : String[STRING_LENGTH_15];
  end;

  // Treatment - Service text file
  PTreatCode = ^TTreatCode;
  TTreatCode = Record
      TREATCODE_PRACTICEID    : Integer;
      TREATCODE_RECORDNUM     : Integer;
      TREATCODE_RECD          : Char;
      TREATCODE_CODE          : String[STRING_LENGTH_8];
      TREATCODE_HEADER        : String[STRING_LENGTH_8];
      TREATCODE_DESCRIPTION   : String[STRING_LENGTH_40];
      TREATCODE_PRICE         : String[STRING_LENGTH_8];
      TREATCODE_CODES         : String[STRING_LENGTH_8];
      TREATCODE_CATEGORYNAME  : String[STRING_LENGTH_31];
  end;

  // old Service Code
  PServiceCode = ^TServiceCode;
  TServiceCode = Record
	    SERVICECODE_ID          : array[0..STRING_LENGTH_8] of char;    // 8
      SERVICECODE_CATEGORY    : Integer;  // 4 byte integer
      SERVICECODE_TYPE        : array[0..CATEGORY_NAME_MAX_LENGTH] of char;  // 31
      SERVICECODE_DESCRIPTION : array[0..STRING_LENGTH_40] of char;  // 40
      SERVICECODE_RECD        : Char;
      SERVICECODE_PRICE       : double;
      SERVICECODE_TRTCODES    : array[0..STRING_LENGTH_8] of char;      // 8
      SERVICECODE_RECORDNUM   : Integer;
      SERVICECODE_VACCINE     : array[0..STRING_LENGTH_8] of char; // Treatment_vaccine
  end;

  PServiceCode2 = ^TServiceCode2;
  TServiceCode2 = Record
    SERVICECODE_DATA : array[0..150] of char;
  End;

  // Pets
  PPetCode = ^TPetCode;
  TPetCode = Record
      PETCODE_PRACTICEID : Integer;
      PETCODE_RECORDNUM  : Integer;
      PETCODE_RECD       : Char;
      PETCODE_CLIENT     : String[STRING_LENGTH_7];
      PETCODE_NAME       : String[STRING_LENGTH_25];
      PETCODE_SPECIES    : String[STRING_LENGTH_8];
      PETCODE_BREED      : String[STRING_LENGTH_8];
      PETCODE_SEX        : String[STRING_LENGTH_2];
      PETCODE_CODES      : String[STRING_LENGTH_5];
      PETCODE_WEIGHT     : String[STRING_LENGTH_15];
      PETCODE_ADDEDDATE  : String[STRING_LENGTH_15];
      PETCODE_BIRTHDATE  : String[STRING_LENGTH_15];
      PETCODE_DEATHDATE  : String[STRING_LENGTH_15];
      PETCODE_PHOTO      : String[STRING_LENGTH_45];
      PETCODE_MICROCHIP  : String[STRING_LENGTH_15];
      PETCODE_RABTAG     : String[STRING_LENGTH_10];
      PETCODE_COLOR      : String[STRING_LENGTH_8];
      PETCODE_SUSPENDREM : String[STRING_LENGTH_15];
  end;

  // Invoices
  PInvoiceCode = ^TInvoiceCode;
  TInvoiceCode = Record
      INVOICECODE_PRACTICEID : Integer;
      INVOICECODE_RECORDNUM  : Integer;
      INVOICECODE_RECD       : Char;
      INVOICECODE_IANIMAL    : String[STRING_LENGTH_6];
      INVOICECODE_CODE       : String[STRING_LENGTH_8];
      INVOICECODE_TYPE       : String[STRING_LENGTH_2];
      INVOICECODE_DATE       : array[0..STRING_LENGTH_10] of char;
      INVOICECODE_DOCTOR     : array[0..STRING_LENGTH_4] of char;
      INVOICECODE_QTY        : array[0..STRING_LENGTH_6] of char;
      INVOICECODE_AMOUNT     : array[0..STRING_LENGTH_8] of char;
      INVOICECODE_CLIENT     : array[0..STRING_LENGTH_8] of char;
      INVOICECODE_NUMBER     : array[0..STRING_LENGTH_15] of char;
      INVOICECODE_DESC       : array[0..STRING_LENGTH_40] of char;
  end;

  // Reminder def
  PReminderCode = ^TReminderCode;
  TReminderCode = Record
      REMINDERCODE_PRACTICEID  : Integer;
      REMINDERCODE_RECORDNUM   : Integer;
      REMINDERCODE_RECD        : Char;
      REMINDERCODE_PARENT      : String[STRING_LENGTH_8];
      REMINDERCODE_CODE        : String[STRING_LENGTH_8];
      REMINDERCODE_DESCRIPTION : String[STRING_LENGTH_30];
      REMINDERCODE_DUEDATE     : String[STRING_LENGTH_15];
      REMINDERCODE_APPROPRIATE : String[STRING_LENGTH_3];
      REMINDERCODE_SUSPEND     : String[STRING_LENGTH_2];
  end;

  // Species records
  PSpeciesCode = ^TSpeciesCode;
  TSpeciesCode = Record
      SPECIESCODE_PRACTICE   : Integer;
      SPECIESCODE_RECD       : Char;
      SPECIESCODE_CODE       : String[STRING_LENGTH_8];
      SPECIESCODE_DECRIPTION : String[STRING_LENGTH_10];
  end;

  
  // Color records
  PColorCode = ^TColorCode;
  TColorCode = Record
      COLORCODE_PRACTICE   : Integer;
      COLORCODE_RECD       : Char;
      COLORCODE_CODE       : String[STRING_LENGTH_8];
      COLORCODE_DECRIPTION : String[STRING_LENGTH_40];
  end;

  // Breeds records
  PBreedCode = ^TBreedCode;
  TBreedCode = Record
      BREEDCODE_PRACTICE   : Integer;
      BREEDCODE_RECD       : Char;
      BREEDCODE_CODE       : String[STRING_LENGTH_8];
      BREEDCODE_DECRIPTION : String[STRING_LENGTH_40];
  end;

  // Entry records
  PEntryCode = ^TEntryCode;
  TEntryCode = Record
      ENTRYCODE_PRACTICE   : Integer;
      ENTRYCODE_RECD       : Char;
      ENTRYCODE_CODE       : String[STRING_LENGTH_8]; //array[0..STRING_LENGTH_8] of char;
      ENTRYCODE_BREED      : String[STRING_LENGTH_40];
      ENTRYCODE_COLOR      : String[STRING_LENGTH_40];
      ENTRYCODE_SPECIES    : String[STRING_LENGTH_10];
  end;

  // jan 14, 2009
  PWpCode = ^TWpCode;
  TWpCode = Record
    WPCODE_PRACTICE     : Integer;
    WPCODE_RECORDNUM    : Integer;
    WPCODE_SIZE         : Integer;
    WPCODE_PAR          : Integer;
    WPCODE_PARENT       : String[STRING_LENGTH_8];
    WPCODE_TEXT         : MemoField;
  end;

  // Jan 06, 2009
  // Med History
  PMedHistoryCode = ^TMedHistoryCode;
  TMedHistoryCode = Record
    MEDCODE_PRACTICE     : Integer;
    MEDCODE_RECORDNUM    : Integer;
    MEDCODE_RECD         : Char;
    MEDCODE_TYPE         : String[STRING_LENGTH_1];
    MEDCODE_POSTED       : String[STRING_LENGTH_1];
    MEDCODE_DATE         : String[STRING_LENGTH_10];
    MEDCODE_VACCINE      : String[STRING_LENGTH_6];
    MEDCODE_DOCTOR       : String[STRING_LENGTH_3];
    MEDCODE_DESCRIPTION  : String[STRING_LENGTH_40];
    MEDCODE_CODE         : String[STRING_LENGTH_8];
    MEDCODE_AMOUNT       : String[STRING_LENGTH_6];
    MEDCODE_QUANTITY     : String[STRING_LENGTH_3];
    MEDCODE_SOLDBY       : String[STRING_LENGTH_3];
    MEDCODE_RXFEES       : String[STRING_LENGTH_5];
    MEDCODE_INVOICE      : String[STRING_LENGTH_8];
    MEDCODE_ACCOUNT      : String[STRING_LENGTH_8];
    MEDCODE_PETID        : String[STRING_LENGTH_5];
    MEDCODE_ENTEREDBY    : String[STRING_LENGTH_3];
    MEDCODE_COMPANY      : String[STRING_LENGTH_3];
    MEDCODE_REFILLS      : String[STRING_LENGTH_2];
    MEDCODE_DOCTOR_INSTR : MemoField;
    MEDCODE_NOTE         : MemoField;
    // MEDCODE_FIRSTSHIP_DATE : ResDataField;
  end;

  // Jan 06, 2008
  // ScriptTemplate
  PScriptCode = ^TScriptCode;
  TScriptCode = Record
      SCRIPTCODE_PRACTICE     : Integer;
      SCRIPTCODE_RECORDNUM    : Integer;
      SCRIPTCODE_RECD         : Char;
      SCRIPTCODE_SERVICECODE  : String[STRING_LENGTH_8];
      SCRIPTCODE_CODES        : String[STRING_LENGTH_8];
      SCRIPTCODE_UOM          : String[STRING_LENGTH_6];
      SCRIPTCODE_REFILLEXP      : String[STRING_LENGTH_3];
      SCRIPTCODE_REFILLRESETTX  : String[STRING_LENGTH_8];
      SCRIPTCODE_REFILLWAIT     : String[STRING_LENGTH_3];
      SCRIPTCODE_INSTRUCTIONS : MemoField; // MemoField
      SCRIPTCODE_DOCUMENT     : MemoField;
  end;

  // Aug 08, 2008
  // a RECNUM field has been added
  // User type
  PUserCode = ^TUserCode;
  TUserCode = Record
      USERCODE_PRACTICEID  : Integer;
      USERCODE_RECNUM     : Integer;
      USERCODE_RECD       : Char;
      USERCODE_GROUP      : String[STRING_LENGTH_3];
      USERCODE_ID         : String[STRING_LENGTH_3];
      USERCODE_NAME       : String[STRING_LENGTH_30];
      USERCODE_STAFF      : String[STRING_LENGTH_3];
      USERCODE_CLASS      : String[STRING_LENGTH_30];
  end;

  type MemoFieldArray = array[1..20] of String[70];

  // Client type
  // Latest update: July 28-30, 2008
  // the company field is not coming correctly

  // Aug 08, 2008
  // Field Class is type String - 5
  // And field Company
  PClientCode = ^TClientCode;
  TClientCode = Record
      CLIENTCODE_PRACTICEID   : Integer;
      CLIENTCODE_RECORDNUM    : Integer;
      CLIENTCODE_RECD         : Char;
      CLIENTCODE_CLASS        : String[STRING_LENGTH_5];
	    CLIENTCODE_FIRST        : String[STRING_LENGTH_20];
      CLIENTCODE_LAST         : String[STRING_LENGTH_25];
      CLIENTCODE_ADDRESS      : String[STRING_LENGTH_25];
      CLIENTCODE_ADDRESS2     : String[STRING_LENGTH_25];
      CLIENTCODE_CITY         : String[STRING_LENGTH_20];
      CLIENTCODE_STATE        : String[STRING_LENGTH_2];
      CLIENTCODE_ZIP          : String[STRING_LENGTH_10];
      CLIENTCODE_AREA         : String[STRING_LENGTH_3];
      CLIENTCODE_PHONE        : String[STRING_LENGTH_8];
      CLIENTCODE_CODES        : String[STRING_LENGTH_8];
      CLIENTCODE_FLAGS        : String[STRING_LENGTH_2];
      CLIENTCODE_ADDED        : String[STRING_LENGTH_15];
      CLIENTCODE_BUSINESS     : String[STRING_LENGTH_20];
      CLIENTCODE_EMAIL        : String[STRING_LENGTH_85];
      CLIENTCODE_COMPANY      : String[STRING_LENGTH_3];
      // added today
      CLIENTCODE_SUSPEND_REM   : String[STRING_LENGTH_2];
      CLIENTCODE_SUSPEND_UNTIL : String[STRING_LENGTH_15];
  end;

  // Result Records
  ResultCodeEnumFunc = function(lpResultRec : PResultData;
                              dwCurrent     : LongInt;
                              dwRecordCount : Integer;
                              dwUserData    : LongInt): wordbool; stdcall;

  // WP Records
  WpCodeEnumFunc = function(lpStructInvoiceRec : PWpCode;
                              dwCurrent     : LongInt;
                              dwRecordCount : Integer;
                              dwUserData    : LongInt): wordbool; stdcall;

    // Invoice code
  MedHistoryCodeEnumFunc = function(lpStructInvoiceRec : PMedHistoryCode;
                              dwCurrent     : LongInt;
                              dwRecordCount : Integer;
                              dwUserData    : LongInt): wordbool; stdcall;

  // ScriptTemplate
  // Jan 06, 2008
  ScriptEnumFunc = function(lpScriptTemplateRec : PScriptCode;
                                  dwCurrent     : LongInt;
                                  dwRecordCount : Integer;
                                  dwUserData    : LongInt) : WordBool; stdcall;

  // Get Data Version
  DataVersionEnumFunc = function(lpStructDataRec : PDataVersion;
                                  dwCurrent     : LongInt;
                                  dwRecordCount : Integer;
                                  dwUserData    : LongInt): WordBool; stdcall;

  // added new separate codes
  // Color Code
  ColorCodeEnumFunc = function(lpStructColorRec : PColorCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  // Breed Code
  BreedCodeEnumFunc = function(lpStructBreedRec : PBreedCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  // Species Code
  SpeciesCodeEnumFunc = function(lpStructSpeciesRec : PSpeciesCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  // Invoice code
  InvoiceCodeEnumFunc = function(lpStructInvoiceRec : PInvoiceCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;
  // Inventory Code
  InvenCodeEnumFunc = function(lpStructInvRec : PInventoryCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  // TreatMent
  TreatCodeEnumFunc = function(lpStructTreatRec : PTreatCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;
  // Pets
  PetCodeEnumFunc = function(lpStructPetRec : PPetCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  // Reminder Code
  ReminderCodeEnumFunc = function(lpStructReminderRec : PReminderCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  // Entry Code
  EntryCodeEnumFunc = function(lpStructEntryRec : PEntryCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  UserCodeEnumFunc = function(lpStructUserRec : PUserCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  // Client Enum Function
  // function is pointing to Pointer not to Type
  ClientCodeEnumFunc = function(lpStructClientRec : PClientCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  ServiceCodeEnumFunc = function( lpStructServiceRec : PServiceCode;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

  ServiceCodeEnumFunc2 = function(lpStructServiceRec : PServiceCode2;
                              dwCurrent     : longint;
                              dwRecordCount : integer;
                              dwUserData    : longint): wordbool; stdcall;

implementation

end.
