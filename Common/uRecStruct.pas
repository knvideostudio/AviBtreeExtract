unit uRecStruct;

interface

type
  TExtractRec = record
    AVIPath : Array [0..255] of Char;
    AppPath : Array [0..255] of Char;
    PracticeID : Array [0..255] of Char;
    StartDate : Array [0..25] of Char;
    EndDate : Array [0..25] of Char;
    ReminderStartDate : Array [0..25] of Char;
    ReminderEndDate : Array [0..25] of Char;
    Password : longint;
    Options : Array [0..255] of Char;
    Tables : Array [0..255] of Char;
  End;

  TServiceCodeRec = record
    AVIPath : Array [0..255] of Char;
    Password : longint;
    UserData : longint;
  End;

implementation

end.



