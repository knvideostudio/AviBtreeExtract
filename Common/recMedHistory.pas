// ----------------------------------------------------
// Created on: Jan 06, 2009
// Med History
// Created by: Krassimir
// ----------------------------------------------------

unit recMedHistory;

interface

uses  AVITyp,
      uaviTypes,
      uDefs;

function ExptMedHistory(  pContext : pointer;
                        sPracticeID : PChar;
                        enumFunc : MedHistoryCodeEnumFunc;
                        UserData : Integer;
                        dtStartDate: AnsiString): Boolean;

const
  DELIMETER   : String = '\';
  FILE_NAME   : String = 'SERVICE.VM$';

implementation

uses  SysUtils,
      Classes,
      Utils,
      ExtractData,
      Filer,
      BTIsBase,
      NumKey32;

function ExptMedHistory(pContext  : pointer;
                    sPracticeID : PChar;
                    enumFunc : MedHistoryCodeEnumFunc;
                    UserData : Integer;
                    dtStartDate: AnsiString): Boolean;

var
    totalRecs   : LongInt;
    current     : LongInt;
    filePath    : String;
    userAborted : Boolean;
    Context     : PExtractContext;

begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath + DELIMETER + FILE_NAME;
    totalRecs   := GetRecordCount(filePath, sizeof(Service_record));

    current     := 0;
    userAborted := false;

   ExtractData.GetCurrentMedHistory(context^, enumFunc,
                          sPracticeID,
                          totalRecs,
                          current,
                          userData,
                          userAborted,
                          dtStartDate);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,  'Med History Data', Context.PullType);
         Result := false;
    end;
  end
end;

end.
