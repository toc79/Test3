DECLARE @id varchar(100)
SET @id = 56149 --55980 --56149

SELECT 
	a.id_pog,
	a.pred_naj,
	a.prv_obr,
	-- round(a.prv_obr * 100 / (100 + st.davek), 2) as prv_obr_neto,
	a.dat_sklen,
	a.id_val,
	a.ost_obr,
	-- round(a.ost_obr * 100 / (100 + st.davek), 2) as ost_obr_neto,
	-- pd.debit as sum_debit_rata,
	a.id_dav_st,
	a.man_str,
	-- round(a.man_str * 100 / (100 + st.davek), 2) as man_str_neto,
	-- round(a.man_str * st.davek / (100 + st.davek), 2) as man_str_davek,
	a.st_obrok,
	a.dovol_km,
	CAST(a.dovol_km AS int) AS dovol_km_int,
	a.cena_dkm,
	a.traj_naj,
	a.obr_mera,
	a.vr_val, a.vr_val_zac, 
	-- CAST(ROUND(a.vr_val/(1+(op.davek/100)),2) as decimal(18,2)) as vr_val_neto,
	a.varscina,
	a.opcija,
	a.vnesel, dbo.gfn_GetUserDesc(a.vnesel) AS vnesel_desc, a.robresti_val, a.robresti_sit
	-- , round(c.vr_bruto-c.vr_neto,2) as pred_ddv,
	a.dni_zap, 
/* DORADA ZA PPMV
	-- round((a.prv_obr-c.robresti_val*(c.prv_obr_p/100)) * st.davek / (100 + st.davek), 2) as PRV_OBR_DAVEK,
	-- c.prv_obr-c.prv_obr_n AS PRV_OBR_DDV, 
	-- round(c.prv_obr_n-(c.robresti_val*(c.prv_obr_p/100)),2) as PRV_OBR_N_BP,
	-- round(c.robresti_val*(c.prv_obr_p/100),2) as PRV_OBR_PPMV,
	-- round(c.ost_obr_n-((c.robresti_val-(c.robresti_val*(c.prv_obr_p/100))-(c.robresti_val*(c.opcija_p/100)))/c.st_obrok),2) as OST_OBR_N_BP,
	-- round((a.ost_obr-((c.robresti_val-(c.robresti_val*(c.prv_obr_p/100))-(c.robresti_val*(c.opcija_p/100)))/c.st_obrok)) * st.davek / (100 + st.davek), 2) as OST_OBR_DAVEK,
	-- c.ost_obr_b-c.ost_obr_n as OST_OBR_DDV,
	-- round(((c.robresti_val-(c.robresti_val*(c.prv_obr_p/100))-(c.robresti_val*(c.opcija_p/100)))/c.st_obrok),2) as OST_OBR_PPMV,
	-- c.ost_obr_b as OST_OBR_B,
ALLT(TRANS(ROUND((_ponudba.opcija-(_ponudba.robresti_val*(_ponudba.opcija_p/100)))*(lookup(dav_stop_pp.davek, _ponudba.id_dav_st, dav_stop_pp.id_dav_st)/100),2),GCCIF)) --OPC_DDV
	-- round((a.opcija-(a.robresti_val*(c.opcija_p/100)))*(st.davek / 100),2) as OPC_DDV,
	-- round(a.robresti_val*(c.opcija_p/100),2) as OPC_PPMV,
ALLT(TRANS(ROUND(((_ponudba.opcija-(_ponudba.robresti_val*(_ponudba.opcija_p/100)))*(lookup(dav_stop.davek, _ponudba.id_dav_st, dav_stop.id_dav_st)/100))+_ponudba.opcija,2),GCCIF)) --OPC_B
	-- round(a.opcija + (a.opcija-(a.robresti_val*(c.opcija_p/100)))*(st.davek / 100),2) as OPC_B,
UK_PR_VRED_N
ROUND(_ponudba.opcija-(_ponudba.robresti_val*(_ponudba.opcija_p/100))+_ponudba.varscina,2)
	-- round((a.opcija-(a.robresti_val*(c.opcija_p/100))+a.varscina),2) AS UK_PR_VRED_N, 
UK_PR_VRED_DDV
ROUND((_ponudba.opcija-(_ponudba.robresti_val*(_ponudba.opcija_p/100))+_ponudba.varscina)*(lookup(dav_stop.davek, _ponudba.id_dav_st, dav_stop.id_dav_st)/100),2)
	-- round((a.opcija-(a.robresti_val*(c.opcija_p/100))+a.varscina)*(st.davek/100),2) as UK_PR_VRED_PDV,
UK_PR_VRED 
UK_PR_VRED_N+UK_PR_VRED_DDV+ROUND(_ponudba.robresti_val*(_ponudba.opcija_p/100),2)
	-- round(((a.opcija-(a.robresti_val*(c.opcija_p/100))+a.varscina))+((a.opcija-(a.robresti_val*(c.opcija_p/100))+a.varscina)*(st.davek/100))+(a.robresti_val*(c.opcija_p/100)),2) AS UK_PR_VRED,
KRAJ DORADE PPMV */
	CASE WHEN v.se_regis = '*' THEN 1 ELSE 0 END as print_se_regis,
	v.tip_opr,
	p.polni_naz as part_polni_naz,
	p.dav_stev as part_dav_stev,
	p.ulica_sed as part_ulica_sed,
	p.id_poste_sed as part_id_poste_sed,
	p.mesto_sed as part_mesto_sed,
	p.emso as part_emso,
	p.direktor as part_direktor,
	p.vr_osebe as part_vr_osebe,
	p.naz_kr_kup as part_naz_kr_kup,
	p.stev_reg as part_stev_reg,
	a.id_pon,
	c.dat_pon,
	c.plac_zac,
	c.manstr_p,
	c.opcija_p,
	c.varsc_p,
	c.prv_obr_p,
	c.st_predr,
	--right('0' + cast(datepart(dd,a.dat_predr) as varchar(2)), 2)+'.'+right('0' + cast(datepart(mm,a.dat_predr) as varchar(2)), 2)+'.'+	cast(datepart(yyyy,a.dat_predr) as char(4))+'.' END
	CASE WHEN c.dat_predr IS NULL THEN '' ELSE ' od '+CONVERT(varchar(10), c.dat_predr, 104) END AS dat_predr_txt,
	d.naz_kr_kup as dob_naz_kr_kup,
	d.dav_stev as dob_dav_stev,
	d.ulica_sed as dob_ulica_sed,
	d.id_poste_sed as dob_id_poste_sed,
	d.mesto_sed as dob_mesto_sed,
	d.emso as dob_emso,
	-- st.davek as st_davek,
	-- op.davek as op_davek,
	dbo.gfn_Nacin_leas_HR(a.nacin_leas) AS tip_leas,
	-- t.naziv as naziv_tec,
	a.naziv_tuje,
	isnull(kat.value,'') as kateg1_value,
	a.spl_pog,
	-- strm.mesto as str_mesto,
	dbo.gfn_xchange(a.id_tec,c.str_notar,'000',c.dat_pon) as str_notar
	-- , ISNULL(man_stros.bruto,0) AS man_stros_bruto
From pogodba a
LEFT JOIN dbo.vrst_opr v ON a.id_vrste = v.id_vrste
LEFT JOIN dbo.partner p ON a.id_kupca = p.id_kupca
LEFT JOIN dbo.ponudba c ON a.id_pon = c.id_pon
LEFT JOIN dbo.partner d ON a.id_dob = d.id_kupca
-- LEFT JOIN (select id_register, id_key, [value] from dbo.general_register where id_register = '_kategorija1') kat on a.kategorija1 = kat.id_key
-- INNER JOIN dbo.dav_stop st ON st.id_dav_st = a.id_dav_st
-- INNER JOIN dbo.dav_stop op ON op.id_dav_st = a.id_dav_op
-- INNER JOIN dbo.nacini_l nl ON a.nacin_leas = nl.nacin_leas
-- INNER JOIN dbo.tecajnic t on a.id_tec = t.id_tec
-- LEFT JOIN dbo.strm1 strm on a.id_strm = strm.id_strm
-- LEFT JOIN (Select pp.id_cont, Sum(pp.neto) as neto, sum(pp.obresti) as kamata, sum(pp.davek) as davek, sum(pp.debit) as debit 
	-- From dbo.planp pp Inner Join dbo.vrst_ter vt on pp.id_terj = vt.id_terj
			-- Where vt.sif_terj='LOBR' and pp.id_cont = @id group by pp.id_cont) pd on a.id_cont = pd.id_cont
-- LEFT JOIN (Select pp.id_cont, Sum(pp.neto+pp.marza) as neto, sum(pp.davek) as davek, sum(pp.debit) as bruto 
	-- From dbo.planp pp Inner Join dbo.vrst_ter vt on pp.id_terj = vt.id_terj
			-- Where vt.sif_terj='MSTR' and pp.id_cont = @id group by pp.id_cont) man_stros on a.id_cont = pd.id_cont
where a.id_cont= @id