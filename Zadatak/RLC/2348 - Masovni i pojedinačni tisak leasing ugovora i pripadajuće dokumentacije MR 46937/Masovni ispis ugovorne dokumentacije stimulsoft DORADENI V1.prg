* 14.12.2018 g_tomislav MID 41455; added transform in format "9999999999", this is needed when cursor is created with syntax "INTO CURSOR" so field can have fixed and sufficient length ( otherwise field length is set considering first record and that can lead to information loss, if field length of other records is at least one character larger then first record). PONUDBA_SSOFT_RLC in not listed above so it is unnecessary   
* 04.05.2017 g_tomislav MID 37977 (RLC 1707) - isključivanje određenih ispisa
* 14.01.2019 g_barbarak MID 43901 (RLC 2089) - isključivanje DOD_POG_SSOFT_RLC
* 24.02.2020 g_tkovacev	MID 43354 (RLC 2051) - iz delete-a maknut POG_SSOFT_RLC" AND RF_TIP_POG(nacin_leas) != "OL", sada se ispisuju svi tipovi leasinga
* 01.07.2021 g_tomislav MID 46937 (RLC 2348) - dodavanje ispisa PLANP_SSOFT_RLC

LOCAL LcList_condition, lcList
LcList_condition = ""  && Mora biti 
lcList = GF_CreateDelimitedList("pogodba", "id_cont", LcList_condition, ",") &&SA NAVODNICIMA provjereno na primjeru i u kodu
GF_SQLEXEC("SELECT id_cont, id_odobrit FROM dbo.pogodba WHERE id_cont in ("+iif(len(allt(lcList))=0,"0",lcList)+")", "_cb_id_odobrit")

GF_SQLEXEC("SELECT distinct id_cont as id_cont FROM dbo.gv_DodStrPogodba WHERE grupa_stroska = 'DOD' AND id_cont in ("+iif(len(allt(lcList))=0,"0",lcList)+")", "_cb_dod_tro")

local lcSelect, lnDone

sele pogodba
if reccount() <= 0 then
	return .f.
endif


text to lcSelect noshow
	Select rtrim(rep_key) as report_name, '-1' as id_key, cast(1 as int) as num_copy, rep_name as report_title, cast(1 as bit) as is_selected, 'Pdf' as rep_format
	From print_selection
	--UPISATI KOJE ISPISE ŽELE --ponuda je 569
	where ID_SELECTION in (	616, --POG_SSOFT_RLC - Ugovor - Stimulsoft
							585, --NAL_PL_SSOFT_RLC - NALOG ZA PLAĆANJE  
							617, --ZAP_REG_NER_SSOFT_RLC - PRIMOPREDAJNI ZAPISNIK stimulsof
							618, --POOB_REG_SSOFT_RLC - OVLAŠTENJE ZA REGISTRIRANJE VOZILA  stimulsoft
							623, --ODOB1_SSOFT_RLC - Odobrenje Financiranja Stimulsoft
							655, --DOD_POG_SSOFT_RLC - DODATAK UGOVOR - Stimulsoft 
							663, --PUN_COC_SSOFT_RLC Punomoć za preuzimanje COC dokumenta - Word
							658  --PLANP_SSOFT_RLC  PLAN OTPLATE - Stimulsoft  
							) 
endtext

GF_SQLEXEC(lcSelect,"reports")

lnDone = GF_DO_FORM("print_copies_select", null,null,.t.)

if ! lnDone then
	if used('reports') then
		use in reports
	endif
	
	return .f.
endif
	

** zadnji označen zapis ne uvažava pa su potrebne sljedeće 3 linije
SELECT reports 
SCAN FOR is_selected = .t.
ENDSCAN

Select * from reports where is_selected = .t. and num_copy > 0 into cursor _cb_selected_reports

if used('reports') then
	use in reports
endif

sele _cb_selected_reports
if reccount() <= 0 then
	return .f.
endif

Select a.*, IIF(report_name == "PONUDBA_SSOFT_RLC", allt(b.id_pon) + ";0", ALLT(TRANS(IIF(report_name == "ODOB1_SSOFT_RLC", NVL(c.id_odobrit, 0), b.id_cont), "9999999999"))) as rep_key, b.id_pog, b.nacin_leas, b.id_vrste, b.id_cont From _cb_selected_reports a left join pogodba b on 1 = 1 LEFT JOIN _cb_id_odobrit c ON b.id_cont = c.id_cont ORDER BY b.id_cont, a.report_name into cursor _cb_for_print READWRITE


DELETE FROM _cb_for_print WHERE report_name == "ODOB1_SSOFT_RLC" AND rep_key == "0"
DELETE FROM _cb_for_print WHERE report_name == "POOB_REG_SSOFT_RLC" AND GF_LOOKUP("vrst_opr.se_regis", pogodba.id_vrste, "vrst_opr.id_vrste") != "*"
DELETE FROM _cb_for_print WHERE report_name == "ZAP_REG_NER_SSOFT_RLC" AND GF_LOOKUP("vrst_opr.se_regis", pogodba.id_vrste, "vrst_opr.id_vrste") != "*"
DELETE FROM _cb_for_print WHERE report_name == "DOD_POG_SSOFT_RLC" AND (RF_TIP_POG(nacin_leas) != "OL" OR id_cont not in (Select id_cont from _cb_dod_tro))
DELETE FROM _cb_for_print WHERE report_name == "PUN_COC_SSOFT_RLC" AND GF_LOOKUP("vrst_opr.se_regis", pogodba.id_vrste, "vrst_opr.id_vrste") != "*"
DELETE FROM _cb_for_print WHERE report_name == "PLANP_SSOFT_RLC" AND RF_TIP_POG(nacin_leas) != "F1"

sele _cb_for_print
go top

scan
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat(allt(_cb_for_print.report_name), allt(_cb_for_print.rep_key), _cb_for_print.num_copy, LEFT(allt(_cb_for_print.report_title),20) + " " + allt(_cb_for_print.id_pog), allt(_cb_for_print.rep_format))
endscan

OBJ_ReportSelector.SkipPreview = .F.
OBJ_ReportSelector.PRAskForCopies = .T.