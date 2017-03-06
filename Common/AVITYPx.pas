unit AVITYPx;
{$R-}

//{$INCLUDE AVIMARK.INC}
{$J-} // $J+ anywhere in this unit indicates a global variable.

interface

uses
  Classes,
  Graphics,
  SysUtils,
  NumKey32,
  Filer,
  umcsTypes;

type
  TBaud_rate = (br110, br300, br1200, br2400, br4800, br9600, br19200, br38400, br57600, br115200);
  TParity_value = (pvNone, pvOdd, pvEven, pvMark, pvSpace);

const
{$IFDEF SouthAfrica}
  App_title = 'GlobalVet';
{$ELSE}
  App_title = 'AVImark';
{$ENDIF}
  RT_types = 20;
  Baud_values: array[TBaud_rate] of Integer = (110, 300, 1200, 2400, 4800, 9600, 19200, 38400,
    57600, 115200);

type
   TAVImark_indexes = (aviidxClient,
    aviidxAnimal,
    aviidxService,
    aviidxTreatment,
    aviidxInventory,
    aviidxLists,
    aviidxAccount,
    aviidxSecurity,
    aviidxReminder,
    aviidxTable,
    aviidxDiagnosis,
    aviidxEstimate,
    aviidxAppoint,
    aviidxFollow,
    aviidxSplit,
    aviidxBoard,
    aviidxMore,
    aviidxQA,
    aviidxProbHist,
    aviidxProblem,
    aviidxTimeclock,
    aviidxFormTemplate,
    aviidxOptionValue,
    aviidxAttachment,
    aviidxGlossary,
    aviidxEntryHistory,
    aviidxDiscountRate,
    aviidxDentalCharts,
    {$IFDEF EquineVersion}
    aviidxEquineRegistry,
    {$ENDIF}
    aviidxReminder2
    );
    
  Index_flags = set of TAVImark_indexes;

  TCPClientException = class(Exception); //#CM 05/30/02

  TEntryTag = class(TObject)
    Tag_entry: Integer;
  end;

  TLanguage = (lngEnglish, lngSpanish, lngPortugese);

  TVendorTag = class(TObject)
    Tag_vendor: Integer;
  end;

  TUserGroupTag = class(TObject)
    Tag_group: Integer;
  end;

  //#CM 02/06/03 moved to implementation of AVICOM
{  RemindSrt_record = record
     RemindSrt_key   : Word;     // Due date for this reminder
     RemindSrt_recno : Integer;  // Reminder RRN
  end;  // RemindSrt_record  }

  Code_string = string[8];
  File_string = string[8];

  Called_type = (cbByCID, cbByEstimate, cbByQuote, cbByUsage, cbByPlan, cbByAppointment,
    cbByMedical, cbByReminder, cbByOther, cbByOrder);
  History_type = (htOther, htTreatment, htInventory, htDiagnosis);
  History_type_set = set of History_type;
  Quality_type = (rqVoid, rqLetter, rqPicture);
  Note_type = (ntAppointment, ntFollowUp, ntEstimate, ntInstruction);
  Merge_type = (mtNormal, mtAll, mtCertificate, mtReminder, mtEstimate);
  PrtReminderType = (rtNormalReminder, rtConsolidatedReminder);
  Audit_who = (awNoOne, awAllButAdmin, awEveryone);
  Request_type = (drNone, drFind, drSearch, drLast, drNext, drPrev, drPosition, drInsert, drDelete,
    drShutDown, drRestart);
  MoveTo_type = (npNone, npNext, npPrev);
  Quotail_types = (qtIsOther, qtIsTreatment, qtIsItem, qtIsDiagnosis);
  Remind_titles = (rtNone, rtPlain, rtWeight);
  Alert_sent_by = (sbByNormal, sbByMedical);
  TAnimal_status = (astNone, astOutPatient, astBoarded, astHospitalized, astReleased,
    astCheckedOut);
  TRefill_result = (reOk, reRefillsExceeded, reTooSoon, reExpired);
  TPhoto_org = (poByNeither, poByClient, poByPatient);
  TTimeClock_access = (taByNeither, taByName, taByIP, taByAPI);
  TTable_type = (ttNormal, ttZip, ttSpecies, ttVaccines, ttPlans, ttAudit, ttFees, ttAllergy,
    ttBreed, ttPayments, ttTax, ttRelationship, ttCompany, ttAntech, ttColor, ttData, ttFacilities,
    ttTables, ttProblem_deprecated, ttAbnormalities, ttGlossary, ttWorkList, ttAntechProfile,
    ttTimeclock, ttFormulary, ttWhiteboardCategories);
  TParent_type = (ptByNone, ptByService, ptByEstimate);
  TRelation_fields = (relTitle, relLastName, relFirstName, relAddress, relAddress2, relCity,
    relState, relZip, relPhone, relBusiness, relFaxNo, relEmail);
  TUsage_by = (ubByNone, ubByService, ubByTreatment, ubByItem);
  TExpand_linked = (elNever, elAlways);
  TAppoint_type = (atReservation, atKept, atCanceled, atNoShow, atRescheduled, atLate);

  Order_states = (Non_order, New_order, Open_order, Received_order, Back_order);

  TClient_flag_set = set of (cfPublicNotes, cfQualitySetByUser);

  TRemind_as_array = array of AnsiString; //#CM 03/12/03

  Reminder_set = record
    Reminder_text: Integer;
    Reminder_name: string[30];
  end; // Reminder_set

  TReports_chosen = (rsAccountSummary, rsAuditTrail, rsControlledSubstance, rsDepositSlip,
    rsIncomeByTreatment, rsPatientsByTreatment, rsPeriodTotals, rsPaymentSummary,
    rsRabiesReport, rsReferralReport, rsSalesSummary, rsTransactionJournal, rsTransactionSummary,
      rsTreatmentControlLog, rsUnpostedTransactions, rsOpenInvoices,
    rsHealthPlan, rsHeldChecks, rsIncomebyProvider, rsTaxByArea);
  Reports_set = set of TReports_chosen;

  Doctor_str = string[3];
  Room_str = string[3];

  Fees_AR_set = (Handling_fee, Service_fee);

  Discount_schedule = record
    Discount_name: string[30];
    Discount_bycost: Boolean;
    Discount_rates: array[1..20] of Byte; //#RWM 12/09/02
  end; // Discount_schedule

  Backup_set = record
    Backup_drive: Char;
    Backup_speed: Integer;
  end; // Backup_set

  Closing_set = record
    Closing_recno: Integer;
    Closing_date: Word;
    Closing_time: Word;
    Closing_by: TDoctorString;
    Closing_reserv: array[1..10] of Byte;
  end; // Closing_set

  ProcRem_record = record
    ProcRem_client: Integer;
    ProcRem_animal: Integer;
    ProcRem_reminder: Integer;
    ProcRem_which: Integer;
  end; // ProcRem_record

  Search_record = record
    Search_client: Integer;
    Search_animal: Integer;
  end; // Search_record

  TResult_parms = record
    // Used to send VetTest data values from ModMaint to EditRslt during auto-define
    Result_code: TCodeString;
    Result_names: TStringList;
    Result_values: TStringList;
  end; // TResult_parms

  RT_lens = array[1..RT_types] of Byte;
  RT_widths = array[1..RT_types] of Byte;
  RT_posnegt = array[1..6] of string[8];
  RT_senrest = array[1..6] of string[11];
  RT_yesnot = array[1..3] of string[3];
  RT_titert = array[1..11] of string[3];
  RT_names = array[1..RT_types] of string[7];

  Aging_buckets = array[1..5] of Integer;

  THospitalPaymentType = (ptNone, ptCheck, ptCash);
  THospital_charge_by = (cbDay, cbNight, cbHotel);
  TAuto_pay = (apNone, apInvoice, apBalance);
  TAlert_when = (awNone, awOnce, awSelected);
  TChart_length = (clDays, clMonths, clVisits);
  TSubstance_type = (stService, stAccount, stUsage, stOrder, stVariance);
  TReminder_edit = (erMSWord, erAVImark);
  TInvoice_organization = (ioByDisplayed, ioByChronological, ioByDoctor, ioByCategory);
  TInvoice_orientation = (ioHorizontal, ioVertical);

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

  TScrollingType = (sctNone, sctUp, sctDown, sctLeft, sctRight);
  TReminder_magazine = (rmHealthyPet, rmPetQuarterly, rmPawPrint); //#LC  3/5/04

  //#CM 08/06/02
  THospital_calendar_format = (cfDailyConsolidated, cfDailyByDoctor, cfWeeklyByRoom,
    cfDailyByRoom);
  THospital_per_page = (ppOne, ppThree, ppFour, pp6490);
  TGraphUsing = (guAVImark, guExcel);
  TChange_when = (cwNever, cwBalance, cwInvoice);

  THospital_remind_colors = record {1026}
    Normal_color: TColor;
    Overdue_color: TColor;
    Patient_specific_color: TColor;
    Never_treated_color: TColor;
    This_cycle_color: TColor;
    Color_reserve: array[1..128] of Byte;
  end; {1026}

  { Hospital file record layout definition }
  Hospital_record = record
    case Integer of
      1: (Hospital_name: string[40];
        Hospital_address: string[40];
        Hospital_address2: string[40];
        Hospital_city: string[20];
        Hospital_state: string[2];
        Hospital_zip: string[10];
        Hospital_norm_city: string[20];
        Hospital_norm_state: string[2];
        Hospital_norm_zip: string[10];
        Hospital_norm_area: string[3];
        Hospital_norm_company: Byte;
        Hospital_demo: Boolean;
        Hospital_account_aging: Boolean; { Print account aging on statements }
        Hospital_patient_summary: Boolean; { Print patient summary on statements }
        Hospital_border: Boolean;
        Hospital_phone: string[14];
        Hospital_motto: string[80];
        Hospital_use_POMR: Boolean;
        Hospital_reservation: Byte; { Default boarding reservation duration }
        Hospital_check_fee: Integer;
        Hospital_use_scheduler: Boolean;
        Hospital_print_referrals: Boolean;
        Hospital_always_area: Boolean;
        Hospital_terms: string[80];
        Hospital_skip_if_paid: Boolean; { Dont apply late fee if payment received within period }
        Hospital_current: string[80];
        Hospital_over_30: string[80];
        Hospital_over_90: string[80];

        Hospital_state_fee: Integer; { Statement handling fee }
        Hospital_apply_after: Word; { Apply late fee after this number of days }
        Hospital_late_rate: SINGLE; { Late fee rate on amount overdue > apply_after days }
        Hospital_minimum_late: Integer; { Minimum late fee }

        Hospital_appt_increment: Byte; { Number of minutes per appointment slot }
        Hospital_species: Code_string; { Default species for new patients }
        Hospital_remind_invoice: Boolean; { Print reminders on invoice }

        Hospital_prescription_add: Integer;
        Hospital_handling_add: Integer;
        Hospital_IVInjection_add: Integer;
        Hospital_IMInjection_add: Integer;

        Hospital_envelope: Byte; { ItemIndex OF EnvelopeBox for statement envelopes }
        Hospital_ePetrecords_installed: Boolean;
        Hospital_acct_by_company: Boolean;
        Hospital_separate_board: Boolean;
        Hospital_separate_appt: Boolean;
        Hospital_preinvoice_watermark: Boolean;
        Hospital_patient_label_break: Boolean;
        Hospital_padBBS: array[1..11] of Byte;
        Hospital_refer_document: File_string;
        Hospital_sidekick: Boolean; { Keep a log file or not  }
        Hospital_autopay: TAuto_pay; { Auto-payment when posting }
        Hospital_multi_AVI: Boolean;
          { Allow multiple copies of AVImark to be running on one workstation }
        Hospital_label_sequence: Boolean; { Print sequence number on drug labels }
        Hospital_invoice_chrono: Boolean; { List transactions chronologically on invoice }
        Hospital_checkout_control: Boolean; { Allow AVImark to control patient release/checkout }

        Hospital_spell_check: Boolean; { Auto-spell check notes, WP result fields, etc. }
        Hospital_alert: TAlert_when;
        Hospital_chart_length: Word;
        Hospital_chart_units: TChart_length;

        Hospital_interest_memo: Integer;
          { Offset in WP.VM$ of notation when balance due on invoice }
        Hospital_total_discounts: Boolean;
        Hospital_weekend_audit: Boolean; { Write to audit trail on weekends }
        Hospital_short_dates: Boolean;
        Hospital_refund_fees: Boolean; { TRUE if AVImark refunds fees on returned items }

        Hospital_prtimage_left: SINGLE;
        Hospital_prtimage_top: SINGLE;
        Hospital_prtimage_width: SINGLE;
        Hospital_prtimage_height: SINGLE;

        Hospital_drug_labels: Byte;
        Hospital_card_left: SINGLE;
        Hospital_boarding_ghosts: Boolean;
        Hospital_remind_no_appts: Boolean;

        Hospital_chart_memo: Integer; { Offset in WP.VM$ to memo to print at bottom of chart }

        Hospital_admitting_doctor: Boolean;
        Hospital_auto_refresh: Boolean;

        Hospital_clinic_id: string[10];
        Hospital_card_font: Byte;
        Hospital_patient_top: SINGLE;
        Hospital_label_top: SINGLE; { Drug label top margin }
        Hospital_via_internet: Boolean;
        Hospital_cookco_code: string[6];
        Hospital_SMTP_password: string[10]; { Password for secure e-mail servers }
        Hospital_SMTP_login: Boolean; //#CM 08/30/02
        Hospital_SMTP_userid: Integer; //#CM 08/30/02 phrase file
        Hospital_invoice_orientation: TInvoice_orientation; //#RWM 12/19/02
        Hospital_backup_logging: Boolean; //#CM 01/23/03
        Hospital_graph_using: TGraphUsing;
        Hospital_payment_doctor: Boolean;
          { TRUE if doctor required on payments--to support deposit slips by cash drawer }
        Hospital_autolock_notes: Boolean; //#CM 03/25/03 lock notes at invoice closing
        Hospital_changemaker: TChange_when;
          //#RWM Open change-maker when either payment >invoice amount or >balance due
        Hospital_choose_referral: Boolean;
        Hospital_journal_path: Integer;
        Hospital_zip_index_length: Byte;
        Hospital_show_censusnotes: Boolean;
        Hospital_label_license: Boolean; // Include doctor's license on drug label
        Hospital_client_quality: Boolean;
        Hospital_post_declined: Boolean;
        Hospital_logo_border: Boolean;
        Hospital_recover_deleted: Boolean;
        Hospital_web_address: Integer;

        Hospital_reminder_magazine: TReminder_magazine; //#LC 3/5/04
        Hospital_appoint_notify: set of TAppoint_type;
        Hospital_appoint_notify_min: Byte;
        //Hospital_pad              : Char;           //#LC Hospital_pad              : array[1..3] of Char;
        Hospital_round_by: Word;
        Hospital_show_exceptions: Boolean;
        Hospital_DEA_number: string[15];
        Hospital_no_date_warning: Boolean;
        Hospital_invoice_phone: Boolean;

        Hospital_invoice_organization: TInvoice_organization;
          //#RWM 12/03/02 - replace Hospital_watermark
        Hospital_logo_left: SINGLE;
        Hospital_logo_top: SINGLE;

        Hospital_invoice_weight: Boolean; { Print weight history on invoice }
        Hospital_expired_warning: Boolean;
        Hospital_cash_drawer: Byte;
        Hospital_instrument_comno: Byte;
        Hospital_cash_baud: TBaud_rate;
        Hospital_cash_data: Byte;
        Hospital_cash_parity: TParity_value;
        Hospital_cash_stop: Byte;
        Hospital_alt_norm_state: string[5]; { South Africa normal state }

        Hospital_board_last_days: Boolean;
          { TRUE if AVImark is to consider last day of reservation in availability algorithm }
        Hospital_norm_title: string[8]; { Default client title }

        Hospital_voice_path: string[30]; { Path for voice annotation files }
        Hospital_rabies_assign: Byte; { ItemIndex of selection for rabies tag assignment }
        Hospital_rabies_prompt: Byte; { ItemIndex of selection for rabies prompt }

        Hospital_rabies_document: string[8];
          { MS Word document name for default rabies certificate }
        Hospital_document_path: string[30]; { Path for MS Word documents }
        Hospital_photo_path: string[30]; { Path for photographs }

        Hospital_prescription: Integer; { Prescription fee }
        Hospital_prescription_min: Integer;
        Hospital_handling: Integer; { Handling fee }
        Hospital_handling_min: Integer;
        Hospital_IVinjection: Integer; { Intravenous injection fee }
        Hospital_IVInjection_min: Integer;
        Hospital_IMInjection: Integer; { Intra-muscular injection fee }
        Hospital_IMInjection_min: Integer;

        Hospital_rabies_certificate: Byte; { ItemIndex of selection for rabies certificates }
        Hospital_label_DEA: Boolean; // Include doctor's DEA no. on drug label
        Hospital_military_time: Boolean; //#CM 06/26/02
        Hospital_category_summary: Boolean;
          //#RWM 12/04/02      Dont print line item detail on invoice
        Hospital_always_quantities: Boolean;
          //#RWM 12/04/02      Print qty value on invoice, even if 1.0
        Hospital_celsius: Boolean; { Temperatures in celsius }
        Hospital_qbooks_path: string[30]; { Path for QuickBooks export }

        Hospital_label_name: Boolean; { Print hospital name on drug label }
        Hospital_label_doctor: Boolean; { Print doctor's name on drug label }

        Hospital_mail_height: SINGLE; { Mailing label height }
        Hospital_mail_top: SINGLE;
        Hospital_mail_left: SINGLE;
        Hospital_patient_height: SINGLE; { Patient label height }

        Hospital_photo_org: TPhoto_org;
        Hospital_invoice_title: string[13]; { Title word on invoice (e.g. I N V O I C E) }
        Hospital_patient_left: SINGLE; { Left margin for patient labels }
        Hospital_OTC_doctor: Doctor_str; { Doctor who gets sales credit for OTC sales }
        Hospital_appt_stop: Word; { Stop time for appointment schedule }
        Hospital_patient_font: Byte; { Drug label point size }
        Hospital_show_ghosts: Boolean; { Show ghosts on appointment calendar }
        Hospital_query_text: Integer; { Offset in WP.VM$ of query post card text }
        Hospital_warning: Integer; { Offset in Phrase.VM$ of drug label warning }
        Hospital_label_address: Boolean; { TRUE if client address required on drug label }
        Hospital_invoice_folder: Boolean; { TRUE if client folder no. required on invoice }
        Hospital_statement_folder: Boolean; { TRUE if client folder no. required on statement }
        Hospital_marketing_memo: Integer; { Offset in WP.VM$ of current marketing memo text }
        Hospital_post_notes: Boolean; { Post appointment notes to medical history }
        Hospital_outof_warning: Boolean; { Warning if items are out of stock }
        Hospital_expand_schedule: Boolean; { Print appointment schedule in expanded format }
        Hospital_appt_use_drcolors: Boolean;
        Hospital_padbbsprefix: array[1..9] of Byte;
        Hospital_set_posting: Boolean; { Set posting date hospital wide }

        Hospital_query_email: Integer; { Offset in WP.VM$ of query email message text }
        Hospital_reminder_email_1: Integer;
          { Offset in WP.VM$ of first reminder email message text }
        Hospital_reminder_email_2: Integer;
          { Offset in WP.VM$ of second reminder email message text }
        Hospital_reminder_email_3: Integer;
          { Offset in WP.VM$ of third reminder email message text }

        Hospital_print_email_1: Boolean;
          { Print first reminder, even when clients have e-mail addresses }
        Hospital_print_email_2: Boolean;
          { Print second reminder, even when clients have e-mail addresses }
        Hospital_print_email_3: Boolean;
          { Print third reminder, even when clients have e-mail addresses }

        Hospital_appt_alerts: Boolean; { Show alerts on calendar }
        Hospital_appt_quickedit: Boolean;
        Hospital_busydate_visible: Boolean; { Display busygraph on appt calendar }
        Hospital_lock_appts: Boolean; { Lock appointments from drag-drop on calendar }
        Hospital_auto_new_reservation: Boolean;
          { automatic showing of 'choose facility' window for new reservations }

        Hospital_cash_array: array[1..9] of Byte;
        Hospital_alt_state: string[5]; { South Africa state field }
        Hospital_max_boarding_duration: Byte;
        Hospital_services_notation: Boolean;
        Hospital_discount_details: Boolean; { Include discounting details on invoice }
        Hospital_invoice_summary: Boolean; { Include patient summary on invoice }
        Hospital_close_on_invoice: Boolean; { Include invoice "closing notation" on statement also }
        Hospital_vaccine_prompt: Boolean; { Auto-prompt for vaccine for all vaccinations }
        Hospital_certificate_prompt: Boolean; { Prompt before printing rabies certificate }
        Hospital_default_room: Integer;

        Hospital_all_referrals: Boolean; { No longer used...see Hospital_patient_folder }
        Hospital_services_taxed: Boolean; { TRUE if all services taxed }
        Hospital_certificates: Byte; { Number of rabies certificates to print }
        Hospital_invoices: Byte; { Number of invoices to print }
        Hospital_deposits: Byte; { Number of deposit slips to print }
        Hospital_version: Integer; { Current version number of data base }
        Hospital_list_prices: Boolean; { Show list prices on invoice }
        Hospital_logo: File_string; { File name of .BMP file containing hospital logo }
        Hospital_cash_discount: Byte; { Discount % for paying by check or cash }
        Hospital_appt_start: Word; { Start time for appointment schedule }
        Hospital_modem: string[4];
        Hospital_stop_audit: Word;
        Hospital_start_audit: Word;
        Hospital_calendar_format: THospital_calendar_format;
        Hospital_multi_open: Boolean;
        Hospital_auto_checkin: Boolean;
        Hospital_include_client: Boolean; { Include client info on patient label }
        Hospital_include_patient: Boolean; { Include patient info on patient label }
        Hospital_weight_history: Byte;

        Hospital_label_width: SINGLE;
        Hospital_label_height: SINGLE;
        Hospital_label_left: SINGLE;

        Hospital_state_rate: SINGLE; { State tax rate }
        Hospital_local_rate: SINGLE; { Local tax rate }

        Hospital_auto_history: Boolean; { True for auto-add of medical history records }
        Hospital_record_number: Byte; { Record number of this record, in each record }
        Hospital_server: Boolean; { Dedicated server }
        Hospital_remind_cycle: Byte; { Normal reminder cycle }
        Hospital_remind_overdue: Boolean; { Show due dates for overdue treatments on reminders }
        Hospital_default_doctor: Doctor_str;
        Hospital_checkin_document: Integer; { Phrase file offset, used to be File_string; }
        Hospital_client_folder: Boolean; { Auto-assign client folder numbers }
        Hospital_include_phone: Boolean; { Include Hospital phone on drug labels }
        Hospital_default_form: SMALLINT;
        Hospital_ftp_passive: Boolean;
          { Allows the ftp component for Heatlhy pet to use passive mode connection } //#DMH 10/09/01
        Hospital_reminders: TReminder_edit;
        Hospital_per_page: THospital_per_page;
        Hospital_charts: Byte;
        Hospital_family_reminder: File_string; { Name of consolidated post card document }
        Hospital_first_selected: Integer;
        Hospital_multi_text: Integer; { Offset in WP.VM$ to multi-patient reminder text }
        Hospital_second_selected: Integer;
        Hospital_third_selected: Integer;
        Hospital_patient_folder: Boolean; { Auto-assign patient folder numbers }
        Hospital_invoice_notes: Boolean; { Print public notes on invoice }
        Hospital_1To2_delay: Byte; { Delay in days between first and second reminders }
        Hospital_2To3_delay: Byte; { Delay in days between second and third reminders }
        Hospital_label_font: Byte; { Drug label point size }
        Hospital_payment_type: THospitalPaymentType; { Default payment type }
        Hospital_internet_logging: Boolean;
          { TRUE if AVImark is to maintain Log file with all updates of certain key files }
        Hospital_assign_by_client: Boolean;
          { Auto-assign doctor to medical history according to preferred doctor }
        Hospital_require_password: Boolean; { Require password entry at logon }

        Hospital_charge_by: THospital_charge_by;
        Hospital_checkout_tod: Word;
        Hospital_boarding_doctor: Doctor_str;
        Hospital_schedule_increment: Byte); { Time in minutes between empty slots on the schedule  }

      2: (Hospital_next_invoice: Integer; { Next invoice number to be assigned }
        Hospital_last_statement: Word; { Date statements were last printed }
        Hospital_last_closed: Word; { Date A/R last closed }
        Hospital_last_treatment: string[8]; { Last treatment code added }
        Hospital_last_item: string[8]; { Last item code added }
        Hospital_last_diagnosis: string[8]; { Last diagnosis code added }
        Hospital_last_executed: Word; { Date AVImark last ran }
        Hospital_last_soapnotes: Boolean;
          { Whether nominal user wants to default to notes in soap window }
        Hospital_last_photopath: Integer;
        Hospital_last_client_folder: Integer; { Last client folder no. auto-assigned }
        Hospital_last_pad8: Char;
        Hospital_last_acctdetail: Boolean; { True if last View of accounting was detail view }
        Hospital_last_census: Boolean; { True if last Census viewed in detail }
        Hospital_using_tempfiles: Boolean;
        Hospital_last_chart: array[1..16] of Boolean;
          { Include options selected on chart last time }
        Hospital_last_client: Integer; { Last client worked with }
        Hospital_last_query: Integer; { Last query used }
        Hospital_last_rabies: string[10]; { Last rabies tag number assigned }
        Hospital_last_certificate: Integer; { Last certificate number assigned }
        Hospital_last_estimate: string[8]; { Last estimate document printed }
        Hospital_last_printer: string[20]; { Last defauult printer saved for printing drug labels }
        Hospital_importing: Boolean;
        Hospital_last_label: Integer; { Sequence no. of last drug label printed }
        Hospital_last_wavDate: Word; { Last Date of last .wav save }
        Hospital_last_wavSeq: Word; { Last Number of sequence done today }
        Hospital_last_board_col: Integer; { Column of last cursor position on boarding calendar }
        Hospital_last_board_date: Word; { Date of last cursor position on boarding calendar }
        Hospital_last_photo: string[8]; { Last photo name auto-assigned }
        Hospital_last_remind1: string[8]; { Last reminder document names used }
        Hospital_last_remind2: string[8];
        Hospital_last_remind3: string[8];
        Hospital_last_remind_date: Word; { Date reminders last printed }
        Hospital_last_state_controlled: Word;
          { Date last state required controlled substance data last sent through } // LC#  4/22/03
        Hospital_last_import_dir: string[80]; { Directory last used to do Sidekick import from }
        Hospital_last_WP_size: Integer; { Size of the WP file on the laptop as of last import }
        Hospital_last_sort_order: Byte; { Last sort order chosen for reminders }
        Hospital_last_late_fee: Word;
        Hospital_last_patient_folder: Integer; { Last animal folder no. auto-assigned }
        Hospital_last_details: Boolean; { Last setting for Details check box on Reminder Analysis }
        Hospital_last_view_text: Boolean; { Last setting for view text on calendar }
        Hospital_last_over30: string[8]; { Document names for collection letters last printed }
        Hospital_last_over60: string[8];
        Hospital_last_over90: string[8];
        Hospital_last_over120: string[8];
        Hospital_last_notes_dir: string[80];
          { Directory last used to do Shift-FS import of a text file }
        Hospital_last_reports: array[0..4] of Reports_set;
        Hospital_last_consolidate: Boolean;
        Hospital_birth_warning: Boolean; { Warning if patient's birthday zero }
        Hospital_last_controlled: Word;
        Hospital_last_transfer: Integer;
        Hospital_posting_date: Word; { Current posting date if Hospital_set_posting is TRUE }
        Hospital_last_sidekick_inventory: Boolean;
          { Default choice for importing inventory usage from sidekick }
        Hospital_custom_date_format: Boolean; //#CM 10/08/02
        Hospital_last_inven_report: Word;
        Hospital_quality_client: Integer; { Last client for which quality was measured }
        Hospital_last_quality: Word; { Date last time quality was measured }
        Hospital_pad12: array[1..801] of Byte;
        Hospital_record_two: Byte;
          { Don't move this field - aligned with Hospital_record_number in record 1 }
        Hospital_pad4: array[1..61] of Byte); { Padded out to end of 1287-byte Hospital_record }

      3: (Hospital_billing_document: string[8];
        Hospital_billing_minimum: Integer;
        Hospital_backup_programs: Boolean;
        Hospital_backup_docs: Boolean;
        Hospital_backup_photos: Boolean;
        Hospital_backup_verify: Boolean;
        Hospital_account_show_all: Boolean; //#CM 04/04/02
        Hospital_pad11: array[1..2] of Byte; //#CM 04/04/02
        Hospital_applications: array[1..10] of string[49];
        Hospital_backup_dir: string[30]; //#RWM 7/21/03 moved to Hospital_backup_path in Phrase file
        Hospital_application: string[30];

        Hospital_VetCor_account: string[10];
        Hospital_checkin_code: Code_string;
        Hospital_timeclock_api: string[50];
        Hospital_forms_path: string[30]; { Directory for medical history forms }
        Hospital_textfiles_path: string[30];
        Hospital_applnames: array[1..10] of string[16];
        Hospital_board_colors: THospital_board_colors;
        Hospital_appt_colors: THospital_appt_colors;

        Hospital_timeclock_ininterval: Word; { Round back to nearest e.g. 5 minutes }
        Hospital_timeclock_outinterval: Word; { Round forward }
        Hospital_timeclock_server: string[44]; { Name of timeclock server }
        Hospital_record_three: Byte;
          { Don't move this field - aligned with Hospital_record_number in record 1 }
        Hospital_backup_path: Integer; { Path to folder in which backup's are to be written }
        Hospital_pad10: Byte;
        Hospital_timeclock_warn: Boolean;
        Hospital_timeclock_login: Boolean;
        Hospital_timeclock_ip: string[15];
        Hospital_timeclock_access: TTimeclock_access;

        Hospital_xls_path: string[30];
        Hospital_useAbbrName: Boolean; //#DMH 06/11/02
        Hospital_pad5: array[1..5] of Byte); { Padded out to end of 1287-byte Hospital_record }

      4: (Hospital_printers: array[0..15] of string[40]; // For backward compatibility only
        Hospital_print_quality: array[0..15] of Quality_type; // ...
        Hospital_mail_server: string[60];
        Hospital_pad9: array[1..3] of Char;

        Hospital_first_reminder: string[79];
          { Reminder document file names - sent to PROCREM.EXE by ANALYZE.PAS }
        Hospital_second_reminder: string[79];
        Hospital_third_reminder: string[79];

        Hospital_period_date: Word;
        Hospital_period_term: Integer;
        Hospital_to_be_sent: Integer;
        Hospital_print_consolidated: Boolean;
        Hospital_reminder_printer: string[30];
        Hospital_mail_address: string[80];
        Hospital_pad14: array[1..127] of Byte;
        Hospital_record_four: Byte;
          { Don't move this field - aligned with Hospital_record_number in record 1 }
        Hospital_pad6: array[1..61] of Byte); { Padded out to end of 1287-byte Hospital_record }

      5: (Hospital_first_set: array[1..10] of Reminder_set;
        Hospital_second_set: array[1..10] of Reminder_set;
        Hospital_third_set: array[1..10] of Reminder_set;
        Hospital_appt_text: Integer;
        Hospital_index_flags: Index_flags;
        Hospital_tax_number: string[20];
        Hospital_antech_path: string[30];
        Hospital_vetconnect_path: string[30];
        Hospital_pad7: array[1..85] of Byte;
        Hospital_record_five: Byte;
          { Don't move this field - aligned with Hospital_record_number in record 1 }
        Hospital_pad8: array[1..61] of Byte); { Padded out to end of 1287-byte Hospital_record }

      6: (Hospital_discounts: array[1..20] of Discount_schedule;
        Hospital_closings: array[1..10] of Closing_set);

      7: (Hospital_One2One_userid: string[50];
        Hospital_One2One_password: string[32];
        Hospital_CC_registration: string[20]; // South Africa "Closed Corporation" number
        Hospital_VAT_registration: string[16]; // South Africa "VAT Registration" number
        Hospital_pad2: array[1..1104] of Byte;
        Hospital_record_seven: Byte;
          { Don't move this field - aligned with Hospital_record_number in record 1 }
        Hospital_pad3: array[1..61] of Byte); { Padded out to end of 1287-byte Hospital_record }
  end; { Hospital_record }

  { Option record definition }
  OptionValue_record = record
    OptionValue_recd: Char;
    OptionValue_option: TGUID;
    OptionValue_parent: Integer;
    OptionValue_data: Integer;
    OptionValue_pad: array[1..7] of Char;
  end; // Length: 32 bytes.

  { Client record definition }
  Client_record = record
    Client_recd: Char;
    Client_title: string[8];
    Client_last: string[25];
    Client_address: string[25];
    Client_address2: string[25];
    Client_city: string[20];
    Client_state: string[2];
    Client_zip: string[10];
    Client_area: string[3];
    Client_phone: string[8];
    Client_first: string[20];
    Client_balance: Integer;
    Client_business: string[20];
    Client_codes: string[8];
    Client_class: Byte;
    Client_reference: string[20];
    Client_until: Word;
    Client_suspend: Boolean;
    Client_flags: TClient_flag_set;
    Client_added: Word;
    Client_doctor: Doctor_str;
    Client_company: Byte;
    Client_spouse: string[25];
    Client_photo: Integer;
    Client_pad1: array [1..5] of Byte;
    Client_instruction: Integer;
    Client_email: Integer;
    Client_extra: Integer;
    Client_faxno: string[12];
    Client_license: string[20];
    Client_SSN: string[15];
    Client_employer: string[20];
    Client_county: string[8];
    Client_alt_state: string[5];
    Client_cell: Integer;
    Client_quality: Byte;
    Client_visits: Word;
    Client_fiscal_sales: Integer;
    Client_added_by: Doctor_str;
    Client_default_site: Byte;
    { Added Client_TaxArea 10/27/2004, changed Client_reserve from 1..9 to 1..5 }
    Client_TaxArea: Integer;
    Client_reserve: array[1..5] of Char;
    Client_alert: Integer;
    Client_note: Integer;
    Client_folder: Integer;
  end; { Client_record }

  TAccount_flags = set of (afDetail, afExported, afPublic);

  { Account record definition }
  Account_dependent = record
    case Integer of
      1: (Account_expense: Integer; { For normal charges  }
        Account_transtax: SINGLE;
        Account_tranltax: SINGLE;
        Account_which: CHAR;
        Account_split: BOOLEAN);

      2: (Account_balance: Integer; { For Invoice & Balance Due records }
        Account_invstax: Integer;
        Account_invltax: Integer;
        Account_invno: Integer);

      3: (Account_deposit: Word; { For payments }
        Account_enteredx: Doctor_str; // Replaced by Account_added_by (for all Trans-types)
        Account_modified: BOOLEAN;
        Account_changed: Doctor_str;
        Account_chgdate: Word;
        Account_time: Word);

      4: (Account_notation: Integer; { For notations }
        Account_public_notation: BOOLEAN);
  end; { Account_dependent RECORD }

  Account_record = record
    Account_code: Code_string; { Check no. if a check payment }
    Account_recd: Char;
    Account_date: Word;
    Account_type: Char;
    Account_doctor: Doctor_str;
    Account_description: string[40];
    Account_data: Account_dependent;
    Account_qty: Integer;
    Account_amount: Integer;
    Account_flags: TAccount_flags;
    Account_normal: Integer; { Normal price for this treatment/item - for discount calculation }
    Account_service: Integer;
    Account_animal: Integer; { WP offset if an Invoice }
    Account_client: Integer;
    Account_note: Integer;
    Account_site: Byte;
    Account_added_by: Doctor_str;
    Account_xcharge: Integer; // phrase field
    Account_company: Byte;
    Account_reserv: array[1..10] of Byte;
  end; { Account_record }

  TAnimal_flags = set of (pfPublicNotes, pfPublicChartNotes, pfMedicalAlert, pfBirthdayUnknown);

  TRelation_set = record
    Relation_code: Code_string; { Entry code of Relation system table identifying relationship }
    Relation_reserv: array[1..4] of Byte;
  end; // TRelation_set

  TRelation_set_array = array[1..3] of TRelation_set;

  Animal_record = record
    Animal_name: string[25];
    Animal_recd: Char;
    Animal_codes: string[5];
    Animal_added: Word;
    Animal_rabies: string[10];
    Animal_birthday: Word;
    Animal_visit: Integer;
    Animal_flags: TAnimal_flags;
    Animal_sex: Char;
    Animal_allergy: Code_string;
    Animal_breed: Code_string;
    Animal_species: Code_string;
    Animal_plan: Code_string;
    Animal_weight: SINGLE;
    Animal_export: Boolean;
    Animal_folder: string[7];
    Animal_registration: string[15];
    Animal_pad2: Integer;
    Animal_certificate: Integer;
    Animal_last_remind: Word;
    Animal_instruction: Integer;
    Animal_chart_notes: Integer;
    Animal_pad: Integer;
    Animal_measure: string[3];
    Animal_extra: Integer;
    Animal_class: Byte;
    Animal_color: Code_string;
    Animal_client: Integer;
    Animal_note: Integer;
    Animal_photo: Integer;
    Animal_pad1: array [1..5] of Byte;
    Animal_suspend: Word;
    Animal_alert: Integer;
    Animal_mixed_breed: Boolean;
    Animal_relationships: TRelation_set_array;
    Animal_death: Word;
    Animal_unposted: Boolean;
    Animal_locator: Integer;
    Animal_last_company: Byte;
    Animal_reserve: array[1..3] of Byte;
  end; // Animal_record

  TService_flag = (sfRemindAs, sfChanged, sfPublicNotes, sfDeclined, sfPublic, sfNotesAligned,
    sfRefill, sfPrintNotes);
  TService_flag2 = (sfLabelNotes, sfFollowNotes, sfApptNotes, sfTrackRefills, sfResultsImported,
    sfEnteringNote, sfNotesLocked, sfHiddenNotes, sfOpen, sfClosed, sfReserv11, sfReserv12,
    sfReserv13, sfReserv14, sfReserv15, sfReserv16);
  TService_flags = set of TService_flag;
  TService_flags2 = set of TService_flag2;

  Service_record = record
    Service_date: Word;
    Service_recd: Char;
    Service_type: Char;
    Service_posted: Boolean;
    Service_vaccine: Integer;
    Service_doctor: Doctor_str;
    Service_description: string[40];
    Service_variance: Integer;
    Service_reason: Char;
    Service_emr_data: Integer;
    Service_code: Code_string;
    Service_amount: Integer;
    Service_quantity: Integer;
    Service_sold_by: Doctor_str;
    Service_medical: Integer;
    Service_normal: Integer;
    Service_codes: string[7];
    Service_results: Integer;
    Service_probhist: Integer;
    Service_photo: Integer;
    Service_pad1: array [1..5] of Byte;
    Service_account: Integer;
    Service_note: Integer;
    Service_animal: Integer;
    Service_tod: Word;
    Service_flags: TService_flags;
    Service_form: Integer;
    Service_pad4: array [1..5] of Byte;
    Service_entered: Doctor_str;
    Service_site: Byte;
    Service_ODCI: Word;
    Service_company: Byte;
    Service_xls: Integer;
    Service_pad2: array [1..5] of Byte;
    Service_flags2: TService_flags2;
    Service_refills: SMALLINT;
      //#CM 07/23/02 Service_refills >= 0 indicates the start of the prescription
    Service_sequence: Integer;
    Service_journal: Integer;
    Service_pad3: array [1..5] of Byte;
    Service_zip: string[5]; // Zip code where service was performed (for alternate taxing)
  end; // Service_record

  { Medical information record definition }
  Medical_record = record
    Medical_recd: Char;
    Medical_weight: SINGLE; { Vital signs fields }
    Medical_temp: SINGLE;
    Medical_resp: SINGLE;
    Medical_pulse: SINGLE;
    Medical_crt: string[16];
    Medical_other: string[30]; { Miscellaneous vital sign }
    Medical_complaint: Integer; { Offset into WP.VM$ for chief complaint notes }
    Medical_examnotes: Integer; {                     ... examination findings }
    Medical_tplannotes: Integer; {                     ... treatment plan notes }
    Medical_service: Integer; { Parent service record }
    Medical_diagnotes: Integer; {                      ... diagnoses notes }
    Medical_dplannotes: Integer; {                      ... diagnostic plan notes }
    Medical_rulenotes: Integer; {                      ... rule-out notes }
    Medical_subject_results: Integer;
    Medical_object_results: Integer;
    Medical_assess_results: Integer;
    Medical_plan_results: Integer;
    Medical_bcs: SINGLE;
    Medical_reserve: array[1..68] of Byte;
  end; { Medical_record }

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

const
  MAX_APPOINT_HISTORY = 20;
  MAX_APPOINT_PROBLEMS = 4;

type
  Appoint_record = record
    Appoint_recd: Char; // Active record code
    Appoint_date: Word; // Date of appointment
    Appoint_time: Word; // TOD of appointment in minutes past midnight
    Appoint_duration: Word; // Length of appointment in minutes
    Appoint_date_made: Word; // Date appointment was made
    Appoint_confirm: TAppoint_confirm; // Appointment confirmed by phone call
    Appoint_room: string[3]; // Facility id
    Appoint_doctor: string[3]; // UserID of doctor
    Appoint_type: TAppoint_type;
    Appoint_history: array[1..MAX_APPOINT_HISTORY] of TAppoint_history; // Associated treatments/items
    Appoint_color: Integer; // Doctor's color for the appointment
    Appoint_problems: array[1..4] of TAppoint_problem;
    Appoint_newclient: string[25];
    Appoint_newpatient: string[25];
    Appoint_newspecies: Code_string;
    Appoint_newphone: string[8];
    Appoint_newarea: string[3];
    Appoint_made_by: Doctor_str;
    Appoint_reason: string[30]; // Appoint_record is used for blockoffs as well
    Appoint_client: Integer;
    Appoint_site: Byte;
    Appoint_flags: TAppoint_flags;
    Appoint_note: Integer; // Offset into WP.VM$ of any notes for this appointment
    Appoint_parent: Integer;
      // RRN of patient's record in Animal.VM$ unless appointment for new client OR out of office appointment
    Appoint_parentis: TAppoint_parentis;
      // Is the appointment tied to an animal or doctor for out-of-office schedule
    Appoint_history_quantity: array[1..MAX_APPOINT_HISTORY] of Word;
      //#CM 09/26/02 corresponds with Appoint_history above
    Appoint_reserve: array[1..24] of Byte;
  end; // Appoint_record

  TBlockOff_apply = (boaWeekly, boaMonthly);

  TBlockOff_week = set of 0..6;
  TBlockOff_month = array[1..6] of TBlockOff_week;

  BlockOff_record = record
    BlockOff_recd: Char;
    BlockOff_enabled: Boolean;
    BlockOff_reason: string[50];
    BlockOff_leave: Word; // Time doctor is leaving
    BlockOff_duration: Word; // Duration the doctor is away
    BlockOff_apply: TBlockOff_apply; // Apply leave time(s) to weekly view or monthly view...
    BlockOff_week: TBlockOff_week; // Apply leave time(s) to these days for every week
    BlockOff_month: TBlockOff_month; // Apply leave time(s) to these days for each week of the month
    BlockOff_reserve: array[1..3] of Byte;
    BlockOff_user: Integer;
    BlockOff_color: Integer; // Doctor's color for the blockoff
    BlockOff_start: Word; // Start date for this blockoff  {0 if permanent}
    BlockOff_end: Word; // End date for this blockoff  (0 if permanent)
    BlockOff_site: Byte;
    BlockOff_room: string[3];
    BlockOff_reserve2: array[1..53] of Byte;
  end; { BlockOff_record  }

  { Reminder file record definition }
  TReminder_term_type = (rcInNone, rcInYears, rcInMonths, rcInWeeks, rcInDays);
  TReminder_how_type = (rwAtAge, rwInTerm, rwOnDate);
  TReminder_send_type = (rsAsRequested, rsOneNotice, rsTwoNotice, rsThreeNotice);
  TReminder_priority_type = (rpAlwaysRemind, rpRemindIfOthers, rpRemindNever);
  TReminder_annual_type = (raNoAnnual, raOneAnnual, raTwoAnnual, raThreeAnnual);
  TReminder_sex_type = (rxIfAny, rxIfFemale, rxIfMale, rxIfSpay, rxIfNeuter);
  TReminder_parent_type = (rpIsAnimal, rpIsTreatment, rpIsItem, rpIsDiagnosis);
  TReminder_flags = set of (rfQtyMultiplier);
  TReminder_altered_array = array[0..5] of Boolean;

  TReminder_appropriate = (remtAppropriate, remtNASex, remtNADueDate, remtNAEndDate,
    remtNANotTreated, remtNACount, remtNASeries, remtNASeriesComplete);

  Reminder_record = record
    Reminder_code: Code_string;
    Reminder_recd: Char;
    Reminder_description: string[30];
    Reminder_safety_net: Byte;
      // If never done, start reminding this number of days after Animal_added
    Reminder_force_due: Boolean; // If true, don't update due date
    Reminder_reminded: Word; // Date this reminder last sent to patient
    Reminder_cycle: Word;
    Reminder_cycle_units: TReminder_term_type;
    Reminder_count: Word; // Patient to be treated this many times
    Reminder_series_name: string[19]; // Name of series, if any, this reminder is part of
    Reminder_series_seq: Byte;
    Reminder_send: TReminder_send_type;
    Reminder_priority: TReminder_priority_type;
    Reminder_annual: TReminder_annual_type;
    Reminder_begin_which: TReminder_how_type;
    Reminder_begin: Integer;
    Reminder_begin_units: TReminder_term_type;
    Reminder_end_which: TReminder_how_type;
    Reminder_end: Integer;
    Reminder_end_units: TReminder_term_type;
    Reminder_suspend: Boolean;
    Reminder_resume_which: TReminder_how_type;
    Reminder_resume: Integer;
    Reminder_resume_units: TReminder_term_type;
    Reminder_sex: TReminder_sex_type;
    Reminder_due: Word; // For animal parents, date this reminder is due
    Reminder_override: Boolean; // For animal reminders, allow Apply function
    Reminder_parent: Integer; // RRN of parent record (animal, treatment, or item
    Reminder_parentis: TReminder_parent_type; // This record is attached to
    Reminder_species1: Code_string; // Species of patient to which this reminder applicable
    Reminder_automatic: Boolean; // Apply automatically when patient added to file
    Reminder_altered: TReminder_altered_array;
    Reminder_linkdue: Word; // Date this reminder due when previous reminder in series complete
    Reminder_done: Byte; // Number of times this treatment has been done in patient's life to date
    Reminder_appropriate: TReminder_appropriate;
    Reminder_last: Word; // Date this treatment last done to animal
    Reminder_for_first: Boolean; // Remind for the first time this treatment is to be done
    Reminder_added: Word; // Date reminder created
    Reminder_species2: Code_string; // Additional species for which this reminder applies
    Reminder_flags: TReminder_flags;
    Reminder_qty: Integer; // Qty last done (for qty-based due date calcuation) * 100
    Reminder_site: Byte;
    Reminder_last_service: Integer;
    Reminder_reserv: array[1..20] of Byte;
  end; // Reminder_record

  TTreatmentFlag = (tfPublicComments, tfNoTagAlong, tfPublicInstructions, tfPriceNormally,
    tfOnInvoice, tfAllowOverride);
  TTreatmentFlags = set of TTreatmentFlag;

  TTreatment_description = string[40];

  Treatment_record = record
    Treatment_code: Code_string;
    Treatment_recd: Char;
    Treatment_class: Byte;
    Treatment_description: TTreatment_description;
    Treatment_invoice: string[30]; // Description of treatment to be shown on invoice
    Treatment_time: SMALLINT;
    Treatment_price: Integer;
    Treatment_follow: Word;
    Treatment_priority: Boolean;
    Treatment_log: string[3];
    Treatment_codes: string[8];
    Treatment_override: Boolean;
    Treatment_changed: Word;
    Treatment_flags: TTreatmentFlags;
    Treatment_doctor: Doctor_str; // Default doctor for this treatment
    Treatment_species1: Code_string; // Treatment valid for these two species
    Treatment_species2: Code_string;
    Treatment_document: Integer;
    Treatment_pad1: array[1..5] of Byte; // ...was rest of 8-character document name prior to v. 144
    Treatment_photo: Integer;
    Treatment_pad2: array [1..5] of Byte;
    Treatment_vaccine: Code_string; // Default vaccine from system tables for this treatment
    Treatment_generation: Word; // Current generation of additional data fields
    Treatment_alert: Integer;
    Treatment_basis: Integer;
    Treatment_high_gen: Word;
    Treatment_instruction: Integer;
    Treatment_site: Byte;
    Treatment_header: Integer;
    Treatment_comment: Integer;
    Treatment_sequence: Word;
    Treatment_weight: Word;
    Treatment_remind_as1: Code_string;
    Treatment_interval: Byte; // Reminder interval in weeks
    Treatment_next: Code_string; // Next treatment in series
    Treatment_form: Integer;
    Treatment_pad3: array [1..5] of Byte;
    Treatment_remind_as2: Code_string;
    Treatment_remind_as3: Code_string;
    Treatment_list_codes: string[3];
    Treatment_sex: string[4];
    Treatment_antech: Code_string; //#RWM 1/27/03  Antech ExtID code
    Treatment_docnotes: Integer; // Offset in WP.vm$ of doctor's notes
    Treatment_follow_subject: Integer; // Offset in PHRASE.VM$ of follow-up description
    Treatment_journal: Integer;
    Treatment_template: Code_string; // Code of form template (new "more stuff")
    Treatment_vetconnect: Code_string;
    Treatment_reserve: array[1..20] of Byte;
  end; // Treatment_record

  THeader_name = string[31];

  Header_record = record
    Header_recd: Char;
    Header_code: Code_string;
    Header_name: THeader_name;
    Header_added: string[5];
    Header_markup: SMALLINT;
    Header_acctno: Integer;
    Header_codes: string[7];
    Header_sequence: Word; { Key of this record for sequencing purposes }
    Header_sales: Integer;
    Header_report: string[31];
    Header_site: Byte;
    Header_reserv: array[1..39] of Char;
  end; { Header_record }

  TDiagnosis_species1 = array[1..8] of Char;
  TDiagnosis_description = string[38];
  TDiagnosis_codes = string[6];

  { Diagnosis record definition }
  Diagnosis_record = record
    Diagnosis_sequence: Word;
    Diagnosis_code: string[7];
    Diagnosis_recd: Char;
    Diagnosis_description: TDiagnosis_description;
    Diagnosis_document: Integer;
    Diagnosis_pad1: array[1..5] of Byte; // ...was rest of 8-character document name prior to v. 143
    Diagnosis_follow: Word;
    Diagnosis_priority: Boolean;
    Diagnosis_control: string[3]; //unused
    Diagnosis_note: Integer;
    Diagnosis_instruction: Integer;
    Diagnosis_codes: TDiagnosis_codes;
    Diagnosis_used: Boolean; //unused
    Diagnosis_override: Boolean;
    Diagnosis_photo: Integer;
    Diagnosis_pad2: array [1..5] of Byte;
    Diagnosis_species1: TDiagnosis_species1; // null terminated
    Diagnosis_diaghdr: Integer;
    Diagnosis_keywords: string[60];
    Diagnosis_recommendations: Integer;
    Diagnosis_form: Integer;
    Diagnosis_pad3: array [1..5] of Byte;
    Diagnosis_remind_as: Code_string;
    Diagnosis_site: Byte;
    Diagnosis_protocol: Integer;
    Diagnosis_list_codes: string[3];
    Diagnosis_follow_subject: Integer;
    Diagnosis_species2: Code_string;
    Diagnosis_reserv2: array[1..6] of Byte;
  end; { Diagnosis_record }

  TDiaghdr_name = string[30];

  { Diagnosis header record definition }
  Diaghdr_record = record
    Diaghdr_pad1: SMALLINT;
    Diaghdr_name: TDiaghdr_name;
    Diaghdr_recd: Char;
    Diaghdr_sequence: Word;
    Diaghdr_code: Code_string;
    Diaghdr_reserv: array[1..19] of Byte;
    Diaghdr_diagnosis: Integer;
    Diaghdr_prev: Integer;
    Diaghdr_next: Integer;
  end; { Diaghdr_record }

  TVariance_is = (viByPercent, viByAmount, viByQuantity);
  TTaskFlags = set of (tfPublicNotes);
  Task_record = record
    Task_recd: Char;
    Task_quantity: Integer;
    Task_pad: SMALLINT;
    Task_amount: Integer;
    Task_usecurrent: Boolean;
    Task_code: Code_string;
    Task_estimate: Integer;
    Task_repeat: Integer; //#RWM 12/13/02  Support number of repeats for this line item
    Task_note: Integer;
    Task_varianceis: TVariance_is;
    Task_sequence: Integer;
    Task_flags: TTaskFlags;
    Task_variance: Integer;
    Task_reserv: array[1..18] of Char;
  end; // Task_record

  Estimate_record = record
    Estimate_pad1: array[1..2] of Byte;
    Estimate_name: string[30];
    Estimate_recd: Char;
    Estimate_document: File_string;
    Estimate_pad2: array[1..3] of Byte;
  end; { Estimate_record }

  { Table record definition }
  TTable_flags = set of (tfAllowAutoAdd);

  Table_record = record
    Table_recd: Char;
    Table_code: Code_string;
    Table_name: string[25];
    Table_flags: TTable_flags;
    Table_reserv: array[1..8] of Char;
  end; { CBZhdr_record }

  TEntry_description = string[50];

  { Definition of variable portion of system table record }
  Entry_area = record
    case Integer of
      { Normal mapping }
      1: (Entry_description: TEntry_description);

      { Zip code entry mapping }
      2: (Entry_city: string[20];
        Entry_county: string[15];
        Entry_tax_area: string[6];
        Entry_alt_state: string[5];
        Entry_state: string[2];
        Entry_area: string[3]);

      { Species entry mapping }
      3: (Entry_pad: array[1..11] of Byte;
        Entry_measure: string[3];
        Entry_weight: SINGLE;
        Entry_increment: SINGLE;
        Entry_species_name: string[10]);

      { Vaccine entry mapping }
      4: (Entry_old_serial: string[10]; // no longer used
        Entry_expiration: string[8];
        Entry_manufacturer: string[5];
        Entry_virus: string[3];
        Entry_administered: string[4];
        Entry_serial: string[15]);

      { Health plan mapping }
      5: (Entry_plan: string[30];
        Entry_courtesy: SMALLINT;
        Entry_months: SMALLINT);

      { Additional data fields mapping }
      6: (Entry_data_name: string[30];
        Entry_action: string[6];
        Entry_generation: Word;
        Entry_high_gen: Word;
        Entry_default_table: Integer); // Used only if this entry defines a Table

      { Audit trail entries }
      7: (Entry_audit_event: string[40];
        Entry_audit_who: Audit_who); // (awNoOne, awAllButAdmin, awEverone)

      { User-defined fees }
      8: (Entry_fee_name: string[30];
        Entry_fee: Integer;
        Entry_pad2: Integer;
        Entry_minimum: Integer);

      { Breed entries }
      9: (Entry_breed: string[40];
        Entry_breedtype: string[8]);

      { Company entries }
      10: (Entry_company_name: string[50];
        Entry_company_phone: string[14];
        Entry_company_color: TColor);

      { Work list entries }
      11: (Entry_work_list: string[30];
        Entry_list_codes: string[3]);

      { User-defined payment types }
      12: (Entry_payment: string[30];
        Entry_payment_codes: string[7]);

      { Client/Patient relationships }
      13: (Entry_relationship: string[30];
        Entry_client: Integer;
        Entry_autopost: BOOLEAN);

      { Tax Tables fees }
      14: (Entry_area_desc: string[30];
        Entry_ltax_rate: SINGLE;
        Entry_stax_rate: SINGLE);

      100: (Entry_other: array[1..100] of CHAR);

      { Facility appointments }
      200: (Entry_facility: string[30];
        Entry_appt_width: Integer);
  end; { Entry_data }

  { Entry record definition }
  Entry_record = record
    Entry_recd: Char;
    Entry_code: Code_string;
    Entry_data: Entry_area;
    Entry_table: Integer;
    Entry_note: Integer;
    Entry_sequence: Word;
    Entry_reserv: array[1..44] of Char;
  end; { Entry_record }

  { QAhdr record definition }
  QAhdr_record = record
    QAhdr_name: string[30];
    QAhdr_recd: Char;
    QAhdr_reserv: array[1..12] of Byte;
  end; { QAhdr_record }

  { QA record definition }
  QA_record = record
    QA_code: Code_string;
    QA_recd: Char;
    QA_description: string[65];
    QA_note: Integer;
    QA_QAhdr: Integer;
    QA_sequence: Integer;
    QA_reserv: array[1..4] of Byte;
  end; { QA_record }

  { Drughdr record definition }
  Drughdr_record = record
    Drughdr_name: string[50];
    Drughdr_recd: Char;
    Drughdr_drug: Integer;
    Drughdr_prev: Integer;
    Drughdr_next: Integer;
  end; { Drughdr_record }

  { Drug record definition }
  Drug_record = record
    Drug_text: string[72];
    Drug_recd: Char;
    Drug_note: Integer;
    Drug_drughdr: Integer;
    Drug_prev: Integer;
    Drug_next: Integer;
  end; { Drug_record }

  { Fachdr record definition }
  Fachdr_group = record
    Fachdr_species: Code_string;
    Fachdr_weight: SINGLE;
    Fachdr_boarded: Code_string;
      // Treatment code to be posted when checking out, having been boarded
    Fachdr_hospitalized: Code_string; //     ...same for checkout, having been hospitalized
    Fachdr_other: Code_string; //     ...save for user-defined check-in type
    Fachdr_set_reserv: array[1..31] of Byte;
  end;

  Fachdr_record = record
    Fachdr_code: Code_string;
    Fachdr_recd: Char;
    Fachdr_occupancy: Word;
    Fachdr_pad1: Char;
    Fachdr_hi_wt: SINGLE;
    Fachdr_lo_wt: SINGLE;
    Fachdr_description: string[30];
    Fachdr_set: array[1..10] of Fachdr_group;
    FacHdr_sequence: Integer; //#CM 10/15/02
    FacHdr_site: Byte;
    FacHdr_reserv: array[1..55] of Byte;
  end; { Fachdr_record }

  { Facility record definition }
  Facility_record = record
    Facility_name: string[8];
    Facility_recd: Char;
    Facility_description: string[30];
    Facility_pad_1: array[1..4] of Byte;
    Facility_board: Integer;
    Facility_last: Integer;
    Facility_reserv: array[1..96] of Byte;
    Facility_history: Integer;
    Facility_fachdr: Integer;
    Facility_pad2: array[1..8] of Byte;
  end; { Facility_record }

  TBoardingStatusType = (bsReservation, bsBoarding, bsHospitalization, bsOther, bsCheckedOut);
  TBoard_type = (btReservation, btCheckedIn, btCheckedOut, btCanceled, btNoShow, btKept,
    btRescheduled);
  TBoard_types = array[TBoard_type] of string[15];

  Board_record = record
    Board_date: Word;
    Board_after: Byte; // Unused
    Board_duration: Byte;
    Board_facility: Word;
    Board_recd: Char;
    Board_type: TBoard_type;
    Board_status: TBoardingStatusType;
    Board_reserv: array[1..15] of Byte;
    Board_client: Integer;
    Board_animal: Integer;
    Board_note: Integer;
    Board_counter: Integer; // Not currently used
    Board_site: Byte;
    Board_new_client: Integer;
    Board_new_patient: Integer;
    Board_reserve: array[1..64] of Byte;
  end; // Board_record

  TActivity_type = (atTreatment, atMedication, atFeeding, atExercise, atAtCheckOut);
  TActivity_measure = (In_minutes, In_hours, In_days, In_weeks);
  Activity_record = record
    Activity_recd: Char;
    Activity_pad1: array[1..7] of Char;
    Activity_description: string[30];
    Activity_qty: Integer;
    Activity_repeat: Word;
    Activity_interval: Byte;
    Activity_measure: TActivity_measure;
    Activity_start: Word; // Start date of this activity
    Activity_time: Word; // Start time of this activity
    Activity_type: TActivity_type;
    Activity_doctor: string[3]; // Default to Treatment_doctor
    Activity_code: Code_string;
    Activity_reserv: array[1..26] of Byte;
    Activity_note: Integer;
    Activity_prev: Integer;
    Activity_next: Integer;
    Activity_visit: Integer;
  end; { Activity_record }

  Visit_record = record
    Visit_recd: Char;
    Visit_in_tod: Word;
    Visit_out_tod: Word;
    Visit_doctor: Doctor_str;
    Visit_in_date: Word;
    Visit_out_date: Word;
    Visit_animal: Integer;
    Visit_status: TAnimal_status;
    Visit_code: Code_string;
    Visit_treatnote: Integer;
    Visit_mednote: Integer;
    Visit_playnote: Integer;
    Visit_foodnote: Integer;
    Visit_results: Integer;
    Visit_board: Integer;
    Visit_checknote: Integer;
    Visit_censusnote: Integer;
    Visit_site: Byte;
    Visit_treatment: Integer;
    Visit_categoryentry: TCodeString;
    Visit_form: Integer;
    Visit_formtemplateversion: Integer;
    Visit_reserve: array[1..19] of Byte;
  end; // Visit_record

  { Merge type record definition }
  Merge_record = record
    Merge_client: Integer;
    Merge_animal: Integer;
  end;

  TItem_months_sold = array[1..12] of Integer;
  TItem_prices = array[1..6] of Integer;

  Item_flag_set = set of (ifItem_break_markup, ifItem_priority, ifPublicInstructions,
    ifPublicNotes); //#RWM 11-07-02
  { TRUE if qty break prices are to also be marked up }
  { TRUE means follow-up is critical }
  TMixture_set = record
    Mixture_item: Code_string;
    Mixture_quantity: Integer;
  end; // TMixture_set

  TItem_description = string[40];

  Item_record = record
    Item_code: Code_string;
    Item_recd: Char;
    Item_class: Byte;
    Item_description: TItem_description;
    Item_pad: array[1..31] of Byte;
    Item_measure: string[6];
    Item_on_hand: Integer;
    Item_on_order: Integer;
    Item_average: Integer;
    Item_last: Integer;
    Item_price: Integer;
    Item_order_qty: Integer;
    Item_pack: Integer;
    Item_order_pt: Integer;
    Item_MTD_sold: Integer;
    Item_MTD_sales: Integer;
    Item_sold: TItem_months_sold;
    Item_YTD_sold: Integer;
    Item_YTD_sales: Integer;
    Item_break_qty: Integer;
    Item_break_disc: Integer;
    Item_2nd_qty: Integer;
    Item_2nd_disc: Integer;
    Item_codes: string[8];
    Item_changed: Word;
    Item_expires: Word;
    Item_markup: SMALLINT;
    Item_high_cost: Integer;
    Item_mfg_no: string[15];
    Item_location: string[15];
    Item_MSDS: string[15];
    Item_UPC: string[15];
    Item_prices: TItem_prices;
    Item_last_on_hand: Integer;
    Item_alert: Integer;
    Item_instruction: Integer;
    Item_document: Integer; // Offset in Phrase.VM$ of document name
    Item_pad1: Byte; // ...was rest of 8-character document name prior to v. 144
    Item_allocated: Integer;
    Item_photo: Integer;
    Item_pad2: array [1..5] of Byte;
    Item_sequence: Word;
    Item_vendor: Integer;
    Item_category: Integer;
    Item_flags: Item_flag_set;
    Item_ODCI: Word; // Hightest "Open drug container index" value for this item, this year
    Item_remaining: Integer;
    Item_remind_as: Code_string;
    Item_fee: Code_string;
    Item_note: Integer;
    Item_last_PO: Code_string;
    Item_last_sold: Word;
    Item_log: string[3];
    Item_follow: Word;
    Item_site: Byte;
    Item_species1: Code_string;
    Item_species2: Code_string;
    Item_refill_exp: Byte; // Can't refill after this no. of months (e.g. 12 mo.)
    Item_refill_tx: Code_string;
      // This treatment resets the refill count and "refill_exp" restriction
    Item_refill_wait: Byte; // Must refill after this no. of days (since last dispensed)
    Item_doctor: Doctor_str; // Default doctor for this item        {#1019+}
    Item_sex: string[4];
    Item_needed: Boolean; // LC #1024  added field and decremented item_reserve from 44 to 43
    Item_follow_subject: Integer;
    Item_reserv: array[1..39] of Char;
  end; // Item_record

  Vendor_record = record
    Vendor_code: Code_string;
    Vendor_recd: Char;
    Vendor_name: string[25];
    Vendor_address: string[25];
    Vendor_city: string[15];
    Vendor_state: string[3];
    Vendor_zip: string[11];
    Vendor_phone: string[13];
    Vendor_fax: string[13];
    Vendor_terms: string[17];
    Vendor_lead: Word;
    Vendor_purchases: Integer;
    Vendor_added: string[5];
    Vendor_needto: Boolean;
    Vendor_contact: string[26];
    Vendor_URL: string[40];
    Vendor_account: string[15];
    Vendor_email: Integer;
    Vendor_language: TLanguage;
    Vendor_reserve: array[1..95] of Byte;
  end; { Vendor_record }

  TCategory_name = string[31];

  { Item category record definition }
  Category_record = record
    Category_code: Code_string;
    Category_recd: Char;
    Category_name: TCategory_name;
    Category_added: Code_string;
    Category_markup: SMALLINT;
    Category_needto: Boolean;
    Category_acctno: Integer;
    Category_sequence: Word;
    Category_codes: string[7];
    Category_sales: Integer;
    Category_report: string[31];
    Category_site: Byte;
    Category_reserv: array[1..39] of Char;
  end; { Category record }

  { Usage record definition }
  TUsageFlag = (ufDontPrice, ufPostToSoap, ufTrackCompliance);
  TUsage_flags = set of TUsageFlag;
    // Used only in SOAP plans built from canned estimates  #RWM 11-05-02

  Usage_ptype = (upIsOther, upIsTreatment, upIsService, upIsDiagnosis, upIsDiscount, upIsProblem,
    upIsReserved, upIsAbnormality, upIsRuleOut, upIsDiagPlan, upIsTreatPlan,
    upIsSubjective, upIsDiagnoses, upIsItem, upIsTemplate);

  Usage_record = record
    Usage_amount: Integer;
      // Estimates in SOAP records, etc....also used for variance qty for inventory used
    Usage_flags: TUsage_flags;
    Usage_ODCI: Word; // Highest "Open drug container index" for this item, this year
    Usage_recd: Char;
    Usage_limit: Byte; // Health plan service count
    Usage_quantity: Integer;
      // Qty used for usage, Discount rate for health plans (e.g. 25.00 = 25%)
    Usage_surcharge: SMALLINT; // Not currently used
    Usage_parent: Integer;
      // Points to either service, treatment, diagnosis, plan, presenting problem, problem, or SOAP record
    Usage_parentis: Usage_ptype;
    Usage_entry: History_type;
    Usage_note: Integer;
    Usage_boolean: Boolean;
    Usage_code: Code_string;
    Usage_site: Byte;
    Usage_reason: Char;
  end; { Usage_record }

  Order_head = record
    case Integer of
      1: (Order_hdate: Word); { Order RRN = 1: Release date for order }
      2: (Order_hvendor: Code_string); {           = 2: Vendor code }
      3: (Order_hstatus: Word); {           = 3: Date order took on current state }
      4: (Order_hitem: Code_string); {           = all others: Item_code }
  end; { Order_head }

  { Order record definition }
  Order_record = record
    Order_header: Order_head;
    Order_recd: Char;
    Order_quantity: Word; { Order RRN = 2: Order_status; otherwise, qty to order }
    Order_received: Word; { Quantity received }
    Order_cost: Integer; { Cost in tenths of pennies }
    Order_expires: Word;
  end;

  { Drug labels record definition }
  Labels_record = record
    Labels_name: string[15];
    Labels_text: Integer; { Offset in WP file of text of label }
    Labels_recd: Char;
    Labels_frequency: Integer;
    Labels_code: Code_string; { Code of this label }
    Labels_refills: Integer;
    Labels_allow_refills: Boolean;
    Labels_reserv: array[1..11] of Byte;
  end; { Labels_record }

  { Electronic travel sheet }
  eTravel_record = record
    eTravel_recd: Char;
    eTravel_animal: Integer; { RRN of animal associated with this entry }
    eTravel_entry: Integer; { RRN of treatment, item, or diagnosis }
    eTravel_type: History_type; { Which kind of entry is this }
    eTravel_quantity: Integer; { Quantity selected }
    eTravel_date: Word; { Date entry selected }
    eTravel_doctor: Doctor_str; { Doctor assigned }
    eTravel_reserv: array[1..20] of Byte;
  end; { eTravel_record }

  { Need List record layout }// LC#  7/22/03
  Need_record = record
    Need_recd: Char;
    Need_code: Code_string;
    Need_description: string[40];
    Need_doctor: Doctor_str;
    Need_quantity: Integer;
    Need_date: Word;
    Need_pad: Word;
    Need_item: Integer; //RRN of associated item  Blank if not contained in inv list.
    Need_reserve: array[1..200] of Byte;
  end; { Need_record }

  TPrice_action = (paNone, paManual, paReceipt, paMarkup);
  // Item price history record layout
  Price_record = record
    Price_recd: Char;
    Price_site: Byte;
    Price_code: Code_string;
    Price_date: Word;
    Price_TOD: Word;
    Price_from: Integer;
    Price_to: Integer;
    Price_set_by: Doctor_str;
    Price_action: TPrice_action;
    Price_reserve: array[1..40] of Byte;
  end; // Price_record

  { Audit trail record layout }
  Audit_record = record
    Audit_recd: Char;
    Audit_date: Word;
    Audit_time: Integer; { Seconds past midnight }
    Audit_station: Code_string; { ID of workstation }
    Audit_user: Code_string; { UserID of user }
    Audit_client: Integer; { RRN of current client, if any }
    Audit_animal: Integer; { RRN of current animal, if any }
    Audit_function: Code_string; { Code of function in RESOURCE.VD$ }
    Audit_comments: string[65]; { Additional information re. this entry }
  end; { Audit_record }

  //TAppointCommunication = (acNone, acPhone, acEmail);
  Follow_record = record
    Follow_recd: Char;
    Follow_code: Code_string;
    Follow_critical: Boolean;
    Follow_due: Word;
    Follow_origin: Word;
    Follow_subject: string[30];
    Follow_doctor: Doctor_str;
    Follow_client: Integer;
    Follow_animal: Integer;
    Follow_note: Integer;
    Follow_extra: Integer;
    Follow_confirm: TAppoint_confirm;
    //Follow_communication: TAppointCommunication;
    Follow_reserv: array[1..35] of Byte;
  end; // Follow_record

  PO_record = record
    PO_site: Byte;
    PO_pad1: array[1..5] of Byte;
    PO_order: File_string;
    PO_date: Word;
    PO_invoice: string[15];
    PO_quantity: SMALLINT;
    PO_recd: Char;
    PO_code: Code_string;
    PO_tax: Integer;
    PO_pad3: array[1..4] of Char;
    PO_vendor: Integer;
    PO_cost: Integer;
    PO_pack: Integer;
  end; { PO_record }

  Split_record = record
    Split_recd: Char;
    Split_client: Integer;
    Split_percent: SMALLINT;
    Split_reserve: array[1..40] of Byte;
    Split_animal: Integer;
    Split_prev: Integer;
    Split_next: Integer;
  end; { Split_record }

  Group_record = record
    Group_recd: Char;
    Group_name: string[30];
    Group_logoff: Integer; { Seconds to elapse before auto-logoff }
    Group_grant: Integer; { Not used..  }
    Group_reserve: array[1..40] of Byte;
    Group_prev: Integer;
    Group_next: Integer;
  end; { Group_record }

  { Record definition for defined system functions, the use of which can be limited using the security feature of AVImark }
  Resource_record = record
    Resource_recd: Char; { Record status flag - 'A" = Ok, 'D' = Deleted record }
    Resource_code: string[5]; { Key of this resource record in INDEX8.VM$ }
    Resource_description: string[60]; { Descriptive name of this resource }
    Resource_reshdr: Integer; { Record No. of parent category record }
    Resource_authed: Integer;
      { UNUSED.  Was Number of groups auth'ed to this resource in DOS Version }
    Resource_audit: Char; { Type of audit; Blank=None, A=All accesses, F=Failed attempts }
    Resource_protected: Boolean;
      { UNUSED.  Was True in DOS Version if any user groups have this resource in their grant records  }
    Resource_reserve: array[1..42] of Byte;
  end; { Resource_record }

  Reshdr_record = record
    Reshdr_recd: Char;
    Reshdr_name: string[30];
    Reshdr_reserve: array[1..52] of Byte;
  end; { Reshdr_record }

  TUser_notify = (upNever, upAtLogon, upAtClientSelect, upAtIdle);
  TUser_type = (utFullType, utPartType, utNonVet);
  TUser_access = (uaFull, uaAddHistory, uaAddPatients, uaReadOnly);

  TUser_id = string[3];

  User_record = record
    User_recd: Char;
    User_id: TUser_id;
    User_name: string[30];
    User_password: string[5];
    User_group: Integer;
    User_license: string[10];
    User_staff: Byte;
    User_pad1: Word;
    User_daily_ot: Word; // #CM 04/09/02 hours per day before ot kicks in * 100
    User_report: string[30];
    User_inactive: Boolean;
    User_account: Integer; //#RWM 06/09/03 Account no. of this user's record
    User_access: TUser_access;
    User_reserv1: array[1..5895] of Byte; //#CM 04/09/02 used to be TUser_NoAppts
    User_soapnotes: Boolean;
    User_apptseq: Byte;
    User_DEA: string[12];
    User_site: Byte;
    User_type: TUser_type;
    User_clocks_in: Boolean; //CM 12/12/00
    User_clocked_in: Integer; //CM 12/12/00 points to timeclock_file
    User_start_period: Word; //CM 12/15/00 last date payroll was run for this user
    User_period_duration: Word; //CM 1/15/01 payroll duration for the user
    User_reserve: Byte;
    User_notify: TUser_notify;
    User_apptcolor: Integer;
    User_appt_width: Integer;
  end; { User_record }

  Grant_record = record
    Grant_recd: Char;
    Grant_pad: Integer;
    Grant_group: Integer;
    Grant_code: TString7;
  end; { Grant_record }

  Dialog_record = record
    Dialog_request: Request_type; { Function to perform }
    Dialog_key: string[50];
      //IsamKeyStr; { Key value to use } //#CM 09/06/02 commented to remove dependency on Filer.pas
    Dialog_recno: Integer; { Record no. to use }
    Dialog_index: Byte; { Which index to process }
    Dialog_reserved: array[1..20] of Byte;
  end; { Dialog_record }

  Quote_disposition = (qsActive, qsPosted, qsDeleted);

  Quote_record = record
    Quote_name: string[30]; // Name of this estimate
    Quote_recd: Char; // Active record code for this estimate record in 'QUOTE.VM$'
    Quote_date: Word; // Date this estimate created
    Quote_doctor: Doctor_str; // Userid of doctor who created this estimate
    Quote_reserv: array[1..36] of Byte;
    Quote_results: Integer; // More stuff for this estimate
    Quote_animal: Integer; // Parent animal for this estimate
    Quote_document: File_string; // Document printed for this estimate
    Quote_declined: Boolean; // Estimate has been declined by the client
    Quote_status: Quote_disposition;
    Quote_pad1: Byte;
  end; { Quote_record }

  TQuotail_flags = set of (qfPublicNotes, qfAllowReprice);
  Quotail_record = record
    Quotail_recd: Char;
    Quotail_codes: string[7];
    Quotail_quantity: Integer;
    Quotail_variance: Integer;
    Quotail_total: Integer;
    Quotail_description: string[40];
    Quotail_code: Code_string;
    Quotail_type: Quotail_types;
    Quotail_quote: Integer;
    Quotail_repeat: Integer; //#RWM 12/19/02
    Quotail_note: Integer;
    Quotail_flags: TQuotail_flags;
    Quotail_varianceis: TVariance_is;
    Quotail_sequence: Integer;
    Quotail_reserv: array[1..26] of Byte;
  end; { Quotail_record }

  Vaccine_record = record
    Vaccine_id: string[10]; { Vaccination id (e.g. Rabies Tag no.) }
    Vaccine_recd: Char; { Active record code }
    Vaccine_date: Word; { Date of vaccination }
    Vaccine_doctor: Doctor_str; { User id performing vaccination }
    Vaccine_code: Code_string; { System table entry code of vaccine }
    Vaccine_pad: array[0..10] of Byte;
    Vaccine_expiration: string[8]; { Expiration date of vaccine }
    Vaccine_virus: string[6]; { Virus type }
    Vaccine_mfg: string[6]; { Manufacturer of vaccine }
    Vaccine_admin: string[6]; { How administered }
    Vaccine_service: Integer; { RRN of associated service record }
    Vaccine_serial: string[15]; { Serial no. of vaccine }
    Vaccine_reserv: array[1..24] of Byte;
  end;

  TModel_type = (mtAge, mtDate, mtDecimal, mtDiag, mtInteger, mtItem, mtPhoto, mtPhrase, mtPosNeg,
    mtSensRes, mtTable, mtTime, mtTreat, mtUser, mtWP, mtYesNo, mtChecked);

type
  TModel_code = (mcOnPatientChart, mcSearchable, mcMergeWord, mcPrintIfPositive, mcMustChoose,
    mcNoPrintPrompt);
  TModel_codes = set of TModel_code;
  TModel_universal = array[0..SizeOf(TModel_codes) - 1] of Byte;
  TModel_parentis = (mpIsTreatment, mpIsEntry);

  // Test results model file layout
  Model_record = record
    Model_prompt: string[15];
    Model_recd: Char;
    Model_type: TModel_type;
    Model_default: string[40];
    Model_units: string[15];
    Model_codes: TModel_codes;
    Model_parentis: TModel_parentis;
    Model_generation: Word;
    Model_pad1: array[1..2] of Byte;
    Model_used: Boolean;
    Model_table: Code_string;
    Model_reserve: array[1..15] of Byte;
    Model_pad2: array[1..4] of Byte;
    Model_parent: Integer;
    Model_pad3: array[1..16] of Byte;
  end; { Model_record }

  Normals_record = record
    Normals_recd: Char; { Active record code: D-deleted record }
    Normals_pad1: string[6]; //used to be normals_species
    Normals_min: SINGLE; { Minimum value, this species }
    Normals_max: SINGLE; { Maximum value, this species }
    Normals_species: Code_string; //#LC  took from reserve
    Normals_reserve: array[1..11] of Byte;
    Normals_model: Integer; { RRN of parent model record }
    Normals_prev: Integer; { RRN of previous Normals record, this model }
    Normals_next: Integer; { RRN of next Normals record, this model }
  end; { Normals_record }

  ProbHist_record = record
    ProbHist_code: Code_string; { Code (in System Tables or Problem List) of this problem }
    ProbHist_recd: Char;
    ProbHist_opened_by: Doctor_str; { Doctor opening this problem }
    ProbHist_opened_on: Word; { Date opened }
    ProbHist_closed_by: Doctor_str; { Doctor closing this problem }
    ProbHist_closed_on: Word; { Date closed }
    ProbHist_keywords: array[1..6] of Code_string; { Additional search keywords }
    ProbHist_description: string[50]; { Description of problem, copied from system table entry }
    ProbHist_animal: Integer; { Animal for which this problem record is associated }
    ProbHist_note: Integer;
    ProbHist_reserv: array[1..36] of Byte;
  end; // ProbHist_record

  ProbHdr_record = record
    ProbHdr_name: string[30];
    ProbHdr_recd: Char;
    ProbHdr_codes: string[6];
    ProbHdr_reserv: array[1..40] of Byte;
  end; // ProbHdr_record

  Problem_record = record
    Problem_code: Code_string;
    Problem_recd: Char;
    Problem_description: string[50];
    Problem_codes: string[6];
    Problem_recommendations: Integer;
    Problem_photo: Integer;
    Problem_pad1: array [1..5] of Byte;
    Problem_probhdr: Integer;
    Problem_pad: Word;
    Problem_note: Integer;
    Problem_document: Code_string;
    Problem_protocol: Integer;
    Problem_species1: Code_string;
    Problem_species2: Code_string;
    Problem_sequence: Integer;
    Problem_reserv: Byte;
  end; // Problem_record

  TListStatus = (lsNew, lsWorking, lsComplete);
  TListStatusSet = set of TListStatus;

  Lists_record = record
    Lists_code: Code_string; // Code of System Table entry for this work list
    Lists_recd: Char; // Active record code
    Lists_added_by: Doctor_str; // Doctor that added this list entry
    Lists_added_on: Word; // Date this entry added
    Lists_animal: Integer; // Patient associated with this entry
    Lists_note: Integer; // Offset into WP.VM$ of this note
    Lists_status: TListStatus; // Status of this entry (e.g. new entry, work in progress, etc.)
    Lists_accepted_by: Doctor_str; // User currently assigned to this entry
    Lists_closed: Doctor_str; // Doctor who closed this entry
    Lists_accepted_tod: Word; // Time of day this entry accepted
    Lists_accepted_on: Word; // Date this entry accepted
    Lists_reserv: array[1..46] of Byte;
  end; // List_record

  TVariance_flags = set of (vfNone);

  Variance_record = record
    Variance_code: Code_string;
    Variance_recd: Char;
    Variance_date: Word;
    Variance_TOD: Word;
    Variance_quantity: Integer;
    Variance_doctor: Doctor_str;
    Variance_reason: Char;
    Variance_note: Integer;
    Variance_flags: TVariance_flags;
    Variance_animal: Integer;
    Variance_service: Integer;
    Variance_codes: string[8];
    Variance_reserv: array[1..23] of Byte;
  end; // Variance_record

  PSite_option = ^Site_options;
  Site_options = record
    Site_same: Boolean;
    Site_same_site: Integer;
    Site_copy_site: Integer;
    Site_options_reserv: array[1..25] of Byte;
  end;

  TSite_list_options = array[htTreatment..htDiagnosis] of Site_options;

  Site_record = record
    Site_recd: Char;
    Site_name: string[40];
    Site_address: string[40];
    Site_address2: string[40];
    Site_city: string[40];
    Site_state: string[2];
    Site_zip: string[10];
    Site_phone: string[14];
    Site_motto: string[80];
    Site_list_options: TSite_list_options;
    Site_tag_number: string[10];
    Site_to_company: Boolean;
      // auto-change the client's company value to be +1 of the site number last visited
    Site_alt_state: string[5]; // RWM Africa state field 10-06-00
    Site_invoice: Integer;
    Site_last_export: Word;
    Site_reserv: array[1..76] of Byte;
  end;

  //CM 12/11/00
  Timeclock_record = record
    Timeclock_recd: Char;
    Timeclock_in_tod: Word;
    Timeclock_out_tod: Word;
    Timeclock_in_date: Word;
    Timeclock_out_date: Word;
    Timeclock_entry: Integer;
    Timeclock_user: Integer;
    Timeclock_note: Integer; //#CM 05/05/03
    Timeclock_reserve: array[1..96] of Byte;
  end;

  TLog_flag = (lfChanged, lfAdded);
  Log_record = record
    Log_datetime: TDateTime;
    Log_recd: Char;
    Log_fileno: Word;
    Log_recno: Integer;
    Log_flag: TLog_flag;
    Log_length: Integer; // used in AVIvput, Alloc_vrecord
    Log_reserved: array[1..6] of Byte;
  end;

  TResults_parentis = (xpIsService, xpIsMedical, xpIsClient, xpIsAnimal, xpIsResults);
  Results_prefix = record
    Results_parent: Integer;
    Results_parentis: TResults_parentis;
    Results_next: Integer;
    Results_prev: Integer;
    Results_site: Byte;
    Results_recd: Char;
    Results_generation: Word;
    Results_length: Integer;
  end; { Results_prefix }

  Results_record = record
    Results_header: Results_prefix;
    Results_data: array[0..1023] of Char;
  end; { Results_record }

  { Word processing file record }
  WP_prefix = record
    WP_parent: Integer; { RRN of record that points to this block of text }
    WP_parentis: Byte; { What kind of note is this? }
    WP_reserv: array[1..8] of Byte;
    WP_size: Integer; { Total size of WP_text data }
  end; { WP_header }

  WP_record = record
    WP_header: WP_prefix;
    WP_text: array[0..65535] of Char;
  end; { WP_record }

  OptionWP_record = WP_record;

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

  Query_record = record
    Query_name: string[30];
    Query_recd: Char;
    Query_added: Word;
    Query_by: Doctor_str;
    Query_notes: Integer;
    Query_reserv: array[1..60] of Byte;

    case Integer of
      1: (Client_values: TField_set;
        Account_values: TField_set;
        Animal_values: TField_set;
        Service_values: TField_set;
        Reminder_values: TField_set;
        Estimate_values: TField_set;
        Follow_values: TField_set;
        Split_values: TField_set;
        Appointment_values: TField_set;
        Boarding_values: TField_set;
        Unused_values: TField_set);

      2: (Value_array: TField_set_array);
  end; { Query_record }

  TImport_type = (impAdded, impChanged, impNote, impAlert, impResults, impSubjNotes, impExamNotes,
    impTPlanNotes, impInstruction, impDefaultReminder, impDPlanNotes, impDiagNotes, impRuleNotes);

  Import_record = record
    Import_recd: Char;
    Import_type: TImport_type;
    Import_parentis: Byte;
    Import_parent: Integer;
    Import_date: Word;
    Import_time: Word;
    Import_user: Doctor_str;
    Import_note: Integer; // not used
    Import_index: Integer; // not used
    Import_old_word: Word; // old date etc. for display purposes
    Import_old_str: string[40]; // old client's name etc. for display purposes
    Import_reserv: array[1..12] of Byte;
  end;

  TAnalysis_parms = record
    Analysis_date: Word;
    Analysis_term: Integer;
    Analysis_send: Integer;
    Analysis_exclude: Boolean;
    Analysis_excludelist: TStringList;
    Analysis_includelist: TStringList;
  end; // TAnalysis_parms

  FormTemplateCategory_record = record
    FormTemplateCategory_recd: Char;
    FormTemplateCategory_name: string[40];
    FormTemplateCategory_reserve: array[1..300] of Byte;
  end;

  FormTemplate_record = record
    FormTemplate_recd: Char;
    FormTemplate_category: Integer;
    FormTemplate_code: Code_string;
    FormTemplate_name: string[50];
    FormTemplate_note: Integer;
    FormTemplate_sequence: Integer;
    FormTemplate_codes: string[5];
    FormTemplate_author: string[50];
    FormTemplate_date: Word;
    FormTemplate_time: Word;
    FormTemplate_version: Integer;
    FormTemplate_reserve: array[1..500] of Byte;
  end;

  FormTemplateVersion_record = record
    FormTemplateVersion_recd: Char;
    FormTemplateVersion_formtemplate: Integer;
    FormTemplateVersion_formwp: Integer;
    FormTemplateVersion_created: TAVIDate;
    FormTemplateVersion_time: TAVITime;
    FormTemplateVersion_used: Boolean;
    FormTemplateVersion_reserve: array[1..499] of Byte;
  end; // FOR Template_record

  FormTemplateWP_record = WP_record;

  MedicalForm_record = record
    MedicalForm_recd: Char;
    MedicalForm_medical: Integer;
    MedicalForm_date: Word;
    MedicalForm_form: Integer;
    MedicalForm_formtemplateversion: Integer;
    MedicalForm_reserve: array[1..500] of Byte;
  end;

  Form_record = record
    Form_parent: Integer;
    Form_size: Integer;
    Form_reserve: array[1..500] of Byte;
  end;

type
  PClient_record = ^Client_record;
  PAnimal_record = ^Animal_record;
  PAccount_record = ^Account_record;
  PService_record = ^Service_record;
  PSplit_record = ^Split_record;
  PVisit_record = ^Visit_record;
  PQA_record = ^QA_record;
  PQAhdr_record = ^QAhdr_record;
  PHospital_record = ^Hospital_record;
  POptionValue_record = ^OptionValue_record;
  POptionWP_record = ^OptionWP_record;
  PProbHist_record = ^ProbHist_record;
  PAppoint_record = ^Appoint_record;
  PImport_record = ^Import_record;
  PTreatment_record = ^Treatment_record;
  PHeader_record = ^Header_record;
  PReminder_record = ^Reminder_record;
  PItem_record = ^Item_record;
  PVendor_record = ^Vendor_record;
  PUsage_record = ^Usage_record;
  PMedical_record = ^Medical_record;
  POrder_record = ^Order_record;
  PPO_record = ^PO_record;
  PUser_record = ^User_record;
  PGroup_record = ^Group_record;
  PCategory_record = ^Category_record;
  PLabels_record = ^Labels_record;
  PFollow_record = ^Follow_record;
  PEstimate_record = ^Estimate_record;
  PTask_record = ^Task_record;
  PTable_record = ^Table_record;
  PEntry_record = ^Entry_record;
  PDiaghdr_record = ^Diaghdr_record;
  PDiagnosis_record = ^Diagnosis_record;
  PAudit_record = ^Audit_record;
  PeTravel_record = ^eTravel_record;
  PFacility_record = ^Facility_record;
  PFachdr_record = ^Fachdr_record;
  PBoard_record = ^Board_record;
  PGrant_record = ^Grant_record;
  PReshdr_record = ^Reshdr_record;
  PResource_record = ^Resource_record;
  PResults_record = ^Results_record;
  PQuote_record = ^Quote_record;
  PQuotail_record = ^Quotail_record;
  PDrughdr_record = ^Drughdr_record;
  PDrug_record = ^Drug_record;
  PDialog_record = ^Dialog_record;
  PQuery_record = ^Query_record;
  PModel_record = ^Model_record;
  PNormals_record = ^Normals_record;
  PActivity_record = ^Activity_record;
  PVaccine_record = ^Vaccine_record;
  PBlockOff_record = ^BlockOff_record;
  PProbHdr_record = ^ProbHdr_record;
  PProblem_record = ^Problem_record;
  PLists_record = ^Lists_record;
  PSite_record = ^Site_record;
  PTimeclock_record = ^Timeclock_record;
  PLog_record = ^Log_record;
  PNeed_record = ^Need_record;
  PPrice_record = ^Price_record;
  PVariance_record = ^Variance_record;
  PWP_record = ^WP_record;
  PFormTemplateCategory_record = ^FormTemplateCategory_record;
  PFormTemplate_record = ^FormTemplate_record;
  PFormTemplateVersion_record = ^FormTemplateVersion_record;
  PForm_record = ^Form_record;
  PFormTemplateWP_record = ^FormTemplateWP_record;
  PMedicalForm_record = ^MedicalForm_record;

const
  AVI_files = 72;

  Client_file = 1;
  Account_file = 2;
  Animal_file = 3;
  Service_file = 4;
  Split_file = 5;
  Visit_file = 6;
  QA_file = 7;
  QAhdr_file = 8;
  Hospital_file = 9;
  ProbHist_file = 10;
  Appoint_file = 11;
  Import_file = 12;
  Treatment_file = 13;
  Header_file = 14;
  Reminder_file = 15;
  Item_file = 16;
  Vendor_file = 17;
  Usage_file = 18;
  Medical_file = 19;
  Order_file = 20;
  PO_file = 21;
  User_file = 22;
  Group_file = 23;
  Category_file = 24;
  Labels_file = 25;
  Follow_file = 26;
  Estimate_file = 27;
  Task_file = 28;
  Table_file = 29;
  Entry_file = 30;
  Diaghdr_file = 31;
  Diagnosis_file = 32;
  Audit_file = 33;
  eTravel_file = 34;
  Facility_file = 35;
  Fachdr_file = 36;
  Board_file = 37;
  Grant_file = 38;
  Reshdr_file = 39;
  Resource_file = 40;
  Quote_file = 41;
  Quotail_file = 42;
  Drughdr_file = 43;
  Drug_file = 44;
  Dialog_file = 45;
  Query_file = 46;
  Model_file = 47;
  Normals_file = 48;
  Activity_file = 49;
  Vaccine_file = 50;
  BlockOff_file = 51;
  ProbHdr_file = 52;
  Problem_file = 53;
  Lists_file = 54;
  Results_file = 55;
  WP_file = 56;
  Phrase_file = 57;
  Site_file = 58;
  Timeclock_file = 59;
  ComLog_file = 60;
  BackupLog_file = 61;
  NeedList_file = 62;
  Price_file = 63;
  Variance_file = 64;
  FormTemplateCategory_file = 65;
  FormTemplate_file = 66;
  FormTemplateVersion_file = 67;
  Form_file = 68;
  FormTemplateWP_file = 69;
  MedicalForm_file = 70;
  OptionValue_file = 71;
  OptionWP_file = 72;

{$J+} // must be assignable for the Order_file
  AVI_filenames: array[1..AVI_files] of string[12] =
  ('CLIENT.VM$',
    'ACCOUNT.VM$',
    'ANIMAL.VM$',
    'SERVICE.VM$',
    'SPLIT.VM$',
    'VISIT.VM$',
    'QA.VM$',
    'QAHDR.VM$',
    'HOSPITAL.VM$',
    'PROBHIST.VM$',
    'APPOINT.VM$',
    'IMPORT.VM$',
    'TREAT.VM$',
    'HEADER.VM$',
    'PROC.VM$',
    'ITEM.VM$',
    'VENDOR.VM$',
    'USAGE.VM$',
    'MEDICAL.VM$',
    'ORDER.VM$',
    'PO.VM$',
    'USER.VM$',
    'GROUP.VM$',
    'CATEGORY.VM$',
    'LABELS.VM$',
    'FOLLOW.VM$',
    'ESTIMATE.VM$',
    'TASK.VM$',
    'TABLE.VM$',
    'ENTRY.VM$',
    'DIAGHDR.VM$',
    'DIAGNOSE.VM$',
    'AUDIT.VM$',
    'ETRAVEL.VM$',
    'FACILITY.VM$',
    'FACHDR.VM$',
    'BOARD.VM$',
    'GRANT.VM$',
    'RESHDR.VM$',
    'RESOURCE.VM$',
    'QUOTE.VM$',
    'QUOTAIL.VM$',
    'DRUGHDR.VM$',
    'DRUG.VM$',
    'DIALOG.VM$',
    'QUERY.VM$',
    'MODEL.VM$',
    'NORMALS.VM$',
    'ACTIVITY.VM$',
    'VACCINE.VM$',
    'BLOCKOFF.VM$',
    'PROBHDR.VM$',
    'PROBLEM.VM$',
    'LISTS.VM$',
    'RESULTS.VM$',
    'WP.VM$',
    'PHRASE.VM$',
    'SITE.VM$',
    'TIME.VM$',
    'COMLOG.VM$',
    'BACKLOG.VM$',
    'NEEDLIST.VM$',
    'PRICE.VM$',
    'VARIANCE.VM$',
    'FTCATGRY.VM$',
    'FTMPLATE.VM$',
    'FTMPLATV.VM$',
    'FORM.VM$',
    'FORMWP.VM$',
    'FMEDICAL.VM$',
    'OPTION.VM$',
    'OPTIONWP.VM$');
{$J-}

  AVI_sizes: array[1..AVI_files] of Word = (SizeOf(Client_record),
    SizeOf(Account_record),
    SizeOf(Animal_record),
    SizeOf(Service_record),
    SizeOf(Split_record),
    SizeOf(Visit_record),
    SizeOf(QA_record),
    SizeOf(QAhdr_record),
    SizeOf(Hospital_record),
    SizeOf(ProbHist_record),
    SizeOf(Appoint_record),
    SizeOf(Import_record),
    SizeOf(Treatment_record),
    SizeOf(Header_record),
    SizeOf(Reminder_record),
    SizeOf(Item_record),
    SizeOf(Vendor_record),
    SizeOf(Usage_record),
    SizeOf(Medical_record),
    SizeOf(Order_record),
    SizeOf(PO_record),
    SizeOf(User_record),
    SizeOf(Group_record),
    SizeOf(Category_record),
    SizeOf(Labels_record),
    SizeOf(Follow_record),
    SizeOf(Estimate_record),
    SizeOf(Task_record),
    SizeOf(Table_record),
    SizeOf(Entry_record),
    SizeOf(Diaghdr_record),
    SizeOf(Diagnosis_record),
    SizeOf(Audit_record),
    SizeOf(eTravel_record),
    SizeOf(Facility_record),
    SizeOf(Fachdr_record),
    SizeOf(Board_record),
    SizeOf(Grant_record),
    SizeOf(Reshdr_record),
    SizeOf(Resource_record),
    SizeOf(Quote_record),
    SizeOf(Quotail_record),
    SizeOf(Drughdr_record),
    SizeOf(Drug_record),
    SizeOf(Dialog_record),
    SizeOf(Query_record),
    SizeOf(Model_record),
    SizeOf(Normals_record),
    SizeOf(Activity_record),
    SizeOf(Vaccine_record),
    SizeOf(BlockOff_record),
    SizeOf(ProbHdr_record),
    SizeOf(Problem_record),
    SizeOf(Lists_record),
    1, 1, 1,
    SizeOf(Site_record),
    SizeOf(Timeclock_record),
    SizeOf(Log_record),
    SizeOf(Log_record),
    SizeOf(Need_record),
    SizeOf(Price_record),
    SizeOf(Variance_record),
    SizeOf(FormTemplateCategory_record),
    SizeOf(FormTemplate_record),
    SizeOf(FormTemplateVersion_record),
    SizeOf(Form_record),
    1,
    SizeOf(MedicalForm_record),
    SizeOf(OptionValue_record),
    1);

//{$IFNDEF prjExtractData}
type
  TAVI_index_definition = record
    Name: ShortString;
    NumKeys: Word;
    FileBlockPtr: IsamFileBlockPtr;
    IDesc: IsamIndDescr;
  end;

const
{$J+} // must be assignable for BtOpenFileBlock etc.
  AVI_index_definitions: array[TAVImark_indexes] of TAVI_index_definition =
  ((Name: 'INDEX1'; NumKeys: 5; IDesc: (
    // ClientName_index
    (KeyL: 25; AllowDupK: TRUE),
      // UpperCase(Lst(Client_last, 15) + Lst(Client_first or Client_spouse, 10)
    // UpperCase(Lst(Client_spouse, 15))
// Phone_index
    (KeyL: 8; AllowDupK: TRUE), // UpperCase(Client_phone)
    // WholePhone_index
    (KeyL: 12; AllowDupK: TRUE),
      // WholePhone_index Lst(Client_area, 3) + ' ' Lst(UpperCase(Client_phone), 8)
    // ClientSoundex_index
    (KeyL: 4; AllowDupK: TRUE), // ClientSoundex_index   Get_soundex(Trim(First_wd(Client_last)))
    // DeletedClients_index
    (KeyL: 4; AllowDupK: FALSE), // Deleted clients - Int32ToKey(Client_recno)
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX2'; NumKeys: 6; IDesc: (
    // AnimalName_index
    (KeyL: 20; AllowDupK: TRUE),
      // UpperCase(Lst(Animal_name, 10) + Lst(Client_last, 10)) + '_' + Get_soundex(Trim(First_wd(Animal_name)))
    // Rabies_index
    (KeyL: 10; AllowDupK: TRUE), // UpperCase(Animal_rabies)
    // Animal_index
    (KeyL: 18; AllowDupK: FALSE),
      // Int32ToKey(Animal_client) + ByteToKey(Pos(Deceased_action, Animal_codes)) + Lst(UpperCase(Animal_name), 8) + Int32ToKey(Animal_recno)
    // Registration_index
    (KeyL: 15; AllowDupK: TRUE), // UpperCase(Animal_registration)
    // Relationship_index
    (KeyL: 12; AllowDupK: FALSE), // Lst(Entry_code, 8) + Int32ToKey(Animal_recno)
    // Locator_index
    (KeyL: 12; AllowDupK: FALSE), // UpperCase(Read_phrase(Animal_locator))

    (KeyL: 1; AllowDupK: TRUE),
    (KeyL: 1; AllowDupK: TRUE),
    (KeyL: 1; AllowDupK: TRUE),
    (KeyL: 1; AllowDupK: TRUE),
    (KeyL: 1; AllowDupK: TRUE),
    (KeyL: 1; AllowDupK: TRUE),
    (KeyL: 1; AllowDupK: TRUE),
    (KeyL: 1; AllowDupK: TRUE),
    (KeyL: 1; AllowDupK: TRUE))),

    (Name: 'INDEX3'; NumKeys: 4; IDesc: (
    // Whogot_index
    (KeyL: 22; AllowDupK: FALSE),
      // Lst(Service_code, 8) + Int32ToKey(Service_animal) + DescendingKey(WordToKey(Service_date) + Int32ToKey(Service_sequence) + Int32ToKey(Service_recno), 10)
    // Service_index
    (KeyL: 14; AllowDupK: FALSE),
      // Int32ToKey(Service_animal) + DescendingKey(WordToKey(Service_date) + Int32ToKey(Service_sequence) + Int32ToKey(Service_recno), 10)
    // ServUsage_index
    (KeyL: 8; AllowDupK: TRUE), // Int32ToKey(Usage_parent) + Int32ToKey(Usage_recno)
    // ServMedical_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Usage_parent) + Int32ToKey(Usage_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX4'; NumKeys: 6; IDesc: (
    // TreatCode_index
    (KeyL: 9; AllowDupK: FALSE), // ByteToKey(Treatment_site) + Treatment_code
    // TreatDesc_index
    (KeyL: 12; AllowDupK: TRUE), // Next_wd(Treatment_description)
    // Treatment_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(Treatment_header) + WordToKey(Treatment_sequence) + Int32ToKey(Treatment_recno)
    // Header_index
    (KeyL: 30; AllowDupK: TRUE), // ByteToKey(Header_site) + UpperCase(Header_name)
    // TreatUsage_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Usage_parent) + Int32ToKey(Usage_recno)
    // HeaderCode_index
    (KeyL: 9; AllowDupK: FALSE), // ByteToKey(Header_site) + Header_code

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX5'; NumKeys: 13; IDesc: (
    // ItemCode_index
    (KeyL: 16; AllowDupK: FALSE),
      // ByteToKey(Item_site) + Item_code  // ByteToKey(Item_site) + UpperCase(Item_UPC)
    // ItemDesc_index
    (KeyL: 16; AllowDupK: TRUE), // Next_wd(Item_description)
    // Item_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(Item_category) + WordToKey(Item_sequence) + Int32ToKey(Item_recno)
    // Category_index
    (KeyL: 17; AllowDupK: TRUE), // ByteToKey(Category_site) + UpperCase(First_wd(Category_name))
    // Vendor_index
    (KeyL: 16; AllowDupK: TRUE), // Vendor_code
    // PO_index
    (KeyL: 11; AllowDupK: TRUE),
      // ByteToKey(PO_site) + Lst(PO_code, 8) + DescendingKey(WordToKey(PO_date), 2)
    // Labels_index
    (KeyL: 12; AllowDupK: FALSE), // Lst(Item_code, 8) + Int32ToKey(Labels_recno)
    // CategoryCode_index
    (KeyL: 8; AllowDupK: FALSE), // ByteToKey(Category_site) + Category_code
    // Price_index
    (KeyL: 17; AllowDupK: FALSE),
      // ByteToKey(Price_site) + Lst(Price_code, 8) + DescendingKey(WordToKey(Price_date) + WordToKey(Price_TOD) + Int32ToKey(Price_recno), 8)
    // ItemUsage_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Usage_parent) + Int32ToKey(Usage_recno)
    // VariCode_index
    (KeyL: 14; AllowDupK: FALSE),
      // Lst(Variance_code, 8) + DescendingKey(WordToKey(Variance_date) + Int32ToKey(Variance_recno), 6)
    // VariDate_index
    (KeyL: 14; AllowDupK: FALSE),
      // DescendingKey(WordToKey(Variance_date) + Int32ToKey(Variance_recno), 6) + Variance_code)

    (KeyL: 20; AllowDupK: FALSE), // Lst(Item_code, 8) + Lst(FileName, 8) + Int32ToKey(Need_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX6'; NumKeys: 1; IDesc: (
    // Lists_index
    (KeyL: 13; AllowDupK: FALSE), // Lists_recd + Lst(Lists_code, 8) + Int32ToKey(Lists_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX7'; NumKeys: 5; IDesc: (
    // Account_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(Account_client) + DescendingKey(WordToKey(Account_date) + Int32ToKey(Account_recno), 6)
    // AccountDate_index
    (KeyL: 6; AllowDupK: TRUE),
      // DescendingKey(WordToKey(Account_date) + Int32ToKey(Account_recno), 6)
    // AccountSumm_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(Account_client) + DescendingKey(WordToKey(Account_date) + Int32ToKey(Account_recno), 6)
    // AccountHeld_index
    (KeyL: 6; AllowDupK: FALSE), // WordToKey(Account_deposit) + Int32ToKey(Account_recno)
    // AccountType_index
    (KeyL: 11; AllowDupK: FALSE),
      // Int32ToKey(Account_client) + ByteToKey(Pos(Account_type, Trans_types)) + DescendingKey(WordToKey(Account_date) + Int32ToKey(Account_recno), 6)
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX8'; NumKeys: 9; IDesc: (
    // GroupName_index
    (KeyL: 30; AllowDupK: TRUE),
    // User_index
    (KeyL: 9; AllowDupK: FALSE),
      // Int32ToKey(User_group) + ByteToKey(User_staff) + Int32ToKey(User_recno)
    // UserId_index
    (KeyL: 3; AllowDupK: FALSE), // User_id
    // UserPassword_index
    (KeyL: 8; AllowDupK: FALSE), // User_password
    // Grant_index
    (KeyL: 8; AllowDupK: FALSE),
    // Resource_index
    (KeyL: 8; AllowDupK: FALSE),
    // ResourceCode_index
    (KeyL: 8; AllowDupK: FALSE),
    // ResourceDesc_index
    (KeyL: 20; AllowDupK: TRUE),
    // GrantWhogot_index
    (KeyL: 11; AllowDupK: FALSE), // Lst(Grant_code, 7) + Int32ToKey(Grant_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX9'; NumKeys: 7; IDesc: (
    // Reminder_index
    (KeyL: 28; AllowDupK: FALSE),
      // Int32ToKey(Reminder_parent) + Lst(UpperCase(Reminder_series_name), 19) + ByteToKey(Reminder_series_seq) + Int32ToKey(Reminder_recno)
    // RemindCode_index
    (KeyL: 12; AllowDupK: TRUE), // Lst(Reminder_code, 8) + Int32ToKey(Reminder_parent)
    // RemindTreat_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Reminder_parent) + Int32ToKey(Reminder_recno)
    // RemindItem_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Reminder_parent) + Int32ToKey(Reminder_recno)
    // RemindDate_index
    (KeyL: 6; AllowDupK: FALSE), // WordToKey(Reminder_due) + Int32ToKey(Reminder_recno)
    // RemindSeries_index
    (KeyL: 24; AllowDupK: TRUE),
      // Lst(ByteToKey(Ord(rpIsAnimal) OR Ord(rpIsTreatment) OR (Ord(rpIsItem)) + Int32ToKey(Reminder_parent) + UpperCase(Reminder_series_name), 23) + ByteToKey(Reminder_series_seq)
    // RemindDiag_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Reminder_parent) + Int32ToKey(Reminder_recno) }

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX10'; NumKeys: 5; IDesc: (
    // TableCode_index
    (KeyL: 8; AllowDupK: TRUE), // Table_code
    // Entry_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(Entry_table) + WordToKey(Entry_sequence) + Int32ToKey(Entry_recno)
    // EntryCode_index
    (KeyL: 12; AllowDupK: FALSE), // Int32ToKey(Entry_table) + Entry_code
    // EntryDesc_index
    (KeyL: 16; AllowDupK: TRUE), // Next_wd(Entry_description)
    // EntryUsage_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Usage_parent) + Int32ToKey(Usage_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX11'; NumKeys: 5; IDesc: (
    // DiagCode_index
    (KeyL: 9; AllowDupK: FALSE), // ByteToKey(Diagnosis_site) + Diagnosis_code
    // Diagnosis_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(Diagnosis_diaghdr) + WordToKey(Diagnosis_sequence) + Int32ToKey(Diagnosis_recno)
    // DiagDesc_index
    (KeyL: 16; AllowDupK: TRUE), // Next_wd(Diagnosis_description)
    // Diaghdr_index
    (KeyL: 30; AllowDupK: TRUE), // ByteToKey(DiagHdr_site) + UpperCase(Diaghdr_name)
    // DiagUsage_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Usage_parent) + Int32ToKey(Usage_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX12'; NumKeys: 4; IDesc: (
    // Estimate_index
    (KeyL: 30; AllowDupK: TRUE), // Estimate_name
    // Task_index
    (KeyL: 12; AllowDupK: FALSE),
      // Int32ToKey(Task_estimate) + Int32ToKey(Task_sequence) + Int32ToKey(Task_recno)
    // Quote_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Quote_animal) + Int32ToKey(Quote_recno)
    // Quotail_index
    (KeyL: 12; AllowDupK: FALSE),
      // Int32ToKey(Quotail_quote) + Int32ToKey(Quotail_sequence) + Int32ToKey(Quotail_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX13'; NumKeys: 4; IDesc: (
    // Appoint_index
    (KeyL: 7; AllowDupK: TRUE),
      // ByteToKey(Appoint_site) + WordToKey(Appoint_date) + Lst(Appoint_doctor, 3) + ByteToKey(Appoint_type)
    // ApptParent_index
    (KeyL: 7; AllowDupK: TRUE),
      // ByteToKey(Ord(Appoint_parentis)) + Int32ToKey(Appoint_parent) + WordToKey(Appoint_date)
    // BlockOff_index
    (KeyL: 9; AllowDupK: FALSE),
      // ByteToKey(BlockOff_site) + Int32ToKey(BlockOff_user) + Int32ToKey(BlockOff_recno)
    // AppointDr_index
    (KeyL: 8; AllowDupK: TRUE),
      // ByteToKey(Appoint_site) + Lst(Appoint_doctor, 3) + ByteToKey(Ord(appoint_parentis)) + WordToKey(Appoint_date) + ByteToKey(Appoint_type)
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX14'; NumKeys: 2; IDesc: (
    // FollowAnimal_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Follow_animal) + Int32ToKey(Follow_recno)
    // FollowDate_index
    (KeyL: 6; AllowDupK: FALSE), // WordToKey(Follow_due) + Int32ToKey(Follow_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX15'; NumKeys: 1; IDesc: (
    // Split_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Split_animal) + Int32ToKey(Split_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX16'; NumKeys: 7; IDesc: (
    // Facility_index
    (KeyL: 12; AllowDupK: TRUE), // Int32ToKey(FacHdr_recno) + Lst(Facility_name, 8)
    // Board_index
    (KeyL: 11; AllowDupK: FALSE),
      // Int32ToKey(Facility_recno) + ByteToKey(Ord(Board_type) + DescendingKey(WordToKey(Board_date), 2) + Int32ToKey(Board_rrn)
    // Activity_index
    (KeyL: 9; AllowDupK: FALSE),
      // Int32ToKey(Visit_recno) + ByteToKey(Ord(Activity_type) + Int32ToKey(Activity_Recno)
    // Census_index
    (KeyL: 2; AllowDupK: TRUE), // DescendingKey(WordToKey(Visit_in_date))
    // BoardAnimal_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(Board_animal) + WordToKey(Board_date) + Int32ToKey(Board_recno)
    // FacHdr_index
    (KeyL: 9; AllowDupK: FALSE),
      // ByteToKey(FacHdr_site) + Int32ToKey(FacHdr_sequence) + Int32ToKey(FacHdr_recno)
    // eTravel_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Animal_recno) + Int32ToKey(eTravel_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX17'; NumKeys: 3; IDesc: (
    // Model_index
    (KeyL: 11; AllowDupK: FALSE),
      // Int32ToKey(Model_parent) + ByteToKey(Ord(Model_parentis)) + WordToKey(Parent_generation) + Int32toKey(Model_recno)
    // Normals_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(Normals_model) + Int32toKey(Normals_recno)
    // ResultsStr_index
    (KeyL: 26; AllowDupK: TRUE),
      // ByteToKey(Ord(Results_parentis)) + Lst(UpperCase(Return_results_str(Model_recno, Results_offset)), 25)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX18'; NumKeys: 4; IDesc: (
    // QAHdr_index
    (KeyL: 30; AllowDupK: TRUE), // UpperCase(QAHdr_name)
    // QA_index
    (KeyL: 12; AllowDupK: FALSE),
      // Int32ToKey(_QACategory) + Int32ToKey(Sequence) + Int32toKey(Recno)
    // QADesc_index
    (KeyL: 12; AllowDupK: TRUE), // Next_wd(QA_description)
    // QACode_index
    (KeyL: 8; AllowDupK: FALSE), // QA_code

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX19'; NumKeys: 2; IDesc: (
    // ProbHist_index
    (KeyL: 8; AllowDupK: FALSE), // Int32ToKey(ProbHist_animal) + Int32ToKey(ProbHist_recno);
    // ProbWhogot_index
    (KeyL: 16; AllowDupK: TRUE),
      // Lst(ProbHist_code, 8) + Int32ToKey(ProbHist_animal) + Int32ToKey(ProbHist_recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX20'; NumKeys: 7; IDesc: (
    // ProbCode_index
    (KeyL: 8; AllowDupK: FALSE), // Problem_code
    // Problem_index
    (KeyL: 12; AllowDupK: FALSE),
      // Int32ToKey(Problem_probhdr) + Int32ToKey(Problem_sequence) + Int32ToKey(Problem_recno);
    // ProbDesc_index
    (KeyL: 16; AllowDupK: TRUE), // Next_wd(Problem_description)
    // ProbHdr_index
    (KeyL: 30; AllowDupK: TRUE), // UpperCase(ProbHdr_name)
    // ProbUsage_index
    (KeyL: 8; AllowDupK: FALSE),
      // Int32ToKey(Usage_parent) + Int32ToKey(Usage_recno)   (for treatment and diagnostic plan}
    // ProbRule_index
    (KeyL: 8; AllowDupK: FALSE),
      // Int32ToKey(Usage_parent) + Int32ToKey(Usage_recno)   (for rule-outs}
    // ProbTemplate_index
    (KeyL: 10; AllowDupK: TRUE),
      // Int32ToKey(Usage_parent) + WordToKey(Usage_ODCI) + Int32ToKey(Usage_recno)   (for emr template list--use ODCI as sequence no.}

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX21'; NumKeys: 1; IDesc: (
    // Timeclock_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(Timeclock_user) + DescendingKey(WordToKey(Timeclock_in_date) + Int32ToKey(Timeclock_recno), 6);

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX22'; NumKeys: 5; IDesc: (
    // FormTemplate_index
    (KeyL: 12; AllowDupK: FALSE),
      // Int32ToKey(FormTemplate_category) + Int32ToKey(FormTemplate_sequence) + Int32ToKey(FormTemplate_recno)
    // FormTemplateCode_index
    (KeyL: 8; AllowDupK: FALSE), // UpperCase(FormTemplate_code)
    // FormTemplateDesc_index
    (KeyL: 20; AllowDupK: TRUE),
    // FormTemplateVersion_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(_FormTemplate) + DescendingKey(WordToKey(Created), 2) + Int32ToKey(Recno)
    // MedicalForm_index
    (KeyL: 10; AllowDupK: FALSE),
      // Int32ToKey(_Medical) + DescendingKey(WordToKey(Date), 2) + Int32ToKey(Recno)

    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))),

    (Name: 'INDEX23'; NumKeys: 1; IDesc: (
    // OptionValue_index
    (KeyL: 21; AllowDupK: FALSE), // ByteToKey(AccessType) + Int32ToKey(Parent) + GUIDToKey(Option._GUID)
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE),
    (KeyL: 1; AllowDupK: FALSE))));
{$J-}

type
  TAVI_index_locator = record
    AVI_index: TAVImark_indexes;
    Offset: Word;
  end;

const
  ClientName_index: TAVI_index_locator = (AVI_index: aviidxClient; Offset: 1);
  Phone_index: TAVI_index_locator = (AVI_index: aviidxClient; Offset: 2);
  WholePhone_index: TAVI_index_locator = (AVI_index: aviidxClient; Offset: 3);
  ClientSoundex_index: TAVI_index_locator = (AVI_index: aviidxClient; Offset: 4);
  DeletedClient_index: TAVI_index_locator = (AVI_index: aviidxClient; Offset: 5);

  AnimalName_index: TAVI_index_locator = (AVI_index: aviidxAnimal; Offset: 1);
  Rabies_index: TAVI_index_locator = (AVI_index: aviidxAnimal; Offset: 2);
  Animal_index: TAVI_index_locator = (AVI_index: aviidxAnimal; Offset: 3);
  Registration_index: TAVI_index_locator = (AVI_index: aviidxAnimal; Offset: 4);
  Relationship_index: TAVI_index_locator = (AVI_index: aviidxAnimal; Offset: 5);
  Locator_index: TAVI_index_locator = (AVI_index: aviidxAnimal; Offset: 6);

  Whogot_index: TAVI_index_locator = (AVI_index: aviidxService; Offset: 1);
  Service_index: TAVI_index_locator = (AVI_index: aviidxService; Offset: 2);
  ServUsage_index: TAVI_index_locator = (AVI_index: aviidxService; Offset: 3);
  ServMedical_index: TAVI_index_locator = (AVI_index: aviidxService; Offset: 4);

  TreatCode_index: TAVI_index_locator = (AVI_index: aviidxTreatment; Offset: 1);
  TreatDesc_index: TAVI_index_locator = (AVI_index: aviidxTreatment; Offset: 2);
  Treatment_index: TAVI_index_locator = (AVI_index: aviidxTreatment; Offset: 3);
  Header_index: TAVI_index_locator = (AVI_index: aviidxTreatment; Offset: 4);
  TreatUsage_index: TAVI_index_locator = (AVI_index: aviidxTreatment; Offset: 5);
  HeaderCode_index: TAVI_index_locator = (AVI_index: aviidxTreatment; Offset: 6);

  ItemCode_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 1);
  ItemDesc_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 2);
  Item_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 3);
  Category_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 4);
  Vendor_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 5);
  PO_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 6);
  Labels_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 7);
  CategoryCode_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 8);
  Price_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 9);
  ItemUsage_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 10);
  VariCode_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 11);
  VariDate_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 12);
  NeedList_index: TAVI_index_locator = (AVI_index: aviidxInventory; Offset: 13);

  Lists_index: TAVI_index_locator = (AVI_index: aviidxLists; Offset: 1);

  Account_index: TAVI_index_locator = (AVI_index: aviidxAccount; Offset: 1);
  AccountDate_index: TAVI_index_locator = (AVI_index: aviidxAccount; Offset: 2);
  AccountSumm_index: TAVI_index_locator = (AVI_index: aviidxAccount; Offset: 3);
  AccountHeld_index: TAVI_index_locator = (AVI_index: aviidxAccount; Offset: 4);
  AccountType_index: TAVI_index_locator = (AVI_index: aviidxAccount; Offset: 5);

  GroupName_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 1);
  User_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 2);
  UserId_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 3);
  UserPassword_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 4);
  Grant_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 5);
  Resource_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 6);
  ResourceCode_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 7);
  ResourceDesc_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 8);
  GrantWhogot_index: TAVI_index_locator = (AVI_index: aviidxSecurity; Offset: 9);

  Reminder_index: TAVI_index_locator = (AVI_index: aviidxReminder; Offset: 1);
  RemindCode_index: TAVI_index_locator = (AVI_index: aviidxReminder; Offset: 2);
  RemindTreat_index: TAVI_index_locator = (AVI_index: aviidxReminder; Offset: 3);
  RemindItem_index: TAVI_index_locator = (AVI_index: aviidxReminder; Offset: 4);
  RemindDate_index: TAVI_index_locator = (AVI_index: aviidxReminder; Offset: 5);
  RemindSeries_index: TAVI_index_locator = (AVI_index: aviidxReminder; Offset: 6);
  RemindDiag_index: TAVI_index_locator = (AVI_index: aviidxReminder; Offset: 7);

  TableCode_index: TAVI_index_locator = (AVI_index: aviidxTable; Offset: 1);
  Entry_index: TAVI_index_locator = (AVI_index: aviidxTable; Offset: 2);
  EntryCode_index: TAVI_index_locator = (AVI_index: aviidxTable; Offset: 3);
  EntryDesc_index: TAVI_index_locator = (AVI_index: aviidxTable; Offset: 4);
  EntryUsage_index: TAVI_index_locator = (AVI_index: aviidxTable; Offset: 5);

  DiagCode_index: TAVI_index_locator = (AVI_index: aviidxDiagnosis; Offset: 1);
  Diagnosis_index: TAVI_index_locator = (AVI_index: aviidxDiagnosis; Offset: 2);
  DiagDesc_index: TAVI_index_locator = (AVI_index: aviidxDiagnosis; Offset: 3);
  Diaghdr_index: TAVI_index_locator = (AVI_index: aviidxDiagnosis; Offset: 4);
  DiagUsage_index: TAVI_index_locator = (AVI_index: aviidxDiagnosis; Offset: 5);

  Estimate_index: TAVI_index_locator = (AVI_index: aviidxEstimate; Offset: 1);
  Task_index: TAVI_index_locator = (AVI_index: aviidxEstimate; Offset: 2);
  Quote_index: TAVI_index_locator = (AVI_index: aviidxEstimate; Offset: 3);
  Quotail_index: TAVI_index_locator = (AVI_index: aviidxEstimate; Offset: 4);

  Appoint_index: TAVI_index_locator = (AVI_index: aviidxAppoint; Offset: 1);
  ApptParent_index: TAVI_index_locator = (AVI_index: aviidxAppoint; Offset: 2);
  BlockOff_index: TAVI_index_locator = (AVI_index: aviidxAppoint; Offset: 3);
  AppointDr_index: TAVI_index_locator = (AVI_index: aviidxAppoint; Offset: 4);

  FollowAnimal_index: TAVI_index_locator = (AVI_index: aviidxFollow; Offset: 1);
  FollowDate_index: TAVI_index_locator = (AVI_index: aviidxFollow; Offset: 2);

  Split_index: TAVI_index_locator = (AVI_index: aviidxSplit; Offset: 1);

  Facility_index: TAVI_index_locator = (AVI_index: aviidxBoard; Offset: 1);
  Board_index: TAVI_index_locator = (AVI_index: aviidxBoard; Offset: 2);
  Activity_index: TAVI_index_locator = (AVI_index: aviidxBoard; Offset: 3);
  Census_index: TAVI_index_locator = (AVI_index: aviidxBoard; Offset: 4);
  BoardAnimal_index: TAVI_index_locator = (AVI_index: aviidxBoard; Offset: 5);
  FacHdr_index: TAVI_index_locator = (AVI_index: aviidxBoard; Offset: 6);
  eTravel_index: TAVI_index_locator = (AVI_index: aviidxBoard; Offset: 7);

  Model_index: TAVI_index_locator = (AVI_index: aviidxMore; Offset: 1);
  Normals_index: TAVI_index_locator = (AVI_index: aviidxMore; Offset: 2);
  ResultsStr_index: TAVI_index_locator = (AVI_index: aviidxMore; Offset: 3);

  QAHdr_index: TAVI_index_locator = (AVI_index: aviidxQA; Offset: 1);
  QA_index: TAVI_index_locator = (AVI_index: aviidxQA; Offset: 2);
  QADesc_index: TAVI_index_locator = (AVI_index: aviidxQA; Offset: 3);
  QACode_index: TAVI_index_locator = (AVI_index: aviidxQA; Offset: 4);

  ProbHist_index: TAVI_index_locator = (AVI_index: aviidxProbHist; Offset: 1);
  ProbWhogot_index: TAVI_index_locator = (AVI_index: aviidxProbHist; Offset: 2);

  ProbCode_index: TAVI_index_locator = (AVI_index: aviidxProblem; Offset: 1);
  Problem_index: TAVI_index_locator = (AVI_index: aviidxProblem; Offset: 2);
  ProbDesc_index: TAVI_index_locator = (AVI_index: aviidxProblem; Offset: 3);
  ProbHdr_index: TAVI_index_locator = (AVI_index: aviidxProblem; Offset: 4);
  ProbUsage_index: TAVI_index_locator = (AVI_index: aviidxProblem; Offset: 5);
  ProbRule_index: TAVI_index_locator = (AVI_index: aviidxProblem; Offset: 6);
  ProbTemplate_index: TAVI_index_locator = (AVI_index: aviidxProblem; Offset: 7);

  Timeclock_index: TAVI_index_locator = (AVI_index: aviidxTimeclock; Offset: 1);

  FormTemplate_index: TAVI_index_locator = (AVI_index: aviidxFormTemplate; Offset: 1);
  FormTemplateCode_index: TAVI_index_locator = (AVI_index: aviidxFormTemplate; Offset: 2);
  FormTemplateDesc_index: TAVI_index_locator = (AVI_index: aviidxFormTemplate; Offset: 3);
  FormTemplateVersion_index: TAVI_index_locator = (AVI_index: aviidxFormTemplate; Offset: 4);
  MedicalForm_index: TAVI_index_locator = (AVI_index: aviidxFormTemplate; Offset: 5);

  OptionValue_index: TAVI_index_locator = (AVI_index: aviidxOptionValue; Offset: 1);

//{$endif}
const
  { Service transaction types }
  Trans_treatment = 'S';
  Trans_item = 'I';
  Trans_diagnosis = 'D';
  Trans_taxed_item = 'X';
  Trans_taxed_treatment = 'T';
  Trans_notes = 'N';
  Trans_visit = 'V';
  Trans_journal = 'J';
  Trans_services = 'SIDXT';
  Trans_treatments = 'ST';
  Trans_items = 'IX';
  Trans_postable = 'STIXOD';
  Trans_chargeable = 'STIX';

  { Account transaction types }
  Trans_invoice = 'I';
  Trans_balance = 'B';
  Trans_cash = 'C';
  Trans_check = 'P';
  Trans_visa = 'V';
  Trans_mastercard = 'M';
  Trans_discover = 'D';
  Trans_amex = 'E';
  Trans_other = 'O';
  Trans_adjustment = 'A';
  Trans_taxed = 'T';
  Trans_nontaxed = 'S';
  Trans_late_fee = 'L';
  Trans_held_check = 'H';
  Trans_writeoff = 'W';
  Trans_diagtrans = 'X';
  Trans_notation = 'N';

  Trans_detail = 'TSX';
  Trans_charges = 'TSALX';

{$J+}
  Trans_credit_cards: string[15] = 'VMDEO';
  Trans_cashes: string[12] = 'PC';
  Trans_payments: string[18] = 'PCVMDEOH';

  Trans_types: string[27] = ' LTSXIBNPCVMDEOAH';
  Trans_descriptions: array[1..27] of string[30] = ('(unknown)',
{$J-}
    'Late fee',
    'Taxable item/service',
    'Non-taxable item/service',
    'Diagnosis',
    'Invoice',
    'Balance brought forward',
    '(Notation)',
{$IFDEF SouthAfrica}
    'Cheque payment',
{$ELSE}
    'Check payment',
{$ENDIF}
    'Cash payment',
    'Visa payment',
    'Mastercard payment',
    'Discover payment',
    'American express payment',
    'Other credit card payment',
    'Account adjustment',
{$IFDEF SouthAfrica}
    'Held cheque payment',
{$ELSE}
    'Held check payment',
{$ENDIF}
    '', '', '', '', '', '', '', '', '', '');

implementation

end.
