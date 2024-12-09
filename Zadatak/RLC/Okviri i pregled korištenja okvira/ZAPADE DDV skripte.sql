--USE_NOVA_HLB
--select * from TECAJNIC
--select  planp_ds_tec, * from loc_nast
--UPDATE loc_nast SET planp_ds_tec ='001'

--select * from custom_settings where code like 'Nova.Le.BookVATDueEvent'
--UPDATE custom_settings SET val='0' where code like 'Nova.Le.BookVATDueEvent'

select CASE WHEN nl.leas_kred = 'L' AND nl.tip_knjizenja = '2' AND nl.finbruto = 0 AND nl.ol_na_nacin_fl = 0 THEN a.poknj_nezap_davek_LPOD ELSE 0 END as poknj_nezap_davek_LPOD,
	CASE WHEN nl.leas_kred = 'L' AND nl.tip_knjizenja = '2' AND nl.finbruto = 0 AND nl.ol_na_nacin_fl = 0 THEN a.bod_davek_lpod ELSE 0 END as bod_davek_lpod,
	bod_davek_lpod, poknj_nezap_davek_lpod, * 
from planp_ds a
join pogodba b on a.id_cont=b.id_cont
join nacini_l nl on b.nacin_leas = nl.nacin_leas
where a.id_cont = 19808

select CASE WHEN nl.leas_kred = 'L' AND nl.tip_knjizenja = '2' AND nl.finbruto = 0 AND nl.ol_na_nacin_fl = 0 THEN a.poknj_nezap_davek_LPOD ELSE 0 END as poknj_nezap_davek_LPOD,
	CASE WHEN nl.leas_kred = 'L' AND nl.tip_knjizenja = '2' AND nl.finbruto = 0 AND nl.ol_na_nacin_fl = 0 THEN a.bod_davek_lpod ELSE 0 END as bod_davek_lpod,
	bod_davek_lpod, poknj_nezap_davek_lpod, * 
from planp_ds a
join pogodba b on a.id_cont=b.id_cont
join nacini_l nl on b.nacin_leas = nl.nacin_leas
where a.id_cont = 19809

--select * from PLAN_KNJ where id_dogodka='ZAPADE_DDV'

--select * from PLAN_KNJ where  DELI_TERJATVE like '%D%' AND nacin_leas='OJ'  --

--INSERT INTO dbo.PLAN_KNJ(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES('FF',NULL,'+','ZAPADE_DDV','D','#TERJOBR','D','$DAVEK','C','DOSPIJEÆE POREZ','IFA')
--INSERT INTO dbo.PLAN_KNJ(NACIN_LEAS,ID_TERJ,AKT_STORNO,ID_DOGODKA,DELI_TERJATVE,KONTO,STRAN_K,PROTIKONTO,STRAN_P,OPIS,VRSTA_DOK) VALUES('FF',NULL,'-','ZAPADE_DDV','D','#TERJOBR','D','#PREHDDV','C','DOSPIJEÆE  POREZ','IFA')
