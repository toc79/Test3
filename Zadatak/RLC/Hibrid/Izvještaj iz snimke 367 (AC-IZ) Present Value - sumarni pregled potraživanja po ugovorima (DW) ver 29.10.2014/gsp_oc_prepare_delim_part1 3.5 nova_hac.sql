------------------------------------------------------------------
-- 
-- History:
-- 28.05.2016 Matjaz; created - extract from oc_prepare and split into several steps to optimize performance and shorten locks on planp
------------------------------------------------------------------
CREATE PROCEDURE [dbo].[gsp_oc_prepare_delim_part1]
	@id_terj_lobr char(2), 
	@id_terj_oobr char(2), 
	@report_id int, 
	@date_to datetime
WITH RECOMPILE AS
select max(a.datum_dok) as ex_instpreTD_DD, id_cont
into #planp1
from dbo.planp as a
inner join dbo.nacini_l as b on a.nacin_leas = b.nacin_leas
where a.datum_dok <= @date_to
and (a.id_terj = case when b.installment_credit = 0 then @id_terj_lobr else @id_terj_oobr end)
group by a.id_cont
create nonclustered index _ix_planp1 on #planp1 (id_cont)
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - delimiting part of interests in claim (step 1.1)'
select pr.id_cont, pr.ex_instpreTD_DD, pp.ID_TEC, pp.NACIN_LEAS, pp.NETO, pp.OBRESTI, pp.ROBRESTI, pp.REGIST, pp.MARZA
into #planp2
from #planp1 pr
inner join dbo.planp pp on pp.id_cont = pr.id_cont and pp.datum_dok = pr.ex_instpreTD_DD
inner join dbo.NACINI_L as b on pp.nacin_leas = b.nacin_leas
and pp.id_terj = case when b.installment_credit = 0 then @id_terj_lobr else @id_terj_oobr end
create nonclustered index _ix_planp2 on #planp2 (id_cont) 
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - delimiting part of interests in claim (step 1.2)'
select
	c.id_oc_report,
	c.id_cont,
	max(pp.ex_instpreTD_DD) as ex_instpreTD_DD,
	sum(en.znesek) as ex_net_instpreTD,
	sum(ei.znesek) as ex_int_instpreTD,
	sum(eri.znesek) as ex_rint_instpreTD,
	sum(ere.znesek) as ex_regist_instpreTD,
	sum(em.znesek) as ex_marza_instpreTD
into #temp_delim1
from dbo.oc_contracts c
inner join #planp2 pp on c.id_cont = pp.id_cont
--inner join dbo.planp pp on pp.id_cont = pr.id_cont and pp.datum_dok = pr.ex_instpreTD_DD
outer apply dbo.gfn_xchange_table(c.id_tec, pp.neto, pp.id_tec, @date_to) en
outer apply dbo.gfn_xchange_table(c.id_tec, pp.obresti, pp.id_tec, @date_to) ei
outer apply dbo.gfn_xchange_table(c.id_tec, pp.robresti, pp.id_tec, @date_to) eri
outer apply dbo.gfn_xchange_table(c.id_tec, pp.regist, pp.id_tec, @date_to) ere
outer apply dbo.gfn_xchange_table(c.id_tec, pp.marza, pp.id_tec, @date_to) em
where c.id_oc_report = @report_id
group by c.id_oc_report, c.id_cont
create nonclustered index _ix_temp_delim1 on #temp_delim1 (id_cont)
	
exec dbo.gsp_log_sproc 'gsp_oc_prepare', 'Performing updates in tables - delimiting part of interests in claim (step 1.3)'
update dbo.oc_contracts
	set ex_instpreTD_DD = a.ex_instpreTD_DD,
		ex_net_instpreTD = a.ex_net_instpreTD,
		ex_int_instpreTD = a.ex_int_instpreTD,
		ex_rint_instpreTD = a.ex_rint_instpreTD,
		ex_regist_instpreTD = a.ex_regist_instpreTD,
		ex_marza_instpreTD = a.ex_marza_instpreTD
from dbo.oc_contracts c
inner join #temp_delim1 a on a.id_cont = c.id_cont
where c.id_oc_report = @report_id
drop table #planp1
drop table #planp2
drop table #temp_delim1