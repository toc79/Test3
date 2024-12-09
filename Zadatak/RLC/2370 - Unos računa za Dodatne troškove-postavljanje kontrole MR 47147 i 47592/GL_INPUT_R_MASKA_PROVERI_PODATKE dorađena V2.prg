**********************************************
**27.07.2021 g_tomislav MID 47147 - provjera potražnog salda za konto 290007 za trošak 03 ODRŽAVANJE 

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

	lcTekst = ""

	select _ef_final
	go top 
	SCAN
		IF _ef_final.potrazni_saldo - _ef_final.sum_znesek < 0
			lcTekst = lcTekst +allt(_ef_final.id_pog) +" iznosi " +allt(trans(_ef_final.potrazni_saldo, gccif)) +", a s uključenim iznosom na stavkama " +allt(trans(_ef_final.sum_znesek, gccif)) +" je prekoračen i iznosi " +allt(trans(_ef_final.potrazni_saldo - _ef_final.sum_znesek, gccif)) +gce
		ENDIF
	ENDSCAN
	IF !EMPTY(lcTekst) 
		lcTekst = "Potražni saldo za konto 290007 za ugovor " +gce +lcTekst
		
		lcTekst = lcTekst +"Iznos je potrebno proknjižiti na uobičajeni konto troška (412403 ili 412404)!"
		POZOR (lcTekst)
		SELECT cur_extfunc_error
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF
ENDIF
*KRAJ 47147***********************************



IF !EMPTY(lcStariAlias) THEN
	SELECT (lcStariAlias)
ENDIF
