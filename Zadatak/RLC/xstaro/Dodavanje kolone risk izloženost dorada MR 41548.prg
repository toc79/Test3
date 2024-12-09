* 27.06.2016. g_tomislav - MR 33436
* 07.12.2018. g_tomislav - MR 41548; added new column POKNJ_NEZAP_OST

lcPar_tecajnica_datumtec = GF_PCDDESC('_PCDPARAMETER','PARNAME','PARCONT','DATUMTEC','TECAJ','PARVALUE','C')
lcPar_tecajnica_tecajnica = GF_PCDDESC('_PCDPARAMETER','PARNAME','PARCONT','TECAJNICA','TECAJ','PARVALUE','C')

*OSTALO: budući neto i PPMV se već nalazi u SKUPAJ tj. u budućoj glavnici
TEXT TO lcSql NOSHOW
SELECT id_cont
	, SUM(dbo.gfn_Xchange({0}, poknj_nezap_debit_brut_all - poknj_nezap_neto_LPOD - poknj_nezap_robresti_LPOD, id_tec, {1})) as OSTALO 
	, SUM(dbo.gfn_Xchange({0}, poknj_nezap_ost, id_tec, {1})) as poknj_nezap_ost 
FROM dbo.planp_ds 
GROUP BY id_cont
ENDTEXT

lcSql = STRTRAN(lcSql, "{0}", GF_Quotedstr(lcPar_tecajnica_tecajnica)) 
lcSql = STRTRAN(lcSql, "{1}", GF_Quotedstr(lcPar_tecajnica_datumtec)) 

GF_SQLEXEC(lcSql,"_dr_planp_ds")

GF_AddColumnsToGrid("frmPP_IZBOR_DS", "BGridResult", "Risk izloženost", "PPIzbor.SKUPAJ + LOOKUP(_dr_planp_ds.OSTALO, PPIzbor.ID_CONT, _dr_planp_ds.ID_CONT)" , 150, "999,999,999,999.99")

GF_AddColumnsToGrid("frmPP_IZBOR_DS", "BGridResult", "Proknj. nedosp. ostali troškovi", "LOOKUP(_dr_planp_ds.poknj_nezap_ost, PPIzbor.ID_CONT, _dr_planp_ds.ID_CONT)" , 150, "999,999,999,999.99")