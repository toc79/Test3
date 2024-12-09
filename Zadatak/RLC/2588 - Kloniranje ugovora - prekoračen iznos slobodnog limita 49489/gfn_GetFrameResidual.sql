----------------------------------------------------------------------------------------------------------------  
-- Returns residual value of approved value and used frame on date ExRateDate in currency ResultCurrency  
--  
-- PARAMETERS:   
--   id_frame - frame id that the residual value is calculated for (can be null)  
--   id_cont - contract id which should be left out by calculation (null - insert, !null - update)  
--   ResultCurrency - the currency in which the calculated value is returned  
--   ExRateDate - date of exchange rate  
  
-- History:  
-- 18.05.2005 Vilko; created  
-- 05.08.2005 Vilko; modified condition - by residual calculation should be considered only unclosed contracts  
-- 05.08.2005 Matjaz; moved condition from join into where  
-- 19.08.2005 Vilko; returned conditon back into join - in where clause it doesn't work properly  
-- 17.01.2006 Vilko; added residual calculation for revolving frames  
-- 11.12.2006 Vilko; Maintenance ID 3722 - added residual calculation for frame type = 'NET' and 'DOB'  
-- 14.02.2008 Jasna; MID 13571 - fixed bug, case when @id_cont is null  
-- 30.07.2008 Jure; TASK 5282 - Supported new frame type for stock management "ZAL"  
-- 22.10.2008 Matjaz; TASK 5282 - fixed id_tec for frame data in case of frame_type = 'ZAL'. Amounts are allways in native currency.  
-- 31.03.2009 Vilko; MID 20096 - fixed residual calculation for frame type = 'DOB' - function returned 0 if there were no payments  
-- 24.04.2009 Vilko; MID 20449 - fixed residual calculation for frame type = 'DOB' - now are also included partialy activated contracts  
-- 24.04.2009 Vilko; MID 20096 - fixed residual calculation for frame type = 'REV' - in obligo are now inlcuded ALL dued not paid claims - before only LOBR  
-- 16.02.2010 Ziga; MID 23659 - modified frame residual for frame types 'NET' and 'POG' - net_nal_zac and vr_val_zac is used instead of net_nal and vr_val  
-- 12.04.2010 Ziga; MID 24705 - added new frame type for Summit Ford with frame_type code = 'RFO'  
-- 04.05.2010 Ziga; MID 25145 - repaired obligo for frame type REV and RFO for active contracts that do not exists in planp_ds (all claims are closed), obligo for such contracts is 0.  
-- 10.05.2010 Vilko; MID 23928 - fixed residual calculation for frame type = 'DOB' - payment based on input invoice is exluded from calculation  
-- 19.05.2010 Ziga; MID 25373 - used view gv_GetDateNow intead of function getdate() according to compatibility problem with SQL Server 2000  
-- 09.06.2011 Jasna; MID 30113 - added new frame type called RRE (Retail Risk Exposure)  
-- 02.11.2011 Vilko; Bug ID 29057 - fixed residual calculation for frame types 'NET' and 'POG' - also closed contracts should reduce frame availability   
-- 23.11.2011 Jasna; MID 30918 - added new frame type mix of REV for DDV and NET for other claims  
-- 26.01.2012 Jasna; BUG 29227 - fix status_placila condition in RRE frame  
-- 06.02.2012 Jasna; BUG ID 29256  - fix exchange part for RRE frame type  
-- 28.03.2012 Ziga; MID 34209 - modified calculation of obligo for frame type RFO - future interests tax is excluded  
-- 09.07.2012 Igor&Jasna; MID 35714 - added condition that supplier is not auto dealer (kategorija3 = 'DA')- frame type RRE  
-- 24.05.2013 Jelena; MID 40473 - for frame_type = 'DOB', type of payments processed (P - procesirano) is now considered into using of frame  
-- 10.03.2014 Jelena; MID 43659 - supported new frame_type DBA  
-- 11.04.2014 Jelena; MID 43659 - split code for frame type DBA, and modified code for frame type DOB  
-- 11.04.2014 Jelena; MID 43659 - modified code for frame type DOB  
-- 30.05.2014 IgorS; Task ID 8109 - added function gfn_VrValToBrutoInternal for vr_bruto  
-- 04.06.2014 IgorS & MatjažS; Task ID 8109 - added robresti for obligo calculation for frame type REV  
-- 05.08.2014 Jelena; Bug ID 31011 - modified code for frame type DBA - adedd join to id_frame  
-- 18.06.2015 Jure; Bug 31753 - Added call of dbo.gfn_SummitPlacIzhData()  
-- 11.09.2015 Jure & Nataša ; BUG 31845 - Correction off RRE frame calculation  
-- 06.01.2015 Jelena; MID 53439 - added option for je_krovni_okvir  
-- 27.01.2016 Jelena; MID 53439 - refactoring due to the introduction of the collection; gfn_GetFrameResidualNotCollection is the same as old gfn_GetFrameResidual  
----------------------------------------------------------------------------------------------------------------  
CREATE              FUNCTION [dbo].[gfn_GetFrameResidual] (  
    @id_frame int,  
    @id_cont int,  
    @ResultCurrency char(3),  
    @ExRateDate datetime  
)    
RETURNS decimal(18,2)   
AS    
BEGIN   
  
    DECLARE @r decimal(18,2), @is_collection_frame bit  
  
    SET @is_collection_frame= (SELECT CASE WHEN id_parent is not null THEN 1 ElSE 0 END FROM dbo.frame_list WHERE id_frame = @id_frame)  
   
 -- navaden okvir  
 IF @is_collection_frame = 0   
  SET @r = (SELECT dbo.gfn_GetFrameResidualNotCollection(@id_frame, @id_cont, @ResultCurrency, @ExRateDate))  
 ELSE   
  -- krovni okvir  
  SET @r = (SELECT dbo.gfn_GetFrameResidualCollectionChild(@id_frame, @id_cont, @ResultCurrency, @ExRateDate))  
  
    RETURN ISNULL(@r, 0)  
    
END  

----------------------------------------------------------------------------------------------------------------  
-- Returns residual value of approved value and used frame on date ExRateDate in currency ResultCurrency  
--  
-- PARAMETERS:   
--   id_frame - frame id that the residual value is calculated for (can be null)  
--   id_cont - contract id which should be left out by calculation (null - insert, !null - update)  
--   ResultCurrency - the currency in which the calculated value is returned  
--   ExRateDate - date of exchange rate  
  
-- History:  
-- 18.05.2005 Vilko; created  
-- 05.08.2005 Vilko; modified condition - by residual calculation should be considered only unclosed contracts  
-- 05.08.2005 Matjaz; moved condition from join into where  
-- 19.08.2005 Vilko; returned conditon back into join - in where clause it doesn't work properly  
-- 17.01.2006 Vilko; added residual calculation for revolving frames  
-- 11.12.2006 Vilko; Maintenance ID 3722 - added residual calculation for frame type = 'NET' and 'DOB'  
-- 14.02.2008 Jasna; MID 13571 - fixed bug, case when @id_cont is null  
-- 30.07.2008 Jure; TASK 5282 - Supported new frame type for stock management "ZAL"  
-- 22.10.2008 Matjaz; TASK 5282 - fixed id_tec for frame data in case of frame_type = 'ZAL'. Amounts are allways in native currency.  
-- 31.03.2009 Vilko; MID 20096 - fixed residual calculation for frame type = 'DOB' - function returned 0 if there were no payments  
-- 24.04.2009 Vilko; MID 20449 - fixed residual calculation for frame type = 'DOB' - now are also included partialy activated contracts  
-- 24.04.2009 Vilko; MID 20096 - fixed residual calculation for frame type = 'REV' - in obligo are now inlcuded ALL dued not paid claims - before only LOBR  
-- 16.02.2010 Ziga; MID 23659 - modified frame residual for frame types 'NET' and 'POG' - net_nal_zac and vr_val_zac is used instead of net_nal and vr_val  
-- 12.04.2010 Ziga; MID 24705 - added new frame type for Summit Ford with frame_type code = 'RFO'  
-- 04.05.2010 Ziga; MID 25145 - repaired obligo for frame type REV and RFO for active contracts that do not exists in planp_ds (all claims are closed), obligo for such contracts is 0.  
-- 10.05.2010 Vilko; MID 23928 - fixed residual calculation for frame type = 'DOB' - payment based on input invoice is exluded from calculation  
-- 19.05.2010 Ziga; MID 25373 - used view gv_GetDateNow intead of function getdate() according to compatibility problem with SQL Server 2000  
-- 09.06.2011 Jasna; MID 30113 - added new frame type called RRE (Retail Risk Exposure)  
-- 02.11.2011 Vilko; Bug ID 29057 - fixed residual calculation for frame types 'NET' and 'POG' - also closed contracts should reduce frame availability   
-- 23.11.2011 Jasna; MID 30918 - added new frame type mix of REV for DDV and NET for other claims  
-- 26.01.2012 Jasna; BUG 29227 - fix status_placila condition in RRE frame  
-- 06.02.2012 Jasna; BUG ID 29256  - fix exchange part for RRE frame type  
-- 28.03.2012 Ziga; MID 34209 - modified calculation of obligo for frame type RFO - future interests tax is excluded  
-- 09.07.2012 Igor&Jasna; MID 35714 - added condition that supplier is not auto dealer (kategorija3 = 'DA')- frame type RRE  
-- 24.05.2013 Jelena; MID 40473 - for frame_type = 'DOB', type of payments processed (P - procesirano) is now considered into using of frame  
-- 10.03.2014 Jelena; MID 43659 - supported new frame_type DBA  
-- 11.04.2014 Jelena; MID 43659 - split code for frame type DBA, and modified code for frame type DOB  
-- 11.04.2014 Jelena; MID 43659 - modified code for frame type DOB  
-- 30.05.2014 IgorS; Task ID 8109 - added function gfn_VrValToBrutoInternal for vr_bruto  
-- 04.06.2014 IgorS & MatjažS; Task ID 8109 - added robresti for obligo calculation for frame type REV  
-- 05.08.2014 Jelena; Bug ID 31011 - modified code for frame type DBA - adedd join to id_frame  
-- 18.06.2015 Jure; Bug 31753 - Added call of dbo.gfn_SummitPlacIzhData()  
-- 11.09.2015 Jure & Nataša ; BUG 31845 - Correction off RRE frame calculation  
-- 06.01.2015 Jelena; MID 53439 - added option for je_krovni_okvir  
-- 27.01.2016 Jelena; MID 53439 - gfn_GetFrameResidualNotCollection is the same as old gfn_GetFrameResidual; is calling from gfn_GetFrameResidual; for ordinary frames  
-- 14.07.2016 MatjazB; Task 9514 - use gv_FrameList instead of table frame_list  
-- 19.07.2016 Blaz; TID 9518 - added a join to stock funding orders and added znesek_narocila to SUM when frame 'REV'  
-- 21.12.2016 Matjaz; T9836 - bugfix to interpret stock_funding_orders correctly  
-- 02.02.2017 Blaz; BUG 32908 - corrected the REV calculation  
-- 15.02.2018 Jelena; MID 69420 - added case for new frame type 'MPC'  
-- 05.03.2018 Jelena; BID 33622 - because pogodba.MPC is in domestic currency, added exchanged from domestic currency to contract currency  
-- 09.04.2018 Jelena; TID 12921 - GDPR - added param into gfn_SummitPlacIzhData  
-- 08.04.2022 Thor; TID 23760 - added reservations from gv_frame_reservations_active  
----------------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_GetFrameResidualNotCollection] (  
    @id_frame int,  
    @id_cont int,  
    @ResultCurrency char(3),  
    @ExRateDate datetime  
)    
RETURNS decimal(18,2)   
AS    
BEGIN   
    DECLARE @r decimal(18,2), @sif_frame_type char(3), @now datetime, @id_frame_type int  
  
 SET @now = (SELECT GetDateNow FROM dbo.gv_GetDateNow)  
  
    SET @sif_frame_type = (SELECT T.sif_frame_type FROM dbo.frame_list F INNER JOIN dbo.frame_type T ON F.frame_type = T.id_frame_type WHERE F.id_frame = @id_frame)  
   
    IF @sif_frame_type = 'POG'  
     SET @r = (  
  SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) -  
         SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(P.vr_val_zac, 0), P.id_tec, @ExRateDate))  
    FROM dbo.gv_FrameList F  
    LEFT JOIN dbo.frame_pogodba FP ON F.id_frame = FP.id_frame  
    LEFT JOIN dbo.pogodba P ON FP.id_cont = P.id_cont AND (@id_cont IS NULL OR P.id_cont != @id_cont)  
   WHERE F.id_frame = @id_frame  
   GROUP BY F.id_frame, F.id_tec, F.znesek_val  
     )  
  
    ELSE IF @sif_frame_type = 'NET'  
     SET @r = (  
  SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) -  
         SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(P.net_nal_zac, 0), P.id_tec, @ExRateDate))  
    FROM dbo.gv_FrameList F  
    LEFT JOIN dbo.frame_pogodba FP ON F.id_frame = FP.id_frame  
    LEFT JOIN dbo.pogodba P ON FP.id_cont = P.id_cont AND (@id_cont IS NULL OR P.id_cont != @id_cont)  
   WHERE F.id_frame = @id_frame  
   GROUP BY F.id_frame, F.id_tec, F.znesek_val  
     )  
  
 ELSE IF @sif_frame_type = 'MPC'  
     SET @r = (  
  SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) -  
         SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(P.MPC, 0), '000', @ExRateDate))  
    FROM dbo.gv_FrameList F  
    LEFT JOIN dbo.frame_pogodba FP ON F.id_frame = FP.id_frame  
    LEFT JOIN dbo.pogodba P ON FP.id_cont = P.id_cont AND (@id_cont IS NULL OR P.id_cont != @id_cont)  
   WHERE F.id_frame = @id_frame  
   GROUP BY F.id_frame, F.id_tec, F.znesek_val  
     )  
  
    ELSE IF @sif_frame_type = 'REV'  
     SET @r = (  
  SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) -  
         SUM(dbo.gfn_XChange(  
     @ResultCurrency,   
     ISNULL(  
      ISNULL(  
       O.obligo,   
       CASE WHEN P.status_akt in ('D', 'N') THEN  P.vr_val - P.varscina ELSE 0 END  
      ), 0   
     ) + ISNULL(FP.znesek_narocila, 0),  
     ISNULL(O.id_tec, isnull(P.id_tec, '000')),   
     @ExRateDate))  
    FROM dbo.gv_FrameList F  
    LEFT JOIN (  
                     select id_frame, id_cont, status, null as znesek_narocila from dbo.frame_pogodba  
                     UNION ALL  
                     select id_frame, null as id_cont, 'A' as status, znesek_narocila from dbo.gv_Stock_fund_orders_reducing_frames  
      UNION ALL  
                     select id_frame, null as id_cont, 'A' as status, amount as znesek_narocila from dbo.gv_frame_reservations_active  
              ) FP ON F.id_frame = FP.id_frame  
    LEFT JOIN dbo.pogodba P ON FP.id_cont = P.id_cont AND (@id_cont IS NULL OR P.id_cont != @id_cont) AND P.status_akt != 'Z'  
    LEFT JOIN (SELECT pp.id_cont, pp.id_kupca, pp.id_tec,   
       SUM(pp.znp_saldo_brut_all + pp.bod_neto_lpod + CASE WHEN nl.tip_knjizenja = '2' and nl.ol_na_nacin_fl = 0 THEN pp.bod_davek_lpod ELSE 0 END + CASE WHEN nl.ima_robresti = 1 THEN pp.bod_robresti_lpod ELSE 0 END) AS obligo  
                 FROM dbo.planp_ds pp  
        INNER JOIN dbo.pogodba po ON po.id_cont = pp.id_cont  
        INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = po.nacin_leas  
        INNER JOIN dbo.dav_stop ds ON ds.id_dav_st = po.id_dav_st  
        GROUP BY pp.id_cont, pp.id_kupca, pp.id_tec) O ON P.id_cont = O.id_cont AND P.id_kupca = O.id_kupca  
   WHERE F.id_frame = @id_frame  
   GROUP BY F.id_frame, F.id_tec, F.znesek_val  
     )  
  
    ELSE IF @sif_frame_type = 'DOB'  
     SET @r = (  
  SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) -  
         SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(P.znesek_dom, 0), P.id_tec, @ExRateDate))  
    FROM dbo.gv_FrameList F  
          LEFT JOIN (SELECT P.id_dob, P.znesek_dom, P.id_tec  
                       FROM dbo.plac_izh P  
                      INNER JOIN dbo.plac_izh_tip T ON P.id_plac_izh_tip = T.id_plac_izh_tip  
                      INNER JOIN dbo.pogodba C ON P.id_cont = C.id_cont  
                      WHERE P.id_vrste = 1   
                        AND P.status_placila IN ('V', 'E', 'A', 'S', 'P')  
                        AND C.status_akt IN ('N', 'D')  
                        AND T.p1_je_racun = 0  
      AND P.id_frame is NULL) P ON F.id_kupca = P.id_dob  
   WHERE F.id_frame = @id_frame  
   GROUP BY F.id_frame, F.id_tec, F.znesek_val  
     )  
  
    ELSE IF @sif_frame_type = 'DBA'  
     SET @r = (  
  SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) -  
         SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(P.znesek_dom, 0), P.id_tec, @ExRateDate))  
    FROM dbo.gv_FrameList F  
          LEFT JOIN (SELECT P.id_dob, P.znesek_dom, P.id_tec, p.id_frame   
                       FROM dbo.plac_izh P  
                      INNER JOIN dbo.plac_izh_tip T ON P.id_plac_izh_tip = T.id_plac_izh_tip  
                      INNER JOIN dbo.pogodba C ON P.id_cont = C.id_cont  
       INNER JOIN dbo.gv_FrameList f ON f.id_frame = P.id_frame  
       INNER JOIN dbo.frame_type ft ON ft.id_frame_type = f.frame_type  
                      WHERE P.id_vrste = 1   
                        AND P.status_placila IN ('V', 'E', 'A', 'S', 'P')  
                        AND T.p1_je_racun = 0  
      AND  ft.sif_frame_type = @sif_frame_type) P ON F.id_kupca = P.id_dob and p.id_frame = f.id_frame  
   WHERE F.id_frame = @id_frame  
   GROUP BY F.id_frame, F.id_tec, F.znesek_val  
     )  
  
 ELSE IF @sif_frame_type = 'ZAL'  
     SET @r = (  
   SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) -   
       SUM(ISNULL(dbo.gfn_XChange(@ResultCurrency, ISNULL(O.kredit,0) - ISNULL(O.debit, 0), '000', @ExRateDate),0))  
     FROM dbo.gv_FrameList as F  
     LEFT JOIN dbo.gfn_stk_get_frame_consument() as O ON F.id_frame = O.id_frame  
    WHERE F.id_frame = @id_frame  
    GROUP BY F.id_frame,F.id_tec, F.znesek_val  
     )  
  
 ELSE IF @sif_frame_type = 'RFO'  
     SET @r = (  
  SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) -  
         SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(ISNULL(O1.obligo, case when P.status_akt = 'Z' or (P.status_akt = 'A' and datediff(dd, P.dat_aktiv, @now) > 5) then 0 else dbo.gfn_VrValToBrutoInternal(p.vr_val, p.robresti_val, ds.davek, nl.ima_robrest
i, nl.dav_b, nl.finbruto, nl.dav_n) + P.man_str + P.stroski_x + P.stroski_pz + P.stroski_zt + P.zav_fin + P.str_financ end), 0), ISNULL(O1.id_tec, P.id_tec), @ExRateDate))  
    FROM dbo.gv_FrameList F  
    LEFT JOIN dbo.frame_pogodba FP ON F.id_frame = FP.id_frame  
    LEFT JOIN dbo.pogodba P ON FP.id_cont = P.id_cont AND (@id_cont IS NULL OR P.id_cont != @id_cont) AND P.status_akt != 'Z'  
    LEFT JOIN (SELECT pp.id_cont, pp.id_kupca, pp.id_tec,  
       -- obligo: zapadlo neplacano + bruto bodoci dolg - bodoce obresti  
       SUM(pp.znp_saldo_brut_all + pp.bod_debit_brut_ALL - pp.bod_obresti_LPOD - case when nl.dav_o = 'D' then pp.bod_obresti_LPOD * (ds.davek / 100) else 0 end) AS obligo  
                 FROM dbo.planp_ds pp  
        INNER JOIN dbo.pogodba p on p.id_cont = pp.id_cont  
        INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = p.nacin_leas  
        INNER JOIN dbo.dav_stop ds ON ds.id_dav_st = p.id_dav_st  
                GROUP BY pp.id_cont, pp.id_kupca, pp.id_tec) O1  
      ON P.id_cont = O1.id_cont AND P.id_kupca = O1.id_kupca  
   LEFT JOIN dbo.nacini_l nl on nl.nacin_leas = P.nacin_leas  
   LEFT JOIN dbo.dav_stop ds on ds.id_dav_st = P.id_dav_st  
   WHERE F.id_frame = @id_frame  
   GROUP BY F.id_frame, F.id_tec, F.znesek_val  
     )  
       
    ELSE IF @sif_frame_type = 'RRE'  
     SET @r = (  
  SELECT   
   dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate) - isnull(pl.znesek_in_ResultCurrency, 0)  
  FROM   
   dbo.gv_FrameList F  
   outer apply (select   
       SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(znesek_dom, 0), '000', @ExRateDate)) as znesek_in_ResultCurrency   
       from   
       dbo.gfn_SummitPlacIzhData(0, null)   
       where   
       id_frame = @id_frame) as pl  
  WHERE   
   F.id_frame = @id_frame  
     )  
 ELSE IF @sif_frame_type = 'RNE'  
     SET @r = (  
   SELECT dbo.gfn_XChange(@ResultCurrency, F.znesek_val, F.id_tec, @ExRateDate)   
   - (  
    SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(ISNULL(V.obligo, case when P.status_akt = 'Z'   
       or (P.status_akt = 'A' and datediff(dd, P.dat_aktiv, @now) > 5) then 0 else P.DDV end), 0)  
       , ISNULL(V.id_tec, P.id_tec), @ExRateDate))  
    +  
          SUM(dbo.gfn_XChange(@ResultCurrency, ISNULL(P.net_nal_zac, 0), P.id_tec, @ExRateDate))  
        )  
    FROM dbo.gv_FrameList F  
    LEFT JOIN dbo.frame_pogodba FP   
      ON F.id_frame = FP.id_frame  
    LEFT JOIN dbo.pogodba P   
      ON FP.id_cont = P.id_cont AND (@id_cont IS NULL OR P.id_cont != @id_cont) AND P.status_akt != 'Z'  
    LEFT JOIN   
    ( SELECT id_cont, id_kupca, id_tec, SUM(znp_saldo_ddv + bod_davek_lpod) AS obligo  
   FROM dbo.planp_ds  
   GROUP BY id_cont, id_kupca, id_tec  
     ) V ON P.id_cont = V.id_cont AND P.id_kupca = V.id_kupca  
    LEFT JOIN dbo.nacini_l nl on nl.nacin_leas = P.nacin_leas  
    WHERE F.id_frame = @id_frame  
    -- ostale pogodbe tega partnerja če obstajajo oz. is null v primeru ko gre za prvo pogodbo partnerja  
    AND (nl.ddv_takoj = 1 OR nl.ddv_takoj is null)   
    GROUP BY F.id_frame, F.id_tec, F.znesek_val)  
  
    RETURN ISNULL(@r, 0)  
END  
  
  