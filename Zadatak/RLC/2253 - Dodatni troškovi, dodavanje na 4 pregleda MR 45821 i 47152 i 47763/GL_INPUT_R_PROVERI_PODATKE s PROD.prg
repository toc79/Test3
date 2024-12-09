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

**********************************************
** MID: 42581 g_barbarak - provjera polja Interna veza za tip dok FLE
** MID: 43901 g_barbarak - promjena provjere polja u Broj povezanog dokumenta

IF gl_input_r.vrsta_rac='FLE' and GF_NULLOREMPTY(gl_input_r.vr_rac_veza)
	POZOR("Obavezan je unos u polje Broj povezanog dokumenta za Tip pov. dokumenta Faktura za FLEET!")
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
ENDIF
**********************************************

**********************************************
** 31.08.2021 g_tomislav MID 47147 - izrada; provjera potražnog salda za konto 290007 za trošak 03 ODRŽAVANJE; obavijest o saldu se uvijek prikazuje, a ako je prekoračen ne može se spremiti račun
** 29.09.2021 g_tomislav MID 47592 - prikaz poruke stavaka u posebnom prozoru

select id_cont, id_pog, sum(znesek) as sum_znesek from gl_input_rk where protikonto = '290007' and id_vrst_dod_str = '03' and !GF_NULLOREMPTY(id_cont) group by id_cont, id_pog INTO CURSOR _ef_kandidati

IF RECCOUNT("_ef_kandidati") > 0
	LcList_condition = ""  && Mora biti 
	lcList = GF_CreateDelimitedList("_ef_kandidati", "id_cont", LcList_condition, ",", .f.) 

	TEXT TO lcSQL NOSHOW
		select id_cont, sum(potrazni_saldo) as potrazni_saldo
		from (
			select id_cont, (gl.kredit_dom - gl.debit_dom) as potrazni_saldo 
			from dbo.gl gl
			inner join dbo.gfn_split_ids('{0}', ',') v on v.id = gl.id_cont
			where konto = '290007'
			union all
			select id_cont, (gl.kredit_dom - gl.debit_dom) as potrazni_saldo 
			from dbo.gl_k_dnev gl
			inner join dbo.gfn_split_ids('{0}', ',') v on v.id = gl.id_cont
			where konto = '290007'
			) a
		group by id_cont
	ENDTEXT

	lcSQL = STRTRAN(lcSQL, "{0}", lcList)
	gf_sqlexec(lcSQL, "_ef_gl")

	select a.id_cont, a.id_pog, a.sum_znesek, NVL(b.potrazni_saldo, 0000000000000.00) as potrazni_saldo;
	from _ef_kandidati a ;
	left join _ef_gl b on a.id_cont = b.id_cont; 
	into cursor _ef_final;
	order by a.id_cont;

	* prebacivanje u clipboard i prikaz tabele u prozoru/na ekran
	select id_pog as Ugovor, potrazni_saldo as Potražni_saldo, sum_znesek as Iznos_na_stavkama, potrazni_saldo - _ef_final.sum_znesek as Trenutni_saldo from _ef_final into cursor _ef_final_clipboard
	_vfp.datatoclip(,,3)
	select * from _ef_final_clipboard

	lcTekst = ""
	llJePrekoracen = .f.

	select _ef_final
	go top 
	SCAN
		lcTekstPrekoracen = ""
		
		IF _ef_final.potrazni_saldo - _ef_final.sum_znesek < 0
			lcTekstPrekoracen = " je prekoračen i"
			llJePrekoracen = .t.
		ENDIF
		
		lcTekst = lcTekst +allt(_ef_final.id_pog) +" iznosi " +allt(trans(_ef_final.potrazni_saldo, gccif)) +", a s uključenim iznosom na stavkama " +allt(trans(_ef_final.sum_znesek, gccif)) +lcTekstPrekoracen +" iznosi " +allt(trans(_ef_final.potrazni_saldo - _ef_final.sum_znesek, gccif)) +gce
		
	ENDSCAN

	lcTekst = "Potražni saldo za konto 290007 za ugovor " +gce +lcTekst
			
	IF llJePrekoracen
		lcTekst = lcTekst +"Iznos je potrebno proknjižiti na uobičajeni konto troška (412403 ili 412404)!"
		POZOR(lcTekst)
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ELSE 
		* u slučaju da nije prekoračen iznos, poruka se netreba prikazivati jer je napravljen prikaz tabele u prozoru/na ekran
		* OBVESTI(lcTekst)
	ENDIF
ENDIF
*KRAJ 47147***********************************
**********************************************
** 10.02.2022. g_andrijap 48328 kontrole ukalkuliranog iznosa na kontu 290008

select id_cont, id_pog, sum(znesek) as sum_znesek from gl_input_rk where protikonto = '290008' and id_vrst_dod_str in ('03','04','08','09','10','11','13') and !GF_NULLOREMPTY(id_cont) group by id_cont, id_pog INTO CURSOR _ef_kandidati2

IF RECCOUNT("_ef_kandidati2") > 0
	LcList_condition = ""  && Mora biti 
	lcList = GF_CreateDelimitedList("_ef_kandidati2", "id_cont", LcList_condition, ",", .f.) 

	TEXT TO lcSQL NOSHOW
		select id_cont, sum(potrazni_saldo) as potrazni_saldo
		from (
			select id_cont, (gl.kredit_dom - gl.debit_dom) as potrazni_saldo 
			from dbo.gl gl
			inner join dbo.gfn_split_ids('{0}', ',') v on v.id = gl.id_cont
			where konto = '290008'
			union all
			select id_cont, (gl.kredit_dom - gl.debit_dom) as potrazni_saldo 
			from dbo.gl_k_dnev gl
			inner join dbo.gfn_split_ids('{0}', ',') v on v.id = gl.id_cont
			where konto = '290008'
			) a
		group by id_cont
	ENDTEXT

	lcSQL = STRTRAN(lcSQL, "{0}", lcList)
	gf_sqlexec(lcSQL, "_ef_gl")

	select a.id_cont, a.id_pog, a.sum_znesek, NVL(b.potrazni_saldo, 0000000000000.00) as potrazni_saldo;
	from _ef_kandidati2 a ;
	left join _ef_gl b on a.id_cont = b.id_cont; 
	into cursor _ef_final2;
	order by a.id_cont;


	lcTekst = ""
	llJePrekoracen = .f.

	select _ef_final2
	go top 
	SCAN
		lcTekstPrekoracen = ""
		
		IF _ef_final2.potrazni_saldo - _ef_final2.sum_znesek < 0
			lcTekstPrekoracen = " je prekoračen i"
			llJePrekoracen = .t.
		ENDIF
		
		lcTekst = lcTekst +allt(_ef_final2.id_pog) +" iznosi " +allt(trans(_ef_final2.potrazni_saldo, gccif)) +", a s uključenim iznosom na stavkama " +allt(trans(_ef_final2.sum_znesek, gccif)) +lcTekstPrekoracen +" iznosi " +allt(trans(_ef_final2.potrazni_saldo - _ef_final2.sum_znesek, gccif)) +gce
		
	ENDSCAN

	lcTekst = "Potražni saldo za konto 290008 za ugovor " +gce +lcTekst
			
	IF llJePrekoracen
		lcTekst = lcTekst +"Iznos je potrebno proknjižiti na uobičajeni konto troška (412403 ili 412404)!"
		POZOR(lcTekst)
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ELSE 
		* u slučaju da nije prekoračen iznos, poruka se netreba prikazivati jer je napravljen prikaz tabele u prozoru/na ekran
		* OBVESTI(lcTekst)
	ENDIF
ENDIF

IF RECCOUNT("_ef_kandidati") > 0 and  RECCOUNT("_ef_kandidati2") > 0
	* prebacivanje u clipboard i prikaz tabele u prozoru/na ekran
	select id_pog as Ugovor, potrazni_saldo as Potražni_saldo, sum_znesek as Iznos_na_stavkama, potrazni_saldo - _ef_final.sum_znesek as Trenutni_saldo from _ef_final UNION select id_pog as Ugovor, potrazni_saldo as Potražni_saldo, sum_znesek as Iznos_na_stavkama, potrazni_saldo - _ef_final2.sum_znesek as Trenutni_saldo from _ef_final2 into cursor _ef_final_clipboard
	_vfp.datatoclip(,,3)
	select * from _ef_final_clipboard 
ENDIF
IF RECCOUNT("_ef_kandidati") > 0 and  RECCOUNT("_ef_kandidati2") < 1
	* prebacivanje u clipboard i prikaz tabele u prozoru/na ekran
	select id_pog as Ugovor, potrazni_saldo as Potražni_saldo, sum_znesek as Iznos_na_stavkama, potrazni_saldo - _ef_final.sum_znesek as Trenutni_saldo from _ef_final into cursor _ef_final_clipboard
	_vfp.datatoclip(,,3)
	select * from _ef_final_clipboard 
ENDIF
IF RECCOUNT("_ef_kandidati") < 1 and  RECCOUNT("_ef_kandidati2") > 0
	* prebacivanje u clipboard i prikaz tabele u prozoru/na ekran
	 select id_pog as Ugovor, potrazni_saldo as Potražni_saldo, sum_znesek as Iznos_na_stavkama, potrazni_saldo - _ef_final2.sum_znesek as Trenutni_saldo from _ef_final2 into cursor _ef_final_clipboard
	_vfp.datatoclip(,,3)
	select * from _ef_final_clipboard 
ENDIF

*KRAJ 48328***********************************



IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF