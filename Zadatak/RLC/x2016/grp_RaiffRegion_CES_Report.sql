------------------------------------------------------------------------------------------------------------
-- Procedure for calculating wcv for collaterals for CES report
--
-- History:
-- 12.11.2015 Ziga MID 42459 - created
-- 23.11.2015 Ziga MID 42459 - modifications according to RLHR comments
-- 01.12.2015 Ziga MID 42459 - modifications according to RLHR and RLRS comments
-- 07.01.2016 Ziga MID 42459 - added field id_val_pog to analitic result and id_pog_list to sintetic result
-- 09.02.2016 Ziga MID 42459 - modified hx_rate to varchar because it can be shown as interval
------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[grp_RaiffRegion_CES_Report]
	@id_kupca char(6),
	@for_connected_partners bit,
	@id_tec char(3),
	@exch_rate_eur_hrk decimal(20,10),
	@temp_table_ces_analitic_result_name varchar(50) = null,
	@temp_table_ces_sintetic_result_name varchar(50) = null
AS BEGIN
	-- CES report
	declare @target_date datetime, @company_id varchar(100), @pov_part_grupa_opis varchar(200), @id_grupe int
	set @target_date = dbo.gfn_GetDatePart(getdate())
	set @company_id = (select entity_name from dbo.loc_nast)
	set @pov_part_grupa_opis = (
		select top 1 a.opis
			from (
			select gp.OPIS
			from dbo.POV_PART pp
			inner join dbo.grupe_p gp on gp.id_grupe = pp.id_grupe
			where pp.id_kupca = @id_kupca
			union
			select gp.OPIS
			from dbo.POV_PART pp
			inner join dbo.grupe_p gp on gp.id_grupe = pp.id_grupe
			where pp.id_kupcab = @id_kupca) a
	)
	-- local currency
	select id_tec
	into #local_currency
	from dbo.tecajnic
	where id_tec = '000' or id_val = 'EUR'
	-- exclude lease types
	select id_key as nacin_leas
	into #exclude_lease_types
	from dbo.gfn_g_register_active('RL_REGION_EXCLUDE_LEASE_TYPES', null)
	create table #collaterals_wcv ([null] int)
	create table #collaterals_insurance ([null] int)
	create table #collaterals_allocation ([null] int)
	exec dbo.grp_RaiffRegion_Collateral_CES_Report @id_kupca, '#collaterals_wcv', '#collaterals_insurance'
	exec dbo.grp_RaiffRegion_Allocation @target_date, @id_kupca, 'RISK', 0, '#collaterals_allocation', null, 1, 'CES'
	-- partner candidates (could be one partner or more partners (connected partners))
	create table #contract_candidates (id_cont int primary key, status_akt char(1))
	create table #partner_candidates (id_kupca char(6) primary key)
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
	insert into #contract_candidates(id_cont, status_akt)
	select po.id_cont, po.status_akt
	from #partner_candidates pa
	inner join dbo.pogodba po on po.id_kupca = pa.id_kupca
	where po.status_akt in ('A','N','D')
	and po.nacin_leas not in (select nacin_leas from #exclude_lease_types)
	-- MAX_DAT_ZAP for single contract
	select pp.id_cont, max(pp.max_datum_dok_total) as contract_expiry_date
	into #contract_max_dat_zap
	from planp_ds pp
	inner join dbo.pogodba po on po.id_cont = pp.id_cont
	inner join #partner_candidates pa on pa.id_kupca = po.id_kupca
	group by pp.id_cont
	create index ix_contract_candidates_id_cont on #contract_max_dat_zap(id_cont)
	select id_cont, id_tec, total_odr
	into #exposure
	from dbo.gfn_RaiffRegion_Exposure(@target_date) ex
	inner join #partner_candidates pa on pa.id_kupca = ex.id_kupca
	create index ix_exposure_id_cont on #exposure (id_cont)
	-- collection contract candidates
	select kp.id_krov_pog, kp.id_kupca
	into #krov_pog_candidates
	from dbo.KROV_POG kp
	inner join #partner_candidates pa on pa.id_kupca = kp.id_kupca
	-- frame candidates
	select fl.id_frame
	into #frame_candidates_tmp
	from dbo.frame_list fl
	inner join dbo.frame_type ft on ft.id_frame_type = fl.frame_type
	inner join #partner_candidates pa on pa.id_kupca = fl.id_kupca
	left join (
		select sum(case when po.status_akt in ('A','N','D') then 1 else 0 end) as co_no, f.id_frame
		from dbo.frame_list f
		inner join #partner_candidates pa on pa.id_kupca = f.id_kupca
		inner join dbo.frame_pogodba fp on fp.id_frame = f.id_frame
		inner join dbo.POGODBA po on po.id_cont = fp.id_cont
		group by f.id_frame
	) fc on fc.id_frame = fl.id_frame
	where (fl.status_akt = 'A' or (fl.status_akt = 'Z' and fc.co_no > 0))
	and ft.sif_frame_type in ('REV','NET','POG','RNE')
	-- obligo from planp_ds on per contract in frame currency
	select pp.id_cont,
			fl.id_tec,
			sum(dbo.gfn_Xchange(fl.id_tec, pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' then pp.b
od_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end, pp.id_tec, @target_date)) as obligo_rev,
			sum(dbo.gfn_Xchange(fl.id_tec, pp.znp_saldo_ddv + pp.bod_davek_lpod, pp.id_tec, @target_date)) as obligo_rne
	into #obligo_planp_ds
	from dbo.planp_ds pp
	inner join dbo.pogodba po on po.id_cont = pp.id_cont
	inner join dbo.frame_pogodba fp on fp.id_cont = po.id_cont
	inner join dbo.frame_list fl on fl.id_frame = fp.id_frame
	inner join #frame_candidates_tmp fc on fc.id_frame = fl.id_frame
	inner join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
	group by pp.id_cont, fl.id_tec
	-- obligo per frame
	select fl.id_frame,
			sum(case when ft.sif_frame_type = 'POG' then dbo.gfn_Xchange(fl.id_tec, po.vr_val_zac, po.id_tec, po.dat_sklen) else 0 end) as vr_val_fr_type_pog,
			sum(case when ft.sif_frame_type = 'NET' then dbo.gfn_XChange(fl.id_tec, po.net_nal, po.id_tec, po.dat_sklen) else 0 end) as vr_val_fr_type_net,
			sum(case when ft.sif_frame_type = 'REV' then IsNull(o.obligo_rev, dbo.gfn_XChange(fl.id_tec, case when po.status_akt = 'Z' or (po.status_akt = 'A' and datediff(dd, po.dat_aktiv, @target_date) > 5) then 0 else po.vr_val - po.varscina end, po.id_tec, @ta
rget_date)) else 0 end) as vr_val_fr_type_rev,
			sum(case when ft.sif_frame_type = 'RNE' and nl.ddv_takoj = 1 then dbo.gfn_Xchange(fl.id_tec, po.net_nal_zac, po.id_tec, po.dat_sklen) + IsNull(o.obligo_rne, dbo.gfn_XChange(fl.id_tec, case when po.status_akt = 'Z' or (po.status_akt = 'A' and datediff(d
d, po.dat_aktiv, @target_date) > 5) then 0 else po.ddv end, po.id_tec, po.dat_sklen)) else 0 end) as vr_val_fr_type_rne
	into #obligo_frame
	from dbo.pogodba po
	inner join dbo.frame_pogodba fp on fp.id_cont = po.id_cont
	inner join dbo.frame_list fl on fl.id_frame = fp.id_frame
	inner join dbo.frame_type ft on ft.id_frame_type = fl.frame_type
	inner join #frame_candidates_tmp fc on fc.id_frame = fl.id_frame
	inner join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
	left join #obligo_planp_ds o on o.id_cont = po.id_cont
	group by fl.id_frame
	select fl.id_frame, fl.opis, ft.naziv_frame_type, fl.znesek_val, IsNull(fl.limvr_val, 0) as limvr_val,
			fl.id_tec, fl.dat_odobritve, fl.status_akt, fl.limnacin_leas, fl.obr_mera, fl.id_kupca,
			IsNull(fl.limvarscina, 0) as frame_ponder,
			case when ft.sif_frame_type = 'REV' then IsNull(o.vr_val_fr_type_rev, 0)
				 when ft.sif_frame_type = 'POG' then IsNull(o.vr_val_fr_type_pog, 0)
				 when ft.sif_frame_type = 'NET' then IsNull(o.vr_val_fr_type_net, 0)
				 when ft.sif_frame_type = 'RNE' then IsNull(o.vr_val_fr_type_rne, 0)
			end as obligo,
			case when fl.id_tec in (select id_tec from #local_currency) then 'n' else 'y' end as curr_mismatch
	into #frame_candidates
	from #frame_candidates_tmp fc
	inner join dbo.frame_list fl on fl.id_frame = fc.id_frame
	inner join dbo.frame_type ft on ft.id_frame_type = fl.frame_type
	left join #obligo_frame o on o.id_frame = fl.id_frame
	-- zapisniki za opremo
	select zn.id_zapo, zn.id_cont, rtrim(ltrim(zn.parcelne_st)) as parcelne_st, rtrim(ltrim(cast(zn.opis as varchar(max)))) as opis
	into #zap_ner
	from dbo.zap_ner zn
	inner join (
		select max(znm.id_zapo) as max_id_zapo, znm.id_cont
		from dbo.zap_ner znm
		inner join #collaterals_allocation ca on ca.id_cont = znm.id_cont
		group by znm.id_cont
	) zn1 on zn1.max_id_zapo = zn.id_zapo
	-- cesije C2 in C3 za RLHR
	select d.id_dokum
	into #cesije
	from dbo.dokument d
	inner join #contract_candidates cc on cc.id_cont = d.id_cont
	where @company_id = 'RLHR'
	and d.id_obl_zav in ('C2','C3')
	and d.ima = 1
	and d.status_akt = 'A'
	union
	select d.id_dokum
	from dbo.dokument d
	inner join #frame_candidates f on f.id_frame = d.id_frame
	where @company_id = 'RLHR'
	and d.id_obl_zav in ('C2','C3')
	and d.ima = 1
	and d.status_akt = 'A'
	union
	select d.id_dokum
	from dbo.dokument d
	inner join #krov_pog_candidates kp on kp.id_krov_pog = d.id_krov_dok
	where @company_id = 'RLHR'
	and d.id_obl_zav in ('C2','C3')
	and d.ima = 1
	and d.status_akt = 'A'
	-- 1.) ANALITIC RESULT
	-- COLLATERALS
	select cw.collateral_id,
			case when cw.collateral_is_ownership = 1 then 'LEASE OBJECT' else 'ADDITONAL COLLATERAL' end as coll_type_view,
			ltrim(rtrim(po.id_pog)) as id_pog,
			case when cw.collateral_is_ownership = 1 then cast(po.id_vrste as varchar(10)) else null end as code, 
			case when cw.collateral_is_ownership = 1 then rtrim(ltrim(vo.naziv)) else rtrim(ltrim(dck.opis)) end as collateral,
			cast(case when cw.collateral_is_ownership = 1 and cw.collateral_type_internal != 'NELA' then rtrim(ltrim(po.pred_naj)) -- premicnine lastnistvo
				 when cw.collateral_is_ownership = 1 and cw.collateral_type_internal = 'NELA' then left(IsNull(zn.opis, '') + IsNull(zn.parcelne_st, ''), 240) -- nepremicnine lastnistvo
				 else left(rtrim(ltrim(IsNull(dc.opombe, ''))), 240) -- ostali kolaterali iz dokumentacije
			end as varchar(240)) as collateral_desc,
			case when ca.fx_discount = 1 then 'n' else 'y' end as curr_mismatch,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then dbo.gfn_Xchange(@id_tec, ca.exposure_eur, ca.exposure_id_tec_eur, @target_date) else null end as collateral_account,
			case when cw.collateral_type_internal in ('PON','IE') or @company_id != 'RLHR'
					then dbo.gfn_Xchange(@id_tec, cw.purchase_price, cw.id_tec, @target_date)
					else null
			end as purchase_price,
			cast(round(cw.ponder * 100, 2) as decimal(18,2)) as ponder,
			case when cw.collateral_type_internal not in ('GARB','GARK')
					then dbo.gfn_Xchange(@id_tec, cw.nominal_value, cw.id_tec, @target_date)
					else null
			end as nominal_value,
			cast(round(cw.hx_rate * 100, 2) as decimal(18,2)) as hx_rate,
			case when cw.collateral_type_internal not in ('GARB','GARK')
					then dbo.gfn_Xchange(@id_tec, cw.prior_claims_amount, cw.id_tec, @target_date)
					else null
			end as prior_claims_amount,
			case when cw.collateral_type_internal not in ('GARB','GARK')
					then dbo.gfn_Xchange(@id_tec, cw.wcov, cw.id_tec, @target_date)
					else null
			end as wcov,
			100 - (ca.fx_discount * 100) as fx_discount,
			100 - (cw.discount_for_mortages * 100) as discount_for_mortages,
			case when cw.collateral_type_internal not in ('GARB','GARK')
					then dbo.gfn_Xchange(@id_tec, ca.wcv_eur, ca.wcv_id_tec_eur, @target_date)
					else null
			end as wcv,
			case when cw.collateral_type_internal not in ('GARB','GARK')
					then dbo.gfn_Xchange(@id_tec, ca.wcv_delivered_eur, ca.wcv_id_tec_eur, @target_date)
					else null
			end as wcv_delivered,
			case when cw.collateral_type_internal in ('GARB','GARK')
					then dbo.gfn_Xchange(@id_tec, ca.wcv_delivered_eur, ca.wcv_id_tec_eur, @target_date)
					else null
			end as wgv_delivered,
			case when cw.collateral_type_internal in ('GARB','GARK')
					then dbo.gfn_Xchange(@id_tec, cw.wcov, cw.id_tec, @target_date)
					else null
			end as guaranteed_amount,
			case when cw.collateral_is_ownership = 1 then fp.id_frame
				 when dc.id_frame is not null then dc.id_frame
				 else null
			end as id_frame,
			case when cw.collateral_is_ownership = 1 then fl.status_akt
				 when dc.id_frame is not null then fld.status_akt
				 else null
			end as frame_status_akt,
			fl.dat_odobritve as frame_dat_aktiv,
			cw.id_dokum,
			dc.id_obl_zav,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then po.status_akt else null end as status_akt,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then po.dat_aktiv else null end as dat_aktiv,
			cw.expiry_date as collateral_expiry_date,
			case when cw.collateral_type_internal in ('PON', 'IE', 'NELA', 'HIPT', 'ZALN', 'ZALP')
					then cw.collateral_insurance_ok
					else cast(0 as bit)
			end as collateral_insurance_ok,
			case when cw.collateral_is_ownership = 0 and cw.expiry_date < cmz.contract_expiry_date then cast(1 as bit) else cast(0 as bit) end as maturity_mismatch,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then cmz.contract_expiry_date else null end as contract_expiry_date,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then po.nacin_leas else null end as nacin_leas,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then po.obr_mera else null end as obr_mera,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K'
					then dbo.gfn_Xchange(@id_tec, po.net_nal_zac, po.id_tec, IsNull(po.dat_aktiv, po.dat_sklen))
					else null
			end as net_nal_zac,
			po.id_val as id_val_pog,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then dbo.gfn_Xchange(@id_tec, po.obrok1, po.id_tec, po.dat_aktiv) else null end as obrok1,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then dbo.gfn_Xchange(@id_tec, IsNull(ex.total_odr, 0), ex.id_tec, @target_date) else null end as total_odr,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then vo.id_grupe1 else null end as id_grupe1,
			case when cw.collateral_is_ownership = 1 or nl.leas_kred = 'K' then vo.id_grupe else null end as id_grupe,
			case when @company_id in ('RLRS','RRRS','RLBH') then
					  case when id_grupe in ('VNC','VUC','VLT') then 'light vehicles'
						   when id_grupe in ('VHT','VTT','VOW') then 'other vehicles'
						   when id_grupe in ('EFM','EIT','EME','EMM','EOT','EPM','VAM','VBO','VCM','VFR') then 'equipment'
						   when id_grupe in ('RCH','RDS','RHT','RIB','ROB','ROE','RRB') then 'real estate'
						   else 'unknown group'
					  end
				 else null
			end as group_type,
			IsNull(pa.naz_kr_kup, '') as partner_desc,
			pa.id_kupca,
			pa.ext_id as coconut_id,
			@pov_part_grupa_opis as gcc_naziv,
			pe.cust_ratin,
			ca.collateral_rank,
			IsNull(pa_cont.naz_kr_kup, '') as partner_cont_desc,
			po.id_kupca as id_kupca_cont,
			cw.collateral_type_internal,
			cw.collateral_is_ownership,
			cw.is_krov_dok,
			ca.id_cont,
			ca.wcv_id_tec_val as id_tec
	into #result_analitic
	from #collaterals_wcv cw
	left join #collaterals_allocation ca on ca.collateral_id = cw.collateral_id
	left join dbo.partner pa on pa.id_kupca = cw.id_kupca_coll
	left join dbo.gv_PEval_LastEvaluation pe on pe.id_kupca = pa.id_kupca
	left join dbo.pogodba po on po.id_cont = ca.id_cont
	left join dbo.vrst_opr vo on vo.id_vrste = po.id_vrste
	left join dbo.partner pa_cont on pa_cont.id_kupca = po.id_kupca
	left join dbo.gv_PEval_LastEvaluation pe_cont on pe_cont.id_kupca = pa_cont.id_kupca
	left join dbo.dav_stop ds on ds.id_dav_st = IsNull(po.id_dav_op, po.id_dav_st)
	left join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
	left join #contract_max_dat_zap cmz on cmz.id_cont = po.id_cont
	left join #exposure ex on ex.id_cont = po.id_cont
	left join dbo.frame_pogodba fp on fp.id_cont = po.id_cont
	left join dbo.frame_list fl on fl.id_frame = fp.id_frame
	left join dbo.dokument dc on dc.id_dokum = cw.id_dokum
	left join dbo.frame_list fld on fld.id_frame = dc.id_frame
	left join dbo.dok dck on dck.id_obl_zav = dc.id_obl_zav
	left join #zap_ner zn on zn.id_cont = po.id_cont
	where ca.collateral_id is not null
	and (@for_connected_partners = 1 or pa_cont.id_kupca = @id_kupca)
	union all
	-- CESIJE (C2, C3 za RLHR) -> not real collaterals, RLHR wants to view this on CES report (we fill only NCV amount , all other fields are empty)
	select 'COLL-' + cast(d.id_dokum as varchar(50)) as collateral_id,
			'ADDITONAL COLLATERAL' as coll_type_view,
			ltrim(rtrim(po.id_pog)) as id_pog,
			null as code,
			rtrim(ltrim(dk.opis)) as collateral,
			cast(left(rtrim(ltrim(IsNull(d.opombe, ''))), 240) as varchar(240)) as collateral_desc,
			case when po.id_cont is not null and dbo.gfn_GetNewTec(po.id_tec) in (select id_tec from #local_currency) then 'n'
				 when fr.id_frame is not null and dbo.gfn_GetNewTec(fr.id_tec) in (select id_tec from #local_currency) then 'n'
				 when kp.ID_KROV_POG is not null then 'n'
				 else 'y'
			end as curr_mismatch,
			null as collateral_account,
			null as purchase_price,
			null as ponder,
			dbo.gfn_Xchange(@id_tec, d.vrednost, d.id_tec, @target_date) as nominal_value,
			null as hx_rate,
			null as prior_claims_amount,
			null as wcov,
			null as fx_discount,
			null as discount_for_mortages,
			null as wcv,
			null as wcv_delivered,
			null as wgv_delivered,
			null as guaranteed_amount,
			fr.id_frame as id_frame,
			fr.status_akt as frame_status_akt,
			fr.dat_odobritve as frame_dat_aktiv,
			d.id_dokum,
			d.id_obl_zav,
			null as status_akt,
			null as dat_aktiv,
			d.velja_do as collateral_expiry_date,
			cast(0 as bit) as collateral_insurance_ok,
			case when d.id_cont is not null and d.velja_do < cmz.contract_expiry_date then cast(1 as bit) else cast(0 as bit) end as maturity_mismatch,
			null as contract_expiry_date,
			null as nacin_leas,
			null as obr_mera,
			null as net_nal_zac,
			null as id_val_pog,
			null as obrok1,
			null as total_odr,
			null as id_grupe1,
			null as id_grupe,
			null as group_type,
			IsNull(pa_coll.naz_kr_kup, '') as partner_desc,
			pa_coll.id_kupca,
			pa_coll.ext_id as coconut_id,
			@pov_part_grupa_opis as gcc_naziv,
			pe.cust_ratin,
			100 as collateral_rank,
			IsNull(pa_cont.naz_kr_kup, '') as partner_cont_desc,
			po.id_kupca as id_kupca_cont,
			d.id_obl_zav as collateral_type_internal,
			cast(0 as bit) as collateral_is_ownership,
			cast(0 as bit) as is_krov_dok,
			d.id_cont,
			d.id_tec
	from #cesije ce
	inner join dbo.dokument d on d.id_dokum = ce.id_dokum
	inner join dbo.dok dk on dk.id_obl_zav = d.id_obl_zav
	left join dbo.pogodba po on po.id_cont = d.id_cont
	left join dbo.partner pa_cont on pa_cont.id_kupca = po.id_kupca
	left join #frame_candidates fr on fr.id_frame = d.id_frame
	left join #krov_pog_candidates kp on kp.id_krov_pog = d.id_krov_pog
	left join dbo.partner pa_coll on pa_coll.id_kupca = IsNull(d.id_kupca, IsNull(po.id_kupca, IsNull(fr.id_kupca, IsNull(kp.id_kupca, null))))
	left join dbo.gv_PEval_LastEvaluation pe on pe.id_kupca = pa_coll.id_kupca
	left join #contract_max_dat_zap cmz on cmz.id_cont = po.id_cont
	union all
	-- FRAMES
	select '' as collateral_id,
			'FRAME' as coll_type_view,
			null as id_pog,
			cast(fc.id_frame as varchar(15)) as code, 
			fc.opis as collateral,
			fc.naziv_frame_type as collateral_desc,
			fc.curr_mismatch as curr_mismatch,
			case when @company_id in ('RLHR','RLSI') then dbo.gfn_Xchange(@id_tec, fc.znesek_val, fc.id_tec, @target_date)
				 when @company_id in ('RLRS','RRRS','RLBH') then dbo.gfn_Xchange(@id_tec, fc.znesek_val - fc.obligo, fc.id_tec, @target_date) 
			end as collateral_account,
			case when @company_id in ('RLHR','RLSI') then dbo.gfn_Xchange(@id_tec, fc.limvr_val, fc.id_tec, @target_date)
				 when @company_id in ('RLRS','RRRS','RLBH') then dbo.gfn_Xchange(@id_tec, fc.znesek_val - fc.obligo, fc.id_tec, @target_date) 
			end as purchase_price,
			cast(fc.frame_ponder as decimal(18,2)) as ponder,
			case when @company_id in ('RLHR','RLSI') then dbo.gfn_Xchange(@id_tec, fc.limvr_val, fc.id_tec, @target_date) * (fc.frame_ponder / 100.00)
				 when @company_id in ('RLRS','RRRS','RLBH') then dbo.gfn_Xchange(@id_tec, (fc.znesek_val - fc.obligo) * (fc.frame_ponder / 100.00), fc.id_tec, @target_date) 
			end as nominal_value,
			cast(dbo.gfn_GetValueTableAdditionalFactor('HXRATE', fc.dat_odobritve) as decimal(18,2)) as hx_rate,
			cast(0 as decimal(18,2)) as prior_claims_amount,
			case when @company_id in ('RLHR','RLSI') then dbo.gfn_Xchange(@id_tec, fc.limvr_val, fc.id_tec, @target_date) * (fc.frame_ponder / 100.00) * ((100 - dbo.gfn_GetValueTableAdditionalFactor('HXRATE', fc.dat_odobritve)) / 100.00)
				 when @company_id in ('RLRS','RRRS','RLBH') then dbo.gfn_Xchange(@id_tec, (fc.znesek_val - fc.obligo) * (fc.frame_ponder / 100.00), fc.id_tec, @target_date) * ((100 - dbo.gfn_GetValueTableAdditionalFactor('HXRATE', fc.dat_odobritve)) / 100.00)
			end as wcov,
			null as fx_discount,
			null as discount_for_mortages,
			case when @company_id in ('RLHR','RLSI') then dbo.gfn_Xchange(@id_tec, fc.limvr_val, fc.id_tec, @target_date) * (fc.frame_ponder / 100.00) * ((100 - dbo.gfn_GetValueTableAdditionalFactor('HXRATE', fc.dat_odobritve)) / 100.00)
				 when @company_id in ('RLRS','RRRS','RLBH') then dbo.gfn_Xchange(@id_tec, (fc.znesek_val - fc.obligo) * (fc.frame_ponder / 100.00), fc.id_tec, @target_date) * ((100 - dbo.gfn_GetValueTableAdditionalFactor('HXRATE', fc.dat_odobritve)) / 100.00)
			end as wcv,
			case when @company_id in ('RLHR','RLSI') then dbo.gfn_Xchange(@id_tec, fc.limvr_val, fc.id_tec, @target_date) * (fc.frame_ponder / 100.00) * ((100 - dbo.gfn_GetValueTableAdditionalFactor('HXRATE', fc.dat_odobritve)) / 100.00)
				 when @company_id in ('RLRS','RRRS','RLBH') then dbo.gfn_Xchange(@id_tec, (fc.znesek_val - fc.obligo) * (fc.frame_ponder / 100.00), fc.id_tec, @target_date) * ((100 - dbo.gfn_GetValueTableAdditionalFactor('HXRATE', fc.dat_odobritve)) / 100.00)
			end as wcv_delivered,
			null as wgv_delivered,
			null as guaranteed_amount,
			fc.id_frame,
			fc.status_akt as frame_status_akt,
			fc.dat_odobritve as frame_dat_aktiv,
			null as id_dokum,
			null as id_obl_zav,
			null as status_akt,
			null as dat_aktiv,
			null as collateral_expiry_date,
			cast(0 as bit) as collateral_insurance_ok,
			cast(0 as bit) as maturity_mismatch,
			null as contract_expiry_date,
			fc.limnacin_leas,
			fc.obr_mera,
			dbo.gfn_Xchange(@id_tec, fc.znesek_val, fc.id_tec, @target_date) as net_nal_zac,
			null as id_val_pog,
			null as obrok1,
			null as total_odr,
			null as id_grupe1,
			null as id_grupe,
			null as group_type,
			IsNull(pa.naz_kr_kup, '') as partner_desc,
			fc.id_kupca,
			pa.ext_id as coconut_id,
			@pov_part_grupa_opis as gcc_naziv,
			pe.cust_ratin,
			100 as collateral_rank,
			IsNull(pa.naz_kr_kup, '') as partner_cont_desc,
			fc.id_kupca as id_kupca_cont,
			null as collateral_type_internal,
			null as collateral_is_ownership,
			cast(null as bit) as is_krov_dok,
			cast(null as int) as id_cont,
			fc.id_tec
	from #frame_candidates fc
	inner join dbo.partner pa on pa.id_kupca = fc.id_kupca
	left join dbo.gv_PEval_LastEvaluation pe on pe.id_kupca = pa.id_kupca
	where fc.status_akt = 'A'
	and (@for_connected_partners = 1 or fc.id_kupca = @id_kupca)
	-- update pogodb v HRK po posebnem tecaju EUR : HRK, ki ga rocno vnasajo kot kriterij
	update #result_analitic
	set collateral_account = round(dbo.gfn_Xchange('000', collateral_account, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		purchase_price = round(dbo.gfn_Xchange('000', purchase_price, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		nominal_value = round(dbo.gfn_Xchange('000', nominal_value, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		prior_claims_amount = round(dbo.gfn_Xchange('000', prior_claims_amount, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		wcov = round(dbo.gfn_Xchange('000', wcov, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		wcv = round(dbo.gfn_Xchange('000', wcv, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		wcv_delivered = round(dbo.gfn_Xchange('000', wcv_delivered, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		wgv_delivered = round(dbo.gfn_Xchange('000', wgv_delivered, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		guaranteed_amount = round(dbo.gfn_Xchange('000', guaranteed_amount, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		net_nal_zac = round(dbo.gfn_Xchange('000', net_nal_zac, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		obrok1 = round(dbo.gfn_Xchange('000', obrok1, @id_tec, @target_date) * @exch_rate_eur_hrk, 2),
		total_odr = round(dbo.gfn_Xchange('000', total_odr, @id_tec, @target_date) * @exch_rate_eur_hrk, 2)
	from #result_analitic a
	where @company_id = 'RLHR'
	and @exch_rate_eur_hrk is not null
	and a.id_tec = '000'
	-- 2.a.) SINTETIC RESULT (RLHR, RLSI)
	create table #result_sintetic(is_frame bit null, id_cont int null, id_kupca char(6) null, partner_desc varchar(100) null, code varchar(15), nr int, collateral varchar(240), collateral_desc varchar(240), curr_mismatch varchar(5), collateral_account decima
l(18,2), purchase_price decimal(18,2),
								  ponder varchar(30), nominal_value decimal(18,2), hx_rate varchar(30), prior_claims_amount decimal(18,2), wcov decimal(18,2), wcv_delivered decimal(18,2),
								  wgv_delivered decimal(18,2), guaranteed_amount decimal(18,2), strong_loc_covered_amount decimal(18,2), collateral_rank int, collateral_is_ownership bit,
								  id_pog_list_short varchar(239), id_pog_list varchar(max))
	if @company_id in ('RLHR','RLSI') begin
		-- predmet lizinga nepremicnine, kjer moramo seseteti stavbni in zemljiski del, ki imata loceni pogodbi (npr. 12345/15 stabni del, 12345/ZM zemljisce)
		select a.collateral_id
		into #lastnistvo_nepremicnine_to_sum
		from #result_analitic a
		where a.collateral_is_ownership = 1
		and a.collateral_type_internal = 'NELA'
		and a.id_pog like '%/ZM%'
		and exists (
			select b.collateral_id
			from #result_analitic b
			where b.collateral_is_ownership = 1
			and b.collateral_type_internal = 'NELA'
			and b.id_pog not like '%/ZM%'
			and left(b.id_pog, charindex('/', b.id_pog) - 1) = left(a.id_pog, charindex('/', a.id_pog) - 1)
		)
		union all
		select a.collateral_id
		from #result_analitic a
		where a.collateral_is_ownership = 1
		and a.collateral_type_internal = 'NELA'
		and a.id_pog not like '%/ZM%'
		and exists (
			select b.collateral_id
			from #result_analitic b
			where b.collateral_is_ownership = 1
			and b.collateral_type_internal = 'NELA'
			and b.id_pog like '%/ZM%'
			and left(b.id_pog, charindex('/', b.id_pog) - 1) = left(a.id_pog, charindex('/', a.id_pog) - 1)
		)
		-- predmet lizinga (premicnine), ki niso vezani na okvir ali so vezani na neaktiven okvir in imajo dodatni kolateral -> potrebno jih je prikazati loceno
		select c.collateral_id
		into #prem_ima_dod_collat
		from #result_analitic c
		where c.collateral_is_ownership = 1
		and c.collateral_type_internal in ('PON', 'IE') -- samo premicnine
		and (c.id_frame is null or (c.id_frame is not null and c.frame_status_akt = 'Z'))
		and exists (
			select d.collateral_id
			from #result_analitic d
			where d.id_cont = c.id_cont
			and d.coll_type_view = 'ADDITONAL COLLATERAL'
			and d.is_krov_dok = 0
		)
		-- predmet lizinga (premicnine), ki niso vezane na okvir
		insert into #result_sintetic(code, nr, collateral, collateral_desc, curr_mismatch, collateral_account, purchase_price,
									 ponder, nominal_value, hx_rate, prior_claims_amount, wcov, wcv_delivered,
									 wgv_delivered, guaranteed_amount, strong_loc_covered_amount, collateral_rank, is_frame, id_cont)
		select cast('' as varchar(15)) as code, 0 as nr, 'Leasing ugovori' as collateral, 'Leasing ugovori' as collateral_desc,
				max(curr_mismatch) as curr_mismatch,
				sum(collateral_account) as collateral_account,
				sum(purchase_price) as purchase_price,
				case when max(ponder) != min(ponder) then replace(cast(cast(min(ponder) as varchar(10)) + ' - ' + cast(max(ponder) as varchar(10)) as varchar(30)), '.', ',') else replace(cast(min(ponder) as varchar(30)), '.', ',') end as ponder,
				sum(nominal_value) as nominal_value,
				case when max(hx_rate) != min(hx_rate) then replace(cast(cast(min(hx_rate) as varchar(10)) + ' - ' + cast(max(hx_rate) as varchar(10)) as varchar(30)), '.', ',') else replace(cast(min(hx_rate) as varchar(30)), '.', ',') end as hx_rate,
				sum(prior_claims_amount) as prior_claims_amount,
				sum(wcov) as wcov,
				sum(wcv_delivered) as wcv_delivered,
				sum(wgv_delivered) as wgv_delivered,
				sum(guaranteed_amount) as guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				max(collateral_rank) as collateral_rank,
				cast(0 as bit) as is_frame,
				null as id_cont
		from #result_analitic
		where collateral_is_ownership = 1
		and collateral_type_internal in ('PON', 'IE') -- samo premicnine
		and id_frame is null
		and collateral_id not in (select collateral_id from #prem_ima_dod_collat) -- nimajo dodatnega kolaterala
		group by id_frame
		union all
		-- predmet lizinga (premicnine), vezane na zakljucene okvir-e
		select cast(id_frame as varchar(15)) as code, 0 as nr, 'Leasing ugovori - Z okvir' as collateral, 'Leasing ugovori - Z okvir' as collateral_desc,
				max(curr_mismatch) as curr_mismatch,
				sum(collateral_account) as collateral_account,
				sum(purchase_price) as purchase_price,
				case when max(ponder) != min(ponder) then replace(cast(cast(min(ponder) as varchar(10)) + ' - ' + cast(max(ponder) as varchar(10)) as varchar(30)), '.', ',') else replace(cast(min(ponder) as varchar(30)), '.', ',') end as ponder,
				sum(nominal_value) as nominal_value,
				case when max(hx_rate) != min(hx_rate) then replace(cast(cast(min(hx_rate) as varchar(10)) + ' - ' + cast(max(hx_rate) as varchar(10)) as varchar(30)), '.', ',') else replace(cast(min(hx_rate) as varchar(30)), '.', ',') end as hx_rate,
				sum(prior_claims_amount) as prior_claims_amount,
				sum(wcov) as wcov,
				sum(wcv_delivered) as wcv_delivered,
				sum(wgv_delivered) as wgv_delivered,
				sum(guaranteed_amount) as guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				max(collateral_rank) as collateral_rank,
				cast(0 as bit) as is_frame,
				null as id_cont
		from #result_analitic
		where collateral_is_ownership = 1
		and collateral_type_internal in ('PON', 'IE') -- samo premicnine
		and id_frame is not null
		and frame_status_akt = 'Z'
		and collateral_id not in (select collateral_id from #prem_ima_dod_collat) -- nimajo dodatnega kolaterala
		group by id_frame
		union all
		-- predmet lizinga (premicnine), ki imajo dodatni kolateral in niso vezane na aktiven okvir
		select IsNull(code, '') as code, 0 as nr, collateral, collateral_desc,
				curr_mismatch,
				collateral_account,
				purchase_price,
				replace(cast(ponder as varchar(30)), '.', ',') as ponder,
				nominal_value,
				replace(cast(hx_rate as varchar(30)), '.', ',') as hx_rate,
				prior_claims_amount,
				wcov,
				wcv_delivered,
				wgv_delivered,
				guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				collateral_rank,
				cast(0 as bit) as is_frame,
				id_cont
		from #result_analitic
		where collateral_id in (select collateral_id from #prem_ima_dod_collat)
		union all
		-- predmet lizinga (premicnine), vezane na aktive okvir-e (prikaze se le okvir)
		select IsNull(code, '') as code, 0 as nr, collateral, collateral_desc,
				curr_mismatch,
				collateral_account,
				purchase_price,
				replace(cast(ponder as varchar(30)), '.', ',') as ponder,
				nominal_value,
				replace(cast(hx_rate as varchar(30)), '.', ',') as hx_rate,
				prior_claims_amount,
				wcov,
				wcv_delivered,
				wgv_delivered,
				guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				collateral_rank,
				cast(1 as bit) as is_frame,
				null as id_cont
		from #result_analitic
		where coll_type_view = 'FRAME'
		and frame_status_akt = 'A'
		union all
		-- predmet lizinga (nepremicnina)
		select IsNull(code, '') as code, 0 as nr, collateral, collateral_desc,
				curr_mismatch,
				collateral_account,
				purchase_price,
				replace(cast(ponder as varchar(30)), '.', ',') as ponder,
				nominal_value,
				replace(cast(hx_rate as varchar(30)), '.', ',') as hx_rate,
				prior_claims_amount,
				wcov,
				wcv_delivered,
				wgv_delivered,
				guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				collateral_rank,
				cast(0 as bit) as is_frame,
				id_cont
		from #result_analitic
		where collateral_is_ownership = 1
		and collateral_type_internal = 'NELA'
		and collateral_id not in (select collateral_id from #lastnistvo_nepremicnine_to_sum)
		and (id_frame is null or (id_frame is not null and frame_status_akt = 'Z'))
		union all
		select max(IsNull(code, '')) as code, 0 as nr, max(collateral) as collateral, max(collateral_desc) as collateral_desc,
				max(curr_mismatch) as curr_mismatch,
				sum(collateral_account) as collateral_account,
				sum(purchase_price) as purchase_price,
				replace(cast(max(ponder) as varchar(30)), '.', ',') as ponder,
				sum(nominal_value) as nominal_value,
				replace(cast(max(hx_rate) as varchar(30)), '.', ',') as hx_rate,
				sum(prior_claims_amount) as prior_claims_amount,
				sum(wcov) as wcov,
				sum(wcv_delivered) as wcv_delivered,
				sum(wgv_delivered) as wgv_delivered,
				sum(guaranteed_amount) as guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				max(collateral_rank) as collateral_rank,
				cast(0 as bit) as is_frame,
				min(id_cont) as id_cont
		from #result_analitic
		where collateral_is_ownership = 1
		and collateral_type_internal = 'NELA'
		and collateral_id in (select collateral_id from #lastnistvo_nepremicnine_to_sum)
		and (id_frame is null or (id_frame is not null and frame_status_akt = 'Z'))
		group by left(id_pog, charindex('/', id_pog) - 1)
		union all
		-- dodatni kolaterali (vezani na pogodbo)
		select IsNull(code, '') as code, 0 as nr, collateral, collateral_desc,
				curr_mismatch,
				collateral_account,
				purchase_price,
				replace(cast(ponder as varchar(30)), '.', ',') as ponder,
				nominal_value,
				replace(cast(hx_rate as varchar(30)), '.', ',') as hx_rate,
				prior_claims_amount,
				wcov,
				wcv_delivered,
				wgv_delivered,
				guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				collateral_rank,
				cast(0 as bit) as is_frame,
				id_cont
		from #result_analitic
		where collateral_is_ownership = 0
		and is_krov_dok = 0
		-- dodatni kolaterali (krovni) -> za 1 krovni kolateral obstaja v #result_analitic toliko zapisov, kolikor je alokacij po pogodbah
		union all
		select max(IsNull(code, '')) as code, 0 as nr, max(collateral) as collateral, max(collateral_desc) as collateral_desc,
				max(curr_mismatch) as curr_mismatch,
				max(collateral_account) as collateral_account,
				max(purchase_price) as purchase_price,
				replace(cast(max(ponder) as varchar(30)), '.', ',') as ponder,
				max(nominal_value) as nominal_value,
				replace(cast(max(hx_rate) as varchar(30)), '.', ',') as hx_rate,
				max(prior_claims_amount) as prior_claims_amount,
				max(wcov) as wcov,
				sum(wcv_delivered) as wcv_delivered,
				sum(wgv_delivered) as wgv_delivered,
				max(guaranteed_amount) as guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				max(collateral_rank) as collateral_rank,
				cast(0 as bit) as is_frame,
				null as id_cont
		from #result_analitic
		where collateral_is_ownership = 0
		and is_krov_dok = 1
		group by collateral_id
		drop table #prem_ima_dod_collat
		drop table #lastnistvo_nepremicnine_to_sum
	end
	-- 2.b.) SINTETIC RESULT (RLRS, RRRS, RLBH)
	if @company_id in ('RLRS', 'RRRS', 'RLBH') begin
		select id_pog, id_kupca_cont, nr,
				ROW_NUMBER() OVER (partition by id_kupca_cont, nr order by id_pog) as row_num,
				ROW_NUMBER() OVER (partition by id_kupca_cont, nr order by id_pog desc) as row_num_desc
		into #id_pog_grp
		from (
			select id_pog, id_kupca_cont,
				case when id_grupe in ('VNC','VUC','VLT') then 1
								when id_grupe in ('VHT','VTT','VOW') then 2
								when id_grupe in ('EFM','EIT','EME','EMM','EOT','EPM','VAM','VBO','VCM','VFR') then 3
								when id_grupe in ('RCH','RDS','RHT','RIB','ROB','ROE','RRB') then 4
								else 5
							end as nr
			from #result_analitic
			where collateral_is_ownership = 1
		) a
		-- Seštevanje id_pog
		; with id_pog_lst as (
			select row_num, row_num_desc, id_kupca_cont, nr,
				cast(id_pog as varchar(max)) as id_pog_lst
			from #id_pog_grp
			where row_num = 1
			union all
			select a.row_num, a.row_num_desc, a.id_kupca_cont, a.nr,
				cast(b.id_pog_lst + ', ' + a.id_pog as varchar(max)) as id_pog_lst
			from #id_pog_grp a
				join id_pog_lst b on b.nr = a.nr and b.id_kupca_cont = a.id_kupca_cont and b.row_num + 1 = a.row_num
		)
		select *
		into #id_pog_list
		from id_pog_lst where row_num_desc = 1
		option (maxrecursion 1000)
		insert into #result_sintetic(id_kupca, partner_desc, code, nr, collateral, collateral_desc, curr_mismatch, collateral_account, purchase_price,
									 ponder, nominal_value, hx_rate, prior_claims_amount, wcov, wcv_delivered,
									 wgv_delivered, guaranteed_amount, strong_loc_covered_amount, collateral_rank, collateral_is_ownership,
									 id_pog_list_short, id_pog_list)
		select ra.id_kupca_cont, ra.partner_cont_desc,
				cast('' as varchar(20)) as code,
				case when ra.id_grupe in ('VNC','VUC','VLT') then 1
					  when ra.id_grupe in ('VHT','VTT','VOW') then 2
					  when ra.id_grupe in ('EFM','EIT','EME','EMM','EOT','EPM','VAM','VBO','VCM','VFR') then 3
					  when ra.id_grupe in ('RCH','RDS','RHT','RIB','ROB','ROE','RRB') then 4
					  else 5
				 end as nr,
				case when ra.id_grupe in ('VNC','VUC','VLT') then 'light vehicles'
					  when ra.id_grupe in ('VHT','VTT','VOW') then 'other vehicles'
					  when ra.id_grupe in ('EFM','EIT','EME','EMM','EOT','EPM','VAM','VBO','VCM','VFR') then 'equipment'
					  when ra.id_grupe in ('RCH','RDS','RHT','RIB','ROB','ROE','RRB') then 'real estate'
					  else 'unknown group'
				 end as collateral,
				 '' as collateral_desc,
				 max(ra.curr_mismatch) as curr_mismatch,
				 sum(ra.collateral_account) as collateral_account,
				 sum(ra.purchase_price) as purchase_price,
				 replace(cast(cast(min(ra.ponder) as varchar(10)) + ' - ' + cast(max(ra.ponder) as varchar(10)) as varchar(30)), '.', ',') as ponder,
				 sum(ra.nominal_value) as nominal_value,
				 case when max(ra.hx_rate) != min(ra.hx_rate) then replace(cast(cast(min(ra.hx_rate) as varchar(10)) + ' - ' + cast(max(ra.hx_rate) as varchar(10)) as varchar(30)), '.', ',') else replace(cast(min(ra.hx_rate) as varchar(30)), '.', ',') end as hx_rate,
				 sum(ra.prior_claims_amount) as prior_claims_amount,
				 sum(ra.wcov) as wcov,
				 sum(ra.wcv_delivered) as wcv_delivered,
				 sum(ra.wgv_delivered) as wgv_delivered,
				 sum(ra.guaranteed_amount) as guaranteed_amount,
				 cast(null as decimal(18,2)) as strong_loc_covered_amount,
				 1 as collateral_rank,
				 ra.collateral_is_ownership as collateral_is_ownership,
				 cast(null as varchar(239)) as id_pog_list_short,
				 cast(null as varchar(max)) as id_pog_list
		from #result_analitic ra
		where ra.collateral_is_ownership = 1
		group by ra.id_kupca_cont, ra.partner_cont_desc,
				 case when ra.id_grupe in ('VNC','VUC','VLT') then 1
					  when ra.id_grupe in ('VHT','VTT','VOW') then 2
					  when ra.id_grupe in ('EFM','EIT','EME','EMM','EOT','EPM','VAM','VBO','VCM','VFR') then 3
					  when ra.id_grupe in ('RCH','RDS','RHT','RIB','ROB','ROE','RRB') then 4
					  else 5
				 end,
				 case when ra.id_grupe in ('VNC','VUC','VLT') then 'light vehicles'
					  when ra.id_grupe in ('VHT','VTT','VOW') then 'other vehicles'
					  when ra.id_grupe in ('EFM','EIT','EME','EMM','EOT','EPM','VAM','VBO','VCM','VFR') then 'equipment'
					  when ra.id_grupe in ('RCH','RDS','RHT','RIB','ROB','ROE','RRB') then 'real estate'
					  else 'unknown group'
				 end, ra.collateral_is_ownership
		union all
		-- dodatni kolaterali (vezani na pogodbo)
		select id_kupca_cont, partner_cont_desc,
				cast('' as varchar(20)) as code, 
				6 as nr,
				collateral,
				'' as collateral_desc,
				curr_mismatch,
				collateral_account,
				purchase_price,
				replace(cast(ponder as varchar(30)), '.', ',') as ponder,
				nominal_value,
				replace(cast(hx_rate as varchar(30)), '.', ',') as hx_rate,
				prior_claims_amount,
				wcov,
				wcv_delivered,
				wgv_delivered,
				guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				collateral_rank,
				collateral_is_ownership,
				id_pog as id_pog_list_short,
				id_pog as id_pog_list
		from #result_analitic
		where collateral_is_ownership = 0
		and is_krov_dok = 0
		-- dodatni kolaterali (krovni) -> za 1 krovni kolateral obstaja v #result_analitic toliko zapisov, kolikor je alokacij po pogodbah
		union all
		select id_kupca, partner_desc,
				max(IsNull(code, '')) as code,
				6 as nr,
				max(collateral) as collateral,
				'' as collateral_desc,
				max(curr_mismatch) as curr_mismatch,
				max(collateral_account) as collateral_account,
				max(purchase_price) as purchase_price,
				replace(cast(max(ponder) as varchar(30)), '.', ',') as ponder,
				max(nominal_value) as nominal_value,
				replace(cast(max(hx_rate) as varchar(30)), '.', ',') as hx_rate,
				max(prior_claims_amount) as prior_claims_amount,
				max(wcov) as wcov,
				sum(wcv_delivered) as wcv_delivered,
				sum(wgv_delivered) as wgv_delivered,
				max(guaranteed_amount) as guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				max(collateral_rank) as collateral_rank,
				collateral_is_ownership,
				cast(null as varchar(239)) as id_pog_list_short,
				cast(null as varchar(max)) as id_pog_list
		from #result_analitic
		where collateral_is_ownership = 0
		and is_krov_dok = 1
		group by id_kupca, partner_desc, collateral_id, collateral_is_ownership
		-- unused frame
		union all
		select id_kupca, partner_desc,
				cast('' as varchar(20)) as code, 
				7 as nr,
				collateral,
				collateral_desc,
				curr_mismatch,
				collateral_account,
				purchase_price,
				replace(cast(ponder as varchar(30)), '.', ',') as ponder,
				nominal_value,
				replace(cast(hx_rate as varchar(30)), '.', ',') as hx_rate,
				prior_claims_amount,
				wcov,
				wcv_delivered,
				wgv_delivered,
				guaranteed_amount,
				cast(null as decimal(18,2)) as strong_loc_covered_amount,
				collateral_rank,
				null as collateral_is_ownership,
				cast(null as varchar(239)) as id_pog_list_short,
				cast(null as varchar(max)) as id_pog_list
		from #result_analitic
		where coll_type_view = 'FRAME'
		-- we update contract list for ownership
		update #result_sintetic
		set id_pog_list_short = left(ipl.id_pog_lst, 239),
			id_pog_list= ipl.id_pog_lst
		from #result_sintetic rs
		inner join #id_pog_list ipl on ipl.nr = rs.nr and ipl.id_kupca_cont = rs.id_kupca
		where rs.collateral_is_ownership = 1
		drop table #id_pog_grp
		drop table #id_pog_list
	end
	-- Return results
	if object_id('tempdb..' + @temp_table_ces_analitic_result_name) is not null begin
		declare @sql_insert varchar(max)
		set @sql_insert = '
		alter table {temp_table_ces_analitic_result_name} add
			collateral_id varchar(30), coll_type_view varchar(30), id_pog char(11), code varchar(10), collateral varchar(240), collateral_desc varchar(240),
			curr_mismatch varchar(10), collateral_account decimal(18,2), purchase_price decimal(18,2), ponder decimal(18,2), nominal_value decimal(18,2), hx_rate decimal(18,2),
			prior_claims_amount decimal(18,2), wcov decimal(18,2), fx_discount decimal(18,2), discount_for_mortages decimal(18,2), wcv decimal(18,2),
			wcv_delivered decimal(18,2), wgv_delivered decimal(18,2), guaranteed_amount decimal(18,2), id_frame int, frame_status_akt char(1), frame_dat_aktiv datetime,
			id_dokum int, id_obl_zav char(2), status_akt char(1), dat_aktiv datetime, collateral_expiry_date datetime, collateral_insurance_ok bit,
			maturity_mismatch bit, contract_expiry_date datetime, nacin_leas char(2), obr_mera decimal(7,4), net_nal_zac decimal(18,2),
			obrok1 decimal(18,2), total_odr decimal(18,2), id_grupe1 char(5), id_grupe char(3), group_type varchar(50), partner_desc varchar(235), id_kupca char(6),
			coconut_id char(11), gcc_naziv varchar(150), cust_ratin varchar(10), collateral_rank int, id_kupca_cont char(6), collateral_type_internal varchar(20),
			collateral_is_ownership bit, is_krov_dok bit, id_cont int, id_tec char(3), id_val_pog char(3)
			
		if exists(select * from tempdb.sys.columns where name = ''null'' and object_id = object_id(''tempdb..{temp_table_ces_analitic_result_name}'')) begin
			alter table {temp_table_ces_analitic_result_name} drop column [null]
		end'
		set @sql_insert = replace(@sql_insert, '{temp_table_ces_analitic_result_name}', @temp_table_ces_analitic_result_name)
		exec(@sql_insert)
		set @sql_insert = '
		insert into {temp_table_ces_analitic_result_name}
			(collateral_id, coll_type_view, id_pog, code, collateral, collateral_desc, curr_mismatch, collateral_account, purchase_price, ponder, nominal_value, hx_rate,
			prior_claims_amount, wcov, fx_discount, discount_for_mortages, wcv, wcv_delivered, wgv_delivered, guaranteed_amount, id_frame, frame_status_akt, frame_dat_aktiv,
			id_dokum, id_obl_zav, status_akt, dat_aktiv, collateral_expiry_date, collateral_insurance_ok, maturity_mismatch, contract_expiry_date, nacin_leas,
			obr_mera, net_nal_zac, obrok1, total_odr, id_grupe1, id_grupe, group_type, partner_desc, id_kupca, coconut_id, gcc_naziv, cust_ratin, collateral_rank, id_kupca_cont,
			collateral_type_internal, collateral_is_ownership, is_krov_dok, id_cont, id_tec, id_val_pog)
		select collateral_id, coll_type_view, id_pog, code, collateral, collateral_desc, curr_mismatch, collateral_account, purchase_price, ponder, nominal_value, hx_rate,
				prior_claims_amount, wcov, fx_discount, discount_for_mortages, wcv, wcv_delivered, wgv_delivered, guaranteed_amount, id_frame, frame_status_akt, frame_dat_aktiv,
				id_dokum, id_obl_zav, status_akt, dat_aktiv, collateral_expiry_date, collateral_insurance_ok, maturity_mismatch, contract_expiry_date, nacin_leas,
				obr_mera, net_nal_zac, obrok1, total_odr, id_grupe1, id_grupe, group_type, partner_desc, id_kupca, coconut_id, gcc_naziv, cust_ratin, collateral_rank, id_kupca_cont,
				collateral_type_internal, collateral_is_ownership, is_krov_dok, id_cont, id_tec, id_val_pog
		from #result_analitic'
		set @sql_insert = replace(@sql_insert, '{temp_table_ces_analitic_result_name}', @temp_table_ces_analitic_result_name)
		exec(@sql_insert)
	end else begin
		select *
		from #result_analitic
		order by case when coll_type_view = 'Frame' then 2 else 1 end,
				 id_kupca_cont, id_pog, collateral_is_ownership desc, collateral_rank
	end
	if object_id('tempdb..' + @temp_table_ces_sintetic_result_name) is not null begin
		set @sql_insert = '
		alter table {temp_table_ces_sintetic_result_name} add
			id_kupca char(6) null, partner_desc varchar(100), code varchar(10), nr int, collateral varchar(240), collateral_desc varchar(240), curr_mismatch varchar(10), collateral_account decimal(18,2),
			purchase_price decimal(18,2), ponder varchar(30), nominal_value decimal(18,2), hx_rate varchar(30), prior_claims_amount decimal(18,2), 
			wcov decimal(18,2), wcv_delivered decimal(18,2), wgv_delivered decimal(18,2), guaranteed_amount decimal(18,2), strong_loc_covered_amount decimal(18,2),
			collateral_rank int, collateral_is_ownership bit, id_pog_list_short varchar(239) null, id_pog_list varchar(max) null, is_frame bit, id_cont int
			
		if exists(select * from tempdb.sys.columns where name = ''null'' and object_id = object_id(''tempdb..{temp_table_ces_sintetic_result_name}'')) begin
			alter table {temp_table_ces_sintetic_result_name} drop column [null]
		end'
		set @sql_insert = replace(@sql_insert, '{temp_table_ces_sintetic_result_name}', @temp_table_ces_sintetic_result_name)
		exec(@sql_insert)
		set @sql_insert = '
		insert into {temp_table_ces_sintetic_result_name}
			(id_kupca, partner_desc, code, nr, collateral, collateral_desc, curr_mismatch, collateral_account, purchase_price, ponder, nominal_value,
			 hx_rate, prior_claims_amount, wcov, wcv_delivered, wgv_delivered, guaranteed_amount, strong_loc_covered_amount,
			 collateral_rank, collateral_is_ownership, id_pog_list_short, id_pog_list, is_frame, id_cont)
		select id_kupca, partner_desc, code, nr, collateral, collateral_desc, curr_mismatch, collateral_account, purchase_price, ponder, nominal_value,
				hx_rate, prior_claims_amount, wcov, wcv_delivered, wgv_delivered, guaranteed_amount, strong_loc_covered_amount,
				collateral_rank, collateral_is_ownership, id_pog_list_short, id_pog_list, is_frame, id_cont
		from #result_sintetic'
		set @sql_insert = replace(@sql_insert, '{temp_table_ces_sintetic_result_name}', @temp_table_ces_sintetic_result_name)
		exec(@sql_insert)
	end else begin
		select * from #result_sintetic order by nr
	end
	drop table #local_currency
	drop table #exclude_lease_types
	drop table #partner_grupe
	drop table #partner_candidates
	drop table #contract_candidates
	drop table #contract_max_dat_zap
	drop table #exposure
	drop table #obligo_planp_ds
	drop table #obligo_frame
	drop table #frame_candidates_tmp
	drop table #frame_candidates
	drop table #zap_ner
	drop table #cesije
	drop table #collaterals_wcv
	drop table #collaterals_insurance
	drop table #collaterals_allocation
	drop table #result_analitic
	drop table #result_sintetic
END