--select *from dbo.oc_reports order by 1 desc
declare @id_oc_report int = 129
DECLARE @date_to datetime --datum izvještaja
SET @date_to = (SELECT date_to FROM gv_OcReports WHERE id_oc_report = @id_oc_report)

	select * 
	into #kred_planp_buduci
	from dbo.kred_planp p
	where p.dat_zap > @date_to and p.id_oc_report = @id_oc_report

	--s kamatom
	SELECT p.id_kredpog, p.id_oc_report
		, min(dat_zap) datum_otpl_sled_kamate, max(dat_zap) datum_otpl_zadnje_kamate 
	INTO #kred_dat_znes_o1
	FROM #kred_planp_buduci p
	WHERE p.znes_o<>0 
	GROUP BY p.id_kredpog, p.id_oc_report
select * from #kred_dat_znes_o1
	
	--obroèni bez iznosa kamate
	select p.id_kredpog, p.id_oc_report
		,  min(dat_zap) datum_otpl_sled_kamate, max(dat_zap) datum_otpl_zadnje_kamate
	into #kred_dat_znes_o2
	from #kred_planp_buduci p 
	where znes_o = 0 and znes_r = 0 and crpanje = 0
	and not exists (select * from #kred_dat_znes_o1 where id_kredpog = p.id_kredpog)
	group by p.id_kredpog, p.id_oc_report
select * from #kred_dat_znes_o2

	--anuitetni bez iznosa kamate
	select p.id_kredpog, p.id_oc_report
		,  min(dat_zap) datum_otpl_sled_kamate, max(dat_zap) datum_otpl_zadnje_kamate
	into #kred_dat_znes_o3
	from #kred_planp_buduci p 
	where znes_r != 0
	and not exists (select * from #kred_dat_znes_o1 where id_kredpog = p.id_kredpog)
	and not exists (select * from #kred_dat_znes_o2 where id_kredpog = p.id_kredpog)
	group by p.id_kredpog, p.id_oc_report
select * from #kred_dat_znes_o3

	select * from #kred_dat_znes_o1
	union all
	select * from #kred_dat_znes_o2
	union all
	select * from #kred_dat_znes_o3

drop table #kred_planp_buduci
drop table #kred_dat_znes_o1
drop table #kred_dat_znes_o2
drop table #kred_dat_znes_o3