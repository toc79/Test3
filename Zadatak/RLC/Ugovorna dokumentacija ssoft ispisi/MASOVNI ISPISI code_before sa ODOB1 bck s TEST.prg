LOCAL LcList_condition, lcList
LcList_condition = ""  && Mora biti 
lcList = GF_CreateDelimitedList("pogodba", "id_cont", LcList_condition, ",") &&SA NAVODNICIMA provjereno na primjeru i u kodu
GF_SQLEXEC("SELECT id_cont, id_odobrit FROM dbo.pogodba WHERE id_cont in ("+iif(len(allt(lcList))=0,"0",lcList)+")", "_cb_id_odobrit")

local lcSelect, lnDone

sele pogodba
if reccount() <= 0 then
	return .f.
endif


text to lcSelect
	Select rtrim(rep_key) as report_name, '-1' as id_key, cast(1 as int) as num_copy, rep_name as report_title, cast(1 as bit) as is_selected, 'Pdf' as rep_format
	From print_selection
	where ID_SELECTION in (616, 585, 628, 630, 636) --UPISATI KOJE ISPISE ŽELE --ponuda je 569 537,
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

Select a.*, allt(trans(IIF(report_name == "PONUDBA_SSOFT_RLC", allt(b.id_pon) + ";0", IIF(report_name == "ODOB1_SSOFT_RLC", NVL(c.id_odobrit, 0), b.id_cont)))) as rep_key, b.id_pog From _cb_selected_reports a left join pogodba b on 1 = 1 LEFT JOIN _cb_id_odobrit c ON b.id_cont = c.id_cont ORDER BY b.id_cont, a.report_name into cursor _cb_for_print

sele _cb_for_print
go top

scan
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat(allt(_cb_for_print.report_name), allt(_cb_for_print.rep_key), _cb_for_print.num_copy, LEFT(allt(_cb_for_print.report_title),20) + " " + allt(_cb_for_print.id_pog), allt(_cb_for_print.rep_format))
endscan

OBJ_ReportSelector.SkipPreview = .F.
OBJ_ReportSelector.PRAskForCopies = .T.