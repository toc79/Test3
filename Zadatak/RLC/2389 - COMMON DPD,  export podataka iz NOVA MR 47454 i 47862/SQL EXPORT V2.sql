-- 23.09.2021 g_tomislav MID 47454 - created based on custom report (RM) EBA RL NON RETAIL early warning list ver. (GMI)

declare @session_id varchar(40) = {@session_id}

--first table settings
SELECT 'RLHR_' +cast(dbo.gfn_ConvertDate(getdate(), 12) as char(8)) +'.csv' AS file_name, --yyymmdd
	'false' AS append,
	';' AS delimiter,
	--'string_double_quot_mark' AS string_format,
	'format_dd_mm_yyyy' AS datetime_format,
	'fstrategy_ui' AS decimal_format,
	'false' AS is_header 
FROM dbo.nastavit


declare @target_id_tec char(3) = '000'
declare @target_date datetime = (select dbo.gfn_GetDatePart(getdate()))
declare @sif_d_event varchar(3) = 'EBS'
declare @today_start datetime, @today_end datetime
SET @today_start = @target_date --dbo.gfn_GetDatePart(getdate())
SET @today_end = dateadd(ms, -3, dateadd(dd, 1, @today_start))

select par.ext_id as coconut
	, isnull(sum(znp_saldo_brut_all), 0) as znp_saldo_brut_all
	, isnull(sum(risk_exposure), 0) as risk_exposure
	, CAST(isnull(sum(risk_exposure), 0) * 0.01 AS DECIMAL(18,2)) as risk_exposure_1_percent
	, isnull(dpd_counter, 0) as dpd_counter
	, s1.naz_kr_kup as skrbnik_1_naziv
	--, cast((select doc_id from dbo.xdoc_document_tmp where session_id = @session_id) as varchar(40)) as doc_id
from dbo.partner par
left join (
		SELECT pp.id_kupca 
			-- risk exposure (total ODR + future capital total + all booked not dued clims)
			, sum(dbo.gfn_xchange(@target_id_tec, pp.znp_saldo_brut_all
											+ pp.poknj_nezap_debit_brut_ALL
											+ pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod
											+ pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod
											+ case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' and nl.ol_na_nacin_fl = 0 then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end, pp.id_tec, @target_date)) 
										as risk_exposure
			, sum(dbo.gfn_xchange(@target_id_tec,pp.znp_saldo_brut_all, pp.id_tec, @target_date)) as znp_saldo_brut_all
		FROM dbo.planp_ds pp
		INNER JOIN dbo.pogodba p ON p.id_cont = pp.id_cont
		INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = p.nacin_leas
		WHERE 1=1
		--and (pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' and nl.ol_na_nacin_fl = 0 then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end) > 0
		AND p.status_akt = 'A'
		--AND nl.nacin_leas not in (select nacin_leas from #exclude_lease_types)
		GROUP BY pp.id_kupca 
	) a  on a.id_kupca = par.id_kupca
left join (select id_kupca 
				, datediff(d, def_start_date, @target_date) as dpd_counter
			from default_events 
			where id_d_event in (select id_d_event from dbo.default_events_register where sif_d_event = @sif_d_event)
			and (def_end_date is null or def_end_date is not null and def_end_date between @today_start and @today_end)
	) def_ev on def_ev.id_kupca = par.id_kupca --to je kao where and isnull(dpd_counter, 0) > 0
left join dbo.partner s1 on par.skrbnik_1 = s1.id_kupca
where not exists (select * from dbo.gv_PEval_LastEvaluation where left(eval_model,2) in ('01','20') and id_kupca = par.id_kupca) 
and par.ext_id != '' 
and exists (select * from dbo.pogodba where status_akt = 'A' and id_kupca = par.id_kupca) -- planp_ds ne sadrži sve aktivne ugovore 
group by par.ext_id, dpd_counter, s1.naz_kr_kup
order by coconut