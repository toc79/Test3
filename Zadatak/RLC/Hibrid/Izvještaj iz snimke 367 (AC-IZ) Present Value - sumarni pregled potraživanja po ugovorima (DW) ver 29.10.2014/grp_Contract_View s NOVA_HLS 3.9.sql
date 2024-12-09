------------------------------------------------------------------------------------------------------------  
-- Function for getting data for  "Pregled pogodbe"  
--   
--  
-- History:  
-- 05.08.2004 Muri; created  
-- 01.09.2004 Muri, spremenil char in varchar(X) v varchar(8000),   
-- 24.09.2004 Muri, dodal kriterij status aktivnosti  
-- 15.10.2004 Matjaz; dodal trim okrog pogodbe  
-- 02.11.2004 Matjaz; added new fields p.MPC, p.DAT_PODPISA, p.ID_POSREDNIK  
-- 29.11.2004 Matjaz; added columns p.RIND_FAKTOR, p.SE_VARSC  
-- 21.12.2004 Muri; updated WHERE for @par_obdobjeAkt_enabled and @par_obdobjesklen_enabled  
-- 24.01.2005 Vilko; added column ref.NAZIV  
-- 01.02.2005 Vilko; updated WHERE - replaced dat_akt >= ... and dat_akt <= ... with gfn_BetweenDate(dat_akt, ...)  
-- 23.02.2005 Darko; added order by id_pog  
-- 03.03.2005 Matjaz; added condition in case of aneks type 2 - or aneks = ''  
-- 07.03.2005 Vik; created grp from gfn  
-- 18.03.2005 Vik; removed (+ 1) for dat_sklen and dat_aktiv  
-- 14.06.2005 Darko: added contriners criteria_vrstaosebe, criteria_strm  
-- 09.08.2005 Matjaz; added condition in case of aneks type 1 - or aneks = ''  
-- 26.09.2005 Matjaz; reorganized procedure to generat sql string  
-- 23.06.2006 Darko; added container status Bug(25991)  
-- 15.12.2006 Ziga; Maintenance ID 4997 - added parameters and conditions for krovna_pogodba  
-- 15.02.2007 MatjazB; Bug ID 26488 - changed parameter and conditions for krovna_pogodba  
-- 19.02.2007 Matjaz; changed use of condition for krovna_pogodba  
-- 23.05.2007 Vilko; Maintenance ID 8873 - added criteria for sklic  
-- 19.07.2007 Vik; MODIFIED ON_SITE: must be included int new version  
-- 22.08.2007 Jasna; Maintenance ID 9100 - changes due to changes in dbo.gfn_Contract_View2 (input para.)   
-- 04.12.2007 Jasna; Maintenance ID 11481 - changes due to vnesel changes in gfn_Contract_View2   
-- 17.12.2008 Matjaz; Bug ID 27631 - changed condition in case parameter @par_user_username is passed.  
-- 27.12.2010 Ziga; MID 28011 - added criteria for closing contract period  
--  Now username is compared to new field vnesel_username rather then user_desc to field vnesel because of better index use.  
-- 03.09.2013 MatjazB; Task 7496 - added new parameters @par_project_enabled and @par_project_value  
-- 23.10.2015 Andrej; MID 53412 - added new parameters @par_vnesel_enabled and @par_vnesel_username  
-- 26.10.2015 Andrej; MID 53412 - replaced parameters @par_vnesel_enabled and @par_vnesel_username with @par_referent_enabled and @par_referent_id  
-- 26.05.2016 MatjazB; Bug 32384 - don't use function dbo.gfn_Contract_View2; added fields form dbo.planp  
-- 04.11.2016 Blaz; BID 32733 - changed the defintion of @date because it was causing problems on older SQL (2005)  
-- 15.11.2016 MatjazB; MID 59630 - added prev_pog.kategorija1_desc as prev_pog_kateg1_desc  
-- 13.01.2017 MatjazB; MID 59597 - added n.ima_opcijo; change tren_opc  
-- 05.05.2017 MatjazB; Bug 33121 - exchange pp.tren_opc and pp.tren_vars  
-- 12.06.2017 Jure; BUG 32461 - Call max ID from dbo.pogodba_opom_info  
-- 23.11.2017 Nejc; TID 11632 - Added field "Popravil" from pogodba  
-- 16.02.2018; Nejc; TID 12768 - GDPR  
------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[grp_Contract_View]   
    @par_pogodba_enabled int,  
    @par_pogodba_pogodba varchar(8000),   
    @par_partner_enabled int,  
    @par_partner_partner char(6),  
    @par_obdobjeAkt_enabled int,  
    @par_obdobjeAkt_datumod char(8),   
    @par_obdobjeAkt_datumdo char(8),  
    @par_obdobjeSklen_enabled int,  
    @par_obdobjeSklen_datumod char(8),   
    @par_obdobjeSklen_datumdo char(8),  
 @par_obdobjeZak_enabled int,  
    @par_obdobjeZak_datumod char(8),   
    @par_obdobjeZak_datumdo char(8),  
    @par_nacinleas_enabled int,   
    @par_nacinleas_nacinleas varchar(8000),  -- type of financing  
    @par_aneks_enabled int,  
    @par_aneks_anekstype int,  
    @par_aneks_anekses varchar(8000),  --eliminate contracts with  annex  
    @par_akt_enabled int,  
    @par_akt_akttype int,  
    @par_akt_akt varchar(8000),    
    @par_partnerDobavitelj_enabled int,  
    @par_partnerDobavitelj_partner char(6),  
    @par_opremavrsta_enabled int,  
    @par_opremavrsta_opremavrsta varchar(8000),  -- types of equipment  
    @par_PVrOsebe_Enabled bit,  
    @par_PVrOsebe_ID char(2),  
    @par_strm_enabled int,  
    @par_strm_strm varchar(8000), --@niz_strm  
    @par_Language_partner char(3),  
    @par_status_enabled int,  
    @par_status_status varchar(8000),  
    @par_obstoja_kp_enabled bit, -- for krovna pogodba  
    @par_obstoja_st_krov_pog varchar(50),  
    @par_sklic_enabled int,  
    @par_sklic_sklic varchar(24),  
    @par_user_enabled int,  
    @par_user_username varchar(8000),  
    @par_referent_enabled int,  
    @par_referent_id varchar(5),  
    @par_project_enabled int,  
    @par_project_value int  
  
AS  
BEGIN  
  
DECLARE @id_kupca char(8)  
    if @par_partner_enabled = 1   
        set @id_kupca = '''' + @par_partner_partner + ''''  
 else  
  set @id_kupca = 'null'  
  
DECLARE @id_dob char(8)  
    if @par_partnerDobavitelj_enabled = 1   
        set @id_dob = '''' + @par_partnerDobavitelj_partner + ''''  
 else  
  set @id_dob = 'null'  
  
DECLARE @cmd varchar(max), @cr varchar(10), @id_cont varchar(20), @cmd_where varchar(4000)  
set @cr = char(13) + char(10) + SPACE(4)  
if @par_pogodba_enabled = 1  
    set @id_cont = (select dbo.gfn_Id_cont4Id_pog(@par_pogodba_pogodba))  
  
SET @cmd = '  
declare @date datetime set @date = getdate()  
  
declare @planp table (id_cont int, max_dat_zap datetime, tren_opc decimal(18,2), tren_vars decimal(18,2))'  
  
if @par_pogodba_enabled = 1 and @id_cont is not null  
begin       
    SET @cmd = @cmd + '  
declare @st_dokOPC varchar(50), @nacin_leas char(2), @id_tec char(3)  
select @nacin_leas = nacin_leas, @id_tec = id_tec from dbo.pogodba where id_cont = ' + @id_cont + '  
set @st_dokOPC = (select dbo.gfn_GetOpcSt_dok(' + @id_cont + ', @nacin_leas))  
  
insert into @planp (id_cont, max_dat_zap, tren_opc, tren_vars)  
select   
    pp1.id_cont,   
    max(pp1.dat_zap) max_dat_zap,   
    sum(case when pp1.st_dok = @st_dokOPC then dbo.gfn_xchange(@id_tec, pp1.debit - pp1.davek, pp1.id_tec, pp1.datum_dok) else 0 end) as tren_opc,   
    sum(case when vt.sif_terj = ''VARS'' then dbo.gfn_xchange(@id_tec, pp1.debit - pp1.davek, pp1.id_tec, pp1.datum_dok) else 0 end) as tren_vars   
from   
    dbo.planp pp1  
    inner join dbo.vrst_ter vt on pp1.id_terj = vt.id_terj  
where pp1.id_cont = ' + @id_cont + '  
group by pp1.id_cont  
'  
end  
  
SET @cmd = @cmd + @cr + '  
SELECT   
    p.id_cont, p.id_pog, p.id_sklic, p.id_kupca, p.id_vrste, p.id_dob, p.st_predr, p.dat_predr, p.predr_do, p.traj_naj,   
    p.zac_naj, p.kon_naj, p.po_tecaju, p.vr_sit, p.vr_val, p.dat_sklen, p.id_tec, p.id_val, p.id_dav_st, p.st_obrok,   
    p.prv_obr, p.marza_av, p.ost_obr, p.marza_ob, p.zap_2ob, p.obr_mera, p.obr_merak, p.id_rtip, p.id_obd, p.opcija,   
    p.zap_opc, p.obl_zt, p.stroski_zt, p.zapade_zt, p.zt_zavar, p.stroski_pz, p.zapade_pz, p.pz_zavar, p.akont,   
    p.dakont, p.diskont, p.pszav, p.id_obrv, p.id_obrs, p.aneks, p.ali_pp, p.prejme_do, p.akc_nal, p.izv_kom, p.izv_naj,   
    p.id, p.trojna_opc, p.ali_sdr, p.id_tecvr, p.pred_naj, p.spl_pog, p.subleasing, p.man_str, p.dat_pol, p.nacin_leas,   
    p.opombe, p.rabat_nam, p.rabat_njim, p.status_akt, p.menic, p.dat_1op, p.dat_2op, p.dat_3op, p.id_kredpog,   
    p.dat_aktiv, p.vred_val, p.net_nal, p.zav_fin, p.zapade_zf, p.dej_obr, p.str_financ, p.obr_financ, p.dni_financ,   
    p.za_odobrit, p.datum_odob, p.pz_let, p.beg_end, p.id_pog_zav, p.refinanc, p.obr_vir, p.id_dav_op, p.zn_refinan,   
    p.obrok1, p.njih_st, p.ze_proviz, p.dav_osno, p.dat_od1, p.dat_kkf, p.vnesel as vnesel_username, p.konsolid,   
    p.stroski_x, p.ref1, p.obr_vir1, p.zn_ref1, p.varscina, p.om_varsc, p.dovol_km, p.cena_dkm, p.id_pon, p.kasko, p.bruto, p.rabat,   
    p.rind_zadnji, p.rind_tdol, p.rind_tgor, p.rind_datum, p.naziv_tuje, p.prenos, p.dva_pp, p.id_kupca1, p.dat_zakl,   
    p.id_strm, p.id_ref, p.kk_memo, p.fix_del, p.ddv, p.dobrocno, p.pred_ddv, p.ddv_id, p.id_svet, p.ze_avansa, p.[status],   
    p.obr_marz, p.ef_obrm, p.izvoz, p.id_prod, p.vr_prom, p.sklic, p.oststr, p.verified, p.dat_arhiv, p.kategorija,   
    p.dni_zap, p.rind_zahte, p.prevzeta, p.disk_r, p.nacin_ms, p.opc_datzad, p.opc_imaobr, p.prza_eom, p.pyr, p.plac_zac,   
    p.mpc, p.dat_podpisa, p.id_posrednik, p.rind_faktor, p.se_varsc, p.vr_val_zac, p.strong_payment,   
    p.moratorij_mes, p.vr_promb, p.kategorija1, p.kategorija2, p.kategorija3, p.ddv_se_ne_odbija, p.net_nal_zac,   
    p.financiranje_zalog, p.tip_om, p.ef_obrm_tren, p.id_project, p.id_datum_dok_create_type, p.robresti_val,   
    p.robresti_zac, p.robresti_sit, p.rind_dat_next, p.id_rind_strategije, p.id_obd_obr, p.pyr_obr, p.dat_obresti,   
    p.dni_zap_obr, p.id_datum_dok_create_type_obr, p.interest_template, p.dat_del_aktiv,   
    p.obr_merak - (p.dej_obr - p.fix_del) as fix_delk,   
  /*p.kdo_odb, p.dav_osno_dom, p.ddv_dom, p.brez_davka_dom, p.neobdav_dom, p.opis_pred, p.next_rpg_num, p.id_odobrit,   
    p.id_kupca_pl, p.id_datum_dok_create_type, p.id_provizije, -- polja niso v seznamu zaradi stevila stolpcev  
  */par.naz_kr_kup as partner_naz_kr_kup, par.emso as partner_emso, par.dav_stev as partner_dav_stev,   
    par.ulica as partner_ulica, par.id_poste as partner_id_poste, par.mesto as partner_mesto,   
    tr.trr as partner_zr1, par.zr2 as partner_zr2, par.zr3 as partner_zr3, par.telefon as partner_telefon,   
    par.fax as partner_fax, par.kontakt as partner_kontakt, par.vr_osebe as partner_vr_osebe, par.ulica_sed,   
    par.id_poste_sed, par.mesto_sed, par.asset_clas as B2_kateg,   
    par.skrbnik_1, par.skrbnik_2, par.gsm as partner_gsm, par.sif_dej as sif_par,   
    dob.naz_kr_kup as dobavitelj_naz_kr_kup, dob.emso as dobavitelj_emso, dob.dav_stev as dobavitelj_dav_stev,   
    dob.sif_dej as sif_dob,   
    t.naziv as tecajnic_naziv,   
    d1.opis as dav_stop_opis, d2.opis AS dav_stop_op_opis,   
    o1.naziv as obdobja_naziv, o2.naziv as obd_obr_naziv,   
    r.naziv as rtip_naziv,   
    v.naziv as vrst_opr_naziv, v.se_regis as vrst_opr_se_regis, v.id_grupe as vrst_opr_id_grupe,   
    ref.naziv as referent_naziv, ref.id_ref as referent_id,   
    cast(n.odstej_var as int) as odstej_var, n.installment_credit, n.ima_opcijo,   
    k.naziv as naziv_kateg,   
    s.naziv as svetovalec_naziv,   
    pon.obr_mera as pon_obr_mera, pon.obr_merak as pon_obr_merak, pon.fix_del as pon_fix_del,   
    pon.obr_merak - (pon.dej_obr - pon.fix_del) as pon_fix_delk,   
    intg_pon.intg_ext_id,   
    pro.id_prod1, pro.naziv as naziv_pro,  
    PK.naziv as kateg_ose,  
    ISNULL(u.user_desc, p.vnesel) as vnesel,   
 ISNULL(u2.user_desc, p.popravil) as popravil,  
    s1.naz_kr_kup AS naz_skrbnik_1, s2.naz_kr_kup AS naz_skrbnik_2,   
    fp.id_frame, ft.naziv_frame_type as frame_type, fl.opis,   
    wp.povp_dzam, wp.povp_dzam_observe,   
    pos.value as posrednik_naziv,   
    k1.value as kategorija1_naziv, k2.value as kategorija2_naziv, k3.value as kategorija3_naziv,   
    poi.ne_opom_do,   
    prn.projectnumber, prn.projectname,   
    strat.naziv as rind_strat_naziv,  
    inst.last_calc_date as zad_izr_obr,   
    it.description as metoda_izr_obr,   
    dbo.gfn_GetMarketValue(p.id_cont, @date, p.dat_aktiv) as trz_vred,  
    dbo.gfn_InstallmentCredit_GetNextIntCalcDate(@date, p.id_cont) as nasl_izr_obr,   
    pp.max_dat_zap, isnull(pp.tren_opc, 0) tren_opc,   
    p.opcija + case when n.odstej_var = 1 then p.varscina else 0 end ost_vred,   
    isnull(pp.tren_opc, 0) + case when n.odstej_var = 1 then isnull(pp.tren_vars, 0) else 0 end ost_vred_tren,   
    prev_pog.kategorija1_desc as prev_pog_kateg1_desc  
FROM   
    dbo.pogodba p   
    INNER JOIN dbo.gfn_Partner_Pseudo(''grp_Contract_View'','+@id_kupca+') par on p.id_kupca = par.id_kupca  
    INNER JOIN dbo.gfn_Partner_Pseudo(''grp_Contract_View'','+@id_dob+') dob on p.id_dob = dob.id_kupca  
    INNER JOIN dbo.tecajnic t on p.id_tec = t.id_tec  
    INNER JOIN dbo.dav_stop d1 on p.id_dav_st = d1.id_dav_st   
    LEFT JOIN dbo.dav_stop d2 on p.id_dav_op = d2.id_dav_st  
    INNER JOIN dbo.obdobja o1 on p.id_obd = o1.id_obd   
    LEFT JOIN dbo.obdobja o2 on p.id_obd_obr = o2.id_obd   
    INNER JOIN dbo.rtip r on p.id_rtip = r.id_rtip   
    INNER JOIN dbo.vrst_opr v on p.id_vrste = v.id_vrste  
    INNER JOIN dbo.referent ref on p.id_ref = ref.id_ref  
    INNER JOIN dbo.nacini_l n on p.nacin_leas = n.nacin_leas  
    INNER JOIN dbo.kategor k on k.kategorija = p.kategorija  
    INNER JOIN dbo.svetoval s on s.id_svet = p.id_svet  
    INNER JOIN dbo.ponudba pon on p.id_pon = pon.id_pon  
    LEFT JOIN dbo.intg_dsa_ponudba intg_pon on pon.id_pon = intg_pon.id_pon  
    LEFT JOIN dbo.prodajal pro on pro.id_prod = p.id_prod  
    LEFT JOIN dbo.p_kateg PK on PK.p_kateg = par.p_kateg   
    LEFT JOIN dbo.users u on u.username = p.vnesel  
 LEFT JOIN dbo.users u2 on u2.username = p.popravil  
    LEFT JOIN dbo.gfn_Partner_Pseudo(''grp_Contract_View'',null) s1 on par.skrbnik_1 = s1.id_kupca  
    LEFT JOIN dbo.gfn_Partner_Pseudo(''grp_Contract_View'',null) s2 on par.skrbnik_2 = s2.id_kupca  
    LEFT JOIN dbo.frame_pogodba fp on fp.id_cont = p.id_cont  
    LEFT JOIN dbo.frame_list fl on fl.id_frame = fp.id_frame  
    LEFT JOIN dbo.frame_type ft on ft.id_frame_type = fl.frame_type  
    LEFT JOIN dbo.wavg_zam_pog wp with (nolock) on wp.id_cont = p.id_cont  
    LEFT JOIN dbo.gfn_g_register(''P_POSREDNIK'') pos ON p.id_posrednik = pos.id_key  
    LEFT JOIN dbo.gfn_g_register(''KATEGORIJA1'') k1 ON p.kategorija1 = k1.id_key  
    LEFT JOIN dbo.gfn_g_register(''KATEGORIJA2'') k2 ON p.kategorija2 = k2.id_key  
    LEFT JOIN dbo.gfn_g_register(''KATEGORIJA3'') k3 ON p.kategorija3 = k3.id_key  
    --LEFT JOIN dbo.pogodba_opom_info poi on poi.id_cont = p.id_cont  
    LEFT JOIN dbo.projects prn on p.id_project = prn.id_project  
    LEFT JOIN dbo.partner_trr tr ON par.id_kupca = tr.id_kupca and tr.prioriteta = 1 and tr.aktivnost = ''A''  
    LEFT JOIN dbo.rind_strategije as strat on p.id_rind_strategije = strat.id_rind_strategije  
    LEFT JOIN dbo.gv_InstallmentCredit_LastCalculationDate as inst on p.id_cont = inst.id_cont   
    LEFT JOIN dbo.interest_template as it on p.interest_template = it.id_interest_template  
    LEFT JOIN @planp pp on p.id_cont = pp.id_cont   
    LEFT JOIN dbo.gfn_Taken_over_contracts() prev_pog ON p.id_cont = prev_pog.pog_po and dbo.gfn_Id_cont4Id_pog(p.prevzeta) = prev_pog.pog_prej  
 outer apply (select max(ID_POG_OPOM_INFO) as ID_POG_OPOM_INFO from dbo.pogodba_opom_info where id_cont = p.id_cont) as oi2  
 left join dbo.pogodba_opom_info as poi on poi.ID_POG_OPOM_INFO = oi2.ID_POG_OPOM_INFO ' + @cr  
IF @par_obstoja_kp_enabled = 1  
BEGIN  
 SET @cmd = @cmd + 'INNER JOIN dbo.krov_pog_pogodba b ON p.id_cont = b.id_cont ' + @cr  
END  
SET @cmd = RTRIM(@cmd) + 'WHERE ' + @cr  
IF @par_pogodba_enabled = 1   
begin  
    if @id_cont is not null  
        SET @cmd = @cmd + 'p.id_cont = ' + @id_cont + ' AND ' + @cr  
    else  
        SET @cmd = @cmd + 'p.id_pog LIKE ''' + @par_pogodba_pogodba + ''' AND ' + @cr  
end  
IF @par_partner_enabled = 1 SET @cmd = @cmd + 'p.id_kupca = ''' + @par_partner_partner + ''' AND ' + @cr  
IF @par_obdobjeAkt_enabled = 1 SET @cmd = @cmd + 'p.dat_aktiv BETWEEN ''' + @par_obdobjeAkt_datumod + ''' AND ''' + @par_obdobjeAkt_datumdo + ''' AND ' + @cr  
IF @par_obdobjeSklen_enabled = 1 SET @cmd = @cmd + 'p.dat_sklen BETWEEN ''' + @par_obdobjeSklen_datumod + ''' AND ''' + @par_obdobjeSklen_datumdo + ''' AND ' + @cr  
IF @par_obdobjeZak_enabled = 1 SET @cmd = @cmd + 'p.dat_zakl BETWEEN ''' + @par_obdobjeZak_datumod + ''' AND ''' + @par_obdobjeZak_datumdo + ''' AND ' + @cr  
IF @par_nacinleas_enabled = 1  
BEGIN  
 SET @par_nacinleas_nacinleas = '''' + REPLACE(@par_nacinleas_nacinleas, ',', ''',''') + ''''  
 SET @cmd = @cmd + 'p.nacin_leas IN (' + @par_nacinleas_nacinleas + ') AND ' + @cr  
END  
  
IF @par_aneks_enabled = 1  
BEGIN  
 IF @par_aneks_anekstype = 1  
 SET @cmd = @cmd + '(CHARINDEX(p.aneks,''' + @par_aneks_anekses + ''') = 0 OR p.aneks = '''') AND ' + @cr  
 ELSE SET @cmd = @cmd + 'NOT (CHARINDEX(p.aneks,''' + @par_aneks_anekses + ''') = 0 OR p.aneks = '''') AND ' + @cr  
END  
  
IF @par_akt_enabled = 1  
BEGIN  
 IF @par_akt_akttype = 1  
 SET @cmd = @cmd + '(CHARINDEX(p.status_akt,''' + @par_akt_akt + ''') = 0) AND ' + @cr  
 ELSE SET @cmd = @cmd + '(CHARINDEX(p.status_akt,''' + @par_akt_akt + ''') != 0) AND ' + @cr  
END  
  
IF @par_partnerDobavitelj_enabled = 1 SET @cmd = @cmd + 'p.id_dob = ''' + @par_partnerDobavitelj_partner + ''' AND ' + @cr  
  
IF @par_opremavrsta_enabled = 1  
BEGIN  
 SET @par_opremavrsta_opremavrsta = '''' + REPLACE(@par_opremavrsta_opremavrsta, ',', ''',''') + ''''  
 SET @cmd = @cmd + 'p.id_vrste IN (' + @par_opremavrsta_opremavrsta + ') AND ' + @cr  
END  
  
IF @par_PVrOsebe_Enabled = 1 SET @cmd = @cmd + 'par.vr_osebe = ''' + @par_PVrOsebe_ID + ''' AND ' + @cr  
  
IF @par_strm_enabled = 1  
BEGIN  
 SET @par_strm_strm = '''' + REPLACE(@par_strm_strm, ',', ''',''') + ''''  
 SET @cmd = @cmd + 'p.id_strm IN (' + @par_strm_strm + ') AND ' + @cr  
END  
  
IF @par_status_enabled = 1  
BEGIN  
 SET @par_status_status = '''' + REPLACE(@par_status_status, ',', ''',''') + ''''  
 SET @cmd = @cmd + 'p.status IN (' + @par_status_status + ') AND ' + @cr  
END  
  
IF @par_user_enabled = 1 SET @cmd = @cmd + 'p.vnesel = ''' + @par_user_username + ''' AND ' + @cr  
  
IF @par_referent_enabled = 1 SET @cmd = @cmd + 'ref.id_ref = ''' + @par_referent_id + ''' AND ' + @cr  
  
IF @par_obstoja_kp_enabled = 1  
BEGIN  
 DECLARE @id_krov_pog int  
 SET @id_krov_pog = (SELECT TOP 1 id_krov_pog FROM dbo.krov_pog WHERE st_krov_pog = @par_obstoja_st_krov_pog)  
 SET @cmd = @cmd + 'b.id_krov_pog = ''' + cast(@id_krov_pog as varchar(10)) + ''' AND ' + @cr  
END  
IF @par_sklic_enabled = 1 SET @cmd = @cmd + 'p.sklic LIKE ''' + @par_sklic_sklic + ''' AND ' + @cr  
  
IF @par_project_enabled = 1 set @cmd = @cmd + 'p.id_project = ' + cast(@par_project_value as varchar(10)) + ' AND ' + @cr  
  
SET @cmd = left(@cmd, len(@cmd) - (4 + len(@cr))) + '  
ORDER BY p.id_pog '  
  
print (@cmd)  
execute(@cmd)  
  
END  
  