------------------------------------------------------------------------------------------------------------
-- Summary view of open and future claims for contracts from daily snapshot
-- 
--
-- History:
-- 06.09.2005 Matjaz; created
-- 07.10.2005 Matjaz; expanded field referent due to structure change in table referent
-- 09.10.2005 Matjaz; MODIFIED ON SITE - added check of parameter @par_ZnesekObrok_enabled
-- 16.11.2005 Matjaz; bugfix (BugID - 25706) - fixed handling empty anekses (before they were always included/excluded)
-- 29.11.2005 Darko; added @par_strm_.. container
-- 13.06.2006 Vilko; resized field sif_dej from C(5) to C(6)
-- 07.08.2006 Matjaz; Bug ID 26088: added columns se_obresti, se_marza, se_regist
-- 20.11.2006 Vilko; Maintenance ID 4793 - added fields skrbnik_1 and naz_skrbnik_1
-- 13.12.2006 Ziga; added conditions for krovna_pogodba, split main select according to conditions (krovna pogodba is selected or is not selected) 
-- 10.01.2007 Jasna; added field boniteta,znp_min_dat_zap_ALL and znp_max_dni_ALL
-- 16.01.2007 Jasna; changed field length naz_kr_kup, Dobavitelj and Naz_skrbnik_1 (40-->80)
-- 17.01.2007 Jasna; modifications in select and update statement
-- 20.02.2007 MatjazB; Bug ID 26496 - removed left join for krovna_pogodba
-- 01.03.2007 Jasna; Task 5021: added fields dat_1op, dat_2op
-- 02.10.2007 Jasna; Maintenance ID 11134 - added fields kategorija and naziv (kategorija)
-- 11.10.2007 Natasa; TASK ID 5190; added field vrsta_opreme, ulica, dat_3op, dobavite, delodajale 
-- 23.10.2007 Natasa; TASK ID 5190 added fields znp_max_dat_obr_LPOD,znp_max_dat_zap_LPOD and bod_min_dat_zap_LPOD to Result from planp_ds 
-- 10.12.2007 Ziga; MID 11390 - added fields min_dat_zap and traj_pog (max_dat_zap - min_dat_zap)
-- 29.01.2008 Vilko; Bug ID 27076 - fixed calculating min_dat_zap
-- 04.02.2008 Ziga; Bug ID 27076 - fixed calculating traj_pog; traj_pog = max_dat_zap - dat_sklen
-- 25.03.2008 Jure; MID 14309 - added field Skrbnik_2
-- 01.07.2008 MatjazB; Bug ID 27362 - added new fields id_val_s and id_tec_s 
-- 02.12.2008 MatjazB; MID 17891 - added new field trz_vred and parameters @par_datum_
-- 16.12.2008 vilko; MID 18385 - added new fields id_obd and obdobja_naziv
-- 06.02.2009 Ziga; Bug ID 27678 - changed length of field vrsta_opreme to varchar(150) in table @result according to length in table vrst_opr
-- 20.02.2009 Vilko; MID 19541 - added field id_svet and svetoval_naziv
-- 17.04.2009 JozeM; BID 27810 - changed check for criteria @par_Aktivirane from < to <=
-- 19.05.2009 JozeM; MID 19451 - added criteria Skrbnik1
-- 31.05.2010 MatjazB; MID 25383 - change type of parameter @par_Obrok and @par_ObrokALI from int to decimal(18,2)
-- 07.10.2010 Jelena; Task ID 6074 - added field pogodba.refinanc
-- 24.01.2011 MatjazB; MID 28546 - use gfn_Xchange for field trz_vred
-- 01.03.2011 Jure; BUG 28788 - Added fields bod_cnt_lobr, bod_cnt_all, kontakt and gsm
-- 28.08.2012 Uros; Bug 29554 - changed mesto length to 30
-- 19.11.2012 Ales; MR 36643 - added field datum_odkupa into UPDATE @Result
-- 30.01.2013 Natasa; BUG ID 28939 - added criteria @par_zaprteterj_enabled
-- 23.04.2013 Ales; MID 39639 - added fields Od_OObresti, Od_ORobresti, Od_OMarza and Od_ORegist
-- 30.05.2013 Uros; bug 30125 - changed mesto length to 50
-- 26.06.2013 Jost; MID 40954 - changed 'refinanc' length to 20
-- 24.09.2013 Uros; Bug 30142 - added join to planp_ds with filter on partner
-- 24.02.2014 Uros; Mr 44704 - reverted changes from previous bug
-- 20.05.2014 Jelena; Task ID 8059 - added Od_Robresti and Se_Robresti
-- 25.08.2014 Uros; Task 8082 - changed field delodajale handling - from p_kontakt
-- 30.12.2014 Andrej; MID 48424 - Added field email, tr1, tr2, zr, no_id_kupca, max_dat_zap_now
-- 05.03.2015 Jelena; Bug ID 31521 - changed getting field delodajale
-- 01.06.2015 Domen; TaskID 8468 - Anonymize displaying of EMSO.
------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[gfn_Report_SumContractFromDailySnapshot] (
@par_pogodba_enabled int,
@par_pogodba_pogodba varchar(8000), 
@par_partner_enabled int,
@par_partner_partner char(6),
@par_tecajnica_enabled int,
@par_tecajnica_tecajnica char(3), -- Exchange rate ID
@par_tecajnica_datumtec datetime,  -- today
@par_tecajnica_valuta char(3), 
@par_ZnesekObrok_enabled as int,
@par_Znesek as decimal(18,2),
@par_ObrokALI as decimal(18,2),
@par_Obrok as decimal(18,2),
@par_aneks_enabled int,
@par_aneks_anekstype int,
@par_aneks_anekses varchar(8000), 
@par_akt_enabled int,
@par_akt_akttype int,
@par_akt_akt varchar(8000),  
@par_nacinleas_enabled int, 
@par_nacinleas_nacinleas varchar(8000), 
@par_Aktivirane_enabled int,
@par_Aktivirane as datetime,
@par_strm_enabled int,
@par_strm_strm varchar(8000),
@par_obstoja_krov_pog_enabled bit,
@par_obstoja_st_krov_pog varchar(50),
@par_datum_enabled bit,
@par_datum_today datetime,
@par_skrbnikone_enabled bit,
@par_skrbnikone char(6),
@par_zaprteterj_enabled int,
@par_vnesel_enabled int,
@par_vnesel_vnesel varchar(8000)
)
RETURNS @Result TABLE
   (
    -- Pogodba
    ID_Cont int, 
    ID_Pog char(11),
    ID_Kupca char(6), 
    Status char(2),
    ID_Strm char(4),
    ID_Kredpog char(15),
    Nacin_leas char(2),
    Dat_sklen datetime,
    ID_Ref char(5),
    Pred_naj varchar(100),
    Traj_naj int,
    Net_nal decimal(18,2),
    Vr_val decimal(18,2),
   Obrok1 decimal(18,2),
    Opcija decimal(18,2),
    id_rtip char(5),
    Zap_opc datetime,
    Aneks char(1),
    Referent varchar(50),
    ID_Dob char(6),
    Dobavitelj varchar(80),
    ID_Grupe char(3),
    vrsta_opreme varchar(150), 
    ID_tec char(3),
    ID_val char(3),
    dat_1op datetime,
    dat_2op datetime,
    dat_3op datetime,
     refinanc char(20),
    -- Partner
    Naz_kr_kup varchar(80),
    Emso char(13),
    Vr_osebe char(2),
    Telefon varchar(30),
    Id_poste varchar(14),
    Mesto varchar(50),
    Ulica varchar(70),    
    Sif_dej char(6),
    Id_skis char(7),
    boniteta char(10),
    St_pogodb int,
    Skrbnik_1 char(10),
    Naz_skrbnik_1 varchar(80),
    Skrbnik_2 char(10),
    Naz_skrbnik_2 varchar(80),
    dobavite bit,    
    delodajale varchar(120),
    email varchar(100),
    TR1 varchar(50),
    TR2 varchar(50),
    ZR varchar(200),
    no_id_kupca int,
    -- PlanP
    Se_neto decimal(18,2),
    Se_obresti decimal(18,2),
    Se_marza decimal(18,2),
    Se_regist decimal(18,2),
    Se_bruto decimal(18,2),
    Se_fin_davek decimal(18,2),
	Se_robresti decimal(18,2),
    Zap_obr decimal(3,0),
    Od_Neto decimal(18,2),
    Od_Obresti decimal(18,2),
    Od_Marza decimal(18,2),
    Od_Regist decimal(18,2),
    Od_Davek decimal(18,2),
	Od_Robresti decimal(18,2),
    Od_ONeto decimal(18,2),
    Od_OObresti decimal(18,2),
	Od_ORobresti decimal(18,2),
	Od_OMarza decimal(18,2),
	Od_ORegist decimal(18,2),
    Od_ODavek decimal(18,2),
    Obrokov decimal(18,2),
    Proc_plac decimal(18,2),
    Obr_Pog decimal(18,2),
    Debit decimal(18,2),   
    Kredit decimal(18,2),
    Saldo decimal(18,2),
    Skupaj decimal(18,2), 
    Max_dat_zap datetime,
    Min_dat_zap datetime,
    max_dat_zap_now datetime, 
    znp_min_dat_zap_ALL datetime, 
    znp_max_dni_ALL int,
    Kategorija char(3),
    Naziv_kateg char(50),
    znp_max_dat_obr_LPOD datetime,
    znp_max_dat_zap_LPOD datetime,
    bod_min_dat_zap_LPOD datetime,
    traj_pog int,
     id_val_s char(3),
     id_tec_s char(3),
    trz_vred decimal(18,2),
    id_obd char(3),
    obdobja_naziv char(20),
    id_svet char(5),
    svetoval_naziv varchar(100),
    bod_cnt_lobr int, 
    bod_cnt_all int,
    kontakt varchar(45),
    gsm varchar(50)
   )
AS
BEGIN
     DECLARE @id_krov_pog int
     SET @id_krov_pog = (SELECT TOP 1 id_krov_pog FROM dbo.krov_pog WHERE st_krov_pog = @par_obstoja_st_krov_pog)
	 DECLARE @delo_old bit
	 SET @delo_old = dbo.gfn_GetCustomSettingsAsBool('Nova.LE.PartnerEmployerContacts')
    /*DECLARE @CriteriaTerj varchar(255), @CriteriaTerj2 varchar(255)
    SET @CriteriaTerj = (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'LOBR') 
    SET @CriteriaTerj2 = 
        (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'POLO') + ',' + 
        (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'LOBR') + ',' + 
        (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'OPC') */
	DECLARE @anonymize_ids bit
	SET @anonymize_ids = 0
	IF @par_vnesel_enabled = 1 and len(@par_vnesel_vnesel) > 0 BEGIN
		SET @anonymize_ids = dbo.gfn_AnonimizirajPodatke('frmparams_ppizbor', @par_vnesel_vnesel)
	END
     INSERT INTO     @Result 
     SELECT    DISTINCT
          P.ID_Cont, 
          P.ID_Pog,
          P.ID_Kupca, 
          P.Status,
          P.ID_Strm,
          P.ID_Kredpog,
          P.Nacin_leas,
          P.Dat_sklen,
          P.ID_ref,
          P.Pred_naj,
          P.Traj_naj,
          dbo.gfn_Xchange(@par_tecajnica_tecajnica, P.Net_nal, P.ID_tec, @par_tecajnica_datumtec) AS Net_nal,
          dbo.gfn_Xchange(@par_tecajnica_tecajnica, P.Vr_val, P.ID_tec, @par_tecajnica_datumtec) AS Vr_val,
          dbo.gfn_Xchange(@par_tecajnica_tecajnica, P.obrok1, P.ID_tec, @par_tecajnica_datumtec) AS Obrok1,
          dbo.gfn_Xchange(@par_tecajnica_tecajnica, P.Opcija, P.ID_tec, @par_tecajnica_datumtec) AS Opcija,
          p.id_rtip as id_rtip,
          P.Zap_opc as Zap_opc,
          P.Aneks as Aneks,
          REF.Naziv as Referent, 
          P.ID_Dob as ID_Dob,
          S.Naz_kr_kup as Dobavitelj,
          VO.ID_Grupe,    
          VO.naziv as vrsta_opreme,            
          p.id_tec,
          p.id_val,
          p.dat_1op,
          p.dat_2op,
          p.dat_3op,
          p.refinanc,
          C.Naz_kr_kup as Naz_kr_kup,
          case when VOS.SIFRA = 'FO' and @anonymize_ids = 1 then dbo.gfn_Anonimiziraj(C.EMSO, 4, 'r') else C.EMSO end as EMSO,
          C.Vr_osebe,
          C.Telefon, 
          C.Id_poste,
          C.Mesto,
          C.ulica, 
          C.Sif_dej,
          C.Id_skis,
          C.boniteta,
          1,
          C.skrbnik_1, S1.naz_kr_kup as Naz_skrbnik_1, C.skrbnik_2, S2.naz_kr_kup as Naz_skrbnik_2, c.dobavite, 
		  CASE WHEN @delo_old = 1 THEN ISNULL(PK.naziv, PKP.naz_kr_kup) ELSE c.delodajale END AS delodajale, 
		  C.email,
		  tr2.trr as Tr1, 
		  tr3.trr as Tr2, 
		  LTRIM(RTRIM(tr1.trr)) +  ' ' + LTRIM(RTRIM(C.Zr2)) + ' ' + LTRIM(RTRIM(C.Zr3)) AS ZR,
		  nc.no_id_kupca,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          null,null,null,null,
          P.kategorija,
          K.naziv, 
          null as znp_max_dat_obr_LPOD,
          null as znp_max_dat_zap_LPOD,
          null as bod_min_dat_zap_LPOD,
          null as traj_pog,
          @par_tecajnica_valuta AS id_val_s,
          @par_tecajnica_tecajnica AS id_tec_s,
          dbo.gfn_Xchange(@par_tecajnica_tecajnica, dbo.gfn_GetMarketValue(p.id_cont, @par_datum_today, p.dat_aktiv), P.ID_tec, @par_tecajnica_datumtec) AS trz_vred,
          p.id_obd,
          o.naziv as obdobja_naziv,
          P.id_svet,
          SV.naziv AS svetoval_naziv,
          0,0, C.kontakt, C.gsm 
    FROM dbo.Pogodba P
   INNER JOIN dbo.Partner C ON P.ID_kupca = C.ID_Kupca
   INNER JOIN dbo.Referent REF ON P.ID_Ref = REF.ID_Ref
   INNER JOIN dbo.Partner S ON P.ID_Dob = S.ID_Kupca
   INNER JOIN dbo.Vrst_opr VO ON P.ID_Vrste = VO.ID_Vrste
   INNER JOIN dbo.Kategor K ON K.kategorija = P.kategorija 
    LEFT JOIN dbo.Partner S1 ON C.skrbnik_1 = S1.id_kupca
    LEFT JOIN dbo.Partner S2 ON C.skrbnik_2 = S2.id_kupca
    LEFT JOIN dbo.obdobja O ON P.id_obd = O.id_obd
    LEFT JOIN dbo.svetoval SV ON P.id_svet = SV.id_svet
	LEFT JOIN dbo.gv_kontakt_delodajalec PK ON P.id_kupca = PK.id_kupca
	LEFT JOIN dbo.Partner PKP ON PK.id_kupca_k = PKP.id_kupca
	LEFT JOIN dbo.gv_NoOfContractsByCustomer nc ON C.id_kupca = nc.id_kupca
	LEFT OUTER JOIN dbo.partner_trr tr1 ON C.id_kupca = tr1.id_kupca and tr1.prioriteta = 1 and tr1.aktivnost = 'A'
	LEFT OUTER JOIN dbo.partner_trr tr2 ON C.id_kupca = tr2.id_kupca and tr2.prioriteta = 2 and tr2.aktivnost = 'A'
	LEFT OUTER JOIN dbo.partner_trr tr3 ON C.id_kupca = tr3.id_kupca and tr3.prioriteta = 3 and tr3.aktivnost = 'A'
	INNER JOIN dbo.VRST_OSE VOS on VOS.VR_OSEBE = C.vr_osebe
   WHERE (@par_pogodba_enabled = 0 OR P.ID_Pog LIKE @par_pogodba_pogodba)
     AND (@par_partner_enabled = 0 OR C.ID_Kupca = @par_partner_partner )
     AND (@par_skrbnikone_enabled = 0 OR S1.id_kupca = @par_skrbnikone)
     AND (1 = (CASE WHEN @par_aneks_enabled = 1 THEN (CASE WHEN @par_aneks_anekstype = 1 THEN (CASE WHEN CHARINDEX(P.aneks,@par_aneks_anekses) = 0 OR P.aneks = '' THEN 1 ELSE 0 END) ELSE (CASE WHEN CHARINDEX(P.aneks,@par_aneks_anekses) = 0 OR P.aneks = ''
 THEN 0 ELSE 1 END) END) ELSE 1 END)) 
     AND 1 = (CASE WHEN @par_akt_enabled = 1 THEN (CASE WHEN @par_akt_akttype = 1 THEN (CASE WHEN CHARINDEX(p.status_akt,@par_akt_akt) = 0 THEN 1 ELSE 0 END) ELSE (CASE WHEN CHARINDEX(p.status_akt,@par_akt_akt) = 0 THEN 0 ELSE 1 END) END) ELSE 1 END) 
     AND (@par_nacinleas_enabled = 0 OR CHARINDEX(P.nacin_leas,@par_nacinleas_nacinleas) > 0)
     AND (@par_Aktivirane_enabled = 0 OR Dat_aktiv <= @par_Aktivirane)
     AND (@par_strm_enabled = 0 OR charindex(p.id_strm, @par_strm_strm) > 0)
     AND (@par_obstoja_krov_pog_enabled = 0 OR P.id_cont IN (SELECT id_cont FROM dbo.krov_pog_pogodba WHERE id_krov_pog = @id_krov_pog))
     UPDATE    @Result
     SET       
          Debit =  CASE WHEN @par_zaprteterj_enabled = 0 THEN T.Debit ELSE t.debit_vklj_zaprto END ,
		  Kredit = CASE WHEN @par_zaprteterj_enabled = 0 THEN T.Kredit ELSE t.kredit_vklj_zaprto END, 
		  Saldo =  CASE WHEN @par_zaprteterj_enabled = 0 THEN T.Saldo ELSE T.saldo_vklj_zaprto END, 
          Obrokov = T.Obrokov,
          Od_Neto = T.Od_Neto,
          Od_Obresti = T.Od_Obresti,
          Od_Regist = T.Od_Regist,
          Od_Marza = T.Od_Marza,
          Od_Davek = T.Od_Davek,
		  Od_Robresti = T.Od_Robresti,
          Od_ONeto = T.Od_ONeto,
          Od_OObresti = T.Od_OObresti,
		  Od_ORobresti = T.Od_ORobresti,
		  Od_OMarza = T.Od_OMarza,
		  Od_ORegist = T.Od_ORegist,
          Od_ODavek = T.Od_ODavek,
          Zap_obr = T.Zap_obr,
          Se_bruto = T.Se_bruto,
          Se_neto = T.Se_neto,
          Se_obresti = T.Se_obresti,
          Se_marza = T.Se_marza,
          Se_regist = T.Se_regist,
          Se_fin_davek = T.Se_fin_davek,
		  Se_robresti = T.Se_robresti,
          max_dat_zap = T.max_dat_zap,
          min_dat_zap = T.min_dat_zap,
          max_dat_zap_now = T.max_dat_zap_now,
          znp_min_dat_zap_ALL = T.znp_min_dat_zap_ALL,
          znp_max_dni_ALL = T.znp_max_dni_ALL,
          znp_max_dat_obr_LPOD = T.znp_max_dat_obr_LPOD,
          znp_max_dat_zap_LPOD = T.znp_max_dat_zap_LPOD,
    bod_min_dat_zap_LPOD = T.bod_min_dat_zap_LPOD,
    bod_cnt_lobr = T.bod_cnt_lobr, 
     bod_cnt_all = T.bod_cnt_all,
     Zap_opc = CASE WHEN T.datum_odkupa is not null THEN datum_odkupa ELSE Zap_opc END
     FROM @Result AS R, 
     (
    SELECT    
        PP.id_cont, 
        MAX(PP.znp_max_zap_obr) AS Zap_obr,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_neto_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_Neto,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_obresti_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_Obresti,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_marza_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_Marza,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_regist_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_Regist,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_davek_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_Davek, 
		SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_robresti_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_Robresti,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_neto_OST + PP.znp_neto_LPOD - PP.znp_neto_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_ONeto,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_obresti_OST + PP.znp_obresti_LPOD - PP.znp_obresti_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_OObresti,
		SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_robresti_OST + PP.znp_robresti_LPOD - PP.znp_robresti_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_ORobresti,
		SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_marza_OST + PP.znp_marza_LPOD - PP.znp_marza_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_OMarza,
		SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_regist_OST + PP.znp_regist_LPOD - PP.znp_regist_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_ORegist,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_davek_OST + PP.znp_davek_LPOD - PP.znp_davek_LOBR, PP.ID_tec, @par_tecajnica_datumtec)) as Od_ODavek,
        SUM(znp_cnt_LOBR) as Obrokov, -- DOLGUJE
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_debit_LPOD + PP.znp_debit_OST, PP.ID_tec, @par_tecajnica_datumtec) ) AS Debit,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_kredit_LPOD + PP.znp_kredit_OST, PP.ID_tec, @par_tecajnica_datumtec) ) AS Kredit,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.znp_saldo_brut_LPOD + PP.znp_saldo_OST, PP.ID_tec, @par_tecajnica_datumtec) ) AS Saldo,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.debit_total - PP.bod_debit_brut_ALL, PP.ID_tec, @par_tecajnica_datumtec) ) AS debit_vklj_zaprto,
		SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.kredit_total, PP.ID_tec, @par_tecajnica_datumtec) ) AS kredit_vklj_zaprto,
		SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.saldo_total - PP.bod_debit_brut_ALL, PP.ID_tec, @par_tecajnica_datumtec) ) AS saldo_vklj_zaprto,
        MAX(max_dat_zap) as max_dat_zap,
        MIN(min_dat_zap) as min_dat_zap,
        MAX(max_dat_zap_now) as max_dat_zap_now,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_debit_brut_LPOD, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_Bruto, 
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_neto_LPOD, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_Neto,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_obresti_LPOD, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_Obresti,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_marza_LPOD, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_Marza,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_regist_LPOD, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_Regist,
        SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_findavek, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_fin_davek,
		SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, PP.bod_robresti_LPOD, PP.ID_tec, @par_tecajnica_datumtec)) AS Se_Robresti,
        MIN(znp_min_dat_zap_ALL) as znp_min_dat_zap_ALL, 
        MAX(znp_max_dni_ALL) as znp_max_dni_ALL,
        MAX(znp_max_dat_obr_LPOD) as znp_max_dat_obr_LPOD,
        MAX(znp_max_dat_zap_LPOD) as znp_max_dat_zap_LPOD,
        MIN(bod_min_dat_zap_LPOD) as bod_min_dat_zap_LPOD,
        MAX(bod_cnt_lobr) as bod_cnt_lobr, MAX(bod_cnt_all) as bod_cnt_all,
        MAX(datum_odkupa) as datum_odkupa
     FROM dbo.planp_ds PP
     GROUP BY id_cont
     ) AS T
     WHERE R.ID_Cont = T.ID_Cont
     IF @par_ZnesekObrok_enabled = 1
     BEGIN
          DELETE FROM @Result 
          WHERE ((Debit-Kredit < @par_Znesek) AND (Obrokov < @par_ObrokALI ))  OR (Obrokov < @par_Obrok) OR Debit = 0 -- s tem izloimo tiste, ki ne ustrezajo obdobju
     END
     --zaradi performanc je ta stavek posebej
     UPDATE    @Result
     SET  Obr_Pog = CASE WHEN  St_pogodb = 0 THEN 0 ELSE Obrokov / St_pogodb END,
          Proc_plac = CASE WHEN Debit = 0 THEN 0 ELSE Kredit/Debit*100 END,
          Skupaj = Saldo + Se_neto + Se_fin_davek,
          traj_pog = DATEDIFF(month, dat_sklen, max_dat_zap)
     RETURN
END