/*--------------------------------------------------------------------------------------------------------
 View: This view represents recovery events 
 History:
 03.12.2007 Vilko; created
 10.02.2009 Vilko; Task ID 5491 - added field id_vrs_dog and naz_id_vrs_dog	
 24.02.2009 Vilko; Bug ID 27696 - added field ext_id and ext_type
 12.11.2009 Vilko; MID 23053 - added fields aneks, status_akt, stauts, id_strm, vr_osebe, znp_max_dni_all, saldo, se_neto, obligo, bod_findavek
 24.02.2010 IgorS; MID 24257 - added column narediti
 16.05.2011 Vilko; Task ID 6094 - added field id_ss_postopek
 28.05.2012 MatjazB; Task 6805 - added filed opis_dog_short and opombe_short
 02.01.2013 Josip; Task ID 7173 - added ol_na_nacin_fl
 17.08.2015 Andrej; MID 51736 - added datum_dogodka
 18.08.2015 Andrej; MID 51736 - added function ISNULL to field datum_dogodka
 25.08.2016 Blaz; MID 58010 - added a convertion to home currency
--------------------------------------------------------------------------------------------------------*/
CREATE VIEW [dbo].[gv_SS_Dogodek_View]
AS
SELECT D.id_dog, D.id_cont, D.id_kupca, D.dat_vnosa, D.vnesel, D.rok, D.izvedeno, D.opis_dog, D.to_do, D.kont_oseba, D.tel_ko, 
       D.obdeluje, D.zakljucil, D.opombe, D.detektiv, D.odvzem, D.skladisce, D.prodano, D.pris_porav, D.stecaj, D.odvetnik, D.tozba, 
       D.odpis_terj, D.predano_a, D.vrnjeno_a, D.zakljuc_a, D.id_agenc, D.id_tip_dog, D.ukraden, D.zaklenjen,  
       D.dat_dolg, D.dat_dogov, D.dat_odzak, D.gsm_ko, C.id_pog, isnull(C.pred_naj, space(len(C.pred_naj))) AS pred_naj, 
       C.traj_naj, C.dat_sklen, P.naz_kr_kup AS naz_id_kupca, P.ulica, P.mesto, P.opombe AS opombe_id_kupca, T.opis AS naz_id_tip_dog, 
       A.opis AS naz_id_agenc, UO.user_desc AS u_obdeluje, UV.user_desc AS u_vnesel, UV.is_support AS logassupportuser,
       D.id_vrs_dog, V.opis AS naz_id_vrs_dog, D.ext_id, D.ext_type, C.aneks, C.status_akt, C.status, C.id_strm, P.vr_osebe,
       PP.znp_max_dni_all, left(D.to_do, 235) as narediti,
       D.id_ss_postopek, CAST(D.opis_dog AS varchar(239)) AS opis_dog_short, CAST(D.opombe AS varchar(239)) AS opombe_short, 
       ISNULL(D.datum_dogodka, D.DAT_VNOSA) AS datum_dogodka,
       (SELECT DOM_VALUTA FROM NASTAVIT) as valuta,
       (dbo.gfn_Xchange((SELECT SIF_BANK FROM NASTAVIT), PP.saldo + PP.se_neto, '000', getdate())) AS obligo,
       (dbo.gfn_Xchange((SELECT SIF_BANK FROM NASTAVIT), D.dolg_dat_d, '000', getdate())) AS dolg_dat_d,
       (dbo.gfn_Xchange((SELECT SIF_BANK FROM NASTAVIT), D.plac_dogov, '000', getdate())) AS plac_dogov,
       (dbo.gfn_Xchange((SELECT SIF_BANK FROM NASTAVIT), PP.saldo, '000', getdate())) AS saldo,
       (dbo.gfn_Xchange((SELECT SIF_BANK FROM NASTAVIT), PP.se_neto, '000', getdate())) AS se_neto,
       (dbo.gfn_Xchange((SELECT SIF_BANK FROM NASTAVIT), PP.bod_findavek, '000', getdate())) AS bod_findavek
  FROM dbo.ss_dogodek AS D 
  LEFT JOIN dbo.pogodba AS C ON D.id_cont = C.id_cont 
 INNER JOIN dbo.partner AS P ON D.id_kupca = P.id_kupca 
 INNER JOIN dbo.ss_tipi_dog AS T ON D.id_tip_dog = T.id_tip_dog 
  LEFT JOIN dbo.ss_agencije AS A ON D.id_agenc = A.id_agenc 
 INNER JOIN dbo.users AS UO ON D.obdeluje = UO.username 
 INNER JOIN dbo.users AS UV ON D.vnesel = UV.username
  LEFT JOIN dbo.ss_vrst_dog V ON D.id_vrs_dog = V.id_vrs_dog
  LEFT JOIN (SELECT DS.id_cont,
                    MAX(DS.znp_max_dni_all) AS znp_max_dni_all,
                    SUM(dbo.gfn_Xchange('000', DS.znp_saldo_brut_ALL, DS.id_tec, getdate())) AS saldo,
                    SUM(dbo.gfn_Xchange('000', DS.bod_neto_LPOD, DS.id_tec, getdate())) AS se_neto,
                    (CASE WHEN N.tip_knjizenja = 2 and N.ol_na_nacin_fl = 0 THEN SUM(dbo.gfn_Xchange('000', DS.bod_davek, DS.id_tec, getdate())) ELSE 0 END) AS bod_findavek
               FROM dbo.planp_ds DS
              INNER JOIN dbo.pogodba C ON DS.id_cont = C.id_cont
              INNER JOIN dbo.nacini_l N ON C.nacin_leas = N.nacin_leas
              GROUP BY DS.id_cont, N.tip_knjizenja, n.ol_na_nacin_fl) AS PP ON D.id_cont = PP.id_cont