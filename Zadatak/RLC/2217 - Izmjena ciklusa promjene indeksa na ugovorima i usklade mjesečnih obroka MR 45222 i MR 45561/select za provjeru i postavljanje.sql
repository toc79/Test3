--select * from dbo.OBDOBJA
select * from dbo.rtip where id_obdrep = '004' --kvartalno

select dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(DATEFROMPARTS(year(pog.rind_dat_next), datepart(quarter,pog.rind_dat_next) * 3, day(pog.rind_dat_next)))) as  zadnjiRadniDanKvartala--zadnji radni dan kvartala
	, dbo.gfn_LastWorkDay(EOMONTH(DATEFROMPARTS(year(pog.rind_dat_next), datepart(quarter,pog.rind_dat_next) * 3, day(pog.rind_dat_next)))) as  zadnjiRadniDanKvartala--zadnji radni dan kvartala
	, dbo.gfn_LastWorkDay(EOMONTH(DATEFROMPARTS(year(pog.rind_dat_next), case when datepart(month,pog.rind_dat_next)<=6 then 1 else 2 end  * 6, day(pog.rind_dat_next)))) as zadnjiRadniDanPolugodista
	, dbo.gfn_LastWorkDay(EOMONTH(pog.rind_dat_next, case month(pog.rind_dat_next) % 3 --@rind_datumMonth % 3 => offset
										when 2 then 1
										when 1 then 2
										else 0 end)) --zadnji radni dan kvartala
	, dbo.gfn_LastWorkDay(EOMONTH(pog.rind_dat_next)) --Zadnji radni dan tog mjeseca
	, EOMONTH(pog.rind_dat_next)
	, pog.RIND_DAT_NEXT, pog.RIND_DATUM, pog.ID_RIND_STRATEGIJE
	, * 
from dbo.pogodba pog
join dbo.rtip r on pog.id_rtip = r.id_rtip
where r.id_obdrep = '004' --kvartalno
and r.FIX_DAT_RPG = 1
and  status_akt = 'A'
and pog.rind_dat_next is not null
and  dbo.gfn_LastWorkDay(EOMONTH(pog.rind_dat_next)) != RIND_DAT_NEXT

--frmActiveContractUpdate       cmbRindStrategije,txtRindDatNext alternativa, ali kod aktivacije ugovora u drugom razdoblju, neæe oni sami moæi promijeniti tak da je bolje ovako 
--sluèaj aktivacije nakon razdoblja æe biti uhvaæen kod rpg zbog promjene indeksa

	select * from (
		select id_cont
			, case when par.vr_osebe in ('FO', 'F1') and dbo.gfn_Nacin_leas_HR(pog.nacin_leas) = 'F1' then cast(DATEFROMPARTS(year(pog.rind_dat_next), month(pog.rind_dat_next), 10) as datetime)
				else dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(pog.rind_dat_next)) end as Correct_rind_dat_next --alternativa je EOMONTH
			, pog.RIND_DAT_NEXT, pog.RIND_DATUM, pog.ID_RIND_STRATEGIJE, rs.naziv as rind_strategije_naziv 
			, r.*
		from dbo.pogodba pog
		inner join dbo.rtip r on pog.id_rtip = r.id_rtip
		inner join dbo.partner par on pog.id_kupca = par.id_kupca
		--inner join dbo.gfn_split_ids('{0}',',') v on v.id = pog.id_cont
		left join dbo.rind_strategije rs on pog.id_rind_strategije = rs.id_rind_strategije
		where 1=1
		and r.FIX_DAT_RPG = 1
		--and pog.rind_dat_next is not null --ovo æe uhvatiti sistemska kontrola?
	) a
	where ISNULL(Correct_rind_dat_next, '19020202') != ISNULL(RIND_DAT_NEXT, '19000101')