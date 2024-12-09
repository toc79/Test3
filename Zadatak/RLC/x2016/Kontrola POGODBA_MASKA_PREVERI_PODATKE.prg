***********************************************************************************
***Popravak općih uvjeta prije provjere RLC prijava 1038 **************************
***********************************************************************************
local lcVr_osebe, lcNacin_leas

lcNacin_leas = RF_TIP_POG(pogodba.nacin_leas)
lcVr_osebe = GF_LOOKUP("partner.vr_osebe",pogodba.id_kupca,"partner.id_kupca")

if (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcNacin_leas = 'F1'
	if pogodba.spl_pog != 'F0216' then
		REPLACE pogodba.spl_pog WITH 'F0216' IN pogodba 
	endif
else
	if pogodba.spl_pog != '0216' and pogodba.nacin_leas != 'OP' then
		REPLACE pogodba.spl_pog WITH '0216' IN pogodba 
	endif
endif
***********************************************************************************
*** provjera općih uvjeta MID 20434, kada se mjenjaju opći uvjeti treba zamijeniti i default values
local lcPogoj1
if used('_partner_list') then
	return
endif

TEXT TO lcPogoj1 NOSHOW
	select * from partner p
		where p.id_kupca = '{0}'
ENDTEXT
lcPogoj1 = STRTRAN(lcPogoj1, '{0}', pogodba.id_kupca)
gf_sqlexec(lcPogoj1,"_partner_list")
if ((_partner_list.vr_osebe  == 'FO' or _partner_list.vr_osebe == 'F1') and pogodba.nacin_leas == 'F1') 
	if pogodba.spl_pog !='F0216'
		if !potrjeno('Nije unešena odgovarajuća vrijednost općih uvjeta! Za tip financiranja F1 i fizičke osobe opći uvjeti trebaju biti F0216, a za sve druge 0216. Želite li spremiti takav ugovor?')
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
			if used("_partner_list")
				use in _partner_list
			endif
		endif
	endif
else
	if pogodba.spl_pog !='0216'
		if !potrjeno('Nije unešena odgovarajuća vrijednost općih uvjeta! Za tip financiranja F1 i fizičke osobe opći uvjeti trebaju biti F0216, a za sve druge 0216. Želite li spremiti takav ugovor?')
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
			if used("_partner_list")
				use in _partner_list
			endif
		endif
	endif
endif
***********************************************************************************
***PROVJERA UNOSA POREZ U MPC U ODNOSU NA STOPU POREZA U MPC NA PONUDI*************
***********************************************************************************
LOCAL loForm, lcPogoj

lcPogoj = ""
loForm = NULL


FOR lnI = 1 TO _Screen.FormCount
	IF UPPER(_Screen.Forms(lnI).Name) == UPPER("frmPOGODBA_MASKA") THEN
	loForm = _Screen.Forms(lnI)
EXIT
ENDIF
NEXT

IF ISNULL(loForm) THEN
	RETURN
ENDIF

if used('_ponudba_list') then
	return
endif

TEXT TO lcPogoj NOSHOW
	select * from ponudba pon
		where pon.id_pon = '{0}'
ENDTEXT
lcPogoj = STRTRAN(lcPogoj, '{0}', pogodba.id_pon)

gf_sqlexec(lcPogoj,"_ponudba_list")
&&select _test
&&brow

if len(alltrim(_ponudba_list.id_pon))>0 and pogodba.id_dav_op!=_ponudba_list.id_dav_op
	if !potrjeno('Porez u MPC na ugovoru drugačiji od Poreza u MPC unešenog na ponudi. Želite li spremiti takav ugovor?')
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		if used("_ponudba_list")
			use in _ponudba_list
		endif
	endif
endif
*********************************************************** 
TEXT TO lcSQL NOSHOW 
Select a.dat_nasl_vred 
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
AND a.id_kupca = 
ENDTEXT 

ldDatEvalZ = GF_SQLExecScalarNull(lcSQL + GF_QuotedStr(pogodba.id_kupca)) 

IF GF_NULLOREMPTY(ldDatEvalZ) THEN 
POZOR ('Odabrani partner nema važeće ZSPNFT vrednovanje.'+chr(13)+'Ugovor nije spremljen!') 
REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
RETURN .F. 
ENDIF 
***********************************************************

** NOVO
*********************************************************** 
* 24.08.2016 g_tomislav - dorada MR 36207
TEXT TO lcSQL NOSHOW 
Select a.dat_nasl_vred 
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
AND a.id_kupca = 
ENDTEXT 

ldDatEvalZ = GF_SQLExecScalarNull(lcSQL + GF_QuotedStr(pogodba.id_kupca)) 

IF !GF_NULLOREMPTY(pogodba.dat_podpisa) AND GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos podatka 'Datum potpisa od strane klijenta' nije dozvoljen zato jer partner nema važeće ZSPNFT vrednovanje."+chr(13)+"Ugovor nije spremljen!") 
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	RETURN .F. 
ENDIF 
***********************************************************

