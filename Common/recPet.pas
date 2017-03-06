// Created on: March 21, 2008
// Return Pets Records

unit recPet;

interface

uses  AVITyp,
      uaviTypes,
      uDefs;

// Declaration of Function and Procedures
function ExpPet(pContext : pointer;
                        sPracticeID : PChar;
                        enumFunc : PetCodeEnumFunc;
                        UserData : Integer) : boolean;

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

function ExpPet(pContext  : pointer;
                    sPracticeID : PChar;
                    enumFunc : PetCodeEnumFunc;
                    UserData : Integer) : Boolean;
var
    totalRecs   : LongInt;
    current     : LongInt;
    filePath    : String;
    userAborted : Boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath + '\ANIMAL.VM$';
    totalRecs   := GetRecordCount(filePath, sizeof(Animal_record));

    current     := 0;
    userAborted := false;

    ExtractData.GetCurrentPets(context^,
                          enumFunc,
                          sPracticeID,
                          totalRecs,
                          current,
                          userData,
                          userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,  'Pets Data', Context.PullType);
         Result := false;
    end;
  end
end;


end.
