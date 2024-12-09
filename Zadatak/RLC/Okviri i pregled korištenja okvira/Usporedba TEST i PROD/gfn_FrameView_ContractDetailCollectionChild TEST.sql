USE [NOVA_TEST]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_FrameView_ContractDetailCollectionChild]    Script Date: 8.4.2016. 12:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting data for report : Frame View - returns contracts for selected frame
--
-- History:
-- 20.05.2005 Vilko; created
-- 22.07.2005 Vilko; renamed function
-- 18.01.2006 Vilko; added field obligo
-- 06.02.2006 Vilko; added new parameter for username
-- 30.08.2006 Vilko; Maintenance ID 2253 - replaced P.* with fields from pogodba
-- 24.04.2009 Vilko; MID 20096 - fixed calculation of obligo - replaced P.dat_sklen with @par_trenutnidatum
-- 12.04.2010 Ziga; MID 24705 - added new frame type for Summit Ford with frame_type code = 'RFO'
-- 04.05.2010 Ziga; MID 25145 - repaired obligo for frame type REV and RFO for active contracts that do not exists in planp_ds (all claims are closed), obligo for such contracts is 0.
-- 19.05.2010 Ziga; MID 25373 - used parameter @par_trenutnidatum intead of getdate() according to compatibility problem with SQL Server 2000
-- 27.12.2011 Jasna; MID 30918 - added new frame type RNE for RL Srbija
-- 14.02.2012 Vilko; Bug ID 29073 - added field users_vnesel
-- 28.03.2012 Ziga; MID 34209 - modified calculation of obligo for frame type RFO - future interests tax is excluded
-- 30.05.2014 IgorS; Task ID 8109 - added function gfn_VrValToBrutoInternal for vr_bruto
-- 04.06.2014 IgorS & MatjažS; Task ID 8109 - added robresti for obligo calculation for frame type REV
------------------------------------------------------------------------------------------------------------
ALTER     FUNCTION [dbo].[gfn_FrameView_ContractDetailCollectionChild]  
(
    @par_frame_enabled int,
    @par_frame_number int, 
    @par_partner_enabled int,
    @par_partner_number varchar(6),
    @par_dat_odobritve_enabled int,
    @par_dat_odobritve_from datetime,
    @par_dat_odobritve_to datetime,
    @par_razlika bit,
    @par_username_enabled int,
    @par_username_value char(10),
    @par_trenutnidatum_enabled int,
    @par_trenutnidatum datetime
)  
RETURNS TABLE
AS  
RETURN(
	SELECT P1.akc_nal, P1.akont, P1.ali_pp, P1.ali_sdr, P1.aneks, P1.beg_end, P1.brez_davka_dom, P1.bruto, P1.cena_dkm,
	       P1.dakont, P1.dat_1op, P1.dat_2op, P1.dat_3op, P1.dat_aktiv, P1.dat_arhiv, P1.dat_kkf, P1.dat_od1, P1.dat_podpisa,
	       P1.dat_pol, P1.dat_predr, P1.dat_sklen, P1.dat_zakl, P1.datum_odob, P1.dav_osno, P1.dav_osno_dom, P1.ddv,
	       P1.ddv_dom, P1.ddv_id, P1.dej_obr, P1.disk_r, P1.diskont, P1.dni_financ, P1.dni_zap, P1.dobrocno, P1.dovol_km,
	       P1.dva_pp, P1.ef_obrm, P1.fix_del, P1.id, P1.id_cont, P1.id_dav_op, P1.id_dav_st, P1.id_dob, P1.id_kredpog,
	       P1.id_kupca, P1.id_kupca1, P1.id_obd, P1.id_obrs, P1.id_obrv, P1.id_odobrit, P1.id_pog, P1.id_pog_zav, P1.id_pon,
	       P1.id_posrednik, P1.id_prod, P1.id_ref, P1.id_rtip, P1.id_sklic, P1.id_strm, P1.id_svet, P1.id_tec, P1.id_tecvr,
	       P1.id_val, P1.id_vrste, P1.izv_kom, P1.izv_naj, P1.izvoz, P1.kasko, P1.kategorija, P1.kdo_odb, P1.kk_memo, P1.kon_naj,
	       P1.konsolid, P1.man_str, P1.marza_av, P1.marza_ob, P1.menic, P1.mpc, P1.nacin_leas, P1.nacin_ms, P1.naziv_tuje,
	       P1.neobdav_dom, P1.net_nal, P1.next_rpg_num, P1.njih_st, P1.obl_zt, P1.obr_financ, P1.obr_marz, P1.obr_mera, 
	       P1.obr_merak, P1.obr_vir, P1.obr_vir1, P1.obrok1, P1.om_varsc, P1.opc_datzad, P1.opc_imaobr, P1.opcija, P1.opis_pred,
	       P1.opombe, P1.ost_obr, P1.oststr, P1.plac_zac, P1.po_tecaju, P1.pred_ddv, P1.pred_naj, P1.predr_do, P1.prejme_do, 
	       P1.prenos, P1.prevzeta, P1.prv_obr, P1.prza_eom, P1.pszav, P1.pyr, P1.pz_let, P1.pz_zavar, P1.rabat, P1.rabat_nam, 
	       P1.rabat_njim, P1.ref1, P1.refinanc, P1.rind_datum, P1.rind_faktor, P1.rind_tdol, P1.rind_tgor, P1.rind_zadnji,
	       P1.rind_zahte, P1.se_varsc, P1.sklic, P1.spl_pog, P1.st_obrok, P1.st_predr, P1.status, P1.status_akt, P1.str_financ,
	       P1.stroski_pz, P1.stroski_x, P1.stroski_zt, P1.subleasing, P1.sys_ts, P1.traj_naj, P1.trojna_opc, P1.varscina,
	       P1.verified, P1.vnesel, P1.vr_prom, P1.vr_sit, P1.vr_val, P1.vr_val_zac, P1.vred_val, P1.za_odobrit, P1.zac_naj,
	       P1.zap_2ob, P1.zap_opc, P1.zapade_pz, P1.zapade_zf, P1.zapade_zt, P1.zav_fin, P1.ze_avansa, P1.ze_proviz, P1.zn_ref1,
	       P1.zn_refinan, P1.zt_zavar, U1.user_desc AS users_vnesel,
	       C1.naz_kr_kup,
	        obligo = case when FT1.sif_frame_type = 'RFO'
								then dbo.gfn_XChange(P1.id_tec, ISNULL(O1.obligo_rfo, case when P1.status_akt = 'Z' or (P1.status_akt = 'A' and datediff(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) then 0 else dbo.gfn_VrValToBrutoInternal(p1.vr_val, p1.robresti_val, ds1.davek, nl1.ima_robresti, nl1.dav_b, nl1.finbruto, nl1.dav_n) + P1.man_str + P1.stroski_x + P1.stroski_pz + P1.stroski_zt + P1.zav_fin + P1.str_financ end), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum)
							 when FT1.sif_frame_type = 'RNE'
								then (dbo.gfn_XChange(P1.id_tec, ISNULL(O1.obligo_rne, case when P1.status_akt = 'Z' or
								(P1.status_akt = 'A' and datediff(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) then 0 else P1.ddv end), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum)
								+ dbo.gfn_XChange(P1.id_tec, ISNULL(P1.net_nal_zac, 0), P1.id_tec, @par_trenutnidatum))
							else dbo.gfn_XChange(P1.id_tec, ISNULL(O1.obligo, case when P1.status_akt = 'Z' or (P1.status_akt = 'A' and datediff(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) then 0 else P1.vr_val - P1.varscina end), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum)
						end
						
	  FROM dbo.frame_list F
	  LEFT JOIN frame_list F1 ON F1.id_parent = F.id_parent
	  LEFT JOIN frame_pogodba FC1 ON	 F1.id_frame = FC1.id_frame
      LEFT JOIN dbo.pogodba P1 ON FC1.id_cont = P1.id_cont
	  INNER JOIN dbo.frame_type FT1 ON FT1.id_frame_type = F1.frame_type
	  LEFT JOIN dbo.partner C1 ON P1.id_kupca = C1.id_kupca
	  LEFT JOIN dbo.nacini_l NL1 ON NL1.nacin_leas = P1.nacin_leas
	  LEFT JOIN dbo.dav_stop DS1 ON DS1.id_dav_st = P1.id_dav_st
      LEFT JOIN (SELECT pp.id_cont, pp.id_kupca, pp.id_tec,
						SUM(pp.znp_saldo_brut_all + pp.bod_neto_lpod + pp.poknj_nezap_davek_LPOD + CASE WHEN nl.ima_robresti = 1 THEN pp.bod_robresti_lpod ELSE 0 END) AS obligo,
						SUM(pp.znp_saldo_brut_all + pp.bod_debit_brut_ALL - pp.bod_obresti_LPOD - case when nl.dav_o = 'D' then pp.bod_obresti_LPOD * (ds.davek / 100) else 0 end) AS obligo_rfo,
						SUM(pp.znp_saldo_ddv + pp.bod_davek_lpod) AS obligo_rne
                     FROM dbo.planp_ds pp
					 INNER JOIN dbo.pogodba po ON po.id_cont = pp.id_cont
					 INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = po.nacin_leas
					 INNER JOIN dbo.dav_stop ds ON ds.id_dav_st = po.id_dav_st
                     GROUP BY pp.id_cont, pp.id_kupca, pp.id_tec) O1 ON P1.id_cont = O1.id_cont AND P1.id_kupca = O1.id_kupca
	LEFT JOIN dbo.users U1 ON P1.vnesel = U1.username
	 WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
	   AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
	   AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)

)
