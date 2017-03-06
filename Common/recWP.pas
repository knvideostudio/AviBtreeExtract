// Created on: Jan 06, 2009
// Time 12:59

unit recWP;

interface


uses  uDefs;
// Declaration of Function and Procedures
// ----------------------------------------------------------
function ExptWpCodes( pContext    : pointer;
                          enumFunc    : WpCodeEnumFunc;
                          sPracticeID : PChar;
                          UserData    : Integer) : Boolean;

procedure GetWpCodes(var Context  : TExtractContext;
                     enumFunc        : WpCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

const
  DELIMITER       : String = '\';
  DATA_VM_FILENAME   : String = '\WP.VM$';

// Begin actual CODE
implementation

uses  SysUtils,
      Classes,
      AVITyp,
      uAVITypes,
      Utils,
      ExtractData;

// Get just Numbers
// ---------------------------------------------------------------------------
function ExptWpCodes( pContext  : pointer;
                          enumFunc  : WpCodeEnumFunc;
                          sPracticeID : PChar;
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
    filePath    := Context.FilePath + DATA_VM_FILENAME;
    totalRecs   := GetRecordCount(filePath, sizeof(WP_record));
    current     := 0;
    userAborted := false;

    // Exec the Actual
    GetWpCodes(context^, enumFunc, sPracticeID, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message, 'Wp Data', Context.PullType);
         Result := false;
    end;
  end
end;

// Get the Codes
// -----------------------------------------------------------------------------
procedure GetWpCodes(var Context : TExtractContext;
                     enumFunc        : WpCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  fsVm          : TStream;
  FWpRec        : WP_record;
  exportRec     : TWpCode;
  vmFileName    : String;
  iLenght       : Integer;
  strText       : String;
begin

  if (userAborted) then exit;

  try
    ResetCounts(Context);

    vmFileName    := Context.FilePath + DATA_VM_FILENAME;
    fsVm      := CreateInputStream(vmFileName);

    try
      while (fsVm.Position < fsVm.Size) do
      begin

        Inc(Context.nCount);
        StreamRead(fsVm, FWpRec, SizeOf(WP_record));

       // if (FWpRec.WP_header.WP_size > 0 ) then
       // begin
      //     (FItemRec.Item_recd = 'A') then
      //  begin
          FillChar(exportRec, sizeof(exportRec), 0);

          exportRec.WPCODE_PRACTICE := StrToInt(sPracticeID);
          exportRec.WPCODE_RECORDNUM := context.nCount;
          exportRec.WPCODE_PAR := FWpRec.WP_header.WP_parentis;
          exportRec.WPCODE_SIZE   := FWpRec.WP_header.WP_size;
          exportRec.WPCODE_PARENT :=  IntToStr(FWpRec.WP_header.WP_parent);

          strText := '';
          //strText := FWpRec.WP_text;
          //StringToBuf(strText, exportRec.WPCODE_TEXT, sizeof(MemoField)-1);
          StrPCopy(exportRec.WPCODE_TEXT, FWpRec.WP_text);

         if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false

          Inc(context.wrCount);
      //  end; // end Size
      end;  // while

    finally
      fsVm.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message, 'GetWptCodes' , Context.PullType);
    end;
end;

end.
