// Created on: March 20, 2008
// Return Invoice Records
// Modified: Aug 08, 2008
// invoice number is not correct


unit recInvoice;

interface

uses  AVITyp,
      uaviTypes,
      uDefs;

// Declaration of Function and Procedures
function ExpInvoice(  pContext : pointer;
                        sPracticeID : PChar;
                        enumFunc : InvoiceCodeEnumFunc;
                        UserData : Integer;
                        dtStartDate: AnsiString;
                        dtEndDate: AnsiString) : boolean;

const
  FLD_DELIM = '|';

implementation

uses  SysUtils,
      Classes,
      Utils,
      ExtractData,
      Filer,
      BTIsBase,
      NumKey32;

function ExpInvoice(pContext  : pointer;
                    sPracticeID : PChar;
                    enumFunc : InvoiceCodeEnumFunc;
                    UserData : Integer;
                    dtStartDate: AnsiString;
                    dtEndDate: AnsiString) : boolean;

var
    totalRecs   : Longint;
    current     : Longint;
    filePath    : String;
    userAborted : Boolean;
    Context     : PExtractContext;

begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath + '\ACCOUNT.VM$';
    totalRecs   := GetRecordCount(filePath, sizeof(Reminder_record));

    current     := 0;
    userAborted := false;

    ExtractData.GetCurrentInvoices(context^, enumFunc,
                          sPracticeID,
                          totalRecs,
                          current,
                          userData,
                          userAborted,
                          dtStartDate,
                          dtEndDate);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,  'Invoices Data', Context.PullType);
         Result := false;
    end;
  end
end;


end.
