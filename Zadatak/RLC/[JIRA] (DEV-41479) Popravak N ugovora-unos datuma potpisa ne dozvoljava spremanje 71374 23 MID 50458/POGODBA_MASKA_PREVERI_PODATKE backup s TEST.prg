local loForm, lcSQL, lcSQL1, lcSQL2

loForm = GF_GetFormObject("frmPOGODBA_MASKA") 
lcStariAlias = ALIAS()

*********************************************************** 
* 24.08.2016 g_tomislav - dorada MR 36207
* procedura mora biti na vrhu zato jer RETURN od nižih provjera prekida izvršenje donjih dijelova koda u slučaju da se dva puta klikne na save. To bi trebalo popraviti.
* 02.10.2020 g_tomislav MR 45561 (MR 45222) - reorganizacija kontrola zbog greške uzrokovane korištenjem varijable lcSQL2 u kontroli za Rind_strategije. Ovim popravkom bi trebao biti riješeni slučajevi navedeno u rečenici iznad
TEXT TO lcSQL NOSHOW 
Select a.dat_nasl_vred
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
AND a.id_kupca = 
ENDTEXT 

TEXT TO lcSQL1 NOSHOW 
Select CAST(count(*) as bit) as ima
From dbo.ss_dogodek
where id_tip_dog = '08' and ID_KUPCA ={0} 
ENDTEXT 

**and ID_CONT = {1}

TEXT TO lcSQL2 NOSHOW 
Select a.ext_id, a.dat_eval, a.dat_nasl_vred, cast('20170425' as datetime) as limit_date
From dbo.gv_PEval_LastEvaluation_ByType a 
Where a.eval_type = 'Z' 
AND a.id_kupca = {0} 
AND dbo.gfn_GetDatePart(a.dat_nasl_vred) > GETDATE() 
ENDTEXT 

ldDatEvalZ = GF_SQLExecScalarNull(lcSQL + GF_QuotedStr(pogodba.id_kupca)) 

IF loForm.tip_vnosne_maske # 1 AND !GF_NULLOREMPTY(pogodba.dat_podpisa) AND GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos podatka 'Datum potpisa od strane klijenta' nije dozvoljen zato jer partner nema važeae ZSPNFT vrednovanje."+chr(13)+"Potrebno dodjeliti ocjenu rizika klijenta!") 
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	IF !EMPTY(lcStariAlias) THEN
	 SELECT (lcStariAlias)
	ENDIF
	RETURN .F. 
ENDIF 

IF loForm.tip_vnosne_maske = 1 AND GF_NULLOREMPTY(ldDatEvalZ) THEN 
	POZOR ("Unos ugovora nije moguć zato jer partner nema važeće ZSPNFT vrednovanje."+chr(13)+"Potrebno dodjeliti ocjenu rizika klijenta!") 
	SELECT cur_extfunc_error
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	IF !EMPTY(lcStariAlias) THEN
	 SELECT (lcStariAlias)
	ENDIF

	RETURN .F. 
ENDIF 

****SLIJEDEĆA PROVJERA UVIJEK MORA BITI ZADNJA************************************
* 06.09.2019 g_tkovacev MR 43084 - uklanjanje upita u slučaju da partner na ugovoru nema unešen događaj, sada se samo zabrani spremanje ugovora u slučaju da ju nema
* 02.10.2020 g_tomislav MR 45561 (MR 45222) - reorganizacija kontrola zbog greške uzrokovane korištenjem varijable lcSQL2 u kontroli za Rind_strategije. Vratio sam ovaj dio koda gdje pripada (do sada je bio na dnu ispod * KRAJ Rind strategije)

**IF loForm.tip_vnosne_maske # 1 then
	lcdat_podpisa = pogodba.dat_podpisa
	lcdat_podpisa1 = _pogodba.dat_podpisa
	lcSQL2 = strtran(lcSQL2, "{0}", gf_quotedstr(pogodba.id_kupca))
	GF_SQLEXEC(lcSQL2, "_pe")

	IF ((gf_nullorempty(lcdat_podpisa1) and !gf_nullorempty(lcdat_podpisa)) or (lcdat_podpisa1 # lcdat_podpisa)) and _pe.dat_eval >= _pe.limit_date then

		lcSQL1 = strtran(lcSQL1, "{0}", gf_quotedstr(pogodba.id_kupca))
		**lcSQL1 = strtran(lcSQL1, "{1}", allt(trans(pogodba.id_cont)))
		llima = GF_SQLExecScalarNull(lcSQL1) 
		if llima = .f. then
			POZOR("Unos ugovora nije moguć dok se ne unese događaj 'Orginali -Izjava i Identifikacijska isprava'")
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
			IF !EMPTY(lcStariAlias) THEN
			 SELECT (lcStariAlias)
			ENDIF

			RETURN .F. 
		endif
	endif
**endif

IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF
************************** KRAJ PROVJERE *****************************************
***********************************************************

*//////////////////////////////////////////////////////////
** 07.11.2018. g_tomislav MR 40602
** 10.11.2022 g_vuradin MR 49836 micanje uvjeta za kasko
LOCAL lcSifraVr_osebe
lcSifraVr_osebe = NVL(GF_SQLExecScalarNull("SELECT b.sifra FROM dbo.partner a INNER JOIN dbo.vrst_ose b ON a.vr_osebe = b.vr_osebe WHERE a.id_kupca = "+GF_QuotedStr(pogodba.id_kupca)), "")
lc_grp_opr=NVL(GF_SQLExecScalarNull("select id_grupe	 from dbo.pogodba pog	 inner join dbo.vrst_opr vrs on vrs.id_vrste=pog.id_vrste where id_cont="+GF_QuotedStr(pogodba.id_cont)), "")
IF INLIST(pogodba.nacin_leas, "F1", "F2", "F3", "F4") AND lcSifraVr_osebe == "FO"
	
	
	SELECT * FROM str_dobr WHERE strosek > 0 AND id_stroska IN ('IK') INTO CURSOR _ef_pon_terj_stros_IK 
        SELECT * FROM str_dobr WHERE strosek > 0 AND id_stroska IN ('KO') INTO CURSOR _ef_pon_terj_stros_KO 

	IF  RECCOUNT("_ef_pon_terj_stros_IK") == 0
		POZOR("Za fizičku osobu za ugovore tipa F1, F2, F3 i F4 je obavezno unijeti troškove IK Interkalarna kamata!")
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		IF !EMPTY(lcStariAlias) THEN
			SELECT (lcStariAlias)
		ENDIF
	ENDIF

	IF  RECCOUNT("_ef_pon_terj_stros_KO") == 0 and lc_grp_opr=="VBO"
		POZOR("Za fizičku osobu za ugovore tipa F1, F2, F3 i F4 i opremu VBO obavezno je unijeti troškove kaska!")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error 
	ENDIF
	
	IF USED ("_ef_pon_terj_stros_KO")
		USE IN _ef_pon_terj_stros_KO
	ENDIF
	IF USED ("_ef_pon_terj_stros_IK")
		USE IN _ef_pon_terj_stros_IK
	ENDIF
ENDIF
IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF
*//////////////////////////////////////////////////////////

*//////////////////////////////////////////////////////////
** 16.01.2019. g_tomislav MR 40602 - check for marginal amount of EKS; logic was taken from source and modified for client
** 21.03.2022. g_tomislav MID 50458 - dodan lcStariAlias i return .f.

IF nacini_l.tip_knjizenja == "2" AND !nacini_l.ol_na_nacin_fl
	loForm.calc_eom(.T.)
	loForm.check_eom_limit
select * from EOM_meja
	IF EOM_meja.exceeded 
		LOCAL lcStr, lctxt, lctxt1, lcEOM_meja_txt, lnEOMMeja
		lnEOMMeja = EOM_meja.meja
		lctxt = "Efektivna kamatna stopa je viša od zakonski propisane" && caption	
		lcEOM_meja_txt= lctxt + SPACE(1) + TRANSFORM(lnEOMMeja)  + " %!" + gcE 	
		lctxt1 = "Ugovor se ne može spremiti." && caption
		lcStr = lcEOM_meja_txt + lctxt1 
		POZOR(lcStr)
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		IF !EMPTY(lcStariAlias) THEN
			SELECT (lcStariAlias)
		ENDIF
		RETURN .F.
	ENDIF
ENDIF
*//////////////////////////////////////////////////////////


***********************************************************************************
*** Popravak općih uvjeta prije provjere RLC prijava 1038 *************************
*** provjera općih uvjeta MID 20434, kada se mjenjaju opći uvjeti treba zamijeniti i POGODBA_SET_default_values
* 15.03.2017 g_tomislav - dorada Opći uvjeti MR 37651 
* 30.03.2021 g_vuradin - dorada Opći uvjeti MR 46220
***********************************************************************************
local   lcuvjeti

TEXT TO lcSQL46180 NOSHOW

declare @dat_sklen date 
set @dat_sklen = {4}

select 
--pon.id_kupca,pon.refinanc,pon.nacin_leas,pon.dat_sklen,part.vr_osebe,
  case when  pon.refinanc = 'EIB' then  (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='EIB' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104) order by val_datetime desc) 
   when  pon.refinanc= 'HBOR' then  (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='HBOR' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104) order by val_datetime desc)
   when  ((part.vr_osebe in ('FO','F1') or (pon.id_kupca=''  and pon.je_foseba = 1)) and pon.nacin_leas='F1') then  (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='F1FO' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104)  order by val_datetime desc)
   when  ((part.vr_osebe not in ('FO','F1') or (pon.id_kupca='' and pon.je_foseba = 0)) and pon.nacin_leas='F1') then  (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='F1PO' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104)  order by val_datetime desc)
	else (SELECT top 1  cast(value as varchar(100)) FROM dbo.general_register where neaktiven = 0 and val_char='OLFOPO' and ID_REGISTER='RLC_OPCI_UVJETI' and val_datetime<=convert(date,{4},104)  order by val_datetime desc)
                                         end  as uvjeti
 from dbo.PONUDBA pon
 left join dbo.PARTNER part on pon.id_kupca=part.id_kupca
 where pon.id_pon ={0}
  ENDTEXT

lcSQL46180 = STRTRAN(lcSQL46180, '{0}', gf_quotedstr(ponudba.ID_PON))
lcSQL46180 = STRTRAN(lcSQL46180, '{4}', gf_quotedstr(pogodba.DAT_SKLEN))
lcuvjeti= GF_SQLEXECSCALAR(lcSQL46180)

IF !GF_NULLOREMPTY(lcuvjeti)
	REPLACE pogodba.spl_pog WITH lcuvjeti  
ELSE
obvesti("Nema defiranih uvjeta!")
ENDIF

* KRAJ OPĆI UVJETI
************************** KRAJ PROVJERE *****************************************

***********************************************************************************
*S promjenom kontrole na ovom mjestu, potrebno je promijeniti POGODBA_MASKA_SET_DEF_VALUES, POGODBA_UPDATE_PREVERI_PODATKE te provjeriti i POGODBA_MASKA_AFTER_INIT
* 14.06.2017 g_tomislav MR 36135 - Rind strategije
* 25.06.2020 g_tomislav MID 44956 - bugfix;
* 01.10.2020 g_tomislav MID 45222 - nova strategija zadnji radni dan u mjesecu
* 21.10.2020 g_tomislav	MID 45655 - bugfix: zamijenjena varijabla ldZadnjiRadniDanZaRazdoblje s ldTarget_date pa je sada izraz ldNoviDan < ldTarget_date
* 27.07.2021 g_tomislav MID 47073 - bugfix: umjesto day('{0}') je podešeno 1 (za izračun zadnjeg radnog rada u mjesecu nije bitno koji je dan u mjesecu)
***********************************************************************************
llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, pogodba.id_rtip, rtip.id_rtip)

IF llfix_dat_rpg 
	LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnDanUMjesecu, lnId_rind_strategije, ldNoviDan, ldRind_dat_next
	lcid_kupca = pogodba.id_kupca
	lcTip_leas = RF_TIP_POG(pogodba.nacin_leas)
	lnObdobje_mes = 12/LOOKUP(obdobja_lookup.obnaleto, GF_LOOKUP("rtip.id_obdrep", pogodba.id_rtip, "rtip.id_rtip"), obdobja_lookup.id_obd)
	GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
	lcVr_osebe = _ef_vr_osebe.vr_osebe
	USE IN _ef_vr_osebe
	
	* Region Izračun rind_dat_next - ovaj dio koda je skoro isti kao u POGODBA_MASKA_SET_DEF_VALUES
	ldTarget_date = DATE()
	
	do case
		case lnObdobje_mes = 3
			lcCalcMonth = "datepart(quarter,'{0}') * 3"
		case lnObdobje_mes = 6
			lcCalcMonth = "case when datepart(month,'{0}') <= 6 then 1 else 2 end * 6"
		*otherwise ipak bez setiranja. Jednomjesečni euribor ne koriste, nemaju aktivnih ugovora
	endcase 
	
	lcSql45222 = "select dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year('{0}')," +lcCalcMonth +", 1)))"
	
	lcSQL45222_1 = strtran(lcSql45222, "{0}", DTOS(ldTarget_date))
	ldZadnjiRadniDanZaRazdoblje = TTOD(GF_SQLEXECScalar(lcSQL45222_1))
	
	IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1') and lcTip_leas = 'F1' && kao na općim uvjetima
		
		select * from rind_strategije where odmik = 10 and !working_days into cursor _ef_rind_strategija_FO
		lnId_rind_strategije = _ef_rind_strategija_FO.id_rind_strategije
		lnDanUMjesecu = _ef_rind_strategija_FO.odmik
		use in _ef_rind_strategija_FO
		
		ldNoviDan = CTOD(ALLTRIM(STR(lnDanUMjesecu)+"/"+ALLTRIM(STR(MONTH(ldZadnjiRadniDanZaRazdoblje)))+"/"+ALLTRIM(STR(YEAR(ldZadnjiRadniDanZaRazdoblje)))))
		
		IF ldNoviDan < ldTarget_date
			ldRind_dat_next = GOMONTH(ldNoviDan, lnObdobje_mes) && pomak za razdoblje (kao što je bilo do sada)
		ELSE
			ldRind_dat_next = ldNoviDan
		ENDIF
		
	ELSE 
		select * from rind_strategije where odmik = 0 and !working_days into cursor _ef_rind_strategija_PO
		lnId_rind_strategije = _ef_rind_strategija_PO.id_rind_strategije
		use in _ef_rind_strategija_PO	
		
		IF ldZadnjiRadniDanZaRazdoblje < ldTarget_date 
			ldTarget_datePomak = GOMONTH(ldTarget_date, lnObdobje_mes) && pomak za razdoblje (kao što je bilo do sada)
						
			lcSQL45222_2 = strtran(lcSql45222, "{0}", DTOS(ldTarget_datePomak))
			ldRind_dat_next = TTOD(GF_SQLEXECScalar(lcSql45222_2))
		ELSE 
			ldRind_dat_next = ldZadnjiRadniDanZaRazdoblje
		ENDIF
	ENDIF
	* END Region Izračun rind_dat_next
	
	IF pogodba.id_rind_strategije != lnId_rind_strategije OR pogodba.Rind_dat_next != ldRind_dat_next
		POZOR("Nije unesena odgovarajuća vrijednost Strategije reprograma. Automatski će se napraviti promjena na odgovarajuće vrijednosti:" +gce;
			+"Strategija reprograma: " +allt(lookup(rind_strategije.naziv, lnId_rind_strategije, rind_strategije.id_rind_strategije)) +gce;
			+"Slj. repr.: "+trans(ldRind_dat_next) )
		loForm.Pageframe1.Page2.cmbRindStrategije.Value = lnId_rind_strategije
		loForm.Pageframe1.Page2.txtRindDatNext.Value = ldRind_dat_next
	ENDIF
ENDIF
* KRAJ Rind strategije
*********************

*********************************************
* 24.11.2021 g_tomislav MID 47577 - mjesto troška ugovora se postavlja prema kategorija4 od skrbnika 1 partnera sa ugovora

TEXT TO lcSql NOSHOW
	select s1.kategorija4 
	from dbo.partner par 
	inner join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
	inner join dbo.strm1 MT on isnull(s1.kategorija4, '') = MT.id_strm -- ako MT/kategorija4 postoji u dbo.STRM1 da tek onda ide
	where par.id_kupca = 
ENDTEXT

lcMT = allt(GF_SQLEXECScalarNull(lcSql +gf_quotedstr(pogodba.id_kupca)))

IF !GF_NULLOREMPTY(lcMT) and lcMT != allt(pogodba.id_strm)
	IF POTRJENO("Mjesto troška na ugovoru treba biti " +lcMT +" " +allt(GF_LOOKUP("strm1.strm_naz", lcMT, "strm1.id_strm")) +"!" +gce;
		+"Želite li spremiti navedenu odgovarajuću vrijednost? Nastavak spremanja ugovora nije moguć s neodgovarajućom vrijednosti (" +allt(pogodba.id_strm) +")!")
		loForm.Pageframe1.Page5.txtId_strm.Value = lcMT
	ELSE
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF 
*******END MID 47577***************************


IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF

**********************************************************************************
**PROVJERA UNOSA POREZ U MPC U ODNOSU NA STOPU POREZA U MPC NA PONUDI*************
**********************************************************************************
* LOCAL loForm, lcPogoj

* lcPogoj = ""
* loForm = NULL


* FOR lnI = 1 TO _Screen.FormCount
	* IF UPPER(_Screen.Forms(lnI).Name) == UPPER("frmPOGODBA_MASKA") THEN
	* loForm = _Screen.Forms(lnI)
* EXIT
* ENDIF
* NEXT

* IF ISNULL(loForm) THEN
	* RETURN
* ENDIF

* if used('_ponudba_list') then
	* return
* endif

* TEXT TO lcPogoj NOSHOW
	* select * from ponudba pon
		* where pon.id_pon = '{0}'
* ENDTEXT
* lcPogoj = STRTRAN(lcPogoj, '{0}', pogodba.id_pon)

* gf_sqlexec(lcPogoj,"_ponudba_list")
* &&select _test
* &&brow

* if len(alltrim(_ponudba_list.id_pon))>0 and pogodba.id_dav_op!=_ponudba_list.id_dav_op
	* if !potrjeno('Porez u MPC na ugovoru drugaeiji od Poreza u MPC unešenog na ponudi. Želite li spremiti takav ugovor?')
		* SELECT cur_extfunc_error
		* REPLACE ni_napaka WITH .F. IN cur_extfunc_error
		* if used("_ponudba_list")
			* use in _ponudba_list
		* endif
	* endif
* endif
********************************************************** 

**********************************************************************************
**** MR 38358 g_mladens; RLHR Ticket 1752 - Unos ugovora, provjera za ROL*********
**********************************************************************************
IF loForm.tip_vnosne_maske = 1 THEN 
	IF !POTRJENO("Jeste li provjerili ROL i COC?") THEN 
		RETURN .F.
	ENDIF
ENDIF
************************** KRAJ **************************************************
**********************************************************************************
**** g_dejank; MR 41269 - provjera da li je partner na ugovoru FO,F1*********
**** 13.11.2018. g_tomislav MR 41506; dorada
**** 18.06.2020. g_vuradin MR 44962; promjena LOOKUP u GF_LOOKUP
**********************************************************************************
llIzvedeniIndeks = ! GF_NULLOREMPTY(GF_LOOKUP("rtip.id_rtip_base", pogodba.id_rtip, "rtip.id_rtip"))

IF llIzvedeniIndeks AND INLIST(GF_LOOKUP("partner.vr_osebe", pogodba.id_kupca,"partner.id_kupca"), "FO","F1") AND !potrjeno('Ugovor se sklapa s fizičkom osobom i izvedenim indeksom - da li ste provjerili kamatnu stopu?') THEN
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
************************** KRAJ 41269**********************************************
***********************************************************************************
* 11.05.2022. g_igorp MR 48804 - podešavanje kontrole obaveznog unos cijene dodatnog kilometra ako na ponudi postoji kategorija JN_CIJENA_KM
* 15.07.2022. g_tomislav MID 49216 - dodana varijabla lcRegis

local lcSql48804, lcCenadkm,lcPonudba

TEXT TO lcSql48804 NOSHOW
SELECT id_entiteta FROM dbo.kategorije_entiteta WHERE id_kategorije_tip = '32' AND LTRIM(RTRIM(id_entiteta)) = '{0}'
ENDTEXT

lcPonudba =loForm.Pageframe1.Page1.txtId_pon.Value
lcCena_dkm = loForm.Pageframe1.Page3.txtCena_dkm.Value
lcRegis = GF_LOOKUP("vrst_opr.se_regis", pogodba.id_vrste, "vrst_opr.id_vrste")

lcSql48804 = STRTRAN(lcSql48804, '{0}', lcPonudba)
GF_SQLEXEC(lcSql48804,"_rezultat48804")
lcGrupa = allt(GF_LOOKUP("vrst_opr.id_grupe", pogodba.id_vrste, "vrst_opr.id_vrste"))
IF RF_TIP_POG(ponudba.nacin_leas) == "OL" AND (INLIST(lcGrupa, "VNC", "VLT", "VUC") OR (lcGrupa =="VFR" AND lcRegis =="*"))
	IF RECCOUNT("_rezultat48804") > 0 AND lcCena_dkm != 0
		POZOR("Ukoliko na ponudi postoji posebna kategorija 'JN_CIJENA_KM', polje 'Cijena dozvoljenog km' mora biti 0!")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
	IF lcCena_dkm = 0 AND RECCOUNT("_rezultat48804") = 0
		POZOR("Polje 'Cijena dozvoljenog kilometra' mora biti veće od 0.00")
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF
************************** KRAJ 48804**********************************************
