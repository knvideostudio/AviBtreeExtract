{-$define debug}
unit Utils;
interface
uses classes, Windows;


{$ifdef debug}
procedure ShowMessage(Msg : string);
{$endif}

function PCharToString(str : PChar) : string;
function SlashedDir(sDirName : string) : string;
function FixCurrentPath(sAppPath : string) : string;
function ForceExtension(Name, Ext : string) : string;
function StringToBuf(Const Str : String; Buf : pchar; maxlen : integer) : boolean;
function GetWindowsDir: string;
function GetSystemDir: string;

function findINI(iniFilename : string; var IniFilePath : string) : boolean;
procedure WriteStringListToTextStream(stream : TStream; list : TStringList);
procedure WriteStringListToTextFile(fileName : string; list : TStringList);

procedure SwapDatesIfNeeded(var startDate, endDate : TDateTime);
procedure Splitt(var ts : TStringList; thing: string; delimeter: string);
procedure SplitString(str : string; delim : string;var left, right : string);
procedure ValidateDirExists(const directoryName : string);

{ DateTimeToStr(AVITimeToDateTime(956))
returns "12/30/1899 3:56:00 PM"
(it throws away the date
  part and only deals with the time) }
//function AVITimeToDateTime(Time_int: Word): TDateTime;
{ DateTimeToStr(AVIDateToDateTime(14951)) returns 12/7/1941 }

function AVIDateToDateTime(Date_int: Word; Time_int: Word = 0): TDateTime;

//#CM 10/08/02
function DateTimeToAVIDate(ADateTime: TDateTime): Word;

// Added by Krassimir
// March 25, 2008
// Function GetTimeMS() : LongInt;

Function RemoveBlanks(S : String) : String;
Function ExtendString(S : String; Anz : Byte) : String;
Function LeftPadCH(S : String; Ch : Char; Len : Byte) : String;
Function PadCH(S : String; Ch : Char; Len : Byte) : String;
Function TrimString(S : String) : String;
Function IntStrToKey(S : String) : String;
// Feb 25, 2009
Procedure WriteHex(var f: text; var s, name: string; x: char);
Function RandomPassGeneration(syllables, numbers: Byte): String;
Function ConvertsStringToHexadecimal(Data: String): String;
Function ConvertHexadecimalToString(value : String) : String;
// end Block

implementation
uses sysutils, iniFiles, StrUtils
{$ifdef AVI_BUFFER_INPUT}
  , BufFStrm
{$endif}
;

// )))))))))))))))))))))))))))))))))))))))))))))))))))))
// Added by Krassimir
// March 25, 2008
// ((((((((((((((((((((((((((((((((((((((((((((((((((((
{Function GetTimeMS() : LongInt;
Var
  Regs : Registers;
Begin
    With Regs Do Begin
      AH := $2C;
      MsDos(Regs);
      GetTimeMS :=  1000 * (LongInt(DH) +
                    60 * (LongInt(CL) +
                    60 * LongInt(CH))) +
                    10 * LongInt(DL);
    end;
End;     }

// removing blank space
Function RemoveBlanks(S : String) : String;
Var
  I : Word;
  SLen : Byte absolute S;

 Begin
    While (SLen > 0) AND (S [SLen] <= ' ') Do
      Dec(SLen);
    I := 1;

    While (I <= SLen) AND (S [I] <= ' ') Do
      Inc(I);

    Dec(I);

    If I > 0 Then
      Delete(S, 1, I);

    RemoveBlanks := S;

End;

// Extend String
Function ExtendString(S : String; Anz : Byte) : String;
Var
  S1 : String[255];

  Begin
    S1 := S;
    While Length(S1) < Anz Do S1 := S1 + ' ';
      S1 := Copy(S1, 1, Anz);

    ExtendString := S1;
End;

// Converts String To Hexadecimal
// Maybe usefull for a hex-editor
// For example:
//     Input = 'ABCD'
//     Output = '41 42 43 44'
function ConvertsStringToHexadecimal(Data: string): string;
var 
  i, i2: Integer;
  s: string;
begin
  i2 := 1;
  for i := 1 to Length(Data) do
  begin
    Inc(i2);
    if i2 = 2 then
    begin
      s  := s + ' ';
      i2 := 1;
    end;
    s := s + IntToHex(Ord(Data[i]), 2);
  end;
  Result := s;
end;

// Feb 25, 2009 3:21 PM
Function ConvertHexadecimalToString(value : String) : String;
var
  buf   : PansiChar;
  l     : Integer;
begin
  while pos(' 00', value) > 0 do
    delete(value,pos(' 00', value), 3);
  while pos(' ', value) > 0 do
    delete(value, pos(' ', value), 1);
  value   := value + '00';
  l       := length(value) div 2+1;
  buf     := AllocMem(l);

  HexToBin(PAnsiChar(value), buf, l);

  result  := buf;
end;

// Added on Feb 25, 2009 2:42 PM
procedure WriteHex(var f: text; var s, name: string; x: char);
  const hexstr: string[16] = '0123456789ABCDEF';
  var i: word;
      c: char;
  begin
    for i := 1 to length(s) do begin
      c := s[i];
      if c = x
        then write(f,'?? ')
        else write(f,hexstr[ord(c) shr 4+1],hexstr[ord(c) and 15+1],' ');
    end;
    for i := length(s)*3 to 79-length(name) do write(f,' ');
    writeln(f,name);
  end;

// Left Pad Char
// the second TempS = 0 is not working
Function LeftPadCH(S : String; Ch : Char; Len : Byte) : String;
Var
  TempS : String;

Begin
  If Len > Length(S) Then Begin
    FillChar(TempS[1], Len - Length(S), Ch);
    TempS[2] := Chr(Len - Length(S));
    LeftPadCH := TempS + S;
  End Else Begin
    LeftPadCH := S;
  end;
End;

// 0 is not Working
Function PadCH(S : String; Ch : Char; Len : Byte) : String;
Var
  TempS : String;
Begin
    TempS := '';
    If Len > Length(S) Then Begin
      FillChar( S [Succ (Length (S))], Len - Length (S), Ch);
      S [1] := Chr(Len);
    end;
    PadCH := S;
End;

// triming string
Function TrimString(S : String) : String;
Var
  I : Word;
  SLen : Byte Absolute S;

Begin
  While (SLen > 0) AND (S [SLen] <= ' ') Do Begin
    Dec(SLen);
  end;

  I := 1;
  While (I <= SLen) AND (S [I] <= ' ') Do Begin
    Inc(I);
  end;

  If I > 1 Then Delete(S, 1, Pred(I));

  TrimString := S;
End;

function IntStrToKey(S : String) : String;
Var
  I : Integer;
Const
  LowIntChar = #128;
  HiIntChar = #165;
  ToKeyTable : Array [LowIntChar..HiIntChar] Of Char = (
      'C', 'U', 'E', 'A', 'A', 'A', 'A', 'C', 'E', 'E', 'E', 'I', 'I',
      'I', 'A', 'A', 'E', 'A', 'A', 'O', 'O', 'O', 'U', 'U', 'Y', 'O',
      'U', '›', 'œ', '', 'ž', 'Ÿ', 'A', 'I', 'O', 'U', 'N', 'N' );

Begin
  For I := 1 To Length(S) Do Begin
    Case S [I] Of
      LowIntChar..HiIntChar : Begin
        S [I] := ToKeyTable [S [I]];
      end;
      Else Begin
        S [I] := UpCase (S [I]);
        If S [I] = 'á' Then S [I] := 'S';
      end;
    end; // Case
  end; // Loop

  IntStrToKey := S;
End;

// (((((((((((((((((((((((((((((((((((((((((((((((((((((

// Convert PChar to non NULL string
function PCharToString(str : PChar) : string;
begin
  if (nil = str) then
    Result := ''
  else
    Result := str;
end;

// Load string value into PChar buffer without overflow
function StringToBuf(Const Str : String; Buf : pchar; maxlen : integer) : boolean;
var BytesToWrite : integer;
begin
  if (Assigned(buf) and (maxlen > 0)) then
  begin
    // Limit string length
    if (maxlen < Length(str)) then
      BytesToWrite := maxLen
    else
      BytesToWrite := Length(str);

    if (Length(Str) = 0)then
      Buf^ := #0
    else
    begin
      FillChar(Buf^,maxlen,#0);
      StrlCopy(Buf,PChar(str),BytesToWrite);
    end;
    Result := true;
  end
  else
    Result := false;
end;

function ForceExtension(Name, Ext : string) : string;
var
  DotPos : Word;
  {------}
  function HasExtension(Name : string; var DotPos : Word)
      : Boolean;
  var
    W : Word;
  begin
    DotPos := 0;
    For W := Length (Name) DownTo 1 do
    begin
      if (Name [W] = '.') and (DotPos = 0) then
      begin
        DotPos := W;
      end;
    end;
    result := (DotPos > 0) and
        (Pos ('\', Copy (Name, Succ (DotPos), 255)) = 0);
  end;
  {------}
begin
  if HasExtension(Name, DotPos) then
    result := Copy(Name, 1, DotPos) + Ext
  else
    result := Name + '.' + Ext;
end;


function SlashedDir(sDirName : string) : string;
//var len : integer;
  //  temp : string;
begin
  Result := IncludeTrailingPathDelimiter(sDirName);
  {
    len := Length(sDirName);
    if  (len > 0) then
    begin
      temp := sDirName[len];
      if  not ((temp = '\') or (temp = '/')) then
        sDirName := sDirName + '\';
    end;
    result := sDirName;
  }
end;

function FixCurrentPath(sAppPath : string) : string;
begin
  sAppPath := Trim(sAppPath);
  if sAppPath = '' then
    sAppPath := ExtractFilePath( ParamStr(0) );

  result := SlashedDir(sAppPath);
end;


function GetTempDir: string;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetTempPath(SizeOf(Buffer), Buffer));
end;

function GetWindowsDir: string;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetWindowsDirectory(Buffer, SizeOf(Buffer)));
end;

function GetSystemDir: string;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetSystemDirectory(Buffer, SizeOf(Buffer)));
end;

function findINI(iniFilename : string;var IniFilePath : string) : boolean;


   function tryDirectory( dir : string ) : boolean;
   var temp : string;
   begin
      temp := SlashedDir(Dir) + iniFileName;
      result := FileExists(temp);
      if result then iniFilePath := temp;
   end;

begin
  if (iniFileName = '') then
    iniFileName := ForceExtension(ExtractFileName( ParamStr(0) ), 'ini');

  result := tryDirectory( getCurrentDir ) or
            tryDirectory( getWindowsDir ) or
            tryDirectory( getSystemDir );
end;


const
 CRLF       = Chr(13) + Chr(10);

procedure WriteStringListToTextStream(stream : TStream; list : TStringList);
var i : integer;
    s : string;
begin
   for i := 0 to list.Count-1 do
   begin
      s := list[i] + CRLF;
      stream.Write(PChar(s)^, Length(s));
   end;
end;

///  What !?????
procedure WriteStringListToTextFile(fileName : string; list : TStringList);
//var stream : TFileStream;
begin
  list.SaveToFile(fileName);
  {
  stream := TFileStream.Create(fileName, fmCreate );
  try
    WriteStringListToTextStream(stream, list);
  finally
    stream.Free;
  end;
  }
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}

// Added Feb 25, 2009
Function RandomPassGeneration(syllables, numbers: Byte): String;

  function Replicate(Caracter: string; Quant: Integer): string;
  var 
    I: Integer;
  begin
    Result := '';
    for I := 1 to Quant do
      Result := Result + Caracter;
  end;
const
  conso: array [0..19] of Char = ('b', 'c', 'd', 'f', 'g', 'h', 'j',
    'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z');
  vocal: array [0..4] of Char = ('a', 'e', 'i', 'o', 'u');
var
  i: Integer;
  si, sf: Longint;
  n: string;
begin
  Result := '';
  Randomize;

  if syllables <> 0 then
    for i := 1 to syllables do
    begin
      Result := Result + conso[Random(19)];
      Result := Result + vocal[Random(4)];
    end;

  if numbers = 1 then Result := Result + IntToStr(Random(9))
  else if numbers >= 2 then
  begin
    if numbers > 9 then numbers := 9;
    si     := StrToInt('1' + Replicate('0', numbers - 1));
    sf     := StrToInt(Replicate('9', numbers));
    n      := FloatToStr(si + Random(sf));
    Result := Result + Copy(n, 0,numbers);
  end;
end;

procedure Splitt(var ts : TStringList; thing: string; delimeter: string);
var
    buffer: string;
begin
    repeat
      if (copy(thing,1,1) = copy(delimeter,1,1)) and (copy(thing,1,length(delimeter)) = delimeter) then
      begin
        ts.Add(buffer);
        buffer := '';
        thing := copy(thing,2,length(thing));
      end
      else
      begin
        buffer := buffer + copy(thing,1,1);
        thing := copy(thing,2,length(thing));
      end;
      if thing = '' then
      begin
        buffer := buffer + thing;
        ts.Add(buffer);
        buffer := '';
        thing := '';
      //end;
      end;
    until thing = '';
end;

procedure SplitString(str : string; delim : string;var left, right : string);
var p : integer;
begin
  p := pos(delim, str);
  if (p = 0) then
  begin
    left := str;
    right := '';
  end
  else
  begin
    left := LeftStr(str, p-1);
    inc(p, Length(delim));
    right := Copy(str, p + length(delim) - 1, Length(str));
  end;
end;

procedure SwapDatesIfNeeded(var startDate, endDate : TDateTime);
var tempDate : TDateTime;
begin
  if (startDate > endDate) then
  begin
    tempDate := startDate;
    startDate := endDate;
    endDate := tempDate;
  end;
end;

procedure ValidateDirExists(const directoryName : string);
begin
  if not DirectoryExists(directoryName) then
    Raise Exception.Create('Directory "' + directoryName + '" does not exist.');
end;


//#CM 10/08/02

function AVIDateToDateTime(Date_int: Word; Time_int: Word = 0): TDateTime;
begin
  Result := Date_int + 366;
  //#CM 05/21/03
  if Time_int > 0 then
    Result := Result + (Time_int / (60 * 24));
end;


//#CM 10/08/02
function DateTimeToAVIDate(ADateTime: TDateTime): Word;
begin
  if ADateTime >= 366 then
    Result := Trunc(ADateTime) - 366
  else
    Result := 0;
end;

{ COMMENTED
function Import_find_entry(ATable_code: String; AEntry_code: String): LONGINT;
  var
    Table_recno: LONGINT;

  begin
    Result := 0;
    Table_recno := 1;
    while Import_get(Table_file, Table_recno) do
    begin
      with Table_record(Import_blocks[Table_file]^) do
      begin
        if (Table_recd = Active_record) and (Table_code = ATable_code) then
        begin
          Result := 1;
          while Import_get(Entry_file, Result) do
          begin
            with Entry_record(Import_blocks[Entry_file]^) do
            begin
              if (Entry_recd = Active_record) and (Entry_table = Table_recno) and (Entry_code = AEntry_code) then
                EXIT;
            end;
            Inc(Result);
          end;

          Result := 0;
          BREAK;
        end;
      end;
      Inc(Table_recno);
    end;
  end;
  }
end.
