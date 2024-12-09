**01.07.2021 g_tomislav MID 46937 - created;

TEXT TO lcSql NOSHOW	
	SELECT count(*) as count
	FROM dbo.gv_DodStrPogodba ds 
	JOIN dbo.dokument d on ds.id_cont = d.id_cont
	WHERE ds.grupa_stroska = 'DOD' 
	and d.id_obl_zav in ('DF', 'DB', 'DT')	
	and ds.id_cont = 
ENDTEXT 
GF_SQLEXEC(lcSql +trans(pogodba.id_cont), "_cb_dod_tro")

lnBrojJamaca = RECCOUNT("pog_poro")
lnBrojKopija = IIF(lnBrojJamaca == 0, 3, (lnBrojJamaca + 1) * 3) && Primatelj leasinga + za svakog jamca

OBJ_ReportSelector.SkipPreview = .F.
OBJ_ReportSelector.PRAskForCopies = .T.

OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("NAL_PL_SSOFT_RLC ", TRANS(pogodba.id_cont), 1, "Nalog za plaćanje", "Pdf")

IF !INLIST(pogodba.refinanc, 'EIB', 'HBOR') 
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("POG_SSOFT_RLC", STR(pogodba.id_cont), lnBrojKopija, "Ugovor", "Pdf")
ELSE 
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("POG_EIB_HBOR_SSOFT_RLC", STR(pogodba.id_cont), lnBrojKopija, "Ugovor EIB i HBOR", "Pdf")
ENDIF 

IF RF_TIP_POG(pogodba.nacin_leas) == "F1" 
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("PLANP_SSOFT_RLC", TRANS(pogodba.id_cont), lnBrojKopija, "Plan otplate", "Pdf")
ENDIF 

IF pogodba.vrst_opr_se_regis = "*"
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("ZAP_REG_NER_SSOFT_RLC", TRANS(pogodba.id_cont), 1, "Primopredajni zapisnik", "Pdf")
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("POOB_REG_SSOFT_RLC", TRANS(pogodba.id_cont), 1, "Ovlaštenje za registriranje vozila", "Pdf")
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("PUN_COC_SSOFT_RLC", TRANS(pogodba.id_cont), 1, "Punomoć za preuzimanje COC dokumenta", "Pdf")
ENDIF 

OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("ODOB1_SSOFT_RLC", TRANS(GF_LOOKUP("pogodba.id_odobrit", pogodba.id_cont, "pogodba.id_cont")), 1, "Odobrenje financiranja", "Pdf")

IF RF_TIP_POG(pogodba.nacin_leas) == "OL" AND _cb_dod_tro.count > 0
	OBJ_ReportSelector.AddReportToPrintJobWithTitleAndFormat("DOD_POG_SSOFT_RLC", TRANS(pogodba.id_cont), lnBrojKopija, "Dodatak ugovor", "Pdf")
ENDIF 