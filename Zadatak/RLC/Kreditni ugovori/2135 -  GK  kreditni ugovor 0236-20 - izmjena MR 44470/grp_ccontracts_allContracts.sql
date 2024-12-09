------------------------------------------------------------------------------------------------------------  
-- Procedure returns all credit contracts  
--  
-- History:  
-- 30.05.2006 Darko; created  
-- 27.02.2007 MatjazB; Bug ID 26448 - moved @par_contract_enabled from 1 to 6 (position) and @par_contract_contract 2 to 7  
-- 19.08.2008 MatjazB; Bug ID 27426 - remove @par_contract_enabled and @par_contract_contract due to form refactory (gform_pregled)  
-- 02.09.2008 PetraR; Task ID 5354 - added fields obdobje_akt and tipakt  
-- 08.09.2008 PetraR; Task ID 5354 - transformed from function to store procedure  
-- 24.09.2008 MatjazB; change fields a.withholding_tax_neto and a.withholding_tax_bruto; added fields a.withholding_tax and a.withholding_tax_net  
-- 25.09.2008 MatjazB; Task ID - added new parameters (@par_krovpog_enabled and @par_krovpog_value)  
-- 12.11.2008 Jure; BUG 27553 - Added support for revolving credits - diff of calculating field razpolozljivo  
-- 28.11.2008 Jure; BUG 27469 - Added fields skl_st_do1, skl_st_do2  
-- 16.12.2008 Jure; BUG 27555 - Added calculate Sum(crpanje) at left join by last select statement  
-- 24.06.2009 Jelena; Task 5584 - Added parametar tecajnica, added fields vred_preg, crpan_znes_preg, razpolozljivo_preg, bod_glavnica_preg, bod_obresti_preg, id_val_preg  
-- 28.07.2009 Jure; TASK 5585 - Modification of calculating exchange rate for field crpan_znes in a case of collection(parent) contract  
-- 04.07.2012 Ziga; Task ID 6936 - added new fields for_allocation, amount_for_allocation, id_purpose, all_in_price_for_npm  
-- 15.02.2013 Uros; Bug 29650 - added field rind_datum  
-- 26.01.2015 Jure; MID 48576 - Correction of calculating field razpolozljivo when using revolving credits  
-- 12.05.2015 Jure; TASK 8268 - Added column k_method  
-- 09.09.2016 Jure; TASK XXXX - Reorganize function  
-- 13.02.2018 KlemenV; TID 9215 - Added fields obresti_zac, fix_del_zac, max_dat_zap, zac_ind, akt_ind  
-- 09.03.2018 KlemenV; Task 12921 - GDPR  
-- 16.04.2018 KlemenV; TID 72543 - added max_dat_zap for past credit contracts  
------------------------------------------------------------------------------------------------------------  
CREATE PROCEDURE [dbo].[grp_ccontracts_allContracts]  
    @par_pogodba_enabled int,  
    @par_pogodba_pogodba varchar(5000),  
    @par_partner_enabled int,  
    @par_partner_partner varchar(5000),  
    @par_obdobje_akt_enabled int,  
    @par_obdobje_akt_datumod datetime,  
    @par_obdobje_akt_datumdo datetime,  
    @par_datsklen_enabled int,  
    @par_datsklen_datumod datetime,  
    @par_datsklen_datumdo datetime,  
    @par_tipakt_enabled int,  
    @par_tipakt_tip int,  
    @par_status_akt_enabled bit,  
    @par_status_akt_type int,  
    @par_status_akt_value varchar(8000),  
    @par_krovpog_enabled int,  
    @par_krovpog_value varchar(15),  
    @par_tecajnica_enabled int,  
    @par_tecajnica_tecajnica char(3), -- Exchange rate ID  
    @par_tecajnica_datumtec datetime,  -- today  
    @par_tecajnica_valuta char(3)  
AS  
BEGIN  
    SELECT   
  DISTINCT a.id_kredpog, a.aneks, a.id_kupca, a.dat_sklen, a.sit_znes,   
  a.val_znes, a.st_anuitet, a.obresti, a.refinanc, a.oznaka,   
  a.status_akt, a.tip_pog, a.id_strm, a.dat_aktiv, a.generate_payment,   
  a.withholding_tax, CASE WHEN a.withholding_tax_net = 1 THEN 'N' ELSE 'B' END as wht_type, a.skupna_cena, a.id_sklic,  
  b.naz_kr_kup, a.id_krov_pog,  
  c.id_val,  
  CASE  
   WHEN a.tip_pog <> 1 THEN (a.val_znes - a.crpan_znes)  
   ELSE (a.val_znes - ISNULL(d.crpan_znes, 0))   
  END AS razpolozljivo,  
  a.id_tec, a.tecaj, a.managment, a.comm, a.ostali_str, a.crpanje, a.id_odplac,  
  a.dat_1obr, a.dinamika, a.zam_obr, a.garancije, a.tip,  
  a.dan_plac, a.dan_izrac, a.dan_obr, a.varianta, a.opombe, a.anuiteta,  
  a.end_mode, a.dat_obr, a.sofin, a.k_method, a.izrac_obr, a.njih_st,  
  a.zadn_an, a.dat_0obr, a.prva_an, a.up_glav, a.vkl_1, a.vkl_2, a.zadnji_mes,  
  a.tip_izracuna, a.id_odplac2, a.st_obrokov2,  
  a.fix_del, a.id_rtip, a.kontodobv, a.kontodrs, a.dat_kon, a.vnesel,  
  a.dat_vnosa, a.crpan_dat,  
  CASE WHEN a.tip_pog <> 1 THEN a.crpan_znes ELSE ISNULL(d.crpan_znes, 0) END AS crpan_znes,  
  a.id_gl_knj_shema,  
  CASE WHEN a.withholding_tax_net = 0 THEN 0 ELSE a.withholding_tax END AS withholding_tax_neto,  
  CASE WHEN a.withholding_tax_net = 1 THEN 0 ELSE a.withholding_tax END AS withholding_tax_bruto,  
  a.skl_st_do1, a.skl_st_do2, a.for_allocation, a.amount_for_allocation, a.all_in_price_for_npm,  
  a.id_purpose, e.value as purpose_description, a.rind_datum,  
  a.obresti_zac, a.fix_del_zac, (a.obresti_zac - a.fix_del_zac) as zac_ind, (a.OBRESTI - a.FIX_DEL) as akt_ind  
 INTO   
  #kred_pog  
 FROM  
  dbo.kred_pog a  
  INNER JOIN dbo.gfn_Partner_Pseudo('grp_ccontracts_allContracts', case when @par_partner_enabled = 1 then @par_partner_partner else null end) b ON a.id_kupca = b.id_kupca  
  INNER JOIN dbo.tecajnic c ON a.id_tec = c.id_tec  
  LEFT JOIN dbo.gfn_g_register('KRED_POG_ALLOC_PURPOSE') e on e.id_key = a.id_purpose  
  LEFT JOIN (  
    SELECT   
     A.id_krov_pog,  
     SUM(A.crpan_znes * dbo.gfn_xr_CalcExRate(CASE WHEN A.krov_pog_val_znes = 0 THEN A.val_znes ELSE A.krov_pog_val_znes END, A.val_znes)) AS crpan_znes  
    FROM   
     dbo.kred_pog as A  
    WHERE   
     tip_pog = 2  
    GROUP BY   
     id_krov_pog) d ON a.id_kredpog = d.id_krov_pog  
 WHERE   
  (@par_pogodba_enabled = 0 OR @par_pogodba_pogodba = a.id_kredpog)  
  AND (@par_partner_enabled = 0 OR @par_partner_partner = a.id_kupca)   
  AND (@par_obdobje_akt_enabled = 0 OR a.dat_aktiv BETWEEN @par_obdobje_akt_datumod AND @par_obdobje_akt_datumdo)   
  AND (@par_datsklen_enabled = 0 OR a.dat_sklen BETWEEN @par_datsklen_datumod AND @par_datsklen_datumdo)   
  AND (@par_tipakt_enabled = 0 OR @par_tipakt_tip = a.tip_pog)  
  AND (@par_status_akt_enabled = 0   
   OR (@par_status_akt_type = 1 AND charindex(a.status_akt, @par_status_akt_value)= 0)  
   OR (@par_status_akt_type = 2 AND charindex(a.status_akt, @par_status_akt_value)> 0))  
  AND (@par_krovpog_enabled = 0 OR a.id_krov_pog = @par_krovpog_value OR a.id_kredpog = @par_krovpog_value)  
  
 SELECT   
  sum(p.znes_r) as bod_glavnica, sum(p.znes_o) as bod_obresti, p.id_kredpog, max(p.dat_zap) as max_dat_zap  
 INTO   
  #kred_planp  
 FROM   
  dbo.kred_planp p   
 WHERE   
  p.dat_zap > getdate()  
 GROUP BY   
  p.id_kredpog  
   
 UNION ALL   
   
 SELECT   
  0 as bod_glavnica, 0 as bod_obresti, p.id_kredpog, max(p.dat_zap) as max_dat_zap  
 FROM   
  dbo.kred_planp p   
 WHERE   
  getdate() >= (select max(subp.dat_zap) from dbo.kred_planp subp where subp.ID_KREDPOG = p.ID_KREDPOG group by subp.id_kredpog)  
 GROUP BY   
  p.id_kredpog  
    
    SELECT   
  a.id_kredpog, a.aneks, a.id_kupca, a.dat_sklen, a.sit_znes, a.val_znes, a.st_anuitet, a.obresti, a.refinanc, a.oznaka,   
        a.status_akt, a.tip_pog, a.id_strm, a.dat_aktiv, a.generate_payment, a.withholding_tax, a.wht_type, a.skupna_cena,   
        a.id_sklic, a.naz_kr_kup, a.id_krov_pog, a.id_val,   
        CASE   
   WHEN a.tip_pog = 4 THEN ISNULL(a.val_znes,0) - ISNULL(x.sum_crpan_znes, 0) + ISNULL(x.znes_r, 0)   
   ELSE ISNULL(a.razpolozljivo, 0)   
  END as razpolozljivo,   
        a.id_tec, a.tecaj, a.managment, a.comm, a.ostali_str, a.crpanje, a.id_odplac, a.dat_1obr, a.dinamika, a.zam_obr, a.garancije,   
        a.tip, a.dan_plac, a.dan_izrac, a.dan_obr, a.varianta, a.opombe, a.anuiteta, a.end_mode, a.dat_obr, a.sofin, a.k_method, a.izrac_obr,   
        a.njih_st, a.zadn_an, a.dat_0obr, a.prva_an, a.up_glav, a.vkl_1, a.vkl_2, a.zadnji_mes, a.tip_izracuna, a.id_odplac2, a.st_obrokov2,   
        a.fix_del, a.id_rtip, a.kontodobv, a.kontodrs, a.dat_kon, a.vnesel, a.dat_vnosa, a.crpan_dat,   
        (CASE WHEN a.tip_pog = 4 THEN ISNULL(x.sum_crpan_znes, 0) - ISNULL(x.znes_r, 0) ELSE ISNULL(crpan_znes, 0) END) as crpan_znes,   
        a.id_gl_knj_shema, a.withholding_tax_neto, a.withholding_tax_bruto, p.bod_glavnica, p.bod_obresti, a.skl_st_do1, a.skl_st_do2,  
  a.for_allocation, a.amount_for_allocation, a.all_in_price_for_npm, a.id_purpose, a.purpose_description,  
  a.rind_datum,  
  a.obresti_zac, a.fix_del_zac, p.max_dat_zap, a.zac_ind, a.akt_ind  
 INTO   
  #kred_pog_preg    
    FROM   
  #kred_pog a  
  LEFT JOIN #kred_planp p ON p.id_kredpog = a.id_kredpog  
  LEFT JOIN ( SELECT id_kredpog, sum(case when placano = 1 then znes_r else 0 end) as znes_r, sum(crpanje) as sum_crpan_znes  
     FROM dbo.kred_planp  
     GROUP BY id_kredpog) AS x ON a.id_kredpog = x.id_kredpog  
  
    SELECT   
  *,  
  dbo.gfn_xchange(@par_tecajnica_tecajnica,val_znes,id_tec,@par_tecajnica_datumtec) AS vred_preg,  
  dbo.gfn_xchange(@par_tecajnica_tecajnica,crpan_znes,id_tec,@par_tecajnica_datumtec) AS crpan_znes_preg,  
  dbo.gfn_xchange(@par_tecajnica_tecajnica,razpolozljivo,id_tec,@par_tecajnica_datumtec) AS razpolozljivo_preg,  
  dbo.gfn_xchange(@par_tecajnica_tecajnica,bod_glavnica,id_tec,@par_tecajnica_datumtec) AS bod_glavnica_preg,  
  dbo.gfn_xchange(@par_tecajnica_tecajnica,bod_obresti,id_tec,@par_tecajnica_datumtec) AS bod_obresti_preg,  
  @par_tecajnica_valuta as id_val_preg  
    FROM   
  #kred_pog_preg   
  
  
    DROP TABLE #kred_pog  
    DROP TABLE #kred_planp  
    DROP TABLE #kred_pog_preg   
END  
  