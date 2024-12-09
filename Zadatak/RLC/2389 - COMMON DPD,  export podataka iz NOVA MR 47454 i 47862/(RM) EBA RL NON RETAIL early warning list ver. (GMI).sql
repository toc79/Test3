--Porocilo za default evente NON RETAIL
-- 14.10.2008 VG : poročilo je v celoti prenovljano in se pripravlja glede na dogodke DCR in DCN v default events modulu
-- 		za poročilo je relevanten aktiven dogodek DCR-DPD counter start-retail, ki pove kdaj je klient izpolnil materialni kriterij
-- 13.05.2011 Ziga; MID 29389 - iz stolpca future_capital_total izkljucena poknjizena nezapadla glavnica, dodan nov stolpec, ki predstavlja znesek vseh poknjizenih nezapadlih terjatev
-- 13.05.2011 Ziga; MID 29389 - stolpec total_exposure preimenovan v risk_exposure, v risk_exposure je vkljucen znesek vseh pokjizenih nezapadloh terjatev
-- 16.04.2013 Ziga; MID 39822 - pri izracunu exposure-a se sedaj upostevajo samo aktivne pogodbe
-- 10.04.2014 Ziga; MID 43841 - added support for two DPD counters and field tlc_2_5_perc
-- 10.04.2014 Ziga; MID 43841 - repaired calculation of fields future_capital and risk_exposure
-- 12.05.2014 Ziga; MID 43841 - added new criteria for excluding partners in default
-- 11.11.2014 Ziga; MID 47635 - added support for PPMV
-- 30.10.2015 Ziga; MID 53714 - added possibility to exclude certain lease types
-- 22.01.2018 Jadranka; MID 71271 - modifications because of new leas type Hibrid - nl.tip_knjizenja = 2 and nl.ol_na_nacin_fl = 1
-- 03.06.2019 Jadranka; MID 80421 - change due to new EBA methodology 
-- 03.06.2019 Jadranka; MID 80421 - change due to new EBA methodology (poslednjoj koloni stoji 2.5% TLC a treba da se izračuna 1% Exposure-a.) 

/*
znp_saldo_brut_all	ODR_total
risk_exposure	Risk exposure
DPD_counter	DPD_counter

*/


DECLARE @target_id_tec char(3)
DECLARE @target_id_val char(3)
DECLARE @zero decimal(18,2)
DECLARE @target_tecaj decimal(10,6)
DECLARE @early_warning_days decimal(5,0)
DECLARE @EUR_id_tec char(3)
DECLARE @sif_d_event char(3)
DECLARE @exclude_partners_in_default bit
DECLARE @target_date datetime, @company_id char(5)

DECLARE @today_start datetime, @today_end datetime
SET @today_start = dbo.gfn_GetDatePart(getdate())
SET @today_end = dateadd(ms, -3, dateadd(dd, 1, @today_start))

SET @target_date=getdate()

SET @target_id_tec= {1}
SET @target_id_val=(select id_val from dbo.tecajnic where id_tec=@target_id_tec) 

SET @early_warning_days = {5} --90

SET @sif_d_event = {7}
SET @exclude_partners_in_default = {8}


SET @eur_id_tec=(select min(id_tec) from dbo.tecajnic where id_val='EUR') 
SET @company_id = (select entity_name FROM dbo.loc_nast)
SET @zero = 0

-- exclude fin types
select id_key as nacin_leas
into #exclude_lease_types
from dbo.gfn_g_register_active('RL_REGION_EXCLUDE_LEASE_TYPES', null)

select a.*,isnull(c.value,'') as eval_model_desc, left(a.eval_model,2) as real_eval_model,
right(rtrim(eval_model),1) as gams_flag 
into #tmp_p_eval
from dbo.gv_p_eval a
left join general_register c on a.eval_model=c.id_key  
where dat_eval in (select max(dat_eval) from dbo.gv_p_eval b where b.eval_type='E' and b.id_kupca = a.id_kupca)
and c.id_register='ev_model'  
order by id_kupca

select a.id_kupca,
sum(dbo.gfn_xchange(@target_id_tec, a.saldo, a.id_tec, @target_date)) as znpl_all,
ev.real_eval_model as eval_model
into #partner_znpl
from dbo.planp a 
inner join dbo.pogodba b on a.id_cont=b.id_cont
inner join dbo.partner c on a.id_kupca=c.id_kupca
inner join dbo.nacini_l nl on nl.nacin_leas = b.nacin_leas
left join #tmp_p_eval ev on a.id_kupca=ev.id_kupca
where a.saldo > 0 and a.evident='*' and a.dat_zap<=@target_date
and b.status_akt='A' 
and ev.real_eval_model not in ('01','20')
and nl.nacin_leas not in (select nacin_leas from #exclude_lease_types)
group by a.id_kupca,ev.real_eval_model having sum(a.saldo) > 0

-- sedaj kreiramo rezultat

SELECT 
p.id_kupca as Partner_id,
c.naz_kr_kup as Partner,
c.ext_id as Coconut_id,
c.skrbnik_1,c.skrbnik_2,p.eval_model,
c.asset_clas as Asset_class,
/*case when c.asset_clas in ('OR/SME' , 'ORET') then 'Y' else 'N' end as is_retail,*/
case when p.eval_model in ('01','20') then 'Y' else 'N' end as is_retail,
a.znp_saldo_brut_all,
a.Open_inst_neto,
a.Open_inst_robresti,
a.Open_inst_tax,
a.odr_interests,
a.future_capital,
a.booked_not_dued_debit_all,
a.booked_not_dued_capital,
a.risk_exposure,
round (0.01 * a.risk_exposure,2) as tlc_2_5_perc,
a.Maturity_of_oldest_claim,
def_ev.dpd_counter as dpd_counter,
@target_id_val as target_id_val
FROM 
#partner_znpl p
inner join 
(
	SELECT pp.id_kupca,
	sum(dbo.gfn_xchange(@target_id_tec, pp.znp_neto_lpod + pp.bod_neto_lpod, pp.id_tec, getdate())) as Open_inst_neto,
	sum(dbo.gfn_xchange(@target_id_tec, pp.znp_robresti_lpod + pp.bod_robresti_lpod, pp.id_tec, getdate())) as Open_inst_robresti,
	sum(dbo.gfn_xchange(@target_id_tec, pp.znp_davek_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' and nl.ol_na_nacin_fl = 0 then pp.bod_davek_LPOD else 0 end, pp.id_tec, getdate())) Open_inst_tax,
	sum(dbo.gfn_xchange(@target_id_tec, pp.znp_obresti_lpod, pp.id_tec, getdate())) as odr_interests,
	
	-- future capital (bodoca glavnica + bodoči financiran davek za financni lizing)
	sum(dbo.gfn_xchange(@target_id_tec, (pp.bod_neto_lpod + pp.bod_robresti_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' and nl.ol_na_nacin_fl = 0 then pp.bod_davek_LPOD else 0 end), pp.id_tec, getdate())) as future_capital,
	
	-- all booked not dued claims (debit)
	sum(dbo.gfn_xchange(@target_id_tec, pp.poknj_nezap_debit_brut_ALL, pp.id_tec, getdate())) as booked_not_dued_debit_all,
	
	-- booked not dued capital + robresti (glavnica + PPMV)
	sum(dbo.gfn_xchange(@target_id_tec, pp.poknj_nezap_neto_lpod + pp.poknj_nezap_robresti_lpod, pp.id_tec, getdate())) as booked_not_dued_capital,
	
	-- risk exposure (total ODR + future capital total + all booked not dued clims)
	sum(dbo.gfn_xchange(@target_id_tec, pp.znp_saldo_brut_all
										+ pp.poknj_nezap_debit_brut_ALL
										+ pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod
										+ pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod
										+ case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' and nl.ol_na_nacin_fl = 0 then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end, pp.id_tec, getdate())) as risk_exposure,
	
	-- 2.5% od TLC
	round(0.025 * sum(dbo.gfn_xchange(@target_id_tec, (pp.bod_neto_lpod + pp.bod_robresti_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' and nl.ol_na_nacin_fl = 0 then pp.bod_davek_LPOD else 0 end), pp.id_tec, getdate())), 2) as tlc_2_5_perc,
	
	max(pp.znp_max_dni_all) as Maturity_of_oldest_claim,
	sum(dbo.gfn_xchange(@target_id_tec,pp.znp_saldo_brut_all, pp.id_tec, getdate())) as znp_saldo_brut_all
	FROM dbo.planp_ds pp
	INNER JOIN dbo.pogodba p ON p.id_cont = pp.id_cont
	INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = p.nacin_leas
	WHERE (pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' and nl.ol_na_nacin_fl = 0 then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end) > 0
	AND p.status_akt = 'A'
	AND nl.nacin_leas not in (select nacin_leas from #exclude_lease_types)
	GROUP BY pp.id_kupca 
) a  on a.id_kupca = p.id_kupca
INNER JOIN (select def_start_date,datediff(d,def_start_date,getdate()) as dpd_counter,id_kupca from default_events where id_d_event in 
		(select id_d_event from default_events_register where sif_d_event=@sif_d_event)
		and (def_end_date is null or def_end_date is not null and def_end_date between @today_start and @today_end)
		) def_ev on def_ev.id_kupca=p.id_kupca
INNER JOIN partner c on c.id_kupca=p.id_kupca
WHERE def_ev.dpd_counter >= @early_warning_days
AND (@exclude_partners_in_default = 0
	 OR NOT EXISTS (select a.*
					from dbo.default_events a
					inner join dbo.default_events_register b on b.id_d_event = a.id_d_event
					where a.id_kupca = p.id_kupca
					and a.def_end_date is null
					and b.sif_d_event = 'MSN'))

drop table #exclude_lease_types
drop table #partner_znpl
drop table #tmp_p_eval