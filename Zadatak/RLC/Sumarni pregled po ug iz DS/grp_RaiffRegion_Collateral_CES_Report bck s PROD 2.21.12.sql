------------------------------------------------------------------------------------------------------------
-- Procedure for calculating wcv for collaterals for CES report
--
-- History:
-- 29.10.2015 Ziga MID 42459 - created
-- 10.11.2015 Ziga; MID 42459 - modifications for connected partners
-- 18.11.2015 Ziga; MID 42459 - added new insurances PA, PB, PC for RLHR for additional collaterals
-- 23.11.2015 Ziga MID 42459 - modifications according to RLHR comments
-- 01.12.2015 Ziga MID 42459 - modifications according to RLHR and RLRS comments for CES
-- 04.01.2016 Ziga; MID 42462 - changed logic for resaled lease objects
-- 03.02.2016 Ziga; MID 42459 - added new insurances 50, K3, K4, K5 for RLSI for additional collaterals for real estates and physical collaterals
-- 21.04.2016 Ziga; MID 56484 - removed insurances 50, and K5 for RLSI
------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[grp_RaiffRegion_Collateral_CES_Report]
	@id_kupca char(6),
	@temp_tale_coll_result_name varchar(50) = null,
	@temp_tale_coll_insurances_result_name varchar(50) = null
AS BEGIN
-- check for inut paramteres
if @id_kupca is null or rtrim(ltrim(@id_kupca)) = '' begin
	RAISERROR('Partner must be defined as input parameter.', 16, 1)
	RETURN
end
declare @target_date datetime, @first_day_of_month datetime
set @target_date = dbo.gfn_GetDatePart(getdate())
set @first_day_of_month = dbo.gfn_GenerateDateTime(year(@target_date), month(@target_date), 1)
declare @company_id varchar(10), @id_tec_prod_eur char(3)
set @company_id = (select entity_name from dbo.loc_nast)
set @id_tec_prod_eur = (case when @company_id = 'RLHR' then '006' when @company_id in ('RLBH','RLRS','RRRS') then '001' else '000' end)
-- EXCLUDE LEASE TYPES
select id_key as nacin_leas
into #exclude_lease_types
from dbo.gfn_g_register_active('RL_REGION_EXCLUDE_LEASE_TYPES', null)
-- CONTRACT CANDIDATES
create table #contract_candidates (id_cont int primary key, status_akt char(1), id_pog char(11))
create table #partner_candidates (id_kupca char(6) primary key)
-- partner candidates (could be one partner or more partners (connected partners))
select id_grupe
into #partner_grupe
from dbo.pov_part
where id_kupca = @id_kupca
union
select id_grupe
from dbo.pov_part
where id_kupcab = @id_kupca
insert into #partner_candidates(id_kupca)
select id_kupca as id_kupca
from dbo.pov_part where id_grupe in (select id_grupe from #partner_grupe)
union
select id_kupcab as id_kupca
from dbo.pov_part where id_grupe in (select id_grupe from #partner_grupe)
union
select @id_kupca as id_kupca
-- contract candidates
insert into #contract_candidates(id_cont, status_akt, id_pog)
select po.id_cont, po.status_akt, po.id_pog
from #partner_candidates pa
inner join dbo.pogodba po on po.id_kupca = pa.id_kupca
where po.status_akt in ('A','N','D')
and po.nacin_leas not in (select nacin_leas from #exclude_lease_types)
-- frame candidates
select fl.id_frame
into #frame_candidates
from dbo.frame_list fl
inner join #partner_candidates pa on pa.id_kupca = fl.id_kupca
left join (
	select sum(case when po.status_akt in ('A','N','D') then 1 else 0 end) as co_no, f.id_frame
	from dbo.frame_list f
	inner join #partner_candidates pa on pa.id_kupca = f.id_kupca
	inner join dbo.frame_pogodba fp on fp.id_frame = f.id_frame
	inner join dbo.POGODBA po on po.id_cont = fp.id_cont
	group by f.id_frame
) fc on fc.id_frame = fl.id_frame
where fl.status_akt = 'A' or (fl.status_akt = 'Z' and fc.co_no > 0)
-- collection contract candidates
select kp.ID_KROV_POG
into #krov_pog_candidates
from dbo.KROV_POG kp
inner join #partner_candidates pa on pa.id_kupca = kp.id_kupca
-- LOCAL CURRENCY
select id_tec
into #local_currency
from dbo.tecajnic
where (id_tec = '000' or id_val = 'EUR')
-- MAX_DAT_ZAP for single contract
select pp.id_cont, max(pp.max_dat_zap_total) as ex_max_dat_zap
into #contract_max_dat_zap
from planp_ds pp
inner join #contract_candidates c on c.id_cont = pp.id_cont
group by pp.id_cont
create clustered index ix_max_dat_zap_id_cont on #contract_max_dat_zap (id_cont)
-- B2OPPROD
create table #b2opprod([null] int)
exec dbo.grp_RaiffRegion_B2Opprod '#b2opprod'
create index ix_b2opprod on #b2opprod(id_vrste)
-- B2COLLAT
create table #b2collat([null] int)
exec dbo.grp_RaiffRegion_B2Collat '#b2collat'
create index ix_b2collat on #b2collat(id_obl_zav, id_hipot)
-- KOLATERALI - MAIN TABLE
create table #collaterals_all
(collateral_id varchar(50), collateral_type_internal varchar(10), collateral_subtype_internal varchar(10), id_dokum int, id_dokum_orig int, id_cont int, id_kupca char(6), id_kupca_coll char(6), id_hipot char(5), id_tec char(3),
 expiry_date datetime, prior_claims_amount decimal(18,2), purchase_price decimal(18,2), nominal_value decimal(18,2), wcov decimal(18,2), ponder decimal(8,4), hx_rate decimal(8,4), discount_for_mortages decimal(8,4),
 collateral_type_rank int, collateral_rank int, is_krov_dok bit, collateral_from_contract bit, collateral_is_ownership bit, last_appraisal_date datetime, alloc_type varchar(10), collateral_insurance_ok bit
)
create index ix_collaterals_lease_object_id_cont on #collaterals_all (id_cont)
 -- UTAJE za PON kolaterale
select d.id_dokum, d.id_cont, d.velja_do, d.zacetek
into #dokument_utaje
from dbo.dokument d
inner join #contract_candidates pc on pc.id_cont = d.id_cont
inner join (
	select max(d.id_dokum) as id_dokum, d.id_cont
	from dbo.dokument d
	inner join #contract_candidates cc on cc.id_cont = d.id_cont
	inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
	where d.status_akt = 'A'
	and d.ima = 1
	and dk.sifra = 'UTAJ'
	group by d.id_cont
) dm on dm.id_dokum = d.id_dokum
create index ix_dokument_resaled_id_cont on #dokument_utaje (id_cont)
-- RESALED ASSET (odvzet in prodan predmet)
select d.id_dokum, d.id_cont, po.id_kupca, po.id_kupca as id_kupca_coll, cast(null as char(5)) as id_hipot, d.id_obl_zav, d.id_tec, d.dat_korig_vred, d.velja_do,
		0 as purchase_price,
		0 as nominal_value,
		0 as wcov,
		0 as ponder,
		0 as hx_rate,
		d.dat_ocene
into #dokument_resaled
from dbo.dokument d
inner join #contract_candidates pc on pc.id_cont = d.id_cont
inner join dbo.pogodba po on po.id_cont = d.id_cont
inner join (
	select max(d.id_dokum) as id_dokum, d.id_cont
	from dbo.dokument d
	inner join #contract_candidates cc on cc.id_cont = d.id_cont
	inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
	where d.status_akt = 'A'
	and d.ima = 1
	and dk.sifra = 'RESA'
	group by d.id_cont
) dm on dm.id_dokum = d.id_dokum
create index ix_dokument_resaled_id_cont on #dokument_resaled (id_cont)
-- REPOSSESED ASSET (odvzet predmet financiranja)
select d.id_dokum, d.id_cont, po.id_kupca, po.id_kupca as id_kupca_coll, d.id_hipot, d.id_obl_zav, IsNull(d.id_tec, '000') as id_tec, d.dat_korig_vred, d.velja_do,
		-- purchase_price
		IsNull(d.ocen_vred, 0) as purchase_price,
		-- nominal value
		IsNull(d.ocen_vred, 0) * (IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 0), 100) / 100) as nominal_value,
		-- arv (wcov) - adjusted realization value
		case when @company_id in ('RLRS','RRRS')
				then 0
				else
					case when vo.tip_opr != 'N'
							then
								IsNull(d.ocen_vred, 0) * (IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 1), 100) / 100)
							else
								IsNull(d.ocen_vred, 0) * (IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 0), 100) / 100)
					end
		end as wcov,
		-- ponder
		(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 0), 100) / 100) as ponder,
		-- hx_rate
		case when vo.tip_opr != 'N'
				then (dbo.gfn_GetValueTableAdditionalFactor('HXRATE', IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) / 100)
				else 0
		end as hx_rate,
		d.dat_ocene,
		d.ocen_vred
into #dokument_repossesed
from dbo.dokument d
inner join #contract_candidates pc on pc.id_cont = d.id_cont
inner join dbo.pogodba po on po.id_cont = d.id_cont
inner join dbo.vrst_opr vo on vo.id_vrste = po.id_vrste
inner join (
	select max(d.id_dokum) as id_dokum, d.id_cont
	from dbo.dokument d
	inner join #contract_candidates cc on cc.id_cont = d.id_cont
	inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
	where dk.sifra = 'REAS'
	and d.status_akt = 'A'
	and d.ima = 1
	group by d.id_cont
) dm on dm.id_dokum = d.id_dokum
create index ix_dokument_repossesed_id_cont on #dokument_repossesed (id_cont)
-- TAKEOVER CONTRACTS (prevzete pogodbe)
select d.id_dokum, d.id_cont, dbo.gfn_GetInitialContractForTakeOver(d.id_cont) as id_cont_initial, po.id_kupca, po.id_kupca as id_kupca_coll, cast(null as char(5)) as id_hipot,
		d.id_obl_zav, IsNull(d.id_tec, '000') as id_tec, d.dat_korig_vred, e.ex_max_dat_zap as velja_do,
		-- purchase price
		IsNull(d.vrednost, 0) as purchase_price,
		-- nominal value
		IsNull(d.vrednost, 0) * (IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, po.id_vrste, null, 0), 100) / 100) as nominal_value,
		-- arv (wcov) - adjusted realization value
		IsNull(d.vrednost, 0) * (IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, po.id_vrste, null, 1), 100) / 100) as wcv,
		-- ponder
		(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, po.id_vrste, null, 0), 100) / 100) as ponder,
		-- hx_rate
		(dbo.gfn_GetValueTableAdditionalFactor('HXRATE', IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) / 100) as hx_rate,
		-- last appraisal date
		case when day(IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) <= day(@target_date)
				then dbo.gfn_GenerateDateTime(year(@target_date), month(@target_date), day(IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))))
				else dbo.gfn_GenerateDateTime2(year(dateadd(mm, -1, @target_date)), month(dateadd(mm, -1, @target_date)), day(IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))), 1, null)
		end as last_appraisal_date
into #dokument_takeover
from dbo.dokument d
inner join #contract_candidates pc on pc.id_cont = d.id_cont
inner join dbo.pogodba po on po.id_cont = pc.id_cont
left join #contract_max_dat_zap e on e.id_cont = po.id_cont
left join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
inner join (
	select max(d.id_dokum) as id_dokum, d.id_cont
	from dbo.dokument d
	inner join #contract_candidates cc on cc.id_cont = d.id_cont
	where d.id_obl_zav = 'TV'
	and d.kategorija1 = 'PU'
	and d.status_akt = 'A'
	and d.ima = 1
	group by d.id_cont
) dm on dm.id_dokum = d.id_dokum
create index ix_dokument_takeover_id_cont on #dokument_takeover (id_cont)
-- 1.) OPC KOLATERALI - INDIVIDUALNE EVALUACIJE
insert into #collaterals_all
select 'OPC-' + po.id_pog as collateral_id,
		'IE' as collateral_type_internal,
		case when re.id_cont is not null then 'RE'
			 when ra.id_cont is not null then 'RA'
			 else ''
		end as collateral_subtype_internal,
		case when re.id_cont is not null then re.id_dokum
			 when ra.id_cont is not null then ra.id_dokum
			 else d.id_dokum
		end as id_dokum,
		d.id_dokum as id_dokum_orig,
		d.id_cont,
		po.id_kupca,
		po.id_kupca as id_kupca_coll,
		case when re.id_cont is not null then re.id_hipot
			 when ra.id_cont is not null then ra.id_hipot
			 else d.id_hipot
		end as id_hipot,
		case when re.id_cont is not null then re.id_tec
			 when ra.id_cont is not null then ra.id_tec
			 else d.id_tec
		end as id_tec,
		-- expiry_date
		case when @company_id = 'RLHR' and re.id_cont is not null then re.velja_do
			 when ra.id_cont is not null then ra.velja_do
			 else d.velja_do
		end as expiry_date,
		-- prior claims amount
		0 as prior_claims_amount,
		-- purchase_price
		case when re.id_cont is not null then re.purchase_price
			 when ra.id_cont is not null then ra.purchase_price
			 else x3.znesek
		end as purchase_price,
		-- nominal value
		case when re.id_cont is not null then re.nominal_value
			 when ra.id_cont is not null then ra.nominal_value
			 else x1.znesek
		end as nominal_value,
		-- arv (wcov) - adjusted realization value
		case when re.id_cont is not null then re.wcov
			 when ra.id_cont is not null then ra.wcov
			 else x2.znesek
		end as wcov,
		-- ponder
		case when re.id_cont is not null then re.ponder
			 when ra.id_cont is not null then ra.ponder
			 else (IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 0), 100) / 100)
		end as ponder,
		-- hx_rate
		case when re.id_cont is not null then re.hx_rate
			 when ra.id_cont is not null then ra.hx_rate
			 else (dbo.gfn_GetValueTableAdditionalFactor('HXRATE', IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) / 100)
		end as hx_rate,
		1 as discount_for_mortages,
		1 as collateral_type_rank,
		1 as collateral_rank,
		0 as is_krov_dok,
		1 as collateral_from_contract,
		1 as collateral_is_ownership,
		case when @company_id = 'RLHR' and re.id_cont is not null then re.dat_ocene
			 when ra.id_cont is not null then ra.dat_ocene
			 else d.dat_ocene
		end as last_appraisal_date,
		null as alloc_type,
		1 as collateral_insurance_ok
from dbo.dokument d
inner join #contract_candidates cc on cc.id_cont = d.id_cont
inner join #contract_candidates pc on pc.id_cont = d.id_cont
inner join dbo.pogodba po on po.id_cont = pc.id_cont
inner join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
inner join dbo.vrst_opr vo on vo.id_vrste = po.id_vrste
left join #dokument_resaled re on re.id_cont = po.id_cont
left join #dokument_repossesed ra on ra.id_cont = po.id_cont
inner join (
	select max(d.id_dokum) as id_dokum, d.id_cont
	from dbo.dokument d
	inner join #contract_candidates cc on cc.id_cont = d.id_cont
	inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
	where dk.sifra = 'INEV'
	and d.status_akt = 'A'
	and d.ima = 1
	group by d.id_cont
) ie on ie.id_dokum = d.id_dokum
-- neponderirana vrednost v EUR PROD
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, case when @company_id = 'RLSI' then IsNull(d.ocen_vred, 0) else IsNull(d.vrednost, 0) end, d.id_tec, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) x3a
-- neponderirana vrednost v tecajnici dokumenta IE
outer apply dbo.gfn_xchange_table(d.id_tec, x3a.znesek, @id_tec_prod_eur, @target_date) x3
-- ponderirana vrednost brez HX v EUR PROD
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, case when @company_id = 'RLSI' then IsNull(d.ocen_vred, 0) else IsNull(d.vrednost, 0) end * (IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_ak
tiv, po.dat_sklen)), @target_date, null, d.id_hipot, 0), 100) / 100), d.id_tec, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) x1a
-- ponderirana vrednost brez HX v tecajnici dokumenta IE
outer apply dbo.gfn_xchange_table(d.id_tec, x1a.znesek, @id_tec_prod_eur, @target_date) x1
-- ponderirana vrednost s HX v EUR PROD
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, case when @company_id = 'RLSI' then IsNull(d.ocen_vred, 0) else IsNull(d.vrednost, 0) end * (IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(d.dat_korig_vred, IsNull(po.dat_ak
tiv, po.dat_sklen)), @target_date, null, d.id_hipot, 1), 100) / 100), d.id_tec, IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) x2a
-- ponderirana vrednost s HX v tecajnici dokumenta IE
outer apply dbo.gfn_xchange_table(d.id_tec, x2a.znesek, @id_tec_prod_eur, @target_date) x2
where vo.tip_opr != 'N'
and re.id_dokum is null
-- 2.) OPC KOLATERALI PON - IZ POGODBE (RAZEN v primeru RA, RE in TV iz dokumentacije)
-- insret into temporary table because of performances
select po.id_cont,
		IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(po.dat_aktiv, po.dat_sklen), @target_date, po.id_vrste, null, 0), 100) / 100 as ponder_no_hx,
		IsNull(dbo.gfn_RaiffRegionGetValueTableFactor4CESReport(@company_id, IsNull(po.dat_aktiv, po.dat_sklen), @target_date, po.id_vrste, null, 1), 100) / 100 as ponder_hx
into #contract_ponders_pon
from #contract_candidates pc
inner join dbo.POGODBA po on po.id_cont = pc.id_cont
inner join dbo.vrst_opr vo on vo.id_vrste = po.id_vrste
inner join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
inner join dbo.dav_stop ds on ds.id_dav_st = IsNull(po.id_dav_op, po.id_dav_st)
inner join #contract_candidates cc on cc.id_cont = po.id_cont
-- not exists as individual evaluation
where not exists (
	select c.id_cont
	from #collaterals_all c
	where c.id_cont = po.id_cont
)
and vo.tip_opr != 'N'
create index ix_contract_ponders_pon_id_cont on #contract_ponders_pon (id_cont)
insert into #collaterals_all
select 'OPC-' + po.id_pog as collateral_id,
		'PON' as collateral_type_internal,
		case when re.id_cont is not null then 'RE'
			 when ra.id_cont is not null then 'RA'
			 when tv.id_cont is not null then 'TV'
			 else ''
		end as collateral_subtype_internal,
		case when re.id_cont is not null then re.id_dokum
			 when ra.id_cont is not null then ra.id_dokum
			 when tv.id_cont is not null then tv.id_dokum
			 else null
		end as id_dokum,
		null as id_dokum_orig,
		po.id_cont,
		po.id_kupca,
		po.id_kupca as id_kupca_coll,
		case when re.id_cont is not null then re.id_hipot
			 when ra.id_cont is not null then ra.id_hipot
			 when tv.id_cont is not null then tv.id_hipot
			 else null
		end as id_hipot,
		case when re.id_cont is not null then re.id_tec
			 when ra.id_cont is not null then ra.id_tec
			 else isnull(nt.id_tec_new, po.id_tec)
		end as id_tec,
		-- expiry_date
		case when @company_id = 'RLHR' and re.id_cont is not null then re.velja_do
			 when ra.id_cont is not null then ra.velja_do
			 when ut.id_cont is not null and ut.zacetek is not null then ut.zacetek
			 else (case when e.ex_max_dat_zap > @target_date then e.ex_max_dat_zap else dateadd(dd, 1, @target_date) end)
		end as expiry_date,
		-- prior claims amount
		0 as prior_claims_amount,
		-- fair market value
		case when re.id_cont is not null then re.purchase_price
			 when ra.id_cont is not null then ra.purchase_price
			 when tv.id_cont is not null then xfmv.znesek
			 else x3.znesek
		end as purchase_price,
		-- nominal value
		case when re.id_cont is not null then re.nominal_value
			 when ra.id_cont is not null then ra.nominal_value
			 when tv.id_cont is not null then xnv.znesek
			 else x1.znesek
		end as nominal_value,
		-- arv (wcov) - adjusted realization value
		case when re.id_cont is not null then re.wcov
			 when ra.id_cont is not null then ra.wcov
			 when tv.id_cont is not null then xwcov.znesek
			 else x2.znesek
		end as wcov,
		-- ponder
		case when re.id_cont is not null then re.ponder
			 when ra.id_cont is not null then ra.ponder
			 when tv.id_cont is not null then tv.ponder
			 else ponder_no_hx
		end as ponder,
		-- hx_rate
		case when re.id_cont is not null then re.hx_rate
			 when ra.id_cont is not null then ra.hx_rate
			 when tv.id_cont is not null then tv.hx_rate
			 else (dbo.gfn_GetValueTableAdditionalFactor('HXRATE', IsNull(po.dat_aktiv, po.dat_sklen)) / 100)
		end as hx_rate,
		1 as discount_for_mortages,
		1 as collateral_type_rank,
		1 as collateral_rank,
		0 as is_krov_dok,
		1 as collateral_from_contract,
		1 as collateral_is_ownership,
		case when @company_id = 'RLHR' and re.id_cont is not null then re.dat_ocene
			 when ra.id_cont is not null then ra.dat_ocene
			 when tv.id_cont is not null then tv.last_appraisal_date
			 else
				case when day(IsNull(po.dat_aktiv, po.dat_sklen)) <= day(@target_date)
								then dbo.gfn_GenerateDateTime(year(@target_date), month(@target_date), day(IsNull(po.dat_aktiv, po.dat_sklen)))
								else dbo.gfn_GenerateDateTime2(year(dateadd(mm, -1, @target_date)), month(dateadd(mm, -1, @target_date)), day(IsNull(po.dat_aktiv, po.dat_sklen)), 1, null)
				end
		end as last_appraisal_date,
		null as alloc_type,
		1 as collateral_insurance_ok
from #contract_candidates pc
inner join dbo.pogodba po on po.id_cont = pc.id_cont
inner join dbo.vrst_opr vo on vo.id_vrste = po.id_vrste
inner join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
inner join dbo.dav_stop ds on ds.id_dav_st = IsNull(po.id_dav_op, po.id_dav_st)
inner join #contract_candidates cc on cc.id_cont = po.id_cont
inner join #contract_ponders_pon pd on pd.id_cont = po.id_cont
left join #contract_max_dat_zap e on e.id_cont = po.id_cont
left join #dokument_resaled re on re.id_cont = po.id_cont
left join #dokument_repossesed ra on ra.id_cont = po.id_cont
left join #dokument_utaje ut on ut.id_cont = po.id_cont
left join #dokument_takeover tv on tv.id_cont = po.id_cont
left join (select id_tec, nullif(id_tec_new, '') as id_tec_new from dbo.tecajnic) nt on nt.id_tec = po.id_tec
-- neponderirana vrednost v EUR PROD
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, dbo.gfn_VrValToNetoInternal(po.vr_val_zac, po.robresti_zac, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto), po.id_tec, IsNull(po.dat_aktiv, po.dat_sklen)) x3a
-- neponderirana vrednost v tecajnici dokumenta IE
outer apply dbo.gfn_xchange_table(po.id_tec, x3a.znesek, @id_tec_prod_eur, @target_date) x3
-- ponderirana vrednost brez HX v EUR PROD
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, 
	dbo.gfn_VrValToNetoInternal(po.vr_val_zac, po.robresti_zac, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto) * ponder_no_hx,
	IsNull(nt.id_tec_new, po.id_tec), IsNull(po.dat_aktiv, po.dat_sklen)) x1a
-- ponderirana vrednost brez HX v pogodbeni tecajnici
outer apply dbo.gfn_xchange_table(IsNull(nt.id_tec_new, po.id_tec),
	x1a.znesek,
	@id_tec_prod_eur, @target_date) x1
	-- ponderirana vrednost brez HX v EUR PROD
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, 
	dbo.gfn_VrValToNetoInternal(po.vr_val_zac, po.robresti_zac, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto) * ponder_hx,
	IsNull(nt.id_tec_new, po.id_tec), IsNull(po.dat_aktiv, po.dat_sklen)) x2a
-- ponderirana vrednost brez HX v pogodbeni tecajnici
outer apply dbo.gfn_xchange_table(IsNull(nt.id_tec_new, po.id_tec), x2a.znesek, @id_tec_prod_eur, @target_date) x2
-- values for dicument TV (takeover contracts)
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, tv.purchase_price, tv.id_tec, IsNull(tv.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) xfmv1
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, tv.nominal_value, tv.id_tec, IsNull(tv.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) xnv1
outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, tv.wcv, tv.id_tec, IsNull(tv.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen))) xwcv1
outer apply dbo.gfn_xchange_table(isnull(nt.id_tec_new, po.id_tec), xfmv1.znesek, @id_tec_prod_eur, @target_date) xfmv
outer apply dbo.gfn_xchange_table(isnull(nt.id_tec_new, po.id_tec), xnv1.znesek, @id_tec_prod_eur, @target_date) xnv
outer apply dbo.gfn_xchange_table(isnull(nt.id_tec_new, po.id_tec), xwcv1.znesek, @id_tec_prod_eur, @target_date) xwcov
-- not exists as individual evaluation
where not exists (
	select c.id_cont
	from #collaterals_all c
	where c.id_cont = po.id_cont
)
and vo.tip_opr != 'N'
and re.id_dokum is null
-- 3.) NEPREMICNINE IN OSTALI KOLATERALI (LASTNISTVO NEPREMICNINE, HIPOTEKE, ZALOGE, GARANCIJE, CASH,...)
-- dok.sifra:
-- NELA -> NEPREMIČNINE LASTNIŠTVO
-- HIPT -> HIPOTEKE
-- ZALN -> ZALOGA NEPREMIČNINE
-- ZALP -> ZALOGA PREMIČNINE
-- GARB -> GARANCIJE BANČNE
-- GARK -> GARANCIJE KORPORATIVNE
-- CASH -> CASH (DEPOZIT)
-- LIFE -> ŽIVLJENJSKO ZAVAROVANJE
-- Za RLHR: C2 in C3 -> dvostrane in trostrane CESIJE
-- candidates for othe collaterals (contrat and collection collaterals)
-- contract collaterals -> ownership of real estate (can be repossesed or resaled)
select 'COLL-' + po.id_pog as collateral_id,
		'NELA' as collateral_type_internal,
		case when re.id_dokum is not null
				then 'RE'
			when ra.id_dokum is not null
				then 'RA'
			else ''
		end as collateral_subtype_internal,
		case when re.id_dokum is not null
				then re.id_dokum
			when ra.id_dokum is not null
				then ra.id_dokum
			else d.id_dokum
		end as id_dokum,
		d.id_dokum as id_dokum_orig,
		d.ext_id,
		dk.sifra,
		po.id_kupca,
		IsNull(d.id_kupca, po.id_kupca) as id_kupca_coll,
		case when re.id_dokum is not null
				then re.id_hipot
			when ra.id_dokum is not null
				then ra.id_hipot
			else d.id_hipot
		end as id_hipot,
		d.id_cont, null as id_frame, null as id_krov_pog, cast(0 as bit) as is_krov_dok,
		case when re.id_dokum is not null
				then cast(0 as decimal(18,2))
			 when ra.id_dokum is not null
				then ra.ocen_vred
			else case when @company_id = 'RLSI' then d.ocen_vred else d.vrednost end
		end as vrednost,
		case when re.id_dokum is not null
				then cast(0 as decimal(18,2))
			 when ra.id_dokum is not null
				then cast(0 as decimal(18,2))
			else IsNull(d.zn_prednos, 0)
		end as zn_prednos,
		case when re.id_dokum is not null
				then re.id_tec
			 when ra.id_dokum is not null
				then ra.id_tec
			 else
				d.id_tec
		end as id_tec,
		case when re.id_dokum is not null
				then re.dat_ocene
			 when ra.id_dokum is not null
				then ra.dat_ocene
			 else
				d.dat_ocene
		end as dat_ocene,
		case when re.id_dokum is not null
				then re.velja_do
			 when ra.id_dokum is not null
				then ra.velja_do
			 else
				d.velja_do
		end as velja_do,
		case when re.id_dokum is not null
				then re.ponder
			 when ra.id_dokum is not null
				then ra.ponder
			 else
				(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor(IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 0), 100) / 100)
		end as ponder,
		case when re.id_dokum is not null
				then re.ponder
			 when ra.id_dokum is not null
				then ra.ponder
			 else
				(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor(IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 0), 100) / 100)
		end as ponder_with_hx,
		cast(0 as decimal(8,4)) as hx_rate,
		bc.priority_for_allocation_amount as collateral_type_rank, bc.property_or_object_rank, null as alloc_type,
		1 as collateral_is_ownership
into #other_collaterals_candidates
from dbo.dokument d
inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
inner join #contract_candidates cc on cc.id_cont = d.id_cont
inner join dbo.pogodba po on po.id_cont = cc.id_cont
inner join dbo.vrst_opr vo on vo.id_vrste = po.id_vrste
left join #dokument_resaled re on re.id_cont = po.id_cont
left join #dokument_repossesed ra on ra.id_cont = po.id_cont
left join #b2collat bc on bc.id_obl_zav = d.id_obl_zav and (d.id_hipot = bc.id_hipot or bc.id_hipot = '*')
where dk.sifra in ('NELA','INEV')
and d.status_akt = 'A'
and d.ima = 1
and d.id_obl_zav in (select id_obl_zav from #b2collat)
and vo.tip_opr = 'N'
and re.id_dokum is null
union all
-- contract collaterals
select case when d.ext_id is null or rtrim(ltrim(d.ext_id)) = '' then 'COLL-' + cast(d.id_dokum as varchar(20)) else 'COLL-' + rtrim(ltrim(d.ext_id)) end as collateral_id,
		dk.sifra as collateral_type_internal,
		'' as collateral_subtype_internal,
		d.id_dokum, d.id_dokum as id_dokum_orig, d.ext_id, dk.sifra, po.id_kupca, IsNull(d.id_kupca, po.id_kupca) as id_kupca_coll, d.id_hipot, d.id_cont, null as id_frame, null as id_krov_pog, cast(0 as bit) as is_krov_dok,
		IsNull(case when @company_id = 'RLSI' then d.ocen_vred else d.vrednost end, 0) as vrednost,
		IsNull(d.zn_prednos, 0) as zn_prednos, d.id_tec, d.dat_ocene, d.velja_do,
		(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor(IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 0), 100) / 100) as ponder,
		(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor(IsNull(d.dat_korig_vred, IsNull(po.dat_aktiv, po.dat_sklen)), @target_date, null, d.id_hipot, 1), 100) / 100) as ponder_with_hx,
		(dbo.gfn_GetValueTableAdditionalFactor('HXRATE', IsNull(po.dat_aktiv, po.dat_sklen)) / 100) as hx_rate,
		bc.priority_for_allocation_amount as collateral_type_rank, bc.property_or_object_rank, null as alloc_type,
		0 as collateral_is_ownership
from dbo.dokument d
inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
inner join #contract_candidates cc on cc.id_cont = d.id_cont
inner join dbo.pogodba po on po.id_cont = cc.id_cont
left join #b2collat bc on bc.id_obl_zav = d.id_obl_zav and (d.id_hipot = bc.id_hipot or bc.id_hipot = '*')
where dk.sifra not in ('INEV','NELA')
and d.status_akt = 'A'
and d.ima = 1
and d.id_obl_zav in (select id_obl_zav from #b2collat)
and d.id_krov_dok is null
union all
-- collection collaterals from collection contracts
select case when d.ext_id is null or rtrim(ltrim(d.ext_id)) = '' then 'COLL-' + cast(d.id_dokum as varchar(20)) else 'COLL-' + rtrim(ltrim(d.ext_id)) end as collateral_id,
		dk.sifra as collateral_type_internal,
		'' as collateral_subtype_internal,
		d.id_dokum, d.id_dokum as id_dokum_orig, d.ext_id, dk.sifra, kp.id_kupca, IsNull(d.id_kupca, kp.id_kupca) as id_kupca_coll, d.id_hipot, null as id_cont, null as id_frame, kp.id_krov_pog, cast(1 as bit) as is_krov_dok,
		IsNull(case when @company_id = 'RLSI' then d.ocen_vred else d.vrednost end, 0) as vrednost,
		IsNull(d.zn_prednos, 0) as zn_prednos, d.id_tec, d.dat_ocene, d.velja_do,
		(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor(IsNull(d.dat_korig_vred, @target_date), @target_date, null, d.id_hipot, 0), 100) / 100) as ponder,
		(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor(IsNull(d.dat_korig_vred, @target_date), @target_date, null, d.id_hipot, 1), 100) / 100) as ponder_with_hx,
		(dbo.gfn_GetValueTableAdditionalFactor('HXRATE', IsNull(d.dat_korig_vred, @target_date)) / 100) as hx_rate,
		bc.priority_for_allocation_amount as collateral_type_rank, bc.property_or_object_rank, d.kategorija4 as alloc_type,
		0 as collateral_is_ownership
from dbo.dokument d
inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
inner join dbo.krov_pog kp on kp.id_krov_pog = d.id_krov_pog
inner join #krov_pog_candidates kpc on kpc.ID_KROV_POG = kp.ID_KROV_POG
left join #b2collat bc on bc.id_obl_zav = d.id_obl_zav and (d.id_hipot = bc.id_hipot or bc.id_hipot = '*')
where d.id_krov_pog is not null
and kp.status_akt = 'A'
and dk.sifra not in ('INEV','NELA')
and d.status_akt = 'A'
and d.ima = 1
and d.id_obl_zav in (select id_obl_zav from #b2collat)
union all
-- collection collaterals from frames
select case when d.ext_id is null or rtrim(ltrim(d.ext_id)) = '' then 'COLL-' + cast(d.id_dokum as varchar(20)) else 'COLL-' + rtrim(ltrim(d.ext_id)) end as collateral_id,
		dk.sifra as collateral_type_internal,
		'' as collateral_subtype_internal,
		d.id_dokum, d.id_dokum as id_dokum_orig, d.ext_id, dk.sifra, fl.id_kupca, IsNull(d.id_kupca, fl.id_kupca) as id_kupca_coll, d.id_hipot, null as id_cont, fl.id_frame as id_frame, null as id_krov_pog, cast(1 as bit) as is_krov_dok,
		IsNull(case when @company_id = 'RLSI' then d.ocen_vred else d.vrednost end, 0) as vrednost,
		IsNull(d.zn_prednos, 0) as zn_prednos, d.id_tec, d.dat_ocene, d.velja_do,
		(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor(IsNull(d.dat_korig_vred, @target_date), @target_date, null, d.id_hipot, 0), 100) / 100) as ponder,
		(IsNull(dbo.gfn_RaiffRegionGetValueTableFactor(IsNull(d.dat_korig_vred, @target_date), @target_date, null, d.id_hipot, 1), 100) / 100) as ponder_with_hx,
		(dbo.gfn_GetValueTableAdditionalFactor('HXRATE', IsNull(d.dat_korig_vred, @target_date)) / 100) as hx_rate,
		bc.priority_for_allocation_amount as collateral_type_rank, bc.property_or_object_rank, d.kategorija4 as alloc_type,
		0 as collateral_is_ownership
from dbo.dokument d
inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
inner join dbo.frame_list fl on fl.id_frame = d.id_frame
inner join #frame_candidates flc on flc.id_frame = fl.id_frame
left join #b2collat bc on bc.id_obl_zav = d.id_obl_zav and (d.id_hipot = bc.id_hipot or bc.id_hipot = '*')
where d.id_frame is not null
and dk.sifra not in ('INEV','NELA')
and d.status_akt = 'A'
and d.ima = 1
and d.id_obl_zav in (select id_obl_zav from #b2collat)
create index ix_other_collaterals_candidates on #other_collaterals_candidates(id_dokum)
insert into #collaterals_all
select 
		d.collateral_id,
		d.collateral_type_internal,
		d.collateral_subtype_internal,
		d.id_dokum,
		d.id_dokum_orig,
		d.id_cont,
		d.id_kupca,
		d.id_kupca_coll,
		d.id_hipot,
		d.id_tec,
		-- expiry date
		d.velja_do as expiry_date,
		-- prior claims amount
		IsNull(d.zn_prednos, 0) as prior_claims_amount,
		-- fair market value
		d.vrednost,
		-- nominal value
		case when d.sifra = 'ZALP'
				then d.vrednost * ponder
			 else
				d.vrednost
		end as nominal_value,
		-- arv (wcov) - adjusted realization value
		case when d.sifra in ('HIPT','NELA','ZALN','INEV') then
				case when d.vrednost * d.ponder - d.zn_prednos > 0
							then d.vrednost * d.ponder - d.zn_prednos
							else 0
				end
			 when d.sifra = 'ZALP'
				then d.vrednost * ponder_with_hx
			 when d.sifra = 'GARK'
				then 0
			 else
				d.vrednost * ponder
		end as wcov,
		-- ponder
		d.ponder as ponder,
		-- hx_rate
		case when d.sifra = 'ZALP'
				then d.hx_rate
			else
				0
		end as hx_rate,
		case when d.sifra in ('HIPT','NELA','ZALN','INEV')
				then case when (1 - ((datediff(dd, d.dat_ocene, @target_date) - 183) / 365) * 0.1) > 0 then (1 - ((datediff(dd, d.dat_ocene, @target_date) - 183) / 365) * 0.1) else 0 end
			else 1
		end as discount_for_mortages,
		d.collateral_type_rank,
		d.property_or_object_rank as collateral_rank,
		d.is_krov_dok,
		0 as collateral_from_contract,
		d.collateral_is_ownership,
		d.dat_ocene as last_appraisal_date,
		d.alloc_type,
		1 as collateral_insurance_ok
from #other_collaterals_candidates d
-- resaled documents (RE)
insert into #collaterals_all
select case when vo.tip_opr != 'N' then 'OPC-' + po.id_pog else 'COLL-' + po.id_pog end as collateral_id,
		case when vo.tip_opr = 'N' then 'NELA' when ie.id_dokum is not null then 'IE' else 'PON' end as collateral_type_internal,
		'RE' as collateral_subtype_internal,
		re.id_dokum,
		null as id_dokum_orig,
		re.id_cont,
		re.id_kupca,
		re.id_kupca_coll,
		re.id_hipot,
		re.id_tec,
		re.velja_do as expiry_date,
		cast(0 as decimal(18,2)) as prior_claims_amount,
		re.purchase_price,
		re.nominal_value,
		re.wcov,
		re.ponder,
		re.hx_rate,
		cast(0 as decimal(18,2)) as discount_for_mortages,
		cast(1 as int) as collateral_type_rank,
		1 as collateral_rank,
		0 as is_krov_dok,
		case when vo.tip_opr != 'N' then 1 else 0 end as collateral_from_contract,
		1 as collateral_is_ownership,
		re.dat_ocene as last_appraisal_date,
		null as alloc_type,
		0 as collateral_insurance_ok
from #dokument_resaled re
inner join dbo.pogodba po on po.id_cont = re.id_cont
inner join dbo.vrst_opr vo on vo.id_vrste = po.ID_VRSTE
left join (
	select max(d.id_dokum) as id_dokum, d.id_cont
	from dbo.dokument d
	inner join #contract_candidates cc on cc.id_cont = d.id_cont
	inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
	where dk.sifra = 'INEV'
	and d.status_akt = 'A'
	and d.ima = 1
	group by d.id_cont
) ie on ie.id_cont = re.id_cont
create clustered index ix_collaterals_all_collateral_id on #collaterals_all(collateral_id)
create index ix_collaterals_all_collateral_type_internal on #collaterals_all(expiry_date, collateral_type_internal)
create index ix_collaterals_all_id_dokum on #collaterals_all(id_dokum)
create index ix_collaterals_all_id_cont on #collaterals_all(id_cont)
-- set wcov to 0 for expired contracts (except where leasing object is collateral)
update #collaterals_all set wcov = 0
where (expiry_date is null or expiry_date < @target_date)
and not (collateral_type_internal = 'PON' and (collateral_subtype_internal = '' or collateral_subtype_internal = 'TV'))
-- COLLATERAL INSURANCES
-- OPC collaterals
select di.id_dokum, di.id_obl_zav, di.opis, di.velja_do, di.vrednost, di.ocen_vred, di.id_tec, di.kategorija1, ca.collateral_id
into #collateral_insurances
from #collaterals_all ca
inner join dbo.dokument di on di.id_cont = ca.id_cont
where ca.collateral_type_internal in ('IE', 'PON')
and ca.collateral_from_contract = 1
and (di.ima = 1 or di.kategorija2 = '1')
and (di.status_akt in ('A','E') or (di.status_akt = 'N' and di.dat_zakl >= @first_day_of_month))
and (
	(@company_id in ('RLRS','RRRS') and di.id_obl_zav in ('PV','PS','GP'))
	or (@company_id = 'RLBH' and di.id_obl_zav in ('AK','IS'))
	or (@company_id = 'RLSI' and di.id_obl_zav in ('X1','X2','X3','Y1'))
	or (@company_id = 'RLHR' and di.id_obl_zav in ('BK','OP','AK'))
)
union all
-- REAL ESTATE collaterals -> ownership of real estate (dk.sifra in ('NELA','REAS','RESA'))
select di.id_dokum, di.id_obl_zav, di.opis, di.velja_do, di.vrednost, di.ocen_vred, di.id_tec, di.kategorija1, ca.collateral_id
from #collaterals_all ca
inner join dbo.dokument dc on dc.id_dokum = ca.id_dokum
inner join dbo.dok dk on dk.id_obl_zav = dc.id_obl_zav
inner join dbo.dokument di on di.id_cont = ca.id_cont
where ca.collateral_type_internal = 'NELA'
and (di.ima = 1 or di.kategorija2 = '1')
and (di.status_akt in ('A','E') or (di.status_akt = 'N' and di.dat_zakl >= @first_day_of_month))
and (
	(@company_id = 'RLBH' and di.id_obl_zav in ('IS'))
	or (@company_id = 'RLSI' and di.id_obl_zav in ('Y3','Y4','K3','K4'))
	or (@company_id = 'RLHR' and di.id_obl_zav in ('OP'))
)
union all
-- OTHER collaterals (vsi nepremicninski kolaterali in premicninski kolaterali, ki ne predstavljajo lastnistva)
select di.id_dokum, di.id_obl_zav, di.opis, di.velja_do, di.vrednost, di.ocen_vred, di.id_tec, di.kategorija1, ca.collateral_id
from #collaterals_all ca
inner join dbo.dokument dc on dc.id_dokum = ca.id_dokum
inner join dbo.dok dk on dk.id_obl_zav = dc.id_obl_zav
inner join dbo.dokument di on di.id_pov_dok = dc.id_dokum
where dk.sifra in ('HIPT', 'ZALN', 'ZALP')
and (di.ima = 1 or di.kategorija2 = '1')
and (di.status_akt in ('A','E') or (di.status_akt = 'N' and di.dat_zakl >= @first_day_of_month))
and (
	(@company_id in ('RLRS','RRRS') and di.id_obl_zav in ('OZ','OH'))
	or(@company_id = 'RLBH' and di.id_obl_zav in ('VO','VI'))
	or (@company_id = 'RLSI' and di.id_obl_zav in ('Y3','Y4','K3','K4'))
	or (@company_id = 'RLHR' and di.id_obl_zav in ('PW','PZ','PŽ','OP','PA','PB','PC') and di.kategorija1 = 'V')
)
create index ix_collateral_insurances_collateral_id on #collateral_insurances (collateral_id)
--select 1 as collateral_id, 'A' as id_obl_zav
--into #collateral_insurances
--union select 1, 'B'
--union select 1, 'CD'
--union select 2, 'B'
--union select 2, 'CD'
-- spravimo v en record per collateral_id vse id_obl_zav-e v en stolpec v tabelo #collateral_insurances_grouped
select
	collateral_id,
	IsNull(velja_do, '19000101') as velja_do,
	ROW_NUMBER() OVER (partition by collateral_id order by id_obl_zav, IsNull(velja_do, '19000101')) as row_id,
	ROW_NUMBER() OVER (partition by collateral_id order by id_obl_zav desc, IsNull(velja_do, '19000101') desc) as row_id_desc,
	id_obl_zav
into #collateral_insurances_sorted
from #collateral_insurances
create clustered index pk on #collateral_insurances_sorted (collateral_id, row_id)
;with collateral_insurances as (
	select
		collateral_id,
		row_id,
		row_id_desc,
		case when velja_do >= @target_date then cast('|' + id_obl_zav + '|' as varchar(max)) else '' end as id_obl_zav_sum
	from #collateral_insurances_sorted
	where row_id = 1
	union all
	select
		cis.collateral_id,
		cis.row_id,
		cis.row_id_desc,
		case when velja_do >= @target_date then cast(ci.id_obl_zav_sum + '|' + id_obl_zav + '|' as varchar(max)) else '' end as id_obl_zav_sum
	from collateral_insurances ci
	join #collateral_insurances_sorted cis on cis.collateral_id = ci.collateral_id and cis.row_id = ci.row_id + 1
)
select collateral_id, id_obl_zav_sum
into #collateral_insurances_grouped
from collateral_insurances
where row_id_desc = 1
create clustered index ix_collateral_insurances_grouped_collateral_id on #collateral_insurances_grouped (collateral_id)
-- SET WCV to zero if collateral is not insured
-- OPC collaterals
update #collaterals_all
set wcov = 0, collateral_insurance_ok = 0
from #collaterals_all ca
left join #collateral_insurances_grouped cig on cig.collateral_id = ca.collateral_id
inner join #contract_candidates pc on pc.id_cont = ca.id_cont
inner join dbo.pogodba po on po.id_cont = pc.id_cont
inner join dbo.vrst_opr vo on vo.id_vrste = po.id_vrste
where ca.collateral_type_internal in ('IE', 'PON')
and ca.collateral_from_contract = 1
and pc.status_akt = 'A'
and (
	-- RLSI
	(@company_id = 'RLSI'
	and not (
			(vo.se_regis = ' ' and IsNull(cig.id_obl_zav_sum, '') like '%Y1%')
			 or
			(vo.se_regis = '*' and ((IsNull(cig.id_obl_zav_sum, '') like '%X3%') or (IsNull(cig.id_obl_zav_sum, '') like '%X1%' and IsNull(cig.id_obl_zav_sum, '') like '%X2%')))
			)
	)
	or
	-- RLRS/RRRS
	(@company_id in ('RLRS','RRRS') and not (( IsNull(cig.id_obl_zav_sum, '') like '%PV%' or IsNull(cig.id_obl_zav_sum, '') like '%PS%' or IsNull(cig.id_obl_zav_sum, '') like '%GP%')))
	or 
	-- RLBH
	(@company_id = 'RLBH' and not ((IsNull(cig.id_obl_zav_sum, '') like '%AK%' or IsNull(cig.id_obl_zav_sum, '') like '%IS%')))
	or
	-- RLHR
	(@company_id = 'RLHR' and not (IsNull(cig.id_obl_zav_sum, '') like '%AK%' or IsNull(cig.id_obl_zav_sum, '') like '%BK%' or IsNull(cig.id_obl_zav_sum, '') like '%OP%'))
)
-- REAL ESTATE collaterals -> ownership of real estate (dk.sifra in ('NELA','REAS','RESA','INEV'))
update #collaterals_all
set wcov = 0, collateral_insurance_ok = 0
from #collaterals_all ca
left join #collateral_insurances_grouped cig on cig.collateral_id = ca.collateral_id
inner join #contract_candidates pc on pc.id_cont = ca.id_cont
inner join dbo.dokument dc on dc.id_dokum = ca.id_dokum
inner join dbo.dok dk on dk.id_obl_zav = dc.id_obl_zav
left join #b2collat bc on bc.id_obl_zav = dc.id_obl_zav and (dc.id_hipot = bc.id_hipot or bc.id_hipot = '*')
left join dbo.Nep_enot ne on ne.id_npr_enote = dc.id_npr_enote
where ca.collateral_type_internal = 'NELA'
and pc.status_akt = 'A'
and (
	-- RLSI
	(@company_id = 'RLSI' and not ((IsNull(cig.id_obl_zav_sum, '') like '%Y3%' and IsNull(cig.id_obl_zav_sum, '') like '%Y4%')
									or (IsNull(cig.id_obl_zav_sum, '') like '%K3%' and IsNull(cig.id_obl_zav_sum, '') like '%K4%') 
								  )
	)
	or 
	-- RLBH
	(@company_id = 'RLBH' and not (IsNull(cig.id_obl_zav_sum, '') like '%IS%'))
	or
	-- RLHR
	(@company_id = 'RLHR' and not (IsNull(cig.id_obl_zav_sum, '') like '%OP%'))
)
and charindex(IsNull(ne.tip_neprem, ''), IsNull(bc.real_estate_property_no_insurance, '')) = 0
-- OTHER collaterals (vsi nepremicninski kolaterali in premicninski kolaterali, ki ne predstavljajo lastnistva)
update #collaterals_all
set wcov = 0, collateral_insurance_ok = 0
from #collaterals_all ca
left join #collateral_insurances_grouped cig on cig.collateral_id = ca.collateral_id
inner join dbo.dokument dc on dc.id_dokum = ca.id_dokum
inner join dbo.dok dk on dk.id_obl_zav = dc.id_obl_zav
left join dbo.dokument di on di.id_pov_dok = dc.id_dokum
where dk.sifra in ('HIPT', 'ZALN', 'ZALP')
and (
	-- RLSI
	(@company_id = 'RLSI' and not ((IsNull(cig.id_obl_zav_sum, '') like '%Y3%' and IsNull(cig.id_obl_zav_sum, '') like '%Y4%')
									or (IsNull(cig.id_obl_zav_sum, '') like '%K3%' and IsNull(cig.id_obl_zav_sum, '') like '%K4%') 
								  )
	)
	or
	-- RLRS/RRRS
	(@company_id in ('RLRS','RRRS') and not ((IsNull(cig.id_obl_zav_sum, '') like '%OZ%' or IsNull(cig.id_obl_zav_sum, '') like '%OH%')))
	or 
	-- RLBH
	(@company_id = 'RLBH' and not ((IsNull(cig.id_obl_zav_sum, '') like '%VO%' or IsNull(cig.id_obl_zav_sum, '') like '%VI%')))
	or
	-- RLHR
	(@company_id = 'RLHR' and not (IsNull(cig.id_obl_zav_sum, '') like '%PW%' or IsNull(cig.id_obl_zav_sum, '') like '%PZ%' or IsNull(cig.id_obl_zav_sum, '') like '%PŽ%' or IsNull(cig.id_obl_zav_sum, '') like '%OP%' or IsNull(cig.id_obl_zav_sum, '') like '%
PA%'  or IsNull(cig.id_obl_zav_sum, '') like '%PB%'  or IsNull(cig.id_obl_zav_sum, '') like '%PC%'))
)
-- update for RLHR for real estate ownership if they have 2 contracts in the system (one for land and one for building) - if there is no isnurance for building WCV on land also has to be zero
update #collaterals_all
set wcov = 0, collateral_insurance_ok = 0
from #collaterals_all ca
inner join #contract_candidates pc on pc.id_cont = ca.id_cont
inner join dbo.dokument dc on dc.id_dokum = ca.id_dokum
inner join dbo.dok dk on dk.id_obl_zav = dc.id_obl_zav
where @company_id = 'RLHR'
and ca.collateral_type_internal = 'NELA'
and pc.status_akt = 'A'
and right(rtrim(ltrim(pc.id_pog)), 2) = 'ZM'
and exists (
	select ca1.*
	from #collaterals_all ca1
	inner join #contract_candidates pc1 on pc1.id_cont = ca1.id_cont
	where ca1.collateral_type_internal = 'NELA'
	and pc.status_akt = 'A'
	and ca1.collateral_type_internal = ca.collateral_type_internal
	and ca1.collateral_id != ca.collateral_id
	and left(pc1.id_pog, charindex('/', pc1.id_pog) - 1) = left(pc.id_pog, charindex('/', pc.id_pog) - 1)
	and ca1.collateral_insurance_ok = 0
)
-- Return results
if object_id('tempdb..' + @temp_tale_coll_result_name) is not null begin
	declare @sql_insert varchar(max)
	set @sql_insert = '
	alter table {temp_tale_result_name} add
		collateral_id varchar(50), collateral_type_internal varchar(10), collateral_subtype_internal varchar(10), id_dokum int, id_dokum_orig int, id_cont int, id_kupca char(6), id_hipot char(5), id_kupca_coll char(6), id_tec char(3), expiry_date datetime,
		 prior_claims_amount decimal(18,2), purchase_price decimal(18,2), nominal_value decimal(18,2), wcov decimal(18,2), ponder decimal(8,4),
		 hx_rate decimal(8,4), discount_for_mortages decimal(8,4), collateral_type_rank int, collateral_rank int, is_krov_dok bit, collateral_from_contract bit, collateral_is_ownership bit,
		 last_appraisal_date datetime, alloc_type varchar(10), collateral_insurance_ok bit
	if exists(select * from tempdb.sys.columns where name = ''null'' and object_id = object_id(''tempdb..{temp_tale_result_name}'')) begin
		alter table {temp_tale_result_name} drop column [null]
	end'
	set @sql_insert = replace(@sql_insert, '{temp_tale_result_name}', @temp_tale_coll_result_name)
	exec(@sql_insert)
	set @sql_insert = '
	insert into {temp_tale_result_name}
		(collateral_id, collateral_type_internal, collateral_subtype_internal, id_dokum, id_dokum_orig, id_cont, id_kupca, id_kupca_coll, id_hipot, id_tec, expiry_date,
		 prior_claims_amount, purchase_price, nominal_value, wcov, ponder,
		 hx_rate, discount_for_mortages, collateral_type_rank, collateral_rank, is_krov_dok, collateral_from_contract, collateral_is_ownership,
		 last_appraisal_date, alloc_type, collateral_insurance_ok)
	select collateral_id, collateral_type_internal, collateral_subtype_internal, id_dokum, id_dokum_orig, id_cont, id_kupca , id_kupca_coll, id_hipot, id_tec, expiry_date,
		 prior_claims_amount, purchase_price, nominal_value, wcov, ponder,
		 hx_rate, discount_for_mortages, collateral_type_rank, collateral_rank, is_krov_dok, collateral_from_contract, collateral_is_ownership,
		 last_appraisal_date, alloc_type, collateral_insurance_ok
	from #collaterals_all'
	set @sql_insert = replace(@sql_insert, '{temp_tale_result_name}', @temp_tale_coll_result_name)
	exec(@sql_insert)
end
if object_id('tempdb..' + @temp_tale_coll_insurances_result_name) is not null begin
	set @sql_insert = '
	alter table {temp_tale_coll_insurances_result_name} add
		id_dokum int, id_obl_zav char(2), opis varchar(max), velja_do datetime, vrednost decimal(18,2), ocen_vred decimal(18,2), id_tec char(3), kategorija1 varchar(max), collateral_id varchar(50)
	if exists(select * from tempdb.sys.columns where name = ''null'' and object_id = object_id(''tempdb..{temp_tale_coll_insurances_result_name}'')) begin
		alter table {temp_tale_coll_insurances_result_name} drop column [null]
	end'
	set @sql_insert = replace(@sql_insert, '{temp_tale_coll_insurances_result_name}', @temp_tale_coll_insurances_result_name)
	exec(@sql_insert)
	set @sql_insert = '
	insert into {temp_tale_coll_insurances_result_name}
		(id_dokum, id_obl_zav, opis, velja_do, vrednost, ocen_vred, id_tec, kategorija1, collateral_id)
	select id_dokum, id_obl_zav, opis, velja_do, vrednost, ocen_vred, id_tec, kategorija1, collateral_id
	from #collateral_insurances'
	set @sql_insert = replace(@sql_insert, '{temp_tale_coll_insurances_result_name}', @temp_tale_coll_insurances_result_name)
	exec(@sql_insert)
end
drop table #local_currency
drop table #exclude_lease_types
drop table #contract_candidates
drop table #partner_grupe
drop table #partner_candidates
drop table #contract_max_dat_zap
drop table #b2opprod
drop table #b2collat
drop table #dokument_utaje
drop table #dokument_resaled
drop table #dokument_repossesed
drop table #dokument_takeover
drop table #other_collaterals_candidates
drop table #contract_ponders_pon
drop table #collaterals_all
drop table #collateral_insurances
drop table #collateral_insurances_sorted
drop table #collateral_insurances_grouped
END