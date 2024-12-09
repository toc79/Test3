**************************************************************************
** MR 48002, 21.02.2022, g_vuradin - create validation
** MR 48002, 28.04.2022, g_vuradin - validation set on 1st day of month
** 05.10.2022 g_tomislav MID 49652 - bugfix and code optimization

IF loForm.tip_vnosne_maske <> 1 && Novi zapis
	TEXT TO lcSQL NOSHOW
		declare @today datetime = dbo.gfn_GetDatePart(getdate())
		declare @firstWorkDay tinyint = datepart(dd, dbo.gfn_FirstWorkDay(dbo.gfn_GetFirstDayOfMonth(@today)))

		select cast((case when @firstWorkDay != datepart(dd, @today) then 1 else 0 end) as bit) as changeEnabled  -- ili < umjesto !=
	ENDTEXT
	llChangeEnabled = GF_SQLEXECScalar(lcSql)

	IF ! llChangeEnabled
		IF _PARTNER_COPY.SKRBNIK_1 <> PARTNER.SKRBNIK_1
			POZOR("Promjena polja SKRBNIK_1 moguća je tek nakon prvog radnog dana u mjesecu!")
		ENDIF

		IF _PARTNER_COPY.KATEGORIJA4 <> PARTNER.KATEGORIJA4  
			POZOR("Promjena polja MJESTO TROŠKA moguća je tek nakon prvog radnog dana u mjesecu!")
		ENDIF
		REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	ENDIF 
ENDIF
** Kraj 48002 **************************************************************



--Prikaz datuma 
declare @today datetime = '20221001'--getdate()

declare @table table (datum datetime, isFirstWorkDay bit)
declare @firstWorkDay tinyint
--declare @target_date datetime

while @today <= dateadd(yy, 5, getdate()) 
begin 
	--set @target_date = dbo.gfn_getDatePart(@today)
	set @firstWorkDay = datepart(dd, dbo.gfn_FirstWorkDay(dbo.gfn_GetFirstDayOfMonth(@today)))
	
	insert into @table(datum, isFirstWorkDay) values (@today,  cast((case when @firstWorkDay != datepart(dd, @today) then 1 else 0 end) as bit)) -- ili < umjesto !=
	set @today = dateadd(dd, 1, @today)
end

select dbo.gfn_ConvertDate(datum, 9) as [Datum], datename(WEEKDAY, datum) as [Dan], dbo.gfn_Praznik(datum) as [Praznik], isFirstWorkDay [Može se promjeniti S1 ili MT] from @table