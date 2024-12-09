select * from dbo.gl where id_cont =65439 and konto='290007'
dodati provjeru na KU_DNEV
select * from dbo.GL_K_DNEV where id_cont =65439 and konto='290007'

LOCAL lcStariAlias, lcPogoj, lcPoruka
lcStariAlias = ALIAS()

if gl_input_r.vrsta_rac='STE'
	TEXT TO lcPogoj NOSHOW 
		select * from dbo.ss_odskod where stevilka = '{0}' 
	ENDTEXT 
	lcPogoj = STRTRAN(lcPogoj, '{0}', gl_input_r.vr_rac_veza)
	gf_sqlexec(lcPogoj, "_ss_odskod_exists")

	if len(alltrim(gl_input_r.vr_rac_veza)) = 0 or len(alltrim(_ss_odskod_exists.stevilka)) = 0
		if len(alltrim(gl_input_r.vr_rac_veza)) = 0
			lcPoruka = 'Za tip dokumenta štete potrebno je unijeti broj štete, želite li prekinuti?'
		else
			lcPoruka = 'Broj štete ' + alltrim(gl_input_r.vr_rac_veza) + ' ne postoji, želite li prekinuti?'
		endif
		if potrjeno(lcPoruka)
			SELECT cur_extfunc_error
			REPLACE ni_napaka WITH .F. IN cur_extfunc_error
			if used("_ss_odskod_exists")
				use in _ss_odskod_exists
			endif
			if gl_input_r.id_cont > 0
				TEXT TO lcPogoj NOSHOW 
					select s.stevilka as broj_stete, s.dat_skod as datum_stete, p.id_pog as broj_ugovora 
					from dbo.ss_odskod s inner join pogodba p on s.id_cont = p.id_cont 
					where s.id_cont = {0}
				ENDTEXT 
				lcPogoj = STRTRAN(lcPogoj, '{0}', alltrim(str(gl_input_r.id_cont)))
				gf_sqlexec(lcPogoj, "_ss_odskod_exists")
				brow
				if used("_ss_odskod_exists")
					use in _ss_odskod_exists
				endif
			endif		
		endif
	endif
endif

**********************************************
&&Kontrola unosa dodatnih troškova RLHR #1651
** MID: 42581 g_barbarak - kod kontrole za FULL leasing dodana i vrsta računa za FLEET
** 04.06.2020 Tomislav MID 44249 RLHR #2120 - dodana provjera za konta razgraničenja iz RLC_DOD_STR_KONTO_RAZMEJ. Promjena 2. kontrole da se radi i za gl_input_r.vrsta_rac!='FLE'. Isključivanje 3. kontrole
**********************************************
TEXT TO lcSQL NOSHOW
	SELECT DISTINCT a.konto, b.cnt
	FROM dbo.VRST_DOD_STR a
	INNER JOIN (SELECT konto, COUNT(id_vrst_dod_str) as cnt FROM dbo.VRST_DOD_STR GROUP BY konto) b ON a.konto = b.konto
	UNION
	Select LTRIM(RTRIM(id)) as konto, CAST(1 as INT) as cnt From dbo.gfn_GetTableFromList ((Select val_char From dbo.general_register Where ID_KEY = 'RLC_REKLAS_DOD_STR' and neaktiven = 0))
	UNION
	Select LTRIM(RTRIM(id)) as konto, CAST(1 as INT) as cnt From dbo.gfn_GetTableFromList ((Select val_char From dbo.general_register Where ID_KEY = 'RLC_DOD_STR_KONTO_RAZMEJ' and neaktiven = 0))
	ORDER BY konto
ENDTEXT
GF_SQLEXEC(lcSQL, "_DodStrKto")

SELECT a.protikonto, a.id_vrst_dod_str, b.cnt FROM gl_input_rk a INNER JOIN _DodStrKto b ON a.protikonto = b.konto INTO CURSOR _DodStrChk

IF RECCOUNT("_DodStrChk") > 0 THEN
 &&1. - konto dodatnog troška, a nije odabran tip povezanoga dokumenta "Faktura za Full leasing"
  IF !INLIST(gl_input_r.vrsta_rac, "FUL", "FLE") THEN
  **gl_input_r.vrsta_rac!='FUL'
   POZOR("Stavke računa knjiže se po kontima dodatnih usluga te je potrebno odabrati ispravan tip povezanoga dokumenta!")
   SELECT cur_extfunc_error
   REPLACE ni_napaka WITH .F. IN cur_extfunc_error
   RETURN
  ENDIF
 
 &&2. - konto dodatnog troška, a dodatni trošak nije evidentiran na stavku
  SELE _DodStrChk
  GO TOP
  SCAN FOR GF_NULLOREMPTY(id_vrst_dod_str)  &&AND gl_input_r.vrsta_rac!='FLE'
   POZOR("Za stavke koje se knjiže na konto "+ALLT(protikonto)+" potrebno je evidentirati vrstu dodatnog troška!")
   REPLACE ni_napaka WITH .F. IN cur_extfunc_error
   RETURN
  ENDSCAN
  
 &&3. - više stavaka na isti konto s istim dodatnim troškom
  * SELE _DodStrChk
  * GO TOP 
  * SCAN FOR cnt > 1
   * IF POTRJENO("Po kontu "+ALLT(protikonto)+" moguće je knjižiti više različitih dodatnih troškova, želite li prekinuti unos i provjeriti stavke?")
    * SELECT cur_extfunc_error
    * REPLACE ni_napaka WITH .F. IN cur_extfunc_error
    * RETURN
   * ENDIF
  * ENDSCAN
ENDIF

&& - MEM FREE
IF USED("_DodStrChk") THEN
 USE IN _DodStrChk
ENDIF
**************** KRAJ DORADE *****************

IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF

**********************************************
** MID: 42581 g_barbarak - provjera polja Interna veza za tip dok FLE
** MID: 43901 g_barbarak - promjena provjere polja u Broj povezanog dokumenta

IF gl_input_r.vrsta_rac='FLE' and GF_NULLOREMPTY(gl_input_r.vr_rac_veza)
	POZOR("Obavezan je unos u polje Broj povezanog dokumenta za Tip pov. dokumenta Faktura za FLEET!")
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
**********************************************