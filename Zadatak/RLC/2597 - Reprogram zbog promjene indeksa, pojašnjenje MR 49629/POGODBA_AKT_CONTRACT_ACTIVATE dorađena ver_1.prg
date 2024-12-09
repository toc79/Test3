Local loForm
loForm = GF_GetFormObject('frmPogodba_akt')

** Created: unknown
LOCAL ldDatAkt, ldDatPot
ldDatAkt = loForm.datumakt
ldDatPot = pogodba.DAT_PODPISA

IF GF_NULLOREMPTY(ldDatPot) OR ldDatAkt < ldDatPot
	IF !POTRJENO("Datum aktivacije je manji od datuma potpisa ugovora, da li želite aktivirati ugovor?")
		RETURN .F.
	ENDIF 
ENDIF

***********************************************************************************
* 07.10.2022 g_tomislav MID 49629 - Rind_strategije: provjera na datum sljedećeg reprograma
***********************************************************************************
LOCAL lnId_cont
lcId_cont = loForm.id_cont

text to lcSql noshow
	--Nije rađena provjera na id_rind_strategije da li je ispravna niti za razdoblje. Provjerava se današnji datum umjesto rind_dat_next zbog slučaja aktivacije ugovora
	declare @today datetime = dbo.gfn_GetDatePart(getdate())
	select case when par.vr_osebe in ('FO', 'F1') and dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'F1' then cast(DATEFROMPARTS(year(@today), month(@today), 10) as datetime)
			else dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(@today)) end as Correct_rind_dat_next --alternativa je EOMONTH
		, cast(rs.naziv as varchar(75)) as rind_strategije_naziv 
		, pog.rind_dat_next 
	from dbo.pogodba pog
	inner join dbo.rtip r on pog.id_rtip = r.id_rtip
	inner join dbo.partner par on pog.id_kupca = par.id_kupca
	left join dbo.rind_strategije rs on pog.id_rind_strategije = rs.id_rind_strategije
	where r.fix_dat_rpg = 1
	and pog.id_cont = {0}
endtext 
lcSql = strtran(lcSql, '{0}', str(lcId_cont)) 
GF_SQLEXEC(lcSql, "_ef_pogodba")

IF RECCOUNT("_ef_pogodba") > 0 and NVL(_ef_pogodba.rind_dat_next, {03.03.1903}) != NVL(_ef_pogodba.Correct_rind_dat_next, {02.02.1902}) && null datumi su mogući kod starih podataka 
	POZOR("Ugovor se ne može aktivirati jer nema odgovarajuću vrijednost datuma sljedećeg reprograma koji bi trebao biti " +trans(TTOD(_ef_pogodba.Correct_rind_dat_next)) +"! Trenutne vrijednosti su:" +gce;
			+"Strategija reprograma: " +allt(_ef_pogodba.rind_strategije_naziv) +gce;
			+"Slj. repr.: "+trans(TTOD(_ef_pogodba.rind_dat_next)))
	RETURN .F.
ENDIF
* KRAJ - Rind_strategije
***********************************************************************************