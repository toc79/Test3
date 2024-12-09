------------------------------------------------------------------------------------------------------------  
-- Procedure for show accounting schema   
--   
--  
-- History:  
-- 06.02.2012 BUG ID 29256 - move code from ex-function with the same name  
-- 09.07.2012 Igor&Jasna; MID 35714 - added condition that supplier is not auto dealer (kategorija3 = 'DA')- frame type RRE  
-- 05.03.2013 MID 38223 Jelena - exchange r.sum_znesek into f.id_tec in where condition (at the end) - currencies were different  
-- 21.03.2014 Jelena; MID 43659 - supported new frame_type DBA  
-- 11.04.2014 Jelena; MID 43659 - split code for frame_type DBA   
-- 06.08.2014 Jelena; Bug ID 31011 - added check to id_frame for frame_type DBA   
-- 18.06.2014 Jure; Bug 31753 - Added call of dbo.gfn_SummitPlacIzhData()  
-- 11.09.2015 Jure & Nataša ; BUG 31845 - Correction off RRE frame calculation  
-- 09.04.2018 Jelena; TID 12921 - GDPR - added param into gfn_SummitPlacIzhData  
------------------------------------------------------------------------------------------------------------  
  
--CREATE PROCEDURE [dbo].[grp_CheckFrameOverdraft]  
declare
 @plac_izh_list varchar(8000) = '46255, 46256',  
 @frame_type char(3) = 'DOB'
 --AS   
--BEGIN  
  
 select top 0 cast(0 as int) as id_plac_izh,cast('' as char(11)) as id_pog,id_val,id_tec,id_dob, id_frame  
 into #plac_candidates  
 from dbo.plac_izh  
  
 select id   
 into #id_plac_list  
 from dbo.gfn_GetTableFromList(@plac_izh_list)  
   
 IF @frame_type = 'DOB'  
 BEGIN  
  INSERT INTO #plac_candidates(id_plac_izh,id_pog,id_val,id_tec,id_dob, id_frame)  
  SELECT a.id_plac_izh, b.id_pog, t.id_val, a.id_tec, b.id_dob, a.id_frame  
  FROM  
   dbo.plac_izh a  
   INNER JOIN dbo.plac_izh_tip tp ON a.id_plac_izh_tip = tp.id_plac_izh_tip  
   INNER JOIN dbo.tecajnic t ON a.id_tec = t.id_tec  
   INNER JOIN dbo.pogodba b ON a.id_cont = b.id_cont  
   INNER JOIN dbo.nacini_l d on b.nacin_leas = d.nacin_leas  
   INNER JOIN dbo.partner e on b.id_dob = e.id_kupca  
   INNER JOIN #id_plac_list l on l.id = a.id_plac_izh  
  WHERE   
   a.id_vrste = 1 --placila dobaviteljem dbo.vrst_plac_izh  
   AND b.status_akt IN ('N', 'D')   
   AND tp.p1_je_racun = 0  
 END  
  
 IF @frame_type = 'DBA'  
 BEGIN  
  INSERT INTO #plac_candidates(id_plac_izh,id_pog,id_val,id_tec,id_dob, id_frame)  
  SELECT a.id_plac_izh, b.id_pog, t.id_val, a.id_tec, b.id_dob, a.id_frame  
  FROM  
   dbo.plac_izh a  
   INNER JOIN dbo.plac_izh_tip tp ON a.id_plac_izh_tip = tp.id_plac_izh_tip  
   INNER JOIN dbo.tecajnic t ON a.id_tec = t.id_tec  
   INNER JOIN dbo.pogodba b ON a.id_cont = b.id_cont  
   INNER JOIN dbo.nacini_l d on b.nacin_leas = d.nacin_leas  
   INNER JOIN dbo.partner e on b.id_dob = e.id_kupca  
   INNER JOIN #id_plac_list l on l.id = a.id_plac_izh  
  WHERE   
   a.id_vrste = 1 --placila dobaviteljem dbo.vrst_plac_izh  
   AND tp.p1_je_racun = 0  
 END  
   
 IF @frame_type = 'RRE'   
 BEGIN  
  INSERT INTO #plac_candidates(id_plac_izh,id_pog,id_val,id_tec,id_dob, id_frame)  
  SELECT   
   a.id_plac_izh, a.id_pog, a.id_val, a.id_tec, a.id_dob, a.id_frame  
  FROM  
   dbo.gfn_SummitPlacIzhData(1, null) as a  
   INNER JOIN #id_plac_list l on l.id = a.id_plac_izh  
 END  
  
  
 SELECT   
  n.id_plac_izh,   
  (dbo.gfn_GetFrameResidual(f.id_frame, NULL, f.id_tec, getdate()) - dbo.gfn_XChange(f.id_tec,r.sum_znesek,'000', getdate())) AS presezeno,   
  n.id_val, n.id_pog, ft.sif_frame_type, r.naz_kr_kup
  , f.*
  , ft.*
 FROM  
  dbo.frame_list f  
  INNER JOIN dbo.frame_type ft ON f.frame_type = ft.id_frame_type  
  INNER JOIN (  
	   SELECT e.naz_kr_kup,  
		   b.id_dob,  
		   SUM(dbo.gfn_XChange('000', a.znesek_dom, a.id_tec, a.datum))as sum_znesek  
	   FROM  
		dbo.plac_izh a  
		INNER JOIN dbo.plac_izh_tip tp ON a.id_plac_izh_tip = tp.id_plac_izh_tip  
		INNER JOIN dbo.tecajnic t ON a.id_tec = t.id_tec  
		INNER JOIN dbo.pogodba b ON a.id_cont = b.id_cont  
		INNER JOIN dbo.nacini_l d on b.nacin_leas = d.nacin_leas  
		INNER JOIN dbo.partner e on b.id_dob = e.id_kupca  
		INNER JOIN #plac_candidates l on l.id_plac_izh = a.id_plac_izh  
	   GROUP BY e.naz_kr_kup, b.id_dob) r ON f.id_kupca = r.id_dob  
  INNER JOIN #plac_candidates n ON n.id_dob = f.id_kupca  
 WHERE  
  ft.sif_frame_type = @frame_type  
  AND f.status_akt != 'Z'  
  AND f.znesek_dom is not null  
  AND (dbo.gfn_GetFrameResidual(f.id_frame, NULL, f.id_tec, getdate()) - dbo.gfn_XChange(f.id_tec,r.sum_znesek,'000', getdate())) < 0  
  AND (n.id_frame is null or n.id_frame = f.id_frame)  
    
    
 drop table #id_plac_list  
 drop table #plac_candidates  
    
--END  
  