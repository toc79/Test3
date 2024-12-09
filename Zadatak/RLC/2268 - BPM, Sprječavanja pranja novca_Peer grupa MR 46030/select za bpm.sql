begin tran
update dbo.general_register set VAL_NUM = cast(LEFT(em.weight, 1) as int), val_bit = cast(case when RIGHT(em.weight, 1) = 'H' then 1 else 0 end as bit)  
from dbo.GENERAL_REGISTER gr
join dbo._tmp_ev_model em on gr.ID_KEY=em.id_key
where gr.ID_REGISTER = 'ev_model' and gr.VAL_CHAR = 'E' 

select cast(LEFT(weight, 1) as int) as val_num_new, cast(case when RIGHT(weight, 1) = 'H' then 1 else 0 end as bit) as val_bit_new, * 
from dbo.GENERAL_REGISTER gr
join dbo._tmp_ev_model em on gr.ID_KEY=em.id_key
where gr.ID_REGISTER = 'ev_model' and gr.VAL_CHAR = 'E' 
--rollback
--commit

select case when opis_tuj3 is null or opis_tuj3 = '' then '1' else rtrim(opis_tuj3) end As customer_sif_dej_mark
	, *
From dbo.dejavnos --Where sif_dej = ${customer_sif_dej}
where 1=1
and opis_tuj3 is null or opis_tuj3 = '' 
and SIF_DEJ = (Select sif_dej From dbo.partner where id_kupca = '033986')

select distinct opis_tuj3 As customer_sif_dej_mark From dbo.dejavnos 


Select  cast(round((cast(case when d.opis_tuj3 is null or d.opis_tuj3 = '' then '1' else rtrim(d.opis_tuj3) end as decimal(18,4)) + ev_model.val_num) / 2, 0) as int) As customer_risk_mark
	, case when opis_tuj3 is null or opis_tuj3 = '' then '1' else rtrim(opis_tuj3) end As customer_sif_dej_mark
	, ev_model.val_num, pl.*
From dbo.partner par
left join dbo.dejavnos d on par.sif_dej = d.sif_dej
outer apply  dbo.gfn_PEval_LastEvaluationOnTargetDateForEvalType(getdate(), par.id_kupca, 'E') pl
left join (select gr.id_key, gr.val_num  
			from dbo.GENERAL_REGISTER gr
			where gr.ID_REGISTER = 'ev_model' and gr.VAL_CHAR = 'E') ev_model on pl.eval_model = ev_model.id_key
where par.id_kupca = '0' --Where sif_dej  ${customer_sif_dej}  ${customer_id}
--što kada nema ocjene id_kupca nije unesen i time 

Select CAST(ev_model.val_num as int) as customer_peergroup_mark, * 
From dbo.partner par
outer apply  dbo.gfn_PEval_LastEvaluationOnTargetDateForEvalType(getdate(), par.id_kupca, 'E') pl
left join (select gr.id_key, gr.val_num  
			from dbo.GENERAL_REGISTER gr
			where gr.ID_REGISTER = 'ev_model' and gr.VAL_CHAR = 'E') ev_model on pl.eval_model = ev_model.id_key
where par.id_kupca = '033986' --Where sif_dej  ${customer_sif_dej}  ${customer_id}

Select CAST(ev_model.val_num as int) as customer_peergroup_mark 
From dbo.partner par
outer apply dbo.gfn_PEval_LastEvaluationOnTargetDateForEvalType(getdate(), par.id_kupca, 'E') pl
left join (select gr.id_key, gr.val_num  
			from dbo.GENERAL_REGISTER gr
			where gr.ID_REGISTER = 'ev_model' and gr.VAL_CHAR = 'E') ev_model on pl.eval_model = ev_model.id_key
where par.id_kupca = '033986' --Where sif_dej  ${customer_sif_dej}  ${customer_id}

select gr.id_key, gr.val_num, *  
			from dbo.GENERAL_REGISTER gr
			where gr.ID_REGISTER = 'ev_model' and gr.VAL_CHAR = 'E'
			
			
			select * from dbo.bpm_process_instance where id = 1778
select * from dbo.bpm_data_field_instance where id_process_instance = 1778 
select * from dbo.bpm_def_data_field where id_process_version = 55 and name = 'customer_not_present'
select * from dbo.bpm_data_field_instance dfi
join dbo.bpm_def_data_field ddf on ddf.id = dfi.id_data_field_definition
where dfi.id_process_instance = 1778 
and ddf.id_process_version = 55 
and ddf.name in ('global_mark_xc', 'customer_not_present', 'global_customer_is_fi')

declare @id varchar(100) = '1778'
Select CAST(val_text as xml)
From dbo.gv_ods_data_field
where id_ods_data_document in 
(select distinct id_ods_data_document from dbo.gv_ods_data_field where val_int= @id And field_sys_id = 'INSTANCE_ID' And document_sys_id ='ZSPNFT_INSTANCE_DATA')
and field_sys_id = 'instance_xml_data'
