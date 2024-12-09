--sp_helptext gv_p_eval
--(1,pog_state)p1 = 38663
--p2 = 16.08.2019
--p3 = '023930'
--select * from dbo.gfn_ContractStateForDashboard(?p1, ?p3, ?p2, 0)
sp_helptext gfn_Nacin_leas_HR
sp_helptext gfn_ContractStateForDashboardFromDS
sp_helptext gv_planp_ds_by_contract
sp_helptext gv_p_eval
sp_helptext gv_PEval_LastEvaluation
sp_helptext gfn_Report_SumContractFromDailySnapshot 
sp_helptext grp_Payment_Detail 
sp_helptext gfn_IsLeapYear

select dbo.gfn_GetCustomSettingsAsBool('Nova.LE.DashboardFromPlanp')

      SELECT *   
        FROM dbo.gfn_ContractStateForDashboardFromDS(@id_cont, @id_kupca, @today, @for_customer)  

Diana,
šaljem odgovore - PLAVO  prema Gemicru na postavljena pitanja vezano za izradu Izvještaj_Repossessed asset  pa vas molim da im isto proslijedite.

1) za kreiranje izvještaja u kojemu će za jedan ugovor biti jedan zapis/redak, podatke s dokumenta RU, RA, RE i KL bi uzeli sa zadnjeg unesenog, s obzirom da postoji mogućnost da za ugovor postoji više takvih dokumenata. Da li je to u redu? To je uredu - podaci se uzimaju sa zadnjeg AKTIVNOG dokumenta.

2) oko podatka u polju:
a) "Model evaluacije" - podatak kao u dodatnoj rutini "Dodavanje kolone Coconut, model eval i CRS status"? Može kroz dodatne rutine
b) "Risk izloženost" -  podatak kao u dodatnoj rutini "Dodavanje kolone Risk izloženost, Proknj. nedosp. ostali troškovi"? Može kroz dodatne rutine
c) "Grupa" - iz šifranta vrsta opreme? Da - podatke preuzeti iz šifranata
d) "Datum dokumenta tj. zadnje rate/zadnjeg potraživanja" - to može biti potraživanje npr. ZATEZNE KAMATE, onda se treba prikazati datum dokumenta tog potraživanja (ili npr. treba to biti za OL otkup/rata, a za FL datum zadnjeg potraživanja "21 RATA/OBROK")? U izvještaju treba biti prikazan datum zadnje rate i kod OJ i FL leasinga, a ne datum eventualnih potraživanja nastalih nakon zadnje rate

3) Da li za izvještaj podesiti GDPR logiranje? Ne - ovaj izvještaj će se koristiti u interne svrhe

Hvala i pozdrav,
Marija



--Model evaluacije
Dodavanje kolone Coconut, model eval i CRS status               
GF_SQLEXEC("SELECT ID_KUPCA, MAX(DAT_EVAL) AS DAT_EVAL FROM gv_p_eval GROUP BY ID_KUPCA","T1")
GF_SQLEXEC("SELECT ID_KUPCA, DAT_EVAL, EVAL_MODEL FROM gv_p_eval ORDER BY ID_KUPCA","T2")
GF_SQLEXEC("SELECT ID_KUPCA, EXT_ID FROM PARTNER ORDER BY ID_KUPCA","T3")
GF_SQLEXEC("select a.id_kupca, a.oall_ratin, b.dat_eval from p_eval a inner join (SELECT ID_KUPCA, MAX(DAT_EVAL) AS DAT_EVAL FROM p_eval WHERE eval_type='C'group by id_kupca) b on a. id_kupca = b.id_kupca and a.eval_type = 'C' and a.dat_eval = b.dat_eval","T4")

	SELECT A.ID_KUPCA, B.DAT_EVAL, D.EVAL_MODEL ;
	FROM PPIZBOR A ;
	LEFT JOIN T1 B ON A.ID_KUPCA = B.ID_KUPCA ;
	LEFT JOIN T2 D ON (A.ID_KUPCA = D.ID_KUPCA AND B.DAT_EVAL = D.DAT_EVAL) ;
	GROUP BY A.ID_KUPCA, B.DAT_EVAL, D.EVAL_MODEL ;
	INTO CURSOR REZ
		
	USE IN T1
	USE IN T2
	
GF_AddColumnsToGrid("frmPP_IZBOR_DS", "BGridResult", "Model evaluacije", "LOOKUP(REZ.EVAL_MODEL, PPIZBOR.ID_KUPCA,REZ.ID_KUPCA)", 150 , "")

GF_AddColumnsToGrid("frmPP_IZBOR_DS", "BGridResult", "Datum zadnje ev.", "LOOKUP(REZ.DAT_EVAL, PPIZBOR.ID_KUPCA,REZ.ID_KUPCA)", 190 , "")

GF_AddColumnsToGrid("frmPP_IZBOR_DS", "BGridResult", "Coconut", "LOOKUP(T3.EXT_ID, PPIZBOR.ID_KUPCA,T3.ID_KUPCA)", 120 , "")
GF_AddColumnsToGrid("frmPP_IZBOR_DS", "BGridResult", "CRS status", "LOOKUP(T4.OALL_RATIN, PPIZBOR.ID_KUPCA,T4.ID_KUPCA)", 120 , "")




Dodavanje kolone Risk izloženost, Proknj. nedosp. ostali troškovi
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

http://gmcv03/support/maintenance.aspx?Mode=Read&Source=3&Document=33436&ID=33436&ShowAll=True
Formula za UKUPNO(SKUPAJ) u gfn_Report_SumContractFromDailySnapshot je sada 
Skupaj = Saldo + Se_neto + Se_fin_davek, 