*//////////////////////////////////////////////
* 05.02.2020 g_tomislav MR 43505 - created;

GF_SQLEXEC("SELECT id_rtip FROM dbo.rtip WHERE id_rtip_base IS NOT NULL", "_ef_izvedeni")

SELECT a.id_pog, a.id_rtip, a.rind_zadnji, a.indeks, a.sprememba, a.obrok_bruto, a.nov_obrok_bruto FROM rep_pog a ;
INNER JOIN _ef_izvedeni b ON a.id_rtip = b.id_rtip ;
WHERE (!GF_NULLOREMPTY(a.sprememba) AND a.sprememba != 0) ;
INTO CURSOR _ef_izv_ugovori

IF RECCOUNT("_ef_izv_ugovori") > 0
	IF POTRJENO("Na ugovorima s izvedenim indeksom je došlo da promjene vrijednosti indeksa. Da li želite vidjeti listu tih ugovora?")
		SELECT id_pog AS Ugovori, id_rtip AS Rev_indeks, rind_zadnji AS Stari_indeks, indeks AS Novi_indeks, sprememba AS Promjena, obrok_bruto AS Trenutna_rata, nov_obrok_bruto AS Nova_rata, obrok_bruto - nov_obrok_bruto AS Razlika_rata FROM _ef_izv_ugovori 
	ENDIF
ENDIF
* END MR 43505//////////////////////////////////////////////

***********************************************************************************
* 24.09.2020 g_tomislav MID 45222 - Rind_strategije: nova strategija zadnji radni dan u mjesecu. rep_pog.datum bi trebao biti rind_dat_next te treba s njime uspoređivati
***********************************************************************************
LcList_condition = ""  && Mora biti 
lcList = GF_CreateDelimitedList("rep_pog", "id_cont", LcList_condition, ",", .f.) &&BEZ NAVODNIKA

text to lcSql noshow
	--Nije rađena provjera na id_rind_strategije da li je ispravna niti za razdoblje. Provjerava se današnji datum umjesto rind_dat_next zbog slučaja aktivacije ugovora
	declare @today datetime = dbo.gfn_GetDatePart(getdate())
	select id_cont
		, case when par.vr_osebe in ('FO', 'F1') and dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'F1' then cast(DATEFROMPARTS(year(@today), month(@today), 10) as datetime)
			else dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(@today)) end as Correct_rind_dat_next --alternativa je EOMONTH
		, cast(rs.naziv as varchar(75)) as rind_strategije_naziv, pog.dat_aktiv
		--, pog.rind_dat_next, pog.rind_datum, pog.id_rind_strategije
	from dbo.pogodba pog
	inner join dbo.rtip r on pog.id_rtip = r.id_rtip
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	inner join dbo.gfn_split_ids('{0}', ',') v on v.id = pog.id_cont
	left join dbo.rind_strategije rs on pog.id_rind_strategije = rs.id_rind_strategije
	where r.fix_dat_rpg = 1
endtext 

lcSql = strtran(lcSql, '{0}', lcList) 
GF_SQLEXEC(lcSql, "_ef_ugovori_rind_strategije")

* null datumi su mogući kod starih podataka 
SELECT b.*, a.* ;
FROM rep_pog a ;
INNER JOIN _ef_ugovori_rind_strategije b ON a.id_cont = b.id_cont ;
WHERE NVL(a.rind_dat_next, {03.03.1903}) != NVL(b.Correct_rind_dat_next, {02.02.1902}) ;
INTO CURSOR _ef_razike_rind_strategije

IF RECCOUNT("_ef_razike_rind_strategije") > 0
	IF POTRJENO("Postoje ugovori kojima datum strategije reprograma nije odgovarajući. Da li želite vidjeti listu tih ugovora?")
		SELECT id_pog AS Ugovor, rind_dat_next Datum_Slj_repr, Correct_rind_dat_next as Izračunati_datum_Slj_repr, rind_strategije_naziv as Naziv_strategije, id_rtip AS Rev_indeks, vr_osebe as Vrsta_osobe, nacin_leas as Tip_leasinga, dat_sklen as Datum_sklapanja, dat_aktiv as Datum_aktiviranja FROM _ef_razike_rind_strategije INTO CURSOR _ef_to_clipboard
		_vfp.datatoclip(,,3) && prebacivanje podataka u clipboard
		select * from _ef_to_clipboard
	ENDIF
ENDIF
* KRAJ - Rind_strategije
