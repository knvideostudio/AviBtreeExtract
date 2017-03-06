// Created on: Jan 06, 2009
// Time 12:59

unit recScriptCode;

interface


uses  uDefs;

// Declaration of Function and Procedures
// ----------------------------------------------------------

function ChkJunk(const fieldStr : String) : String;
function ExptScriptCodes( pContext    : pointer;
                          enumFunc    : ScriptEnumFunc;
                          sPracticeID : PChar;
                          UserData    : Integer) : Boolean;

procedure GetScriptCodes(var Context  : TExtractContext;
                     enumFunc        : ScriptEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

const
  DELIMITER       : String = '\';
  ITEM_FILENAME   : String = 'ITEM.VM$';
  DATA_PH_FILENAME   : String = 'Data\PHRASE.VM$';
  DATA_VM_FILENAME   : String = 'WP.VM$';

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
function ExptScriptCodes( pContext  : pointer;
                          enumFunc  : ScriptEnumFunc;
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
    filePath    := Context.FilePath + DELIMITER + ITEM_FILENAME;
    totalRecs   := GetRecordCount(filePath, sizeof(Item_record));

    current     := 0;
    userAborted := false;

    // Exec the Actual CODE
    GetScriptCodes(context^, enumFunc, sPracticeID, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message, 'Script Template Data', Context.PullType);
         Result := false;
    end;
  end
end;

function ChkJunk(const fieldStr : String) : String;
var
  //iAscii : Integer;
  i : Integer;
Begin
  Result := '';
  for i := 1 to Length(fieldStr) do
  Begin
    //iAscii := Ord(fieldStr[i]);
    if (Ord(fieldStr[i]) IN [32, 33, 35..123, 125, 126]) then
      Result := (Result + fieldStr[i]);
  End;
End;

// Get the Codes
// -----------------------------------------------------------------------------
procedure GetScriptCodes(var Context : TExtractContext;
                     enumFunc        : ScriptEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  fsItem        : TStream;
  fsPhrase      : TStream;
  FSearchStream : TFileStream;
  WpRecord      : WP_record;
  FItemRec      : Item_record;
  exportRec     : TScriptCode;
  itemFileName  : String;
  phraFileName  : String;
  vmFileName    : String;
  iDoc          : Integer;
  sDoc          : String;
  iInstr        : LongInt;
  sInstr        : String;

begin
  if (userAborted) then exit;

  try
    iDoc  := 0;
    sDoc  := '';
    iInstr := 0;
    sInstr := '';

    ResetCounts(Context);

    itemFileName  := Context.FilePath + DELIMITER + ITEM_FILENAME;
    phraFileName  := Context.DataFldr + DATA_PH_FILENAME;
    vmFileName    := Context.FilePath + DELIMITER + DATA_VM_FILENAME;

    fsItem  := CreateInputStream(itemFileName);
    fsPhrase  := CreateInputStream(phraFileName);

    FSearchStream := TFileStream.Create(vmFileName, fmOpenRead or fmShareDenyNone);
    Try
      while (fsItem.Position < fsItem.Size) do
      begin

        Inc(Context.nCount);
        StreamRead(fsItem, FItemRec, SizeOf(Item_record));

        // FItemRec.
        if (FItemRec.Item_recd = 'D') or
           (FItemRec.Item_recd = 'A') then
        begin

          FillChar(exportRec, sizeof(exportRec), 0);

          exportRec.SCRIPTCODE_PRACTICE := StrToInt(sPracticeID);
          exportRec.SCRIPTCODE_RECORDNUM := context.nCount;
          exportRec.SCRIPTCODE_RECD := FItemRec.Item_recd;

          exportRec.SCRIPTCODE_SERVICECODE  := FItemRec.Item_code;
          exportRec.SCRIPTCODE_CODES        := FItemRec.Item_codes;
          exportRec.SCRIPTCODE_UOM          := FItemRec.Item_measure;
          exportRec.SCRIPTCODE_REFILLEXP := IntToStr(FItemRec.Item_refill_exp);
          exportRec.SCRIPTCODE_REFILLRESETTX := FItemRec.Item_refill_tx;
          exportRec.SCRIPTCODE_REFILLWAIT := IntToStr(FItemRec.Item_refill_wait);

          // Instruction
          // BEGINs
          sInstr := '';
          if FItemRec.Item_instruction > 0 then
            begin
              FillChar(WpRecord, sizeof(WpRecord), 0);
              FSearchStream.Position := FItemRec.Item_instruction - 1;
              FSearchStream.Read(WpRecord, SizeOf(WP_record));

              if (WpRecord.WP_text <> '') then
                sInstr := ChkJunk(WpRecord.WP_text);
          end;
          StringToBuf(sInstr, exportRec.SCRIPTCODE_INSTRUCTIONS, sizeof(MemoField) - 1);
          // end Instruction

          // BEGINs Document
          iDoc := FItemRec.Item_document_pad;
          if iDoc > 0 then
            sDoc := ChkJunk(StreamReadString(fsPhrase, iDoc - 1))
          else
            sDoc := IntToStr(iDoc);

          StringToBuf(sDoc, exportRec.SCRIPTCODE_DOCUMENT, sizeof(MemoField) - 1);
          // End Document

         if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false

          Inc(context.wrCount);
        end; // end D or A
      end;  // while

    finally
      fsItem.Free;
      fsPhrase.Free;
      FSearchStream.Free;
    end;

except
    on E:Exception do
        writeExcept(E.Message, 'GetScriptCodes' , Context.PullType);
    end;
end;

end.
