// Created on: Feb 23, 2009 - 10:30

unit recResult;

interface

uses  uDefs;

{
  Data comes from two B-TREE table :
  RESULTS.VM$
}

// Declaration of Function and Procedures
function ExpResults(  pContext : pointer;
                      enumFunc : ResultCodeEnumFunc;
                      sPracticeID : PChar;
                      UserData : Integer) : Boolean;

procedure GetResults(var Context     : TExtractContext;
                     enumFunc        : ResultCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);


const
  FLD_DELIM = '\';
  FILE_NAME = 'RESULTS.VM$';


implementation

uses  SysUtils,
      Classes,
      AVITyp,
      uAVITypes,
      Utils,
      ExtractData;

function ExpResults(  pContext    : pointer;
                      enumFunc    : ResultCodeEnumFunc;
                      sPracticeID : PChar;
                      UserData    : Integer) : Boolean;

var
    totalRecs   : LongInt;
    current     : LongInt;
    filePath    : String;
    userAborted : Boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  Try
    filePath    := Context.FilePath + FLD_DELIM + FILE_NAME;
    totalRecs   := GetRecordCount(filePath, sizeof(Results_record));

    current     := 0;
    userAborted := false;

    GetResults(context^, enumFunc, sPracticeID, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message, 'Results Data', Context.PullType);
         Result := false;
    end;
  end
end;

// Actual procedure
// get results
procedure GetResults(var Context     : TExtractContext;
                     enumFunc        : ResultCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  FRecord        : Results_record;
  exportRec      : TResultData;
  FStream        : TStream;
  GenDate        : TDateTime;
  fName          : String;
begin
  if (userAborted) then exit;

  Try

    ResetCounts(Context);

    fName    := Context.FilePath + FLD_DELIM + FILE_NAME;
    FStream  := CreateInputStream(fName);

    Try
      while (FStream.Position < FStream.Size) do
      begin

        Inc(Context.nCount);
        StreamRead(FStream, FRecord, SizeOf(Results_record));

       // if (FRecord.Results_header.Results_recd = 'D') or
       //    (FRecord.Results_header.Results_recd = 'A') then
      //  begin

          FillChar(exportRec, sizeof(exportRec), 0);

          exportRec.RESULT_PRACTICEID := StrToInt(sPracticeID);
          exportRec.RESULT_RECNUM := Context.nCount;
          exportRec.RESULT_PARENT := FRecord.Results_header.Results_parent;
          exportRec.RESULT_RECD   := FRecord.Results_header.Results_recd;
          exportRec.RESULT_NEXT   := FRecord.Results_header.Results_next;
          exportRec.RESULT_PREV   := FRecord.Results_header.Results_prev;

          exportRec.RESULT_SITE   := FRecord.Results_header.Results_site;
          
          GenDate := FRecord.Results_header.Results_generation;
          exportRec.RESULT_GENERATION := DateToStr(GenDate);

          exportRec.RESULT_LENGTH   := FRecord.Results_header.Results_length;

          // export the big data as chunks
          LogStr(FRecord.Results_data);
          StrPCopy(exportRec.RESULT_DATA, FRecord.Results_data);

        //  exportRec.CLIENTCODE_PRACTICEID := StrToInt(sPracticeID);
        //  exportRec.CLIENTCODE_RECORDNUM := context.nCount;
         // exportRec.CLIENTCODE_RECD := FClientRecord.Client_recd;
         // exportRec.CLIENTCODE_CLASS := IntToStr(FClientRecord.Client_class);
        //  exportRec.CLIENTCODE_FIRST := FClientRecord.Client_first;
        //  exportRec.CLIENTCODE_LAST := FClientRecord.Client_last;
       //   exportRec.CLIENTCODE_ADDRESS := FClientRecord.Client_address;
      //    exportRec.CLIENTCODE_ADDRESS2 := FClientRecord.Client_address2;
       //   exportRec.CLIENTCODE_CITY := FClientRecord.Client_city;

       //  exportRec.CLIENTCODE_ADDED := DateToStr(AVIDateToDateTime(FClientRecord.Client_added));
       //  exportRec.CLIENTCODE_BUSINESS := FClientRecord.Client_business;

         if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false

          Inc(context.wrCount);
       // end; // end D or A
      end;  // while

    finally
      FStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message, 'NEW Get Results' , Context.PullType);
    end;
end;

end.
