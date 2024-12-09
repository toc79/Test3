--USE [Mary]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_FrameView]    Script Date: 8.4.2016. 9:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting data for report : Frame View
--
-- History:
-- 20.05.2005 Vilko; created
-- 21.07.2005 Vilko; added frame availability for payments
-- 02.08.2005 vilko; fixed condition in having clause
-- 05.08.2005 Vilko; fixed condition - for contract frame availability should be selected only unclosed contracts
-- 12.08.2005 Vilko; added new fields status_akt and dat_zak
-- 19.08.2005 Vilko; fixed calculation of frame availability for payments
-- 13.10.2005 Vilko; currency value - odbitni_ddv and znesek_pl is recalculated in frame currency
-- 18.01.2006 Vilko; added frame availability for residual frames 
-- 30.01.2006 Vilko; added new field user_desc
-- 06.02.2006 Vilko; added new parameter for username
-- 30.06.2006 Vilko; added new fields opombe and velja_do
-- 11.12.2006 Vilko; Maintenance ID 3722 - added frame availability for frame type = 'NET'
-- 11.12.2006 Vik; code formatting
-- 12.12.2006 Vilko; Maintenance ID 3722 - added frame availability for frame type = 'DOB'
-- 21.05.2007 Vilko; Maintenance ID 8952 - MODIFIED ON SITE - fixed calculating all values
-- 07.11.2007 Matjaz; Maintenance ID 11588 - added all the missing fields from table frame_list
-- 06.02.2008 Ziga; Maintenance ID 13138 - changed date of exchange rate from P.dat_sklen to today and substract varscina from vr_val for REV frames
-- 22.10.2008 Matjaz; TASK ID 5282 - added support for frames of type 'ZAL'
-- 02.12.2008 Ziga; Maintenance ID 18088 - added new fields skrbnik_1, skrbnik_2, naz_kr_kup_skrbnik_1, naz_kr_kup_skrbnik_2
-- 20.03.2009 Vilko; MID 20096 - fixed calculating frame availability for frame_type = 'DOB' - calculation was not made in frame currency
-- 24.04.2009 Vilko; MID 20096 - fixed calculating frame availability for frame type = 'REV' - in obligo are now inlcuded ALL dued not paid claims - before only LOBR
-- 26.05.2009 Vilko; MID 20449 - fixed calculating frame availability for frame type = 'DOB' - now are also included partialy activated contracts
-- 16.02.2010 Ziga; MID 23659 - modified fields vr_val, razlika_val, vr_dom, razlika_dom for frame types 'NET' and 'POG' - net_nal_zac and vr_val_zac is used instead of net_nal and vr_val
-- 12.04.2010 Ziga; MID 24705 - added new frame type for Summit Ford with frame_type code = 'RFO'
-- 04.05.2010 Ziga; MID 25145 - repaired obligo for frame type REV and RFO for active contracts that do not exists in planp_ds (all claims are closed), obligo for such contracts is 0.
-- 07.05.2010 Vilko; MID 23928 - fixed calculating frame availability for frame_type = 'DOB' - payments does not affect on frame availability if frame is closed or are based on input invoice
-- 19.05.2010 Ziga; MID 25373 - used parameter @par_trenutnidatum intead of getdate() according to compatibility problem with SQL Server 2000
-- 08.07.2010 Natasa; MID 25371 - added field and criteria b2 eligible and status akt 
-- 09.06.2011 Jasna; MID 30113 - added new frame type called RRE (Retail Risk Exposure)
-- 19.10.2011 Jasna; BUG ID 29064 - change select (V) for RRE frame type
-- 02.11.2011 Vilko; Bug ID 29057 - fixed frame availability for frame types 'NET' and 'POG' - also closed contracts should reduce frame availability 
-- 23.11.2011 Jasna; MID 30918 - added new frame type mix of REV for DDV and NET for other claims (RNE)
-- 26.11.2011 Jasna; BUG 29227 - added a.id_vrste = 1 in (V) and fix status_placila
-- 28.03.2012 Ziga; MID 34209 - modified calculation of obligo for frame type RFO - future interests tax is excluded 
-- 19.12.2012 Ales; MID 36551 - added left join on subquery ST_POG, added ST_POG.st_pogodb in select and group by 
-- 24.05.2013 Jelena; MID 40473 - for frame_type = 'DOB', type of payments processed (P - procesirano) is now considered into using of frame
-- 10.03.2014 Jelena; MID 43659 - supported new frame_type DBA
-- 13.04.2014 Jelena; MID 43659 -  modified code for frame type DOB and DBA
-- 30.05.2014 IgorS; Task ID 8109 - added function gfn_VrValToBrutoInternal
-- 04.06.2014 IgorS & MatjažS; Task ID 8109 - added robresti for obligo calculation for frame type REV
-- 06.08.2014 Jelena; Bug ID 31011 -  for frame type 'DBA' added relation through id_frame and remove condition for frame activity status
-- 06.01.2014 Ales; MID 48847 - changed id_plac_izh_tip condition
-- 14.04.2015 Andrej; Bug 31630 - modified calculation of 'vr_val' for frame type 'NET'. Calculation was using 'net_nal_zac', now is using 'net_nal'.
-- 20.05.2015 Andrej; Bug 31702 - modified columns datatype for tables @result and @frame_candidates. Columns: opis, kraj, opombe, tecaj, obr_mera, int_obr_mera, konto, pkonto, pkonto_davek, int_opis_fak, limproc_pol, limobr_mera, limtraj_naj, opis_zav, limproc_varsc, limproc_opcija
-- 18.06.2015 Jure; BUG 31753 - Added call of function gfn_SummitPlacIzhData
-- 13.07.2015 Andrej; MID 50974 - added pp.poknj_nezap_davek_LPOD in SUM for 'obligo_rev'
-- 11.09.2015 Jure & Nataša ; BUG 31845 - Correction off RRE frame calculation
-- 10.02.2016 Jelena; MID 53439 - added union for collection
-- 17.02.2016 Ziga; MID 55440 - added custom settings 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc' for REV frames
-- 08.04.2016 Josip; Modify on site - vrijedi samo za FF tip leasinga (popraviti comment) u GMI (vezano na 50974 - added pp.poknj_nezap_davek_LPOD)
------------------------------------------------------------------------------------------------------------
ALTER               FUNCTION [dbo].[gfn_FrameView](
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
    @par_trenutnidatum datetime,
	@par_b2eligible_enabled int,
    @par_b2eligible_value int,
	@par_akt_enabled int,
    @par_akt_value int
)  
RETURNS TABLE AS
RETURN(
	-- navadni okviri in childi od krovnih okvirjev
  SELECT F.id_parent, F.je_krovni_okvir, 
        F.id_frame, F.id_kupca, F.opis, F.id_tec, F.kraj, F.dat_odobritve, F.znesek_val, F.znesek_dom, 
        F.status_akt, F.dat_zak, F.velja_do, F.opombe,
        FT.sif_frame_type,
        C.naz_kr_kup,
        T.id_val,
        U.user_desc,
        vr_val = ISNULL(CASE FT.sif_frame_type
             WHEN 'POG' THEN SUM(dbo.gfn_XChange(F.id_tec, P.vr_val_zac, P.id_tec, P.dat_sklen))
             WHEN 'PLA' THEN SUM(dbo.gfn_XChange(F.id_tec, FP.znesek_pl, '000', FP.datum_pl) - dbo.gfn_XChange(F.id_tec, FP.odbitni_ddv, '000', FP.datum_pl))
             WHEN 'REV' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O.obligo_rev, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.vr_val - P.varscina END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
             WHEN 'NET' THEN SUM(dbo.gfn_XChange(F.id_tec, P.net_nal, P.id_tec, P.dat_sklen))
             WHEN 'DOB' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END, '000', @par_trenutnidatum))
             WHEN 'ZAL' THEN SUM(dbo.gfn_XChange(F.id_tec, STK.kredit - STK.debit, '000', @par_trenutnidatum))
			 WHEN 'RFO' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O.obligo_rfo, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P.man_str + P.stroski_x + P.stroski_pz + P.stroski_zt + P.zav_fin + P.str_financ END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
			 WHEN 'RRE' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END, '000', @par_trenutnidatum))
			 WHEN 'RNE' THEN SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN P.net_nal_zac ELSE 0 END,P.id_tec, P.dat_sklen)) + SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O.obligo_rne, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.DDV END)) ELSE 0 END, ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
			 WHEN 'DBA' THEN SUM(dbo.gfn_XChange(F.id_tec, S.znesek_dom, '000', @par_trenutnidatum))
           END, 0),
        razlika_val = F.znesek_val - ISNULL(CASE FT.sif_frame_type
             WHEN 'POG' THEN SUM(dbo.gfn_XChange(F.id_tec, P.vr_val_zac, P.id_tec, P.dat_sklen))
             WHEN 'PLA' THEN SUM(dbo.gfn_XChange(F.id_tec, FP.znesek_pl, '000', FP.datum_pl) - dbo.gfn_XChange(F.id_tec, FP.odbitni_ddv, '000', FP.datum_pl))
             WHEN 'REV' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O.obligo_rev, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.vr_val - P.varscina END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
             WHEN 'NET' THEN SUM(dbo.gfn_XChange(F.id_tec, P.net_nal, P.id_tec, P.dat_sklen))
             WHEN 'DOB' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END, '000', @par_trenutnidatum))
             WHEN 'ZAL' THEN SUM(dbo.gfn_XChange(F.id_tec, STK.kredit - STK.debit, '000', @par_trenutnidatum))
			 WHEN 'RFO' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O.obligo_rfo, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P.man_str + P.stroski_x + P.stroski_pz + P.stroski_zt + P.zav_fin + P.str_financ END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
			 WHEN 'RRE' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END, '000', @par_trenutnidatum))
			 WHEN 'RNE' THEN SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN P.net_nal_zac ELSE 0 END,P.id_tec, P.dat_sklen)) + SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O.obligo_rne, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.DDV END)) ELSE 0 END, ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
			 WHEN 'DBA' THEN SUM(dbo.gfn_XChange(F.id_tec, S.znesek_dom, '000', @par_trenutnidatum))
           END, 0),
        vr_dom = ISNULL(CASE FT.sif_frame_type 
             WHEN 'POG' THEN SUM(dbo.gfn_XChange('000', P.vr_val_zac, P.id_tec, P.dat_sklen))
             WHEN 'PLA' THEN SUM(FP.znesek_pl - FP.odbitni_ddv)
             WHEN 'REV' THEN SUM(dbo.gfn_XChange('000', ISNULL(O.obligo_rev, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.vr_val - P.varscina END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
             WHEN 'NET' THEN SUM(dbo.gfn_XChange('000', P.net_nal, P.id_tec, P.dat_sklen))
             WHEN 'DOB' THEN SUM(CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END)
             WHEN 'ZAL' THEN SUM(STK.kredit - STK.debit)
			 WHEN 'RFO' THEN SUM(dbo.gfn_XChange('000', ISNULL(O.obligo_rfo, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P.man_str + P.stroski_x + P.stroski_pz + P.stroski_zt + P.zav_fin + P.str_financ END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
			 WHEN 'RRE' THEN SUM(CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END)
			 WHEN 'RNE' THEN SUM(dbo.gfn_XChange('000',  CASE WHEN nl.ddv_takoj = 1 THEN P.net_nal_zac ELSE 0 END,P.id_tec, P.dat_sklen)) + SUM(dbo.gfn_XChange('000',  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O.obligo_rne, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.DDV END)) ELSE 0 END, ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
			 WHEN 'DBA' THEN SUM(S.znesek_dom)
           END, 0),
        razlika_dom = F.znesek_dom - ISNULL(CASE FT.sif_frame_type 
             WHEN 'POG' THEN SUM(dbo.gfn_XChange('000', P.vr_val_zac, P.id_tec, P.dat_sklen))
             WHEN 'PLA' THEN SUM(FP.znesek_pl - FP.odbitni_ddv)
             WHEN 'REV' THEN SUM(dbo.gfn_XChange('000', ISNULL(O.obligo_rev, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.vr_val - P.varscina END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
             WHEN 'NET' THEN SUM(dbo.gfn_XChange('000', P.net_nal, P.id_tec, P.dat_sklen))
             WHEN 'DOB' THEN SUM(CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END)
             WHEN 'ZAL' THEN SUM(STK.kredit - STK.debit)
			 WHEN 'RFO' THEN SUM(dbo.gfn_XChange('000', ISNULL(O.obligo_rfo, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P.man_str + P.stroski_x + P.stroski_pz + P.stroski_zt + P.zav_fin + P.str_financ END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
			 WHEN 'RRE' THEN SUM(CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END)
			 WHEN 'RNE' THEN SUM(dbo.gfn_XChange('000',  CASE WHEN nl.ddv_takoj = 1 THEN P.net_nal_zac ELSE 0 END,P.id_tec, P.dat_sklen)) + SUM(dbo.gfn_XChange('000',  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O.obligo_rne, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.DDV END)) ELSE 0 END, ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
			 WHEN 'DBA' THEN SUM(S.znesek_dom)
           END, 0),
		f.tecaj, f.obr_mera, f.int_obr_mera, f.id_strm, f.id_dav_st, f.konto, 
		f.pkonto, f.pkonto_davek, f.id_rtip, f.int_id_rtip, f.int_id_obd, 
		f.int_max_dat, f.int_opis_fak, f.limvr_val, f.limproc_pol, f.limprv_obr, 
		f.limvarscina, f.limnacin_leas, f.limobr_mera, f.limid_rtip, f.limopcija, 
		f.limproc_ms, f.limman_str, f.limtraj_naj, f.opis_zav, f.limproc_varsc, 
		f.limproc_opcija, f.ali_pov_part, f.sif_odobrit, f.dat_izteka,
        C.skrbnik_1, S1.naz_kr_kup as naz_kr_kup_skrbnik_1,
        C.skrbnik_2, S2.naz_kr_kup as naz_kr_kup_skrbnik_2,
		ft.b2_eligible, ST_POG.st_pogodb as st_pogodb
    FROM 
        dbo.frame_list F
        LEFT JOIN dbo.frame_pogodba FC ON F.id_frame = FC.id_frame
        LEFT JOIN dbo.pogodba P ON FC.id_cont = P.id_cont
        LEFT JOIN (SELECT pp.id_cont, pp.id_kupca, pp.id_tec,
							SUM(case when upper(IsNull(cs.val, '')) = 'TRUE'
										then pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end
										else pp.znp_saldo_brut_all + pp.bod_neto_lpod 
											+ CASE WHEN nl.leas_kred = 'L' AND nl.tip_knjizenja = '2' AND nl.finbruto = 0 AND nl.ol_na_nacin_fl = 0 THEN pp.poknj_nezap_davek_LPOD ELSE 0 END
											+ CASE WHEN nl.ima_robresti = 1 THEN pp.bod_robresti_lpod ELSE 0 END
								end) AS obligo_rev,
							SUM(pp.znp_saldo_brut_all + pp.bod_debit_brut_ALL - pp.bod_obresti_LPOD - case when nl.dav_o = 'D' then pp.bod_obresti_LPOD * (ds.davek / 100) else 0 end) AS obligo_rfo,
							SUM(pp.znp_saldo_ddv + pp.bod_davek_lpod) AS obligo_rne
                     FROM dbo.planp_ds pp
					 INNER JOIN dbo.pogodba po ON po.id_cont = pp.id_cont
					 INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = po.nacin_leas
					 INNER JOIN dbo.dav_stop ds ON ds.id_dav_st = po.id_dav_st
					 LEFT JOIN (select val from dbo.custom_settings where code = 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc') cs on 1 = 1
                     GROUP BY pp.id_cont, pp.id_kupca, pp.id_tec) O ON P.id_cont = O.id_cont AND P.id_kupca = O.id_kupca
        LEFT JOIN dbo.partner C ON F.id_kupca = C.id_kupca
        LEFT JOIN dbo.partner S1 ON S1.id_kupca = C.skrbnik_1
        LEFT JOIN dbo.partner S2 ON S2.id_kupca = C.skrbnik_2
        LEFT JOIN dbo.tecajnic T ON F.id_tec = T.id_tec
        LEFT JOIN dbo.frame_plac FP ON F.id_frame = FP.id_frame
        LEFT JOIN dbo.users U ON F.username = U.username 
		LEFT JOIN dbo.gfn_stk_get_frame_consument() as STK ON F.id_frame = STK.id_frame
        LEFT JOIN (SELECT SUM(dbo.gfn_XChange('000', R.znesek_dom, R.id_tec, R.datum)) AS znesek_dom, R.id_dob
                     FROM dbo.plac_izh R
                    INNER JOIN dbo.plac_izh_tip T ON R.id_plac_izh_tip = T.id_plac_izh_tip
                    INNER JOIN dbo.pogodba PR ON R.id_cont = PR.id_cont
					LEFT OUTER JOIN dbo.frame_list f ON f.id_frame = R.id_frame
					LEFT OUTER JOIN frame_type ft ON ft.id_frame_type = f.frame_type
                    WHERE R.id_vrste = 1 
                      AND R.status_placila IN ('V', 'E', 'A', 'S', 'P')
                      AND PR.status_akt IN ('N', 'D')
                      AND T.p1_je_racun = 0
					  AND  ft.sif_frame_type is NULL
                    GROUP BY R.id_dob) R ON F.id_kupca = R.id_dob
         LEFT JOIN (SELECT SUM(dbo.gfn_XChange('000', S.znesek_dom, S.id_tec, S.datum)) AS znesek_dom, S.id_dob, S.id_frame 
                     FROM dbo.plac_izh S
                    INNER JOIN dbo.plac_izh_tip T ON S.id_plac_izh_tip = T.id_plac_izh_tip
                    INNER JOIN dbo.pogodba PR ON S.id_cont = PR.id_cont
					INNER JOIN dbo.frame_list f ON f.id_frame = s.id_frame
					INNER JOIN dbo.frame_type ft ON ft.id_frame_type = f.frame_type
                    WHERE S.id_vrste = 1 
                      AND S.status_placila IN ('V', 'E', 'A', 'S', 'P')
                      AND T.p1_je_racun = 0
					  AND  ft.sif_frame_type = 'DBA' 
                    GROUP BY S.id_dob, S.id_frame) S ON F.id_kupca = S.id_dob and F.id_frame = S.id_frame 
        INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type
		LEFT JOIN dbo.nacini_l nl on nl.nacin_leas = P.nacin_leas
		LEFT JOIN dbo.dav_stop ds on ds.id_dav_st = P.id_dav_st
		LEFT JOIN (SELECT 
						sum(a.znesek_dom) as znesek_dom,
						a.id_dob
					FROM 
						dbo.gfn_SummitPlacIzhData(0) as a 
					GROUP BY 
						a.id_dob) V on F.id_kupca = V.id_dob
		LEFT JOIN (SELECT id_frame, COUNT(status_akt) AS st_pogodb
				   FROM dbo.frame_pogodba fp
				   INNER JOIN dbo.pogodba p ON fp.id_cont = p.id_cont
				   WHERE p.status_akt != 'Z' 
				   GROUP BY id_frame) ST_POG ON ST_POG.id_frame = F.id_frame
    WHERE F.je_krovni_okvir = 0 
        AND (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
        AND (@par_partner_enabled = 0 OR F.id_kupca = @par_partner_number)
        AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
        AND (@par_username_enabled = 0 OR F.username = @par_username_value)
		AND (@par_b2eligible_enabled = 0 OR FT.B2_eligible = CONVERT(char(1), @par_b2eligible_value))
		AND (@par_akt_enabled = 0 OR F.status_akt = CASE WHEN @par_akt_value = 1 THEN 'A' ELSE 'Z' END)
    GROUP BY 
        F.id_frame, F.id_kupca, F.opis, F.id_tec, F.kraj, F.dat_odobritve, 
        F.znesek_val, F.znesek_dom, C.naz_kr_kup, T.id_val,
        FT.sif_frame_type, F.status_akt, F.dat_zak, F.velja_do, U.user_desc, F.opombe,
		f.tecaj, f.obr_mera, f.int_obr_mera, f.id_strm, f.id_dav_st, f.konto, 
		f.pkonto, f.pkonto_davek, f.id_rtip, f.int_id_rtip, f.int_id_obd, 
		f.int_max_dat, f.int_opis_fak, f.limvr_val, f.limproc_pol, f.limprv_obr, 
		f.limvarscina, f.limnacin_leas, f.limobr_mera, f.limid_rtip, f.limopcija, 
		f.limproc_ms, f.limman_str, f.limtraj_naj, f.opis_zav, f.limproc_varsc, 
		f.limproc_opcija, f.ali_pov_part, f.sif_odobrit, f.dat_izteka,
        C.skrbnik_1, S1.naz_kr_kup,
        C.skrbnik_2, S2.naz_kr_kup,
		ft.b2_eligible, ST_POG.st_pogodb,F.id_parent, F.je_krovni_okvir
    HAVING (@par_razlika = 0 OR (F.znesek_val - ISNULL(CASE FT.sif_frame_type
                                                         WHEN 'POG' THEN SUM(dbo.gfn_XChange(F.id_tec, P.vr_val_zac, P.id_tec, P.dat_sklen))
                                                         WHEN 'PLA' THEN SUM(dbo.gfn_XChange(F.id_tec, FP.znesek_pl, '000', FP.datum_pl) - dbo.gfn_XChange(F.id_tec, FP.odbitni_ddv, '000', FP.datum_pl))
                                                         WHEN 'REV' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O.obligo_rev, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.vr_val - P.varscina END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
                                                         WHEN 'NET' THEN SUM(dbo.gfn_XChange(F.id_tec, P.net_nal, P.id_tec, P.dat_sklen))
                                                         WHEN 'DOB' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END, '000', @par_trenutnidatum))
														 WHEN 'ZAL' THEN SUM(STK.kredit - STK.debit)
														 WHEN 'RFO' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O.obligo_rfo, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P.man_str + P.stroski_x + P.stroski_pz + P.stroski_zt + P.zav_fin + P.str_financ END), ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
														 WHEN 'RRE' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END, '000', @par_trenutnidatum))
														 WHEN 'RNE' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN nl.ddv_takoj = 1 THEN P.net_nal_zac ELSE 0 END,P.id_tec, P.dat_sklen)) + SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O.obligo_rne, CASE WHEN P.status_akt = 'Z' OR (P.status_akt = 'A' AND DATEDIFF(dd, P.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P.DDV END)) ELSE 0 END, ISNULL(O.id_tec, P.id_tec), @par_trenutnidatum))
														 WHEN 'DBA' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END, '000', @par_trenutnidatum))
                                                       END, 0)) < 0)
	UNION
	-- krovni okviri
    SELECT
        F.id_parent, F.je_krovni_okvir, 
		F.id_frame, F.id_kupca, F.opis, F.id_tec, F.kraj, F.dat_odobritve, F.znesek_val, F.znesek_dom, 
        F.status_akt, F.dat_zak, F.velja_do, F.opombe,
        FT.sif_frame_type,
        C.naz_kr_kup,
        T.id_val,
        U.user_desc,
        vr_val = ISNULL(CASE FT.sif_frame_type
             WHEN 'POG' THEN SUM(dbo.gfn_XChange(F.id_tec, P1.vr_val_zac, P1.id_tec, P1.dat_sklen))
             WHEN 'PLA' THEN SUM(dbo.gfn_XChange(F.id_tec, FP.znesek_pl, '000', FP.datum_pl) - dbo.gfn_XChange(F.id_tec, FP.odbitni_ddv, '000', FP.datum_pl))
             WHEN 'REV' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O1.obligo_rev, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.vr_val - P1.varscina END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
             WHEN 'NET' THEN SUM(dbo.gfn_XChange(F.id_tec, P1.net_nal, P1.id_tec, P1.dat_sklen))
             WHEN 'DOB' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END, '000', @par_trenutnidatum))
             WHEN 'ZAL' THEN SUM(dbo.gfn_XChange(F.id_tec, STK.kredit - STK.debit, '000', @par_trenutnidatum))
			 WHEN 'RFO' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O1.obligo_rfo, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p1.vr_val, p1.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P1.man_str + P1.stroski_x + P1.stroski_pz + P1.stroski_zt + P1.zav_fin + P1.str_financ END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
			 WHEN 'RRE' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END, '000', @par_trenutnidatum))
			 WHEN 'RNE' THEN SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN P1.net_nal_zac ELSE 0 END,P1.id_tec, P1.dat_sklen)) + SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O1.obligo_rne, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.DDV END)) ELSE 0 END, ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
			 WHEN 'DBA' THEN SUM(dbo.gfn_XChange(F.id_tec, S.znesek_dom, '000', @par_trenutnidatum))
           END, 0),
        razlika_val = F.znesek_val - ISNULL(CASE FT.sif_frame_type
             WHEN 'POG' THEN SUM(dbo.gfn_XChange(F.id_tec, P1.vr_val_zac, P1.id_tec, P1.dat_sklen))
             WHEN 'PLA' THEN SUM(dbo.gfn_XChange(F.id_tec, FP.znesek_pl, '000', FP.datum_pl) - dbo.gfn_XChange(F.id_tec, FP.odbitni_ddv, '000', FP.datum_pl))
             WHEN 'REV' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O1.obligo_rev, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.vr_val - P1.varscina END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
             WHEN 'NET' THEN SUM(dbo.gfn_XChange(F.id_tec, P1.net_nal, P1.id_tec, P1.dat_sklen))
             WHEN 'DOB' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END, '000', @par_trenutnidatum))
             WHEN 'ZAL' THEN SUM(dbo.gfn_XChange(F.id_tec, STK.kredit - STK.debit, '000', @par_trenutnidatum))
			 WHEN 'RFO' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O1.obligo_rfo, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p1.vr_val, p1.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P1.man_str + P1.stroski_x + P1.stroski_pz + P1.stroski_zt + P1.zav_fin + P1.str_financ END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
			 WHEN 'RRE' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END, '000', @par_trenutnidatum))
			 WHEN 'RNE' THEN SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN P1.net_nal_zac ELSE 0 END,P1.id_tec, P1.dat_sklen)) + SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O1.obligo_rne, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.DDV END)) ELSE 0 END, ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
			 WHEN 'DBA' THEN SUM(dbo.gfn_XChange(F.id_tec, S.znesek_dom, '000', @par_trenutnidatum))
           END, 0),
        vr_dom = ISNULL(CASE FT.sif_frame_type 
             WHEN 'POG' THEN SUM(dbo.gfn_XChange('000', P1.vr_val_zac, P1.id_tec, P1.dat_sklen))
             WHEN 'PLA' THEN SUM(FP.znesek_pl - FP.odbitni_ddv)
             WHEN 'REV' THEN SUM(dbo.gfn_XChange('000', ISNULL(O1.obligo_rev, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.vr_val - P1.varscina END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
             WHEN 'NET' THEN SUM(dbo.gfn_XChange('000', P1.net_nal, P1.id_tec, P1.dat_sklen))
             WHEN 'DOB' THEN SUM(CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END)
             WHEN 'ZAL' THEN SUM(STK.kredit - STK.debit)
			 WHEN 'RFO' THEN SUM(dbo.gfn_XChange('000', ISNULL(O1.obligo_rfo, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p1.vr_val, p1.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P1.man_str + P1.stroski_x + P1.stroski_pz + P1.stroski_zt + P1.zav_fin + P1.str_financ END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
			 WHEN 'RRE' THEN SUM(CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END)
			 WHEN 'RNE' THEN SUM(dbo.gfn_XChange('000',  CASE WHEN nl.ddv_takoj = 1 THEN P1.net_nal_zac ELSE 0 END,P1.id_tec, P1.dat_sklen)) + SUM(dbo.gfn_XChange('000',  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O1.obligo_rne, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.DDV END)) ELSE 0 END, ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
			 WHEN 'DBA' THEN SUM(S.znesek_dom)
           END, 0),
        razlika_dom = F.znesek_dom - ISNULL(CASE FT.sif_frame_type 
             WHEN 'POG' THEN SUM(dbo.gfn_XChange('000', P1.vr_val_zac, P1.id_tec, P1.dat_sklen))
             WHEN 'PLA' THEN SUM(FP.znesek_pl - FP.odbitni_ddv)
             WHEN 'REV' THEN SUM(dbo.gfn_XChange('000', ISNULL(O1.obligo_rev, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.vr_val - P1.varscina END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
             WHEN 'NET' THEN SUM(dbo.gfn_XChange('000', P1.net_nal, P1.id_tec, P1.dat_sklen))
             WHEN 'DOB' THEN SUM(CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END)
             WHEN 'ZAL' THEN SUM(STK.kredit - STK.debit)
			 WHEN 'RFO' THEN SUM(dbo.gfn_XChange('000', ISNULL(O1.obligo_rfo, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p1.vr_val, p1.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P1.man_str + P1.stroski_x + P1.stroski_pz + P1.stroski_zt + P1.zav_fin + P1.str_financ END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
			 WHEN 'RRE' THEN SUM(CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END)
			 WHEN 'RNE' THEN SUM(dbo.gfn_XChange('000',  CASE WHEN nl.ddv_takoj = 1 THEN P1.net_nal_zac ELSE 0 END,P1.id_tec, P1.dat_sklen)) + SUM(dbo.gfn_XChange('000',  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O1.obligo_rne, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.DDV END)) ELSE 0 END, ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
			 WHEN 'DBA' THEN SUM(S.znesek_dom)
           END, 0),
		f.tecaj, f.obr_mera, f.int_obr_mera, f.id_strm, f.id_dav_st, f.konto, 
		f.pkonto, f.pkonto_davek, f.id_rtip, f.int_id_rtip, f.int_id_obd, 
		f.int_max_dat, f.int_opis_fak, f.limvr_val, f.limproc_pol, f.limprv_obr, 
		f.limvarscina, f.limnacin_leas, f.limobr_mera, f.limid_rtip, f.limopcija, 
		f.limproc_ms, f.limman_str, f.limtraj_naj, f.opis_zav, f.limproc_varsc, 
		f.limproc_opcija, f.ali_pov_part, f.sif_odobrit, f.dat_izteka,
        C.skrbnik_1, S1.naz_kr_kup as naz_kr_kup_skrbnik_1,
        C.skrbnik_2, S2.naz_kr_kup as naz_kr_kup_skrbnik_2,
		ft.b2_eligible, ST_POG.st_pogodb as st_pogodb
    FROM 
        dbo.frame_list F
		LEFT JOIN dbo.frame_list F1	ON F1.id_parent = F.id_frame
	    LEFT JOIN dbo.frame_pogodba FC1 ON F1.id_frame = FC1.id_frame
        LEFT JOIN dbo.pogodba P1 ON FC1.id_cont = P1.id_cont
        LEFT JOIN dbo.partner C ON F.id_kupca = C.id_kupca
        LEFT JOIN dbo.partner S1 ON S1.id_kupca = C.skrbnik_1
        LEFT JOIN dbo.partner S2 ON S2.id_kupca = C.skrbnik_2
        LEFT JOIN dbo.tecajnic T ON F.id_tec = T.id_tec
        LEFT JOIN dbo.frame_plac FP ON F1.id_frame = FP.id_frame
        LEFT JOIN dbo.users U ON F.username = U.username 
		LEFT JOIN dbo.gfn_stk_get_frame_consument() as STK ON F.id_frame = STK.id_frame
		LEFT JOIN (SELECT SUM(dbo.gfn_XChange('000', ISNULL(P.znesek_dom, 0), P.id_tec, P.datum)) as znesek_dom, P.id_dob
                       FROM dbo.plac_izh P
                       INNER JOIN dbo.plac_izh_tip T ON P.id_plac_izh_tip = T.id_plac_izh_tip
                      INNER JOIN dbo.pogodba C ON P.id_cont = C.id_cont
                      WHERE P.id_vrste = 1 
                        AND P.status_placila IN ('V', 'E', 'A', 'S', 'P')
                        AND C.status_akt IN ('N', 'D')
                        AND T.p1_je_racun = 0
						AND P.id_frame is NULL
					  GROUP BY P.id_dob) R ON F1.id_kupca = R.id_dob
         LEFT JOIN (SELECT SUM(dbo.gfn_XChange('000', S.znesek_dom, S.id_tec, S.datum)) AS znesek_dom, S.id_dob, S.id_frame 
                     FROM dbo.plac_izh S
                    INNER JOIN dbo.plac_izh_tip T ON S.id_plac_izh_tip = T.id_plac_izh_tip
                    INNER JOIN dbo.pogodba PR ON S.id_cont = PR.id_cont
					INNER JOIN dbo.frame_list f ON f.id_frame = s.id_frame
					LEFT JOIN dbo.frame_list F1	ON F.id_parent = F1.id_frame
					INNER JOIN dbo.frame_type ft ON ft.id_frame_type = f.frame_type
                    WHERE S.id_vrste = 1 
                      AND S.status_placila IN ('V', 'E', 'A', 'S', 'P')
                      AND T.p1_je_racun = 0
					  AND  ft.sif_frame_type = 'DBA' 
                    GROUP BY S.id_dob, S.id_frame) S ON F1.id_kupca = S.id_dob and F1.id_frame = S.id_frame 
        INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type
		LEFT JOIN dbo.nacini_l nl on nl.nacin_leas = P1.nacin_leas 
		LEFT JOIN dbo.dav_stop ds on ds.id_dav_st = P1.id_dav_st 
		LEFT JOIN (SELECT 
						sum(a.znesek_dom) as znesek_dom,
						a.id_dob
					FROM 
						dbo.gfn_SummitPlacIzhData(0) as a 
					GROUP BY 
						a.id_dob) V on F1.id_kupca = V.id_dob
		LEFT JOIN (SELECT id_frame, COUNT(status_akt) AS st_pogodb
				   FROM dbo.frame_pogodba fp
				   INNER JOIN dbo.pogodba p ON fp.id_cont = p.id_cont
				   WHERE p.status_akt != 'Z' 
				   GROUP BY id_frame) ST_POG ON ST_POG.id_frame = F.id_frame
        LEFT JOIN (SELECT pp.id_cont, pp.id_kupca, pp.id_tec,
							SUM(case when upper(IsNull(cs.val, '')) = 'TRUE'
										then pp.znp_saldo_brut_all + pp.poknj_nezap_debit_brut_ALL + pp.bod_neto_lpod - pp.poknj_nezap_neto_lpod + pp.bod_robresti_lpod - pp.poknj_nezap_robresti_lpod + case when nl.leas_kred = 'L' and nl.tip_knjizenja = '2' then pp.bod_davek_LPOD - pp.poknj_nezap_davek_LPOD else 0 end
										else pp.znp_saldo_brut_all + pp.bod_neto_lpod 
											+ CASE WHEN nl.leas_kred = 'L' AND nl.tip_knjizenja = '2' AND nl.finbruto = 0 AND nl.ol_na_nacin_fl = 0 THEN pp.poknj_nezap_davek_LPOD ELSE 0 END 
											+ CASE WHEN nl.ima_robresti = 1 THEN pp.bod_robresti_lpod ELSE 0 END
								end) AS obligo_rev,
							SUM(pp.znp_saldo_brut_all + pp.bod_debit_brut_ALL - pp.bod_obresti_LPOD - case when nl.dav_o = 'D' then pp.bod_obresti_LPOD * (ds.davek / 100) else 0 end) AS obligo_rfo,
							SUM(pp.znp_saldo_ddv + pp.bod_davek_lpod) AS obligo_rne
                     FROM dbo.planp_ds pp
					 INNER JOIN dbo.pogodba po ON po.id_cont = pp.id_cont
					 INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = po.nacin_leas
					 INNER JOIN dbo.dav_stop ds ON ds.id_dav_st = po.id_dav_st
					 LEFT JOIN (select val from dbo.custom_settings where code = 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc') cs on 1 = 1
                     GROUP BY pp.id_cont, pp.id_kupca, pp.id_tec) O1 ON P1.id_cont = O1.id_cont AND P1.id_kupca = O1.id_kupca

    WHERE  F.je_krovni_okvir = 1 
        AND (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
        AND (@par_partner_enabled = 0 OR F.id_kupca = @par_partner_number)
        AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)
        AND (@par_username_enabled = 0 OR F.username = @par_username_value)
		AND (@par_b2eligible_enabled = 0 OR FT.B2_eligible = CONVERT(char(1), @par_b2eligible_value))
		AND (@par_akt_enabled = 0 OR F.status_akt = CASE WHEN @par_akt_value = 1 THEN 'A' ELSE 'Z' END)
    GROUP BY 
        F.id_frame, F.id_kupca, F.opis, F.id_tec, F.kraj, F.dat_odobritve, 
        F.znesek_val, F.znesek_dom, C.naz_kr_kup, T.id_val,
        FT.sif_frame_type, F.status_akt, F.dat_zak, F.velja_do, U.user_desc, F.opombe,
		f.tecaj, f.obr_mera, f.int_obr_mera, f.id_strm, f.id_dav_st, f.konto, 
		f.pkonto, f.pkonto_davek, f.id_rtip, f.int_id_rtip, f.int_id_obd, 
		f.int_max_dat, f.int_opis_fak, f.limvr_val, f.limproc_pol, f.limprv_obr, 
		f.limvarscina, f.limnacin_leas, f.limobr_mera, f.limid_rtip, f.limopcija, 
		f.limproc_ms, f.limman_str, f.limtraj_naj, f.opis_zav, f.limproc_varsc, 
		f.limproc_opcija, f.ali_pov_part, f.sif_odobrit, f.dat_izteka,
        C.skrbnik_1, S1.naz_kr_kup,
        C.skrbnik_2, S2.naz_kr_kup,
		ft.b2_eligible, ST_POG.st_pogodb,F.je_krovni_okvir, F.id_parent
    HAVING (@par_razlika = 0 OR (F.znesek_val - ISNULL(CASE FT.sif_frame_type
                                                         WHEN 'POG' THEN SUM(dbo.gfn_XChange(F.id_tec, P1.vr_val_zac, P1.id_tec, P1.dat_sklen))
                                                         WHEN 'PLA' THEN SUM(dbo.gfn_XChange(F.id_tec, FP.znesek_pl, '000', FP.datum_pl) - dbo.gfn_XChange(F.id_tec, FP.odbitni_ddv, '000', FP.datum_pl))
                                                         WHEN 'REV' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O1.obligo_rev, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.vr_val - P1.varscina END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
                                                         WHEN 'NET' THEN SUM(dbo.gfn_XChange(F.id_tec, P1.net_nal, P1.id_tec, P1.dat_sklen))
                                                         WHEN 'DOB' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END, '000', @par_trenutnidatum))
														 WHEN 'ZAL' THEN SUM(STK.kredit - STK.debit)
														 WHEN 'RFO' THEN SUM(dbo.gfn_XChange(F.id_tec, ISNULL(O1.obligo_rfo, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE dbo.gfn_VrValToBrutoInternal(p1.vr_val, p1.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + P1.man_str + P1.stroski_x + P1.stroski_pz + P1.stroski_zt + P1.zav_fin + P1.str_financ END), ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
														 WHEN 'RRE' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE V.znesek_dom END, '000', @par_trenutnidatum))
														 WHEN 'RNE' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN nl.ddv_takoj = 1 THEN P1.net_nal_zac ELSE 0 END,P1.id_tec, P1.dat_sklen)) + SUM(dbo.gfn_XChange(F.id_tec,  CASE WHEN nl.ddv_takoj = 1 THEN (ISNULL(O1.obligo_rne, CASE WHEN P1.status_akt = 'Z' OR (P1.status_akt = 'A' AND DATEDIFF(dd, P1.dat_aktiv, @par_trenutnidatum) > 5) THEN 0 ELSE P1.DDV END)) ELSE 0 END, ISNULL(O1.id_tec, P1.id_tec), @par_trenutnidatum))
														 WHEN 'DBA' THEN SUM(dbo.gfn_XChange(F.id_tec, CASE WHEN F.status_akt = 'Z' THEN 0 ELSE R.znesek_dom END, '000', @par_trenutnidatum))
                                                       END, 0)) < 0)
)
