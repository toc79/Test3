------------------------------------------------------------------------------------------------------------------  
-- This procedure prepares snapshot data for FRAME_LIST and FRAME_POGODBA.   
--  
-- History:  
-- 27.08.2009 Ziga; Task ID 5599 - created  
-- 16.02.2010 Ziga MID 23659 - changed fields vr_val and net_nal for frame types 'POG' and 'NET' - vr_val_zac and net_nal_zac are used instead of vr_val nad net_nal  
-- 12.04.2010 Ziga; MID 24705 - added new frame type for Summit Ford with frame_type code = 'RFO'  
-- 14.06.2010 Natasa; TID 5935- added new field "product" to oc_frames   
-- 09.06.2011 Jasna; MID 30113 - added new frame type called RRE (Retail Risk Exposure)  
-- 27.12.2011 Jasna; MID 30918 - added new frame type mix of REV for DDV and NET for other claims  
-- 28.03.2012 Ziga; MID 34209 - modified calculation of obligo for frame type RFO - future interests tax is excluded   
-- 05.08.2013 Jost; Task ID 7513 - added field 'id_project' while transfering data from 'dbo.oc_frames'  
-- 10.03.2014 Jelena; MID 43659 - supported new frame_type DBA  
-- 11.04.2014 Jelena; MID 43659 - for frame type DOB  - added partly activate contract (status_akt IN ('N', 'D'))  
-- 30.05.2014 IgorS; Task ID 8109 - added function gfn_VrValToBrutoInternal for vr_val bruto  
-- 04.06.2014 IgorS & MatjažS; Task ID 8109 - added robresti in futrue_claims calculation for frame type REV  
-- 15.07.2014 Natasa; MID 43343 - added obr_mera and id_rtip to oc_frames  
-- 15.01.2015 Domen; TaskID 8447 - Optimization: replacing gfn_Xchange with gfn_xchange_table  
-- 12.07.2016 Blaz: TID 9512 - added fields kategorija 1,kategorija 2, kategorija 3  
-- 14.07.2016 MatjazB; Task 9514 - use gv_FrameList instead of table frame_list;  fix bug - use frame_type instead of 29 (SUMMIT)  
-- 19.07.2016 Blaz; TID 9518 - added #grouped_frame_orders and znesek_narocila to oc_frames insert  
-- 25.07.2016 Ziga; MID 57807 - modification for REV frames, added custom setting Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc  
-- 26.07.2016 Ales; Task id 9517 - added column id_gl_knj_shema to table oc_frames  
-- 15.02.2018 Jelena; MID 69420 - added new frame type 'MPC'  
-- 05.03.2018 Jelena; BID 33622 - because pogodba.MPC is in domestic currency, added exchanged from domestic currency to contract currency  
-- 16.03.2018 Josip; MID 71245 - modifications because of new leas type Hibrid - nl.tip_knjizenja = 2 and nl.ol_na_nacin_fl = 1  
-- 22.03.2018 Jelena; MID 68161 - added column ali_porok to table oc_frames  
-- 10.07.2018 Ales; TID 13297 - added fields on oc_frames  
-- 08.04.2022 Thor; TID 23760 - added reservations from gv_frame_reservations_active  
------------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[gsp_oc_frames_prepare]  
    @report_id int,  
 @target_date datetime  
AS  
  
exec dbo.gsp_log_sproc 'gsp_oc_frames_prepare', 'Preparing oc_frames.'  
  
-- PLA  
SELECT FP.id_frame,  
SUM(FP.znesek_pl - FP.odbitni_ddv) as plac_dom,  
SUM(FP.znesek_val - dbo.gfn_xr_dom2val(FP.odbitni_ddv, FP.tecaj)) as plac_val  
INTO #frame_pla  
FROM dbo.frame_list F  
INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
INNER JOIN dbo.frame_plac FP ON F.id_frame = FP.id_frame  
WHERE FP.datum_pl <= @target_date and FT.sif_frame_type = 'PLA'  
GROUP BY FP.id_frame  
  
-- REV, RFO  
-- dued not paied  
select f.id_frame,   
 sum(  
  case when upper(IsNull(cs.val, '')) = 'TRUE' and FT.sif_frame_type = 'REV' then  
    case when p.status_akt in ('N','D') then 0 else (case when oc.datum_dok <= @target_date then ov.znesek else 0 end) end  
  else  
   CASE WHEN oc.datum_dok <= @target_date AND (FT.sif_frame_type <> 'RNE' OR T.sif_terj = 'DDV')  
   THEN ov.znesek  
   ELSE 0 END  
  end  
 ) as Obligo_val,  
 sum(  
  case when upper(IsNull(cs.val, '')) = 'TRUE' and FT.sif_frame_type = 'REV' then  
    case when p.status_akt in ('N','D') then 0 else (case when oc.datum_dok <= @target_date then ov.znesek else 0 end) end  
  else     CASE WHEN oc.datum_dok <= @target_date AND (FT.sif_frame_type <> 'RNE' OR T.sif_terj = 'DDV')  
   THEN od.znesek  
   ELSE 0 END  
  end  
 ) as Obligo_dom  
into #oc_claims  
from dbo.frame_list f   
INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
inner join dbo.frame_pogodba fp on f.id_frame = fp.id_frame  
inner join dbo.oc_claims oc on oc.id_cont = fp.id_cont  
inner join dbo.oc_contracts p on p.id_oc_report = oc.id_oc_report and p.id_cont = oc.id_cont  
inner join dbo.vrst_ter T on T.id_terj = oc.id_terj  
left join (select entity_name from dbo.loc_nast) ln on 1 = 1  
left join (select val from dbo.custom_settings where code = 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc') cs on 1 = 1  
outer apply dbo.gfn_xchange_table(f.id_tec, oc.ex_saldo_val_claim, oc.id_tec, @target_date) ov  
outer apply dbo.gfn_xchange_table('000', oc.ex_saldo_val_claim, oc.id_tec, @target_date) od  
where   
FT.sif_frame_type in ('REV', 'RFO', 'RNE')   
and oc.id_oc_report = @report_id  
group by f.id_frame  
  
-- future claims  
-- REV  
select f.id_frame,  
sum(fcv.znesek) as future_claims_val,  
sum(fcd.znesek) as future_claims_dom  
into #oc_contracts  
from dbo.oc_contracts p  
inner join dbo.frame_pogodba fp on p.id_cont = fp.id_cont   
inner join dbo.frame_list f on f.id_frame = fp.id_frame   
INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
INNER JOIN dbo.nacini_l N ON N.nacin_leas = p.nacin_leas   
left join dbo.odobrit od on od.id_odobrit = p.id_odobrit  
left join (select entity_name from dbo.loc_nast) ln on 1 = 1  
left join (select val from dbo.custom_settings where code = 'Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc') cs on 1 = 1  
outer apply dbo.gfn_xchange_table(f.id_tec,  
         case when upper(IsNull(cs.val, '')) = 'TRUE' then  
           case when p.status_akt in ('N','D') and od.id_odobrit_tip in (12, 13) and ln.entity_name = 'RLHR' then p.vr_val_zac  
             when p.status_akt in ('N','D') then p.net_nal_zac  
             else p.ex_g1_neto + case when n.ima_robresti = 1 then p.ex_g1_robresti else 0 end + case when n.leas_kred = 'L' and n.tip_knjizenja = '2' and n.ol_na_nacin_fl = 0 then p.ex_g1_davek else 0 end  
           end  
           else  
            case when p.status_akt in ('A', 'Z') then p.ex_g1_neto + CASE WHEN N.ima_robresti = 1 THEN p.ex_g1_robresti ELSE 0 END  
              else p.vr_val - p.varscina  
           end  
         end,  
         p.id_tec, @target_date) fcv  
outer apply dbo.gfn_xchange_table('000',  
         case when upper(IsNull(cs.val, '')) = 'TRUE' then  
           case when p.status_akt in ('N','D') and od.id_odobrit_tip in (12, 13) and ln.entity_name = 'RLHR' then p.vr_val_zac  
             when p.status_akt in ('N','D') then p.net_nal_zac  
             else p.ex_g1_neto + case when n.ima_robresti = 1 then p.ex_g1_robresti else 0 end + case when n.leas_kred = 'L' and n.tip_knjizenja = '2' and n.ol_na_nacin_fl = 0 then p.ex_g1_davek else 0 end  
           end  
           else  
           case when p.status_akt in ('A', 'Z') then p.ex_g1_neto + CASE WHEN N.ima_robresti = 1 THEN p.ex_g1_robresti ELSE 0 END  
             else p.vr_val - p.varscina  
           end  
         end,  
         p.id_tec, @target_date) fcd  
where FT.sif_frame_type = 'REV' and p.id_oc_report = @report_id  
group by f.id_frame, FT.sif_frame_type  
union  
-- RFO  
select f.id_frame,  
sum(fcv.znesek) as future_claims_val,  
sum(fcd.znesek) as future_claims_dom  
from dbo.oc_contracts p  
inner join dbo.frame_pogodba fp on p.id_cont = fp.id_cont   
inner join dbo.frame_list f on f.id_frame = fp.id_frame   
inner join dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
inner join dbo.nacini_l nl on nl.nacin_leas = p.nacin_leas  
inner join dbo.dav_stop ds on ds.id_dav_st = p.id_dav_st  
outer apply dbo.gfn_xchange_table(f.id_tec, case when p.status_akt in ('A', 'Z') then p.ex_g1_debit + p.ex_g2_debit - p.ex_g1_obresti - case when nl.dav_o = 'D' then p.ex_g1_obresti * (ds.davek / 100) else 0 end  
           else dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + p.man_str + p.stroski_x + p.stroski_pz + p.stroski_zt + P.zav_fin + p.str_financ end, p.id_tec, @target_date) fcv  
outer apply dbo.gfn_xchange_table('000', case when p.status_akt in ('A', 'Z') then p.ex_g1_debit + p.ex_g2_debit - p.ex_g1_obresti - case when nl.dav_o = 'D' then p.ex_g1_obresti * (ds.davek / 100) else 0 end  
        else dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robresti, nl.dav_b, nl.finbruto, nl.dav_n) + p.man_str + p.stroski_x + p.stroski_pz + p.stroski_zt + P.zav_fin + p.str_financ end, p.id_tec, @target_date) fcd  
where FT.sif_frame_type = 'RFO' and p.id_oc_report = @report_id  
group by f.id_frame, FT.sif_frame_type  
union  
-- RNE  
select f.id_frame,  
sum(fcv.znesek) as future_claims_val,  
sum(fcd.znesek) as future_claims_dom  
from dbo.oc_contracts p  
inner join dbo.frame_pogodba fp on p.id_cont = fp.id_cont   
inner join dbo.frame_list f on f.id_frame = fp.id_frame   
inner join dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
outer apply dbo.gfn_xchange_table(f.id_tec, p.ex_g1_davek, p.id_tec, @target_date) fcv  
outer apply dbo.gfn_xchange_table('000', p.ex_g1_davek, p.id_tec, @target_date) fcd  
where FT.sif_frame_type = 'RNE'   
and p.id_oc_report = @report_id  
group by f.id_frame, FT.sif_frame_type  
  
-- REV outstanding  
select a.id_frame,  
isnull(b.obligo_val, 0) + a.future_claims_val as obligo_val,  
isnull(b.obligo_dom, 0) + a.future_claims_dom as obligo_dom  
into #frame_rev  
from #oc_contracts a  
left outer join #oc_claims b on a.id_frame = b.id_frame  
  
drop table #oc_claims  
drop table #oc_contracts  
  
-- POG, NET, MPC  
SELECT f.id_frame,   
SUM(vvd.znesek) as vr_val_dom,  
SUM(nnd.znesek) as net_nal_dom,  
SUM(c.MPC) as MPC_dom,  
SUM(vv.znesek) as vr_val,  
SUM(nn.znesek) as net_nal,  
SUM(mm.znesek) as MPC  
INTO #frame_pognet  
FROM dbo.oc_contracts c  
INNER JOIN dbo.frame_pogodba fp ON c.id_cont = fp.id_cont   
INNER JOIN dbo.frame_list f ON f.id_frame = fp.id_frame   
INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
OUTER APPLY dbo.gfn_xchange_table('000', IsNull(c.vr_val_zac, 0), c.id_tec, @target_date) vvd  
OUTER APPLY dbo.gfn_xchange_table('000', IsNull(c.net_nal_zac, 0), c.id_tec, @target_date) nnd  
OUTER APPLY dbo.gfn_xchange_table(f.id_tec, IsNull(c.vr_val_zac, 0), c.id_tec, @target_date) vv  
OUTER APPLY dbo.gfn_xchange_table(f.id_tec, IsNull(c.net_nal_zac, 0), c.id_tec, @target_date) nn  
OUTER APPLY dbo.gfn_xchange_table(f.id_tec, IsNull(c.MPC, 0), '000', @target_date) mm  
WHERE FT.sif_frame_type IN ('POG', 'NET', 'RNE', 'MPC') AND c.id_oc_report = @report_id  
GROUP BY f.id_frame  
  
-- DOB  
SELECT f.id_frame,  
SUM(zd.znesek) as znesek_dom,   
SUM(zv.znesek) as znesek_val  
INTO #frame_dob  
FROM dbo.plac_izh R  
INNER JOIN dbo.pogodba PR ON R.id_cont = PR.id_cont  
INNER JOIN dbo.frame_list f on f.id_kupca = r.id_dob  
INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
OUTER APPLY dbo.gfn_xchange_table('000', R.znesek_dom, R.id_tec, R.datum) zd  
OUTER APPLY dbo.gfn_xchange_table(f.id_tec, R.znesek_dom, R.id_tec, R.datum) zv  
WHERE R.id_vrste = 1 AND FT.sif_frame_type = 'DOB'  
AND R.status_placila IN ('V', 'E', 'A', 'S')  
AND PR.status_akt IN ('N', 'D') AND r.datum <= @target_date  
GROUP BY f.id_frame  
  
-- DBA  
SELECT f.id_frame,  
SUM(zd.znesek) as znesek_dom,   
SUM(zv.znesek) as znesek_val  
INTO #frame_dob_avans  
FROM dbo.plac_izh R  
INNER JOIN dbo.pogodba PR ON R.id_cont = PR.id_cont  
INNER JOIN dbo.frame_list f on f.id_kupca = r.id_dob  
INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
OUTER APPLY dbo.gfn_xchange_table('000', R.znesek_dom, R.id_tec, R.datum) zd  
OUTER APPLY dbo.gfn_xchange_table(f.id_tec, R.znesek_dom, R.id_tec, R.datum) zv  
WHERE R.id_vrste = 1 AND FT.sif_frame_type ='DBA'  
AND R.status_placila IN ('V', 'E', 'A', 'S')  
AND r.datum <= @target_date  
GROUP BY f.id_frame  
  
  
  
-- ZAL  
SELECT F.id_frame,  
SUM(STK.kredit - STK.debit) AS znesek_dom,  
SUM(zv.znesek) AS znesek_val  
INTO #frame_zal  
FROM dbo.frame_list F  
INNER JOIN dbo.frame_type FT ON F.frame_type = FT.id_frame_type  
INNER JOIN dbo.gfn_stk_get_frame_consument() STK ON F.id_frame = STK.id_frame  
OUTER APPLY dbo.gfn_xchange_table(F.id_tec, STK.kredit - STK.debit, '000', @target_date) zv  
WHERE FT.sif_frame_type = 'ZAL'  
GROUP BY F.id_frame  
  
-- RRE  
SELECT f.id_frame,  
SUM(zd.znesek) as znesek_dom,   
SUM(zv.znesek) as znesek_val  
INTO #frame_rre  
FROM dbo.plac_izh a  
INNER JOIN dbo.pogodba c on a.id_cont = c.id_cont  
INNER JOIN dbo.nacini_l d on c.nacin_leas = d.nacin_leas  
INNER JOIN dbo.partner e on c.id_dob = e.id_kupca  
INNER JOIN dbo.frame_list f on a.id_dob = f.id_kupca   
INNER JOIN dbo.frame_type ft on f.frame_type = ft.id_frame_type  
OUTER APPLY dbo.gfn_xchange_table('000', a.znesek_dom, a.id_tec, a.datum) zd  
OUTER APPLY dbo.gfn_xchange_table(f.id_tec, a.znesek_dom, a.id_tec, a.datum) zv  
WHERE a.id_plac_izh_tip in ('1','2','3') -- plačilo, kompenzacija, asignacija  
 and a.status_placila IN ('V', 'E', 'A', 'S', 'P') -- vnešeno, odobreno, zavrnjeno  
 and d.leas_kred = 'L'  
 and c.nacin_leas != 'FS'  
 and c.id_strm not like '%05%'  
 and c.id_kupca != c.id_dob  
 and f.znesek_dom is not null  
 and c.status_akt != 'Z'  
    and ft.sif_frame_type = 'RRE'  
 and not exists   
  (select * from dbo.dokument D1  
   INNER JOIN dbo.dok D2 ON D2.id_obl_zav = D1.id_obl_zav  
   where D1.id_cont = c.id_cont   
   and D2.sifra = 'PROM'   
   and D1.ima = 1)  
GROUP BY f.id_frame  
  
-- GROUPED ORDERS FOR FRAME TYPE REV  
SELECT u.id_frame, SUM(u.znesek) as znesek_narocila  
INTO #grouped_frame_orders  
FROM (  
 SELECT f1.id_frame, f1.znesek_narocila as znesek  
 FROM dbo.gv_Stock_fund_orders_reducing_frames f1  
 UNION ALL   
 SELECT f2.id_frame, f2.amount as znesek  
 FROM dbo.gv_frame_reservations_active f2  
 ) u  
GROUP BY id_frame  
  
--------------------------------------  
INSERT INTO dbo.oc_frames   
 (id_oc_report, id_frame, id_kupca, dat_odobritve, id_frame_type, frame_type,   
 znesek_val, id_tec, znesek_dom, plac_dom, plac_val, dat_zak,  
 limvr_val, limproc_pol, limprv_obr, limvarscina, limnacin_leas, limobr_mera,  
 limid_rtip, limopcija, limproc_ms, limman_str, limtraj_naj, opis_zav,   
 ali_pov_part,  sif_odobrit, b2_eligible, velja_do, dat_izteka, status_akt, opis,   
 kraj, username, opombe, id_kredpog, product, id_project, obr_mera, id_rtip,  
 kategorija1, kategorija2, kategorija3, id_gl_knj_shema, ali_porok,  
 id_dav_st, id_strm, int_id_obd, int_id_rtip, int_max_dat, int_obr_mera, int_opis_fak,  
 konto, limproc_opcija, limproc_varsc, pkonto, pkonto_davek, tecaj)  
select   
 @report_id, F.id_frame, F.id_kupca, F.dat_odobritve, F.frame_type, FT.sif_frame_type,   
 F.znesek_val, F.id_tec, F.znesek_dom,   
 case when ft.sif_frame_type = 'PLA' then ISNULL(fp.plac_dom, 0)  
      when ft.sif_frame_type in ('REV','RFO') then ISNUll(fr.obligo_dom, 0) + dbo.gfn_xr_val2dom(ISNUll(gfo.znesek_narocila, 0), F.tecaj)  
      when ft.sif_frame_type = 'POG' then ISNULL(fpn.vr_val_dom, 0)  
      when ft.sif_frame_type = 'NET' then ISNULL(fpn.net_nal_dom, 0)  
   when ft.sif_frame_type = 'MPC' then ISNULL(fpn.MPC_dom, 0)  
      when ft.sif_frame_type = 'DOB' then ISNULL(fd.znesek_dom, 0)  
   when ft.sif_frame_type = 'DBA' then ISNULL(fa.znesek_dom, 0)  
      when ft.sif_frame_type = 'ZAL' then ISNULL(stk.znesek_dom, 0)   
      when ft.sif_frame_type = 'RRE' then ISNULL(rre.znesek_dom,0)   
      when ft.sif_frame_type = 'RNE' then (ISNULL(fpn.net_nal_dom,0) + ISNULL(fr.obligo_dom,0)) end as plac_dom,  
	  
 case when ft.sif_frame_type = 'PLA' then ISNULL(fp.plac_val, 0)  
      when ft.sif_frame_type in ('REV', 'RFO') then ISNULL(fr.obligo_val, 0) + ISNUll(gfo.znesek_narocila, 0)  
      when ft.sif_frame_type = 'POG' then ISNULL(fpn.vr_val, 0)  
      when ft.sif_frame_type = 'NET' then ISNULL(fpn.net_nal, 0)  
   when ft.sif_frame_type = 'MPC' then ISNULL(fpn.MPC, 0)  
      when ft.sif_frame_type = 'DOB' then ISNULL(fd.znesek_val, 0)  
   when ft.sif_frame_type = 'DBA' then ISNULL(fa.znesek_val, 0)  
      when ft.sif_frame_type = 'ZAL' then ISNULL(stk.znesek_val, 0)   
   when ft.sif_frame_type = 'RRE' then ISNULL(rre.znesek_val,0)   
   when ft.sif_frame_type = 'RNE' then (ISNULL(fpn.net_nal,0) + ISNULL(fr.obligo_val,0)) end as plac_val,  
 F.dat_zak,  
 F.limvr_val, F.limproc_pol, F.limprv_obr, F.limvarscina, F.limnacin_leas, F.limobr_mera,  
 F.limid_rtip, F.limopcija, F.limproc_ms, F.limman_str, F.limtraj_naj, F.opis_zav, F.ali_pov_part,F.sif_odobrit,  
 FT.b2_eligible, F.velja_do, F.dat_izteka, F.status_akt, F.opis, F.kraj, F.username, F.opombe, F.id_kredpog,  
 ft.product, F.id_project,  
 F.obr_mera, F.id_rtip,  
 F.kategorija1, F.kategorija2, F.kategorija3, F.id_gl_knj_shema, ali_porok,  
 F.id_dav_st, F.id_strm, F.int_id_obd, F.int_id_rtip, F.int_max_dat, F.int_obr_mera, F.int_opis_fak,  
 F.konto, F.limproc_opcija, F.limproc_varsc, F.pkonto, F.pkonto_davek, F.tecaj  
from dbo.gv_FrameList F   
inner join dbo.frame_type ft ON f.frame_type = ft.id_frame_type  
left outer join #frame_pla fp on f.id_frame = fp.id_frame  
left outer join #frame_rev fr on f.id_frame = fr.id_frame  
left outer join #frame_pognet fpn on f.id_frame = fpn.id_frame  
left outer join #frame_dob fd on f.id_frame = fd.id_frame  
left outer join #frame_zal stk on f.id_frame = stk.id_frame   
left outer join #frame_rre rre on f.id_frame = rre.id_frame   
left outer join #frame_dob_avans fa on f.id_frame = fa.id_frame  
left outer join #grouped_frame_orders gfo on f.id_frame = gfo.id_frame  
  
  
drop table #frame_pla  
drop table #frame_rev  
drop table #frame_pognet  
drop table #frame_dob  
drop table #frame_dob_avans  
drop table #frame_zal  
drop table #frame_rre  
  
exec dbo.gsp_log_sproc 'gsp_oc_frames_prepare', 'Preparing oc_frame_pogodba.'  
  
INSERT INTO dbo.oc_frame_pogodba  
 (id_oc_report, id_frame_pogodba, id_frame, id_cont, status)  
SELECT  
 @report_id, fp.id_frame_pogodba, fp.id_frame, fp.id_cont, fp.status  
FROM dbo.frame_pogodba fp  
JOIN dbo.oc_contracts c on c.id_oc_report = @report_id and fp.id_cont = c.id_cont  
  
  