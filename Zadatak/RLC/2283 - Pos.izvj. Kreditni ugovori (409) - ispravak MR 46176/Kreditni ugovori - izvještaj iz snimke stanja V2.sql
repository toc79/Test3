--Poročilo o kreditnih pogodb za RAIFFEISEN
--10.02.2021 g_tomislav MR 46176 - dodavanje podatka datuma sljedeće kamate i za slučajeve kada je kamata 0 

-- PARAMETERS
DECLARE	@id_oc_report int
SET    	@id_oc_report = {1}
--
DECLARE @date_to datetime --datum izvještaja
SET @date_to = (SELECT date_to FROM gv_OcReports WHERE id_oc_report = @id_oc_report)


SELECT  a.id_kredpog, 
	a.status_akt, 
	a.id_kupca,
	b.naz_kr_kup, 
	c.id_val, 
	a.sit_znes, 
	a.val_znes, 
	a.dat_sklen,
        CASE WHEN a.tip_pog <> 1 THEN a.crpan_znes ELSE ISNULL(d.crpan_znes, 0) END AS crpan_znes,
	a.anuiteta,
	r.naziv as naziv_r,
	r.id_tiprep, 
	a.fix_del,
	a. managment, 
	a.comm, 
	a.ostali_str,
	a.skupna_cena,
	a.refinanc,
	a.oznaka, 
	a.njih_st, 
	o.naziv as naziv_o,
	a.tip_pog,
	a.id_oc_report
      INTO #kred_pog	
      FROM dbo.kred_pog a
      INNER JOIN dbo.oc_customers b ON a.id_kupca = b.id_kupca and a.id_oc_report = b.id_oc_report	
      INNER JOIN dbo.tecajnic c ON a.id_tec = c.id_tec and a.id_oc_report = c.id_oc_report	
      LEFT JOIN (SELECT SUM(crpan_znes) AS crpan_znes, id_krov_pog, id_oc_report
                   FROM dbo.kred_pog
                  WHERE tip_pog = 2
                  GROUP BY id_krov_pog, id_oc_report) d ON a.id_kredpog = d.id_krov_pog and a.id_oc_report = d.id_oc_report
     LEFT OUTER JOIN dbo.rtip r ON a.id_rtip = r.id_rtip and a.id_oc_report = r.id_oc_report	
     LEFT OUTER JOIN dbo.obdobja o ON a.id_odplac = o.id_obd and a.id_oc_report = o.id_oc_report	
     WHERE a.id_oc_report = @id_oc_report	 

  SELECT  min(dat_zap) as dat_otpl_prve_rate_gl, max(dat_zap) as dat_otpl_zadnje_rate_gl, p.id_kredpog, p.id_oc_report
      INTO #kred_dat
      FROM dbo.kred_planp p
      WHERE p.znes_r<>0 and p.id_oc_report = @id_oc_report
      GROUP BY p.id_kredpog, p.id_oc_report
	
  SELECT  DATEDIFF (month,k.dat_sklen, min(p.dat_zap)) as grace_period,
	DATEDIFF (month,k.dat_sklen, max(p.dat_zap)) as total_period, p.id_kredpog, p.id_oc_report
   INTO #kred_per
      FROM dbo.kred_planp p 
     INNER JOIN kred_pog k ON  p.id_kredpog=k.id_kredpog and p.id_oc_report= k.id_oc_report
    WHERE p.anuiteta <> 0 and p.id_oc_report = @id_oc_report
     GROUP BY p.id_kredpog, k.dat_sklen, p.id_oc_report

  SELECT  max(dat_zap) as dat_koristenja, p.id_kredpog, p.id_oc_report
  INTO #kred_kor 
      FROM dbo.kred_planp p 
    WHERE p.crpanje<>0   and p.id_oc_report = @id_oc_report
     GROUP BY p.id_kredpog, p.id_oc_report

    SELECT sum(p.znes_r) as bud_glavnica, sum(p.znes_o) as bud_kamate, p.id_kredpog, p.id_oc_report
      INTO #kred_planp
      FROM dbo.kred_planp p 
     WHERE p.dat_zap > @date_to and p.id_oc_report = @id_oc_report
   GROUP BY p.id_kredpog, p.id_oc_report

    SELECT sum(p.znes_r) as ocek_outst, p.id_kredpog, p.id_oc_report
      INTO #kred_outst
      FROM dbo.kred_planp p 
     WHERE p.dat_zap > STR(year(getdate()), 4) + '1231' and p.id_oc_report = @id_oc_report
     GROUP BY p.id_kredpog, p.id_oc_report

    SELECT sum(p.znes_r) as otpl_gl_do_dana_izv, p.id_kredpog, p.id_oc_report
      INTO #kred_otpl
      FROM dbo.kred_planp p 
     WHERE p.dat_zap >= STR(year(getdate()), 4) + '0101' and p.dat_zap < @date_to and p.id_oc_report = @id_oc_report
     GROUP BY p.id_kredpog, p.id_oc_report

    SELECT sum(p.znes_r) as ostat_gl_od_dana_izv, p.id_kredpog, p.id_oc_report
      INTO #kred_ostat
      FROM dbo.kred_planp p 
     WHERE p.dat_zap <= STR(year(getdate()), 4) + '1231' and p.dat_zap >= @date_to and p.id_oc_report = @id_oc_report
     GROUP BY p.id_kredpog, p.id_oc_report
	
	--====================
	--Izračun datuma sljedeće kamate
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
	
	--obročni bez iznosa kamate
	select p.id_kredpog, p.id_oc_report
		,  min(dat_zap) datum_otpl_sled_kamate, max(dat_zap) datum_otpl_zadnje_kamate
	into #kred_dat_znes_o2
	from #kred_planp_buduci p 
	where znes_o = 0 and znes_r = 0 and crpanje = 0
	and not exists (select * from #kred_dat_znes_o1 where id_kredpog = p.id_kredpog)
	group by p.id_kredpog, p.id_oc_report

	--anuitetni bez iznosa kamate
	select p.id_kredpog, p.id_oc_report
		,  min(dat_zap) datum_otpl_sled_kamate, max(dat_zap) datum_otpl_zadnje_kamate
	into #kred_dat_znes_o3
	from #kred_planp_buduci p 
	where znes_r != 0
	and not exists (select * from #kred_dat_znes_o1 where id_kredpog = p.id_kredpog)
	and not exists (select * from #kred_dat_znes_o2 where id_kredpog = p.id_kredpog)
	group by p.id_kredpog, p.id_oc_report

	select * 
	into #kred_dat_znes_o
	from #kred_dat_znes_o1
	union all
	select * from #kred_dat_znes_o2
	union all
	select * from #kred_dat_znes_o3
	--====================

SELECT  a.id_kredpog as broj_kreditnog_ugovora,
	a.status_akt as status, 
	a.id_kupca as sifra_davatelja,
	a.naz_kr_kup as kreditodavac, 
	a.id_val as valuta, 
	a.sit_znes as kredit_dom_valuta, 
	a.val_znes as kredit_val, 
	a.dat_sklen as datum_sklapanja,
    d.dat_otpl_prve_rate_gl,
	d.dat_otpl_zadnje_rate_gl,
	r.grace_period,
	r.total_period,
	k.dat_koristenja,
    (CASE WHEN a.tip_pog = 4 THEN ISNULL(x.sum_crpan_znes, 0) - ISNULL(x.znes_r, 0) ELSE ISNULL(a.crpan_znes, 0) END) as koristeno_ukupno, 
	p.bud_glavnica, 
	p.bud_kamate,
	a.anuiteta as iznos_rate_glavnice,
	a.naziv_r as indeks_kamate,
	a.fix_del as fiksna_marza,
	a.managment as menagment_fee, 
	a.comm as commitment_fee, 
	a.ostali_str as ostali_troskovi,
	a.skupna_cena as all_in_price,
	a.refinanc as kod_ref,
	a.oznaka, 
	a.njih_st as njihov_broj, 
	a.naziv_o as nacin_placanja_glavnice,
	o.ocek_outst,
	t.otpl_gl_do_dana_izv,
	s.ostat_gl_od_dana_izv,
	case when a.id_tiprep != 0 then b.datum_otpl_sled_kamate else b.datum_otpl_zadnje_kamate end as Dat_otpl_prve_sled_kamate
FROM #kred_pog a
LEFT JOIN #kred_planp p ON a.id_kredpog = p.id_kredpog 
LEFT JOIN #kred_dat d ON a.id_kredpog = d.id_kredpog  
LEFT JOIN #kred_per r ON a.id_kredpog = r.id_kredpog    
LEFT JOIN #kred_kor k ON a.id_kredpog = k.id_kredpog   
LEFT JOIN #kred_outst o ON a.id_kredpog = o.id_kredpog   
LEFT JOIN #kred_otpl t ON a.id_kredpog = t.id_kredpog   
LEFT JOIN #kred_ostat s ON a.id_kredpog = s.id_kredpog    
LEFT JOIN (SELECT id_kredpog, sum(case when placano = 1 then znes_r else 0 end) as znes_r,    sum(crpanje) as sum_crpan_znes
		   FROM dbo.kred_planp
		 WHERE id_oc_report = @id_oc_report
		  GROUP BY id_kredpog) AS x ON a.id_kredpog = x.id_kredpog
LEFT JOIN #kred_dat_znes_o b ON a.id_kredpog = b.id_kredpog
ORDER BY a.id_kredpog


drop table #kred_pog
drop table #kred_planp
drop table #kred_dat
drop table #kred_per
drop table #kred_kor
drop table #kred_outst
drop table #kred_otpl
drop table #kred_ostat
drop table #kred_planp_buduci
drop table #kred_dat_znes_o1
drop table #kred_dat_znes_o2
drop table #kred_dat_znes_o3
drop table #kred_dat_znes_o 
