USE [NOVA_TEST]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_FrameView_ContractDetailsNotCollection]    Script Date: 8.4.2016. 12:19:03 ******/
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
-- 27.01.2016 Jelena; MID 53439 - gfn_FrameView_ContractDetailsNotCollectio is the same as old gfn_FrameView_ContractDetails; is calling from gfn_FrameView_ContractDetails; for ordinary frames
-- 17.02.2016 Ziga; MID 55440 - added custom settings 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc' for REV frames
-- 04.04.2016 Ziga; MID 55440 - modification for custom settings 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc'
------------------------------------------------------------------------------------------------------------
ALTER    FUNCTION [dbo].[gfn_FrameView_ContractDetailsNotCollection]
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
	SELECT P.akc_nal, P.akont, P.ali_pp, P.ali_sdr, P.aneks, P.beg_end, P.brez_davka_dom, P.bruto, P.cena_dkm,
	       P.dakont, P.dat_1op, P.dat_2op, P.dat_3op, P.dat_aktiv, P.dat_arhiv, P.dat_kkf, P.dat_od1, P.dat_podpisa,
	       P.dat_pol, P.dat_predr, P.dat_sklen, P.dat_zakl, P.datum_odob, P.dav_osno, P.dav_osno_dom, P.ddv,
	       P.ddv_dom, P.ddv_id, P.dej_obr, P.disk_r, P.diskont, P.dni_financ, P.dni_zap, P.dobrocno, P.dovol_km,
	       P.dva_pp, P.ef_obrm, P.fix_del, P.id, P.id_cont, P.id_dav_op, P.id_dav_st, P.id_dob, P.id_kredpog,
	       P.id_kupca, P.id_kupca1, P.id_obd, P.id_obrs, P.id_obrv, P.id_odobrit, P.id_pog, P.id_pog_zav, P.id_pon,
	       P.id_posrednik, P.id_prod, P.id_ref, P.id_rtip, P.id_sklic, P.id_strm, P.id_svet, P.id_tec, P.id_tecvr,
	       P.id_val, P.id_vrste, P.izv_kom, P.izv_naj, P.izvoz, P.kasko, P.kategorija, P.kdo_odb, P.kk_memo, P.kon_naj,
	       P.konsolid, P.man_str, P.marza_av, P.marza_ob, P.menic, P.mpc, P.nacin_leas, P.nacin_ms, P.naziv_tuje,
	       P.neobdav_dom, P.net_nal, P.next_rpg_num, P.njih_st, P.obl_zt, P.obr_financ, P.obr_marz, P.obr_mera, 
	       P.obr_merak, P.obr_vir, P.obr_vir1, P.obrok1, P.om_varsc, P.opc_datzad, P.opc_imaobr, P.opcija, P.opis_pred,
	       P.opombe, P.ost_obr, P.oststr, P.plac_zac, P.po_tecaju, P.pred_ddv, P.pred_naj, P.predr_do, P.prejme_do, 
	       P.prenos, P.prevzeta, P.prv_obr, P.prza_eom, P.pszav, P.pyr, P.pz_let, P.pz_zavar, P.rabat, P.rabat_nam, 
	       P.rabat_njim, P.ref1, P.refinanc, P.rind_datum, P.rind_faktor, P.rind_tdol, P.rind_tgor, P.rind_zadnji,
	       P.rind_zahte, P.se_varsc, P.sklic, P.spl_pog, P.st_obrok, P.st_predr, P.status, P.status_akt, P.str_financ,
	       P.stroski_pz, P.stroski_x, P.stroski_zt, P.subleasing, P.sys_ts, P.traj_naj, P.trojna_opc, P.varscina,
	       P.verified, P.vnesel, P.vr_prom, P.vr_sit, P.vr_val, P.vr_val_zac, P.vred_val, P.za_odobrit, P.zac_naj,
	       P.zap_2ob, P.zap_opc, P.zapade_pz, P.zapade_zf, P.zapade_zt, P.zav_fin, P.ze_avansa, P.ze_proviz, P.zn_ref1,
	       P.zn_refinan, P.zt_zavar, U.user_desc AS users_vnesel,
	       C.naz_kr_kup,
	       obligo = (case when FT.sif_frame_type = 'RFO'
							then dbo.gfn_XChange(P.id_tec, ISNULL(O.obligo_rfo, case when P.status_akt = 'Z' or (P.status_akt = 'A' and datediff(dd, P.dat_aktiv, @par_trenutnidatum) > 5) then 0 else dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P.man_str + P.stroski_x + P.stroski_pz + P.stroski_zt + P.zav_fin + P.str_financ end), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum)
						  when FT.sif_frame_type = 'RNE'
							then (dbo.gfn_XChange(P.id_tec, ISNULL(O.obligo_rne, case when P.status_akt = 'Z' or
								(P.status_akt = 'A' and datediff(dd, P.dat_aktiv, @par_trenutnidatum) > 5) then 0 else P.ddv end), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum)
								+ dbo.gfn_XChange(P.id_tec, ISNULL(P.net_nal_zac, 0), P.id_tec, @par_trenutnidatum))
						else dbo.gfn_XChange(P.id_tec, ISNULL(O.obligo, case when P.status_akt = 'Z' or (P.status_akt = 'A' and datediff(dd, P.dat_aktiv, @par_trenutnidatum) > 5) then 0 else P.vr_val - P.varscina end), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum)
					end)
	  FROM dbo.frame_list F
	 INNER JOIN dbo.frame_pogodba FP ON F.id_frame = FP.id_frame
	 INNER JOIN dbo.pogodba P ON FP.id_cont = P.id_cont
	 INNER JOIN dbo.frame_type FT ON FT.id_frame_type = F.frame_type
	  LEFT JOIN dbo.partner C ON P.id_kupca = C.id_kupca
	  LEFT JOIN dbo.nacini_l NL ON NL.nacin_leas = P.nacin_leas
	  LEFT JOIN dbo.dav_stop DS ON DS.id_dav_st = P.id_dav_st
	  LEFT JOIN (SELECT pp.id_cont, pp.id_kupca, pp.id_tec,
					    SUM(case when upper(IsNull(cs.val, '')) = 'TRUE'
									then
										case when po.status_akt in ('N','D') and od.id_odobrit_tip in (12, 13) and ln.entity_name = 'RLHR'
												then dbo.gfn_Xchange(dbo.gfn_GetNewTec(pp.id_tec), po.vr_val_zac, po.id_tec, po.dat_sklen)
	 										 when po.status_akt in ('N','D')
												then dbo.gfn_Xchange(dbo.gfn_GetNewTec(pp.id_tec), po.net_nal_zac, po.id_tec, po.dat_sklen)
											 else
												pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end
										end
									else pp.znp_saldo_brut_all + pp.bod_neto_lpod 
										+ CASE WHEN nl.leas_kred = 'L' AND nl.tip_knjizenja = '2' AND nl.finbruto = 0 AND nl.ol_na_nacin_fl = 0 THEN pp.poknj_nezap_davek_LPOD ELSE 0 END 
										+ CASE WHEN nl.ima_robresti = 1 THEN pp.bod_robresti_lpod ELSE 0 END
							end) AS obligo,
					    SUM(pp.znp_saldo_brut_all + pp.bod_debit_brut_ALL - pp.bod_obresti_LPOD - case when nl.dav_o = 'D' then pp.bod_obresti_LPOD * (ds.davek / 100) else 0 end) AS obligo_rfo,
					    SUM(pp.znp_saldo_ddv + pp.bod_davek_lpod) AS obligo_rne
	               FROM dbo.planp_ds pp
				   INNER JOIN dbo.pogodba po ON po.id_cont = pp.id_cont
				   LEFT JOIN dbo.odobrit od on od.id_odobrit = po.id_odobrit
				   INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = po.nacin_leas
				   INNER JOIN dbo.dav_stop ds ON ds.id_dav_st = po.id_dav_st
				   LEFT JOIN (select val from dbo.custom_settings where code = 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc') cs on 1 = 1
				   LEFT JOIN (select entity_name from dbo.loc_nast) ln on 1 = 1
	              GROUP BY pp.id_cont, pp.id_kupca, pp.id_tec) O ON P.id_cont = O.id_cont AND P.id_kupca = O.id_kupca
	  LEFT JOIN dbo.users U ON P.vnesel = U.username
	 WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
	   AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
	   AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
)


