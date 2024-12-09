USE [Nova_rlc]
GO
/****** Object:  StoredProcedure [dbo].[gsp_oc_prepare_delim_part2]    Script Date: 7.2.2018. 14:03:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------
-- 
-- History:
-- 28.05.2016 Matjaz; created - extract from oc_prepare and split into several steps to optimize performance and shorten locks on planp
------------------------------------------------------------------

ALTER PROCEDURE [dbo].[gsp_oc_prepare_delim_part2]
	@id_terj_lobr char(2), 
	@id_terj_oobr char(2), 
	@report_id int, 
	@date_to datetime
WITH RECOMPILE AS

select min(a.datum_dok) as ex_instpostTD_DD, id_cont
into #planp3
from dbo.planp as a
inner join dbo.nacini_l as b on a.nacin_leas = b.nacin_leas
where a.datum_dok > @date_to
and (a.id_terj = case when b.installment_credit = 0 then @id_terj_lobr else @id_terj_oobr end)
group by a.id_cont

create nonclustered index _ix_planp3 on #planp3 (id_cont)

exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - delimiting part of interests in claim (step 2.1)'


select pr.id_cont, pr.ex_instpostTD_DD, pp.ID_TEC, pp.NACIN_LEAS, pp.NETO, pp.OBRESTI, pp.ROBRESTI, pp.REGIST, pp.MARZA
into #planp4
from #planp3 pr
inner join dbo.planp pp on pp.id_cont = pr.id_cont and pp.datum_dok = pr.ex_instpostTD_DD
inner join dbo.NACINI_L as b on pp.nacin_leas = b.nacin_leas
and pp.id_terj = case when b.installment_credit = 0 then @id_terj_lobr else @id_terj_oobr end

create nonclustered index _ix_planp4 on #planp4 (id_cont) 

exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - delimiting part of interests in claim (step 2.2)'


select
	c.id_oc_report,
	c.id_cont,
	max(pp.ex_instpostTD_DD) as ex_instpostTD_DD,
	sum(en.znesek) as ex_net_instpostTD,
	sum(ei.znesek) as ex_int_instpostTD,
	sum(eri.znesek) as ex_rint_instpostTD,
	sum(ere.znesek) as ex_regist_instpostTD,
	sum(em.znesek) as ex_marza_instpostTD
into #temp_delim2
from dbo.oc_contracts c
inner join #planp4 pp on c.id_cont = pp.id_cont
--inner join dbo.planp pp on pp.id_cont = pr.id_cont and pp.datum_dok = pr.ex_instpostTD_DD
outer apply dbo.gfn_xchange_table(c.id_tec, pp.neto, pp.id_tec, @date_to) en
outer apply dbo.gfn_xchange_table(c.id_tec, pp.obresti, pp.id_tec, @date_to) ei
outer apply dbo.gfn_xchange_table(c.id_tec, pp.robresti, pp.id_tec, @date_to) eri
outer apply dbo.gfn_xchange_table(c.id_tec, pp.regist, pp.id_tec, @date_to) ere
outer apply dbo.gfn_xchange_table(c.id_tec, pp.marza, pp.id_tec, @date_to) em
where c.id_oc_report = @report_id
group by c.id_oc_report, c.id_cont

create nonclustered index _ix_temp_delim2 on #temp_delim2 (id_cont)
	
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - delimiting part of interests in claim (step 2.3)'


update dbo.oc_contracts
	set ex_instpostTD_DD = a.ex_instpostTD_DD,
		ex_net_instpostTD = a.ex_net_instpostTD,
		ex_int_instpostTD = a.ex_int_instpostTD,
		ex_rint_instpostTD = a.ex_rint_instpostTD,
		ex_regist_instpostTD = a.ex_regist_instpostTD,
		ex_marza_instpostTD = a.ex_marza_instpostTD
from dbo.oc_contracts c
inner join #temp_delim2 a on a.id_cont = c.id_cont
where c.id_oc_report = @report_id

drop table #planp3
drop table #planp4
drop table #temp_delim2
