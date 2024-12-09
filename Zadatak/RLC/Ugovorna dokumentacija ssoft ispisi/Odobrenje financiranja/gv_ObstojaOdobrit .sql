----------------------------------------------------------------------------------------------------------
-- View: used for function gfn_Odobrit_View
--
-- History:
-- 20.10.2006 Vilko; created	
-- 05.01.2007 Vilko; Maintenance ID 3722 - added field O.id_frame
-- 29.06.2007 Jelena; Maintenance ID 9192 - added fields vrsta_opreme and vr_osebe
-- 07.12.2007 Vilko; Bug ID 26990 - added fields F.id_rtip, F.obr_merak, F.fix_delk
-- 09.03.2011 Vilko; MID 27829 - added field o.id_odobrit_veza and id_doc_veza
-- 27.09.2013 Jost; Task ID 7520 - added fields id_cont, id_odobrit_tip, id_odobrit_kateg
-- 13.06.2014 Uros; Bug 30999 - added field id_kupca_pl
-- 16.05.2016 Jasna; MID 56457 -- added kategorija1 and kategorija2
-- 28.06.2016 Natasa; TaskID 9481 - added field status_date to result 
----------------------------------------------------------------------------------------------------------
CREATE VIEW [dbo].[gv_ObstojaOdobrit]
AS
SELECT D.id_document,
       D.id_process,
       D.foreign_document,
       D.date_wf_started,
       D.date_wf_finished,
       D.date_wf_planned,
       D.id_status,
       D.date_last_status_change,
       D.date_last_change,
       D.username_last_change,
       D.assigned_to,
       D.current_comment,
       D.status_date,  	
       P.title as process_title,
       P.description as process_description,
       S.title as status_title,
       S.description as status_description,
       S.check_assigner as status_check_assigner,
       S.is_start as status_is_start,
       S.is_end as status_is_end,
       isnull(U_AS.USER_DESC, D.assigned_to) as assigned_to_full_name,
       isnull(U_LC.USER_DESC, D.username_last_change) as username_last_change_to_full_name,
       isnull(U_RE.USER_DESC, O.referent) as username_referent_to_full_name,
       O.id_odobrit,
       O.aktivna,
       O.id_pon,
       O.id_kupca,
       O.id_doc,
       K1.Naz_kr_kup as kupec_naziv,
       O.id_dobavitelj,
       D1.Naz_kr_kup as dobavitelj_naziv,
       O.pred_naj,
       O.Ostanek_dolga,   -- ostanek dolga
       O.ZNPL, -- zapadlo neplačano (stare pogodbe)
       O.BOD_Glav, -- bodoča glavnica (stare pogodbe)
       O.Obligo,
       O.ZNPL + O.BOD_Glav + O.Ostanek_Dolga as Skupaj,
       O.vr_val,
       O.prv_obr,
       O.net_nal,
       O.dat_pricak,
       O.referent,
       O.ddv as Znesek_DDV,
       O.nacin_leas,
       O.osnova,
       T.id_val,
       O.id_frame,
       V.naziv  as vrsta_opreme,
       K1.vr_osebe,
       F.obr_merak,
       F.id_rtip,
       F.obr_merak - (F.dej_obr - F.fix_del) as fix_delk,
       O.id_odobrit_veza,
       O1.id_doc AS id_doc_veza,
       O.id_cont as id_cont,
       O.id_odobrit_tip as id_odobrit_tip,
       O.id_odobrit_kateg as id_odobrit_kateg,
	   O.id_kupca_pl,
	   O.kategorija1,
	   O.kategorija2
  FROM dbo.WF_Document D
 INNER JOIN dbo.Odobrit O ON D.foreign_document = O.id_odobrit
 INNER JOIN dbo.WF_Process P ON D.id_process = P.id_process
 INNER JOIN dbo.WF_Status S ON D.id_status = S.id_status AND D.id_process = S.id_process
 INNER JOIN dbo.Tecajnic T ON O.id_tec = T.id_tec
  LEFT JOIN dbo.Users U_AS ON D.assigned_to = U_AS.USERNAME
  LEFT JOIN dbo.Users U_LC ON D.username_last_change = U_LC.USERNAME
  LEFT JOIN dbo.Users U_RE ON O.referent = U_RE.USERNAME	
 INNER JOIN dbo.Partner K1 ON O.id_kupca = K1.id_kupca
  LEFT JOIN dbo.Partner D1 ON O.id_dobavitelj = D1.id_kupca
  LEFT JOIN dbo.Vrst_opr V ON O.id_vrste = V.id_vrste
  LEFT JOIN dbo.Ponudba F ON O.id_pon = F.id_pon
  LEFT JOIN dbo.Odobrit O1 ON O.id_odobrit_veza = O1.id_odobrit