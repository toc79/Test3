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
-- 09.08.2022 Jelena; BID 39615 - v OUTER APPLY added TOP 1 and ORDER BY y.zap_obr - 2 record were being prepared for the contract, which had only 1 future installment and redemption (which is also LOBR claim), with the same datum_dok  
-- 06.02.2023 Jadranka; BUG 39817 - support for conformal interest calculation (konformni izračun)  
-- 06.11.2023 MatjazB; TID 27672 - added check for max IR  
------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[grp_RepIndChangeView]  
AS  
BEGIN  
 declare   
  @target_date datetime,  
  @toleranca_za_obresti decimal(18,2),  
  @min_obresti decimal(18,2),  
  @id_terj_lobr char(2)  
  
 set @target_date = dbo.gfn_getdatepart(getdate())  
    select top 1 @toleranca_za_obresti = rpgi_interests_min, @min_obresti = repidx_future_interests from dbo.loc_nast  
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
   when a.id_tiprep = 2 and a.installment_credit = 0 then nobr.nov_obrok  
   when a.installment_credit = 1 then isnull(pp.next_installment, 0)  
   else 0  
  end as nov_obrok_bruto,  
  a.id_rind_strategije,  
  case   
            when a.fix_dat_rpg = 1 and a.installment_credit = 0   
                 and b.je_nk = 0   
                 and iobr.znesek <= @toleranca_za_obresti / cast(x.st_obrok as decimal(18,2))  
       then cast(1 as bit)  
   else cast(0 as bit)  
  end as only_update_rind_dat_next,   
        b.je_nk  
 from   
  dbo.gv_RepIndCandidatesPresentation as a   
  inner join dbo.pogodba b on a.id_cont = b.id_cont   
  inner join dbo.obdobja c on b.id_obd = c.id_obd  
  inner join dbo.nacini_l d on b.nacin_leas = d.nacin_leas  
  inner join dbo.dav_stop e on b.id_dav_st = e.id_dav_st  
  cross apply dbo.gfn_GetDataForReprogram(a.id_cont, @target_date) as x  
  outer apply   
  (  
   select top 1   
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
            order by y.zap_obr    
  ) pp  
        cross apply (select dbo.gfn_IzracunObroka(   
          x.neto_lobr_opc,   
          x.regist,    
          x.opcija,   
          case when a.max_ir_used = 1 then 0 else a.indeks end,  
          case when a.max_ir_used = 1 then a.max_allowedIR else b.fix_del end,  
          c.obnaleto,  
          x.st_obrok,  
          d.tip_knjizenja,  
          b.dobrocno,  
          b.id_dav_st,  
          e.davek,  
          case when a.max_ir_used = 1 then 0 else a.obnaleto_rtip end,  
          x.robresti,  
          d.ol_na_nacin_fl,  
          d.tip_izracuna_robresti,  
          d.tip_om) as nov_obrok  
        ) nobr  
        cross apply dbo.gfn_xchange_table('000', ABS((nobr.nov_obrok - isnull(pp.next_installment, 0))), b.id_tec,  @target_date) iobr  
          
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
END  