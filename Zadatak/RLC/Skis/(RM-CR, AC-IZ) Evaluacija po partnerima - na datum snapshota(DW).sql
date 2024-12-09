--MID 33144 03.11.2015 OB izbacivanje ugovora zakupa i najma
--MID 37010 23.12.2016 Dodavanje kolona Kategorija4-5-6
DECLARE	@id_oc_report int, @id_tec char(3), @id_val char(3), @target_date datetime, @okvir_status int
SET    	@id_oc_report = {1}
SET     @id_tec= {3}
SET     @id_val = {5}
SET     @okvir_status = {6}

-- EXCLUDE LEASE TYPES
SELECT id_key as nacin_leas
INTO #exclude_lease_types
FROM dbo.general_register
WHERE id_oc_report = @id_oc_report
AND id_register = 'RL_REGION_EXCLUDE_LEASE_TYPES'
AND neaktiven = 0

Select @target_date=date_to from dbo.gv_OcReports Where id_oc_report=@id_oc_report

Select a.id_kupca, a.ext_id id_kupca2, a.naziv1_kup, 
	a.dav_stev as matbr, a.emso as jmbg, CASE WHEN a.vr_osebe = 'SP' THEN a.stev_reg ELSE '' END AS stev_reg
	, a.vr_osebe as vr_osobe, a.skrbnik_2, pov.id_grupe, gp.opis, gp.id_kupca as nositelj_grupe, a1.naziv1_kup as naz_nos_grupe
	, a.sif_dej, ISNULL(dj.b2grupa,'') as nace
	, c.dat_eval,left(c.eval_model,2) as eval_model, RIGHT(RTRIM(c.eval_model),1) as gams_flag, c.model_naziv, c.tec_limite
	, CASE WHEN YEAR(c.datum_bil)=1899 THEN NULL ELSE c.datum_bil END datum_bil
	, ISNULL(dbo.gfn_xchange(@id_tec,pbil.prihodki, c.tec_limite, @target_date,@id_oc_report),0) prihodki
	, ISNULL(dbo.gfn_xchange(@id_tec,pbil.sredstva, c.tec_limite, @target_date,@id_oc_report),0) sredstva
	, ISNULL(c.limita,0) limita
	, c.rating1, c.rating2, c.uk_rating, c.kateg_b2, c.kategorija1, c.kateg1_opis, c.DAT_NASL_VRED
	, ISNULL(b.net_nal,0) net_nal
	, ISNULL(d.odr,0) odr, ISNULL(e.bud_gl,0) bud_gl, ISNULL(e.pot_net_nal,0) pot_net_nal
	, ISNULL(frame.znesek_val,0) as znesek_val_frame, ISNULL(frame.koristeno_val,0) as koristeno_val_frame
	, ISNULL(frame.razlika_val,0) as razlika_val_frame
	, ISNULL(d.odr,0) + ISNULL(e.bud_gl,0) + ISNULL(e.pot_net_nal,0) + ISNULL(frame.razlika_val,0) as uk_izloz_OLD
	, ISNULL(d.odr,0) + ISNULL(d.bnd_neto,0) + ISNULL(e.bud_gl,0) + ISNULL(e.pot_net_nal,0) + ISNULL(frame.razlika_val,0) as uk_izloz
	, pbil.zaposleno, a.id_skis, sif_skis.opis as skis_opis, a.skrbnik_1, sk1.naz_kr_kup as sk1_naziv, a.skrbnik_2
	, sk2.naz_kr_kup as sk2_naziv, a.dat_vnosa, a.id, a.dat_poprave, popr.user_desc as popravil
	,  ISNULL(d.odr,0) + ISNULL(d.bnd_neto,0) + ISNULL(e.bud_gl,0) as RISK_EXPOSURE
	, crs.dat_eval as dat_crs,  crs.oall_ratin as crs
	, SUBSTRING(c.kateg4_opis,0,253) as kateg4_opis, SUBSTRING(kateg5_opis,0,253) as kateg5_opis, SUBSTRING(c.kateg6_opis,0,253) as kateg6_opis
	
From dbo.oc_customers a
Left Join dbo.oc_customers sk1 ON a.skrbnik_1 = sk1.id_kupca and a.id_oc_report = sk1.id_oc_report
Left Join dbo.oc_customers sk2 ON a.skrbnik_2 = sk2.id_kupca and a.id_oc_report = sk2.id_oc_report
Left Join dbo.users popr ON a.id = popr.username and a.id_oc_report = popr.id_oc_report
Left join 
	(Select a.id_oc_report, a.id_kupca, sum(dbo.gfn_xchange(@id_tec, a.net_nal, a.id_tec, @target_date, @id_oc_report)) as net_nal 
	From dbo.oc_contracts a
	Where a.status_akt = 'A' 
	AND a.nacin_leas NOT IN (SELECT nacin_leas FROM #exclude_lease_types)
	Group by a.id_oc_report, a.id_kupca) b on a.id_kupca=b.id_kupca and a.id_oc_report = b.id_oc_report
Left join 
	(Select pe.id_oc_report, pe.id_kupca, pe.dat_eval,pe.eval_model, isnull(y.value,'') as model_naziv, pe.tec_limite,pe.datum_bil,
		dbo.gfn_xchange(@id_tec, pe.limita, pe.tec_limite, @target_date, @id_oc_report) limita,
		pe.cust_ratin as rating1, pe.coll_ratin as rating2, pe.oall_ratin as uk_rating, 
		pe.asset_clas as kateg_b2, pe.kategorija1, gr.value as kateg1_opis, pe.DAT_NASL_VRED,
		pe.kategorija4, gr4.value as kateg4_opis,pe.kategorija5, gr5.value as kateg5_opis,pe.kategorija6, gr6.value as kateg6_opis
	From dbo.p_eval pe --NE DIRATI ZBOG KATEGORIJE1
	Inner join (select id_oc_report,id_kupca, max(dat_eval) dat_eval 
				From dbo.p_eval --NE DIRATI ZBOG KATEGORIJE1
				Where eval_type ='E' and id_oc_report = @id_oc_report group by id_oc_report,id_kupca) q	
					on pe.id_kupca=q.id_kupca and pe.dat_eval=q.dat_eval and pe.id_oc_report=q.id_oc_report
	Left join ( Select id_oc_report,id_register, id_key, value
				From dbo.general_register
				where id_oc_report=@id_oc_report and id_register='ev_model'
			  ) y on pe.id_oc_report=y.id_oc_report and pe.eval_model=y.id_key and id_register='ev_model'
	Left join dbo.general_register gr on pe.id_oc_report = gr.id_oc_report and pe.kategorija1 = gr.id_key and gr.id_register = 'P_EVAL_KATEG1'
	Left join dbo.general_register gr4 on pe.id_oc_report = gr4.id_oc_report and pe.kategorija4 = gr4.id_key and gr4.id_register = 'P_EVAL_KATEG4'
	Left join dbo.general_register gr5 on pe.id_oc_report = gr5.id_oc_report and pe.kategorija5 = gr5.id_key and gr5.id_register = 'P_EVAL_KATEG5'
	Left join dbo.general_register gr6 on pe.id_oc_report = gr6.id_oc_report and pe.kategorija6 = gr6.id_key and gr6.id_register = 'P_EVAL_KATEG6'
	Where pe.eval_type ='E'	AND pe.id_oc_report = @id_oc_report) c on a.id_kupca=c.id_kupca and a.id_oc_report=c.id_oc_report
Left join 
	(Select pog.id_oc_report, pog.id_kupca, SUM(ISNULL(pp.neto, 0)) as odr, SUM(ISNULL(pp.bnd_neto, 0)) as bnd_neto
	From dbo.oc_contracts pog 
	Left join (Select id_oc_report, id_cont
					 --Booked due
					, SUM(CASE WHEN evident='*' and ex_dni_zamude >= 0 THEN dbo.gfn_xchange(@id_tec,ex_saldo_dom, '000', @target_date, @id_oc_report) ELSE 0 END) neto
					 --Booked not due
					, SUM(CASE WHEN evident='*' and id_terj NOT IN ('21','23','00','20') and ex_dni_zamude < 0 THEN dbo.gfn_xchange(@id_tec,ex_saldo_dom, '000', @target_date, @id_oc_report) ELSE 0 END) bnd_neto
				From dbo.oc_claims
				Where id_oc_report = @id_oc_report
				Group by id_oc_report,id_cont) pp on pog.id_cont=pp.id_cont and pog.id_oc_report=pp.id_oc_report
	Where pog.id_oc_report = @id_oc_report
	AND pog.nacin_leas NOT IN (SELECT nacin_leas FROM #exclude_lease_types)
	Group by pog.id_oc_report,pog.id_kupca) d on a.id_kupca=d.id_kupca and a.id_oc_report=d.id_oc_report
Left join 
	(Select pog.id_oc_report, pog.id_kupca
		, SUM(CASE WHEN status_akt = 'A' THEN ISNULL(pp.neto ,0) ELSE 0 END + dbo.gfn_xchange(@id_tec, ex_g1_neto+ex_g1_robresti, id_tec, @target_date, @id_oc_report)) bud_gl
		, SUM(CASE WHEN status_akt ='D' THEN dbo.gfn_xchange(@id_tec, net_nal, id_tec, @target_date, @id_oc_report) ELSE 0 END) pot_net_nal
	From dbo.oc_contracts pog 
	Left join (Select id_oc_report,id_cont, sum(dbo.gfn_xchange(@id_tec, neto+robresti, id_tec, @target_date, @id_oc_report)) neto
				From dbo.oc_claims
				Where id_oc_report = @id_oc_report and (evident='' or (evident='*' and ex_dni_zamude<0)) 
					and id_terj in ('21','23','00','20')
				Group by id_oc_report, id_cont) pp on pog.id_cont = pp.id_cont and pog.id_oc_report = pp.id_oc_report
	Where pog.id_oc_report = @id_oc_report
	AND pog.nacin_leas NOT IN (SELECT nacin_leas FROM #exclude_lease_types)
	Group by pog.id_oc_report, pog.id_kupca) e on a.id_kupca=e.id_kupca and a.id_oc_report=e.id_oc_report
Left join p_bilanc pbil on a.id_kupca=pbil.id_kupca and c.datum_bil=pbil.datum_bil and a.id_oc_report=pbil.id_oc_report
Left join dbo.dejavnos dj on a.sif_dej = dj.sif_dej and a.id_oc_report = dj.id_oc_report
Left join (Select h.id_grupe, h.id_kupca
			From 
			(Select id_grupe, id_kupca
				From dbo.pov_part
				Where id_oc_report=@id_oc_report Group by id_grupe,id_kupca
				UNION ALL
				Select id_grupe, id_kupcab
				From dbo.pov_part
				Where id_oc_report=@id_oc_report Group by id_grupe,id_kupcab) h
			Where h.id_grupe is not null
			Group by id_grupe,id_kupca
		  ) pov on a.id_kupca = pov.id_kupca
Left join dbo.grupe_p gp on pov.id_grupe = gp.id_grupe and gp.id_oc_report=@id_oc_report
Left join dbo.oc_customers a1 on gp.id_kupca = a1.id_kupca and a1.id_oc_report= @id_oc_report
Left join (Select id_kupca, SUM(dbo.gfn_xchange(@id_tec,f.znesek_val, f.id_tec, @target_date,@id_oc_report)) as znesek_val,
				SUM(dbo.gfn_xchange(@id_tec,f.plac_val, f.id_tec, @target_date,@id_oc_report)) as koristeno_val,		   
				SUM(dbo.gfn_xchange(@id_tec,f.znesek_val - f.plac_val, f.id_tec, @target_date,@id_oc_report)) as razlika_val
			From dbo.oc_frames f		   
			Where f.id_oc_report = @id_oc_report and f.frame_type='REV'   
				   and 1 = case when @okvir_status=1 then case when f.status_akt = 'A' then 1 else 0 end else 1 end
			Group by id_kupca) frame on a.id_kupca = frame.id_kupca 
Left join dbo.sif_skis on a.id_skis = sif_skis.id_skis and a.id_oc_report = sif_skis.id_oc_report 
LEFT  JOIN (Select a.id_kupca, a.dat_eval, a.oall_ratin
	From dbo.p_eval a
	inner join (Select id_kupca, max(dat_eval) dat_eval
				From dbo.p_eval
				Where eval_type = 'C' AND id_oc_report = @id_oc_report
				Group by id_kupca) b on a.id_kupca = b.id_kupca and a.dat_eval = b.dat_eval
	where a.eval_type = 'C' AND id_oc_report = @id_oc_report
)crs on a.id_kupca = crs.id_kupca

Where a.id_kupca NOT IN ('XXXXXX','000000') AND a.id_oc_report = @id_oc_report
Order by 1

DROP TABLE #exclude_lease_types