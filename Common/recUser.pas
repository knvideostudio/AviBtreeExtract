// Created on: March 12, 2008
// Time 12:59

// Modified on Aug 08, 2008
// for new Version

unit recUser;

interface

uses  uDefs;

{
Data comes from two tables:

 ****************************************
}

// Declaration of Function and Procedures
function ExpUsers(pContext : pointer;
                  enumFunc : UserCodeEnumFunc;
                  sPracticeID : PChar;
                  UserData : Integer) : boolean;

procedure GetCurrentUsers(var Context     : TExtractContext;
                     enumFunc        : UserCodeEnumFunc;
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

function ExpUsers(pContext    : pointer;
                  enumFunc    : UserCodeEnumFunc;
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

    filePath    := Context.FilePath + '\USER.VM$';
    LogStr('ExpUsers: ' + filePath);
    totalRecs   := GetRecordCount(filePath, sizeof(User_record));

    LogStr('ExpUsers: ' + IntToStr(totalRecs));

    current     := 0;
    userAborted := false;

    GetCurrentUsers(context^, enumFunc, sPracticeID, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message, 'User Data', Context.PullType);
         Result := false;
    end;
  end
end;

// The procedure is Starting
procedure GetCurrentUsers(var Context     : TExtractContext;
                     enumFunc        : UserCodeEnumFunc;
                     sPracticeID     : PChar;
                     totalRecs       : LongInt;
                     var current     : LongInt;
                     userData        : LongInt;
                     var userAborted : Boolean);

var
  FStream         : TStream;
  FSearchStream   : TFileStream;
  FUsrRecord      : User_record;
  FGroupRec       : Group_record;
  fName           : String;
  sGroup_Category : String;
  sGroupFname     : String;
  nSearchSize     : LongInt;
  exportRec       : TUserCode;
//  iDataVersion    : Integer;

begin
  if (userAborted) then exit;

  try
    ResetCounts(context);

    fName    := Context.FilePath + '\USER.VM$';

    // LogStr('GetCurrentUsers: ' + fName);
    FStream  := CreateInputStream(fName);

    try
      sGroupFname   := Context.DataFldr + 'Data\GROUP.VM$';
      // LogStr('GetCurrentUsers: ' + sGroupFname);
      
      nSearchSize   := GetRecordCount(sGroupFName, SizeOf(Group_record));
      FSearchStream := TFileStream.Create(sGroupFname, fmOpenRead or fmShareDenyNone);

     // iDataVersion := GetDataVersion(Context.FilePath);

    try
      while (FStream.Position < FStream.Size) do
      begin

        StreamRead(FStream, FUsrRecord, SizeOf(User_record));

        if (FUsrRecord.User_recd = 'A') then
        begin
          Inc(context.nCount);
          sGroup_Category := '';

          if FUsrRecord.User_group <= nSearchSize then
          begin
             //Searching the category Name in Header based on Treatment_header
             FSearchStream.Position := (FUsrRecord.User_group - 1) * SizeOf(Group_record);
             FSearchStream.Read(FGroupRec, SizeOf(Group_record));

             if (FGroupRec.Group_name  <> '') then
               sGroup_Category := FGroupRec.Group_name;
          end;

          FillChar(exportRec, sizeof(exportRec), 0);

          exportRec.USERCODE_PRACTICEID := StrToInt(sPracticeID);
          exportRec.USERCODE_RECNUM :=  context.nCount;
          exportRec.USERCODE_RECD   :=   FUsrRecord.User_recd;
          exportRec.USERCODE_GROUP  :=   IntToStr(FUsrRecord.User_group);
          exportRec.USERCODE_ID     :=   FUsrRecord.User_id;
          exportRec.USERCODE_NAME   :=   FUsrRecord.User_name;
            
          // if (iDataVersion = 11841) then
          exportRec.USERCODE_STAFF  :=   IntToStr(FUsrRecord.User_staffpad);
          // else
          //  exportRec.USERCODE_STAFF  :=   '0';

          exportRec.USERCODE_CLASS  :=  sGroup_Category;

          // This is Version number
          // Forney is 11841
          // IntToStr(iDataVersion)
          
         if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
         begin
            userAborted := true;
            break;
         end; // end if false

          Inc(Context.wrCount);
        end; // end A
      end;  // while

    finally
      FSearchStream.Free;
    end;
  finally
    FStream.Free;
  end;
  
except
    on E:Exception do
        writeExcept(E.Message,fName, Context.PullType);
    end;
end;

end.
