unit ServiceCodes;

interface

uses uDefs;

//type
  {
Data comes from two tables:
	Item.vm$
		(1) ITEM_CODE
		(2) ITEM_CATEGORY
		(3) CATEGORY.VM$.CATEGORY_NAME (Item Type)
		(4) ITEM_DESCRIPTION
		(5) ITEM_RECD
		(6) ITEM_PRICE
		(8) Record Number

	Treatment.vm$
		(1) TREATMENT_CODE
		(2) TREATMENT_HEADER
		(3) HEADER.VM$.HEADER_NAME (Item Type)
		(4) TREATMENT_DESCRIPTION
		(5) TREATMENT_RECD
		(6) TREATMENT_PRICE
		(7) TREATMENT_CODES
		(8) Record Number
  }

  function ExportServiceCodes( pContext   : pointer;
                              enumFunc : ServiceCodeEnumFunc;
                              UserData   : Integer) : boolean;

  function ExportServiceCodes2( pContext   : pointer;
                              enumFunc : ServiceCodeEnumFunc2;
                              UserData   : Integer) : boolean;

const
  FLD_DELIM = '|';  // Change this line to change the field delimiter for all exports

implementation

uses
  SysUtils, Classes,
  AVITyp, uAVITypes,
	Utils, ExtractData;


// INVENTORY FILE
// Populates export record with item data and passes it to the callback function
//    with each record
procedure ExportItem(var Context     : TExtractContext;
                     enumFunc        : ServiceCodeEnumFunc;
                     totalRecs       : longint;
                     var current     : longint;
                     userData        : longint;
                     var userAborted : boolean);

var
  FStream        : TStream;
  FItemrecord    : Item_record;
  fName          : String;
  FSearchStream  : TFileStream;
  FCategoryRec   : Category_record;
  sItem_Category : string;
  nSearchSize    : LongInt;
  dMidValue      : double;
  sCategoryFname : string;
  rCount         : longint;
  exportRec      : TServiceCode;

begin
  if (userAborted) then exit;
  try
    rCount  := 0;
    ResetCounts(context);

    fName    := Context.FilePath + '\ITEM.VM$';
    FStream  := CreateInputStream(fName);

    sCategoryFname := Context.FilePath + '\CATEGORY.VM$';
    nSearchSize    := GetRecordCount(sCategoryFname, sizeof(Category_record));

    //Open Item File for Category Name
    FSearchStream := TFileStream.Create(sCategoryFname, fmOpenRead or fmShareDenyNone);
    try
      while (FStream.Position < FStream.Size) do
      begin
        inc(rCount);
        inc(current);
        sItem_Category := '';

        StreamRead(FStream, FItemrecord, SizeOf(Item_record));
        if (FItemrecord.Item_recd = 'D') or
           (FItemrecord.Item_recd = 'A') then
        begin
          Inc(context.nCount);
          if FItemrecord.Item_category <= nSearchSize then
          begin
            //Searching the Category Name in Category based on Item_Category
            FillChar(FCategoryRec, sizeof(FCategoryRec), 0);
            FSearchStream.Position := (FItemrecord.Item_category - 1) * SizeOf(Category_record);
            FSearchStream.Read(FCategoryRec, SizeOf(Category_record));

            if (FCategoryRec.Category_name <> '') then
              sItem_Category := FCategoryRec.Category_name;
          end;

          dMidValue := FItemrecord.Item_price / 100;

          FillChar(exportRec, sizeof(exportRec), 0);

          StringToBuf(FItemrecord.Item_code,
            exportRec.SERVICECODE_ID, sizeof(exportRec.SERVICECODE_ID)-1);

          exportRec.SERVICECODE_CATEGORY := FItemrecord.Item_category;

          StringToBuf(sItem_Category,
            exportRec.SERVICECODE_TYPE, sizeof(exportRec.SERVICECODE_TYPE)-1);

          StringToBuf(FItemrecord.Item_description,
            exportRec.SERVICECODE_DESCRIPTION, sizeof(exportRec.SERVICECODE_DESCRIPTION)-1);

          exportRec.SERVICECODE_RECD  := FItemrecord.Item_recd;
          exportRec.SERVICECODE_PRICE := dMidValue;

          exportRec.SERVICECODE_RECORDNUM := rCount;

          if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
          begin
            userAborted := true;
            break;
          end;

          inc(context.wrCount);
        end;
      end;

    finally
      FSearchStream.Free;
    end;

    FStream.Free;
except
    on E:Exception do
        writeExcept(E.Message,fName, Context.PullType);
    end;
end;



//TREATMENT OUTPUT FILE
// Populates export record with treatment data and passes it to the callback function
//    with each record
procedure ExportTreatment(var Context     : TExtractContext;
                          enumFunc        : ServiceCodeEnumFunc;
                          totalRecs       : longint;
                          var current     : longint;
                          userData        : longint;
                          var userAborted : boolean);
var
  FStream          : TStream;
  FTreatmentrecord : Treatment_record;
  fName            : String;
  FSearchStream    : TFileStream;
  FHeaderRec       : Header_record;
  sHeader_Category : string;
  nSearchSize      : Longint;
  sHeaderFName     : string;
  rCount           : longint;
  exportRec        : TServiceCode;

begin
  try
    if (userAborted) then exit;

    fName   := Context.FilePath +'\TREAT.VM$';
    rCount  := 0;
    ResetCounts(context);

    FStream := CreateInputStream(fName);
    try
     //Open Animal File for Client Column Value
      sHeaderFName := Context.FilePath + '\HEADER.VM$';
      nSearchSize := GetRecordCount(sHeaderFName, SizeOf(Header_record));

      FSearchStream := TFileStream.Create(sHeaderFName, fmOpenRead or fmShareDenyNone);
      try
        while (FStream.Position < FStream.Size) do
        begin
          inc(rCount);
          inc(current);

          StreamRead(FStream, FTreatmentrecord, SizeOf(Treatment_record));

          if (FTreatmentrecord.Treatment_recd ='D') or
             (FTreatmentrecord.Treatment_recd ='A')then
          begin
            inc(context.ncount);
            sHeader_Category := '';

            if FTreatmentrecord.Treatment_header <= nSearchSize then
            begin
              //Searching the category Name in Header based on Treatment_header
              FSearchStream.Position := (FTreatmentrecord.Treatment_header - 1) * SizeOf(Header_record);
              FSearchStream.Read(FHeaderRec, SizeOf(Header_record));

              if (FHeaderRec.Header_name <> '') then
                sHeader_Category := FHeaderRec.Header_name;
            end;

            FillChar(exportRec, sizeof(exportRec), 0);

            StringToBuf(FTreatmentrecord.Treatment_code,
              exportRec.SERVICECODE_ID, sizeof(exportRec.SERVICECODE_ID)-1);

            exportRec.SERVICECODE_CATEGORY := FTreatmentRecord.Treatment_header;

            StringToBuf(sHeader_Category,
              exportRec.SERVICECODE_TYPE, sizeof(exportRec.SERVICECODE_TYPE)-1);

            StringToBuf(FTreatmentrecord.Treatment_description,
              exportRec.SERVICECODE_DESCRIPTION, sizeof(exportRec.SERVICECODE_DESCRIPTION)-1);

            exportRec.SERVICECODE_RECD := FTreatmentrecord.Treatment_recd;
            exportRec.SERVICECODE_PRICE := FTreatmentrecord.Treatment_price/100;

            StringToBuf(FTreatmentrecord.Treatment_codes,
              exportRec.SERVICECODE_TRTCODES, sizeof(exportRec.SERVICECODE_TRTCODES)-1);

            exportRec.SERVICECODE_RECORDNUM := rCount;

            // add new field
            StringToBuf(FTreatmentrecord.Treatment_vaccine,
              exportRec.SERVICECODE_VACCINE, sizeof(exportRec.SERVICECODE_VACCINE)-1);


            if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
            begin
              userAborted := true;
              break;
            end;

            inc(context.wrCount);
          end;
        end;  // while

      finally
        FSearchStream.Free;
      end;

    finally
      FStream.Free;
    end;

  except
    on E:Exception do
         writeExcept(E.Message,fName,Context.PullType);
    end;
end;

function ExportServiceCodes( pContext  : pointer;
                              enumFunc : ServiceCodeEnumFunc;
                              UserData : Integer) : boolean;

var treatRecs,
    itemRecs,
    totalRecs   : longint;
    current     : longint;
    filePath    : string;
    userAborted : boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath +'\TREAT.VM$';
    treatRecs   := GetRecordCount(filePath, sizeof(Treatment_record));
    filePath    := Context.FilePath +'\ITEM.VM$';
    itemRecs    := GetRecordCount(filePath, sizeof(Item_record));
    totalRecs   := treatRecs + itemRecs;
    current     := 0;
    userAborted := false;

    ExportTreatment(context^, enumFunc, totalRecs, current, userData, userAborted);
    ExportItem(context^, enumFunc, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,'ServiceCodes',Context.PullType);
         Result := false;
    end;
  end
end;

{ ******************************************************************* }

// INVENTORY FILE
// Populates export record with item data and passes it to the callback function
//    with each record
procedure ExportItem2(var Context     : TExtractContext;
                     enumFunc        : ServiceCodeEnumFunc2;
                     totalRecs       : longint;
                     var current     : longint;
                     userData        : longint;
                     var userAborted : boolean);

var
  FStream        : TStream;
  FItemrecord    : Item_record;
  fName          : String;
  FSearchStream  : TFileStream;
  FCategoryRec   : Category_record;
  sItem_Category : string;
  nSearchSize    : Longint;
  dMidValue      : double;
  sCategoryFname : string;
  rCount         : longint;
  sResult        : WideString;
  exportRec      : TServiceCode2;

begin
  if (userAborted) then exit;
  try
    rCount  := 0;
    ResetCounts(context);

    fName    := Context.FilePath + '\ITEM.VM$';
    FStream  := CreateInputStream(fName);

    sCategoryFname := Context.FilePath + '\CATEGORY.VM$';
    nSearchSize    := GetRecordCount(sCategoryFname, sizeof(Category_record));

    //Open Item File for Category Name
    FSearchStream := TFileStream.Create(sCategoryFname, fmOpenRead or fmShareDenyNone);
    try
      while (FStream.Position < FStream.Size) do
      begin
        inc(rCount);
        inc(current);
        sItem_Category := '';
        sResult := '';  // Init

        StreamRead(FStream, FItemrecord, SizeOf(Item_record));
        if (FItemrecord.Item_recd = 'D') or
           (FItemrecord.Item_recd = 'A') then
        begin
          Inc(context.nCount);
          if FItemrecord.Item_category <= nSearchSize then
          begin
            //Searching the Category Name in Category based on Item_Category
            FillChar(FCategoryRec, sizeof(FCategoryRec), 0);
            FSearchStream.Position := (FItemrecord.Item_category - 1) * SizeOf(Category_record);
            FSearchStream.Read(FCategoryRec, SizeOf(Category_record));

            if (FCategoryRec.Category_name <> '') then
              sItem_Category := Trim(FCategoryRec.Category_name);
          end;

          dMidValue := FItemrecord.Item_price / 100;

          // Build export string
          sResult := (Trim(FItemrecord.Item_code)         + FLD_DELIM +
                      IntToStr(FItemrecord.Item_category) + FLD_DELIM +
                      sItem_Category                      + FLD_DELIM +
                      Trim(FItemrecord.Item_description)  + FLD_DELIM +
                      Trim(FItemrecord.Item_recd)         + FLD_DELIM +
                      FloatToStr(dMidValue)               + FLD_DELIM +
                      IntToStr(rCount));

          // Assign export string to export buffer
          FillChar(exportRec, sizeof(exportRec), 0);
          StrPCopy(exportRec.SERVICECODE_DATA, sResult);

          if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
          begin
            userAborted := true;
            break;
          end;

          inc(context.wrCount);
        end;
      end;

    finally
      FSearchStream.Free;
    end;

    FStream.Free;
except
    on E:Exception do
        writeExcept(E.Message,fName, Context.PullType);
    end;
end;



//TREATMENT OUTPUT FILE
// Populates export record with treatment data and passes it to the callback function
//    with each record
procedure ExportTreatment2(var Context     : TExtractContext;
                          enumFunc        : ServiceCodeEnumFunc2;
                          totalRecs       : longint;
                          var current     : longint;
                          userData        : longint;
                          var userAborted : boolean);
var
  FStream          : TStream;
  FTreatmentrecord : Treatment_record;
  fName            : String;
  FSearchStream    : TFileStream;
  FHeaderRec       : Header_record;
  sHeader_Category : string;
  nSearchSize      : Longint;
  sHeaderFName     : string;
  rCount           : longint;
  exportRec        : TServiceCode2;
  sResult          : WideString;
begin
  try
    if (userAborted) then exit;

    fName   := Context.FilePath +'\TREAT.VM$';
    rCount  := 0;
    ResetCounts(context);

    FStream := CreateInputStream(fName);
    try
     //Open Animal File for Client Column Value
      sHeaderFName := Context.FilePath + '\HEADER.VM$';
      nSearchSize := GetRecordCount(sHeaderFName, SizeOf(Header_record));

      FSearchStream := TFileStream.Create(sHeaderFName, fmOpenRead or fmShareDenyNone);
      try
        while (FStream.Position < FStream.Size) do
        begin
          inc(rCount);
          inc(current);
          sResult := '';  // Init

          StreamRead(FStream, FTreatmentrecord, SizeOf(Treatment_record));

          if (FTreatmentrecord.Treatment_recd ='D') or
             (FTreatmentrecord.Treatment_recd ='A')then
          begin
            inc(context.ncount);
            sHeader_Category := '';

            if FTreatmentrecord.Treatment_header <= nSearchSize then
            begin
              //Searching the category Name in Header based on Treatment_header
              FSearchStream.Position := (FTreatmentrecord.Treatment_header - 1) * SizeOf(Header_record);
              FSearchStream.Read(FHeaderRec, SizeOf(Header_record));

              if (FHeaderRec.Header_name <> '') then
                sHeader_Category := FHeaderRec.Header_name;
            end;

            sResult := FTreatmentrecord.Treatment_code                 + FLD_DELIM +
                      IntToStr(FTreatmentRecord.Treatment_header)      + FLD_DELIM +
                      sHeader_Category                                 + FLD_DELIM +
                      FTreatmentrecord.Treatment_description           + FLD_DELIM +
                      FTreatmentrecord.Treatment_recd                  + FLD_DELIM +
                      FloatToStr(FTreatmentrecord.Treatment_price/100) + FLD_DELIM +
                      FTreatmentrecord.Treatment_codes                 + FLD_DELIM +
                      IntToStr(rCount);

            // Assign export string to export buffer
            FillChar(exportRec, sizeof(exportRec), 0);
            StrPCopy(exportRec.SERVICECODE_DATA, sResult);

            if (false = enumFunc(@exportRec, current, totalRecs, userData)) then
            begin
              userAborted := true;
              break;
            end;

            inc(context.wrCount);
          end;
        end;  // while

      finally
        FSearchStream.Free;
      end;

    finally
      FStream.Free;
    end;

  except
    on E:Exception do
         writeExcept(E.Message,fName,Context.PullType);
    end;
end;

function ExportServiceCodes2( pContext  : pointer;
                              enumFunc : ServiceCodeEnumFunc2;
                              UserData : Integer) : boolean;

var treatRecs,
    itemRecs,
    totalRecs   : longint;
    current     : longint;
    filePath    : string;
    userAborted : boolean;
    Context     : PExtractContext;
begin
  context := PExtractContext(pContext);

  try
    filePath    := Context.FilePath +'\TREAT.VM$';
    treatRecs   := GetRecordCount(filePath, sizeof(Treatment_record));
    filePath    := Context.FilePath +'\ITEM.VM$';
    itemRecs    := GetRecordCount(filePath, sizeof(Item_record));
    totalRecs   := treatRecs + itemRecs;
    current     := 0;
    userAborted := false;

    ExportTreatment2(context^, enumFunc, totalRecs, current, userData, userAborted);
    ExportItem2(context^, enumFunc, totalRecs, current, userData, userAborted);

    Result := not userAborted;
  except
    on E:Exception do
    begin
         writeExcept(E.Message,'ServiceCodes',Context.PullType);
         Result := false;
    end;
  end
end;

end.

