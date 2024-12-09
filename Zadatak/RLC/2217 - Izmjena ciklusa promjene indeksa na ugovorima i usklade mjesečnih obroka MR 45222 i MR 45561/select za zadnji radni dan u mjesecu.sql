declare @rind_datum datetime = '20220130' --2022-12-30 00:00:00.000 je petak
--declare @rind_datumMonth tinyint = month(@rind_datum)
--kvartalno , svaka 3 mjeseca 12/4 (obnaleto)
declare @rind_datumOffset tinyint = (case month(@rind_datum) % 3 --@rind_datumMonth % 3
										when 2 then 1
										when 1 then 2
										else 0 end)
declare @rind_datumNew datetime = (dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(dateadd(month, @rind_datumOffset, @rind_datum))))
declare @rind_datumNewEOMONTH datetime = (dbo.gfn_LastWorkDay(EOMONTH(@rind_datum, @rind_datumOffset)))
--iznimka ako je zadnji dan u mjesecu manji od rind datuma (u sluèaju da su unijeli ponudu u subotu koji je poslije zadnjeg radnog dana u godini), tada treba napraviti pomak na sljedeæe razdoblje (osim ako drugaèije definiraju)
declare @rind_datumNew2 datetime = (case when @rind_datumNew < @rind_datum THEN (dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(dateadd(month, 3, @rind_datumNew)))) else @rind_datumNew end)

--declare @rind_datumMonthNew tinyint = (case 
--										when @rind_datumMonth between 1 and 3 then 3 
--										when @rind_datumMonth between 4 and 6 then 6 
--										when @rind_datumMonth between 7 and 9 then 9
--										when @rind_datumMonth between 10 and 12 then 12 
--										end)
--lnObdobje_mes = 12/LOOKUP(obdobja_lookup.obnaleto, GF_LOOKUP("rtip.id_obdrep", ponudba.id_rtip, "rtip.id_rtip"), obdobja_lookup.id_obd)
--lnRind_dat_next = GOMONTH(lcNoviDan, lnObdobje_mes)
select dbo.gfn_GetLastDayOfMonth(@rind_datum)  as gfn_GetLastDayOfMonth 
	, dbo.gfn_LastWorkDay(dbo.gfn_GetLastDayOfMonth(@rind_datum)) as LastWorkingDayOfMonth
	, dbo.gfn_PreviousWorkDay(dbo.gfn_GetLastDayOfMonth(@rind_datum)) as gfn_PreviousWorkDay
	, dbo.gfn_LastWorkDay(@rind_datum) as gfn_LastWorkDay
	, MONTH(@rind_datum) as month
	--, @rind_datumMonthNew as rind_datumMonthNew
	--, @rind_datumOffset as rind_datumOffset
	, @rind_datumNew as rind_datumNew
	, @rind_datumNew2 as rind_datumNew2
	, @rind_datumNewEOMONTH

Select datepart(quarter,@rind_datum) * 3 as quater-- i onda kreirati datum u funkciji datefromparts
	, DATEFROMPARTS(year(@rind_datum), datepart(quarter,@rind_datum) * 3, day(@rind_datum)) set_to_EOQ
	, dbo.gfn_LastWorkDay(EOMONTH(DATEFROMPARTS(year(@rind_datum), datepart(quarter,@rind_datum) * 3, day(@rind_datum)))) zadnjiRadniDanKvartala--zadnji radni dan kvartala
	, DATEFROMPARTS(year(@rind_datum), case when datepart(month,@rind_datum)<=6 then 1 else 2 end  * 6, day(@rind_datum)) zadnjiRadniDanPolugodista
--SELECT  EOMONTH(@rind_datum, 2) end_of_month
select * from dbo.obdobja
