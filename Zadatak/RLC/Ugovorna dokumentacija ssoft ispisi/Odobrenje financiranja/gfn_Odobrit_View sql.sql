------------------------------------------------------------------------------------------------------------
-- Function for listing approvals
-- Used in Odobrit_pregled form mostly
-- History:
-- 31.03.2006 Muri; created
-- 26.05.2006 Muri; added field T.id_val
-- 23.06.2006 Vilko; added field O.nacin_leas
-- 06.07.2006 Muri; spremenil LEFT join na userje
-- 25.07.2006 Vilko; Bug ID 26078 - fixed date conditions - datime value should be converted to date
-- 17.10.2006 Vilko; Bug ID 26333 - added field osnova
-- 18.10.2006 Vilko; Bug ID 26251 - added new parameter for offer and change parameters for dates
-- 05.01.2007 Vilko; Maintenance ID 3722 - added field id_frame
-- 29.06.2007 Jelena; Maintenance ID 9192 - added fields vrsta_opreme and vr_osebe
-- 07.12.2007 Vilko; Bug ID 26990 - added fields id_rtip, obr_merak, fix_delk
-- 18.03.2008 Jure; BUG 26774 - added oznacen field for multiselecting purposes
-- 26.05.2010 Jure; BUG 28382 - added left join on gv_PEval_LastEvaluation
-- 09.03.2011 Vilko; MID 27829 - added field a.id_odobrit_veza and a.id_doc_veza
-- 11.05.2011 Jasna; BUG ID 28861 - added new parameter id_kupca
-- 23.05.2013 Jost; Task id: 7386 - added 'intg_ext_id', made left join to intg_dsa_ponudba
-- 19.09.2013 Uros; Bug 30369 - changed join to intg_dsa_ponudba
-- 27.09.2013 Jost; Task ID 7520 - added fields id_cont, id_pog, id_odobrit_tip, odobrit_tip_naziv, id_odobrit_kateg, odobrit_kateg_naziv and made 3 new LEFT JOINS
-- 30.09.2013 Uros; Bug 30369 - changed join to intg_dsa_ponudba
-- 30.09.2013 Jost; Task ID 7520 - added additional input parameters: 'pogodba','tip_odobritve','kateg_odobrit'
-- 04.10.2013 Uros; Bug 30369 - changed join to intg_dsa_ponudba
-- 05.03.2014 Jost; Bug id 30604 - change the way how conditions for 'odobrit_tip' and 'odobrit_kateg' is checked
-- 16.05.2016 Jasna; MID 56457 - aded kategorija1 and kategorija2
-- 28.06.2016 Natasa; TaskID 9481 - added field status_date to result
-- 21.11.2016 Blaz; MID 59366 - added fields kategorija1_naziv and kategorija2_naziv
------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[gfn_Odobrit_View] 
(
@par_Ponudba_enabled as bit,
@par_Ponudba_criteria as varchar(8000),
@par_Partner_enabled as bit,
@par_Partner_criteria as varchar(8000),
@par_Referent_enabled as bit,
@par_Referent_criteria as char(10),
@par_Dodeljeno_enabled as bit,
@par_Dodeljeno_criteria as char(10),
@par_Status_enabled as bit,
@par_Status_criteria as char(4000),
@par_Date_started_enabled as bit,
@par_Date_started_from_criteria as datetime,
@par_Date_started_to_criteria as datetime,
@par_Date_lastchange_enabled as bit,
@par_Date_lastchange_from_criteria as datetime,
@par_Date_lastchange_to_criteria as datetime,
@par_Date_planned_enabled as bit,
@par_Date_planned_from_criteria as datetime,
@par_Date_planned_to_criteria as datetime,
@par_Date_active_enabled as bit,
@par_OdobritTip_enabled as bit,
@par_OdobritTip_criteria as char(8000),
@par_OdobritKateg_enabled as bit,
@par_OdobritKateg_criteria as char(8000),
@par_Pogodba_enabled as bit,
@par_Pogodba_criteria as char(11)
)
RETURNS TABLE	
AS
RETURN (
SELECT CAST(0 AS bit) AS oznacen,
	   a.id_document,
       a.id_process,
       a.foreign_document,
       a.date_wf_started,
       a.date_wf_finished,
       a.date_wf_planned,
       a.id_status,
       a.date_last_status_change,
       a.date_last_change,
       a.username_last_change,
       a.assigned_to,
       a.current_comment,
       a.process_title,
       a.process_description,
       a.status_title,
       a.status_description,
       a.status_check_assigner,
       a.status_is_start,
       a.status_is_end,
       a.assigned_to_full_name,
       a.username_last_change_to_full_name,
       a.username_referent_to_full_name,
       a.id_odobrit,
       a.aktivna,
       a.id_pon,
       a.id_kupca,
       a.id_doc,
       a.kupec_naziv,
       a.id_dobavitelj,
       a.dobavitelj_naziv,
       a.pred_naj,
       a.Ostanek_dolga,   -- ostanek dolga
       a.ZNPL, -- zapadlo neplačano (stare pogodbe)
       a.BOD_Glav, -- bodoča glavnica (stare pogodbe)
       a.Obligo,
       a.Skupaj,
       a.vr_val,
       a.prv_obr,
       a.net_nal,
       a.dat_pricak,
       a.referent,
       a.Znesek_DDV,
       a.nacin_leas,
       a.osnova,
       a.id_val,
       a.id_frame,
       a.vrsta_opreme,
       a.vr_osebe,
       a.obr_merak,
       a.id_rtip,
       a.fix_delk,
       b.cust_ratin,
       b.coll_ratin,
       b.oall_ratin,
       b.dat_eval,
       a.id_odobrit_veza,
       a.id_doc_veza,
       INTG_PON.intg_ext_id,
       p.id_cont as id_cont,
       p.id_pog as id_pog,
       ot.id_odobrit_tip as id_odobrit_tip,
       ot.naziv as odobrit_tip_naziv,
       ok.id_odobrit_kateg as id_odobrit_kateg,
       ok.naziv as odobrit_kateg_naziv,
       a.kategorija1 as kategorija1,
       a.kategorija2 as kategorija2,
       a.status_date,
	   CONVERT(varchar(240), GR1.VALUE) as kategorija1_naziv,
	   CONVERT(varchar(240), GR2.VALUE) as kategorija2_naziv
  FROM dbo.gv_ObstojaOdobrit AS a
  LEFT JOIN dbo.gv_PEval_LastEvaluation AS b ON a.id_kupca = b.id_kupca
  LEFT JOIN dbo.Pogodba p on p.id_cont = a.id_cont
  LEFT JOIN dbo.odobrit_tip ot on ot.id_odobrit_tip = a.id_odobrit_tip
  LEFT JOIN dbo.odobrit_kateg ok on ok.id_odobrit_kateg = a.id_odobrit_kateg
  LEFT JOIN dbo.intg_dsa_ponudba INTG_PON on a.id_pon = INTG_PON.id_pon and rtrim(ltrim(INTG_PON.id_pon)) != ''
  LEFT JOIN dbo.GENERAL_REGISTER GR1 on a.kategorija1 = GR1.ID_KEY and GR1.ID_REGISTER = 'ODOBRIT_KATEG1'
  LEFT JOIN dbo.GENERAL_REGISTER GR2 on a.kategorija2 = GR2.ID_KEY and GR2.ID_REGISTER = 'ODOBRIT_KATEG2'
  --LEFT JOIN (SELECT id_pon,intg_ext_id from dbo.intg_dsa_ponudba WHERE rtrim(ltrim(id_pon)) != '') as INTG_PON on a.id_pon = INTG_PON.id_pon
 WHERE (@par_Ponudba_enabled = 0 OR a.id_pon LIKE @par_Ponudba_criteria)	
   AND (@par_Partner_enabled = 0 OR a.id_kupca = @par_Partner_criteria)
   AND (@par_Referent_enabled = 0 OR a.referent = @par_Referent_criteria)
   AND (@par_Dodeljeno_enabled = 0 OR a.assigned_to = @par_Dodeljeno_criteria)
   AND (@par_Status_enabled = 0 OR CHARINDEX(a.id_status, @par_Status_criteria) > 0)
   AND (@par_Date_started_enabled = 0 OR dbo.gfn_ConvertDateTime(a.date_wf_started) BETWEEN @par_Date_started_from_criteria AND @par_Date_started_to_criteria)
   AND (@par_Date_lastchange_enabled = 0 OR dbo.gfn_ConvertDateTime(a.date_last_status_change) BETWEEN @par_Date_lastchange_from_criteria AND @par_Date_lastchange_to_criteria)
   AND (@par_Date_planned_enabled = 0 OR dbo.gfn_ConvertDateTime(a.date_wf_planned) BETWEEN @par_Date_planned_from_criteria AND @par_Date_planned_to_criteria)
   AND (@par_Date_active_enabled = 0 OR a.aktivna = 1) 
   AND (@par_OdobritTip_enabled = 0 OR a.id_odobrit_tip in (select * from dbo.gfn_split_ids(@par_OdobritTip_criteria,',')))
   AND (@par_OdobritKateg_enabled = 0 OR a.id_odobrit_kateg in (select * from dbo.gfn_split_ids(@par_OdobritKateg_criteria,',')))
   AND (@par_Pogodba_enabled = 0 OR p.id_pog LIKE @par_Pogodba_criteria)
)