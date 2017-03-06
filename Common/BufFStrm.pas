{**************************************************************************************************}
{                                                                                                  }
{  TBufFileStream, Version 1.0.3 alpha                                                             }
{                                                                                                  }
{  The contents of this file are subject to the Y Library Public License Version 1.0 (the          }
{  "License"); you may not use this file except in compliance with the License. You may obtain a   }
{  copy of the License at http://delphi.pjh2.de/                                                   }
{                                                                                                  }
{  Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF  }
{  ANY KIND, either express or implied. See the License for the specific language governing        }
{  rights and limitations under the License.                                                       }
{                                                                                                  }
{  The Original Code is: BufFStrm.pas.                                                             }
{  The Initial Developer of the Original Code is Peter J. Haas (libs@pjh2.de). Portions created    }
{  by Peter J. Haas are Copyright (C) 2000-2005 Peter J. Haas. All Rights Reserved.                }
{                                                                                                  }
{  Contributor(s):                                                                                 }
{                                                                                                  }
{  You may retrieve the latest version of this file at the homepage of Peter J. Haas, located at   }
{  http://delphi.pjh2.de/                                                                          }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Limitations:                                                                                     }
{   Delphi 1:                                                                                      }
{     - Win3.x, Win9x, WinNT, Win2k, OS/2                                                          }
{     - max. file size = 2^31-1 bytes  (2 GB)                                                      }
{     - max. buffer size = 61440                                                                   }
{     - no align to sector size                                                                    }
{                                                                                                  }
{   Delphi 2 to 5:                                                                                 }
{     - Win3.x, Win9x, WinNT, Win2k, OS/2 (Delphi 1)                                               }
{     - Win9x, WinNT, Win2k (Delphi 2 to 5)                                                        }
{     - max. file size = 2^31-1 bytes  (2 GB)                                                      }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Credits:                                                                                         }
{   Heiko Tietze for testing                                                                       }
{                                                                                                  }
{**************************************************************************************************}

// For history see end of file

unit BufFStrm;

{ diesen Compilerschalter für deutsche Fehlermeldungen aktivieren }
{$define ResLangGerman}

{ notice:
   - for correct write access use 'read and write mode'
   - you can use 'only write mode' for a faster access
     under following conditions:
      - only sequential write access
      - only new file or if complete overwrite the old file }

{$ifdef ver130}
  {$define Delphi5_up}
  {$define Delphi4_up}
  {$define Delphi3_up}
  {$define Delphi2_up}
  {$define Delphi1_up}
{$endif}

{$ifdef ver120}
  {$define Delphi4_up}
  {$define Delphi3_up}
  {$define Delphi2_up}
  {$define Delphi1_up}
{$endif}

{$ifdef ver100}
  {$define Delphi3_up}
  {$define Delphi2_up}
  {$define Delphi1_up}
{$endif}

{$ifdef ver90}
  {$define Delphi2}
  {$define Delphi2_up}
  {$define Delphi1_up}
{$endif}

{$ifdef ver80}
  {$define Delphi1}
  {$define Delphi1_up}
{$endif}

{$ifdef Ver80}
{$else}
{$ALIGN ON, $BOOLEVAL OFF, $LONGSTRINGS ON, $IOCHECKS ON, $WRITEABLECONST OFF}
{$OVERFLOWCHECKS OFF, $RANGECHECKS OFF, $TYPEDADDRESS ON, $MINENUMSIZE 1}
{$endif}

interface

uses
  {$ifdef Delphi5_up}
  RTLConsts,
  {$endif}
  {$ifdef Delphi1}
  WinProcs, WinTypes,
  {$else}
  Windows,
  {$endif}
  SysUtils, Classes;

resourceString
  SReadError = 'Stream read error';
  SWriteError = 'Stream write error';
  SFCreateError = 'Error creating file %s';

{$ifdef Delphi1}
type
  DWord = LongInt;

const
  HFILE_ERROR  = -1;
  FILE_BEGIN   = 0;
  FILE_CURRENT = 1;
  FILE_END     = 2;
{$endif}

type
  TBufferedFileStream = class(TStream)
  private
    {$ifdef Delphi1}
    FFileHandle     : Word;     { handle of file }
    FAccessMode     : Word;     { for write access without read }
    FBufferSize     : Word;     { buffer capacity }
    {$else}
    FFileHandle     : THandle;  { handle of file }
    FAccessMode     : DWord;    { for write access without read }
    FBufferSize     : DWord;    { buffer capacity }
    {$endif}
    FBuffer         : PByte;    { pointer to buffer }
    FIsModified     : Boolean;  { is buffer modified }
    FBufPosition    : LongInt;  { abs. file position from first byte in buffer }
    FBufPtr         : PByte;    { pointer of current byte in buffer }
    FBufEnd         : PByte;    { pointer behind last valid byte in buffer }
                                { is FBufPtr + FBufferSize, except last block }
    procedure ReadBufferFromFile;
  protected
    {$ifdef Delphi3_up}
    procedure SetSize(NewSize: LongInt); override;
    {$endif}
    property FileHandle: THandle read FFileHandle;  { handle of file }
  public
    { create a buffered filestream, used default buffersize
      compatible to TFileStream }
    constructor Create(const AFilename: String; AMode: Word);

    {$ifdef Delphi1}
    { create a buffered filestream
      for parameter, look TFileStream help }
    constructor CreateCustom(const AFilename: String;
                             AMode: Word; ABufferSize: Word);
    {$else}
    { create a buffered filestream with all parameter for CreateFile function
      for the first parameter, look in WinAPI helpfile
        AFilename             file name
        ADesiredAccess        access mode
        AShareMode            share mode
        ASecurityAttributes   SD
        ACreationDisposition  how to create
        AFlagsAndAttributes   file attributes
        ATemplateFile         handle to template file
        ABufferSize           buffer size, it's aligning to sector size
                              set to 0 for default buffer size }
    constructor CreateCustom(const AFilename: String;
                             ADesiredAccess, AShareMode: DWord;
                             ASecurityAttributes: PSecurityAttributes;
                             ACreationDisposition, AFlagsAndAttributes: DWord;
                             ATemplateFile: THandle; ABufferSize: DWord);
    {$endif}
    destructor Destroy; override;
    function Read(var Buffer; Count: LongInt): LongInt; override;
    function Write(const Buffer; Count: LongInt): LongInt; override;
    function Seek(Offset: LongInt; Origin: Word): LongInt; override;
    {$ifndef Delphi3_up}
    procedure SetSize(NewSize: LongInt); override;
    {$endif}
    procedure Flush;
  end;


const
  INVALID_SET_FILE_POINTER = DWORD(-1);
  {$ifdef Delphi4_up}       { TODO : prüfen, ob Delphi5_up }
  {$EXTERNALSYM INVALID_SET_FILE_POINTER}
  {$endif}


{ error messages }

{$ifdef Delphi3_up}
resourcestring
{$else}
const
{$endif}
  {$ifdef ResLangGerman}
  SSeekError    = 'Stream-Seek-Fehler';
  SSetSizeError = 'Stream-SetSize-Fehler';
  {$else}
  SSeekError    = 'Stream-Seek-Error';
  SSetSizeError = 'Stream-SetSize-Error';
  {$endif}

implementation

uses
  Consts;

const
  DefaultBufferSize = 8192; //32768; { default buffer size }
  DefaultSectorSize = 2048;  { default sector size = max known sector size (CDFS) }
  {$ifdef Delphi1}
  Delphi1MaxBufferSize = $F000;
  {$endif}

constructor TBufferedFileStream.Create(const AFilename: String; AMode: Word);
{$ifdef Delphi1}
begin
  CreateCustom(AFilename, AMode, 0);
end;
{$else}
const
  AccessMode: array[0..2] of DWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of DWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
  CreationMode: array[Boolean] of DWord = (
    OPEN_EXISTING,
    CREATE_ALWAYS);
var
  flCreate : Boolean;
begin
  flCreate := AMode = fmCreate;
  if flCreate then AMode := 2;  { GENERIC_READ or GENERIC_WRITE, no sharing }
  CreateCustom(AFilename,
               AccessMode[AMode and 3],
               ShareMode[(AMode and $F0) shr 4],
               Nil,
               CreationMode[flCreate],
               FILE_ATTRIBUTE_NORMAL,
               0,
               0);
end;
{$endif}

{$ifdef Delphi1}
constructor TBufferedFileStream.CreateCustom(const AFilename: String;
                             AMode: Word; ABufferSize: Word);
const
  ReadWriteMask = $0003;
begin
  inherited Create;
  if AMode = fmCreate then
  begin
    FAccessMode := of_ReadWrite;
    FFileHandle := FileCreate(AFileName);
    if FFileHandle < 0 then
      raise EFCreateError.Create(FmtLoadStr(SFCreateError, [AFileName]));
  end
  else
  begin
    FAccessMode := AMode and ReadWriteMask;
    FFileHandle := FileOpen(AFileName, AMode);
    if FFileHandle < 0 then
      raise EFOpenError.Create(FmtLoadStr(SFOpenError, [AFileName]));
  end;
  { correct buffer size }
  if ABufferSize = 0 then ABufferSize := DefaultBufferSize;
  if ABufferSize > Delphi1MaxBufferSize then
    ABufferSize := Delphi1MaxBufferSize;
  FBufferSize := ABufferSize;
  GetMem(FBuffer, FBufferSize);           { get buffer memory }
  FBufPtr := FBuffer;                     { set pointer }
  FBufEnd := FBufPtr;
end;
{$else}
constructor TBufferedFileStream.CreateCustom(const AFilename: String;
                             ADesiredAccess, AShareMode: DWord;
                             ASecurityAttributes: PSecurityAttributes;
                             ACreationDisposition, AFlagsAndAttributes: DWord;
                             ATemplateFile: THandle; ABufferSize: DWord);
const
  GenericReadWriteMask = GENERIC_READ or GENERIC_WRITE;
var
  Drive          : String;
  SectorsPerCluster    : DWord;  // Dummy
  BytesPerSector       : DWord;
  NumberOfFreeClusters : DWord;  // Dummy
  TotalNumberOfClusters: DWord;  // Dummy

begin
  inherited Create;
  FAccessMode := ADesiredAccess and GenericReadWriteMask;
  FFileHandle := CreateFile(PChar(AFileName),
                            ADesiredAccess,
                            AShareMode,
                            ASecurityAttributes,
                            ACreationDisposition,
                            AFlagsAndAttributes,
                            ATemplateFile);
  if FFileHandle = INVALID_HANDLE_VALUE then
    {$ifdef Delphi3_up}            { TODO : prüfen, zwei verschiedene Meldungen }
    raise EFCreateError.CreateFmt(SFCreateError, [AFileName]);
    {$else}
    raise EFCreateError.CreateFmt(SFCreateError, [AFileName]);
    {$endif}

  { correct buffer size }
  {$ifdef Delphi4_up}
  if ABufferSize = 0 then ABufferSize := DefaultBufferSize;
  {$else}
  if ABufferSize <= 0 then ABufferSize := DefaultBufferSize;
  {$endif}
  { get sector size }
  Drive := ExtractFileDrive(AFilename);
  if (Length(Drive)>0) and (Drive[Length(Drive)]<>'\') then Drive := Drive+'\';
  if Not GetDiskFreeSpace(Pointer(Drive),
                          SectorsPerCluster, BytesPerSector,
                          NumberOfFreeClusters, TotalNumberOfClusters) then
    BytesPerSector := DefaultSectorSize;  { can't get sector size -> default }
  { align buffer size to sector size }
  FBufferSize := ((ABufferSize + BytesPerSector-1) div BytesPerSector) * BytesPerSector;
  GetMem(FBuffer, FBufferSize);           { get buffer memory }
  FBufPtr := FBuffer;                     { set pointer }
  FBufEnd := FBufPtr;
end;
{$endif}

destructor TBufferedFileStream.Destroy;
begin
  Flush;                                           { flush buffer }
  {$ifdef Delphi1}
  if FFileHandle >= 0 then FileClose(FFileHandle); { close file }
  {$else}
  if FFileHandle <> INVALID_HANDLE_VALUE then      { close file }
    FileClose(FFileHandle);    { TODO : prüfen, CloseHandle }
  {$endif}
  if FBufferSize > 0 then                          { free buffer }
    FreeMem(FBuffer, FBufferSize);
end;

{ read block from file to buffer }
procedure TBufferedFileStream.ReadBufferFromFile;
var
  BytesRead : DWord;
begin
  {$ifdef Delphi1}
  if FAccessMode = of_Write then  { no read access }
  {$else}
  if (FAccessMode and GENERIC_READ) = 0 then  { no read access }
  {$endif}
  begin
    FBufPtr := FBuffer;
    FBufEnd := FBufPtr;
  end
  else
  begin
    {$ifdef Delphi1}
    if FileSeek(FFileHandle, FBufPosition, 0) = HFILE_ERROR then
      raise EReadError.Create(LoadStr(SReadError));
    BytesRead := FileRead(FFileHandle, FBuffer^, FBufferSize);
    if BytesRead = HFILE_ERROR then
      raise EReadError.Create(LoadStr(SReadError));
    {$else}
    { set file pointer to start of block }
    if SetFilePointer(FFileHandle, FBufPosition, Nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER then
      {$ifdef Delphi2}
      raise EReadError.CreateRes(SReadError);
      {$else}
      RaiseLastOSError;
      {$endif}
    { read to buffer }
    {$ifdef Delphi2}
    if ReadFile(FFileHandle, FBuffer^, FBufferSize, BytesRead, Nil) then
      raise EReadError.CreateRes(SReadError);
    {$else}
    Win32Check(ReadFile(FFileHandle, FBuffer^, FBufferSize, BytesRead, Nil));
    {$endif}
    {$endif}
    FBufPtr := FBuffer;
    FBufEnd := Pointer(DWord(FBufPtr)+BytesRead);
  end;
end;

function TBufferedFileStream.Read(var Buffer; Count: LongInt): LongInt;
var
  DstPtr      : PByte;
  BytesToRead : Integer;

  procedure ReadNextBlock;
  var
    BytesInBuffer  : DWord;
    SaveCurrentPtr : PByte;
  begin
    { calculate number of bytes in buffer }
    BytesInBuffer := DWord(FBufEnd) - DWord(FBuffer);
    { save the current position in buffer }
    SaveCurrentPtr := FBufPtr;
    { if a complete block then read next block,
      else read same block again, test to new bytes }
    {$ifdef Delphi3_up}
    Assert(BytesInBuffer <= FBufferSize, 'buffer overflow');  { TODO : assert }
    {$endif}
    if BytesInBuffer >= FBufferSize then
    begin
      Inc(FBufPosition,   FBufferSize);
      Dec(SaveCurrentPtr, FBufferSize);
    end;
    ReadBufferFromFile;                 { read to buffer }
    FBufPtr := SaveCurrentPtr;          { set position in buffer }
  end;

begin
  Result := 0;
  {$ifdef Delphi1}
  if FAccessMode = of_Write then Exit;  { no read access }
  {$else}
  if (FAccessMode and GENERIC_READ) = 0 then Exit;  { no read access }
  {$endif}
  DstPtr := @Buffer;
  if DstPtr = Nil then Exit;
  while Count > 0 do
  begin
    { calculate bytes remain in buffer }
    BytesToRead := DWord(FBufEnd) - DWord(FBufPtr);
    if BytesToRead <= 0 then  { is the end of buffer }
    begin
      { read next block }
      ReadNextBlock;
      { calculate bytes remain in buffer }
      BytesToRead := DWord(FBufEnd) - DWord(FBufPtr);
    end;
    { set number of bytes to copy }
    if BytesToRead > Count then BytesToRead := Count;
    { check end of file }
    if BytesToRead <= 0 then Break;
    { copy bytes }
    Move(FBufPtr^, DstPtr^, BytesToRead);  { copy }
    Dec(Count,   BytesToRead);             { decrement number bytes remain }
    Inc(FBufPtr, BytesToRead);             { increment position in buffer }
    Inc(DstPtr,  BytesToRead);             { increment destination pointer }
    Inc(Result,  BytesToRead);             { increment number of bytes read }
  end;
end;

function TBufferedFileStream.Write(const Buffer; Count: LongInt): LongInt;
var
  SrcPtr : PByte;
  BytesToWrite : LongInt;
begin
  Result := 0;
  {$ifdef Delphi1}
  if FAccessMode = of_Read then Exit;  { no write access }
  {$else}
  if (FAccessMode and GENERIC_WRITE) = 0 then Exit;   { no write access }
  {$endif}
  SrcPtr := @Buffer;
  if SrcPtr = Nil then Exit;
  while Count > 0 do
  begin
    { calculate free space in block }
    BytesToWrite := FBufferSize- (DWord(FBufPtr) - DWord(FBuffer));
    { if no more free space then write block }
    if BytesToWrite <= 0 then
    begin
      Flush;                           { write block }
      Inc(FBufPosition, FBufferSize);  { set next block }
      ReadBufferFromFile;              { read next block }
      { calculate free space in block }
      BytesToWrite := FBufferSize - (DWord(FBufPtr) - DWord(FBuffer));
    end;
    { set number of bytes to copy }
    if BytesToWrite>Count then BytesToWrite:=Count;
    { if necessary set buffer end to new position }
    if BytesToWrite>LongInt(FBufEnd)-LongInt(FBufPtr) then
      LongInt(FBufEnd):=LongInt(FBufPtr)+BytesToWrite;
    { copy bytes }
    if BytesToWrite>0 then
    begin
      FIsModified := True;                    { mark as modified }
      Move(SrcPtr^, FBufPtr^, BytesToWrite);  { copy }
      Dec(Count,   BytesToWrite);             { decrement number bytes remain }
      Inc(SrcPtr,  BytesToWrite);             { increment source pointer }
      Inc(FBufPtr, BytesToWrite);             { increment position in buffer }
      Inc(Result,  BytesToWrite);             { increment number of bytes write }
    end;
  end;
end;

procedure TBufferedFileStream.Flush;
var
  BytesToWrite : DWord;
  BytesWrite   : DWord;
begin
  if FIsModified then
  begin
    FIsModified := False;     { mark as unmodified }
    {$ifdef Delphi1}
    if FileSeek(FFileHandle, FBufPosition, 0) = HFILE_ERROR then
      raise EWriteError.Create(LoadStr(SWriteError));
    {$else}
    if SetFilePointer(FFileHandle, FBufPosition, Nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER then
      {$ifdef Delphi2}
      raise EReadError.CreateRes(SWriteError);
      {$else}
      RaiseLastOSError;
      {$endif}
    {$endif}
    BytesToWrite := DWord(FBufEnd) - DWord(FBuffer);
    {$ifdef Delphi1}
    BytesWrite := FileWrite(FFileHandle, FBuffer^, BytesToWrite);
    {$else}
    {$ifdef Delphi2}
    if WriteFile(FFileHandle, FBuffer^, BytesToWrite, BytesWrite, Nil) then
      raise EWriteError.CreateRes(SWriteError);
    {$else}
    Win32Check(WriteFile(FFileHandle, FBuffer^, BytesToWrite, BytesWrite, Nil));
    {$endif}
    {$endif}
    if BytesToWrite <> BytesWrite then            { can't write all bytes }
      {$ifdef Delphi1}
      raise EWriteError.Create(LoadStr(SWriteError));
      {$else}
      {$ifdef Delphi2}
      raise EWriteError.CreateRes(SWriteError);
      {$else}
      raise EWriteError.Create(SWriteError);
      {$endif}
      {$endif}
  end;
end;

function TBufferedFileStream.Seek(Offset: LongInt; Origin: Word): LongInt;
begin
  { calculate new absolute position }
  case Origin of
    FILE_CURRENT : begin
      Result := DWord(FBufPosition) + (DWord(FBufPtr) - DWord(FBuffer)) + DWord(Offset);
    end;
    FILE_END : begin
      {$ifdef Delphi1}
      Result := FileSeek(FFileHandle, Offset, FILE_END);
      if Result = HFILE_ERROR then
        raise EStreamError.Create(SSeekError);
      {$else}
      Result := SetFilePointer(FFileHandle, Offset, Nil, FILE_END);  { get file size }
      if DWord(Result) = INVALID_SET_FILE_POINTER then
        {$ifdef Delphi2}
        raise EStreamError.Create(SSeekError);
        {$else}
        RaiseLastOSError;
        {$endif}
      {$endif}
    end;
  else { FILE_BEGIN }
    Result := Offset;
  end;
  { is new position outside of the curent block? }
  if (Result < FBufPosition) or
     (DWord(Result) >= DWord(FBufPosition) + FBufferSize) then
  begin
    Flush;                 { write buffer }
    { calculate file position from first byte in buffer }
    FBufPosition := DWord(Result) - (DWord(Result) mod FBufferSize);
    ReadBufferFromFile;    { read block }
  end;
  { calculate position in buffer }
  FBufPtr := Pointer(DWord(FBuffer) + DWord(Result) - DWord(FBufPosition));
  { if necessary set buffer end to new position }
  if DWord(FBufEnd) < DWord(FBufPtr) then
    FBufEnd := FBufPtr;
end;

procedure TBufferedFileStream.SetSize(NewSize: LongInt);
begin
  if NewSize < 0 then NewSize := 0;
  { if current block in new file then write block }
  if DWord(NewSize) > DWord(FBufPosition) then
    Flush;
  { set file size }
  {$ifdef Delphi1}
  if FileSeek(FFileHandle, NewSize, FILE_BEGIN) = HFILE_ERROR then
    raise EStreamError.Create(SSeekError);
  if FileWrite(FFileHandle, PByte(Nil)^, 0) = HFILE_ERROR then
    raise EStreamError.Create(SSetSizeError);
  {$else}
  if SetFilePointer(FFileHandle, NewSize, Nil, FILE_BEGIN) = INVALID_SET_FILE_POINTER then
    {$ifdef Delphi2}
    raise EStreamError.Create(SSeekError);
    {$else}
    RaiseLastOSError;
    {$endif}
  {$ifdef Delphi2}
  if SetEndOfFile(FFileHandle) then
    raise EStreamError.Create(SSetSizeError);
  {$else}
  Win32Check(SetEndOfFile(FFileHandle));
  {$endif}
  {$endif}
  { if current position outside of the file then set position to end of file }
  if DWord(Position) > DWord(NewSize) then
    Position := NewSize;
end;

// *******************************************************************************************

//  History:
//   2005-02-20, Peter J. Haas
//    - new license
//
//   2001-02-11 Version 1.0.3 alpha
//    - BugFix Dummy variables for GetDiskFreeSpace
//      (WinNT 4.0SP6a have problems with Nil)
//
//   2000-09-16 Version 1.0.2 alpha
//    - Design FileHandle -> protected
//    - Bugfix CreateCustom: negative ABufferSize in Delphi 2, 3
//
//   2000-09-10 Version 1.0.1 alpha
//    - Bugfix Read / Write: Buffer = Nil
//    - Bugfix Read: no Return by end of file
//
//   2000-09-06 Version 1.0 alpha
//    - First test version
end.
