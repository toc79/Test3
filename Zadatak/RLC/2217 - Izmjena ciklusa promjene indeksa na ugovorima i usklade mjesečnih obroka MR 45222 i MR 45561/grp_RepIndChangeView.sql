------------------------------------------------------------------------------------------------------------  
-- HISTORY:  
-- [GMI_GENERATE_DATA_WRAPPER]  
--  
-- 24.10.2014 Jure; Task 8293 - Created  
-- 06.01.2015 Jure; Task 8293 - Excluded condition of calculation installment for case when contract use reprograming with strategy  
-- 19.02.2015 Jure; MID 49719 - Izračun obroka se mora zgoditi, kadar gre za id_tiprep = 2  
-- 16.04.2015 Jure; TASK 8629 - Added support for installment credit  
-- 21.01.2016 Jure; BUG 32184 - Za obročne kredite ne gledemo pogoja x.st_obrok > 0  
-- 17.05.2016 MID 54410 - Jure&Strko; Added support for PPMV  
-- 31.08.2016 Jure; MID on-the-fly; Added condition x.neto_lobr_opc > 0 za primere, ki niso obročni krediti  
-- 04.10.2016 Jure; MID XXXXX; Optimization of procedure  
-- 03.04.2017 Jure; MID 61560; Instead of pogodba.obrok1 is now calculated field isnull(pp.next_installment, 0)  
-- 30.01.2018 Josip; MID 71405 - added support for ol_na_nacin_fl  
-- 31.07.2018 KlemenV; MID 67595 - added support for tip_izracuna_robresti  
-- 03.12.2018 MatjazB; Task 14943 - changes due to je_nk = 1  
------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[grp_RepIndChangeView]  
AS  
 declare   
  @target_date datetime,  
  @toleranca_za_obresti decimal(18,2),  
  @min_obresti decimal(18,2),  
  @id_terj_lobr char(2)  
  
 set @target_date = dbo.gfn_getdatepart(getdate())  
 set @toleranca_za_obresti = (select top 1 rpgi_interests_min from dbo.loc_nast)  
 set @min_obresti =  (SELECT repidx_future_interests FROM dbo.loc_nast)  
 set @id_terj_lobr = (select id_terj from dbo.vrst_ter where sif_terj = 'LOBR')  
   
 select   
  a.oznacen,  
  a.id_cont,  
  a.id_pog,  
  a.id_kupca,  
  a.naz_kr_kup,  
  a.id_rtip,  
  a.rind_datum,  
  a.datum,  
  a.indeks,  
  a.rind_zadnji,  
  a.sprememba,  
  a.rind_tgor,  
  a.rind_zahte,  
  a.id_tiprep,  
  a.beg_end,  
  a.faktor,  
  a.obr_mera,  
  a.obr_merak,  
  a.fix_del,  
  a.id_strm,  
  a.dat_sklen,  
  a.kon_naj,  
  a.vr_osebe,  
  a.nacin_leas,  
  a.rind_dat_next,  
  a.rind_dat_next_new,  
  a.indeks_na_dan,  
  a.fix_dat_rpg,  
  case  
            when b.je_nk = 1 then null  
            else isnull(pp.next_installment, 0)  
        end as obrok_bruto,  
  case   
            when b.je_nk = 1 then null  
   when a.id_tiprep = 2 and a.installment_credit = 0 then   
    dbo.gfn_IzracunObroka(  
     x.neto_lobr_opc,   
     x.regist,   
     x.opcija,   
     a.indeks,  
     b.fix_del,   
     c.obnaleto,  
     x.st_obrok,   
     d.tip_knjizenja,  
     b.dobrocno,  
     b.id_dav_st,  
     e.davek,  
     a.obnaleto_rtip,  
     x.robresti,  
     d.ol_na_nacin_fl,  
     d.tip_izracuna_robresti)  
   when a.installment_credit = 1 then isnull(pp.next_installment, 0)  
   else 0  
  end as nov_obrok_bruto,  
  a.id_rind_strategije,  
  case   
            when a.fix_dat_rpg = 1 and a.installment_credit = 0 and b.je_nk = 0 and dbo.gfn_xchange('000', ABS((dbo.gfn_IzracunObroka(   
          x.neto_lobr_opc,   
          x.regist,    
          x.opcija,   
          a.indeks,  
          b.fix_del,   
          c.obnaleto,  
          x.st_obrok,   
          d.tip_knjizenja,  
          b.dobrocno,  
          b.id_dav_st,  
          e.davek,  
          a.obnaleto_rtip,  
          x.robresti,  
          d.ol_na_nacin_fl,  
          d.tip_izracuna_robresti) -  isnull(pp.next_installment, 0))), b.id_tec,  @target_date) <= @toleranca_za_obresti / cast(x.st_obrok as decimal(18,2))  
       then cast(1 as bit)  
   else cast(0 as bit)  
  end as only_update_rind_dat_next,   
        b.je_nk   
 from   
  dbo.gv_RepIndCandidatesPresentation as a   
  inner join pogodba b on a.id_cont=b.id_cont   
  inner join obdobja c on b.id_obd=c.id_obd  
  inner join nacini_l d on b.nacin_leas=d.nacin_leas  
  inner join dav_stop e on b.id_dav_st=e.id_dav_st  
  cross apply dbo.gfn_GetDataForReprogram(a.id_cont, @target_date) as x  
  outer apply   
  (  
   select   
    y.DEBIT as next_installment  
   from   
    dbo.planp as y  
    inner join   
    (  
     select   
      min(datum_dok) as datum_dok  
     from   
      dbo.planp as yx   
     where   
      x.st_obrok > 0 and  
      yx.id_cont = a.id_cont and   
      yx.datum_dok > @target_date and   
      yx.ID_TERJ = @id_terj_lobr   
    ) as ppx on y.ID_CONT = a.id_cont and y.DATUM_DOK = ppx.datum_dok and y.ID_TERJ = @id_terj_lobr         
  ) pp  
  cross apply dbo.gfn_xchange_table('000', ABS((dbo.gfn_IzracunObroka(   
          x.neto_lobr_opc,   
          x.regist,    
          x.opcija,   
          a.indeks,  
          b.fix_del,  
          c.obnaleto,  
          x.st_obrok,  
          d.tip_knjizenja,  
          b.dobrocno,  
          b.id_dav_st,  
          e.davek,  
          a.obnaleto_rtip,  
          x.robresti,  
          d.ol_na_nacin_fl,  
          d.tip_izracuna_robresti) - isnull(pp.next_installment, 0))), b.id_tec,  @target_date) iobr  
    where  
        a.installment_credit = 1   
        or   
        (  
            x.st_obrok > 0 and x.neto_lobr_opc > 0 -- mora imeti najmanj en obrok do konca financiranja, razen v primeru KO - obročni kredit  
            and (x.bod_obresti_lpod > @min_obresti) OR a.id_tiprep != 2 -- minimalne trenutne obresti za katere še naredim reprogram  
        )   
        and    
        (  
            a.fix_dat_rpg = 1 -- za primere kadar pogodba uporablja reprogramiranje s strategijo, potem izpustimo preverjanje obroka  
            or b.je_nk = 1 -- za NK izpustimo preverjanje obroka  
            or (iobr.znesek > case when x.st_obrok = 0 then 0 else @toleranca_za_obresti / cast(x.st_obrok as decimal(18,2)) end)  
        )  
  
  
  /*----------------------------------------------------------------------------------------------------------------------------------  
 History:  
 12.11.2004 Matjaz; created  
 29.11.2004 Matjaz; removed comment for rind_faktor  
 02.06.2006 Vilko; added fields p.obr_mera, p.fix_del, p.id_strm  
 09.11.2006 Vilko; Maintenance ID 4648 - added fields p.dat_sklen and p.kon_naj  
 24.02.2010 IgorS; Bug ID 28203 - added column vr_osebe to the select list  
 22.11.2010 Jasna; MID 27231 - added check gfn_ContractCanRpgInd  
 11.03.2011 Jasna; MID 29163 - added round for p.indeks  
 13.08.2014 MID 45172 - Jure; Changed dat_ind instead of getdate() into datum field, also added rind_dat_next  
 Returns all contracts that are candidates for reprogram due to index   
 change for presentation side  
 02.10.2014 Bug ID 30587 - Jelena; added field fix_dat_rpg  
 24.10.2014 Jure; Task 8293 - Added obnaleto_rtip field  
 19.01.2015 Jure; Added rind_dat_next_new  
 16.04.2015 Jure; TASK 8629 - Added support for installment credit  
 04.10.2016 Jure; MID XXXXX - Optimization of view  
----------------------------------------------------------------------------------------------------------------------------------  
 pogodba nima ustavljen reprogram zaradi spremembe index-a*/  
  
CREATE VIEW [dbo].[gv_RepIndCandidatesPresentation]  
AS  
SELECT       
 CAST(0 AS bit) AS oznacen, p.id_cont, p.id_pog, p.id_kupca, a.naz_kr_kup, p.id_rtip, p.rind_datum, dat_ind AS datum, p.indeks * 100 AS indeks,   
    CASE WHEN p.id_tiprep <> 1 THEN p.rind_zadnji ELSE 0 END AS rind_zadnji, CASE WHEN p.id_tiprep <> 1 THEN round(p.indeks * 100, 4)   
    - p.rind_zadnji ELSE p.rind_zadnji END AS sprememba, p.rind_tgor, p.rind_zahte, p.id_tiprep, p.beg_end,   
    CASE WHEN p.id_tiprep = 1 THEN CAST(p.rind_faktor AS char(5)) ELSE '' END AS faktor, p.obr_mera, p.fix_del, p.id_strm, p.dat_sklen, p.kon_naj, a.vr_osebe,   
    p.nacin_leas, p.rind_dat_next, p.indeks_na_dan, p.fix_dat_rpg, p.obnaleto_rtip, p.id_rind_strategije, p.rind_dat_next_new, p.installment_credit,   
 p.obr_merak, p.obrok1  
FROM           
 dbo.gv_RepIndCandidates AS p INNER JOIN  
    dbo.PARTNER AS a ON a.id_kupca = p.id_kupca  
	
	
------------------------------------------------------------------------------------------------------------------------------------  
-- Returns all contracts that are candidates for reprogram due to index change  
-- History:  
-- ????????? Matjaz; created  
-- 22.03.2004 Matjaz; Changes due to id_cont 2 PK transition  
-- 08.11.2004 Matjaz; added columns p.opcija, p.opc_imaobr, p.dva_pp  
-- 08.11.2004 Matjaz; added column po_tecaju and removed join on tecajnic  
-- 08.11.2004 Matjaz; removed column datum  
-- 09.11.2004 Matjaz; added columns disk_r, opc_datzad, nacin_ms, dat_kkf, ddv_id  
-- 10.11.2004 Matjaz; added condition for id_tiprep = 1, added dej_obr  
-- 12.11.2004 Matjaz; removed column oznacen  
-- 15.11.2004 Matjaz; added columns dav_obv, dav_stev, name_and_address, id_obrs  
-- 26.11.2004 Matjaz; removed din_ind and din_pog  
-- 26.11.2004 Matjaz; added condition for id_tiprep=1 that summary factor has to be different than 0  
-- 29.11.2004 Matjaz; added rind_faktor  
-- 23.01.2005 Vik; added pred_ddv  
-- 25.01.2005 Matjaz; added obindnaleto  
-- 09.02.2006 Matjaz; changed condition for index change from >= to >  
-- 02.06.2006 Vilko; added field p.id_strm  
-- 18.07.2006 Vilko; added condition for future interests, which should be greater then setting  
-- 07.09.2006 Vilko; fixed null value for field bod_obresti_lpod  
-- 09.11.2006 Vilko; Maintenance ID 4648 - added fields p.dat_sklen and p.kon_naj  
-- 26.03.2007 MatjazB; Maintenance ID 6674 - added condition for id_tiprep = 4  
-- 22.06.2007 Vilko; Bug ID 26692 - added case switch due problems with query execution on SQL 2005  
-- 05.02.2008 Ziga; Bug ID 13152 - added condition for bod_cnt_lobr > 0 if id_tip_rep <> 2  
-- 11.03.2011 Jasna; MID 29163 - added round for l.indeks  
-- 31.08.2011 TASK 6401 - Jure; Added support for new calcalation type of installments (tip_om)  
-- 13.08.2014 MID 45172 - Jure; Added support for strategy r.fix_dat_rpg of reprogramming (index change => id_rtip = 2)  
-- 09.09.2014 MID 45172 - Jure; Tweaking - Added call of function gfn_RindStrat_GetNewIndexDate to choose right index date  
-- 02.10.2014 Bug ID 30587 - Jelena; completed indeks_na_dan and added field fix_dat_rpg  
-- 24.10.2014 Jure; Task 8293 - Added obnaleto_rtip field  
-- 19.01.2015 Jure; Added call of function dbo.gfn_RindStrat_GetCurrentNextRpgDate when calculating rind_dat_next  
-- 16.04.2015 Jure; TASK 8629 - Added support for installment credit  
-- 04.12.2015 Jure; TASK 9130 - Changed inner join to left join on table planp_ds  
-- 05.04.2016 Jure; BUG 32176 - Added bod_cnt_lobr field  
-- 05.04.2016 Jure; BUG 32176 - Correction of show only installment credit candidates  
-- 04.10.2016 Jure; MID XXXXX - Optimization of view  
-- 02.01.2017 Jure; MID 60970 - Corection of condition rep_spr_ind  
-- 19.09.2018 MatjazB; Task 14660 - added p.je_nk  
-- 17.03.2020 MitjaM; BID 38037 - changed format for opiskup  
------------------------------------------------------------------------------------------------------------------------------------  
  
CREATE VIEW [dbo].[gv_RepIndCandidates]  
AS  
SELECT   
 p.id_cont,   
 p.id_pog,   
 p.id_kupca,   
 p.id_rtip,   
 CASE WHEN r.id_tiprep = 1   
  THEN dbo.gfn_GetSumIndexFromGivenDate(p.id_rtip, p.rind_datum)   
  ELSE p.rind_zadnji   
 END as rind_zadnji,   
 p.id_obd,   
 p.fix_del,   
 p.dobrocno,   
 p.id_val,   
 p.id_strm,  
 p.rind_datum,   
 case when p.id_rind_strategije is null then l.dat_ind else rv.datum end as dat_ind,   
 case when p.id_rind_strategije is null then l.indeks else rv.indeks/100 end as indeks,   
 p.obr_mera,   
 p.nacin_leas,  
 r.id_tiprep,   
 p.id_dav_st,   
 p.rind_faktor,   
 p.pred_ddv,  
 p.rind_tgor,   
 p.beg_end,   
 p.vr_prom,   
 l.obnaleto,   
 l.obindnaleto,   
 p.dej_obr,  
 p.id_dav_op,   
 p.rind_zahte,   
 p.id_tec,   
 p.po_tecaju,   
 p.opcija,   
 p.opc_imaobr,   
 p.dva_pp,   
 p.disk_r,   
 p.opc_datzad,   
 p.nacin_ms,   
 p.dat_kkf,   
 p.ddv_id,   
 p.id_obrs,  
 c.dav_obv,   
 c.dav_stev,  
 (c.naz_kr_kup + ', ' + c.ulica_sed + ', ' + c.id_poste_sed + ' ' + c.mesto_sed) as name_and_address,  
 p.dat_sklen,   
 p.kon_naj,   
 p.tip_om,  
 rs.odmik as rind_odmik,   
 rs.working_days as rind_working_days,   
 p.id_rind_strategije,   
 dbo.gfn_RindStrat_GetCurrentRindDatNext(p.rind_dat_next, p.ID_RTIP, 0) as rind_dat_next,  
 dbo.gfn_RindStrat_GetCurrentRindDatNext(p.rind_dat_next, p.ID_RTIP, 1) as rind_dat_next_new,  
 CASE   
  WHEN p.rind_dat_next is NULL and p.id_rind_strategije IS NULL THEN dbo.gfn_getDatePart(getdate())  
  ELSE dbo.gfn_RindStrat_GetNewIndexDate(dbo.gfn_RindStrat_GetCurrentRindDatNext(p.rind_dat_next, p.ID_RTIP, 0) , p.id_rind_strategije)  
 END as indeks_na_dan, -- !!! pove na kateri dan BI MORAL biti vnešen indeks !!!  
 r.fix_dat_rpg,  
 l.obindnaleto as obnaleto_rtip,  
 nl.installment_credit,  
 p.OBR_MERAK,  
 p.OBROK1,   
    p.je_nk   
FROM   
 dbo.pogodba p  
 INNER JOIN dbo.gv_LastIndexes l ON p.id_rtip = l.id_rtip  
 INNER JOIN dbo.rtip r ON p.id_rtip = r.id_rtip  
 INNER JOIN dbo.partner c ON p.id_kupca = c.id_kupca  
 LEFT JOIN dbo.RVRED as rv on p.id_rind_strategije is not null and   
         p.id_rtip = rv.id_rtip and   
         dbo.gfn_RindStrat_GetNewIndexDate(dbo.gfn_RindStrat_GetCurrentRindDatNext(p.rind_dat_next, p.ID_RTIP, 0) , p.id_rind_strategije) = rv.datum  
 LEFT JOIN dbo.RIND_STRATEGIJE as rs ON p.id_rind_strategije = rs.id_rind_strategije  
 inner join dbo.nacini_l as nl on p.NACIN_LEAS = nl.nacin_leas  
 left join dbo.pog_pos as ps on p.ID_CONT = ps.ID_CONT  
 WHERE   
 (CASE  
  -- pri revalorizaciji glavnice moramo pogledati,   
  -- ce zmnozek vseh indeksov od zadnjega reprograma presega toleranco in je vecji od 0  
  WHEN (r.id_tiprep = 1   
   AND ABS(dbo.gfn_GetSumIndexFromGivenDate(p.id_rtip, p.rind_datum)/100) >= ABS(p.rind_tgor)/100  
   AND ABS(dbo.gfn_GetSumIndexFromGivenDate(p.id_rtip, p.rind_datum)/100) > 0) THEN 1  
  -- pri verižnem indeksu primerjamo 2 indeksa med sabo  
  WHEN (r.id_tiprep = 4 AND ABS(round(l.indeks, 6)/(p.rind_zadnji/100)-1) > ABS(p.rind_tgor)/100) THEN 1  
  -- pri ostalih pa razliko med indeksom ob zadnjem reprogramu in trenutnim indeksom   
  WHEN (r.id_tiprep NOT IN (1,4) AND ((r.fix_dat_rpg = 0 AND ABS(round(l.indeks, 6) - p.rind_zadnji/100) > ABS(p.rind_tgor)/100) OR   
           (r.fix_dat_rpg = 1))) THEN 1  
  ELSE 0  
 END) = 1  
 -- ali smo že v novem obdobju plačevanja  
 AND ((r.fix_dat_rpg = 0 and (12*year(getdate()) + month(getdate())) - (12*year(p.rind_datum) + month(p.rind_datum)) >= (12/l.obnaleto)) OR   
   (r.fix_dat_rpg = 1 and p.rind_dat_next <= getdate()))  
 AND LTRIM(RTRIM(r.id_rtip)) <> '0' AND LTRIM(RTRIM(r.id_rtip)) <> '' -- samo za ustrezne tipe indeksov  
 -- TODO (ustavljenost pogodbe bo v statusu ali posebnostih pogodb - še ni dorečeno)  
 AND ps.KNJIZENJE is null  
 AND (ps.rep_spr_ind is null or ps.rep_spr_ind < dbo.gfn_getdatepart(GETDATE()))  
 AND p.status_akt = 'A' -- pogodba mora biti aktivna  
  
  
  ------------------------------------------------------------------------------------------------------------  
-- Function for getting appropriate index date for a given input date and reprogram strategy  
-- Spodaj je dogovor glede interpretacije polja rind_strategije.odmik:  
-- 1.) odmik = 0 --> indeks se vzame na @target_date  
-- 2.) odmik != 0 --> indeks se vzame na prvega v obdobju + stevilo dni iz polja odmik (Npr. 1 pomeni na prvi dan v mesecu, -1 pomeni na zadnji dan prejšnjega meseca, 27 pomeni na 27-eti dan v mesecu)  
--  
-- History:  
-- 08.09.2014 Jure; MID 45172 - Created  
-- 20.01.2015 Jure; TASK 8293 - Added support for last day in month  
------------------------------------------------------------------------------------------------------------  
CREATE function [dbo].[gfn_RindStrat_GetCurrentRindDatNext](@target_date datetime,  @id_rtip varchar(5), @next bit)  
returns datetime  
  
begin  
 if (isnull(@target_date, '19000101') = '19000101')  
  return null  
  
 declare @factor decimal(18,2), @today datetime, @last_day_in_month datetime, @is_last_day_in_month bit  
 set @today = dbo.gfn_getdatepart(getdate())  
 set @target_date = dbo.gfn_getdatepart(@target_date)  
 set @last_day_in_month = dbo.gfn_GetLastDayOfMonth(@target_date)  
   
 if (@last_day_in_month = @target_date)  
  set @is_last_day_in_month = 1  
 else  
  set @is_last_day_in_month = 0  
  
 select   
  @factor = 12.00 / b.obnaleto  
 from   
  dbo.rtip as a   
  inner join dbo.obdobja as b on a.id_obdrep = b.id_obd  
 where   
  a.id_rtip = @id_rtip  
  
 while(@target_date <= @today)   
 begin  
  set @target_date = DATEADD(mm, @factor, @target_date)  
 end  
  
 if (@next = 0) -- return current next_dat_rpg date (nearest closest to the current date --> pog_pos issue)  
  set @target_date = DATEADD(mm, -@factor, @target_date)  
   
 if (@is_last_day_in_month = 1)  
  return dbo.gfn_GetLastDayOfMonth(@target_date)  
   
 return @target_date  
end  