//{$INCLUDE mcs.inc}

unit umcsTypes;

interface

const
  SFalse = 'F';
  STrue = 'T';
  SLongFalse = 'False';
  SLongTrue = 'True';
  SNo = 'N';
  SYes = 'Y';
  SLongNo = 'No';
  SLongYes = 'Yes';

  BooleanStrings: array[Boolean] of string = (SFalse, STrue);
  YesNoStrings: array[Boolean] of string = (SNo, SYes);
  BooleanLongStrings: array[Boolean] of string = (SLongFalse, SLongTrue);
  YesNoLongStrings: array[Boolean] of string = (SLongNo, SLongYes);

type
  TExact2 = type Integer;
  TExact3 = type Integer;
  TRecno = type Integer;

  TString2 = string[2];
  TString3 = string[3];
  TString4 = string[4];
  TString5 = string[5];
  TString6 = string[6];
  TString7 = string[7];
  TString8 = string[8];
  TString9 = string[9];
  TString10 = string[10];
  TString11 = string[11];
  TString12 = string[12];
  TString13 = string[13];
  TString14 = string[14];
  TString15 = string[15];
  TString16 = string[16];
  TString17 = string[17];
  TString18 = string[18];
  TString19 = string[19];
  TString20 = string[20];
  TString25 = string[25];
  TString26 = string[26];
  TString30 = string[30];
  TString31 = string[31];
  TString33 = string[33];
  TString35 = string[35];
  TString40 = string[40];
  TString50 = string[50];
  TString60 = string[60];
  TString65 = string[65];
  TString80 = string[80];

  TCodeString = type TString8;
  TDoctorString = type TString3;
  TFileString = type TString8;
  TDiscountClass = type Byte;

  TAVIDate = type Word;
  TAVITime = type Word;

implementation

end.
