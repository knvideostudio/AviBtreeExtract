// Created on: March 18, 2008

unit recReminder;

interface

uses  AVITyp,
      uaviTypes,
      uDefs;

function ExpReminders(  pContext : pointer;
                        sPracticeID : PChar;
                        enumFunc : ReminderCodeEnumFunc;
                        UserData : Integer;
                        dtReminderStartDate: AnsiString;
                        dtReminderEndDate: AnsiString) : boolean;

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

function ExpReminders(pContext  : pointer;
                    sPracticeID : PChar;
                    enumFunc : ReminderCodeEnumFunc;
                    UserData : Integer;
                    dtReminderStartDate: AnsiString;
                    dtReminderEndDate: AnsiString) : boolean;

var
    totalRecs   : Longint;
    current     : Longint;
    filePath    : String;
    userAborted : Boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath + '\PROC.VM$';
    totalRecs   := GetRecordCount(filePath, sizeof(Reminder_record));

    current     := 0;
    userAborted := false;

    ExtractData.GetCurrentReminders(context^, enumFunc,
                          sPracticeID,
                          totalRecs,
                          current,
                          userData,
                          userAborted,
                          dtReminderStartDate,
                          dtReminderEndDate);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,  'Reminders Data', Context.PullType);
         Result := false;
    end;
  end
end;


end.
