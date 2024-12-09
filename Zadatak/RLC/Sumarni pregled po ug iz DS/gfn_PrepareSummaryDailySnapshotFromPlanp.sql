---------------------------------------------------------------
-- This function returns open claims for prepare daily snapshot
--
-- History:
-- 07.03.2012 MatjazB; Task 6325 - created
-- 19.11.2012 Ales; MR 36643 - added field datum_odkupa
-- 27.03.2013 Ales; MR 36643 - changed selected field (datum_zap -> datum_dok) for value of field datum_odkupa
-- 23.04.2013 Ales; MR 39639 - added fields znp_obresti_OST, znp_robresti_OST, znp_regist_OST and znp_marza_OST
-- 21.05.2014 Jelena; Task ID 8059 - added zap_nepoknj_robresti_opc
-- 13.01.2015 Josip; Task ID 8460 - added fields dat_zap_odkupa, max_datum_dok_lobr, max_dat_zap_lobr
-- 26.05.2015 Jure: TASK 8680 - Added support for claim OOBR when interpret longterm claims ONLY.
---------------------------------------------------------------
CREATE   FUNCTION [dbo].[gfn_PrepareSummaryDailySnapshotFromPlanp] (@today datetime)
RETURNS table AS
RETURN (
    SELECT	
        pp.id_kupca, pp.id_cont, pp.id_tec, 
        -- zapadle neplacane terjatve
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_LPOD,
        SUM(CASE WHEN PP.Dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.Saldo*(PP.Debit-PP.Davek)/PP.Debit ELSE 0 END) AS znp_saldo_net_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.debit ELSE 0 END) AS znp_debit_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.kredit ELSE 0 END) AS znp_kredit_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.saldo/pp.debit)*PP.neto ELSE 0 END) AS znp_neto_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.saldo/pp.debit)*PP.obresti ELSE 0 END) AS znp_obresti_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.saldo/pp.debit)*PP.marza ELSE 0 END) AS znp_marza_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.saldo/pp.debit)*PP.regist ELSE 0 END) AS znp_regist_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.saldo/pp.debit)*PP.robresti ELSE 0 END) AS znp_robresti_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.saldo/pp.debit)*PP.davek ELSE 0 END) AS znp_davek_LPOD,
        MIN(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.dat_zap ELSE null END) AS znp_min_dat_zap_LPOD,
        MAX(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN datediff(dd, PP.dat_zap, @today) ELSE 0 END) AS znp_max_dni_LPOD,    
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR') THEN PP.debit ELSE 0 END) AS znp_debit_LOBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR') THEN PP.kredit ELSE 0 END) AS znp_kredit_LOBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR') THEN (PP.saldo/pp.debit)*PP.neto ELSE 0 END) AS znp_neto_LOBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR') THEN (PP.saldo/pp.debit)*PP.obresti ELSE 0 END) AS znp_obresti_LOBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR') THEN (PP.saldo/pp.debit)*PP.marza ELSE 0 END) AS znp_marza_LOBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR') THEN (PP.saldo/pp.debit)*PP.regist ELSE 0 END) AS znp_regist_LOBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR') THEN (PP.saldo/pp.debit)*PP.robresti ELSE 0 END) AS znp_robresti_LOBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR') THEN (PP.saldo/pp.debit)*PP.davek ELSE 0 END) AS znp_davek_LOBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj = 'LOBR' AND PP.saldo > 0 THEN PP.saldo/PP.debit ELSE 0 END) AS znp_cnt_LOBR,
        MAX(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj = 'LOBR' THEN PP.zap_obr ELSE 0 END) AS ZNP_MAX_ZAP_OBR,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	PP.saldo ELSE 0 END) AS znp_saldo_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	PP.debit ELSE 0 END) AS znp_debit_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	PP.kredit ELSE 0 END) AS znp_kredit_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	(PP.saldo/pp.debit)*PP.neto ELSE 0 END) AS znp_neto_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	(PP.saldo/pp.debit)*PP.davek ELSE 0 END) AS znp_davek_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	(PP.saldo/pp.debit)*PP.obresti ELSE 0 END) AS znp_obresti_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	(PP.saldo/pp.debit)*PP.robresti ELSE 0 END) AS znp_robresti_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	(PP.saldo/pp.debit)*PP.regist ELSE 0 END) AS znp_regist_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN	(PP.saldo/pp.debit)*PP.marza ELSE 0 END) AS znp_marza_OST,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND datediff(dd, PP.dat_zap, @today) < 15 THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL_15,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND (datediff(dd, PP.dat_zap, @today) BETWEEN 15 AND 29) THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL_30,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND (datediff(dd, PP.dat_zap, @today) BETWEEN 30 AND 59) THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL_60,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND (datediff(dd, PP.dat_zap, @today) BETWEEN 60 AND 89) THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL_90,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND (datediff(dd, PP.dat_zap, @today) BETWEEN 90 AND 119) THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL_120,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND (datediff(dd, PP.dat_zap, @today) BETWEEN 120 AND 179) THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL_180,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND (datediff(dd, PP.dat_zap, @today) BETWEEN 180 AND 359) THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL_360,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND datediff(dd, PP.dat_zap, @today) >= 360 THEN PP.saldo ELSE 0 END) AS znp_saldo_brut_ALL_360_PLUS,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' THEN PP.Saldo*(PP.Debit-PP.Davek)/PP.Debit ELSE 0 END) AS znp_saldo_net_ALL,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' THEN PP.neto ELSE 0 END) AS znp_neto_ALL,
        MIN(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' THEN PP.dat_zap ELSE null END) AS znp_min_dat_zap_ALL,
        MAX(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' THEN datediff(dd, PP.dat_zap, @today) ELSE 0 END) AS znp_max_dni_ALL,    
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('DDV') THEN PP.saldo ELSE 0 END) AS znp_saldo_ddv,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('DDV') THEN PP.debit ELSE 0 END) AS znp_debit_ddv,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('DDV') THEN PP.kredit ELSE 0 END) AS znp_kredit_ddv,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.zaprto = '*' AND VT.sif_terj IN ('OPC') THEN PP.neto ELSE 0 END) AS zap_nepoknj_neto_opc,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.zaprto = '*' AND VT.sif_terj IN ('OPC') THEN PP.debit ELSE 0 END) AS zap_nepoknj_debit_opc,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.zaprto = '*' AND VT.sif_terj IN ('OPC') THEN PP.robresti ELSE 0 END) AS zap_nepoknj_robresti_opc,
        -- vse nezapadle terjatve + zapadle nepoknjizene -> bodoci del
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.saldo ELSE 0 END) AS bod_debit_brut_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.saldo * (PP.debit-PP.davek)/PP.debit ELSE 0 END) AS bod_debit_net_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.neto * (saldo/debit) ELSE 0 END) AS bod_neto_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.obresti * (saldo/debit) ELSE 0 END) AS bod_obresti_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.marza * (saldo/debit) ELSE 0 END) AS bod_marza_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.regist * (saldo/debit) ELSE 0 END) AS bod_regist_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.robresti * (saldo/debit) ELSE 0 END) AS bod_robresti_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') AND NL.base_nl IS NOT null THEN PP.davek * (saldo/debit) ELSE 0 END) AS bod_findavek,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND NL.base_nl IS null THEN PP.davek * (saldo/debit) ELSE 0 END) AS bod_davek,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.debit-PP.davek) * (saldo/debit) ELSE 0 END) AS bod_OST,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') THEN PP.saldo ELSE 0 END) AS bod_debit_brut_ALL,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') THEN PP.Saldo*(PP.Debit-PP.Davek)/PP.Debit ELSE 0 END) AS bod_debit_net_ALL,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.davek * (saldo/debit) ELSE 0 END) AS bod_davek_LPOD,
        -- poknjizene nezapadle terjatve
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.saldo ELSE 0 END) AS poknj_nezap_debit_brut_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.saldo*(PP.debit-PP.davek)/PP.debit ELSE 0 END) AS poknj_nezap_debit_net_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.neto * (saldo/debit) ELSE 0 END) AS poknj_nezap_neto_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.obresti * (saldo/debit) ELSE 0 END) AS poknj_nezap_obresti_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.marza * (saldo/debit) ELSE 0 END) AS poknj_nezap_marza_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.regist * (saldo/debit) ELSE 0 END) AS poknj_nezap_regist_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.robresti * (saldo/debit) ELSE 0 END) AS poknj_nezap_robresti_LPOD,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') AND NL.base_nl IS NOT null THEN PP.davek * (saldo/debit) ELSE 0 END) AS poknj_nezap_findavek,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND NL.base_nl IS null THEN PP.davek * (saldo/debit) ELSE 0 END) AS poknj_nezap_davek,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.debit-PP.davek) * (saldo/debit) ELSE 0 END) AS poknj_nezap_OST,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') THEN PP.saldo ELSE 0 END) AS poknj_nezap_debit_brut_ALL,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') THEN PP.Saldo*(PP.Debit-PP.Davek)/PP.Debit ELSE 0 END) AS poknj_nezap_debit_net_ALL,
        SUM(CASE WHEN (PP.dat_zap > @today AND PP.evident = '*') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.davek * (saldo/debit) ELSE 0 END) AS poknj_nezap_davek_LPOD,
        -- nepoknjizene zapadle terjatve
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.saldo ELSE 0 END) AS nepoknj_zap_debit_brut_LPOD,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.saldo*(PP.debit-PP.davek)/PP.debit ELSE 0 END) AS nepoknj_zap_debit_net_LPOD,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.neto * (saldo/debit) ELSE 0 END) AS nepoknj_zap_neto_LPOD,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.obresti * (saldo/debit) ELSE 0 END) AS nepoknj_zap_obresti_LPOD,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.marza * (saldo/debit) ELSE 0 END) AS nepoknj_zap_marza_LPOD,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.regist * (saldo/debit) ELSE 0 END) AS nepoknj_zap_regist_LPOD,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.robresti * (saldo/debit) ELSE 0 END) AS nepoknj_zap_robresti_LPOD,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') AND NL.base_nl IS NOT null THEN PP.davek * (saldo/debit) ELSE 0 END) AS nepoknj_zap_findavek,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND NL.base_nl IS null THEN PP.davek * (saldo/debit) ELSE 0 END) AS nepoknj_zap_davek,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj NOT IN ('LOBR','OPC','POLO','DDV','OOBR') THEN (PP.debit-PP.davek) * (saldo/debit) ELSE 0 END) AS nepoknj_zap_OST,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') THEN PP.saldo ELSE 0 END) AS nepoknj_zap_debit_brut_ALL,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') THEN PP.Saldo*(PP.Debit-PP.Davek)/PP.Debit ELSE 0 END) AS nepoknj_zap_debit_net_ALL,
        SUM(CASE WHEN (PP.dat_zap <= @today AND PP.evident = '') AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.davek * (saldo/debit) ELSE 0 END) AS nepoknj_zap_davek_LPOD,
        -- ostalo
        MAX (PP.Dat_zap) AS max_dat_zap,
        MAX (PP.datum_dok) AS max_datum_dok,
        MIN (PP.Dat_zap) AS min_dat_zap,
        MIN (PP.datum_dok) AS min_datum_dok,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') AND VT.sif_terj = 'LOBR' THEN 1 ELSE 0 END) AS bod_cnt_LOBR,
        SUM(CASE WHEN (PP.dat_zap > @today OR PP.evident = '') THEN 1 ELSE 0 END) AS bod_cnt_ALL,
        SUM(PP.debit) AS debit,
        SUM(PP.kredit) AS kredit,
        SUM(PP.saldo) AS saldo,
        MAX(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.dat_zap ELSE null END) AS znp_max_dat_zap_LPOD,
        MAX(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.dat_obr ELSE null END) AS znp_max_dat_obr_LPOD,
        MIN(CASE WHEN PP.dat_zap > @today AND PP.evident = '' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV','OOBR') THEN PP.dat_zap ELSE null END) AS bod_min_dat_zap_LPOD,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' THEN 1 ELSE 0 END) AS znp_count_ALL,
        SUM(CASE WHEN PP.dat_zap <= @today AND PP.evident = '*' AND VT.sif_terj IN ('LOBR','OPC','POLO','DDV') THEN 1 ELSE 0 END) AS znp_count_LOBR,
        
        MAX(CASE WHEN vt.sif_terj = 'OPC' THEN pp.datum_dok ELSE null END) AS datum_odkupa,
        MAX(CASE WHEN vt.sif_terj = 'OPC' THEN pp.dat_zap ELSE null END) AS dat_zap_odkupa, 
        MAX(CASE WHEN vt.sif_terj = 'LOBR' THEN pp.datum_dok ELSE null END) AS max_datum_dok_lobr, 
        MAX(CASE WHEN vt.sif_terj = 'LOBR' THEN pp.dat_zap ELSE null END) AS max_dat_zap_lobr
    FROM 
        dbo.planp pp
        INNER JOIN dbo.vrst_ter vt ON pp.id_terj = vt.id_terj
        INNER JOIN dbo.nacini_l nl ON pp.nacin_leas = nl.nacin_leas 
    WHERE pp.debit > 0 and pp.zaprto <> 'Z'
    GROUP BY pp.id_cont, pp.id_kupca, pp.id_tec
)