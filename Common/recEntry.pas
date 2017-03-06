// Created on: March 12, 2008
// Time 12:59

unit recEntry;

interface

uses  uDefs;

{
Data comes from two tables:


}

// Declaration of Function and Procedures
// Breed
function ExportBreedEntity( pContext : pointer;
                            enumFunc : BreedCodeEnumFunc;
                            sPracticeID : PChar;
                            UserData : Integer) : boolean;

// Species
function ExportSpeciesEntity( pContext : pointer;
                              enumFunc : SpeciesCodeEnumFunc;
                              sPracticeID : PChar;
                              UserData : Integer) : boolean;

// Color
function ExportColorEntity( pContext : pointer;
                            enumFunc : ColorCodeEnumFunc;
                            sPracticeID : PChar;
                            UserData : Integer) : boolean;

procedure GetBreedEntry(var Context     : TExtractContext;
                     enumFunc        : EntryCodeEnumFunc;
                     totalRecs       : longint;
                     var current     : longint;
                     sPracticeID     : PChar;
                     userData        : longint;
                     var userAborted : boolean);

procedure GetColorEntry(var Context     : TExtractContext;
                     enumFunc        : EntryCodeEnumFunc;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     sPracticeID     : PChar;
                     userData        : LongInt;
                     var userAborted : boolean);

procedure GetSpeciesEntry(var Context     : TExtractContext;
                     enumFunc        : EntryCodeEnumFunc;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     sPracticeID     : PChar;
                     userData        : LongInt;
                     var userAborted : boolean);

// New declaration Separate classes
// May 07, 2008

// Species separate
procedure GetSpeciesData(var Context : TExtractContext;
                     enumFunc        : SpeciesCodeEnumFunc;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     sPracticeID     : PChar;
                     userData        : LongInt;
                     var userAborted : Boolean);

// Color separate
procedure GetColorData(var Context   : TExtractContext;
                     enumFunc        : ColorCodeEnumFunc;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     sPracticeID     : PChar;
                     userData        : LongInt;
                     var userAborted : Boolean);

// Breeds separate
procedure GetBreedData(var Context   : TExtractContext;
                     enumFunc        : BreedCodeEnumFunc;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     sPracticeID     : PChar;
                     userData        : LongInt;
                     var userAborted : Boolean);

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

// Species entity
function ExportSpeciesEntity(pContext  : pointer;
                    enumFunc : SpeciesCodeEnumFunc;
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
    filePath    := Context.FilePath + '\ENTRY.VM$';
    totalRecs   := GetRecordCount(filePath, sizeof(Entry_record));

    current     := 0;
    userAborted := false;

    GetSpeciesData(context^, enumFunc, totalRecs, current, sPracticeID, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,'Species Data',Context.PullType);
         Result := false;
    end;
  end
end;

// new procedure
// May 07, 2008

// Colors
// Color
procedure GetColorData(var Context   : TExtractContext;
                     enumFunc        : ColorCodeEnumFunc;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     sPracticeID     : PChar;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  FStream        : TStream;
  FEntryRecord   : Entry_record;
  fName          : String;
  exportColorRec : TColorCode;

  // sub Procedure   *********************************************************
    procedure DisplayColor();
      begin

       FillChar(exportColorRec, sizeof(exportColorRec), 0);

       exportColorRec.COLORCODE_PRACTICE    := StrToInt(sPracticeID);
       exportColorRec.COLORCODE_RECD        := FEntryRecord.Entry_recd;
       exportColorRec.COLORCODE_CODE        := FEntryRecord.Entry_code;
       exportColorRec.COLORCODE_DECRIPTION  := FEntryRecord.Entry_data.Entry_description;

    end;
  // end
begin
  if (userAborted) then exit;

  try
    ResetCounts(context);

    fName   := Context.FilePath + '\ENTRY.VM$';
    FStream := CreateInputStream(fName);

    try
      while (FStream.Position < FStream.Size) do
      begin
        StreamRead(FStream, FEntryRecord, SizeOf(Entry_record));

        // Begin Color
        if (FEntryRecord.Entry_recd = 'A') and
          (FEntryRecord.Entry_table = 3 ) then
        begin

         DisplayColor();

         if (false = enumFunc(@exportColorRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false
        end; // end Color
      end;  // while
     finally
      FStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message,fName, Context.PullType);
    end;
end;
// end Colors

// Breeds
procedure GetBreedData(var Context   : TExtractContext;
                     enumFunc        : BreedCodeEnumFunc;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     sPracticeID     : PChar;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  FStream        : TStream;
  FEntryRecord   : Entry_record;
  fName          : String;
  exportBreedRec : TBreedCode;

  // sub Procedure   *********************************************************
    procedure DisplayBreed();
      begin

       FillChar(exportBreedRec, sizeof(exportBreedRec), 0);

       exportBreedRec.BREEDCODE_PRACTICE    := StrToInt(sPracticeID);
       exportBreedRec.BREEDCODE_RECD        := FEntryRecord.Entry_recd;
       exportBreedRec.BREEDCODE_CODE        := FEntryRecord.Entry_code;
       exportBreedRec.BREEDCODE_DECRIPTION  :=  FEntryRecord.Entry_data.Entry_breed;

    end;
 // sub Procedure   *********************************************************
begin
  if (userAborted) then exit;
  try
    ResetCounts(context);

    fName   := Context.FilePath + '\ENTRY.VM$';
    FStream := CreateInputStream(fName);

    try
      while (FStream.Position < FStream.Size) do
      begin
        StreamRead(FStream, FEntryRecord, SizeOf(Entry_record));

      // Begin Breed
        if (FEntryRecord.Entry_recd = 'A') and
          (FEntryRecord.Entry_table = 4 ) then
        begin

         DisplayBreed();

         if (false = enumFunc(@exportBreedRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false
        end; // end Breed
      end;  // while

    finally
      FStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message, fName, Context.PullType);
    end;
end;
// end Breeds DATA

// Species
procedure GetSpeciesData(var Context : TExtractContext;
                     enumFunc        : SpeciesCodeEnumFunc;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     sPracticeID     : PChar;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  FStream        : TStream;
  FEntryRecord   : Entry_record;
  fName          : String;
  exportSpecRec  : TSpeciesCode;

  // sub Procedure   *********************************************************
    procedure DisplaySpec();
     begin

       FillChar(exportSpecRec, sizeof(exportSpecRec), 0);

       exportSpecRec.SPECIESCODE_PRACTICE   := StrToInt(sPracticeID);
       exportSpecRec.SPECIESCODE_RECD       := FEntryRecord.Entry_recd;
       exportSpecRec.SPECIESCODE_CODE       := FEntryRecord.Entry_code;
       exportSpecRec.SPECIESCODE_DECRIPTION := FEntryRecord.Entry_data.Entry_description;

     end;
 // sub Procedure   *********************************************************
begin
  if (userAborted) then exit;

  try
    ResetCounts(context);

    fName   := Context.FilePath + '\ENTRY.VM$';
    FStream := CreateInputStream(fName);

    try
      while (FStream.Position < FStream.Size) do
      begin
        StreamRead(FStream, FEntryRecord, SizeOf(Entry_record));

      // Begin Species
        if (FEntryRecord.Entry_recd = 'A') and
          (FEntryRecord.Entry_table = 9 ) then
        begin

         DisplaySpec();

         if (false = enumFunc(@exportSpecRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false
        end; // end Breed
      end;  // while

    finally
      FStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message, fName, Context.PullType);
    end;
end;
// end species old version

// Species
procedure GetSpeciesEntry(var Context     : TExtractContext;
                     enumFunc        : EntryCodeEnumFunc;
                     totalRecs       : longint;
                     var current     : longint;
                     sPracticeID     : PChar;
                     userData        : longint;
                     var userAborted : boolean);

var
  FStream        : TStream;
  FEntryRecord   : Entry_record;
  fName          : String;
  rCount         : longint;
  exportSpecRec  : TEntryCode;

  // sub Procedure   *********************************************************
    procedure DisplaySpec();
     begin

       FillChar(exportSpecRec, sizeof(exportSpecRec), 0);
       rCount := rCount + 1;

       exportSpecRec.ENTRYCODE_PRACTICE := StrToInt(sPracticeID);
       // exportSpecRec.ENTRYCODE_RECORDNUM :=  rCount;
       exportSpecRec.ENTRYCODE_RECD := FEntryRecord.Entry_recd;
       exportSpecRec.ENTRYCODE_CODE := FEntryRecord.Entry_code;
       exportSpecRec.ENTRYCODE_SPECIES :=  FEntryRecord.Entry_data.Entry_description;
     end;
 // sub Procedure   *********************************************************
begin
  if (userAborted) then exit;
  try
    rCount  := 0;
    ResetCounts(context);

    fName   := Context.FilePath + '\ENTRY.VM$';
    FStream := CreateInputStream(fName);

    try
      while (FStream.Position < FStream.Size) do
      begin
        StreamRead(FStream, FEntryRecord, SizeOf(Entry_record));

      // Begin Species
        if (FEntryRecord.Entry_recd = 'A') and
          (FEntryRecord.Entry_table = 9 ) then
        begin

         DisplaySpec();

         if (false = enumFunc(@exportSpecRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false
        end; // end Breed
      end;  // while

    finally
      FStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message, fName, Context.PullType);
    end;
end;

// End SPECIES SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
function ExportBreedEntity(pContext  : pointer;
                    enumFunc : BreedCodeEnumFunc;
                    sPracticeID : PChar;
                    UserData : Integer) : boolean;

var
    totalRecs   : LongInt;
    current     : LongInt;
    filePath    : String;
    userAborted : Boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath + '\ENTRY.VM$';
    totalRecs   := GetRecordCount(filePath, sizeof(Entry_record));

    current     := 0;
    userAborted := false;

    // GetBreedEntry(context^, enumFunc, totalRecs, current, sPracticeID, userData, userAborted);
    GetBreedData(context^, enumFunc, totalRecs, current, sPracticeID, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,'Breed Data',Context.PullType);
         Result := false;
    end;
  end
end;

// Breed
procedure GetBreedEntry(var Context     : TExtractContext;
                     enumFunc        : EntryCodeEnumFunc;
                     totalRecs       : longint;
                     var current     : longint;
                     sPracticeID     : PChar;
                     userData        : longint;
                     var userAborted : boolean);

var
  FStream        : TStream;
  FEntryRecord   : Entry_record;
  fName          : String;
  rCount         : longint;
  exportBreedRec : TEntryCode;

  // sub Procedure   *********************************************************
    procedure DisplayBreed();
      begin

       FillChar(exportBreedRec, sizeof(exportBreedRec), 0);
       rCount := rCount + 1;

       exportBreedRec.ENTRYCODE_PRACTICE := StrToInt(sPracticeID);
      // exportBreedRec.ENTRYCODE_RECORDNUM :=  rCount;
       exportBreedRec.ENTRYCODE_RECD := FEntryRecord.Entry_recd;
       exportBreedRec.ENTRYCODE_CODE := FEntryRecord.Entry_code;
       exportBreedRec.ENTRYCODE_BREED :=  FEntryRecord.Entry_data.Entry_breed;

    end;
 // sub Procedure   *********************************************************
begin
  if (userAborted) then exit;
  try
    rCount  := 0;
    ResetCounts(context);

    fName   := Context.FilePath + '\ENTRY.VM$';
    FStream := CreateInputStream(fName);

    try
      while (FStream.Position < FStream.Size) do
      begin
        StreamRead(FStream, FEntryRecord, SizeOf(Entry_record));

      // Begin Breed
        if (FEntryRecord.Entry_recd = 'A') and
          (FEntryRecord.Entry_table = 4 ) then
        begin

         DisplayBreed();

         if (false = enumFunc(@exportBreedRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false
        end; // end Breed
      end;  // while

    finally
      FStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message, fName, Context.PullType);
    end;
end;

    {
    ))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
    Table Entry
       case FEntryRecord.Entry_table of
       3 : AddColor();
       4 : DisplayBreed();
       9 : AddSpecies();
    end;   }

function ExportColorEntity(pContext  : pointer;
                    enumFunc : ColorCodeEnumFunc;
                    sPracticeID : PChar;
                    UserData : Integer) : boolean;

var
    totalRecs   : LongInt;
    current     : LongInt;
    filePath    : String;
    userAborted : Boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath + '\ENTRY.VM$';
    totalRecs   := GetRecordCount(filePath, sizeof(Entry_record));

    current     := 0;
    userAborted := false;

    GetColorData(context^, enumFunc, totalRecs, current, sPracticeID, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,'Color Data',Context.PullType);
         Result := false;
    end;
  end
end;

// Color
procedure GetColorEntry(var Context     : TExtractContext;
                     enumFunc        : EntryCodeEnumFunc;
                     totalRecs       : longint;
                     var current     : longint;
                     sPracticeID     : PChar;
                     userData        : longint;
                     var userAborted : boolean);

var
  FStream        : TStream;
  FEntryRecord   : Entry_record;
  fName          : String;
  rCount         : longint;
  exportColorRec : TEntryCode;

  // sub Procedure   *********************************************************
    procedure DisplayColor();
      begin

       FillChar(exportColorRec, sizeof(exportColorRec), 0);
       rCount := rCount + 1;

       exportColorRec.ENTRYCODE_PRACTICE := StrToInt(sPracticeID);
      // exportColorRec.ENTRYCODE_RECORDNUM :=  rCount;
       exportColorRec.ENTRYCODE_RECD := FEntryRecord.Entry_recd;
       exportColorRec.ENTRYCODE_CODE := FEntryRecord.Entry_code;
       exportColorRec.ENTRYCODE_COLOR := FEntryRecord.Entry_data.Entry_description;

    end;
  // end
begin
  if (userAborted) then exit;
  try
    rCount  := 0;
    ResetCounts(context);

    fName   := Context.FilePath + '\ENTRY.VM$';
    FStream := CreateInputStream(fName);

    try
      while (FStream.Position < FStream.Size) do
      begin
        StreamRead(FStream, FEntryRecord, SizeOf(Entry_record));

        // Begin Color
        if (FEntryRecord.Entry_recd = 'A') and
          (FEntryRecord.Entry_table = 3 ) then
        begin

         DisplayColor();

         if (false = enumFunc(@exportColorRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false
        end; // end Color
      end;  // while
     finally
      FStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message,fName, Context.PullType);
    end;
end;

end.
