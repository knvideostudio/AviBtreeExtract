// Latest Update: Feb 09, 2009
// Author: Krassimir
// Veterinary Metrics, Inc.
// Release Version: 3.0.9.0
// Output file: VetMetAviVM

library VetMetAviVM;
uses
  ExtractData in 'ExtractData.pas',
  ServiceCodes in '.\Common\ServiceCodes.pas',
  uRecStruct in '.\Common\uRecStruct.pas',
  Utils in '.\Common\Utils.pas';

{$E .dll}
{$R *.res}

exports
  GetLastErrorMessage,
  EnumServiceCodes,
  EnumServiceCodes2,
  EnumClientData,
  EnumUserData,
  EnumBreedData,
  EnumColorData,
  EnumSpeciesData,
  EnumReminderData,
  EnumTreatData,
  EnumInventoryData,
  EnumInvoiceData,
  EnumPetData,
  EnumScriptCodeData,
  EnumHistoryMedicalData,
  EnumResultData,
  EnumGetDataVersion,
  EnumWpCodeData;

  { Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }
begin
end.
