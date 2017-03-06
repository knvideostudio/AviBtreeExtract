// Created on: March 19, 2008

unit recTreatment;

interface

uses  uDefs;

{
Data comes from two tables:
}

// Declaration of Function and Procedures
function ExpTreat(  pContext : pointer;
                    enumFunc : TreatCodeEnumFunc;
                    sPracticeID     : PChar;
                    UserData : Integer) : boolean;

procedure GetCurrentTreat(var Context     : TExtractContext;
                     enumFunc        : TreatCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : longint;
                     var current     : longint;
                     userData        : longint;
                     var userAborted : boolean);
// end declaration

const
  FLD_DELIM = '|';

implementation

uses  SysUtils,
      Classes,
      AVITyp,
      uAVITypes,
      Utils,
      ExtractData;


function ExpTreat(  pContext    : pointer;
                    enumFunc    : TreatCodeEnumFunc;
                    sPracticeID : PChar;
                    UserData    : Integer) : boolean;
var
    totalRecs   : LongInt;
    current     : LongInt;
    filePath    : String;
    userAborted : Boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath + '\TREAT.VM$';

    LogStr('ExpTreat: ' + filePath);
    totalRecs   := GetRecordCount(filePath, sizeof(Treatment_record));

    LogStr('ExpTreat: ' + IntToStr(totalRecs));

    current     := 0;
    userAborted := false;

    GetCurrentTreat(context^, enumFunc, sPracticeID, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message, 'Treat Data', Context.PullType);
         Result := false;
    end;
  end
end;

procedure GetCurrentTreat(var Context     : TExtractContext;
                     enumFunc        : TreatCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  FStream       : TStream;
  TrRecord      : Treatment_record;
  FHeaderRec    : Header_record;
  fName         : String;
  exportRec     : TTreatCode;
  FSearchStream : TFileStream;
  sHeader_Category : String;
  nSearchSize   : LongInt;
  dMidAmount    : Double;
  sHeaderFName  : String;
begin

  if (userAborted) then exit;

  try
    ResetCounts(context);

    fName    := Context.FilePath + '\TREAT.VM$';

    // LogStr('GetCurrentTreat: ' + fName);
    FStream  := CreateInputStream(fName);

    try
      sHeaderFName    := Context.DataFldr + 'Data\HEADER.VM$';
      // LogStr('GetCurrentTreat: ' + sHeaderFName);

      nSearchSize := GetRecordCount(sHeaderFName, SizeOf(Header_record));

      FSearchStream := TFileStream.Create(sHeaderFName, fmOpenRead or fmShareDenyNone);
      
      try
         while (FStream.Position < FStream.Size) do
         begin
            Inc(context.nCount);
            StreamRead(FStream, TrRecord, SizeOf(Treatment_record));

             if (TrRecord.Treatment_recd = 'D') or
                (TrRecord.Treatment_recd = 'A') then
             begin

                sHeader_Category := '';

                if TrRecord.Treatment_header <= nSearchSize then
                begin
                //Searching the category Name in Header based on Treatment_header
                  FSearchStream.Position := (TrRecord.Treatment_header - 1) * SizeOf(Header_record);
                  FSearchStream.Read(FHeaderRec, SizeOf(Header_record));

                  if (FHeaderRec.Header_name <> '') then
                    sHeader_Category := FHeaderRec.Header_name;
                end;

                FillChar(exportRec, sizeof(exportRec), 0);

                // adding data to Records
                exportRec.TREATCODE_PRACTICEID := StrToInt(sPracticeID);
                exportRec.TREATCODE_RECORDNUM := context.nCount;
                exportRec.TREATCODE_RECD  := TrRecord.Treatment_recd;
                exportRec.TREATCODE_CODE  := TrRecord.Treatment_code;
                exportRec.TREATCODE_HEADER := IntToStr(TrRecord.Treatment_header);
                exportRec.TREATCODE_DESCRIPTION := TrRecord.Treatment_description;

                // sPrice := FormatFloat('0.00',dMidAmount)
                dMidAmount := 0;
                dMidAmount := TrRecord.Treatment_price / 100;

                exportRec.TREATCODE_PRICE := FormatFloat('0.00', dMidAmount);
                exportRec.TREATCODE_CODES := TrRecord.Treatment_codes;
                exportRec.TREATCODE_CATEGORYNAME := sHeader_Category;

               if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
                begin
                  userAborted := true;
                  break;
               end; // end if false
            end; // end D or A
          end;  // while
     finally
      FSearchStream.Free;
     end;
  finally
      FStream.Free;
  end;

except
    on E:Exception do
        writeExcept(E.Message, 'GetCurrentTreat', Context.PullType);
    end;
end;

end.
