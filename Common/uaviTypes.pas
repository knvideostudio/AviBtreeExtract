(*
   Copyright (c) 1997-2005 McAllister Software Systems
   ALL RIGHTS RESERVED

   The entire contents of this file is protected by U.S. and
   International Copyright Laws. Unauthorized reproduction,
   reverse-engineering, and distribution of all or any portion of
   the code contained in this file is strictly prohibited and may
   result in severe civil and criminal penalties and will be
   prosecuted to the maximum extent possible under the law.
*)

{-$INCLUDE AVIMARK.INC}
{$H+}

unit uaviTypes;

interface
                                        
uses
  SysUtils,
  Classes,
  Graphics,
  umcsTypes;

  // put all types from AVITYP here, e.g. enumerated types, set types, constants
  // but don't put the record definitions themselves
  // that way all of the framework units can compile w/out having to use AVITYP.pas

type
  //originally from AVITYP
  Code_string = string[8];
  File_string = string[8];

  TUserGroupTag = class(TObject)
    Tag_group: Integer;
  end;

  TVendorTag = class(TObject)
    Tag_vendor: Integer;
  end;

  TLanguage = (lngEnglish, lngSpanish, lngPortugese);           //Ask if we need this????

  TEntryTag = class(TObject)
    Tag_entry: Integer;
  end;

  TTaxType = (ttNone, ttLocal, ttState, ttTaxed);

  TMoreStuffPosNeg = (mspnNone, mspnPositive, mspnNegative, mspnInconclusive);

  TMoreStuffSensRes = (mssrNone, mssrResistant, mssrModSuscept, mssrSusceptible, mssrNotTested,
    mssrNotDone);

  TMoreStuffEntryType = (msetClient, msetPatient, msetTable, msetSubjective, msetObjective,
    msetAssessment, msetPlan, msetCheckin, msetWhiteboard);

  TBaud_rate = (br110, br300, br1200, br2400, br4800, br9600, br19200, br38400, br57600, br115200);
  TParity_value = (pvNone, pvOdd, pvEven, pvMark, pvSpace);

  Called_type = (cbByCID, cbByEstimate, cbByQuote, cbByUsage, cbByPlan, cbByAppointment,
    cbByMedical, cbByReminder, cbByOther, cbByOrder, cbByWhiteboard);
  History_type = (htOther, htTreatment, htInventory, htDiagnosis);
  History_type_set = set of History_type;
  Lab_type = (ltAntech, ltOther);
  Quality_type = (rqVoid, rqLetter, rqPicture);
  Note_type = (ntAppointment, ntFollowUp, ntEstimate, ntInstruction, ntEmail);
  Merge_type = (mtNormal, mtAll, mtCertificate, mtReminder, mtEstimate);
  PrtReminderType = (rtNormalReminder, rtConsolidatedReminder);
  Audit_who = (awNoOne, awAllButAdmin, awEveryone);
  Request_type = (drNone, drFind, drSearch, drLast, drNext, drPrev, drPosition, drInsert, drDelete,
    drShutDown, drRestart);
  MoveTo_type = (npNone, npNext, npPrev);
  Quotail_types = (qtIsOther, qtIsTreatment, qtIsItem, qtIsDiagnosis);
  Remind_titles = (rtNone, rtPlain, rtWeight);
  Alert_sent_by = (sbByNormal, sbByMedical);

  TAnimal_status = (astOutPatient, astOther, astBoarded, astHospitalized);
  TAnimalStatusSet = set of TAnimal_status;

const
  AnimalInPatientStatusTypes: TAnimalStatusSet = [astOther, astBoarded, astHospitalized];

type
  TRefill_result = (reOk, reRefillsExceeded, reTooSoon, reExpired);
  TFile_org = (poByNeither, poByClient, poByPatient);
  TTimeClock_access = (taByNeither, taByName, taByIP, taByAPI);
  TTable_type = (ttNormal, ttZip, ttSpecies, ttVaccines, ttPlans, ttAudit, ttFees, ttAllergy,
    ttBreed, ttPayments, ttTax, ttRelationship, ttCompany, ttAntech, ttColor, ttData, ttFacilities,
    ttTables, ttProblem_deprecated, ttAbnormalities, ttWorkList, ttAntechProfile,
    ttTimeclock, ttFormulary, ttWhiteboardCategories, ttCounty, ttIndication, ttRoute,
    ttClientDiscountClass, ttDiscountClass, ttMeasure);
  TParent_type = (ptByNone, ptByService, ptByEstimate);
  TRelation_fields = (relTitle, relLastName, relFirstName, relAddress, relAddress2, relCity,
    relState, relZip, relPhone, relBusiness, relFaxNo, relEmail);
  TUsage_by = (ubByNone, ubByService, ubByTreatment, ubByItem);
  TExpand_linked = (elNever, elAsk, elAlways);
  TAppoint_type = (atReservation, atKept, atCanceled, atNoShow, atRescheduled, atLate);
  TRabiesAssign = (raNone, raAlways, raCanines, raFelines, raEquines);
  TRabiesPrompt = (rpNone, rpAlways, rpCanines, rpFelines, rpEquines);
  TRabiesCertificates = (rcNone, rcAlways, rcCanines, rcFelines, rcEquines);
  TAttachmentTransferType = (attNeither, attCopy, attMove);
  TDosingScheduleType = (dstNone, dstQD, dstBID, dstTID, dstQID);
  TCreditCardType = (cctVisa, cctMasterCard, cctDiscover, cctAmericanExpress, cctOther);

  TFormularyRoute = (frOral, frInEar, frInEye, frIM, frIV, frSQ, frIP, frRectal, frOther);
  TFormularyDoseUnitType = (fdutUnknown, fdutMgKg, fdutIuKg, fdutMeqKg, fdutMlsKg, fdutUnitsKg, fdutMgM2);

  TOrder_states = (Non_order, New_order, Open_order, Received_order, Back_order);

  TClient_flag_set = set of (cfPublicNotes, cfQualitySetByUser);

  TRemind_as_array = array of AnsiString;
  TReports_chosen = (rsAccountSummary, rsAuditTrail, rsControlledSubstance, rsDepositSlip,
    rsIncomeByTreatment, rsPatientsByTreatment, rsPeriodTotals, rsPaymentSummary,
    rsRabiesReport, rsReferralReport, rsSalesSummary, rsTransactionJournal, rsTransactionSummary,
      rsTreatmentControlLog, rsUnpostedTransactions, rsOpenInvoices,
    rsHealthPlan, rsHeldChecks, rsIncomebyProvider, rsTaxByArea);
  Reports_set = set of TReports_chosen;

  Doctor_str = string[3];
  Room_str = string[3];
  TWhiteboardCodeString = string[3];

  Closing_set = record
    Closing_recno: Integer;
    Closing_date: Word;
    Closing_time: Word;
    Closing_by: TDoctorString;
    Closing_reserv: array[1..10] of Byte;
  end;

  Reminder_set = record
    Reminder_text: Integer;
    Reminder_name: string[30];
  end; // Reminder_set

  Discount_schedule = record
    Discount_name: string[30];
    Discount_bycost: Boolean;
    Discount_rates: array[1..20] of Byte; //#RWM 12/09/02
  end; // Discount_schedule

  Search_record = record
    Search_client: Integer;
    Search_animal: Integer;
  end; // Search_record

  THospital_board_colors = record
    Reservation_color: TColor;
    Reservation_overlap: TColor;
    Check_in_color: TColor;
    Check_in_overlap: TColor;
    Color_reserve: array[1..128] of Byte;
  end;

  THospital_appt_colors = record
    Normal_color: TColor;
    Normal_overlap: TColor;
    Selected_color: TColor;
    Blockoff_color: TColor;
    Blockoff_overlap: TColor;
    Color_reserve: array[1..128] of Byte;
  end;

  Aging_buckets = array[1..5] of Integer;

  THospitalPaymentType = (ptNone, ptCheck, ptCash);
  THospital_charge_by = (cbDay, cbNight, cbHotel);
  TAuto_pay = (apNone, apInvoice, apBalance);
  TAlert_when = (awNone, awOnce, awSelected);
  TChart_length = (clDays, clMonths, clVisits);
  TReminder_edit = (erMSWord, erAVImark);
  TInvoice_organization = (ioByDisplayed, ioByChronological, ioByDoctor, ioByCategory);
  TInvoice_orientation = (ioHorizontal, ioVertical);
  THospitalEnvelope = (heIF, heStandard, heArtina);

  TScrollingType = (sctNone, sctUp, sctDown, sctLeft, sctRight);
  TReminder_magazine = (rmHealthyPet, rmPetQuarterly, rmPawPrint, rmUSNetCom); //#LC  3/5/04

  THospital_calendar_format = (cfDailyConsolidated, cfDailyByDoctor, cfWeeklyByRoom,
    cfDailyByRoom);
  THospital_per_page = (ppOne, ppThree, ppFour, pp6490);
  TGraphUsing = (guAVImark, guExcel);
  TChange_when = (cwNever, cwBalance, cwInvoice);

  TAccount_flag = (afDetail, afExported, afPublic);
  TAccount_flags = set of TAccount_flag;

  TAnimal_flags = set of (pfPublicNotes, pfPublicChartNotes, pfMedicalAlert, pfBirthdayUnknown);

  TService_flag = (sfRemindAs, sfChanged, sfPublicNotes, sfDeclined, sfPublic, sfNotesAligned,
    sfRefill, sfPrintNotes);
  TService_flag2 = (sfLabelNotes, sfFollowNotes, sfApptNotes, sfTrackRefills, sfResultsImported,
    sfEnteringNote, sfNotesLocked, sfHiddenNotes, sfOpen, sfClosed, sfAntechPrintable, sfReserv12,
    sfReserv13, sfReserv14, sfReserv15, sfReserv16);
  TService_flags = set of TService_flag;
  TService_flags2 = set of TService_flag2;

  TAppoint_flags = set of (afPublicNotes, afAlert);

  TAppoint_history = record
    Appoint_history_type: History_type;
    Appoint_history_recno: Integer;
  end; // TAppoint_history

  TAppoint_problem_flags = set of (apfNone);
  TAppoint_problem = record
    Appoint_problem_recno: Integer;
    Appoint_problem_flags: TAppoint_problem_flags;
  end;

  TAppoint_confirm = (acNotConfirmed, acConfirmed, acLeftMessage);
  TAppoint_parentis = (apIsAnimal, apIsUser);

  TBlockOff_apply = (boaWeekly, boaMonthly);

  TBlockOff_week = set of 0..6;
  TBlockOff_month = array[1..6] of TBlockOff_week;

  TReminder_term_type = (rcInNone, rcInYears, rcInMonths, rcInWeeks, rcInDays);
  TReminder_how_type = (rwAtAge, rwInTerm, rwOnDate);
  TReminder_send_type = (rsAsRequested, rsOneNotice, rsTwoNotice, rsThreeNotice);
  TReminder_priority_type = (rpAlwaysRemind, rpRemindIfOthers, rpRemindNever);
  TReminder_annual_type = (raNoAnnual, raOneAnnual, raTwoAnnual, raThreeAnnual);
  TReminder_sex_type = (rxIfAny, rxIfFemale, rxIfMale, rxIfSpay, rxIfNeuter);
  TReminder_parent_type = (rpIsAnimal, rpIsTreatment, rpIsItem, rpIsDiagnosis);
  TReminder_flag = (rfQtyMultiplier, rfIncludeInVaccineHistory);
  TReminder_flags = set of TReminder_flag;
  TReminderSentBy = (rsbUnknown, rsbEmail, rsbPostCard, rsbPawPrint, rsbPetQuarterly, rsbHealthyPet,
    rsbUSNetCom);
    
  TReminder_appropriate = (remtAppropriate, remtNASex, remtNADueDate, remtNAEndDate,
    remtNANotTreated, remtNACount, remtNASeries, remtNASeriesComplete);

  TTreatmentFlag = (tfPublicComments, tfNoTagAlong, tfPublicInstructionsPad, tfPriceNormally,
    tfOnInvoice, tfAllowOverride, tfIncludeTagAlongsOnWhiteBoard);
  TTreatmentFlags = set of TTreatmentFlag;

  TTreatment_description = string[40];

  THeader_name = string[31];

  TDiagnosis_species1 = array[1..8] of Char;
  TDiagnosis_description = string[38];
  TDiagnosis_codes = string[6];

  TDiaghdr_name = string[30];

  TVariance_is = (viByPercent, viByAmount, viByQuantity);
  TTaskFlags = set of (tfPublicNotes);

  TTable_flags = set of (tfAllowAutoAdd);

  TEntry_description = string[50];

  TBoardingStatusType = (bsReservation, bsBoarding, bsHospitalization, bsOther, bsCheckedOut);
  TBoard_type = (btReservation, btCheckedIn, btCheckedOut, btCanceled, btNoShow, btKept,
    btRescheduled);
  TBoard_types = array[TBoard_type] of string[15];

  TActivity_type = (atTreatment, atMedication, atFeeding, atExercise, atAtCheckOut);
  TActivity_measure = (In_minutes, In_hours, In_days, In_weeks);
  TWhiteboardActivityCategoryPending = (wacpNone, wacpPending, wacpOverdue);

  Item_flag_set = set of (ifItem_break_markup, ifItem_priority, ifPublicInstructionsPad,
    ifPublicNotes);

  TItem_description = string[40];

  TCategory_name = string[31];

  TUsageFlag = (ufDontPrice, ufPostToSoap, ufTrackCompliance);
  TUsage_flags = set of TUsageFlag;

  Usage_ptype = (upIsOther, upIsTreatment, upIsService, upIsDiagnosisPad, upIsDiscount, upIsProblemPad,
    upIsReserved, upIsAbnormality, upIsRuleOut, upIsDiagPlan, upIsTreatPlan,
    upIsSubjective, upIsDiagnoses, upIsItem, upIsTemplate);

  Order_head = record
    case Integer of
      1: (Order_hdate: Word); { Order RRN = 1: Release date for order }
      2: (Order_hvendor: Code_string); {           = 2: Vendor code }
      3: (Order_hstatus: Word); {           = 3: Date order took on current state }
      4: (Order_hitem: Code_string); {           = all others: Item_code }
  end; { Order_head }

  TPrice_action = (paNone, paManual, paReceipt, paMarkup);

  TUser_notify = (upNever, upAtLogon, upAtClientSelect, upAtIdle);
  TUser_type = (utFullType, utPartType, utNonVet);
  TUser_access = (uaFull, uaAddHistory, uaAddPatients, uaReadOnly);

  TUser_id = string[3];

  TQuote_status = (qsActive, qsPosted, qsDeleted);

  TQuotail_flag = (qfPublicNotes, qfAllowReprice);
  TQuotail_flags = set of TQuotail_flag;

  TModel_type = (mtAge, mtDate, mtDecimal, mtDiag, mtInteger, mtItem, mtPhoto, mtPhrase, mtPosNeg,
    mtSensRes, mtTable, mtTime, mtTreat, mtUser, mtWP, mtYesNo, mtChecked);

  TModel_code = (mcOnPatientChart, mcSearchable, mcMergeWord, mcPrintIfPositive, mcMustChoose,
    mcNoPrintPrompt);
  TModel_codes = set of TModel_code;
  TModel_universal = array[0..SizeOf(TModel_codes) - 1] of Byte;
  TModel_parentis = (mpIsTreatment, mpIsEntry);

  TListStatus = (lsNew, lsWorking, lsComplete);
  TListStatusSet = set of TListStatus;

  TVariance_flags = set of (vfNone);

  PSite_option = ^Site_options;
  Site_options = record
    Site_same: Boolean;
    Site_same_site: Integer;
    Site_copy_site: Integer;
    Site_options_reserv: array[1..25] of Byte;
  end;

  TSite_list_options = array[htTreatment..htDiagnosis] of Site_options;

  TLog_flag = (lfChanged, lfAdded);

  TResults_parentis = (xpIsService, xpIsMedical, xpIsClient, xpIsAnimal, xpIsResults, xpIsCheckin,
    xpIsWhiteboardActivity);

  Report_sorttype = (soNone, soAscending, soDescending);

  PReport_set = ^Report_set;
  Report_set = record
    Report_column: Byte;
    Report_width: Byte;
    Report_heading: string[30];
    Report_precedence: Byte;
    Report_sortorder: Report_sorttype;
    Report_subtotal: Boolean;
    Report_sum: Boolean;
    Report_count: Boolean;
    Report_average: Boolean;
    Report_median: Boolean;
    Report_deviation: Boolean;
    Report_maximum: Boolean;
    Report_minimum: Boolean;
    Report_reserve: array[1..16] of Byte;
  end; { Report_set RECORD }

  TField_set_names = array[1..20] of string[15];
  TField_set_tests = array[1..20] of Byte;
  TField_set_value = array[1..20] of Integer;
  TField_set_report = array[1..20] of Report_set;
  TField_set_merge = array[1..20] of Boolean;

  PField_set = ^TField_set;
  TField_set = record
    Field_names: TField_set_names;
    Field_tests: TField_set_tests;
    Field_value: TField_set_value;
    Field_report: TField_set_report;
    Field_omit: Boolean;
    Field_merge: TField_set_merge;
    Field_reserve: array[1..90] of Byte;
  end; { Field_set RECORD }

  TField_set_array = array[0..9] of TField_set;

  TImport_type = (impAdded, impChanged, impNote, impAlert, impResults, impSubjNotes, impExamNotes,
    impTPlanNotes, impInstruction, impDefaultReminder, impDPlanNotes, impDiagNotes, impRuleNotes);

  TAnalysis_parms = record
    Analysis_date: Word;
    Analysis_term: Integer;
    Analysis_send: Integer;
    Analysis_exclude: Boolean;
    Analysis_excludelist: TStringList;
    Analysis_includelist: TStringList;
  end; 

  // originally from AVICOM
  TaviPrinterArea = (pareaInvoices, pareaPatientCharts, pareaReminders, pareaDrugLabels,
    pareaReports, pareaStatements, pareaInventory, pareaDocuments, pareaOther, pareaOtherLabels,
    pareaPreview, pareaReceipt);

  TInstrument_def = record
    Instrument_com_port: Integer;
    Instrument_baud_rate: Integer;
    Instrument_data_bits: Integer;
    Instrument_parity: Integer;
    Instrument_stop_bits: Word;
  end;

  TInstrument_types = (itAbaxisHMT, itAbaxisVetScan, itCDCHemavet, itHemagen, itHeskaABC,
    itHeskaSpotchemEZ, itIDEXXVettest, itIDEXXLaserCyte, itHeskaCBC, itScilVetABC, itForcyte,
    itHMII);
  TInstrument_definitions = array[TInstrument_types] of TInstrument_def;
  TWorkLists_sortby = (ByAddedOn, ByAddedBy, ByAcceptedOn, ByAcceptedBy, ByStatus, ByPatientName,
    ByClientName);

  TOLE_office_type = (oleWord, oleStarOffice);

  TaviOptionAccessType = (oatByDefault, oatBySite, oatByUser);

  TaviThumbnailSize = (tsTiny, tsSmall, tsMedium, tsLarge);

  TGlossaryArea = (gaNone, gaAbnormality, gaAccounting, gaAlerts, gaAppointments, gaBoarding,
    gaWhiteboard, gaClients, gaDiagnosis, gaEmail, gaEstimates, gaFollowups, gaHistory,
    gaHospitalSetup, gaInventory, gaInvoicing, gaLabResults, gaMedicalCondition, gaSOAPSubjective,
    gaSOAPObjective, gaSOAPAssessment, gaSOAPPlan, gaPatients, gaProblems, gaQA, gaReminders,
    gaSystemTables, gaTreatments, gaTimeclock, gaWorkLists);

  TEntryHistory_type = (ehtCreated, ehtPropertyChanged);

  TProtocolEntryFlag = (ppfPostToSoap, ppfTrackCompliance);
  TProtocolEntryFlags = set of TProtocolEntryFlag;


  TPetIDSendType = (pidstOvernight, pidstOnDemand);

implementation

end.
