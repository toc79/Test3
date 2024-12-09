? GF_SQLEXECScalar("select  dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year(pog.rind_datum), datepart(quarter,pog.rind_datum) * 3, day(pog.rind_datum)))) as  zadnjiRadniDanKvartala from dbo.pogodba pog where id_cont =  38678")


lcSql = "select  dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year({0}), datepart(quarter,{0}) * 3, day({0}))))"
lcSQL = strtran(lcSql, "{0}", ldRind_datum)
? GF_SQLEXECScalar(lcSql)

dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year(pog.rind_dat_next), case when datepart(month,pog.rind_dat_next)<=6 then 1 else 2 end  * 6, day(pog.rind_dat_next)))) as zadnjiRadniDanPolugodista

select * from dbo.rind_strategije
select id_rind_strategije from dbo.rind_strategije where odmik = 10 and working_days = 0

select rind_datum, * from dbo.PONUDBA where id_pon = '0263374'
select rind_datum, * from dbo.PONUDBA pon
join dbo.rtip r on pon.id_rtip = r.id_rtip
where r.FIX_DAT_RPG = 1
and pon.rind_datum between '20200101' and '20200630'


select * from dbo.OBDOBJA
select * from dbo.rtip where id_obdrep = '004' --kvartalno
select * from dbo.rtip where FIX_DAT_RPG = 1 --kvartalno

select dbo.gfn_LastWorkDay(EOMONTH(DATEFROMPARTS(year(pog.rind_dat_next), datepart(quarter,pog.rind_dat_next) * 3, day(pog.rind_dat_next)))) as  zadnjiRadniDanKvartala--zadnji radni dan kvartala
	, dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year(pog.rind_dat_next), datepart(quarter,pog.rind_dat_next) * 3, day(pog.rind_dat_next)))) as  zadnjiRadniDanKvartala--zadnji radni dan kvartala
	, dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year(pog.rind_dat_next), case when datepart(month,pog.rind_dat_next)<=6 then 1 else 2 end  * 6, day(pog.rind_dat_next)))) as zadnjiRadniDanPolugodista
	, dbo.gfn_LastWorkDay(EOMONTH(pog.rind_dat_next, case month(pog.rind_dat_next) % 3 --@rind_datumMonth % 3 => offset
										when 2 then 1
										when 1 then 2
										else 0 end)) as test--zadnji radni dan kvartala
	--, dbo.gfn_LastWorkDay(EOMONTH(pog.rind_dat_next)) --Zadnji radni dan tog mjeseca
	--, EOMONTH(pog.rind_dat_next)
	, pog.RIND_DAT_NEXT, pog.RIND_DATUM, pog.ID_RIND_STRATEGIJE
	, * 
from dbo.pogodba pog
join dbo.rtip r on pog.id_rtip = r.id_rtip
where r.id_obdrep = '004' --kvartalno
and r.FIX_DAT_RPG = 1
and  status_akt = 'A'
and pog.rind_dat_next is not null
and  dbo.gfn_LastWorkDay(EOMONTH(pog.rind_dat_next)) != RIND_DAT_NEXT





? dtoc(date(), 1) 

--        set @Return = dbo.gfn_GetLastDayOfMonth(@AddedDate)  
select dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth('20200520')), dbo.gfn_PreviousWorkDay(dbo.gfn_GetLastDayOfMonth('20200220')), dbo.gfn_LastWorkDay('20200520')

*STARO
***********************************************************************************
* 14.06.2017 g_tomislav MR 36135 - Rind strategije; Sa promjenom kontrole na ovom mjestu, potrebno je promijeniti i POGODBA_MASKA_PREVERI PODATKE
* 25.06.2020 g_tomislav MID 44956 - bugfix;
***********************************************************************************
* llfix_dat_rpg = LOOKUP(rtip.fix_dat_rpg, ponudba.id_rtip, rtip.id_rtip)

* IF llfix_dat_rpg 
	* LOCAL lcid_kupca, lcTip_leas, lcVr_osebe, lnObdobje_mes, lnStrategija10, lnStrategija25, lnDanUMjesecu, lnId_rind_strategije, ldRind_datum, lnRind_datumMonth, lnRind_datumYear, lcNoviDan, lnRind_dat_next
	* lcid_kupca = ponudba.id_kupca
	* lcTip_leas = RF_TIP_POG(ponudba.nacin_leas)
	* lnObdobje_mes = 12/LOOKUP(obdobja_lookup.obnaleto, GF_LOOKUP("rtip.id_obdrep", ponudba.id_rtip, "rtip.id_rtip"), obdobja_lookup.id_obd)
	* GF_SQLEXEC("select vr_osebe from dbo.partner where id_kupca = "+GF_QUOTEDSTR(lcid_kupca),"_ef_vr_osebe")
	* lcVr_osebe = _ef_vr_osebe.vr_osebe
	* USE IN _ef_vr_osebe
	
	* lnStrategija10 = 10
	* lnStrategija25 = 25
	
	* IF (lcVr_osebe  == 'FO' or lcVr_osebe == 'F1' OR ponudba.je_foseba) and lcTip_leas = 'F1' && kao na općim uvjetima
		* lnDanUMjesecu = lnStrategija10
	* ELSE 
		* lnDanUMjesecu = lnStrategija25
	* ENDIF
	
	* lnId_rind_strategije = LOOKUP(rind_strategije.id_rind_strategije, lnDanUMjesecu, rind_strategije.odmik)
	
	* ldRind_datum = ponudba.rind_datum
	* lnRind_datumMonth = MONTH(ldRind_datum)
	* lnRind_datumYear = YEAR(ldRind_datum)
	* lcNoviDan = CTOD(ALLTRIM(STR(lnDanUMjesecu)+"/"+ALLTRIM(STR(lnRind_datumMonth))+"/"+ALLTRIM(STR(lnRind_datumYear))))
	* lnRind_dat_next = GOMONTH(lcNoviDan, lnObdobje_mes)
		
	* REPLACE pogodba.id_rind_strategije WITH lnId_rind_strategije IN pogodba
	* REPLACE pogodba.Rind_dat_next WITH lnRind_dat_next IN pogodba
		
* ENDIF
*KRAJ Rind strategije
********************

do case
			case inlist(lnRind_datumMonth, 1, 2, 3)
				store 3 to lnRind_datumMonthNew 
			case inlist(lnRind_datumMonth, 4,5,6)
				store 6 to lnRind_datumMonthNew 
			case inlist(lnRind_datumMonth, 7,8,9)
				store 9 to lnRind_datumMonthNew 
			case inlist(lnRind_datumMonth, 10,11,12)
				store 12 to lnRind_datumMonthNew 
		endcase	