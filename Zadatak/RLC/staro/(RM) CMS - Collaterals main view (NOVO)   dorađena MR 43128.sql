-- TO DO:
-- zamenjaj join pri tabelah nep_enot in neprem + prefixi baz na tabelah + #tip_nepremicnine in #neprem_regije_detail
-- zamenjaj monica pri dbo.regije
-- 29.03.2018 GMC Branislav; MID 40181 - replace usage gv_PEval_LastEvaluation, gv_p_eval with function gfn_PEval_LastEvaluationOnTargetDate
-- 09.08.2019 g_tomislav MR 43128 - replaced cast(d.stevilka as int) for bigint


declare @id_oc_report int, @id_oc_report_previous int, @target_date datetime, @target_date_previous datetime, @exposure_type varchar(10), @id_tec_prod_eur char(3), @company_id varchar(10), @id_kupca_rl char(6), @only_fl bit ,
@na char(1)
set @id_oc_report = {1}
set @id_oc_report_previous = {3}
set @na = ''
set @target_date = (select date_to from dbo.oc_reports where id_oc_report = @id_oc_report)
set @target_date_previous = (select date_to from dbo.oc_reports where id_oc_report = @id_oc_report_previous)
set @only_fl = {4}
set @exposure_type = 'B2'
set @exposure_type = 'B2'
set @company_id = (select entity_name from dbo.loc_nast where id_oc_report = @id_oc_report)
set @id_tec_prod_eur = (case when @company_id = 'RLHR' then '006' when @company_id in ('RLBH','RLRS','RRRS') then '001' else '000' end)
set @id_kupca_rl = (select value from dbo.general_register where id_oc_report = @id_oc_report and id_register = 'RL_ID_KUPCA' and id_key = @company_id)

declare @id_poste_sed_rl varchar(15), @mesto_sed_rl varchar(200), @naz_kr_kup_rl varchar(300)

select @id_poste_sed_rl = id_poste_sed, @mesto_sed_rl = mesto_sed, @naz_kr_kup_rl = naz_kr_kup
from dbo.oc_customers 
where id_oc_report = @id_oc_report and id_kupca = @id_kupca_rl

-- Exposure
create table #exposure([null] int)
exec [dbo].[grp_RaiffRegion_Exposure] @id_oc_report, '#exposure'
create index ix_exposure_id_oc_report_id_cont on #exposure (id_oc_report, id_cont)

-- Exposure previous snapshot
create table #exposure_prev([null] int)
exec [dbo].[grp_RaiffRegion_Exposure] @id_oc_report_previous, '#exposure_prev'
	

-- collaterals wcv
create table #collaterals_wcv([null] int)
create table #collaterals_insurances([null] int)
create table #collaterals_undelivered([null] int)
exec dbo.grp_RaiffRegion_Collateral @id_oc_report, null, @only_fl, '#collaterals_wcv', '#collaterals_insurances', '#collaterals_undelivered'
create index ix_collaterals_wcv_collateral_id on #collaterals_wcv (id_oc_report, collateral_id)
create index ix_collaterals_wcv_id_dokum on #collaterals_wcv (id_oc_report, id_dokum)
create index ix_collaterals_insurances_collateral_id on #collaterals_insurances (id_oc_report, collateral_id)


-- partner last evaluation
select @id_oc_report as id_oc_report, id_kupca, cust_ratin, coll_ratin, eval_model, kategorija4
into #last_partner_evaluation
from dbo.gfn_PEval_LastEvaluationOnTargetDate (@target_date, @id_oc_report, NULL)
create index ix_last_partner_evaluation_id_kupca on #last_partner_evaluation (id_oc_report, id_kupca)

select ci.id_oc_report, ci.collateral_id, min(ci.velja_do) as insurance_min_velja_do,
		sum(dbo.gfn_Xchange(@id_tec_prod_eur, ci.vrednost, ci.id_tec, @target_date, @id_oc_report)) as ins_vrednost_eur,
		sum(dbo.gfn_Xchange(@id_tec_prod_eur, ci.ocen_vred, ci.id_tec, @target_date, @id_oc_report)) as ins_ocen_vred_eur,
		max(di.stevilka) as stevilka_insurance,
		max(di.opis) as insurence_desc,
		max(IsNull(za.naziv, '')) as naziv_zav_insurance,
		max(cast(di.ima as int)) as insurance_ima,
		max(di.kategorija2) as insurance_kategorija2,
		max(di.status_akt) as insurance_status_akt,
		min(di.zacetek) as insurance_zacetek, 
		max(dbo.gfn_Xchange(@id_tec_prod_eur, ci.vrednost, ci.id_tec, @target_date, @id_oc_report)) as ins_vrednost_eur_max,
		max(dbo.gfn_Xchange(@id_tec_prod_eur, ci.ocen_vred, ci.id_tec, @target_date, @id_oc_report)) as ins_ocen_vred_eur_max,
		max('INS_' + cast(ci.id_dokum as varchar(20))) as INSURANCE_ID,				
		max(case substring(pz.id_poste_sed,0,3) when 'XX' then @na when 'EU' then @na when 'B1' then 'BA' when 'B2' then 'BA' when 'CS' then 'RS' else substring(pz.id_poste_sed,0,3) end) as insurance_country,
		max(za.ID_KUPCA) as id_kupca_ins, 
		max(pe.cust_ratin) as insc_rat,
		max(pe.kategorija4) as rating_agency,		
		max(pz.ext_id) as cocunut_id_ins
into #collaterals_insurances_min_dates
from #collaterals_insurances ci
left join dbo.dokument di on di.id_oc_report = ci.id_oc_report and di.id_dokum = ci.id_dokum
left join dbo.zavarova za on za.id_oc_report = di.id_oc_report and za.id_zav = di.id_zav
left join #last_partner_evaluation pe on pe.id_oc_report = za.ID_OC_REPORT and za.ID_KUPCA = pe.id_kupca
left join dbo.oc_customers pz on pz.ID_OC_REPORT = za.ID_OC_REPORT and pz.id_kupca = za.id_kupca
group by ci.id_oc_report, ci.collateral_id


-- collaterals wcv previous snapshot
create table #collaterals_wcv_prev([null] int)
create table #collaterals_insurances_prev([null] int)
exec dbo.grp_RaiffRegion_Collateral @id_oc_report_previous, null, 0, '#collaterals_wcv_prev', '#collaterals_insurances_prev'
create index ix_collaterals_wcv_prev_collateral_id on #collaterals_wcv_prev (id_oc_report, collateral_id)


-- collaterals allocations
create table #collaterals_alloc([null] int)
exec dbo.grp_RaiffRegion_Allocation @id_oc_report, null, @exposure_type, 0, '#collaterals_alloc'
create index ix_collaterals_alloc_collateral_id on #collaterals_alloc (collateral_id)

-- collaterals allocations previous snapshot
create table #collaterals_alloc_prev([null] int)
exec dbo.grp_RaiffRegion_Allocation @id_oc_report_previous, null, @exposure_type, 0, '#collaterals_alloc_prev'
create index ix_collaterals_alloc_prev_collateral_id on #collaterals_alloc_prev (collateral_id)


-- PROPERTY LOCATION
select id_key, value, val_char
into #property_location
from dbo.general_register
where id_oc_report = @id_oc_report
and id_register = 'NEPREM_KATEG1'
create index ix_property_location_id_key on #property_location(id_key)


select id_oc_report, id_key, left(value, 230) as value, val_char
into #appraisers
from dbo.GENERAL_REGISTER
where id_oc_report = @id_oc_report
and id_register = 'OCEN_VRED_TIP'
--create index ix_appraisers_val_char on #appraisers(val_char)

-- APPREISER TYPE
select id_key, value, val_char
into #appraiser_type
from dbo.general_register
where id_oc_report = @id_oc_report
and id_register = 'OCEN_VRED_TIP_APPR_TYPE'

select id_oc_report, id_key, left(value, 230) as value, val_char
into #kind_of_recovery
from dbo.GENERAL_REGISTER
where id_oc_report = @id_oc_report
and id_register = 'DOK_KATEGORIJA2'
create index ix_kind_of_recovery_id_key on #kind_of_recovery(id_oc_report, id_key)


-- APPRAISAL METHOD
select id_key, value, val_char
into #appraisal_method
from dbo.general_register
where id_oc_report = @id_oc_report
and id_register = 'DOK_KATEGORIJA3'
create index ix_appraisal_method_id_key on #appraisal_method(id_key)

-- real estate
select id_oc_report, id_key, left(value, 230) as value, val_char
into #tip_nepremicnine
from dbo.GENERAL_REGISTER
where id_oc_report = @id_oc_report
and id_register = 'TIP_NEPREMICNINE'
create index ix_tip_nepremicnine on #tip_nepremicnine(id_oc_report, id_key)

-- real estate region
select id_oc_report, id_key, left(value, 230) as value, val_char
into #neprem_regije_detail
from dbo.GENERAL_REGISTER
where id_oc_report = @id_oc_report
and id_register = 'STATISTICNE_REGIJE'
and @company_id = 'RLHR'
union all 
select id_oc_report, id_key, left(value, 230) as value, val_char
from dbo.GENERAL_REGISTER
where id_oc_report = @id_oc_report
and id_register = 'NEPREM_KATEG2'
and @company_id != 'RLHR'
create index ix_neprem_regije_detail on #neprem_regije_detail(id_oc_report, id_key)


-- B2COLLAT
create table #b2collat([null] int)
exec dbo.grp_RaiffRegion_B2Collat '#b2collat'
create index ix_b2collat on #b2collat(id_obl_zav, id_hipot)

-- B2OPPROD
create table #b2opprod([null] int)
exec dbo.grp_RaiffRegion_B2Opprod '#b2opprod'
create index ix_b2opprod on #b2opprod(id_vrste)

-- ZAP_REG data
select co.id_oc_report, co.id_cont, max(zr.id_zapo) as max_id_zapo
into #zap_reg_tmp1
from dbo.oc_contracts co
inner join dbo.zap_reg zr on co.id_oc_report = zr.id_oc_report and co.id_cont = zr.id_cont
where co.id_oc_report = @id_oc_report and (co.status_akt = 'A' or (co.status_akt = 'Z' and co.dat_zakl >= @target_date))
group by co.id_cont, co.id_oc_report

create index ix_zap_reg_id_zapo on #zap_reg_tmp1 ( max_id_zapo)

select zr.id_cont, rtrim(ltrim(zr.znamka)) as znamka, rtrim(ltrim(zr.tip)) as tip, zr.id_dob, rtrim(ltrim(zr.vrsta)) as vrsta,
		rtrim(ltrim(dob.naz_kr_kup)) as naz_kr_kup,
		rtrim(ltrim(dob.ulica_sed)) + ', ' + rtrim(ltrim(dob.mesto_sed)) + ', ' + rtrim(ltrim(dob.id_poste_sed)) + ' ' + rtrim(ltrim(pos.naziv)) + ', ' + rtrim(ltrim(drz.DRZAVA)) as dealer_address
into #zap_reg_tmp
from #zap_reg_tmp1 zt
inner join dbo.ZAP_REG zr on zt.id_oc_report = zr.id_oc_report and zr.id_zapo = zt.max_id_zapo
inner join dbo.oc_customers dob on zr.id_oc_report = dob.id_oc_report and dob.id_kupca = zr.id_dob
inner join dbo.poste pos on dob.id_oc_report = pos.id_oc_report and pos.id_poste = dob.id_poste
inner join dbo.drzave drz on drz.id_oc_report = pos.id_oc_report and drz.drzava = pos.drzava



create index ix_zap_reg_tmp on #zap_reg_tmp (id_cont)

-- MAX_DAT_ZAP for single contract
select co.id_oc_report, co.id_cont, co.ex_max_dat_zap as contract_expiry_date
into #contract_max_dat_zap
from dbo.oc_contracts co
where co.id_oc_report = @id_oc_report
and co.status_akt = 'A'
create index ix_contract_candidates_id_cont on #contract_max_dat_zap(id_oc_report, id_cont)

select a.id_oc_report, a.id_cont,
		sum(case when w.collateral_type_b2 != '9' then wcv_eur else 0 end) as wcv_eur_sum,
		sum(case when w.collateral_type_b2 = '9' then wcv_eur else 0 end) as wgv_eur_sum
into #collaterals_alloc_by_contract
from #collaterals_alloc a
inner join #collaterals_wcv w on w.id_oc_report = a.id_oc_report and w.collateral_id = a.collateral_id
where a.id_oc_report = @id_oc_report
group by a.id_oc_report, a.id_cont
create index ix_collaterals_alloc_by_contract_id_cont on #collaterals_alloc (id_oc_report, id_cont)


select id_oc_report, id_key, left(value, 230) as value
into #partner_status
from dbo.general_register
where id_oc_report = @id_oc_report
and id_register = 'p_status'
create index ix_partner_status_id_key on #partner_status (id_oc_report, id_key)

select id_oc_report, id_key, left(value, 230) as value
into #allocation_types
from dbo.general_register
where id_oc_report = @id_oc_report
and id_register = 'DOK_KATEGORIJA4'

-- CENTRAL REPORT FOR COLLATERALS
select  po.id_cont as id_cont,
		po.id_pog as id_pog,
		po.id_kupca as id_kupca,
		pa.ext_id as ext_id ,
		pa.naz_kr_kup naz_kr_kup,
		pstc.drzava as drzava_part_cont,
		pa.vr_osebe as vr_osebe,
		pe.eval_model as eval_model,
		pa.p_status as p_status,
		ps.value as p_status_desc ,
		po.status_akt as status_akt,
		po.dat_aktiv as dat_aktiv,
		po.pred_naj as contract_desc,
		nl.nacin_leas as nacin_leas,
		po.status as status,
		po.aneks as aneks,
		cmd.contract_expiry_date as contract_expiry_date,
		case when nl.leas_kred = 'K'
				then 'LO'
			 when nl.tip_knjizenja = '2' or dbo.gfn_RaiffRegion_ol2fl(@company_id, nl.tip_knjizenja, po.dat_aktiv, nl.nacin_leas, po.aneks, po.id_cont) = 1
				then 'FL'
				else 'OL'
		end as b2_leasing_type,
		cw.collateral_type_b2_desc as collateral_type_b2_desc,
		case when cw.collateral_type_internal = 'PON' and cw.collateral_subtype_internal in ('', 'TV', 'RA', 'RE')
				then po.pred_naj
				else d.opis
		end as coll_desc,
		cw.collateral_type_b2,
		case when cw.collateral_type_b2 = '10' then 'RRE' when cw.collateral_type_b2 = '14' then 'CRE' else '' end as real_estate_indicator,
		case when cw.collateral_type_b2 = '12'
				then 'OPC'
			 when cw.collateral_type_b2 = '0'
				then 'CSH'
			 when cw.collateral_type_b2 = '9'
				then 'GUA'
			 when cw.collateral_type_b2 = '10'
				then 'RRE'
			 when cw.collateral_type_b2 = '14'
				then 'CRE'
			 when cw.collateral_type_b2 = '13'
				then 'LINS'
			 when cw.collateral_type_b2 = '11'
				then 'RECEIVABLES'
			 when cw.collateral_subtype_internal = 'RE' and cw.collateral_type_b2 = ''
				then 'RRE/CRE'
			 else
				'UNKNOWN'
		end as collateral_type_report,
		cw.collateral_is_ownership,
		case when cw.collateral_type_internal = 'PON' and cw.collateral_subtype_internal = 'TV' then 'TV' else '' end as takeover,
		-- collateral owner
		cw.id_kupca_coll_ow,
		pacoll_ow.ext_id as ext_id_coll_ow,
		pacoll_ow.naz_kr_kup as naz_kr_kup_coll_ow,
		pacoll_ow.vr_osebe as vr_osebe_coll_ow,
		pacoll_ow.p_status as p_status_coll_ow,
		pscoll_ow.value as p_status_desc_coll_ow,
		-- collateral object
		cw.id_kupca_coll,
		pacoll.ext_id as ext_id_coll,
		pacoll.naz_kr_kup as naz_kr_kup_coll,
		pacoll.vr_osebe as vr_osebe_coll,
		pacoll.p_status as p_status_coll,
		pscoll.value as p_status_desc_coll,
		case when @company_id in ('RLRS','RRRS')
				then
					pa_skr.id_poste_sed
				else
					pacoll.id_poste_sed
		end as id_poste_sed,
		case when @company_id in ('RLRS','RRRS')
				then
					pst_skr.naziv
				else
					pst.naziv
		end as naziv_poste,
		case when @company_id in ('RLRS','RRRS')
				then IsNull(pst_skr.drzava, 'NEDEFINIRANO')
			 when @company_id = 'RLHR'
				then pst.drzava
			 when @company_id = 'RLSI'
				then pst.drzava
			 else
				case when @company_id = 'RLBH' and pst.drzava in ('B1','B2','BA') then 'BA' else pst.drzava end
		end as drzava,
		case when @company_id in ('RLRS','RRRS')
				then IsNull(reg_skr.naziv, 'NEDEFINIRANO')
			 when @company_id = 'RLHR'
				then (case when pst.drzava = 'HR' then IsNull(reg.naziv, 'NEDEFINIRANO') else drz.ime end)
			 when @company_id = 'RLSI'
				then case when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 1 then 'Notranjska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 2 then 'Koroško-podravska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 3 then 'Savinjska-posavska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 4 then 'Gorenjska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 5 then 'Severno primorska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 6 then 'Primorska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 8 then 'Dolenjska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 9 then 'Prekmurska regija'
						  when pst.drzava != 'SI' then drz.ime
					 end
			 else
				(case when @company_id = 'RLBH' and pst.drzava in ('B1','B2','BA') then drz.ime else IsNull(reg.naziv, 'NEDEFINIRANO') end)
		end as naziv_reg,
		case when cw.collateral_subtype_internal != 'RA' then pecoll.eval_model else rl_pecoll.eval_model end as eval_model_coll,
		case when cw.collateral_subtype_internal != 'RA' then pecoll.cust_ratin else rl_pecoll.cust_ratin end as cust_ratin,
		case when cw.collateral_subtype_internal != 'RA' then pecoll.coll_ratin else rl_pecoll.coll_ratin end as coll_ratin,
		case when cw.is_krov_dok = 0 then r.naziv else null end as naziv_ref,
		pa_skr.naz_kr_kup as skrbnik1_naziv,
		d.id_dokum,
		d.id_obl_zav,
		d.d_vrednot,
		cw.collateral_id, -- TO DO za cenitve (novo polje dokument.additional_id)
		case when cw.collateral_type_internal = 'PON' then @target_date else cw.last_appraisal_date end as last_appraisal_date,
		cw.last_appraisal_date as contract_reval_date,
		case when cw.collateral_type_internal = 'PON' then null else d.dat_ocene end as appr_valuation_date,
		case when cw.collateral_type_internal = 'PON' and cw.collateral_subtype_internal in ('', 'TV')
				then 'System generated'
			 else ap.value
		end as last_appraiser,
		paappr.id_kupca as id_kupca_appraiser,
		paappr.naz_kr_kup as naz_kr_kup_appraiser,
		case when cw.collateral_type_b2 = '12' then 'N' else CASE WHEN d.is_elligible = 1 THEN 'Y' ELSE 'N' END end as is_elligible,
		cw.expiry_date as collateral_expiry_date,
		datediff(dd, cmd.contract_expiry_date, cw.expiry_date) as coll_ex_date_contr_ex_date, 
		case when cmd.contract_expiry_date <= cw.expiry_date
				then 'Contract expiry date'
				else 'Collateral expiry date'
		end as earliest_expiry_of_secured_deals,
		case when cmd.contract_expiry_date >= cw.expiry_date
				then 'Contract expiry date'
				else 'Collateral expiry date'
		end as latest_expiry_of_secured_deals,
		cw.ponder * 100 as ponder,
		cw.hx_rate * 100 hx_rate,
		case when cw.collateral_type_b2 = '12'
				then round((cw.ponder * 100) * (1 - cw.hx_rate), 2)
				else cw.ponder * 100
		end as ponder_with_hx,
		cw.id_tec as id_tec_collat,
		tcoll.id_val as id_val_collat,
		cw.fair_market_value as fair_market_value_val,
		dbo.gfn_Xchange(@id_tec_prod_eur, cw.fair_market_value, cw.id_tec, @target_date, @id_oc_report) as fair_market_value_eur,
		dbo.gfn_Xchange(@id_tec_prod_eur, cw.nominal_value, cw.id_tec, @target_date, @id_oc_report) as nominal_value_eur,
		cw.nominal_value as nominal_value_val,
		cw.prior_claims_amount as prior_claims_amount_val,
		dbo.gfn_Xchange(@id_tec_prod_eur, cw.prior_claims_amount, cw.id_tec, @target_date, @id_oc_report) as prior_claims_amount_eur,
		case when cw.collateral_type_b2 != '9' then cw.wcov else 0 end as wcov_val,
		case when cw.collateral_type_b2 != '9' then dbo.gfn_Xchange(@id_tec_prod_eur, cw.wcov, cw.id_tec, @target_date, @id_oc_report) else 0 end as wcov_eur,
		case when cw.collateral_type_b2 = '9' then cw.wcov else 0 end as wgov_val,
		case when cw.collateral_type_b2 = '9' then dbo.gfn_Xchange(@id_tec_prod_eur, cw.wcov, cw.id_tec, @target_date, @id_oc_report) else 0 end as wgov_eur,
		-- ALOKACIJA
		case when atpy.ID_KEY is not null then atpy.VALUE else '' end as allocation_type,
		cw.collateral_type_rank,
		cw.collateral_rank as coll_property_or_object_rank,
		ca.collateral_rank,
		ca.object_rank as cont_object_rank,
		ca.cont_rank,
		IsNull(ca.alloc_percentage, 100.00) as alloc_percentage,
		dbo.gfn_Xchange(@id_tec_prod_eur, cw.wcov, cw.id_tec, @target_date, @id_oc_report) * (IsNull(ca.alloc_percentage, 100.00) / 100.00) as allocation_no_fx_eur,
		100 - (ca.fx_discount * 100) as fx_discount,
		100 - (cw.discount_for_mortages * 100) as discount_for_mortages,
		case when cw.collateral_type_b2 != '9' then ca.wcv_eur else 0 end as wcv_eur,
		case when cw.collateral_type_b2 = '9' then ca.wcv_eur else 0 end as wgv_eur,
		cabc.wcv_eur_sum as sum_of_allocated_wcv,
		cabc.wgv_eur_sum as sum_of_allocated_wgv,
		dbo.gfn_Xchange(@id_tec_prod_eur, dbo.gfn_VrValToNetoInternal(po.net_nal_zac, po.robresti_zac, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto), po.id_tec, po.dat_aktiv, @id_oc_report) as net_nal_zac_eur,
		IsNull(ex.total_odr, 0) as total_odr_val,
		dbo.gfn_Xchange(@id_tec_prod_eur, IsNull(ex.total_odr, 0), ex.id_tec, @target_date, @id_oc_report) as total_odr_eur,
		ca.exposure_val,
		ca.exposure_id_val_val,
		ca.exposure_eur,
		ca.exposure_remaining_start_val,
		ca.exposure_remaining_start_eur,
		ca.exposure_remaining_end_val,
		ca.exposure_remaining_end_eur,
		ca.wcv_val,
		--ca.wcv_eur,
		ca.wcv_remaining_val,
		ca.wcv_remaining_eur,
		ca.wcv_delivered_val,
		ca.wcv_delivered_eur,
		ca.wcv_remaining_val - ca.wcv_delivered_val as wcv_sufficient_foc_val,
		ca.wcv_remaining_eur - ca.wcv_delivered_eur as wcv_sufficient_foc_eur,
		th.id_hipot,
		cw.object_or_property_type,
		cw.group_collateral_type,
		vo.id_vrste,
		vo.id_grupe1,
		case when nl.leas_kred = 'K' then 'LO'
			 when nl.leas_kred = 'L' and (nl.tip_knjizenja = '2' or dbo.gfn_RaiffRegion_ol2fl(@company_id, nl.tip_knjizenja, po.DAT_AKTIV, po.NACIN_LEAS, po.ANEKS, po.ID_CONT) = 1) then 'FL'
			 else 'OL'
		end as leasing_type,
		case when cw.collateral_type_b2 in ('10','14') then IsNull(tnp.value, 'UNKNOWN') else '' end as real_estate_type,
		case when cw.collateral_type_b2 in ('10','14') then 
				case when @company_id != 'RLSI' then IsNull(nrd.value, 'UNKNOWN')
					 else
						case when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 1 then 'Notranjska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 2 then 'Koroško-podravska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 3 then 'Savinjska-posavska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 4 then 'Gorenjska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 5 then 'Severno primorska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 6 then 'Primorska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 8 then 'Dolenjska regija'
						  when pst.drzava = 'SI' and left(replace(pst.id_poste, 'SI-', ''), 1) = 9 then 'Prekmurska regija'
						  when pst.drzava != 'SI' then drz.ime
					    end
				end
			 else ''
		end as real_estate_region_detail,
		cw.collateral_insurance_ok as collateral_insurance_ok,
		ci.insurance_min_velja_do as min_insurance_expiry_date,
		ci.ins_vrednost_eur as ins_vrednost_eur,
		ci.ins_ocen_vred_eur as ins_ocen_vred_eur,
		ci.stevilka_insurance as stevilka_insurance,
		ci.insurence_desc as insurence_desc,
		ci.naziv_zav_insurance as naziv_zav_insurance,
		cast(ci.insurance_ima as bit) as insurance_ima,
		ci.insurance_kategorija2 as insurance_kategorija2,
		ci.insurance_status_akt as insurance_status_akt,
		ci.insurance_zacetek as insurance_zacetek,
		case when cw.collateral_subtype_internal = 'RE' then
				case when @company_id = 'RLBH' then IsNull(d.vrednost, 0)
					 when @company_id = 'RLHR' then IsNull(d.ocen_vred, 0)
					 when @company_id = 'RLSI' then IsNull(d.vrednost, 0)
					 when @company_id in ('RLRS','RRRS') then IsNull(d.vrednost, 0)
				end
			else null
		end as realization_value,
		case when cw.collateral_subtype_internal = 'RE' then
				case when @company_id = 'RLBH' then IsNull(d.vrednost, 0)
					 when @company_id = 'RLHR' then IsNull(d.vrednost, 0)
					 when @company_id = 'RLSI' then IsNull(d.vrednost, 0)
					 when @company_id in ('RLRS','RRRS') then IsNull(d.vrednost, 0)
				end
			else null
		end as recovery_amount,
		case when cw.collateral_subtype_internal = 'RE' then kr.VALUE else null end as kind_of_recovery,
		case when cw.collateral_subtype_internal = 'RE' then d.velja_do else null end as recovery_date,
		cast(null as decimal(18, 2)) as cost_amount,
		cw.collateral_type_internal,
		cw.collateral_subtype_internal,
		cw.is_krov_dok,
		-- začetek 
		case when cw.collateral_subtype_internal = 'TV' then '' else uv.user_desc end as Verified_by, 
		d.dat_poprave as Latest_Change_on, 
		case when cw.collateral_subtype_internal = 'TV' then '' else up.user_desc end as Latest_Change_by, 
		sd.naziv as Wf_Status, 
		'CCONT_' + cw.collateral_id as COLLATERAL_CONTRACT_ID,
		case when cw.collateral_type_internal in ('GARB','GARK')
				then IsNull(pecoll.eval_model, @na)
		end as GUARANTOR_TYPE_ID,
		case when cw.collateral_type_internal = 'CASH' then bn.id_kupca else NULL end as DEPOSIT_CUSTOMER_ID,
		case when cw.collateral_type_internal = 'CASH' and isnumeric(d.stevilka) = 1 then cast(d.stevilka as bigint) else NULL end as DEPOSIT_REFERENCE_NUMBER,		

		case when cw.collateral_type_internal = 'PON'
				then '4' -- Leasing Contract
			 else IsNull(bc.collateral_contract_type, IsNull(bc_dorig.collateral_contract_type, @na))
		end as COLLATERAL_CONTRACT_TYPE, 
		case when cw.collateral_type_internal = 'PON'
				then IsNull((select group_collateral_type_id from #b2opprod where id_vrste = po.id_vrste and leasing_type = case when nl.leas_kred = 'K' then 'LO' when nl.tip_knjizenja = '1' and dbo.gfn_RaiffRegion_ol2fl(@company_id, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, po.id_cont) = 0 then 'OL' else 'FL' end), @na)
			 when cw.collateral_type_internal = 'ZALP' and cw.id_hipot is null
				then 'OOMOP'
			 else
				IsNull(bc.group_collateral_type_id, IsNull(bc_dorig.group_collateral_type_id, @na))
		end as GROUP_COLLATERAL_TYPE_ID,
		case when @company_id = 'RLHR' then
			case when zr.id_cont is not null and zr.vrsta in ('LK','MO','OS','OV') then zr.znamka else @na end
		else
			case when zr.id_cont is not null then zr.znamka else @na end
		end as CAR_BRAND,
		cast(
			case when @company_id = 'RLHR' then
				case when zr.id_cont is not null and zr.vrsta in ('LK','MO','OS','OV') then zr.naz_kr_kup + ', ' + zr.dealer_address else @na end
			else
				case when zr.id_cont is not null then left(zr.naz_kr_kup + ', ' + zr.dealer_address, 240) else @na end
			end 
		as varchar(240)) as CAR_DEALER,
		case when @company_id = 'RLHR' then
			case when zr.id_cont is not null and zr.vrsta in ('LK','MO','OS','OV') then zr.tip else @na end
		else
			case when zr.id_cont is not null then zr.tip else @na end
		end as CAR_MODEL,
		case when @company_id = 'RLHR' then
			case when zr.id_cont is not null and zr.vrsta in ('LK','MO','OS','OV') then zr.vrsta else @na end
		else
			case when zr.id_cont is not null then zr.vrsta else @na end
		end as CAR_TYPE,
		case when cw.collateral_type_internal = 'PON'
				then 'FDN'
			 else
				IsNull(bc.collateral_class_id, IsNull(bc_dorig.collateral_class_id, @na))
		end as COLLATERAL_CLASS_ID,
		case when cw.collateral_type_internal in ('GARB','GARK') then pecoll.cust_ratin else null end as Guarantor_rating, 
		case when cw.collateral_type_internal = 'PON'
				then IsNull((select modus from #b2opprod where id_vrste = po.id_vrste and leasing_type = case when nl.leas_kred = 'K' then 'LO' when nl.tip_knjizenja = '1' and dbo.gfn_RaiffRegion_ol2fl(@company_id, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, po.id_cont) = 0 then 'OL' else 'FL' end), @na)
			 else
				IsNull(bc.modus, IsNull(bc_dorig.modus, @na))
		end as ENDORSEMENT_TYPE,
		case when rtrim(ltrim(atp.value)) = 'INT' then 'Y' else 'N' end as INTERNAL_EXTERNAL_INDICATOR,
		IsNull(rtrim(ltrim(amf.id_key)), @na) as APPRAISAL_METHOD_first,
		IsNull(rtrim(ltrim(paapprf.naz_kr_kup)), @na) as APPRAISER_COMPANY_FIRST,
		IsNull(left(rtrim(ltrim(atpf.value)), 240), @na) as APPRAISER_TYPE_FIRST,
		IsNull(rtrim(ltrim(am.id_key)), @na) as APPRAISAL_METHOD_LAST,
		IsNull(rtrim(ltrim(paappr.naz_kr_kup)), @na) as APPRAISER_COMPANY_LAST,
		IsNull(left(rtrim(ltrim(atp.value)), 240), @na) as APPRAISER_TYPE_LAST,
		case when cw.collateral_type_b2 = '10' then 'Y' else 'N' end as ELIGIBILITY_INDICATOR_LOCAL,
		dbo.gfn_Xchange(@id_tec_prod_eur, cw.fair_market_value, cw.id_tec, @target_date, @id_oc_report) as CONTRACTUAL_MAXIMUM_AMOUNT,
		dbo.gfn_xchange(@id_tec_prod_eur, cw.execution_value, cw.id_tec, @target_date, @id_oc_report) as execution_value_eur,
		case when cw.collateral_type_internal in ('GARB','GARK')
				then d.kategorija2
			 else @na
		end GUARANTEE_COVERS_INTEREST, 
		cast(case when pl.id_key is null then @na else rtrim(ltrim(pl.value)) end as varchar(240)) as PROPERTY_LOCATION,
		case substring(pacoll.id_poste_sed,0,3) when 'XX' then @na when 'EU' then @na when 'B1' then 'BA' when 'B2' then 'BA' when 'CS' then 'RS' else substring(pacoll.id_poste_sed,0,3) end as country_of_collateral_provider,
		cast(left(ltrim(nep.parcel_st), 240) as varchar(240)) as Parcel_Number,
		ci.INSURANCE_ID,
		ci.cocunut_id_ins,
		ci.insurance_country as Insurance_company_country,
		ci.id_kupca_ins as ID_Insurance_Company,
		ci.insc_rat as Rating_of_insurance_company,		
		ci.rating_agency as Rating_Agency,		
		ci.stevilka_insurance as INSURANCE_NUMBER,
		ci.insurance_min_velja_do as INS_MATURITY_DATE, -- že obstaja 
		ci.ins_vrednost_eur_max as PAYMENT_AMOUNT, 
		ci.ins_ocen_vred_eur_max as INSURANCE_AMOUNT,
		case when cw.collateral_subtype_internal in ('RE','RA')
				then @mesto_sed_rl
			 when cw.collateral_type_internal in ('PON','IE','NELA')
				then IsNull(pacoll.mesto_sed, @na)
			 when cw.collateral_type_internal in ('HIPT','ZALN')
				then IsNull(posn.naziv, @na)
			 else
				IsNull(pacoll.mesto_sed, @na)
		end as CITY_TOWN_COLL,		
		ca.wcv_id_tec_val, 
		ca.wcv_id_val_val,
		tv.naziv as wcv_tec_naziv
into #final_result

from #collaterals_alloc ca
left join #allocation_types atpy on atpy.id_oc_report = ca.id_oc_report and atpy.ID_KEY = ca.alloc_type
inner join #collaterals_wcv cw on cw.id_oc_report = ca.id_oc_report and cw.collateral_id = ca.collateral_id
left join #collaterals_insurances_min_dates ci on ci.id_oc_report = ca.id_oc_report and ci.collateral_id = ca.collateral_id
left join dbo.tecajnic tcoll on tcoll.id_oc_report = cw.id_oc_report and tcoll.id_tec = cw.id_tec
left join #collaterals_alloc_by_contract cabc on cabc.id_oc_report = ca.id_oc_report and cabc.id_cont = ca.id_cont
left join dbo.dokument d on d.id_oc_report = cw.id_oc_report and d.id_dokum = cw.id_dokum
left join dbo.ban_sdk bn on bn.id_oc_report = d.id_oc_report and bn.ID_SDK = d.ID_SDK
left join dbo.users uv on uv.id_oc_report = d.id_oc_report and uv.username = d.vnesel
left join dbo.users up on up.id_oc_report = d.id_oc_report and up.username = d.popravil
left join dbo.STATUSI_DOKUMENT sd on sd.id_oc_report = d.id_oc_report and d.status_dok = sd.STATUS
left join dbo.dokument d_orig on d_orig.id_oc_report = cw.id_oc_report and d_orig.id_dokum = cw.id_dokum_orig
left join dbo.DOKUMENT df on df.id_oc_report = d.id_oc_report and cast(df.ID_DOKUM as varchar(50)) = d.ext_id -- da dobimo dokument ki je prva cenitev
left join #appraisers apf on apf.id_key = df.tip_cen
left join #appraisal_method amf on amf.id_key = df.kategorija3
left join #appraiser_type atpf on atpf.id_key = apf.id_key
left join dbo.oc_customers paapprf on paapprf.id_oc_report = apf.id_oc_report and paapprf.id_kupca = apf.val_char
inner join dbo.oc_contracts po on po.id_oc_report = ca.id_oc_report and po.id_cont = ca.id_cont
left join #exposure ex on ex.id_oc_report = po.id_oc_report and ex.id_cont = po.id_cont
left join dbo.tecajnic tv on ca.id_oc_report  = tv.id_oc_report and ca.wcv_id_tec_val = tv.id_tec 

-- partner iz pogodbe
inner join dbo.oc_customers pa on pa.id_oc_report = po.id_oc_report and pa.id_kupca = po.id_kupca
left join dbo.poste pstc on pstc.id_oc_report = pa.id_oc_report and pstc.id_poste = pa.id_poste_sed
left join #partner_status ps on ps.id_oc_report = pa.id_oc_report and ps.id_key = pa.p_status
left join #last_partner_evaluation pe on pe.id_oc_report = pa.id_oc_report and pe.id_kupca = pa.id_kupca
left join #b2collat bc on bc.id_obl_zav = d.id_obl_zav and (d.id_hipot = bc.id_hipot or bc.id_hipot = '*')
left join #b2collat bc_dorig on bc_dorig.id_obl_zav = d_orig.id_obl_zav and (d_orig.id_hipot = bc_dorig.id_hipot or bc_dorig.id_hipot = '*')
left join #zap_reg_tmp zr on zr.id_cont = po.id_cont

-- partner iz kolaterala
inner join dbo.oc_customers pacoll on pacoll.id_oc_report = cw.id_oc_report and pacoll.id_kupca = cw.id_kupca_coll
left join dbo.poste pst on pst.id_oc_report = pacoll.id_oc_report and pst.id_poste = pacoll.id_poste_sed
left join dbo.drzave drz on drz.id_oc_report = pst.id_oc_report and drz.drzava = pst.drzava
left join dbo.regije reg on reg.id_oc_report = pst.id_oc_report and reg.id_reg = pst.id_reg
left join #partner_status pscoll on pscoll.id_oc_report = pacoll.id_oc_report and pscoll.id_key = pacoll.p_status
left join #last_partner_evaluation pecoll on pecoll.id_oc_report = pacoll.id_oc_report and pecoll.id_kupca = pacoll.id_kupca
-- partner iz kolaterala (owner)

inner join dbo.oc_customers pacoll_ow on pacoll_ow.id_oc_report = cw.id_oc_report and pacoll_ow.id_kupca = cw.id_kupca_coll_ow
left join dbo.poste pst_ow on pst_ow.id_oc_report = pacoll_ow.id_oc_report and pst_ow.id_poste = pacoll_ow.id_poste_sed
left join dbo.drzave drz_ow on drz_ow.id_oc_report = pst_ow.id_oc_report and drz_ow.drzava = pst_ow.drzava
left join dbo.regije reg_ow on reg_ow.id_oc_report = pst_ow.id_oc_report and  reg_ow.id_reg = pst_ow.id_reg
left join #partner_status pscoll_ow on pscoll_ow.id_key = pacoll_ow.p_status
left join #last_partner_evaluation pecoll_ow on pecoll_ow.id_kupca = pacoll_ow.id_kupca

-- skrbnik partnerja iz kolaterala (za RLRS/RRRS)
left join dbo.oc_customers pa_skr on pa_skr.id_oc_report = pacoll.id_oc_report and pa_skr.id_kupca = pacoll.skrbnik_1
left join dbo.poste pst_skr on pst_skr.id_oc_report = pa_skr.id_oc_report and pst_skr.id_poste = pa_skr.id_poste_sed
left join dbo.drzave drz_skr on drz_skr.id_oc_report = pst_skr.id_oc_report and drz_skr.drzava = pst_skr.drzava
left join dbo.regije reg_skr on reg_skr.id_oc_report = pst_skr.id_oc_report and reg_skr.id_reg = pst_skr.id_reg
inner join dbo.nacini_l nl on nl.id_oc_report = po.id_oc_report and nl.nacin_leas = po.nacin_leas
inner join dbo.vrst_opr vo on vo.id_oc_report = po.id_oc_report and vo.id_vrste = po.id_vrste
inner join dbo.dav_stop ds on ds.id_oc_report = po.id_oc_report and ds.id_dav_st = IsNull(po.id_dav_op, po.id_dav_st)
left join dbo.referent r on r.id_oc_report = po.id_oc_report and r.id_ref = po.id_ref
left join #contract_max_dat_zap cmd on cmd.id_oc_report = ca.id_oc_report and cmd.id_cont = ca.id_cont
left join dbo.thipot th on th.id_oc_report = d.id_oc_report and th.id_hipot = d.id_hipot
left join #appraisers ap on ap.id_oc_report = d.id_oc_report and ap.id_key = d.tip_cen
left join #appraiser_type atp on atp.id_key = ap.id_key
left join #appraisal_method am on am.id_key = d.kategorija3
left join dbo.oc_customers paappr on paappr.id_oc_report = ap.id_oc_report and paappr.id_kupca = ap.val_char
left join #kind_of_recovery kr on kr.id_oc_report = d.id_oc_report and kr.ID_KEY = d.kategorija2
left join dbo.nep_enot nee on nee.id_oc_report = d.id_oc_report and nee.id_npr_enote = d.id_npr_enote
left join dbo.neprem nep on nep.id_oc_report = nee.id_oc_report and nep.id_nepr = nee.id_nepr
left join #tip_nepremicnine tnp on tnp.id_oc_report = nee.id_oc_report and tnp.ID_KEY = nee.tip_neprem
left join #neprem_regije_detail nrd on nrd.id_oc_report = nep.id_oc_report and nrd.ID_KEY = nep.stat_reg
left join #property_location pl on pl.id_key = nep.kateg1
left join dbo.poste posn on posn.id_oc_report = nep.id_oc_report and posn.id_poste = nep.id_poste
-- partner Raiffeisen Leasing
left join dbo.oc_customers pa_rl on pa_rl.id_oc_report = @id_oc_report and pa_rl.id_kupca = @id_kupca_rl
left join #partner_status ps_rl on ps_rl.id_oc_report = pa_rl.id_oc_report and ps_rl.id_key = pa_rl.p_status
left join dbo.poste rl_pst on rl_pst.id_oc_report = pa_rl.id_oc_report and rl_pst.id_poste = pa_rl.id_poste_sed
left join #last_partner_evaluation rl_pecoll on rl_pecoll.id_oc_report = pa_rl.id_oc_report and rl_pecoll.id_kupca = pa_rl.id_kupca
left join dbo.regije rl_reg on rl_reg.id_oc_report = rl_pst.id_oc_report and rl_reg.id_reg = rl_pst.id_reg
where ca.id_oc_report = @id_oc_report
and ca.collateral_id is not null
order by po.id_kupca, ca.cont_rank, ca.collateral_rank, po.id_pog



-- FINAL RESULT
select *
from #final_result
where collateral_subtype_internal != 'RE'


-- BLUE PRINT REPORTS

-- grouped by collateral and leasing type
select id_dokum, id_obl_zav, collateral_id, leasing_type, collateral_type_report, collateral_type_b2_desc, object_or_property_type, group_collateral_type, real_estate_region_detail, real_estate_type, last_appraisal_date,
		last_appraiser, id_kupca_coll, ext_id_coll, cust_ratin, coll_ratin, collateral_expiry_date, d_vrednot, is_elligible, naziv_ref, skrbnik1_naziv,
		id_poste_sed, naziv_poste, drzava, naziv_reg, collateral_type_b2, real_estate_indicator, naz_kr_kup_coll,
		collateral_type_internal, collateral_subtype_internal, collateral_is_ownership,
		ins_ocen_vred_eur, ins_vrednost_eur, min_insurance_expiry_date, stevilka_insurance, insurence_desc, naziv_zav_insurance, insurance_ima, insurance_kategorija2, insurance_status_akt, insurance_zacetek,
		nominal_value_eur, wcov_eur, wgov_eur, wcov_eur + wgov_eur as wcov_wgov_eur, ponder_with_hx,
		max(case when is_krov_dok = 0 then id_pog else null end) as id_pog,
		max(case when is_krov_dok = 0 then nacin_leas else null end) as nacin_leas,
		max(case when is_krov_dok = 0 then aneks else null end) as aneks,
		sum(case when collateral_type_b2 != '9' then wcv_delivered_eur else 0 end) as wcv_only_delivered_eur,
		sum(case when collateral_type_b2 = '9' then wcv_delivered_eur else 0 end) as wgv_only_delivered_eur,
		sum(wcv_delivered_eur) as wcv_all_delivered_eur,
		sum(exposure_eur) as exposure_eur,
		min(contract_expiry_date) as min_contract_expiry_date,
		sum(net_nal_zac_eur) as net_nal_zac_eur,
		max(case when is_krov_dok = 0 then earliest_expiry_of_secured_deals else null end) as earliest_expiry_of_secured_deals,
		max(case when is_krov_dok = 0 then latest_expiry_of_secured_deals else null end) as latest_expiry_of_secured_deals
into #report_group_by_collateral
from #final_result
where collateral_subtype_internal != 'RE'
group by id_dokum, id_obl_zav, collateral_id, leasing_type, collateral_type_report, collateral_type_b2_desc, object_or_property_type, group_collateral_type, real_estate_region_detail, real_estate_type, last_appraisal_date,
		last_appraiser, id_kupca_coll, ext_id_coll, cust_ratin, coll_ratin, collateral_expiry_date, d_vrednot, is_elligible, naziv_ref, skrbnik1_naziv, nominal_value_eur,
		wcov_eur, wgov_eur, wcov_eur + wgov_eur, ponder_with_hx,
		ins_ocen_vred_eur, ins_vrednost_eur, min_insurance_expiry_date, stevilka_insurance, insurence_desc, naziv_zav_insurance, insurance_ima, insurance_kategorija2, insurance_status_akt, insurance_zacetek,
		id_poste_sed, naziv_poste, drzava, naziv_reg, collateral_type_b2, real_estate_indicator, naz_kr_kup_coll, collateral_type_internal, collateral_subtype_internal, collateral_is_ownership


-- grouped by collateral - previous snapshot
select ca.collateral_id,
		sum(dbo.gfn_Xchange(@id_tec_prod_eur, cw.wcov, cw.id_tec, @target_date, @id_oc_report_previous)) as wcov_wgov_eur,
		sum(ca.wcv_delivered_eur) as wcv_delivered_eur
into #report_group_by_collateral_prev
from #collaterals_alloc_prev ca
inner join #collaterals_wcv_prev cw on cw.id_oc_report = ca.id_oc_report and cw.collateral_id = ca.collateral_id
group by ca.collateral_id



-- undelivered collaterals (we need this for Report 8. - Minimum collateral coverage)
select c.id_dokum, d.id_obl_zav,
		case when nl.leas_kred = 'K' then 'LO'
			 when nl.leas_kred = 'L' and (nl.tip_knjizenja = '2' or dbo.gfn_RaiffRegion_ol2fl(@company_id, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, po.id_cont) = 1) then 'FL'
			 else 'OL'
		end as leasing_type,
		pa.id_kupca as id_kupca_coll, pa.ext_id as ext_id_coll, pa.naz_kr_kup as naz_kr_kup_coll, pe.cust_ratin, c.collateral_id,
		case when c.collateral_type_b2 = '12'
				then 'OPC'
			 when c.collateral_type_b2 = '0'
				then 'CSH'
			 when c.collateral_type_b2 = '9'
				then 'GUA'
			 when c.collateral_type_b2 = '10'
				then 'RRE'
			 when c.collateral_type_b2 = '14'
				then 'CRE'
			 when c.collateral_type_b2 = '13'
				then 'LINS'
			 when c.collateral_type_b2 = '11'
				then 'RECEIVABLES'
			 else
				'UNKNOWN'
		end as collateral_type_report,
		dbo.gfn_Xchange(@id_tec_prod_eur, c.nominal_value, c.id_tec, @target_date, @id_oc_report) as ncv_eur,
		cast(0 as decimal(18,2)) as wcv_all_delivered_eur,
		dbo.gfn_Xchange(@id_tec_prod_eur, IsNull(e.b2_total_exposure, 0), IsNull(e.id_tec, '000'), @target_date, @id_oc_report) as exposure_eur,
		dbo.gfn_Xchange(@id_tec_prod_eur, dbo.gfn_VrValToNetoInternal(po.net_nal_zac, po.robresti_zac, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto), po.id_tec, po.dat_aktiv, @id_oc_report) as net_nal_zac_eur,
		0 as limit_of_secur_deals,
		null as int_cover_approval,
		r.naziv as naziv_ref
into #collaterals_undelivered_by_contract
from #collaterals_undelivered c
inner join dbo.oc_contracts po on po.id_oc_report = c.id_oc_report and po.id_cont = c.id_cont
inner join dbo.nacini_l nl on nl.id_oc_report = po.id_oc_report and nl.nacin_leas = po.nacin_leas
inner join dbo.dav_stop ds on ds.id_oc_report = po.id_oc_report and ds.id_dav_st = IsNull(po.id_dav_op, po.id_dav_st)
inner join dbo.dokument d on d.id_oc_report = c.id_oc_report and d.id_dokum = c.id_dokum
inner join dbo.oc_customers pa on pa.id_oc_report = c.id_oc_report and pa.id_kupca = c.id_kupca_coll
left join #exposure e on e.id_cont = c.id_cont
left join #last_partner_evaluation pe on pe.id_kupca = pa.id_kupca
left join dbo.referent r on r.id_oc_report = po.id_oc_report and r.id_ref = po.id_ref
where po.id_oc_report = @id_oc_report
and c.id_cont is not null
union all
select c.id_dokum, d.id_obl_zav, 
		case when nl.leas_kred is null then '' 
			 when nl.leas_kred = 'K' then 'LO'
			 when nl.leas_kred = 'L' and (nl.tip_knjizenja = '2' or dbo.gfn_RaiffRegion_ol2fl(@company_id, nl.tip_knjizenja, po.dat_aktiv, po.nacin_leas, po.aneks, po.id_cont) = 1) then 'FL'
			 else 'OL'
		end as leasing_type,
		pa.id_kupca as id_kupca_coll, pa.ext_id as ext_id_coll, pa.naz_kr_kup as naz_kr_kup_coll, pe.cust_ratin, c.collateral_id,
		case when c.collateral_type_b2 = '12'
				then 'OPC'
			 when c.collateral_type_b2 = '0'
				then 'CSH'
			 when c.collateral_type_b2 = '9'
				then 'GUA'
			 when c.collateral_type_b2 = '10'
				then 'RRE'
			 when c.collateral_type_b2 = '14'
				then 'CRE'
			 when c.collateral_type_b2 = '13'
				then 'LINS'
			 when c.collateral_type_b2 = '11'
				then 'RECEIVABLES'
			 else
				'UNKNOWN'
		end as collateral_type_report,
		IsNull(dbo.gfn_Xchange(@id_tec_prod_eur, c.nominal_value, c.id_tec, @target_date, @id_oc_report), 0) as ncv_eur,
		cast(0 as decimal(18,2)) as wcv_all_delivered_eur,
		dbo.gfn_Xchange(@id_tec_prod_eur, IsNull(e.b2_total_exposure, 0), IsNull(e.id_tec, '000'), @target_date, @id_oc_report) as exposure_eur,
		IsNull(dbo.gfn_Xchange(@id_tec_prod_eur, dbo.gfn_VrValToNetoInternal(po.net_nal_zac, po.robresti_zac, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto), po.id_tec, po.dat_aktiv, @id_oc_report), 0) as net_nal_zac_eur,
		0 as limit_of_secur_deals,
		null as int_cover_approval,
		null as naziv_ref
from #collaterals_undelivered c
inner join dbo.dokument d on d.id_oc_report = c.id_oc_report and d.id_dokum = c.id_dokum
inner join dbo.oc_customers pa on pa.id_oc_report = c.id_oc_report and pa.id_kupca = c.id_kupca_coll
left join #last_partner_evaluation pe on pe.id_kupca = pa.id_kupca
left join dbo.dokument l on l.id_oc_report = c.id_oc_report and l.id_krov_dok = c.id_dokum
left join dbo.dok dk on dk.id_oc_report = l.id_oc_report and dk.id_obl_zav = l.id_obl_zav and dk.sifra = 'LINK'
left join dbo.oc_contracts po on po.id_oc_report = l.id_oc_report and po.id_cont = l.id_cont
left join dbo.nacini_l nl on nl.id_oc_report = po.id_oc_report and nl.nacin_leas = po.nacin_leas
left join dbo.dav_stop ds on ds.id_oc_report = po.id_oc_report and ds.id_dav_st = IsNull(po.id_dav_op, po.id_dav_st)
left join #exposure e on e.id_cont = po.id_cont
left join dbo.referent r on r.id_oc_report = po.id_oc_report and r.id_ref = po.id_ref
where po.id_oc_report = @id_oc_report
and c.id_dokum is null


-- REPORTS

-- Report 1.- Portfolio overview and development of collateral
select leasing_type, collateral_type_report,
		sum(nominal_value_eur) as ncv_eur,
		sum(wcov_wgov_eur) as wcov_wgov_eur,
		sum(wcv_only_delivered_eur) as wcv_only_delivered_eur,
		sum(wgv_only_delivered_eur) as wgv_only_delivered_eur,
		sum(wcv_all_delivered_eur) as wcv_all_delivered_eur
from #report_group_by_collateral
group by leasing_type, collateral_type_report



-- Report 2.- Portfolio overview and RE & OPC types analysis
select leasing_type, collateral_type_report, object_or_property_type,
		sum(nominal_value_eur) as ncv_eur,
		sum(wcov_wgov_eur) as wcov_wgov_eur,
		sum(wcv_only_delivered_eur) as wcv_only_delivered_eur,
		sum(wgv_only_delivered_eur) as wgv_only_delivered_eur,
		sum(wcv_all_delivered_eur) as wcv_all_delivered_eur
from #report_group_by_collateral
group by leasing_type, collateral_type_report, object_or_property_type


-- Report 3. - Real Estate Locations & Concentrations
if @company_id = 'RLHR' begin

	-- we sum building and property contract into one entity
	select a.collateral_id
	into #lastnistvo_nepremicnine_to_sum
	from #report_group_by_collateral a
	where a.collateral_type_internal = 'NELA'
	and a.id_pog like '%/ZM%'
	and exists (
			select b.collateral_id
			from #report_group_by_collateral b
			where b.collateral_type_internal = 'NELA'
			and b.id_pog not like '%/ZM%'
			and left(b.id_pog, charindex('/', b.id_pog) - 1) = left(a.id_pog, charindex('/', a.id_pog) - 1)
		)
	union all
	select a.collateral_id
	from #report_group_by_collateral a
	where a.collateral_type_internal = 'NELA'
	and a.id_pog not like '%/ZM%'
	and exists (
		select b.collateral_id
		from #report_group_by_collateral b
		where b.collateral_type_internal = 'NELA'
		and b.id_pog like '%/ZM%'
		and left(b.id_pog, charindex('/', b.id_pog) - 1) = left(a.id_pog, charindex('/', a.id_pog) - 1)
	)
	
	select leasing_type, real_estate_region_detail, real_estate_type, sum(nominal_value_eur) as ncv_eur, sum(wcv_all_delivered_eur) as wcv_all_delivered_eur
	from #report_group_by_collateral
	where collateral_type_b2 in ('10','14')
	and collateral_id not in (select collateral_id from #lastnistvo_nepremicnine_to_sum)
	group by leasing_type, real_estate_region_detail, real_estate_type
	union all
	select leasing_type, real_estate_region_detail, min(real_estate_type) as real_estate_type, sum(nominal_value_eur) as ncv_eur, sum(wcv_all_delivered_eur) as wcv_all_delivered_eur
	from #report_group_by_collateral
	where collateral_type_b2 in ('10','14')
	and collateral_id in (select collateral_id from #lastnistvo_nepremicnine_to_sum)
	group by leasing_type, real_estate_region_detail
	
	drop table #lastnistvo_nepremicnine_to_sum
	
end else begin
	select leasing_type, real_estate_region_detail, real_estate_type, sum(nominal_value_eur) as ncv_eur, sum(wcv_all_delivered_eur) as wcv_all_delivered_eur
	from #report_group_by_collateral
	where collateral_type_b2 in ('10','14')
	group by leasing_type, real_estate_region_detail, real_estate_type
end


-- Report 4. - Report for Due Revaluations
select leasing_type, collateral_id, id_dokum, id_obl_zav, id_kupca_coll, ext_id_coll, naz_kr_kup_coll, cust_ratin, coll_ratin, last_appraisal_date, last_appraiser, naziv_ref, skrbnik1_naziv,
		collateral_type_report, d_vrednot, last_appraiser, is_elligible, collateral_expiry_date, wcv_all_delivered_eur, id_pog
from #report_group_by_collateral
where (((collateral_type_internal != 'PON') or (collateral_type_internal = 'PON' and collateral_subtype_internal = 'RA')) and collateral_subtype_internal != 'RE')
and (d_vrednot <= dbo.gfn_GetLastDayOfMonth(dateadd(mm, 1, @target_date)))


-- Report 4.1 - Report for Overdue Revaluations (buckets - without repossesed OL)
select leasing_type,
		case when datediff(dd, last_appraisal_date, @target_date) / 30.00 >= 13 and datediff(dd, last_appraisal_date, @target_date) <= 18 then '13 - 18 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 18 and datediff(dd, last_appraisal_date, @target_date) <= 24 then '18 - 24 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 24 and datediff(dd, last_appraisal_date, @target_date) <= 36 then '24 - 36 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 36 then '> 36 mth'
			else '< 13 mth'
		end as time_after_evaluation,
	   sum(wcv_all_delivered_eur) as wcv_all_delivered_eur
from #report_group_by_collateral
where (((collateral_type_internal != 'PON') or (collateral_type_internal = 'PON' and collateral_subtype_internal = 'RA')) and collateral_subtype_internal != 'RE')
and ((@company_id not in ('RLBH') and d_vrednot <= dbo.gfn_GetLastDayOfMonth(dateadd(mm, 1, @target_date))))
and not (leasing_type = 'OL' and collateral_subtype_internal = 'RA')
group by leasing_type,
		case when datediff(dd, last_appraisal_date, @target_date) / 30.00 >= 13 and datediff(dd, last_appraisal_date, @target_date) <= 18 then '13 - 18 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 18 and datediff(dd, last_appraisal_date, @target_date) <= 24 then '18 - 24 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 24 and datediff(dd, last_appraisal_date, @target_date) <= 36 then '24 - 36 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 36 then '> 36 mth'
			else '< 13 mth'
		end

		
-- Report 4.2 - Report for Overdue Revaluations (buckets - only repossesed OL)
select leasing_type,
		case when datediff(dd, last_appraisal_date, @target_date) / 30.00 >= 1 and datediff(dd, last_appraisal_date, @target_date) <= 3 then '1 - 3 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 3 and datediff(dd, last_appraisal_date, @target_date) <= 12 then '3 - 12 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 12 then '> 1 year'
			else '< 1 mth'
		end as time_after_evaluation,
	   sum(wcv_all_delivered_eur) as wcv_all_delivered_eur
from #report_group_by_collateral
where (((collateral_type_internal != 'PON') or (collateral_type_internal = 'PON' and collateral_subtype_internal = 'RA')) and collateral_subtype_internal != 'RE')
and ((@company_id not in ('RLBH') and d_vrednot <= dbo.gfn_GetLastDayOfMonth(dateadd(mm, 1, @target_date))))
and (leasing_type = 'OL' and collateral_subtype_internal = 'RA')
group by leasing_type,
		case when datediff(dd, last_appraisal_date, @target_date) / 30.00 >= 1 and datediff(dd, last_appraisal_date, @target_date) <= 3 then '1 - 3 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 3 and datediff(dd, last_appraisal_date, @target_date) <= 12 then '3 - 12 mth'
			when datediff(dd, last_appraisal_date, @target_date) / 30.00 > 12 then '> 1 year'
			else '< 1 mth'
		end


-- Report 5. - Main Value Changes
select c.leasing_type, c.collateral_id, c.id_kupca_coll, c.naz_kr_kup_coll, c.ext_id_coll, c.cust_ratin, c.coll_ratin, c.naziv_ref, skrbnik1_naziv,
		c.collateral_type_report, c.last_appraisal_date, c.last_appraiser,
		c.wcv_all_delivered_eur as wcv_all_delivered_eur, c.wcov_wgov_eur as wcov_wgov_eur_current, p.wcov_wgov_eur as wcov_wgov_eur_prev,
		case when c.wcov_wgov_eur = p.wcov_wgov_eur
				then 0
			 when IsNull(p.wcov_wgov_eur, 0) = 0
				then null
			 else
				round(((p.wcov_wgov_eur - c.wcov_wgov_eur) / p.wcov_wgov_eur) * 100, 4)
				--round((c.wcov_wgov_eur / IsNull(p.wcov_wgov_eur, 0)), 4)
		end as wcov_wgov_perc_change,
		c.is_elligible, c.collateral_expiry_date
from #report_group_by_collateral c
left join #report_group_by_collateral_prev p on p.collateral_id = c.collateral_id


-- Report 7. - Expiry report
select id_dokum, id_obl_zav, leasing_type, id_kupca_coll, ext_id_coll, naz_kr_kup_coll, cust_ratin, id_pog, d_vrednot, min_contract_expiry_date, collateral_id, collateral_type_report, collateral_type_b2_desc, collateral_expiry_date,
		wcov_wgov_eur, wcv_all_delivered_eur, exposure_eur, nominal_value_eur,
		case when nominal_value_eur = 0 then null
			 else round((exposure_eur / nominal_value_eur) * 100, 4)
		end as current_ltc_percentage,
		earliest_expiry_of_secured_deals,
		latest_expiry_of_secured_deals,
		datediff(dd, min_contract_expiry_date, collateral_expiry_date) as early_exp_secured_deals_days,
		case when collateral_expiry_date > min_contract_expiry_date then collateral_expiry_date else min_contract_expiry_date end as late_exp_secured_deals_date,
		naziv_ref, skrbnik1_naziv
from #report_group_by_collateral
where (((collateral_type_internal != 'PON') or (collateral_type_internal = 'PON' and collateral_subtype_internal = 'RA')) and collateral_subtype_internal != 'RE')
and (collateral_expiry_date <= dbo.gfn_GetLastDayOfMonth(dateadd(mm, 2, @target_date)))


-- Report 8. - Minimum collateral coverage
select id_dokum, id_obl_zav, leasing_type, id_kupca_coll, ext_id_coll, naz_kr_kup_coll, cust_ratin, collateral_id, collateral_type_report,
		nominal_value_eur as ncv_eur, wcv_all_delivered_eur, exposure_eur, net_nal_zac_eur, 0 as limit_of_secur_deals,
		case when exposure_eur = 0 then 0
			 when (wcv_all_delivered_eur / exposure_eur) * 100.00 > 100.00 then 100.00
			 else round((wcv_all_delivered_eur / exposure_eur) * 100.00, 4)
		end as curr_collat_coverage,
		case when net_nal_zac_eur = 0 then 0
			 when (nominal_value_eur / net_nal_zac_eur) * 100.00 > 100.00 then 100.00
			 else round((nominal_value_eur / net_nal_zac_eur) * 100.00, 4)
		end as cntractu_collat_coverage,
		null as int_cover_approval, naziv_ref, skrbnik1_naziv,
		cast(1 as bit) as collateral_is_delivered
from #report_group_by_collateral
where collateral_is_ownership = 0
union all
select id_dokum, id_obl_zav, min(leasing_type) as leasing_type, id_kupca_coll, ext_id_coll, naz_kr_kup_coll, cust_ratin, collateral_id, collateral_type_report,
		sum(ncv_eur) as ncv_eur, sum(wcv_all_delivered_eur) as wcv_all_delivered_eur, sum(exposure_eur) as exposure_eur, sum(net_nal_zac_eur) as net_nal_zac_eur,
		sum(limit_of_secur_deals) as limit_of_secur_deals, cast(0 as decimal(18,4)) as curr_collat_coverage, cast(0 as decimal(18,4)) as cntractu_collat_coverage,
		null as int_cover_approval, max(naziv_ref) as naziv_ref, max(naziv_ref) as skrbnik1_naziv,
		cast(0 as bit) as collateral_is_delivered
from #collaterals_undelivered_by_contract
group by id_dokum, id_obl_zav, id_kupca_coll, ext_id_coll, naz_kr_kup_coll, cust_ratin, collateral_id, collateral_type_report		

-- Report 9. - Insurance coverage
select id_dokum, id_obl_zav, c.leasing_type, c.id_kupca_coll, c.ext_id_coll, c.naz_kr_kup_coll, c.collateral_id, c.collateral_type_report, c.ins_ocen_vred_eur as insurance_sum,
		c.wcv_all_delivered_eur, c.min_insurance_expiry_date, 'Y' as premium_paid, 'n.a.' as eligibility, naziv_ref, skrbnik1_naziv,
		c.id_pog, c.nacin_leas, c.aneks, c.stevilka_insurance, c.insurence_desc, c.naziv_zav_insurance, c.insurance_ima, c.insurance_kategorija2, c.insurance_status_akt, c.insurance_zacetek
from #report_group_by_collateral c


-- Report 10. - Concentration monitoring
select count(*) as cnt_cont, a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator, a.naziv_reg, a.drzava
into #report_10_cnt_cont
from (
	select id_pog, leasing_type, collateral_type_report, object_or_property_type, real_estate_indicator, naziv_reg, drzava
	from #final_result
	where collateral_subtype_internal != 'RE'
	group by id_pog, leasing_type, collateral_type_report, object_or_property_type, real_estate_indicator, naziv_reg, drzava
) a
group by a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator, a.naziv_reg, a.drzava

select count(*) as cnt_coll, a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator, a.naziv_reg, a.drzava
into #report_10_cnt_coll
from (
	select collateral_id, leasing_type, collateral_type_report, object_or_property_type, real_estate_indicator, naziv_reg, drzava
	from #final_result
	where collateral_subtype_internal != 'RE'
	group by collateral_id, leasing_type, collateral_type_report, object_or_property_type, real_estate_indicator, naziv_reg, drzava
) a
group by a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator, a.naziv_reg, a.drzava

select count(*) as cnt_part, a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator, a.naziv_reg, a.drzava
into #report_10_cnt_part
from (
	select id_kupca_coll, leasing_type, collateral_type_report, object_or_property_type, real_estate_indicator, naziv_reg, drzava
	from #final_result
	where collateral_subtype_internal != 'RE'
	group by id_kupca_coll, leasing_type, collateral_type_report, object_or_property_type, real_estate_indicator, naziv_reg, drzava
) a
group by a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator, a.naziv_reg, a.drzava

select a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator,
		a.drzava, a.naziv_reg,
		sum(a.nominal_value_eur) as ncv_eur,
		sum(a.wcv_all_delivered_eur) as wcv_all_delivered_eur
into #report_10
from #report_group_by_collateral a
group by a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator, a.drzava, a.naziv_reg


select a.leasing_type, a.collateral_type_report, a.object_or_property_type, a.real_estate_indicator, a.drzava, a.naziv_reg,
		b.cnt_cont, c.cnt_coll, d.cnt_part,
		a.ncv_eur,
		a.wcv_all_delivered_eur
from #report_10 a
inner join #report_10_cnt_cont b on b.leasing_type = a.leasing_type and b.collateral_type_report = a.collateral_type_report and IsNull(b.object_or_property_type, '') = IsNull(a.object_or_property_type, '') and b.real_estate_indicator = a.real_estate_indicator and b.DRZAVA = a.DRZAVA and b.naziv_reg = a.naziv_reg
inner join #report_10_cnt_coll c on c.leasing_type = a.leasing_type and c.collateral_type_report = a.collateral_type_report and IsNull(c.object_or_property_type, '') = IsNull(a.object_or_property_type, '') and c.real_estate_indicator = a.real_estate_indicator and c.DRZAVA = a.DRZAVA and c.naziv_reg = a.naziv_reg
inner join #report_10_cnt_part d on d.leasing_type = a.leasing_type and d.collateral_type_report = a.collateral_type_report and IsNull(d.object_or_property_type, '') = IsNull(a.object_or_property_type, '') and d.real_estate_indicator = a.real_estate_indicator and d.DRZAVA = a.DRZAVA and d.naziv_reg = a.naziv_reg


drop table #report_10_cnt_cont
drop table #report_10_cnt_coll
drop table #report_10_cnt_part
drop table #report_10


-- Report 11. - Recovery and Realization Reporting

-- kandidati so vsi partnerji (NRT in RET), ki imajo odvzet in prodan predmet financiranja (dokument RE - Resale asset)
-- zaenkrat prikazemo le RE dokumente, realizacija iz naslova ostalih kolateralov se ni podprta/zabelezena v sistemu
select de.id_kupca
into #ddb_candidates
from dbo.default_events de
inner join dbo.default_events_register der on der.id_d_event = de.id_d_event
where der.sif_d_event in ('D8N','D8R')
and de.def_end_date is null
group by de.id_kupca

select id_dokum, id_obl_zav, c.id_kupca, c.ext_id, c.naz_kr_kup, c.collateral_id, c.collateral_type_report, c.drzava_part_cont, c.object_or_property_type,
		case when c.collateral_type_b2 != '9' then c.nominal_value_eur else 0 end as ncv_eur,
		case when c.collateral_type_b2 = '9' then c.nominal_value_eur else 0 end as ngv_eur,
		c.realization_value,
		c.recovery_amount,
		c.wcov_eur,
		c.wgov_eur,
		c.kind_of_recovery,
		c.recovery_date,
		case when r.id_kupca is null then cast(0 as bit) else cast(1 as bit) end as has_overdue_payment,
		sum(case when collateral_type_b2 != '9' then wcv_delivered_eur else 0 end) as wcv_delivered,
		sum(case when collateral_type_b2 = '9' then wcv_delivered_eur else 0 end) as wgv_delivered,
		null as cost_amount
from #final_result c
left join #ddb_candidates r on r.id_kupca = c.id_kupca
where c.collateral_subtype_internal = 'RE'
group by id_dokum, id_obl_zav, c.id_kupca, c.ext_id, c.naz_kr_kup, c.collateral_id, c.collateral_type_report, c.drzava_part_cont, c.object_or_property_type,
		case when c.collateral_type_b2 != '9' then c.nominal_value_eur else 0 end,
		case when c.collateral_type_b2 = '9' then c.nominal_value_eur else 0 end,
		c.realization_value, c.recovery_amount, c.wcov_eur, c.wgov_eur, c.kind_of_recovery, c.recovery_date,
		case when r.id_kupca is null then cast(0 as bit) else cast(1 as bit) end
		
drop table #ddb_candidates


-- Report 12. - Discount applied
select id_dokum, id_obl_zav, leasing_type, id_kupca_coll, collateral_id, group_collateral_type, collateral_type_report, drzava as country_of_collateral, object_or_property_type,
		case when collateral_type_b2 != '9' then nominal_value_eur else null end as ncv_eur,
		case when collateral_type_b2 = '9' then nominal_value_eur else null end as ngv_eur,
		wcov_eur,
		wgov_eur,
		wcv_only_delivered_eur as wcv_only_delivered_eur,
		wgv_only_delivered_eur as wgv_only_delivered_eur,
		ponder_with_hx as discount_applied,
		null as discount_minimum,
		is_elligible,
		collateral_type_internal
into #report_12
from #report_group_by_collateral

select * from #report_12

-- Report 12.1 - Discount applied - agregated analysis
select collateral_type_report, group_collateral_type, object_or_property_type, count(*) as no_of_collaterals,
		sum(ncv_eur) / count(*) as sum_ncv_eur_avg,
		sum(ngv_eur) / count(*) as sum_ngv_eur_avg,
		sum(wcov_eur) / count(*) as sum_wcov_eur_avg,
		sum(wgov_eur) / count(*) as sum_wgov_eur_avg,
		sum(wcv_only_delivered_eur) / count(*) as wcv_only_delivered_eur_avg,
		sum(wgv_only_delivered_eur) / count(*) as wgv_only_delivered_eur_avg,
		sum(discount_applied) / count(*) as discount_avg,
		max(discount_applied) as discount_max,
		min(discount_applied) as discount_min,
		cast(0 as decimal(18,4)) as discount_gd_min
from #report_12
where discount_applied > 0 and collateral_type_internal not in ('PON', 'IE')
group by collateral_type_report, group_collateral_type, object_or_property_type



drop table #report_12
drop table #exposure
drop table #exposure_prev
drop table #collaterals_wcv
drop table #collaterals_wcv_prev
drop table #collaterals_insurances
drop table #collaterals_insurances_prev
drop table #collaterals_insurances_min_dates
drop table #collaterals_alloc
drop table #collaterals_alloc_prev
drop table #collaterals_undelivered
drop table #collaterals_undelivered_by_contract
drop table #last_partner_evaluation
drop table #appraisers
drop table #kind_of_recovery
drop table #tip_nepremicnine
drop table #neprem_regije_detail
drop table #contract_max_dat_zap
drop table #collaterals_alloc_by_contract
drop table #partner_status
drop table #allocation_types
drop table #final_result
drop table #report_group_by_collateral
drop table #report_group_by_collateral_prev
drop table #property_location
drop table #appraiser_type
drop table #appraisal_method
drop table #b2collat
drop table #b2opprod
drop table #zap_reg_tmp1
drop table #zap_reg_tmp