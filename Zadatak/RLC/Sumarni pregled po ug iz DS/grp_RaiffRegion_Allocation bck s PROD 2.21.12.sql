------------------------------------------------------------------------------------------------------------
-- Procedure for allocating collaterals on exposures
--
-- History:
-- 24.03.2015 Domen, Žiga; MID 42462 - created
-- 20.05.2015 Ziga; MID 42462 - modifications
-- 22.06.2015 Ziga; MID 42462 - adaptation for provisions, added parameter id_oc_report_im
-- 09.07.2015 Ziga; MID 42462 - added parameter @id_oc_report to call of procedure grp_RaiffRegion_Collateral
-- 10.07.2015 Domen, Ziga; MID 42462 - repaired case if no additional collaterals are present
-- 17.08.2015 Domen; MID 49452 - RLRS, RRRS: using FX discount for EUR when vrst_opr.logotip != '1'
-- Present in versions: 2.21, 2.20.5, 2.19.8
-- 30.10.2015 Ziga; MID 53714 - added possibility to exclude certain lease types
-- 03.11.2015 Ziga, Domen; MID 42459 - added support for CES report and allocation to connected partners
-- 10.11.2015 Ziga; MID 42459 - modifications for connected partners
-- 23.11.2015 Ziga MID 42459 - modifications according to RLHR comments (modified exposure for inactive contracts)
-- 08.12.2015 Ziga, Domen; MID 49452 - minor correction for FX
-- 02.02.2016 Domen; MID 49452 - add applyed FX to all rows with the same collateral_id, fix for manual and pro-rata allocation
-- 20.04.2016 Domen, Ziga; ON SITE - modified field fx_discount in final select statement
------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[grp_RaiffRegion_Allocation]
	@target_date datetime,
	@id_kupca varchar(6),
	@exposure_type varchar(10),
	@exclude_real_ol_pon_collaterals bit,
	@temp_table_result_name varchar(50),
	@id_oc_report_im int = null,
	@for_connected_partners bit = 0,
	@allocation_source varchar(5) = null -- (available enums: null, CES)
AS
-- Get id_tec for EUR
declare @company_id varchar(10), @id_tec_prod_eur char(3)
set @company_id = (select entity_name from dbo.loc_nast)
set @id_tec_prod_eur = (case when @company_id = 'RLHR' then '006' when @company_id in ('RLBH','RLRS','RRRS') then '001' else '000' end)
if @id_oc_report_im is not null begin
	set @target_date = (select date_to from dbo.oc_reports where id_oc_report = @id_oc_report_im)
end
-- XChange discount
declare @xchange_discount as decimal(10,8)
select @xchange_discount = isnull((100 - dbo.gfn_GetValueTableAdditionalFactor('FXDISC', @target_date)) / 100, 0)
-- LOCAL CURRENCY
select id_tec
into #local_currency
from dbo.tecajnic
where (id_tec = '000' or id_val = 'EUR')
create clustered index pk on #local_currency (id_tec)
-- EXCLUDE LEASE TYPES
select id_key as nacin_leas
into #exclude_lease_types
from dbo.gfn_g_register_active('RL_REGION_EXCLUDE_LEASE_TYPES', null)
-- CONTRACT CANDIDATES
create table #contract_candidates (id_cont int primary key, id_kupca char(6), id_tec char(3), id_vrste char(4))
create table #partner_candidates (id_kupca char(6) primary key)
-- from production or intermediate snapshot
if @id_kupca is null begin
	if @id_oc_report_im is null begin
		-- CMS iz produkcije
		insert into #contract_candidates(id_cont, id_kupca, id_tec, id_vrste)
		select id_cont, id_kupca, id_tec, id_vrste
		from dbo.pogodba
		where status_akt = 'A'
		and nacin_leas not in (select nacin_leas from #exclude_lease_types)
	end else begin
		-- Provisions
		insert into #contract_candidates(id_cont, id_kupca, id_tec, id_vrste)
		select id_cont, id_kupca, id_tec, id_vrste
		from dbo.oc_contracts
		where id_oc_report = @id_oc_report_im
		and status_akt = 'A'
		and dat_aktiv <= @target_date
		and nacin_leas not in (select nacin_leas from #exclude_lease_types)
	end
end else begin
	-- partner candidates (always all connected partners because of collection collaterals)
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
	drop table #partner_grupe
	if @id_oc_report_im is null begin
		-- CMS iz produkcije za posameznega partnerja (zaenkrat se ne uporablja)
		if @allocation_source is null begin
			insert into #contract_candidates(id_cont, id_kupca, id_tec, id_vrste)
			select po.id_cont, po.id_kupca, po.id_tec, po.id_vrste
			from #partner_candidates pa
			inner join dbo.pogodba po on po.id_kupca = pa.id_kupca
			where po.status_akt = 'A'
			and po.nacin_leas not in (select nacin_leas from #exclude_lease_types)
		end
		-- CES report
		if @allocation_source = 'CES' begin
			insert into #contract_candidates(id_cont, id_kupca, id_tec, id_vrste)
			select po.id_cont, po.id_kupca, po.id_tec, po.id_vrste
			from #partner_candidates pa
			inner join dbo.pogodba po on po.id_kupca = pa.id_kupca
			where po.status_akt in ('A','N','D')
			and po.nacin_leas not in (select nacin_leas from #exclude_lease_types)
		end
	end else begin
		insert into #contract_candidates(id_cont, id_kupca, id_tec, id_vrste)
		select po.id_cont, po.id_kupca, po.id_tec, po.id_vrste
		from #partner_candidates pa
		inner join dbo.oc_contracts po on po.id_kupca = pa.id_kupca
		where po.id_oc_report = @id_oc_report_im
		and po.status_akt = 'A'
		and po.dat_aktiv <= @target_date
		and po.nacin_leas not in (select nacin_leas from #exclude_lease_types)
	end
end
drop table #partner_candidates
-- EXPOSURES
create table #exposures_tmp(id_cont int, id_tec char(3), total_exposure decimal(18,2))
if @id_oc_report_im is null begin
	insert into #exposures_tmp
	select e.id_cont,
			case when po.status_akt in ('N','D') then dbo.gfn_GetNewTec(po.id_tec) else e.id_tec end as id_tec,
			case when po.status_akt in ('N','D') and od.id_odobrit_tip in (12, 13) and @company_id = 'RLHR'
					then dbo.gfn_Xchange(dbo.gfn_GetNewTec(po.id_tec), po.vr_val_zac, po.id_tec, IsNull(po.dat_aktiv, po.dat_sklen))
				 when po.status_akt in ('N','D')
					then
						dbo.gfn_Xchange(dbo.gfn_GetNewTec(po.id_tec), po.net_nal_zac, po.id_tec, IsNull(po.dat_aktiv, po.dat_sklen))
					else
						case when @exposure_type = 'B2' then e.b2_total_exposure
							 when @exposure_type = 'PROV' then e.provision_exposure
							 when @exposure_type = 'RISK' then e.risk_exposure
							 else e.b2_total_exposure
						end
			end as total_exposure
	from dbo.gfn_RaiffRegion_Exposure(@target_date) e
	inner join dbo.pogodba po on po.id_cont = e.id_cont
	left join dbo.odobrit od on od.id_odobrit = po.id_odobrit
	inner join dbo.nacini_l nl on nl.nacin_leas = po.nacin_leas
	inner join dbo.dav_stop ds on ds.id_dav_st = IsNull(po.id_dav_op, po.id_dav_st)
end else begin
	create table #exp_tmp([null] int)
	exec dbo.grp_RaiffRegion_Exposure @id_oc_report_im, '#exp_tmp'
	insert into #exposures_tmp
	select e.id_cont, e.id_tec,
			case when @exposure_type = 'B2' then e.b2_total_exposure
					when @exposure_type = 'PROV' then e.provision_exposure
					when @exposure_type = 'RISK' then e.risk_exposure
					else e.b2_total_exposure
			end as total_exposure
	from #exp_tmp e
	drop table #exp_tmp
end
create clustered index ix_contract_exopsure_tmp_id_cont on #exposures_tmp (id_cont)
create table #exposures(id_cont int, id_tec char(3), id_kupca char(6), id_vrste char(4), total_exposure decimal(18,2))
insert into #exposures
select c.id_cont, IsNull(nt.id_tec_new, nt.id_tec) as id_tec, c.id_kupca, c.id_vrste, IsNull(te.znesek, 0) as total_exposure
from #contract_candidates c
left join #exposures_tmp e on e.id_cont = c.id_cont
left join (select id_tec, nullif(id_tec_new, '') as id_tec_new from dbo.tecajnic) nt on nt.id_tec = c.id_tec
outer apply dbo.gfn_xchange_table(IsNull(nt.id_tec_new, nt.id_tec), IsNull(e.total_exposure, 0), IsNull(e.id_tec, IsNull(nt.id_tec_new, nt.id_tec)), @target_date) te
create clustered index ix_contract_exopsure_id_cont on #exposures (id_cont)
-- COLLATERALS
create table #collaterals_wcv ([null] bit)
if @allocation_source is null begin
	execute dbo.grp_RaiffRegion_Collateral @target_date, @id_kupca, @exclude_real_ol_pon_collaterals, '#collaterals_wcv', null, @id_oc_report_im
end
if @allocation_source = 'CES' begin
	execute dbo.grp_RaiffRegion_Collateral_CES_Report @id_kupca, '#collaterals_wcv', null
end
create clustered index ix_collaterals_wcv_collateral_id on #collaterals_wcv (collateral_id)
-- CONTRACT RANKS
create table #b2opprod([null] int)
exec dbo.grp_RaiffRegion_B2Opprod '#b2opprod'
create index ix_b2collat on #b2opprod(id_vrste)
-- Ordering exposure ranks (turns around -> cont_rank = 1 -> cont_rank = 3)
select
	e.id_kupca as id_kupca,
	e.id_cont as id_cont,
	isnull(ot.object_rank, 1) as object_rank,
	row_number() over (partition by e.id_kupca order by
		isnull(ot.object_rank, 1) desc,
		case when @id_tec_prod_eur not in (select id_tec from #local_currency) then 1 else 2 end,
		e.total_exposure desc,
		e.id_cont) as cont_rank,
	case
		when @company_id in ('RLRS', 'RRRS') and e.id_tec != '000' and (isnull(vo.kategorija1, '') = '1') then @xchange_discount -- Is EUR, exclude contracts with vo.kategorija1=1
		when @company_id not in ('RLRS', 'RRRS') and lc.id_tec is null then @xchange_discount -- Not local currency (or EUR)
		else 1
		end as fx_discount,
	case
		when @company_id in ('RLRS', 'RRRS') and e.id_tec != '000' and (isnull(vo.kategorija1, '') = '1') then 1
		when @company_id not in ('RLRS', 'RRRS') and lc.id_tec is null then 1
		else 0
		end as fx_discount_used,
	e.total_exposure as exposure_val,
	e.total_exposure as exposure_remaining_val,
	e.id_tec as id_tec_val
into
	#exposure_rank
from
	#exposures e
	left join #local_currency lc on lc.id_tec = e.id_tec
	left join dbo.VRST_OPR vo on vo.id_vrste = e.id_vrste
	left join (
		select id_vrste, max(object_rank) as object_rank
		from #b2opprod
		group by id_vrste
	) ot on ot.id_vrste = e.id_vrste
create clustered index pk on #exposure_rank (id_kupca, id_cont)
create index ix_rank_cont on #exposure_rank (id_cont)
create index ix_rank on #exposure_rank (cont_rank, id_kupca)
-- Ordering collaterals
select
	c.id_kupca as id_kupca,
	c.collateral_id as collateral_id,
	c.wcov as wcov_val,
	cast(1 as decimal(10,8)) as fx_discount,
	cast(isnull(c.discount_for_mortages, 1) as decimal(10,8)) as mx_discount,
	c.wcov as wcv_val,
	c.wcov as wcv_remaining_val,
	c.id_tec as id_tec_val,
	cast(0 as bit) as wcov_to_wcv
into
	#collaterals_all
from
	#collaterals_wcv c
where
	-- Financed objects
	c.collateral_from_contract = 1
union all
select
	c.id_kupca,
	c.collateral_id,
	c.wcov as wcov_val,
	cast(1 as decimal(10,8)) as fx_discount,
	cast(isnull(c.discount_for_mortages, 1) as decimal(10,8)) as mx_discount,
	c.wcov as wcv_val,
	c.wcov as wcv_remaining_val,
	c.id_tec as id_tec_val,
	cast(0 as bit) as wcov_to_wcv
from
	#collaterals_wcv c
where
	-- Other collaterals (all, excluding financed objects)
	c.collateral_from_contract = 0
create clustered index pk on #collaterals_all (collateral_id)
-- Additional collaterals linked to partner
;with collateral_links as (
	select
		d.id_krov_dok, d.id_cont, d.vrednost, c.id_kupca as id_kupca_cont
	from
		dbo.DOKUMENT d
		join dbo.dok dl on dl.ID_OBL_ZAV = d.ID_OBL_ZAV
		join #contract_candidates c on c.id_cont = d.id_cont
	where
		dl.sifra = 'LINK'
		and d.status_akt = 'A'
		and d.ima = 1
)
select
	row_number() over (partition by a.id_kupca_cont, a.id_cont order by
		a.collateral_type_rank,
		a.collateral_rank,
		case when a.is_krov_dok = 0 then 1 else 2 end,
		case when a.id_kupca_cont = a.id_kupca then 1 else 2 end,
		a.id_kupca_cont,
		a.wcv_val desc,
		a.collateral_id) as collateral_rank,
	a.collateral_id,
	a.alloc_type,
	a.id_kupca,
	a.id_kupca_cont,
	a.id_cont,
	a.id_dokum,
	a.alloc_percentage,
	a.wcv_val,
	a.wcv_remaining_val,
	cast(0 as bit) as wcov_to_wcv,
	a.alloc_contracts
into
	#additional_collateral
from
	(
		select
			c.collateral_id as collateral_id,
			c.alloc_type as alloc_type,
			c.id_kupca as id_kupca,
			cl.id_kupca_cont as id_kupca_cont,
			cl.id_cont as id_cont,
			c.id_dokum as id_dokum,
			cl.vrednost as alloc_percentage,
			cln.alloc_contracts,
			c.is_krov_dok,
			c.collateral_type_rank,
			c.collateral_rank,
			cl.vrednost * 0.01 * c.wcov as wcv_val,
			cl.vrednost * 0.01 * c.wcov as wcv_remaining_val
		from
			#collaterals_wcv c
			join collateral_links cl on cl.id_krov_dok = c.id_dokum
			left join (
				select id_krov_dok, count(id_cont) alloc_contracts
				from collateral_links
				group by id_krov_dok
			) cln on cln.id_krov_dok = c.id_dokum
		where
			c.collateral_from_contract = 0
			and c.is_krov_dok = 1
		-- Additional collaterals linked to contract
		union all
		select
			c.collateral_id as collateral_id,
			c.alloc_type as alloc_type,
			c.id_kupca as id_kupca,
			c.id_kupca as id_kupca_cont,
			c.id_cont as id_cont,
			c.id_dokum as id_dokum,
			100.0 as alloc_percentage,
			1 as alloc_contracts,
			c.is_krov_dok,
			c.collateral_type_rank,
			c.collateral_rank,
			c.wcov as wcv_val,
			c.wcov as wcv_remaining_val
		from
			#collaterals_wcv c
		where
			c.collateral_from_contract = 0
			and c.is_krov_dok = 0
	) a
-- Index
create clustered index pk on #additional_collateral (id_kupca_cont, collateral_id, id_cont)
-- Creating table for storing coverage
create table #allocation (
	step int,
	id_kupca char(6),
	id_cont int,
	cont_rank int,
	exposure_val decimal(18,2),
	exposure_remaining_val decimal(18,2),
	exposure_id_tec_val char(3),
	collateral_id varchar(25),
	collateral_rank int,
	fx_discount decimal(10, 8),
	mx_discount decimal(10, 8),
	wcv_val decimal(18,2),
	wcv_delivered_val decimal(18,2),
	wcv_id_tec_val char(3),
	wcov_to_wcv bit, -- Telling update to change wcv_val
	alloc_type varchar(10)
)
create clustered index pk on #allocation (step, id_kupca, collateral_id)
-- 1. Covering exposure with financed object
insert into #allocation
select
	a.step,
	a.id_kupca,
	a.id_cont,
	a.cont_rank,
	a.exposure_val,
	a.exposure_remaining_val,
	a.exposure_id_tec_val,
	a.collateral_id,
	a.collateral_rank,
	a.fx_discount,
	a.mx_discount,
	a.wcv_val,
	case when a.collateral_id is not null then xwdv.znesek end as wcv_delivered_val, -- Calculationg delivered collateral
	a.wcv_id_tec_val,
	a.wcov_to_wcv,
	a.alloc_type
from
	(
		select
			a.step,
			a.id_kupca,
			a.id_cont,
			a.cont_rank,
			a.exposure_val,
			case
				when a.exposure_remaining_val - xwrv.znesek < 0 then 0
				else a.exposure_remaining_val - xwrv.znesek
				end as exposure_remaining_val,
			a.exposure_id_tec_val,
			a.collateral_id,
			a.collateral_rank,
			a.fx_discount,
			a.mx_discount,
			a.wcv_val,
			a.wcv_id_tec_val,
			a.wcov_to_wcv,
			a.alloc_type
		from
			(
				select
					0 as step,
					er.id_kupca,
					er.id_cont,
					er.cont_rank,
					er.exposure_remaining_val as exposure_val,
					er.exposure_remaining_val as exposure_remaining_val,
					er.id_tec_val as exposure_id_tec_val,
					c.collateral_id,
					c.collateral_rank,
					er.fx_discount,
					c.mx_discount,
					er.fx_discount * c.wcv_remaining_val as wcv_val,
					er.fx_discount * c.wcv_remaining_val as wcv_remaining_val,
					c.id_tec_val as wcv_id_tec_val,
					c.wcov_to_wcv,
					c.alloc_type -- Automatic simple allocation
				from
					#exposure_rank er
					left join (
						-- Cover the contract with financed object
						select
							cr.id_kupca,
							c.id_cont as id_cont,
							cr.collateral_id,
							0 as collateral_rank,
							1 as mx_discount,
							cr.wcv_val as wcv_remaining_val,
							cr.id_tec_val,
							0 as wcov_to_wcv,
							'ASIA' as alloc_type -- Automatic simple allocation
						from
							#collaterals_all cr
							join #collaterals_wcv c on c.id_kupca = cr.id_kupca and c.collateral_id = cr.collateral_id
						where
							c.collateral_from_contract = 1
					) c on c.id_kupca = er.id_kupca and c.id_cont = er.id_cont
			) a
			outer apply dbo.gfn_xchange_table(a.exposure_id_tec_val, isnull(a.wcv_remaining_val, 0), a.wcv_id_tec_val, @target_date) xwrv
	) a
	outer apply dbo.gfn_xchange_table(a.wcv_id_tec_val, a.exposure_val - a.exposure_remaining_val, a.exposure_id_tec_val, @target_date) xwdv
-- Last loop doesn't allocate anything, so this will run properly for 1st step and the step of last loop
update #exposure_rank
	set exposure_remaining_val = x.exposure_remaining_val
	from (
			select step, id_kupca, id_cont, exposure_remaining_val
			from #allocation
			where step = 0
		) x
		join #exposure_rank xr on xr.id_kupca = x.id_kupca and xr.id_cont = x.id_cont
update #collaterals_all
	set wcv_remaining_val = cr.wcv_remaining_val - x.wcv_delivered_val
	from (
			select step, id_kupca, collateral_id, wcv_delivered_val
			from #allocation
			where step = 0 and collateral_id is not null
		) x
		join #collaterals_all cr on cr.id_kupca = x.id_kupca and cr.collateral_id = x.collateral_id
-- Filtering contracts for 2nd step
select a.*
into #exposure_rank_additional
from #exposure_rank a
where exists (select 1 from #additional_collateral b where a.id_cont = b.id_cont)
create clustered index pk on #exposure_rank_additional (id_kupca, id_cont)
create index ix_rank on #exposure_rank_additional (cont_rank, id_kupca)
-- 2. Covering partner's contracts with other collaterals
declare @cont_rank int, @max_cont_rank int, @collateral_rank int, @max_collateral_rank int, @step int
select @max_cont_rank = max(cont_rank) from #exposure_rank_additional
select @max_collateral_rank = max(collateral_rank) from #additional_collateral
select @step = 0
-- Ranks of contracts
set @cont_rank = 0
while isnull(@max_cont_rank, 0) > 0 and @cont_rank > -1 begin
	set @cont_rank = @cont_rank + 1
	print '### @cont_rank = ' + cast(@cont_rank as varchar) + '/' + cast(@max_cont_rank as varchar)
	-- Ranks of collaterals
	set @collateral_rank = 0
	while isnull(@max_collateral_rank, 0) > 0 and @collateral_rank > -1 begin
		set @collateral_rank = @collateral_rank + 1
		print '### @collateral_rank = ' + cast(@collateral_rank as varchar) + '/' + cast(@max_collateral_rank as varchar)
		set @step = @step + 1
		insert into #allocation
		select
			a.step,
			a.id_kupca,
			a.id_cont,
			a.cont_rank,
			a.exposure_val,
			a.exposure_remaining_val,
			a.exposure_id_tec_val,
			a.collateral_id,
			a.collateral_rank,
			a.fx_discount,
			a.mx_discount,
			a.wcv_val,
			case when a.collateral_id is not null then xwdv.znesek end as wcv_delivered_val, -- Calculationg delivered collateral
			a.wcv_id_tec_val,
			a.wcov_to_wcv,
			a.alloc_type
		from
			(
				-- Prepare values for next step
				select
					a.step,
					a.id_kupca,
					a.id_cont,
					a.cont_rank,
					a.exposure_remaining_val as exposure_val, -- Reducing exposure for next step
					case
						when a.exposure_remaining_val - isnull(xwav.znesek, 0) < 0 then 0
						else a.exposure_remaining_val - isnull(xwav.znesek, 0)
						end as exposure_remaining_val, -- Calculating remaining exposure
					a.exposure_id_tec_val,
					a.collateral_id,
					a.collateral_rank,
					a.fx_discount,
					a.mx_discount,
					a.wcv_remaining_val as wcv_val, -- Reducing collateral for next step
					a.wcv_id_tec_val,
					a.wcov_to_wcv,
					a.alloc_type
				from
					(
						-- Calculate allocation for non-automatic allocations
						select
							a.step,
							a.id_kupca,
							a.id_cont,
							a.cont_rank,
							a.exposure_val,
							a.exposure_remaining_val,
							a.exposure_id_tec_val,
							a.collateral_id,
							a.collateral_rank,
							a.mx_discount,
							a.wcov_to_wcv,
							a.fx_discount,
							a.wcv_val,
							a.wcv_remaining_val,
							a.wcv_id_tec_val,
							a.alloc_type,
							a.alloc_contracts
						from
							(
								-- Calculate discounts only on 1st collateral allocation
								select
									@step as step,
									er.id_kupca,
									er.id_cont,
									er.cont_rank,
									er.exposure_val,
									er.exposure_remaining_val,
									er.id_tec_val as exposure_id_tec_val,
									c.collateral_id,
									c.collateral_rank,
									c.mx_discount,
									-- WCOV (at start WCOV = WCV) is reduced if it's the first usege of this collateral and the exchange rates differ
									-- Other option: er.id_tec_val != c.id_tec_val -- exposure_val != collateral_val
									case when c.wcov_to_wcv = 0 and er.fx_discount_used = 1 then 1 else 0 end as wcov_to_wcv,
									case when c.wcov_to_wcv = 0 and er.fx_discount_used = 1 then @xchange_discount else 1 end as fx_discount,
									case when c.wcov_to_wcv = 0 and er.fx_discount_used = 1 then @xchange_discount else 1 end * c.mx_discount * c.wcv_val as wcv_val,
									case when c.wcov_to_wcv = 0 and er.fx_discount_used = 1 then @xchange_discount else 1 end * c.mx_discount * c.wcv_remaining_val as wcv_remaining_val,
									c.id_tec_val as wcv_id_tec_val,
									c.alloc_type,
									c.alloc_contracts
								from
									#exposure_rank_additional er
									left join #local_currency lc on lc.id_tec = er.id_tec_val
									left join (
										-- Cover the contract with next appropriate collateral
										select
											cr.id_kupca,
											ac.id_kupca_cont,
											ac.id_cont,
											cr.collateral_id,
											ac.collateral_rank,
											cr.mx_discount,
											case when left(ac.alloc_type, 3) in ('MAA', 'PRA') then ac.wcv_val else cr.wcv_val end as wcv_val,
											case when left(ac.alloc_type, 3) in ('MAA', 'PRA') then ac.wcv_remaining_val else cr.wcv_remaining_val end as wcv_remaining_val,
											cr.id_tec_val,
											case when left(ac.alloc_type, 3) in ('MAA', 'PRA') then ac.wcov_to_wcv else cr.wcov_to_wcv end as wcov_to_wcv,
											-- For wcv_allocated_val
											ac.alloc_type,
											ac.alloc_contracts
										from
											#collaterals_all cr
											join #additional_collateral ac on ac.id_kupca = cr.id_kupca and ac.collateral_id = cr.collateral_id
									) c on c.id_kupca_cont = er.id_kupca and c.id_cont = er.id_cont
										and c.collateral_rank = @collateral_rank
								where
									er.cont_rank = @cont_rank
							) a
					) a
					outer apply dbo.gfn_xchange_table(a.exposure_id_tec_val, a.wcv_remaining_val, a.wcv_id_tec_val, @target_date) xwav
			) a
			outer apply dbo.gfn_xchange_table(a.wcv_id_tec_val, a.exposure_val - a.exposure_remaining_val, a.exposure_id_tec_val, @target_date) xwdv
		update #exposure_rank_additional
			set exposure_remaining_val = x.exposure_remaining_val
			from (
					select step, id_kupca, id_cont, exposure_remaining_val
					from #allocation
					where step = @step
				) x
				join #exposure_rank_additional er on er.id_kupca = x.id_kupca and er.id_cont = x.id_cont
		-- NOT(MAA,PRA): Apply FX discount only when wcov_to_wcv goes from 0 to 1 (first usage of this collateral)
		update #collaterals_all
			set fx_discount = case when cr.wcov_to_wcv = 0 and x.wcov_to_wcv = 1 then x.fx_discount else cr.fx_discount end,
				wcv_val = case when cr.wcov_to_wcv = 0 and x.wcov_to_wcv = 1 then x.wcv_val else cr.wcv_val end,
				wcv_remaining_val = case when cr.wcov_to_wcv = 0 and x.wcov_to_wcv = 1 then x.wcv_val else cr.wcv_remaining_val end,
				wcov_to_wcv = 1
			from (
					select id_kupca, collateral_id, fx_discount, wcv_val, wcv_delivered_val, wcov_to_wcv
					from #allocation
					where step = @step and collateral_id is not null and left(alloc_type, 3) not in ('MAA', 'PRA')
				) x
				join #collaterals_all cr on cr.id_kupca = x.id_kupca and cr.collateral_id = x.collateral_id
		-- NOT(MAA,PRA): Reduce remaining value
		update #collaterals_all
			set wcv_remaining_val = cr.wcv_remaining_val - x.wcv_delivered_val -- Should be called after setting of wcv_val
			from (
					select id_kupca, collateral_id, fx_discount, wcv_val, wcv_delivered_val, wcov_to_wcv
					from #allocation
					where step = @step and collateral_id is not null and left(alloc_type, 3) not in ('MAA', 'PRA')
				) x
				join #collaterals_all cr on cr.id_kupca = x.id_kupca and cr.collateral_id = x.collateral_id
		-- MAA,PRA: Apply FX discount only when wcov_to_wcv goes from 0 to 1 (first usage of this collateral)
		update #collaterals_all
			set fx_discount = case when x.wcov_to_wcv = 1 then x.fx_discount else cr.fx_discount end,
				wcov_to_wcv = 1
			from (
					select id_kupca, collateral_id, min(fx_discount) as fx_discount, max(cast(wcov_to_wcv as int)) as wcov_to_wcv
					from #allocation
					where step = @step and collateral_id is not null and left(alloc_type, 3) in ('MAA', 'PRA')
					group by id_kupca, collateral_id
				) x
				join #collaterals_all cr on cr.id_kupca = x.id_kupca and cr.collateral_id = x.collateral_id
			where cr.wcov_to_wcv = 0
		-- MAA,PRA: If FX discount was applied in previous step, apply discount to collaterals on contracts
		update #additional_collateral
			set wcv_val = cra.wcv_val * cr.fx_discount,
				wcv_remaining_val = cra.wcv_remaining_val * cr.fx_discount,
				wcov_to_wcv = 1
			from (
					select id_kupca, collateral_id, min(fx_discount) as fx_discount
					from #allocation
					where step = @step and collateral_id is not null and left(alloc_type, 3) in ('MAA', 'PRA')
					group by id_kupca, collateral_id
				) x
				join #additional_collateral cra on cra.id_kupca = x.id_kupca and cra.collateral_id = x.collateral_id
				join #collaterals_all cr on cr.id_kupca = x.id_kupca and cr.collateral_id = x.collateral_id
			where cra.wcov_to_wcv = 0 and cr.wcov_to_wcv = 1
		-- Break
		if @collateral_rank >= @max_collateral_rank set @collateral_rank = -1
	end
	-- Break
	if @cont_rank >= @max_cont_rank set @cont_rank = -1
end
update #exposure_rank
set exposure_remaining_val = era.exposure_remaining_val
from #exposure_rank er
inner join #exposure_rank_additional era on era.id_kupca = er.id_kupca and era.id_cont = er.id_cont
update #collaterals_all
	set wcv_remaining_val = x.wcv_remaining_val
	from (
			select id_kupca, collateral_id, sum(wcv_val) as wcv_val, sum(wcv_remaining_val) as wcv_remaining_val
			from #additional_collateral
			where left(alloc_type, 3) in ('MAA', 'PRA')
			group by id_kupca, collateral_id
		) x
		join #collaterals_all cr on cr.id_kupca = x.id_kupca and cr.collateral_id = x.collateral_id
-- Remove exposures without collaterals
select
	a.id_kupca,
	a.id_cont,
	a.collateral_id
into
	#allocation_filter
from
	#allocation a
where
	a.collateral_id is not null
union all
select
	a.id_kupca,
	a.id_cont,
	a.collateral_id
from
	#allocation a
where
	a.collateral_id is null
	and not exists (
		select 1
		from #allocation a2
		where a2.collateral_id is not null
	and a2.id_kupca = a.id_kupca and a2.id_cont = a.id_cont
)
create clustered index pk on #allocation_filter (id_kupca, id_cont, collateral_id)
-- FINAL RESULT
select distinct
	a.id_kupca,
	-- Exposure
	a.id_cont,
	a.cont_rank,
	er.object_rank,
	-- Val
	er.exposure_val, -- Za posamezno pogodbo  (ID) je povsod enak
	a.exposure_val as exposure_remaining_start_val, -- Vrednost, ki jo je potrebno pokriti
	a.exposure_remaining_val as exposure_remaining_end_val, -- Vrednost, ki je ostala po pokritju s kolateralom
	a.exposure_id_tec_val,
	texp.id_val as exposure_id_val_val,
	-- Eur
	xee.znesek as exposure_eur,
	xerse.znesek as exposure_remaining_start_eur,
	xeree.znesek as exposure_remaining_end_eur,
	@id_tec_prod_eur as exposure_id_tec_eur,
	teur.id_val as exposure_id_val_eur,
	-- Collateral
	a.collateral_id,
	a.collateral_rank,
	a.alloc_type,
	case when left(ac.alloc_type, 3) in ('MAA', 'PRA') then ac.alloc_percentage else 100.0 end as alloc_percentage,
	-- Val
	cr.wcov_val, -- Za posamezen kolateral (ID) je povsod enak
	case when a.step = 0 then a.fx_discount else cr.fx_discount end fx_discount,
	cr.mx_discount,
	case when left(ac.alloc_type, 3) in ('MAA', 'PRA') then ac.wcv_val else cr.wcv_val end as wcv_val, -- Za posamezen kolateral (ID) je povsod enak, diskounti so že upoštevani
	a.wcv_val as wcv_remaining_val, -- Vrednost, ki je v tem koraku na voljo za pokrivanje
	a.wcv_delivered_val, -- Koliko od razpoložljivega se je porabilo
	a.wcv_id_tec_val,
	tcol.id_val as wcv_id_val_val,
	-- Eur
	xwoe.znesek as wcov_eur,
	xwe.znesek as wcv_eur,
	xwre.znesek as wcv_remaining_eur,
	xwde.znesek as wcv_delivered_eur,
	@id_tec_prod_eur as wcv_id_tec_eur,
	teur.id_val as wcv_id_val_eur
into #result_contract_allocation
from
	#allocation a
	join #allocation_filter af on af.id_kupca = a.id_kupca and af.id_cont = a.id_cont and isnull(af.collateral_id, '') = isnull(a.collateral_id, '')
	left join #exposure_rank er on er.id_cont = a.id_cont
	left join #collaterals_all cr on cr.collateral_id = a.collateral_id
	left join #additional_collateral ac on ac.collateral_id = a.collateral_id and ac.id_cont = a.id_cont
	outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, er.exposure_val, a.exposure_id_tec_val, @target_date) xee
	outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, a.exposure_val, a.exposure_id_tec_val, @target_date) xerse
	outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, a.exposure_remaining_val, a.exposure_id_tec_val, @target_date) xeree
	outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, cr.wcov_val, a.wcv_id_tec_val, @target_date) xwoe
	outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, case when left(ac.alloc_type, 3) in ('MAA', 'PRA') then ac.wcv_val else cr.wcv_val end, a.wcv_id_tec_val, @target_date) xwe
	outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, a.wcv_val, a.wcv_id_tec_val, @target_date) xwre
	outer apply dbo.gfn_xchange_table(@id_tec_prod_eur, a.wcv_delivered_val, a.wcv_id_tec_val, @target_date) xwde
	left join dbo.tecajnic texp on texp.id_tec = a.exposure_id_tec_val
	left join dbo.tecajnic tcol on tcol.id_tec = a.wcv_id_tec_val
	left join dbo.tecajnic teur on teur.id_tec = @id_tec_prod_eur
order by
	id_kupca,
	cont_rank,
	collateral_rank
-- Overview of collaterals by collateral and partner
-- Return results
if object_id('tempdb..' + @temp_table_result_name) is not null begin
	declare @sql_insert varchar(max)
	set @sql_insert = '
	alter table {temp_tale_result_name} add
		id_kupca char(6), id_cont int, cont_rank int, object_rank int,
		exposure_val decimal(18,2), exposure_remaining_start_val decimal(18,2), exposure_remaining_end_val decimal(18,2), exposure_id_tec_val char(3), exposure_id_val_val char(3),
		exposure_eur decimal(18,2), exposure_remaining_start_eur decimal(18,2), exposure_remaining_end_eur decimal(18,2), exposure_id_tec_eur char(3), exposure_id_val_eur char(3),
		collateral_id varchar(20), collateral_rank int,
		fx_discount decimal(10,6), mx_discount decimal(10,6), alloc_type varchar(10), alloc_percentage decimal(9,2),
		wcov_val decimal(18,2), wcv_val decimal(18,2), wcv_remaining_val decimal(18,2), wcv_delivered_val decimal(18,2), wcv_id_tec_val char(3), wcv_id_val_val char(3),
		wcov_eur decimal(18,2), wcv_eur decimal(18,2), wcv_remaining_eur decimal(18,2), wcv_delivered_eur decimal(18,2), wcv_id_tec_eur char(3), wcv_id_val_eur char(3)
	if exists(select * from tempdb.sys.columns where name = ''null'' and object_id = object_id(''tempdb..{temp_tale_result_name}'')) begin
		alter table {temp_tale_result_name} drop column [null]
	end'
	set @sql_insert = replace(@sql_insert, '{temp_tale_result_name}', @temp_table_result_name)
	exec(@sql_insert)
	set @sql_insert = '
	insert into {temp_tale_result_name}
		(id_kupca, id_cont, cont_rank, object_rank,
		exposure_val, exposure_remaining_start_val, exposure_remaining_end_val, exposure_id_tec_val, exposure_id_val_val,
		exposure_eur, exposure_remaining_start_eur, exposure_remaining_end_eur, exposure_id_tec_eur, exposure_id_val_eur,
		collateral_id, collateral_rank, fx_discount, mx_discount, alloc_type, alloc_percentage,
		wcov_val, wcv_val, wcv_remaining_val, wcv_delivered_val, wcv_id_tec_val, wcv_id_val_val,
		wcov_eur, wcv_eur, wcv_remaining_eur, wcv_delivered_eur, wcv_id_tec_eur, wcv_id_val_eur)
	select id_kupca, id_cont, cont_rank, object_rank,
		exposure_val, exposure_remaining_start_val, exposure_remaining_end_val, exposure_id_tec_val, exposure_id_val_val,
		exposure_eur, exposure_remaining_start_eur, exposure_remaining_end_eur, exposure_id_tec_eur, exposure_id_val_eur,
		collateral_id, collateral_rank, fx_discount, mx_discount, alloc_type, alloc_percentage,
		wcov_val, wcv_val, wcv_remaining_val, wcv_delivered_val, wcv_id_tec_val, wcv_id_val_val,
		wcov_eur, wcv_eur, wcv_remaining_eur, wcv_delivered_eur, wcv_id_tec_eur, wcv_id_val_eur
	from #result_contract_allocation'
	set @sql_insert = replace(@sql_insert, '{temp_tale_result_name}', @temp_table_result_name)
	exec(@sql_insert)
end else begin
	select * from #result_contract_allocation
end
drop table #exclude_lease_types
drop table #local_currency
drop table #contract_candidates
drop table #exposures_tmp
drop table #exposures
drop table #exposure_rank_additional
drop table #b2opprod
drop table #exposure_rank
drop table #collaterals_all
drop table #additional_collateral
drop table #allocation
drop table #allocation_filter
drop table #result_contract_allocation
drop table #collaterals_wcv