// Created on: March 12, 2008
// Time 12:59
// Modified on: August 08, 2008
// Client_Class must be INTEGER

unit recClient;

interface

uses  uDefs;

{
Data comes from two tables:

CLIENT.VM$
}

// Declaration of Function and Procedures
function ExpClients(  pContext : pointer;
                      enumFunc : ClientCodeEnumFunc;
                      sPracticeID : PChar;
                      UserData : Integer) : boolean;

procedure GetCurrentClients(var Context     : TExtractContext;
                     enumFunc        : ClientCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : longint;
                     var current     : longint;
                     userData        : longint;
                     var userAborted : boolean);


const
  FLD_DELIM = '|';


implementation

uses  SysUtils,
      Classes,
      AVITyp,
      uAVITypes,
      Utils,
      ExtractData;

function ExpClients(  pContext  : pointer;
                      enumFunc : ClientCodeEnumFunc;
                      sPracticeID : PChar;
                      UserData : Integer) : boolean;

var
    totalRecs   : longint;
    current     : longint;
    filePath    : string;
    userAborted : boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath + '\CLIENT.VM$';

  //  LogStr('ExpClients: ' + filePath);

    totalRecs   := GetRecordCount(filePath, sizeof(Client_record));

 //   LogStr('ExpClients: ' + IntToStr(totalRecs));

    current     := 0;
    userAborted := false;

    GetCurrentClients(context^, enumFunc, sPracticeID, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message, 'Client Data', Context.PullType);
         Result := false;
    end;
  end
end;

procedure GetCurrentClients(var Context     : TExtractContext;
                     enumFunc        : ClientCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  FStream        : TStream;
  Estream        : TStream;
  FClientRecord  : Client_record;
  fName          : String;
  exportRec      : TClientCode;
  flagstr        : String;
  mail           : Integer;
  email          : String;
  strSuspendUntilDate   : String;

begin
  if (userAborted) then exit;
  try

    ResetCounts(Context);

    fName    := Context.FilePath + '\CLIENT.VM$';

   // LogStr('GetCurrentClients: ' + fName);
    FStream  := CreateInputStream(fName);

    fName    := Context.DataFldr + 'Data\PHRASE.VM$';
    // LogStr('GetCurrentClients: ' + fName);
    EStream  := CreateInputStream(fName);

    try
      while (FStream.Position < FStream.Size) do
      begin

        Inc(Context.nCount);
        StreamRead(FStream, FClientRecord, SizeOf(Client_record));

        if (FClientRecord.Client_recd = 'D') or
           (FClientRecord.Client_recd = 'A') then
        begin

          FillChar(exportRec, sizeof(exportRec), 0);

          exportRec.CLIENTCODE_PRACTICEID := StrToInt(sPracticeID);
          exportRec.CLIENTCODE_RECORDNUM := context.nCount;
          exportRec.CLIENTCODE_RECD := FClientRecord.Client_recd;
          exportRec.CLIENTCODE_CLASS := IntToStr(FClientRecord.Client_class);
          exportRec.CLIENTCODE_FIRST := FClientRecord.Client_first;
          exportRec.CLIENTCODE_LAST := FClientRecord.Client_last;
          exportRec.CLIENTCODE_ADDRESS := FClientRecord.Client_address;
          exportRec.CLIENTCODE_ADDRESS2 := FClientRecord.Client_address2;
          exportRec.CLIENTCODE_CITY := FClientRecord.Client_city;
          exportRec.CLIENTCODE_STATE := FClientRecord.Client_state;
          exportRec.CLIENTCODE_ZIP := FClientRecord.Client_zip;
          exportRec.CLIENTCODE_AREA := FClientRecord.Client_area;
          exportRec.CLIENTCODE_PHONE := FClientRecord.Client_phone;
          exportRec.CLIENTCODE_CODES := FClientRecord.Client_codes;
          flagstr := '';
          exportRec.CLIENTCODE_FLAGS := '0';
          exportRec.CLIENTCODE_ADDED := DateToStr(AVIDateToDateTime(FClientRecord.Client_added));
          exportRec.CLIENTCODE_BUSINESS := FClientRecord.Client_business;

         // Reading Email Codes from Phase data file
          mail := FClientRecord.Client_email;
          if mail > 0 then
            email := StreamReadString(Estream, mail - 1)
          else
            email := IntToStr(mail);
            
          exportRec.CLIENTCODE_EMAIL := email;
          // end reading emails

          exportRec.CLIENTCODE_COMPANY := IntToStr(FClientRecord.Client_company);

         // Suspend BOOLEAN
         exportRec.CLIENTCODE_SUSPEND_REM := BoolToStr(FClientRecord.Client_suspend);

         // Suspend UNTIL Date
         strSuspendUntilDate := '';
          if FClientRecord.Client_until <> 0 then
            strSuspendUntilDate := DateToStr(AVIDateToDateTime(FClientRecord.Client_until))
          else
            strSuspendUntilDate := TimeToStr(FClientRecord.Client_until);

         exportRec.CLIENTCODE_SUSPEND_UNTIL :=  strSuspendUntilDate;
         // End UNTIL Date

         if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false

          Inc(context.wrCount);
        end; // end D or A
      end;  // while

    finally
      FStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message, 'GetCurrentClients' , Context.PullType);
    end;
end;

end.
