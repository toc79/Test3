declare @cmd varchar(max), @b2rl_db_name varchar(10)
set @b2rl_db_name = (select val from dbo.custom_settings where code = 'B2RLDatabase')

set @cmd = '  '
declare @entity_name varchar(10), @id_tec char(3), @target_date datetime
declare @percentage_nretail decimal(6,4), @amount_nretail decimal(18,2)
declare @arh_date datetime

start date for new DPD counter DPD_B3
declare @new_dpd_counter_date_str varchar(50), @new_dpd_counter_date datetime, @new_dpd_counter bit

set @entity_name = (select ltrim(rtrim(entity_name)) from dbo.loc_nast)
set @id_tec = (case when @entity_name in (''RLRS'', ''RRRS'', ''RLBH'') then ''001'' when @entity_name = ''RLHR'' then ''006'' else ''000'' end)
set @target_date = dbo.gfn_GetDatePart(getdate())
set @amount_nretail = 250.00
set @percentage_nretail = 0.025

set @new_dpd_counter_date_str = (SELECT val FROM dbo.custom_settings WHERE code = ''DE_NEW_DPD_COUNTER_DATE'')
set @new_dpd_counter_date = (case when @new_dpd_counter_date_str is null or @new_dpd_counter_date_str = '''' then null else cast(@new_dpd_counter_date_str as datetime) end)
set @new_dpd_counter = case when @target_date >= @new_dpd_counter_date then cast(1 as bit) else cast(0 as bit) end

--- osvežitev planp_ds je obvezno, predno se poganjajo default eventi

declare @planp_ds_tec char(3)
select top 1 @planp_ds_tec = planp_ds_tec from dbo.LOC_NAST
exec dbo.gsp_PrepareSummaryDailySnapshotFromPlanp @planp_ds_tec, null, null

-- arhiviramo zapise, ki so starejsi od 6 mesecev
set @arh_date = dateadd(mm, -6, @target_date)
set @arh_date = dbo.gfn_GenerateDateTime(year(@arh_date), month(@arh_date), 1)

insert into {0}.dbo.st_customer_past_due_production_arh(id, id_kupca, effective_date, due_start_date, due_end_date, current_days_past_due, total_overdue_amount, total_overdue_cur_code, eval_model, last_dat_plac, future_capital, dpd_type, last_id_lsk_for_payment)
select id, id_kupca, effective_date, due_start_date, due_end_date, current_days_past_due, total_overdue_amount, total_overdue_cur_code, eval_model, last_dat_plac, future_capital, dpd_type, last_id_lsk_for_payment
from {0}.dbo.st_customer_past_due_production
where effective_date < @arh_date

delete from {0}.dbo.st_customer_past_due_production where effective_date < @arh_date

-- prepare dates -> when closing DPD counters, claims with due dates on those days need to be excluded from ODR (because payments are booked first working day after due date)
create table #dates_exclude_odr(date_excl_odr datetime)

declare @first_woking_day_in_the_past bit, @current_date datetime
set @first_woking_day_in_the_past = 0

set @current_date = dbo.gfn_GetDatePart(@target_date)
while @first_woking_day_in_the_past != 1 begin

	insert into #dates_exclude_odr(date_excl_odr)
	values(@current_date)

	set @current_date = dateadd(dd, -1, @current_date)
	if dbo.gfn_FirstWorkDay(@current_date) = @current_date begin
		set @first_woking_day_in_the_past = 1
	end

end

-- exclude fin types
select id_key as nacin_leas
into #exclude_lease_types
from dbo.gfn_g_register_active(''RL_REGION_EXCLUDE_LEASE_TYPES'', null)

-- booked claims that have due date on today or on non working day until last working day in the past
SELECT pp.id_cont, pp.id_kupca,
		sum(dbo.gfn_Xchange(@id_tec, case when pp.evident = ''*'' then pp.saldo else 0 end, pp.id_tec, @target_date)) as saldo,
		sum(dbo.gfn_Xchange(@id_tec, case when pp.evident = ''*'' and vt.sif_terj in (''LOBR'', ''OPC'', ''POLO'', ''DDV'') then pp.neto + pp.robresti else 0 end, pp.id_tec, @target_date)) as neto_lpod,
		sum(dbo.gfn_Xchange(@id_tec, case when pp.evident = ''*'' and nl.leas_kred = ''L'' and nl.tip_knjizenja = ''2'' and vt.sif_terj in (''LOBR'', ''OPC'', ''POLO'', ''DDV'') then pp.davek else 0 end, pp.id_tec, @target_date)) as fin_davek_lpod
INTO #planp_nezap_ik_ic
FROM dbo.planp pp
INNER JOIN dbo.pogodba p on p.id_cont = pp.id_cont
INNER JOIN dbo.nacini_l nl on nl.nacin_leas = pp.nacin_leas
INNER JOIN dbo.vrst_ter vt on vt.id_terj = pp.id_terj
LEFT JOIN dbo.gv_PEval_LastEvaluation pe ON pe.id_kupca = pp.id_kupca
WHERE pp.dat_zap in (select date_excl_odr from #dates_exclude_odr)
ANd p.status_akt = ''A''
AND left(pe.eval_model, 2) NOT IN (''01'',''20'')
AND nl.nacin_leas not in (select nacin_leas from #exclude_lease_types)
AND  (pp.id_kupca = p.id_kupca)
GROUP BY pp.id_cont, pp.id_kupca

SELECT id_kupca,
		sum(saldo) as saldo,
		sum(neto_lpod) as neto_lpod,
		sum(fin_davek_lpod) as fin_davek_lpod
INTO #planp_nezap_ik
FROM #planp_nezap_ik_ic
GROUP BY id_kupca

-- kandidati, ki izpolnjujejo materialni kriterij - B2 COUNTER
SELECT pds.id_kupca,
		cast(IsNull(pe.eval_model, '''') as varchar(10)) as eval_model,
       sum(dbo.gfn_xchange(@id_tec, pds.znp_saldo_brut_all, pds.id_tec, @target_date)) AS overdue_amount,
       sum(dbo.gfn_xchange(@id_tec, pds.znp_saldo_brut_all + pds.bod_neto_lpod + pds.bod_robresti_lpod + case when nl.leas_kred = ''L'' and nl.tip_knjizenja = ''2'' then pds.bod_davek_LPOD else 0 end, pds.id_tec, @target_date)) AS total_exposure,
       sum(dbo.gfn_xchange(@id_tec, pds.bod_neto_lpod + pds.bod_robresti_lpod + case when nl.leas_kred = ''L'' and nl.tip_knjizenja = ''2'' then pds.bod_davek_LPOD else 0 end, pds.id_tec, @target_date)) AS future_capital,
		cast(null as datetime) as due_start_date,
		''B2'' as dpd_type
INTO #partners_past_due_today
FROM dbo.planp_ds pds
INNER JOIN dbo.pogodba p ON pds.id_cont = p.id_cont
INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = p.nacin_leas
LEFT JOIN dbo.gv_PEval_LastEvaluation pe ON pe.id_kupca = pds.id_kupca
WHERE p.status_akt = ''A''
AND left(pe.eval_model, 2) NOT IN (''01'',''20'')
AND nl.nacin_leas not in (select nacin_leas from #exclude_lease_types)
AND  (pds.id_kupca = p.id_kupca)
GROUP BY pds.id_kupca, pe.eval_model
HAVING sum(dbo.gfn_xchange(@id_tec, pds.znp_saldo_brut_all, pds.id_tec, @target_date)) > @amount_nretail
	   and sum(pds.znp_saldo_brut_all) > @percentage_nretail * sum(pds.bod_neto_lpod + pds.bod_robresti_lpod + case when nl.leas_kred = ''L'' and nl.tip_knjizenja = ''2'' then pds.bod_davek_LPOD else 0 end)

-- vstavimo zapise se za B3 COUNTER
insert into #partners_past_due_today(id_kupca, eval_model, overdue_amount, total_exposure, future_capital, due_start_date, dpd_type)
select id_kupca, eval_model, overdue_amount, total_exposure, future_capital, due_start_date, ''B3'' as dpd_type
from #partners_past_due_today

CREATE INDEX IX_PARTNERS_PAST_DUE_TODAY_IK ON #partners_past_due_today(id_kupca)

-- kandidati, ki izpolnjujejo materialni kriterij, kjer se terjatve iz tabele #planp_nezap_ik ne upostevajo v dolg
SELECT pdt.id_kupca,
		pdt.eval_model,
        pdt.overdue_amount - IsNull(pn.saldo, 0) as overdue_amount,
        pdt.total_exposure - IsNull(pn.saldo, 0) + IsNull(pn.neto_lpod, 0) + IsNull(pn.fin_davek_lpod, 0) as total_exposure,
        pdt.future_capital + IsNull(pn.neto_lpod, 0) + IsNull(pn.fin_davek_lpod, 0) as future_capital,
		case when pdt.overdue_amount > @amount_nretail AND overdue_amount > @percentage_nretail * pdt.future_capital
				then cast(1 as bit)
				else cast(0 as bit)
		end as izpolnjuje_material_kriterij,
		case when pdt.overdue_amount - IsNull(pn.saldo, 0) > @amount_nretail AND (pdt.overdue_amount - IsNull(pn.saldo, 0)) > @percentage_nretail * (pdt.future_capital + IsNull(pn.neto_lpod, 0) + IsNull(pn.fin_davek_lpod, 0))
				then cast(1 as bit)
				else cast(0 as bit)
		end as izpolnjuje_material_kriterij_brez_terjdan,
		dpd_type
INTO #partners_past_due_today_exlude_claims_today_from_debt
FROM #partners_past_due_today pdt
LEFT JOIN #planp_nezap_ik pn on pn.id_kupca = pdt.id_kupca

CREATE INDEX IX_PARTNERS_PAST_DUE_TODAY_EXLUDE_CLAIMS_TODAY_FROM_DEBT_IK ON #partners_past_due_today(id_kupca)


-- zadnji zapis za vsakega partnerja iz st_customer_past_due_production za B2 COUNTER
select a.*
into #partners_past_due_last_b2
from {0}.dbo.st_customer_past_due_production a
inner join (select p.id_kupca, max(p.id) as id
			from {0}.dbo.st_customer_past_due_production p
			inner join (select id_kupca, max(effective_date) as max_effective_date
						from {0}.dbo.st_customer_past_due_production
						where dpd_type = ''B2''
						group by id_kupca) ppdp on p.id_kupca = ppdp.id_kupca and p.effective_date = ppdp.max_effective_date
			where dpd_type = ''B2''
			group by p.id_kupca) b on b.id = a.id

CREATE INDEX IX_PARTNERS_PAST_DUE_LAST_B2_IK ON #partners_past_due_last_b2(id_kupca)

-- zadnji zapis za vsakega partnerja iz st_customer_past_due_production za B3 COUNTER
select a.*
into #partners_past_due_last_b3
from {0}.dbo.st_customer_past_due_production a
inner join (select p.id_kupca, max(p.id) as id
			from {0}.dbo.st_customer_past_due_production p
			inner join (select id_kupca, max(effective_date) as max_effective_date
						from {0}.dbo.st_customer_past_due_production
						where dpd_type = ''B3''
						group by id_kupca) ppdp on p.id_kupca = ppdp.id_kupca and p.effective_date = ppdp.max_effective_date
			where dpd_type = ''B3''
			group by p.id_kupca) b on b.id = a.id

CREATE INDEX IX_PARTNERS_PAST_DUE_LAST_B3_IK ON #partners_past_due_last_b3(id_kupca)


-- partnerji, ki so na novo izpolnili materialni kriterij
select distinct id_kupca, future_capital
into #partners_past_due_new
from #partners_past_due_today
where id_kupca not in (select id_kupca from #partners_past_due_last_b2 where due_end_date is null)
or id_kupca in (select id_kupca from #partners_past_due_today_exlude_claims_today_from_debt where dpd_type = ''B3'' and izpolnjuje_material_kriterij = 1 and izpolnjuje_material_kriterij_brez_terjdan = 0)


-- zadnja placila za kandidate, ki izpolnjujejo materialni kriterij
SELECT l.id_kupca, MAX(l.datum_dok) AS dat_izpisk, MAX(l.id_lsk) as id_lsk_for_payment, MAX(case when l.id_dogodka = ''PLACILO'' then l.datum_dok end) as dat_izpisk_placilo
INTO #placila_tmp_dat_izpiska
FROM dbo.lsk l
INNER JOIN #partners_past_due_today pd on pd.id_kupca = l.id_kupca
WHERE l.id_dogodka in (''PLACILO'', ''PLAC_IZ_AV'')
AND pd.dpd_type = ''B2''
GROUP BY l.id_kupca

CREATE INDEX IX_PLACILA_TMP_DAT_IZPISKA_IK ON #placila_tmp_dat_izpiska(id_kupca)

SELECT pl.id_kupca, MAX(pl.dat_izpisk) as dat_izpisk, MAX(dat_pl) as dat_placila
INTO #placila_tmp_dat_placila
FROM dbo.placila pl
INNER JOIN #placila_tmp_dat_izpiska di on di.id_kupca = pl.id_kupca and di.dat_izpisk_placilo = pl.dat_izpisk
GROUP BY pl.id_kupca

CREATE INDEX IX_PLACILA_TMP_DAT_PLACILA_IK ON #placila_tmp_dat_placila(id_kupca)

SELECT pl.id_kupca, MAX(pl.dat_izpisk) as dat_izpisk, MAX(dat_pl) as dat_placila 
INTO #placila_tmp_dat_placila_b23
FROM dbo.placila pl
WHERE (
	exists (select b.id_kupca from #partners_past_due_last_b2 b where b.id_kupca = pl.id_kupca)
	or exists (select b.id_kupca from #partners_past_due_last_b3 b where b.id_kupca = pl.id_kupca))
GROUP BY pl.id_kupca

CREATE INDEX IX_PLACILA_TMP_DAT_PLACILA_B23_IK ON #placila_tmp_dat_placila_b23(id_kupca)


-- kandidati za katere je potrebno ponovno preracunati due_start_date, ker je prislo novo placilo
SELECT a.id_kupca, c.dat_izpisk, c.id_lsk_for_payment
INTO #candidates_recalculate_dpd
FROM #partners_past_due_today a
INNER JOIN #partners_past_due_last_b2 b ON b.id_kupca = a.id_kupca
INNER JOIN #placila_tmp_dat_izpiska c ON c.id_kupca = b.id_kupca
WHERE a.dpd_type = ''B2''
AND b.last_id_lsk_for_payment < c.id_lsk_for_payment 

CREATE INDEX IX_CANDIDATES_RECALCULATE_DPD_IK ON #candidates_recalculate_dpd(id_kupca)

-- za vse partnerje, ki izpolnjujejo materialni kriterij in za katere je prislo kaksno novo placilo poiscemo datum izpolnitve materialnega kriterija v planu placil
-- to je potrebno, ker se datum izpolnitve materialnega kriterija lahko spremeni, ce partner poplaca terjatev, a se vedno izpolnjuje materialni kriterij
declare @id_kupca char(6), @odr_current decimal(18,2), @saldo decimal(18,2), @dat_zap datetime, @future_capital decimal(18,2), @future_capital_planp decimal(18,2), @is_new bit

DECLARE PART_CRZ CURSOR FAST_FORWARD FOR
SELECT a.id_kupca, a.future_capital, cast(0 as bit) as is_new_customer
FROM #partners_past_due_today a
INNER JOIN #candidates_recalculate_dpd b on b.id_kupca = a.id_kupca
WHERE a.dpd_type = ''B2''
UNION ALL
SELECT a.id_kupca, a.future_capital, cast(1 as bit) as is_new_customer
FROM #partners_past_due_new a

OPEN PART_CRZ
FETCH NEXT FROM PART_CRZ INTO @id_kupca, @future_capital, @is_new
WHILE @@FETCH_STATUS = 0
BEGIN

	SELECT
		sum(dbo.gfn_Xchange(@id_tec, pp.saldo, pp.id_tec, @target_date)) as saldo,
		sum(dbo.gfn_Xchange(@id_tec, case when vt.sif_terj in (''LOBR'', ''OPC'', ''POLO'', ''DDV'') then pp.neto else 0 end, pp.id_tec, @target_date)) AS neto_as_future,
		sum(dbo.gfn_Xchange(@id_tec, case when nl.leas_kred = ''L'' and nl.tip_knjizenja = ''2'' and vt.sif_terj in (''LOBR'', ''OPC'', ''POLO'', ''DDV'') then pp.davek else 0 end, pp.id_tec, @target_date)) AS davek_as_future,
		sum(dbo.gfn_Xchange(@id_tec, case when vt.sif_terj in (''LOBR'', ''OPC'', ''POLO'', ''DDV'') then pp.robresti else 0 end, pp.id_tec, @target_date))AS robresti_as_future,
		pp.dat_zap
	INTO #planp_tmp
	FROM dbo.planp pp
	INNER JOIN dbo.nacini_l nl on nl.nacin_leas = pp.nacin_leas
	INNER JOIN dbo.vrst_ter vt on vt.id_terj = pp.id_terj
	INNER JOIN dbo.pogodba po on po.id_cont = pp.id_cont
	WHERE pp.id_kupca = @id_kupca
	AND po.status_akt = ''A''
	AND pp.saldo <> 0
	AND pp.evident = ''*''
	AND pp.dat_zap <= @target_date
	AND nl.nacin_leas not in (select nacin_leas from #exclude_lease_types)
	GROUP BY pp.dat_zap

	DECLARE CLAIM_CRZ CURSOR FAST_FORWARD FOR
	SELECT saldo, dat_zap
	FROM #planp_tmp
	ORDER BY dat_zap
	
	OPEN CLAIM_CRZ
	
	SET @odr_current = 0
	FETCH NEXT FROM CLAIM_CRZ INTO @saldo, @dat_zap
	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @odr_current = @odr_current + @saldo

		-- zapadle terjatve iz planp z dat_zap > datuma zapadlosti terjatve na kateri stojimo -> pri preverjanju pogoja za NRT jih priostejmo h bodocemu delu iz planp_ds
		set @future_capital_planp = IsNull((select sum(neto_as_future + robresti_as_future + davek_as_future) from #planp_tmp where dat_zap > @dat_zap), 0)
			
		-- update due_start_date samo za B2 counterje za ze obstojece partnerje, kjer je potreben restart counterja
		if @is_new = 0 and @odr_current > @amount_nretail and @odr_current > @percentage_nretail * (@future_capital + @future_capital_planp) begin
			update #partners_past_due_today set due_start_date = @dat_zap where id_kupca = @id_kupca and dpd_type = ''B2''
			break
		end

		-- update due_start_date za oba counterja (B2 in B3) za nove partnejrje, ki so na novo zadovoljili materialni kriterij
		if @is_new = 1 and @odr_current > @amount_nretail and @odr_current > @percentage_nretail * (@future_capital + @future_capital_planp) begin
			update #partners_past_due_today set due_start_date = @dat_zap where id_kupca = @id_kupca
			break
		end

	FETCH NEXT FROM CLAIM_CRZ INTO @saldo, @dat_zap
	END

	CLOSE CLAIM_CRZ
	DEALLOCATE CLAIM_CRZ
	
	drop table #planp_tmp

FETCH NEXT FROM PART_CRZ INTO @id_kupca, @future_capital, @is_new
END

CLOSE PART_CRZ
DEALLOCATE PART_CRZ

-- in case that due_start_date would stay null, but this should never happened
update #partners_past_due_today
set due_start_date = @target_date
from #partners_past_due_today t
inner join #partners_past_due_new n on n.id_kupca = t.id_kupca
where t.due_start_date is null

-- 1.) zakljucimo counterje (samo za B3 DPD counter) za primere, kjer partner na danasnji dan izpolnjuje materialni kriterij, ne izpolnjuje pa materialnega kriterija, ce v dolg ne upostevamo terjatev, ki zapadejo na danasnji dan oz. terjatev, ki zapadejo na nedelovne dneve
INSERT INTO {0}.dbo.st_customer_past_due_production(id_kupca, effective_date, due_start_date, due_end_date, current_days_past_due, total_overdue_amount, total_overdue_cur_code, eval_model, last_dat_plac, future_capital, dpd_type, last_id_lsk_for_payment)
SELECT a.id_kupca,
		@target_date as effective_date,
		c.due_start_date,
		case when b.dat_izpisk is not null and b.dat_izpisk >= c.last_dat_plac then b.dat_placila else @target_date end as due_end_date,
		0 as current_days_past_due,
		0 as total_overdue_amount,
		''EUR'' as total_overdue_cur_code,
		c.eval_model,
		c.last_dat_plac,
		0 as future_capital,
		a.dpd_type,
		c.last_id_lsk_for_payment
FROM #partners_past_due_today_exlude_claims_today_from_debt a
LEFT JOIN #placila_tmp_dat_placila b on b.id_kupca = a.id_kupca
INNER JOIN #partners_past_due_last_b3 c on c.id_kupca = a.id_kupca
WHERE a.dpd_type = ''B3''
AND a.izpolnjuje_material_kriterij = 1 and a.izpolnjuje_material_kriterij_brez_terjdan = 0 -- izpolnjuje kriterij na danasnji dan, ne izpolnjuje kriterija ce odstejemo terjatve zapadle na danasnji dan oz. na nedelovne dneve
AND c.due_end_date is null -- zadnji record se ni zakljucen
AND c.effective_date != @target_date -- zadnji zapis ni bil vnesen danes


-- 2.) ce izpolnjuje materialni kriterij, vstavi zapis za danasnji dan, osnova mu je zapis od prejsnjega dne
INSERT INTO {0}.dbo.st_customer_past_due_production(id_kupca, effective_date, due_start_date, due_end_date, current_days_past_due, total_overdue_amount, total_overdue_cur_code, eval_model, last_dat_plac, future_capital, dpd_type, last_id_lsk_for_payment)
-- B2 COUNTER
SELECT ppd.id_kupca, 
		@target_date as effective_date,
		IsNull(ppd.due_start_date, ppdp.due_start_date) as due_start_date,
		null as due_end_date,
		case when ppd.due_start_date is not null then datediff(dd, ppd.due_start_date, @target_date) + 1 else datediff(dd, ppdp.due_start_date, @target_date) + 1 end as current_days_past_due,
		ppd.overdue_amount as total_overdue_amount,
		''EUR'' as total_overdue_cur_code,
		ppd.eval_model,
		case when ppdp.id_kupca is null then ''19000101''
			 when ppdp.due_end_date is not null then @target_date
			 when cr.id_kupca is not null then cr.dat_izpisk
			 else ppdp.last_dat_plac
		end as last_dat_plac,
		ppd.future_capital as future_capital,
		''B2'' as dpd_type,
		case when ppdp.id_kupca is null then 0
			 when ppdp.due_end_date is not null then 0
			 when cr.id_kupca is not null then cr.id_lsk_for_payment
			 else ppdp.last_id_lsk_for_payment
		end as last_id_lsk_for_payment
FROM #partners_past_due_today ppd
LEFT JOIN #partners_past_due_last_b2 ppdp ON ppdp.id_kupca = ppd.id_kupca
LEFT JOIN #candidates_recalculate_dpd cr ON cr.id_kupca = ppd.id_kupca 
WHERE ppd.dpd_type = ''B2''
AND IsNull(ppdp.effective_date, ''19000101'') != @target_date
UNION ALL
-- B3 COUNTER
SELECT ppd.id_kupca, 
		@target_date as effective_date,
		IsNull(ppd.due_start_date, ppdp.due_start_date) as due_start_date,
		null as due_end_date,
		case when ppd.due_start_date is not null then datediff(dd, ppd.due_start_date, @target_date) + 1 else datediff(dd, ppdp.due_start_date, @target_date) + 1 end as current_days_past_due,
		ppd.overdue_amount as total_overdue_amount,
		''EUR'' as total_overdue_cur_code,
		ppd.eval_model,
		case when ppdp.id_kupca is null then ''19000101''
			 when ppdp.due_end_date is not null then @target_date
			 when cr.id_kupca is not null then cr.dat_izpisk
			 else ppdp.last_dat_plac
		end as last_dat_plac,
		ppd.future_capital as future_capital,
		''B3'' as dpd_type,
		case when ppdp.id_kupca is null then 0
			 when ppdp.due_end_date is not null then 0
			 when cr.id_kupca is not null then cr.id_lsk_for_payment
			 else ppdp.last_id_lsk_for_payment
		end as last_id_lsk_for_payment
FROM #partners_past_due_today ppd
LEFT JOIN #partners_past_due_last_b3 ppdp ON ppdp.id_kupca = ppd.id_kupca
LEFT JOIN #candidates_recalculate_dpd cr ON cr.id_kupca = ppd.id_kupca
WHERE ppd.dpd_type = ''B3''
AND IsNull(ppdp.effective_date, ''19000101'') != @target_date


-- 3.) ce ne izpolnjuje vec materialnega kriterija, vstavimo nov zapis, ki predstavlja zakljucek (upostevamo le zapise z due_end_date is null - pomeni da se niso zakljuceni
INSERT INTO {0}.dbo.st_customer_past_due_production(id_kupca, effective_date, due_start_date, due_end_date, current_days_past_due, total_overdue_amount, total_overdue_cur_code, eval_model, last_dat_plac, future_capital, dpd_type, last_id_lsk_for_payment)
SELECT a.id_kupca,
		@target_date as effective_date,
		a.due_start_date,
		case when b.dat_izpisk is not null and b.dat_izpisk >= a.last_dat_plac then b.dat_placila else @target_date end as due_end_date,
		0 as current_days_past_due,
		0 as total_overdue_amount,
		''EUR'' as total_overdue_cur_code,
		a.eval_model,
		a.last_dat_plac,
		0 as future_capital,
		''B2'' as dpd_type,
		a.last_id_lsk_for_payment
FROM #partners_past_due_last_b2 a
LEFT JOIN #placila_tmp_dat_placila_b23 b on b.id_kupca = a.id_kupca
WHERE a.id_kupca not in (select id_kupca from #partners_past_due_today where dpd_type = ''B2'')
AND a.due_end_date is null
UNION ALL
SELECT a.id_kupca,
		@target_date as effective_date,
		a.due_start_date,
		case when b.dat_izpisk is not null and b.dat_izpisk >= a.last_dat_plac then b.dat_placila else @target_date end as due_end_date,
		0 as current_days_past_due,
		0 as total_overdue_amount,
		''EUR'' as total_overdue_cur_code,
		a.eval_model,
		a.last_dat_plac,
		0 as future_capital,
		''B3'' as dpd_type,
		a.last_id_lsk_for_payment
FROM #partners_past_due_last_b3 a
LEFT JOIN #placila_tmp_dat_placila_b23 b on b.id_kupca = a.id_kupca
WHERE a.id_kupca not in (select id_kupca from #partners_past_due_today where dpd_type = ''B3'')
AND a.due_end_date is null


-- 4.) vstavimo zapise za manjkajoce nedelovne dni (od zadnjega delovnega dne), ker se rutina poganja samo na delovne dneve
INSERT INTO {0}.dbo.st_customer_past_due_production(id_kupca, effective_date, due_start_date, due_end_date, current_days_past_due, total_overdue_amount, total_overdue_cur_code, eval_model, last_dat_plac, future_capital, dpd_type, last_id_lsk_for_payment)
SELECT b.id_kupca, a.date_excl_odr as effective_date, b.due_start_date, b.due_end_date,
		datediff(dd, b.due_start_date, a.date_excl_odr) + 1 as current_days_past_due,
		b.total_overdue_amount, b.total_overdue_cur_code, b.eval_model, b.last_dat_plac, b.future_capital, b.dpd_type, b.last_id_lsk_for_payment
FROM #dates_exclude_odr a, #partners_past_due_last_b2 b
WHERE b.due_end_date is null
AND a.date_excl_odr != @target_date
AND NOT EXISTS (SELECT c.* FROM {0}.dbo.st_customer_past_due_production c WHERE c.effective_date = a.date_excl_odr AND c.id_kupca = b.id_kupca AND c.dpd_type = b.dpd_type)
UNION ALL
SELECT b.id_kupca, a.date_excl_odr as effective_date, b.due_start_date, b.due_end_date,
		datediff(dd, b.due_start_date, a.date_excl_odr) + 1 as current_days_past_due, 
		b.total_overdue_amount, b.total_overdue_cur_code, b.eval_model, b.last_dat_plac, b.future_capital, b.dpd_type, b.last_id_lsk_for_payment
FROM #dates_exclude_odr a, #partners_past_due_last_b3 b
WHERE b.due_end_date is null
AND a.date_excl_odr != @target_date
AND NOT EXISTS (SELECT c.* FROM {0}.dbo.st_customer_past_due_production c WHERE c.effective_date = a.date_excl_odr AND c.id_kupca = b.id_kupca AND c.dpd_type = b.dpd_type)


DROP TABLE #exclude_lease_types
DROP TABLE #dates_exclude_odr
DROP TABLE #planp_nezap_ik_ic
DROP TABLE #planp_nezap_ik
DROP TABLE #partners_past_due_today_exlude_claims_today_from_debt
DROP TABLE #partners_past_due_today
DROP TABLE #partners_past_due_last_b2
DROP TABLE #partners_past_due_last_b3
DROP TABLE #partners_past_due_new
DROP TABLE #placila_tmp_dat_izpiska
DROP TABLE #placila_tmp_dat_placila
DROP TABLE #placila_tmp_dat_placila_b23
DROP TABLE #candidates_recalculate_dpd
'

set @cmd = REPLACE(@cmd, '{0}', @b2rl_db_name)
exec(@cmd)
