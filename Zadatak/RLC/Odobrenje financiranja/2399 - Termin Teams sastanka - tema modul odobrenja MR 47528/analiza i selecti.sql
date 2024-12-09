select * from dbo.wf_status
select * from dbo.WF_WorkFlow where id_status_old = 'AMM' or id_status_new = 'AMM'
select dbo.gfn_GetCustomSettings('NOVA_SYS_EMAIL_FROM')


select * from dbo.xdoc_template where id_xdoc_template=22
select top 10 * from dbo.arh_xdoc_template where id_xdoc_template=22 order by time 
select top 10 * from dbo.arh_xdoc_template where id_xdoc_template=22 and sql_data_select like '%min%' order by time 
select ISNULL(min(date_inserted),getdate()) as min_date_inserted, ISNULL(max(date_inserted),getdate()) as max_date_inserted from dbo.xdoc_run_history Where id_xdoc_template = 22
select top 200 * from dbo.xdoc_run_history Where id_xdoc_template = 22 and date_e order by date_inserted desc
select top 200 * from dbo.xdoc_document Where id_xdoc_template = 22 and date_exported between '20210902' and '20210903' order by 1 desc

--DECLARE @id_xdoc_template int
--SET @id_xdoc_template = 22

--select cast(id_history as char(30)) as doc_id
--from dbo.wf_history 
--WHERE date_entered >= (select ISNULL(max(date_inserted),getdate()-1) as max_date_inserted from dbo.xdoc_run_history Where status='C' and id_xdoc_template = @id_xdoc_template)

select * 
from dbo.wf_history 
where id_history in (select doc_id from dbo.xdoc_document Where id_xdoc_template = 22 and date_exported between '20210902' and '20210903')
and id_status_old in ('AMM')

select * from dbo.odobrit where id_odobrit= 45857





select * from dbo.WF_Status
--select * from dbo.wf_workflow
select * from dbo.wf_workflow where id_status_old='AMM' or id_status_new = 'AMM'

--begin tran 
--INSERT INTO dbo.WF_Status(id_process,id_status,title,description,check_assigner,is_start,is_end,change_data) VALUES('ODB','AMM','Asset manager','Mišljenje asset managera',1,0,0,0)
--INSERT INTO dbo.wf_workflow(id_process,id_status_old,id_status_new,assign_to_owner,default_comment) VALUES('ODB','AMM','KRK',0,NULL)
--INSERT INTO dbo.wf_workflow(id_process,id_status_old,id_status_new,assign_to_owner,default_comment) VALUES('ODB','CRM','AMM',0,NULL)
--rollback
--commit
select * from dbo.WF_StatusUser where username like '%g_tomislav%'
begin tran
insert into dbo.WF_StatusUser
select distinct 'ODB', id_status, 'g_tomislav', NULL, 0  from dbo.WF_StatusUser

insert into dbo.WF_StatusUser values ('ODB', 'AMM', 'g_tomislav', NULL, 0)

select * from dbo.WF_Status
select * from dbo.wf_workflow where id_status_old='AMM' or id_status_new = 'AMM'
select * from dbo.WF_StatusUser

exec dbo.tsp_generate_inserts 'wf_workflow', 'dbo', 'FALSE', '##inserts', 'where id_status_old=''AMM'' or id_status_new = ''AMM'''
select * from ##inserts
--drop table ##inserts



select * from dbo.WF_Status
select * from dbo.wf_workflow where id_status_old='AMM' or id_status_new = 'AMM'

select * from dbo.WF_StatusUser where id_status = 'KRK'


select * from dbo.WF_StatusUser where id_status = 'KRK'

insert into dbo.WF_StatusUser values ('ODB','AMM','inesj'    , NULL,	0)
insert into dbo.WF_StatusUser values ('ODB','AMM','marijanam', NULL,	0)
insert into dbo.WF_StatusUser values ('ODB','AMM','nikolas'  , NULL,	0)
insert into dbo.WF_StatusUser values ('ODB','AMM','zoricav'  , NULL,	0)


SELECT 
	a.id_odobrit, a.osnova, a.id_pon, a.id_doc, a.nacin_leas, a.id_wf_document, a.id_tec, a.naziv_kup, a.id_frame, a.frame_opis, a.username_vnesel, 
	a.datum_vnosa, a.username_dodeljeno, a.status, a.assigned_to_full_name, a.username_referent_to_full_name, a.vec_ponudb, a.aktivna, a.id_vrste, 
	a.naziv_opr, a.pred_naj, a.id_kupca, a.naziv_kup_pon, a.kupec_naziv, a.kupec_ulica, a.kupec_id_poste, a.kupec_mesto, a.kupec_crna_lista, 
	a.kupec_odobritev, a.kupec_zavrnitev, a.id_dobavitelj, a.dobavitelj_naziv, a.dobavitelj_dav_stev, a.dobavitelj_emso, a.dobavitelj_ulica, 
	a.dobavitelj_id_poste, a.dobavitelj_mesto, a.dobavitelj_crna_lista, a.dobavitelj_pogodb, a.obligoLH, a.obligoLH_vred, a.dat_pricak, 
	cast(a.opis_pred as [text]) as opis_pred, a.vr_val, a.vr_val_val, a.vr_ocen_vred, a.vr_ocen_vred_val, a.vr_ocen_vred_tip, a.vr_ocen_vred_datum, 
	a.MPC, a.MPC_val, a.letnik, cast(a.ocena_tveganja as [text]) as ocena_tveganja, a.rizik_predmeta_financiranja, a.skupina_predmeta_financiranja, 
	a.kdo_provizija, a.plac_dob, a.boniteta, a.bilanca_datum, a.evaluacija_datum, a.prv_obr, a.varscina, a.net_nal, a.ost_obr, a.opcija, a.obr_mera, 
	a.ostanek_dolga, a.ZNPL, a.BOD_debit, a.BOD_glav, a.obligo, a.man_str, a.stroski_zt, a.stroski_pz, a.zav_fin, a.st_obrok, a.traj_naj, 
	a.pokritost_zavar, a.tip_DDV, a.tip_DDV_traj, cast(a.porostva_dod_opis as [text]) as porostva_dod_opis, 
	cast(a.zavar_ostalo as [text]) as zavar_ostalo, a.Znesek_DDV, a.is_start, a.is_end, a.title, a.frame_velja_do, a.frame_dat_izteka, a.vin, 
	a.id_odobrit_veza, a.id_doc_veza, a.prevozeni_km, a.id_odobrit_tip, a.id_odobrit_kateg, a.id_cont, a.id_pog, a.id_planp_cl_content, a.id_p_eval, 
	a.id_kupca_pl, a.robresti_val, a.BOD_robresti, a.kategorija1, a.kategorija2, a.dat_1registracije, a.stroski_x, a.max_st_kloniranj
FROM dbo.gfn_odobrit_main_view(44405) a

SELECT * FROM dbo.gfn_WF_ListAssigners('ODB', 'AMM') ORDER BY user_desc

SELECT * FROM dbo.WF_Status WHERE id_process = 'ODB'
SELECT * FROM dbo.gfn_WF_ListStatuses('ODB','AMM')
SELECT assign_to_owner FROM dbo.wf_workflow WHERE id_process = 'ODO' AND id_status_old = 'AMM' AND id_status_new = 'KRK'


