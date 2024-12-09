CREATE VIEW [dbo].[gv_ods_data_field]  
AS  
  
select  
 odh.document_sys_id,  
 odh.doc_desc,  
 odh.id_ods_data_document,  
 odh.field_sys_id,  
 odh.field_code,  
 odh.datatype,  
 odh.field_desc,  
 odh.id_ods_data_field,  
 odh.val_int,  
 odh.val_decimal,  
 odh.val_str,  
 odh.val_bit,  
 odh.val_datetime,  
 odh.val_text,  
 odh.valid_since,  
 odh.valid_to  
from   
 dbo.gv_ods_data_field_history odh  
where   
    odh.valid_to is null  
	
	
CREATE VIEW [dbo].[gv_ods_data_field_history]  
AS  
  
select  
 def_doc.document_sys_id,  
 def_doc.description as doc_desc,  
 dat_doc.id_ods_data_document,  
 def_fi.field_sys_id,  
 def_fi.field_code,  
 def_fi.datatype,  
 def_fi.description as field_desc,  
 dat_fi.id_ods_data_field,  
 dat_fi.val_int,  
 dat_fi.val_decimal,  
 dat_fi.val_str,  
 dat_fi.val_bit,  
 dat_fi.val_datetime,  
 dat_fi.val_text,  
 dat_fi.valid_since,  
 dat_fi.valid_to  
from   
 dbo.ods_data_field dat_fi  
 inner join dbo.ods_data_document dat_doc on dat_fi.id_ods_data_document = dat_doc.id_ods_data_document  
 inner join dbo.ods_def_field def_fi on def_fi.id_ods_def_field = dat_fi.id_ods_def_field  
    inner join dbo.ods_def_document def_doc on def_doc.id_ods_def_document = dat_doc.id_ods_def_document  
where  
 dat_doc.is_deleted = 0  