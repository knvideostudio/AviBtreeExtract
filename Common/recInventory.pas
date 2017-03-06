// Created on: March 19, 2008
///////////////////////////////////////////////////////////////////////
// Aug 08, 2008
// price is not correct
// record number is out of sync

unit recInventory;

interface

uses  uDefs;

{
 //////////////////////////////////////////////////////////////////////////////
}

// Declaration of Function and Procedures
function ExpMyItem( pContext : pointer;
                    enumFunc : InvenCodeEnumFunc;
                    sPracticeID : PChar;
                    UserData : Integer) : boolean;

procedure GetCurrentMyItem(var Context     : TExtractContext;
                     enumFunc        : InvenCodeEnumFunc;
                     sPracticeID : PChar;
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


function ExpMyItem( pContext    : pointer;
                    enumFunc    : InvenCodeEnumFunc;
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
    filePath    := Context.FilePath + '\ITEM.VM$';
    totalRecs   := GetRecordCount(filePath, sizeof(Item_record));

    current     := 0;
    userAborted := false;

    GetCurrentMyItem(context^, enumFunc, sPracticeID, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message, 'Inventory Data', Context.PullType);
         Result := false;
    end;
  end
end;

procedure GetCurrentMyItem(var Context : TExtractContext;
                     enumFunc        : InvenCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  FStream       : TStream;
  FItemRecord   : Item_record;
  FCategoryRec  : Category_record;
  fName         : String;
  exportRec     : TInventoryCode;
  FSearchStream : TFileStream;
  sItemCategory : String;
  nSearchSize   : LongInt;
  dMidAmount    : Double;
  sCategoryFname  : String;
begin

  if (userAborted) then exit;
  try
    ResetCounts(context);

    fName    := Context.FilePath + '\ITEM.VM$';
    FStream  := CreateInputStream(fName);

    try
      sCategoryFname := Context.DataFldr + 'Data\CATEGORY.VM$';
      nSearchSize := GetRecordCount(sCategoryFname, sizeof(Category_record));

      FSearchStream := TFileStream.Create(sCategoryFname, fmOpenRead or fmShareDenyNone);

      try
         while (FStream.Position < FStream.Size) do
         begin

             StreamRead(FStream, FItemRecord, SizeOf(Item_record));
             Inc(context.nCount);

             if (FItemRecord.Item_recd = 'D') or
                (FItemRecord.Item_recd = 'A') then
             begin

            // Inc(context.nCount);

                sItemCategory := '';
                if FItemRecord.Item_category <= nSearchSize then
                begin
                //Searching the category Name in Header based on Treatment_header
                  FSearchStream.Position := (FItemRecord.Item_category - 1) * SizeOf(Category_record);
                  FSearchStream.Read(FCategoryRec, SizeOf(Category_record));

                  if (FCategoryRec.Category_name <> '') then
                    sItemCategory := FCategoryRec.Category_name;
                end;

                FillChar(exportRec, sizeof(exportRec), 0);
       
                // adding data to Records
                exportRec.TINVECODE_PRACTICEID := StrToInt(sPracticeID);
                exportRec.TINVECODE_RECORDNUM := context.nCount;
                exportRec.TINVECODE_RECD  := FItemRecord.Item_recd;
                exportRec.TINVECODE_CODE  := FItemRecord.Item_code;
                exportRec.TINVECODE_CATEGORY := IntToStr(FItemRecord.Item_category);
                exportRec.TINVECODE_DESCRIPTION := FItemRecord.Item_description;
                exportRec.TINVECODE_CATEGORYNAME := sItemCategory;

                dMidAmount := FItemRecord.Item_price / 100;
                exportRec.TINVECODE_PRICE := FormatFloat('0.00', dMidAmount);

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
        writeExcept(E.Message, 'GetCurrentMyItem', Context.PullType);
    end;
end;

end.
